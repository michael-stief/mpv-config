local loop_active = false
local skip = 0.01
local interval = 0.33
local duration = 0

local min_skip = 30
local max_skip = 120

local mp = require("mp")

local function loop()
    if not loop_active then
        return
    end

    local current_cache = mp.get_property_number("demuxer-cache-duration") or 0
--  local duration = mp.get_property_number("duration") or 0
    local time_pos = mp.get_property_number("time-pos") or 0
    local target_time

    if current_cache > duration * skip then
        target_time = time_pos + (duration * skip)
        mp.osd_message(string.format("Seeking: +%.1f%%", skip * 100), interval)
    elseif current_cache > min_skip then
        target_time = time_pos + (current_cache * 0.5)
        mp.osd_message(string.format("Seeking: +%.0fs", (current_cache * 0.5)), interval)
    else
        mp.osd_message("Seeking: cache low", interval)
    end

    if target_time then
       mp.commandv("seek", target_time, "absolute+keyframes")
--     mp.set_property_number("time-pos", target_time)
--     mp.command_native({"seek", target_time, "absolute+keyframes"})
    end

    mp.add_timeout(interval, loop)
end

local function toggle_loop()
    loop_active = not loop_active
    if loop_active then
        loop()
    end
end

local function on_duration_change(event)
    duration = mp.get_property_number("duration")

    if duration and duration > 1 then
        if duration / 100 > max_skip then
             skip = max_skip / duration
        elseif duration / 100 < min_skip then
             skip = min_skip / duration
        else
             skip = 0.01
        end
    end
end

mp.register_event("file-loaded", on_duration_change)
mp.add_key_binding("y", "toggle-loop", toggle_loop)
