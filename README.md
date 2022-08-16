# ImNotify
Dear ImGui Nim library that draws some nice-looking notifications. (Based upon [patrickcjk/imgui-notify](https://github.com/patrickcjk/imgui-notify))

```
nimble install imnotify
```

## Basic
```nim
var toaster = initToaster(spacing = 10f) # Spacing between toasts
toaster.addInfo("I'm a notification full of useful information", title = "Hello")

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

_Note: to modify a toast colors use `Header` and `HeaderHovered` before `toaster.draw()`._

## Demo
For an interactive demo see [demo/](https://github.com/Patitotective/ImNotify/tree/main/demo).  
You have to have nimgl and imnotify installed.
```
git clone https://github.com/Patitotective/ImNotify
cd ImNotify/demo
nim c -r demo
```

https://user-images.githubusercontent.com/79225325/184793063-42c0a056-5ab4-4e9f-955c-ffc40ef1133d.mp4

## About
- GitHub: https://github.com/Patitotective/ImNotify.
- Discord: https://discord.gg/as85Q4GnR6.
- Icon Font: https://forkaweso.me (MIT).

Contact me:
- Discord: **Patitotective#0127**.
- Twitter: [@patitotective](https://twitter.com/patitotective).
- Email: **cristobalriaga@gmail.com**.
