local target_fps = 23

mp.add_periodic_timer(1, function()
    local fps = mp.get_property_native("estimated-vf-fps")
    if fps and math.abs(fps - target_fps) > 0.1 then
        mp.set_property_native("speed", fps / target_fps)
    else
        mp.set_property_native("speed", 1)
    end
end)
