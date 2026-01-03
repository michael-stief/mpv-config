local loop_active = false
local duration = 0
local seek_interval = 900
local play_duration = 2
local last_seek_time = 0

local mp = require("mp")

local function loop()
    if not loop_active then
        return
    end

    duration = mp.get_property_number("duration")
    seek_interval = duration / 30
    if seek_interval > 1200 then
        seek_interval = 1200
        play_duration = 3
    end
    if seek_interval < 300 then
        seek_interval = 300
    end

    local time_pos = mp.get_property_number("time-pos") or 0
    local target_time = last_seek_time + seek_interval

    if time_pos > last_seek_time + play_duration then
        last_seek_time = target_time
        mp.osd_message(string.format("Seeking: +%d seconds", seek_interval), 1)
        mp.commandv("seek", target_time, "absolute+exact")
    else
        mp.osd_message(string.format("Preview: %.0f/%.0f seconds", time_pos - last_seek_time, play_duration), 1)
    end

    mp.add_timeout(0.1, loop)
end

local function toggle_loop()
    loop_active = not loop_active
    if loop_active then
        last_seek_time = mp.get_property_number("time-pos") or 0
        loop()
    end
end

mp.register_event("file-loaded", on_duration_change)
mp.add_key_binding("?", "toggle-loop", toggle_loop)
