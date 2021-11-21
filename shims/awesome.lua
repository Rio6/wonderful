local lgi       = require("lgi")
local gears_obj = require("gears.object")

-- Emulate the C API classes. They differ from C API objects as connect_signal
-- doesn't take an object as first argument and they support fallback properties
-- handlers.
local function _shim_fake_class()
    local obj = gears_obj()
    obj._private = {}

    -- Deprecated.
    obj.data = obj._private

    local meta = {
        __index     = function()end,
        __newindex = function()end,
    }

    obj._connect_signal    = obj.connect_signal
    obj._disconnect_signal = obj.disconnect_signal

    function obj.connect_signal(name, func)
        return obj._connect_signal(obj, name, func)
    end

    function obj.disconnect_signal(name, func)
        return obj._disconnect_signal(obj, name, func)
    end

    function obj.set_index_miss_handler(handler)
        meta.__index = handler
    end

    function obj.set_newindex_miss_handler(handler)
        meta.__newindex = handler
    end

    function obj.emit_signal(name, c, ...)
        local conns = obj._signals[name] or {strong={}}
        for func in pairs(conns.strong) do
            func(c, ...)
        end
    end

    return obj, meta
end

local function forward_class(obj, class)
    assert(obj.emit_signal)
    local es = obj.emit_signal
    function obj:emit_signal(name, ...)
        es(obj, name, ...)
        class.emit_signal(name, obj, ...)
    end
end

local awesome = _shim_fake_class()
awesome._shim_fake_class = _shim_fake_class
awesome._forward_class = forward_class

awesome.version   = "4"
awesome.api_level = 4
awesome.themes_path = "/usr/share/awesome/themes"
awesome.icons_path = "/usr/share/awesome/icons"
awesome.conffile = resource("rc.lua")
awesome.startup = true

function awesome.register_xproperty()
end

awesome.load_image = lgi.cairo.ImageSurface.create_from_png

function awesome.pixbuf_to_surface(_, path)
    return awesome.load_image(path)
end

function awesome.xrdb_get_value()
    return nil
end

function awesome.spawn(cmd, use_sn, use_stdin, use_stdout, use_stderr, exit_callback, envp)
    if exit_callback ~= nil then
        -- TODO
        --flags |= G_SPAWN_DO_NOT_REAP_CHILD;
    end

    if type(cmd) == "string" then
        argv, err = lgi.GLib.shell_parse_argv(cmd)
        if argv == false then
            return "spawn: parse error: " .. tostring(err)
        end
    elseif type(cmd) == "table" then
        argv = cmd
    else
        return "spawn: cmd must be string or table"
    end

    if not argv or not argv[1] then
        return "spawn: There is nothing to execute"
    end

    if use_sn then
        -- not supported
    end

    local flags = lgi.GLib.SpawnFlags { "SEARCH_PATH", "CLOEXEC_PIPES" }
    local pid, stdin, stdout, stderr = lgi.GLib.spawn_async_with_pipes(nil, argv, envp, flags)
    if pid == false then
        return tostring(stdin)
    end

    if lgi.GLib.SpawnFlags[flags].DO_NOT_REAP_CHILD then
        --/* Only do this down here to avoid leaks in case of errors */
        --running_child_t child = { .pid = pid, .exit_callback = LUA_REFNIL };
        --luaA_registerfct(L, 6, &child.exit_callback);
        --running_child_array_insert(&running_children, child);
    end

    -- TODO figure out how to pass null to spawn_async_with_pipes
    if not use_stdin then stdin = nil end
    if not use_stdout then stdout = nil end
    if not use_stderr then stderr = nil end

    return pid, 0, stdin, stdout, stderr
end

function awesome.start()
   system_load("rc.lua")()
   awesome.startup = false
end

-- SVG are composited. Without it we need a root surface
awesome.composite_manager_running = true

awesome._modifiers = {
     Shift = {
          {keycode = 50 , keysym = 'Shift_L'    },
          {keycode = 62 , keysym = 'Shift_R'    },
     },
     Lock = {},
     Control = {
          {keycode = 37 , keysym = 'Control_L'  },
          {keycode = 105, keysym = 'Control_R'  },
     },
     Mod1 = {
          {keycode = 64 , keysym = 'Alt_L'      },
          {keycode = 108, keysym = 'Alt_R'      },
     },
     Mod2 = {
          {keycode = 77 , keysym = 'Num_Lock'   },
     },
     Mod3 = {},
     Mod4 = {
          {keycode = 133, keysym = 'Super_L'    },
          {keycode = 134, keysym = 'Super_R'    },
     },
     Mod5 = {
          {keycode = 203, keysym = 'Mode_switch'},
     },
}

function awesome._get_key_name(key)
    return key
end

awesome._active_modifiers = {}

function awesome.quit()
    shutdown()
end

return awesome

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80