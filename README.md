# ImNotify
Dear ImGui Nim library that draws some nice-looking notifications. (Based upon [patrickcjk/imgui-notify](https://github.com/patrickcjk/imgui-notify))

```
nimble install imnotify
```

## Basic
```nim
var toaster = initToaster(spacing = 10f) # Spacing between toasts
toaster.add(initToast(ToastKind.Info, "I'm a notification full of useful information", title = "Hello"))

# Inside Dear ImGui main loop
...
toaster.draw()
```

Read the [docs](https://patitotective.github.io/imnotify) for more.

## Toast Properties
- `kind`: success, error, warning, info or none. It is used to show an icon using [ForkAwesome](https://github.com/patrickcjk/imgui-notify), therefore you need to load an icon font, check out [demo.nim](https://github.com/Patitotective/ImNotify/blob/main/demo/demo.nim).
- `dismissTime`: Dismiss toast after `n` milliseconds. Pass a negative number to disable automatic dismiss.
- `fadeInOutTime`: Fade in out animation duration in milliseconds.
- `padding`: Toast padding.
- `opacity`: Toast default opacity.
- `rounding`: Toast rounding.
- `width`: Toast width.
- `separator`: Draw a separator between the title and content.
- `rightMargin`: Distance between the toast and viewport's right side.
- `closeBtn`: Draw a close button.

_Note: to modify a toast colors use `FrameBg` and `FrameBgHovered` before `toaster.draw()`._

## Demo
For an interactive demo see [demo/](https://github.com/Patitotective/ImNotify/tree/main/demo).  
You have to have nimgl and imnotify installed.
```
git clone https://github.com/Patitotective/ImNotify
cd ImNotify/demo
nim c -r demo
```

https://user-images.githubusercontent.com/79225325/183262973-1a52eda5-0dec-4b87-9c2b-62daa57f8d68.mp4

## About
- GitHub: https://github.com/Patitotective/ImNotify.
- Discord: https://discord.gg/as85Q4GnR6.
- Icon Font: https://forkaweso.me (MIT).

Contact me:
- Discord: **Patitotective#0127**.
- Twitter: [@patitotective](https://twitter.com/patitotective).
- Email: **cristobalriaga@gmail.com**.