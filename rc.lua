local awful = require("awful")
local gears = require("gears")

awful.screen.connect_for_each_screen(function(s)
    awful.tag({ "test" }, s, awful.layout.suit.tile)
end)

client.connect_signal("list", function()
   if #client.get() == 0 then
      awesome.quit()
   end
end)

root.keys(
   awful.key({"Control", "Mod1"}, "t", function()
      awful.spawn.with_line_callback("afsrv_terminal", {
         stdout = function(line)
            print("stdout", line)
         end,
         stderr = function(line)
            print("stderr", line)
         end,
         output_done = function()
            print(done)
         end,
         exit = function(reason, n)
            print("exit", reason, n)
         end
      })
   end)
)

root.buttons(
   awful.button({"Shift"}, 1, function()
      print("pressed")
   end,
   function()
      print("release")
   end)
)
