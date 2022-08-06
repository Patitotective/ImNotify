import std/strformat
import nimgl/imgui
import imnotify/[utils, icons] 

type
  ToastKind* = enum
    None, Success, Warning, Error, Info

  ToastPhase* = enum
    FadeIn, Wait, FadeOut, Expired

  Toast* = object
    kind*: ToastKind
    title*, content*: string
    creationTime, dismissTime*, fadeInOutTime*: int64 ## In milliseconds. Pass a negative number to dismissTime to disable automatic dismiss.
    padding*: ImVec2
    opacity*, rounding*, width*: float32
    separator*: bool ## Draw a separator between the title and content
    rightMargin*: float32 ## Space from the right side
    closeBtn*: bool ## Draw a close button

  Toaster* = object
    data: seq[Toast]
    spacing*: float32 ## Spacing between each toast

proc initToaster*(spacing = 10f): Toaster = 
  Toaster(spacing: spacing)

proc initToast*(
  kind: ToastKind, 
  content: string, 
  title = "", 
  dismissTime = 5000i64,
  fadeInOutTime = 300i64, 
  padding = igVec2(10, 10), 
  opacity = 1f, 
  rounding = 5f, 
  width = 200f, 
  separator = true, 
  rightMargin = 10f, 
  closeBtn = true, 
): Toast = 
  Toast(
    kind: kind, 
    content: content, 
    title: title, 
    creationTime: getMilliseconds(), 
    dismissTime: dismissTime, 
    fadeInOutTime: fadeInOutTime, 
    padding: padding, 
    opacity: opacity, 
    rounding: rounding, 
    width: width, 
    separator: separator, 
    rightMargin: rightMargin, 
    closeBtn: closeBtn, 
  )

proc add*(self: var Toaster, toast: Toast) =
  self.data.add(toast)
  self.data[^1].padding = toast.padding # https://github.com/nimgl/nimgl/issues/83 :[

proc addInfo*(self: var Toaster, content: string, title = "") = 
  self.data.add(initToast(ToastKind.Info, content, title))

proc addSuccess*(self: var Toaster, content: string, title = "") = 
  self.data.add(initToast(ToastKind.Success, content, title))

proc addWarning*(self: var Toaster, content: string, title = "") = 
  self.data.add(initToast(ToastKind.Warning, content, title))

proc addError*(self: var Toaster, content: string, title = "") = 
  self.data.add(initToast(ToastKind.Error, content, title))

proc addNone*(self: var Toaster, content: string, title = "") = 
  self.data.add(initToast(ToastKind.None, content, title))

proc getDefaultTitle*(self: Toast): string = 
  result = self.title

  if result.len == 0:
    if self.kind == ToastKind.None:
      result = ""
    else:
      result = $self.kind

proc getIcon*(self: Toast): string = 
  case self.kind
  of ToastKind.None:
    ""
  of ToastKind.Success:
    FA_CheckCircle
  of ToastKind.Warning:
    FA_ExclamationTriangle
  of ToastKind.Error:
    FA_TimesCircle
  of ToastKind.Info:
    FA_InfoCircle

proc getElapsedTime*(self: Toast): int64 = getMilliseconds() - self.creationTime

proc getPhase*(self: Toast): ToastPhase = 
  let elapsed = self.getElapsedTime()
  let dismiss = self.dismissTime >= 0

  if dismiss and elapsed > self.fadeInOutTime + self.dismissTime + self.fadeInOutTime:
    ToastPhase.Expired
  elif dismiss and elapsed > self.fadeInOutTime + self.dismissTime:
    ToastPhase.FadeOut
  elif elapsed > self.fadeInOutTime:
    ToastPhase.Wait
  else:
    ToastPhase.FadeIn

proc getFadePercent*(self: Toast): float32 = 
  let phase = self.getPhase()
  let elapsed = self.getElapsedTime()

  result = 
    if phase == ToastPhase.FadeIn:
      (elapsed.float32 / self.fadeInOutTime.float32) * self.opacity
    elif phase == ToastPhase.FadeOut:
      (1f - (float32(elapsed - self.fadeInOutTime - self.dismiss_time) / self.fadeInOutTime.float32)) * self.opacity
    else:
      1f * self.opacity

proc draw*(self: var Toaster) = 
  let style = igGetStyle()
  let size = igGetMainViewport().size

  var height = self.spacing
  var expired: seq[int] # List of toast indexes that are already expired therefore will be deleten

  for e in countdown(self.data.high, 0):
    let toast = self.data[e]
    if toast.getPhase() == ToastPhase.Expired: # Remove toast if expired
      expired.add(e)
      continue

    let icon = toast.getIcon()
    let defaultTitle = toast.getDefaultTitle()
    let opacity = toast.getFadePercent() # Get opacity based of the current phase

    igPushStyleVar(Alpha, opacity)
    igPushStyleVar(WindowRounding, toast.rounding)
    igPushStyleVar(WindowPadding, toast.padding)

    igSetNextWindowPos(igVec2(size.x - toast.rightMargin, size.y - height), pivot = igVec2(1f, 1f)) # Set pivot to bottom-right
    igSetNextWindowSize(igVec2(toast.width, 0))
    igSetNextWindowBgAlpha(opacity)

    if igBegin(cstring &"##TOAST{e}", flags = makeFlags(ImGuiWindowFlags.NoDecoration, ImGuiWindowFlags.NoNav, ImGuiWindowFlags.NoBringToFrontOnFocus, ImGuiWindowFlags.NoFocusOnAppearing, ImGuiWindowFlags.NoSavedSettings)):
      let window = igGetCurrentWindow()

      window.igBringWindowToDisplayFront()
      igPushTextWrapPos(igGetContentRegionAvail().x)

      if icon.len != 0:
        igText(cstring icon)

      if defaultTitle.len != 0:
        if icon.len != 0:
          igSameLine()

        igText(cstring defaultTitle)

      if toast.closeBtn and igCloseButton(
        window.getID("#CLOSE"), 
        igVec2((window.pos.x + window.size.x) - igGetFontSize() - (style.framePadding.x * 2) - style.framePadding.x, window.pos.y + style.framePadding.y)
      ):
        expired.add(e)

      if toast.content.len != 0:
        if toast.separator and defaultTitle.len != 0: # Do not draw a separator when there is no title
          igSeparator()

        igText(cstring toast.content)

      igPopTextWrapPos()

      height += igGetWindowHeight() + self.spacing

    igEnd(); igPopStyleVar(3)

  for i in expired:
    self.data.delete(i)
