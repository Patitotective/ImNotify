import std/strutils

import nimgl/imgui, nimgl/imgui/[impl_opengl, impl_glfw]
import nimgl/[opengl, glfw]

import imnotify, imnotify/icons

proc newImFontConfig(mergeMode = false): ImFontConfig =
  result.fontDataOwnedByAtlas = true
  result.fontNo = 0
  result.oversampleH = 3
  result.oversampleV = 1
  result.pixelSnapH = true
  result.glyphMaxAdvanceX = float.high
  result.rasterizerMultiply = 1.0
  result.mergeMode = mergeMode

proc getEnumValues[T: enum](): seq[string] = 
  for i in T:
    result.add($i)

proc cleanString(str: string): string = 
  if '\0' in str:
    str[0..<str.find('\0')].strip()
  else:
    str.strip()

proc newString(lenght: int, default: string): string = 
  result = newString(lenght)
  result[0..default.high] = default

proc igVec2*(x, y: float32): ImVec2 = ImVec2(x: x, y: y)

proc igVec4*(x, y, z, w: float32): ImVec4 = ImVec4(x: x, y: y, z: z, w: w)

proc main() =
  doAssert glfwInit()

  glfwWindowHint(GLFWContextVersionMajor, 3)
  glfwWindowHint(GLFWContextVersionMinor, 3)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE)
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFWResizable, GLFW_TRUE)

  var w: GLFWWindow = glfwCreateWindow(553, 570)
  if w == nil:
    quit(-1)

  w.makeContextCurrent()

  doAssert glInit()

  let context = igCreateContext()
  let io = igGetIO()

  doAssert igGlfwInitForOpenGL(w, true)
  doAssert igOpenGL3Init()

  # igStyleColorsCherry()
  # igStyleColorsLight()

  io.fonts.addFontDefault()

  # Merge ForkAwesome icon font
  var config = newImFontConfig(mergeMode = true)
  var ranges = [FA_Min.uint16,  FA_Max.uint16]

  io.fonts.addFontFromFileTTF("forkawesome-webfont.ttf", 13, config.addr, ranges[0].addr)

  var toaster = initToaster()
  var titleBuffer = newString(100, "Hello")
  var contentBuffer = newString(1024, "I'm a nice-looking toast, customize me")
  var dismissTime = 3000i32
  var fadeInOutTime = 300i32
  var currentKind = int ToastKind.Info
  var padding = [10f, 10f]
  var opacity = 1f
  var rounding = 5f
  var width = 200f
  var separator = true
  var rightMargin = 10f
  var closeBtn = true
  var bgColor = igVec4(0.078f, 0.078f, 0.078f, 1f)
  var hoveredBgColor = igVec4(0.137f, 0.137f, 0.137f, 1f)

  while not w.windowShouldClose:
    glfwPollEvents()

    igOpenGL3NewFrame()
    igGlfwNewFrame()
    igNewFrame()

    igSetNextWindowPos(igVec2(0, 0), ImGuiCond.Always)
    igSetNextWindowSize(igGetMainViewport().workSize, ImGuiCond.Always)

    if igBegin("Example", flags = ImGuiWindowFlags.NoResize):
      igInputTextMultiline("Title", cstring titleBuffer, 100)
      igInputTextMultiline("Content", cstring contentBuffer, 1024)

      var tempDismissTime = dismissTime
      var tempFadeInOutTime = fadeInOutTime

      if igInputInt("Dismiss time (ms)", tempDismissTime.addr) and tempDismissTime >= -1:
        dismissTime = tempDismissTime

      if igInputInt("Fade in/out time (ms)", tempFadeInOutTime.addr) and tempFadeInOutTime >= 0:
        fadeInOutTime = tempFadeInOutTime

      const kinds = getEnumValues[ToastKind]()
      if igBeginCombo("Kind", cstring kinds[currentKind]):
        for e, i in kinds:
          if igSelectable(cstring i, e == currentKind):
            currentKind = e

        igEndCombo()

      igSliderFloat2("Padding", padding, 0f, 50f, "%.1f")
      igSliderFloat("Opacity", opacity.addr, 0.1f, 1f, "%.1f")
      igSliderFloat("Rounding", rounding.addr, 0f, 20f, "%.1f")
      igSliderFloat("Width", width.addr, 50f, 500f, "%.1f")
      igCheckbox("Separator", separator.addr)
      igSliderFloat("Right margin", rightMargin.addr, 0f, 100f, "%.1f")
      igCheckbox("Close button", closeBtn.addr)

      var tempArray = [bgColor.x, bgColor.y, bgColor.z]
      if igColorEdit3("Background color", tempArray):
        bgColor = igVec4(tempArray[0], tempArray[1], tempArray[2], 0)

      tempArray = [hoveredBgColor.x, hoveredBgColor.y, hoveredBgColor.z]
      if igColorEdit3("Hovered background color", tempArray):
        hoveredBgColor = igVec4(tempArray[0], tempArray[1], tempArray[2], 0)

      if igButton("Show"):
        toaster.add(initToast(
          currentKind.ToastKind, 
          contentBuffer.cleanString(), 
          titleBuffer.cleanString(), 
          dismissTime, 
          fadeInOutTime, 
          igVec2(padding[0], padding[1]), 
          opacity, 
          rounding, 
          width, 
          separator, 
          rightMargin, 
          closeBtn,  
        ))

    igEnd()

    igPushStyleColor(Header, bgColor)
    igPushStyleColor(HeaderHovered, hoveredBgColor)
    toaster.draw()
    igPopStyleColor(2)
    # End

    igRender()

    glClearColor(0.45f, 0.55f, 0.60f, 1.00f)
    glClear(GL_COLOR_BUFFER_BIT)

    igOpenGL3RenderDrawData(igGetDrawData())

    w.swapBuffers()

  igOpenGL3Shutdown()
  igGlfwShutdown()
  context.igDestroyContext()

  w.destroyWindow()
  glfwTerminate()

main()