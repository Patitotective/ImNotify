# ImNotify
Dear ImGui Nim library that draws some nice-looking notifications. (Based upon https://github.com/patrickcjk/imgui-notify)

```console
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

_Note: To change toast's background do:_
```nim
...
igPushStyleColor(WindowBg, newColor)
toaster.draw()
igPopStyleColor()
```

## Demo
For an interactive demo see [demo/](https://github.com/Patitotective/ImNotify/tree/main/demo).  
You have to have nimgl and imnotify installed.
```console
git clone https://github.com/Patitotective/ImNotify
cd ImNotify/demo
nim c -r demo
```


## About
- GitHub: https://github.com/Patitotective/ImNotify.
- Discord: https://discord.gg/as85Q4GnR6.
- Icon Font: https://forkaweso.me (MIT).

Contact me:
- Discord: **Patitotective#0127**.
- Twitter: [@patitotective](https://twitter.com/patitotective).
- Email: **cristobalriaga@gmail.com**.