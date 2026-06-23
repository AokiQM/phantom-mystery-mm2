return function(M)
    local lp=game:GetService("Players").LocalPlayer
    local _enabled=false;local _speed=24;local _t=nil
    local function apply()
        local c=lp.Character;if c then local h=c:FindFirstChildOfClass("Humanoid");if h then h.WalkSpeed=_speed end end
    end
    function M.toggleSpeed(s)
        _enabled=s
        if s and not _t then _t=task.spawn(function() while _enabled do apply();task.wait(0.5) end end)
        elseif not s and _t then task.cancel(_t);_t=nil
            local c=lp.Character;if c then local h=c:FindFirstChildOfClass("Humanoid");if h then h.WalkSpeed=16 end end
        end
    end
    function M.setSpeed(v) _speed=math.clamp(v,16,60);apply() end
end
