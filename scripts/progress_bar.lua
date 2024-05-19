local assdraw = require("mp.assdraw")
local last_position = 0
local last_cache_duration = 0

local bar_height = 10
local progress_color = "&HAAAAAA&"
local cache_color = "&H333333&"
local remaining_color = "&H000000&"

function draw_progress_bars()
    local position = mp.get_property_number("time-pos")
    local duration = mp.get_property_number("duration")
    local cache_duration = mp.get_property_number("demuxer-cache-duration")

    if position and duration and cache_duration and (position ~= last_position or cache_duration ~= last_cache_duration) then
        local width = mp.get_property_number("osd-width")
        local height = mp.get_property_number("osd-height")

        local progress_width = width * (position / duration)
        local cache_width = width * (cache_duration / duration)
        local remaining_width = width - progress_width - cache_width

        local ass = assdraw.ass_new()

        ass:draw_start()

        ass:pos(0, height - bar_height)
        ass:append("{\\bord0}{\\c" .. progress_color .. "}")
        ass:rect_cw(0, 0, progress_width, bar_height)

        ass:pos(progress_width, height - bar_height)
        ass:append("{\\bord0}{\\c" .. cache_color .. "}")
        ass:rect_cw(0, 0, cache_width, bar_height)

        ass:pos(progress_width + cache_width, height - bar_height)
        ass:append("{\\bord0}{\\c" .. remaining_color .. "}")
        ass:rect_cw(0, 0, remaining_width, bar_height)

--      ass:pos(0, height - bar_height * 3)
--      ass:append("{\\bord0}{\\c" .. remaining_color .. "}")
--      ass:rect_cw(0, 0, width, bar_height * 2)

        ass:draw_stop()

        mp.set_osd_ass(width, height, ass.text)

        last_position = position
        last_cache_duration = cache_duration
    end
end

mp.add_periodic_timer(0.1, draw_progress_bars)
