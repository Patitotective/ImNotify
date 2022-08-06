# Package

version       = "0.1.0"
author        = "Patitotective"
description   = "A notifications library for Dear ImGui"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.6.5"
requires "nimgl >= 1.3.2"

task docs, "Generate documentation":
  exec "nim doc --git.url:https://github.com/Patitotective/imnotify --git.commit:main --project --outdir:docs src/imnotify.nim"
  exec "echo \"<meta http-equiv=\\\"Refresh\\\" content=\\\"0; url='imnotify.html'\\\" />\" >> docs/index.html"
