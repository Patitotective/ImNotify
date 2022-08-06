import std/[monotimes, times]

import nimgl/imgui

proc igVec2*(x, y: float32): ImVec2 = ImVec2(x: x, y: y)

proc igGetContentRegionAvail*(): ImVec2 = 
  igGetContentRegionAvailNonUDT(result.addr)

proc makeFlags*[T: enum](flags: varargs[T]): T =
  ## Mix multiple flags of a specific enum
  var res = 0
  for x in flags:
    res = res or int(x)

  result = T res

proc getMilliseconds*(): int64 = 
  initDuration(nanoseconds = getMonoTime().ticks).inMilliseconds
