function format_time(time_left)
    local mins = math.floor(time_left / 60)
    local secs = math.floor(time_left % 60)
    return string.format("%01d:%02d", mins, secs)
end

function display_osd()
	-- sync_offset
    local sync_offset = mp.get_property_number("avsync", 0)
	-- time_left
    local duration = mp.get_property_number("duration", 0)
    local time_pos = mp.get_property_number("time-pos", 0)
    local time_left_value = duration and time_pos and (duration - time_pos) or nil
    local time_left = time_left_value and format_time(time_left_value) or "N/A"
	-- cache
    local cache_value = mp.get_property_number("demuxer-cache-duration", 0)
    -- local cache_duration = format_time(math.floor(cache_value))
    local cache_duration = tostring(math.floor(cache_value)) .. "s"
	-- framedrop
	local frame_drop_count = mp.get_property_number("frame-drop-count") or 0
	local decoder_frame_drop_count = mp.get_property_number("decoder-frame-drop-count") or 0
	local framedrop_value = frame_drop_count + decoder_frame_drop_count
	local framedrop = framedrop_value > 0 and string.format(" D%d", framedrop_value) or ""
	-- av sync
	local sync_offset_value = mp.get_property_number("avsync")
	local sync_offset = (sync_offset_value and math.abs(sync_offset_value) >= 0.01) and string.format(" S%0.1f", sync_offset_value) or ""
    local filename = (duration > 60 and time_pos < 10) and " " .. mp.get_property("filename") or ""

--  "-%s%s%s (%s) | ${filename}${?chapter: | Chapter: ${chapter}}",
    local osd_status_msg = string.format("-%s%s%s +%s%s", time_left, framedrop, sync_offset, cache_duration, filename)
    mp.set_property("osd-status-msg", osd_status_msg)
end

mp.observe_property("time-pos", "number", display_osd)
mp.observe_property("duration", "number", display_osd)
mp.observe_property("demuxer-cache-duration", "number", display_osd)
