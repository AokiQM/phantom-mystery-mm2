return function(M)
    local cmds = {}
    function cmds.register(name, fn, desc) cmds[name] = { fn = fn, desc = desc } end
    cmds.register("help", function()
        local lines = { "=== 破坏者谜团 命令 ===" }
        for k, v in pairs(cmds) do
            if type(v) == "table" then
                table.insert(lines, "/" .. k .. " - " .. (v.desc or ""))
            end
        end
        return table.concat(lines, "\n")
    end, "显示帮助")
    cmds.register("ver", function() return "破坏者谜团 v1.0 | MM2" end, "版本信息")
    function M.runCommand(cmd)
        local parts = {}
        for p in (cmd or ""):gmatch("%S+") do table.insert(parts, p) end
        local name = parts[1] and parts[1]:lower()
        if name and cmds[name] then
            local ok, r = pcall(cmds[name].fn, table.unpack(parts, 2))
            return ok and (r or "") or "错误"
        end
        return "未知命令"
    end
    return M
end
