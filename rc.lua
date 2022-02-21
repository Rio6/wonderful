local awful = require("awful")
local gears = require("gears")

gears.timer.start_new(10, function()
   awesome.quit()
end)

awful.screen.connect_for_each_screen(function(s)
    awful.tag({ "test" }, s, awful.layout.suit.tile)
end)


print(awful.spawn.with_line_callback("afsrv_terminal", {
   stdout = print,
   stderr = print,
}))
