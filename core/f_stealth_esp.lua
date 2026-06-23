return function(M)
    local lp=game:GetService("Players").LocalPlayer
    local _enabled=false;local _t=nil
    local function loop()
        while _enabled do
            local ok,crc=pcall(function() return require(game:GetService("ReplicatedStorage").Modules.CurrentRoundClient) end)
            if ok and crc and crc.PlayerData then
                for name,data in pairs(crc.PlayerData) do
                    if type(data)=="table" and (data.Role=="Murderer" or data.role=="Murderer") then
                        local p=game:GetService("Players"):FindFirstChild(name)
                        if p and p.Character then
                            for _,part in ipairs(p.Character:GetChildren()) do
                                if part:IsA("BasePart") then pcall(function() part.Transparency=math.min(part.Transparency,0.2) end) end end
                            for _,obj in ipairs(p.Character:GetDescendants()) do
                                if obj:IsA("Highlight") and obj.Name~="MM2_ESP" then pcall(function() obj:Destroy() end) end end
                        end end end end end
            task.wait(0.1)
        end end
    function M.toggleStealthESP(s)
        _enabled=s
        if s and not _t then _t=task.spawn(loop)
        elseif not s and _t then task.cancel(_t);_t=nil end
    end
end
