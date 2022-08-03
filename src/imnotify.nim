import std/strformat
import nimgl/imgui
import imnotify/[utils, icons] 

# defined NOTIFY_USE_SEPARATOR

#define NOTIFY_INLINE         inline
#define NOTIFY_NULL_OR_EMPTY(str)   (!str ||! strlen(str))
#define NOTIFY_FORMAT(fn, format, ...)  if (format) { va_list args va_start(args, format) fn(format, args, __VA_ARGS__) va_end(args) }

type
  ToastKind* = enum
    None, Success, Warning, Error, Info

  ToastPhase* = enum
    FadeIn, Wait, FadeOut, Expired

  ToastPos* = enum
    TopLeft, TopCenter, TopRight, BottomLeft, BottomCenter, BottomRight, Center

  Toast* = object
    kind*: ToastKind
    title*, content*: string
    creationTime, dismissTime*, fadeInOutTime*: int64 ## In milliseconds
    padding*: ImVec2
    opacity*, rounding*, width*: float32
    separator*: bool ## Draw a separator between the title and content

  Notifications* = object
    data: seq[Toast]
    spacing*: float32 ## Spacing between each toast

proc notifications*(spacing = 10f): Notifications = 
  Notifications(spacing: spacing)

proc toast*(kind: ToastKind, content: string, title = "", dismissTime = 3000i64, fadeInOutTime = 150i64, padding = igVec2(10, 10),  opacity = 1f, rounding = 5f, width = 200f, separator = false): Toast = 
  Toast(kind: kind, content: content, title: title, creationTime: getMilliseconds(), dismissTime: dismissTime, fadeInOutTime: fadeInOutTime, padding: padding, opacity: opacity, rounding: rounding, width: width, separator: separator)

proc add*(self: var Notifications, toast: Toast) =
  self.data.add(toast)
  assert self.data[^1].padding != toast.padding
  echo self.data[^1].padding, " - ", toast.padding

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

  if elapsed > self.fadeInOutTime + self.dismissTime + self.fadeInOutTime:
    ToastPhase.Expired
  elif elapsed > self.fadeInOutTime + self.dismissTime:
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

proc draw*(self: var Notifications) = 
  let size = igGetMainViewport().size

  var height = 0f
  var expired: seq[int] # List of toast indexes that are already expired therefore will be deleten

  for e, toast in self.data:
    # Remove toast if expired
    if toast.getPhase() == ToastPhase.Expired:
      expired.add(e)
      continue

    # Get icon, title and other data
    let icon = toast.getIcon()
    let defaultTitle = toast.getDefaultTitle()
    let opacity = toast.getFadePercent() # Get opacity based of the current phase

    igPushStyleVar(Alpha, opacity)
    igPushStyleVar(WindowRounding, toast.rounding)
    igPushStyleVar(WindowPadding, toast.padding)
    # igPushStyleColor(WindowBg, igGetColorU32(ChildBg))

    igSetNextWindowPos(igVec2(size.x - toast.padding.x, size.y - self.spacing - height), ImGuiCond.Always, igVec2(1f, 1f))
    igSetNextWindowSize(igVec2(toast.width, 0))

    if igBegin(cstring &"##TOAST{e}", flags = makeFlags(ImGuiWindowFlags.NoDecoration, ImGuiWindowFlags.NoInputs, ImGuiWindowFlags.NoNav, ImGuiWindowFlags.NoBringToFrontOnFocus, ImGuiWindowFlags.NoFocusOnAppearing)):
      igGetCurrentWindow().igBringWindowToDisplayFront()
      # Here we render the toast content
      igPushTextWrapPos(toast.width) # We want to support multi-line text, this will wrap the text after 1/3 of the screen width

      let titleRendered = icon.len != 0 or defaultTitle.len != 0

      # If an icon is set
      if icon.len != 0:
        igText(cstring icon)

      # If a title is set
      if defaultTitle.len != 0:
        # If a title and an icon is set, we want to render on same line
        if icon.len != 0:
          igSameLine()

        igText(cstring defaultTitle) # Render title text

      # In case ANYTHING was rendered in the top, we want to add a small padding so the text (or icon) looks centered vertically
      if titleRendered and toast.content.len != 0:
        igSetCursorPosY(igGetCursorPosY() + 5f) # Must be a better way to do this!!!!

      # If a content is set
      if toast.content.len != 0 and titleRendered:
        if toast.separator:
          igSeparator()

        igText(cstring toast.content) # Render content text

      igPopTextWrapPos()

      height += igGetWindowHeight()

    igEnd(); igPopStyleVar(3); igPopStyleColor()

  for i in expired:
    self.data.delete(i)
