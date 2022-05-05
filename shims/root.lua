local keyboard = system_load("builtin/keyboard.lua")()
local root = {_tags={}}

local gtable = require("gears.table")
local cairo  = require( "lgi" ).cairo

local mod_maps = {
    lshift = "Shift",
    rshift = "Shift",
    lalt = "Mod1",
    ralt = "Mod1",
    lctrl = "Control",
    rctrl = "Control",
    lmeta = "Mod4",
    rmeta = "Mod4",
    num = "Num",
    caps = "Lock",
    mode = "Mode",
}

function root:tags()
    return root._tags
end

function root.size()
    local geo = {x1 = math.huge, y1 = math.huge, x2 = 0, y2 = 0}

    for s in screen do
        geo.x1 = math.min( geo.x1, s.geometry.x                   )
        geo.y1 = math.min( geo.y1, s.geometry.y                   )
        geo.x2 = math.max( geo.x2, s.geometry.x+s.geometry.width  )
        geo.y2 = math.max( geo.y2, s.geometry.y+s.geometry.height )
    end

    return math.max(0, geo.x2-geo.x1), math.max(0, geo.y2 - geo.y1)
end

function root.size_mm()
    local w, h = root.size()
    return (w/96)*25.4, (h/96)*25.4
end

function root.cursor() end

-- GLOBAL KEYBINDINGS --

local keys = {}

function root.keys(k)
    keys = k or keys
    return keys
end

-- FAKE INPUTS --

local function match_modifiers(mods1, mods2)
    if #mods1 ~= #mods2 then return false end

    for _, mod1 in ipairs(mods1) do
        if not gtable.hasitem(mods2, mod1) then
            return false
        end
    end

    return true
end

local function execute_keybinding(key, mods, event)
    for _, v in ipairs(keys) do
        if key == v.key and match_modifiers(v.modifiers, mods) then
            v:emit_signal(event)
            return
        end
    end
end

function root.fake_input(event_type, detail, x, y)
    -- TODO
end

function root.buttons()
    return {}
end

function root._wallpaper(pattern)
    if not pattern then return root._wallpaper_surface end

    -- Make a copy because `:finish()` is called by `root.wallpaper` to avoid
    -- a memory leak in the "real" backend.
    local target = cairo.ImageSurface(cairo.Format.RGB32, root.size())
    local cr     = cairo.Context(target)

    cr:set_source(pattern)
    cr:rectangle(0, 0, root.size())
    cr:fill()

    root._wallpaper_pattern = cairo.Pattern.create_for_surface(target)
    root._wallpaper_surface = target

    return target
end


function root.set_newindex_miss_handler(h)
    rawset(root, "_ni_handler", h)
end

function root.set_index_miss_handler(h)
    rawset(root, "_i_handler", h)
end

function root.handle_event(eve)
    local handled
    if eve.kind == "digital" then
        if eve.translated then -- keyboard
            local action = eve.active and "press" or "release"
            local key = keyboard[eve.keysym]
            local mods = {}

            for _, mod in ipairs(decode_modifiers(eve.modifiers)) do
                table.insert(mods, select(1, mod_maps[mod]))
            end

            if keygrabber._current_grabber then
                keygrabber._current_grabber(mods, key, action)
                handled = true
            else
                handled = execute_keybinding(key, mods, action)
            end
        end
    end
    if not handled and client.focus ~= nil then
        target_input(client.focus.window, eve)
    end
end

return setmetatable(root, {
    __index = function(self, key)
        if key == "screen" then
            return screen[1]
        end
        local h = rawget(root,"_i_handler")
        if h then
            return h(self, key)
        end
    end,
    __newindex = function(...)
        local h = rawget(root,"_ni_handler")
        if h then
            h(...)
        end
    end,
})

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
