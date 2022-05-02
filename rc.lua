local awful = require("awful")
local gears = require("gears")

awful.screen.connect_for_each_screen(function(s)
    awful.tag({ "test" }, s, awful.layout.suit.tile)
end)

awful.spawn("afsrv_terminal")

client.connect_signal("list", function()
   if #client.get() == 0 then
      awesome.quit()
   end
end)
