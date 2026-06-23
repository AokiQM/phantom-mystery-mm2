_G.BFH = _G.BFH or {}
do
local Components, UI = _G.BFH.Components, _G.BFH.UI
local Tween, Theme = _G.BFH.Tween, _G.BFH.Theme
local ContainsText = _G.BFH.ContainsText
local AddCorner, AddPadding = _G.BFH.AddCorner, _G.BFH.AddPadding
local SetScrollCanvas = _G.BFH.SetScrollCanvas
local New = _G.BFH.New
local RefreshContentCanvas = _G.BFH.RefreshContentCanvas
    local AppConfig = {
        Name = "破坏者谜团",
        Version = "1.0.0",
        Author = "青木作者",
        GuiName = "MM2Framework",
        ShellMode = true,
        DefaultPage = "mm2",
        MarqueeText = "反馈",
        AnnouncementTitle = "公告",
        AnnouncementText = [=[001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试
001001测试测试测试]=],
        WindowPresets = {
            { label = "迷你", value = "mini", size = Vector2.new(620, 420) },
            { label = "标准", value = "standard", size = Vector2.new(760, 500) },
            { label = "宽屏", value = "wide", size = Vector2.new(900, 560) },
            { label = "大型", value = "large", size = Vector2.new(1020, 640) },
        },
        MinimumDpi = 65,
        MaximumDpi = 140,
        ToggleKey = Enum.KeyCode.RightShift,
        MaxRecent = 18,
    }
_G.BFH.AppConfig = AppConfig

    local Registry = {
        Callbacks = {},
        Meta = {},
    }
    local Pages = {
        List = {},
        ById = {},
    }
_G.BFH.Registry = Registry
_G.BFH.Pages = Pages

    local State = {
        CurrentPage = AppConfig.DefaultPage,
        SearchText = "",
        Toggles = {},
        Sliders = {},
        Inputs = {},
        Dropdowns = {},
        Segments = {},
        Collapsed = {},
        SubPages = {},
        Logs = {},
        Controls = {},
        VisibleControlKeys = {},
        Favorites = {},
        Recent = {},
        Keybinds = {},
        Colors = {},
        Numbers = {},
        MultiDropdowns = {},
        ConfirmEnabled = true,
        SearchScope = "current",
        SearchReturnPage = AppConfig.DefaultPage,
        WindowPreset = "mini",
        WindowTransparency = 0,
        DpiScale = 0.75,
        }
_G.BFH.State = State

    function _G.BFH.State:GetBucket(kind)
        if kind == "toggle" then
            return self.Toggles
        elseif kind == "slider" then
            return self.Sliders
        elseif kind == "input" then
            return self.Inputs
        elseif kind == "dropdown" then
            return self.Dropdowns
        elseif kind == "segment" then
            return self.Segments
        elseif kind == "number" then
            return self.Numbers
        elseif kind == "color" then
            return self.Colors
        elseif kind == "multi-dropdown" then
            return self.MultiDropdowns
        end

        return self.Inputs
    end

    function _G.BFH.State:Get(kind, key, defaultValue)
        local bucket = self:GetBucket(kind)
        if bucket[key] == nil then
            bucket[key] = defaultValue
        end

        return bucket[key]
    end

    function _G.BFH.State:Set(kind, key, value)
        if type(value) == "string" and value:find("^table: 0") then return end
        local strOnly = { input = true, dropdown = true, segment = true, color = true }
        if strOnly[kind] and type(value) == "table" then return end
        self:GetBucket(kind)[key] = value
    end

    function _G.BFH.State:IsFavorite(key)
        return self.Favorites[key] == true
    end

    function _G.BFH.State:SetFavorite(key, enabled)
        if enabled then
            self.Favorites[key] = true
        else
            self.Favorites[key] = nil
        end
    end

    function _G.BFH.State:TouchRecent(key, title, page)
        if not key or key == "" then
            return
        end

        for index = #self.Recent, 1, -1 do
            if self.Recent[index].key == key then
                table.remove(self.Recent, index)
            end
        end

        table.insert(self.Recent, 1, {
            key = key,
            title = title or key,
            page = page or "",
            time = os.date("%H:%M:%S"),
        })

        while #self.Recent > AppConfig.MaxRecent do
            table.remove(self.Recent)
        end
    end

    function _G.BFH.State:ResetControls()
        self.Toggles = {}
        self.Sliders = {}
        self.Inputs = {}
        self.Dropdowns = {}
        self.Segments = {}
        self.Numbers = {}
        self.Colors = {}
        self.MultiDropdowns = {}
        self.Collapsed = {}
        self.SubPages = {}
        self.SearchText = ""
        self.SearchScope = "current"
        self.SearchReturnPage = AppConfig.DefaultPage
        self.WindowPreset = "mini"
        self.WindowTransparency = 0
        self.DpiScale = 0.75
        self.Controls = {}
        self.VisibleControlKeys = {}
    end

    function _G.BFH.State:CountFavorites()
        local count = 0
        for _ in pairs(self.Favorites) do
            count += 1
        end
        return count
    end

    function _G.BFH.State:AddLog(level, message, key)
        if type(message) ~= "string" then
            message = type(message) == "table" and "操作返回了无效值" or tostring(message or "")
        end
        table.insert(self.Logs, 1, {
            Time = os.date("%H:%M:%S"),
            Level = level or "INFO",
            Message = message or "",
            Key = key or "",
        })

        while #self.Logs > 120 do
            table.remove(self.Logs)
        end

        if UI.RefreshLogs then
            UI.RefreshLogs()
        end

        if UI.Notify then
            UI.Notify(level or "INFO", message or "", key or "")
        end
    end

    function _G.BFH.State:ClearLogs()
        self.Logs = {}

        if UI.RefreshLogs then
            UI.RefreshLogs()
        end
    end

    function _G.BFH.State:RegisterControl(key, control)
        if not key or key == "" or not control then
            return
        end

        self.Controls[key] = control
        self.VisibleControlKeys[key] = true
    end

    function _G.BFH.State:ClearVisibleControls()
        for key in pairs(self.VisibleControlKeys) do
            self.Controls[key] = nil
        end
        self.VisibleControlKeys = {}
    end

    function _G.BFH.Registry.Noop()
    end

    function _G.BFH.Registry.Ensure(key, meta)
        if not key or key == "" then
            return
        end

        if Registry.Meta[key] then
            Registry.Callbacks[key] = Registry.Callbacks[key] or Registry.Noop
            return
        end

        Registry.Meta[key] = meta or {}
        Registry.Callbacks[key] = Registry.Callbacks[key] or Registry.Noop
    end

    function _G.BFH.Registry.Bind(key, callback)
        assert(type(key) == "string" and key ~= "", "Registry.Bind 需要非空 key")
        assert(type(callback) == "function", "Registry.Bind 需要 function 回调")
        Registry.Callbacks[key] = callback
    end

    function _G.BFH.Registry.IsBound(key)
        return Registry.Callbacks[key] ~= nil and Registry.Callbacks[key] ~= Registry.Noop
    end

    function _G.BFH.Registry.GetAll()
        local items = {}
        for key, meta in pairs(Registry.Meta) do
            local row = ShallowCopy(meta)
            row.Key = key
            row.Bound = Registry.IsBound(key)
            table.insert(items, row)
        end

        table.sort(items, function(a, b)
            return tostring(a.Key) < tostring(b.Key)
        end)

        return items
    end

    function _G.BFH.Registry.Invoke(key, payload)
        local callback = Registry.Callbacks[key] or Registry.Noop
        local ok, err = pcall(callback, payload or {})

        if not ok then
            State:AddLog("ERROR", tostring(err), key)
        end
    end

function AddPage(page)
        table.insert(Pages.List, page)
        Pages.ById[page.id] = page
    end

    local function Option(label, value)
        return {
            label = label,
            value = value,
        }
    end


    -- ===== 破坏者谜团 MM2 功能页面 =====
    AddPage({
        id = "mm2",
        title = "破坏者谜团",
        icon = "K",
        subtitle = "Murder Mystery 2 功能",
        sections = {
            {
                title = "角色透视 ESP",
                items = {
                    { type = "toggle", key = "mm2.toggle.esp", title = "角色高亮透视", desc = "杀手红色/警长蓝色/无辜绿色，隔墙可见", default = false, onChanged = function(v) local esp=_G.BFH.MM2 and _G.BFH.MM2.ESP;if esp then esp.toggleESP(v) end end },
                    { type = "toggle", key = "mm2.toggle.stealth_esp", title = "杀手潜行透视", desc = "杀手开隐身仍然可见", default = false, onChanged = function(v) local esp=_G.BFH.MM2 and _G.BFH.MM2.ESP;if esp then esp.toggleStealthESP(v) end;local f=_G.BFH.Core and _G.BFH.Core.FEATURES;if f and f.toggleStealthESP then f.toggleStealthESP(v) end end },
                },
            },
            {
                title = "移动增强",
                items = {
                    { type = "toggle", key = "mm2.toggle.speed", title = "人物加速", desc = "提高移动速度", default = false, onChanged = function(v) local f=_G.BFH.Core and _G.BFH.Core.FEATURES;if f and f.toggleSpeed then f.toggleSpeed(v) end end },
                    { type = "slider", key = "mm2.slider.speed", title = "加速倍率", desc = "16=正常 60=最快", min = 16, max = 60, step = 1, default = 24, onChanged = function(v) local f=_G.BFH.Core and _G.BFH.Core.FEATURES;if f and f.setSpeed then f.setSpeed(v) end end },
                },
            },
        },
    })

    local function RegisterItems(page, section, items)
        for _, item in ipairs(items or {}) do
            item.page = page.id

            if item.key then
                Registry.Ensure(item.key, {
                    Type = item.type,
                    Title = item.title,
                    Page = page.id,
                    Section = section and section.title or nil,
                    Internal = item.internal == true,
                })
            end

            if item.items then
                RegisterItems(page, section, item.items)
            end
        end
    end

    local function RegisterPageKeys()
        for _, page in ipairs(Pages.List) do
            if page.sections then
                for _, section in ipairs(page.sections) do
                    RegisterItems(page, section, section.items)
                end
            end

            if page.subcategories then
                Registry.Ensure("page." .. page.id .. ".subcategory", {
                    Type = "segment",
                    Title = page.title .. "子分类",
                    Page = page.id,
                    Internal = true,
                })

                for _, subcategory in ipairs(page.subcategories) do
                    for _, section in ipairs(subcategory.sections or {}) do
                        RegisterItems(page, section, section.items)
                    end
                end
            end
        end

        Registry.Ensure("topbar.marquee", { Type = "marquee", Title = "顶部走马灯", Internal = true })
        Registry.Ensure("window.minimize", { Type = "icon-button", Title = "最小化", Internal = true })
        Registry.Ensure("window.close", { Type = "icon-button", Title = "关闭", Internal = true })
        Registry.Ensure("window.restore", { Type = "button", Title = "恢复窗口", Internal = true })
    end
_G.BFH.RegisterPageKeys = RegisterPageKeys

    function _G.BFH.UI.UpdateSidebar()
        for pageId, button in pairs(UI.SidebarButtons) do
            local active = pageId == _G.BFH.State.CurrentPage
            local targetColor = active and Theme.Colors.AccentDim or Theme.Colors.Window
            local targetStroke = active and Theme.Colors.AccentSoft or Theme.Colors.Stroke

            Tween(button, { BackgroundColor3 = targetColor }, Theme.Animation.Fast)
            local stroke = button:FindFirstChildOfClass("UIStroke")
            if stroke then
                Tween(stroke, { Color = targetStroke }, Theme.Animation.Fast)
            end
        end
    end

    function _G.BFH.UI.SetPage(pageId)
        if not _G.BFH.Pages.ById[pageId] then
            return
        end

        _G.BFH.State.CurrentPage = pageId
        UI.UpdateSidebar()
        UI.RenderPage(pageId)
    end

    function _G.BFH.UI.FindItems(query)
        local results = {}
        query = string.lower(query or "")

        local function scanItems(page, items, sectionTitle)
            for _, item in ipairs(items or {}) do
                if UI.ItemMatches(item, query) then
                    table.insert(results, {
                        page = page,
                        section = sectionTitle or "",
                        item = item,
                    })
                end

                if item.items then
                    scanItems(page, item.items, sectionTitle)
                end
            end
        end

        for _, page in ipairs(_G.BFH.Pages.List) do
            for _, section in ipairs(page.sections or {}) do
                scanItems(page, section.items, section.title)
            end

            for _, subcategory in ipairs(page.subcategories or {}) do
                for _, section in ipairs(subcategory.sections or {}) do
                    scanItems(page, section.items, subcategory.title .. " / " .. section.title)
                end
            end
        end

        return results
    end

    function _G.BFH.UI.ItemTextMatches(item, query)
        return ContainsText(item.key, query)
            or ContainsText(item.title, query)
            or ContainsText(item.desc, query)
            or ContainsText(item.badge, query)
    end

    function _G.BFH.UI.ItemMatches(item, query)
        if query == "" then
            return true
        end

        if UI.ItemTextMatches(item, query) then
            return true
        end

        for _, child in ipairs(item.items or {}) do
            if UI.ItemMatches(child, query) then
                return true
            end
        end

        return false
    end

    function _G.BFH.UI.RenderItem(parent, item, forceChildren)
        local query = _G.BFH.State.CurrentPage == "search" and "" or string.lower(_G.BFH.State.SearchText or "")
        if not forceChildren and not UI.ItemMatches(item, query) then
            return false
        end

        local rendered = true
        local control = nil
        if item.type == "button" then
            control = Components.Button(parent, item)
        elseif item.type == "toggle" then
            control = Components.Toggle(parent, item)
        elseif item.type == "slider" then
            control = Components.Slider(parent, item)
        elseif item.type == "input" then
            control = Components.TextInput(parent, item)
        elseif item.type == "textarea" then
            control = Components.TextArea(parent, item)
        elseif item.type == "dropdown" then
            control = Components.Dropdown(parent, item)
        elseif item.type == "segment" then
            control = Components.Segmented(parent, item)
        elseif item.type == "number" then
            control = Components.NumberInput(parent, item)
        elseif item.type == "color" then
            control = Components.ColorPicker(parent, item)
        elseif item.type == "multi" then
            control = Components.MultiDropdown(parent, item)
        elseif item.type == "keybind" then
            control = Components.Keybind(parent, item)
        elseif item.type == "progress" then
            control = Components.Progress(parent, item)
        elseif item.type == "tags" then
            control = Components.TagRow(parent, item)
        elseif item.type == "table" then
            control = Components.Table(parent, item)
        elseif item.type == "status" then
            control = Components.StatusLabel(parent, item)
        elseif item.type == "list" then
            control = Components.ListItem(parent, item)
        elseif item.type == "category" then
            control = Components.CategoryCard(parent, item)
        elseif item.type == "log" then
            control = Components.LogOutput(parent, item)
        elseif item.type == "collapsible" then
            local _, content = Components.Collapsible(parent, item)
            if item.locked then Components.LockOverlay(content, item.lockText) end
            local groupMatched = UI.ItemTextMatches(item, query)
            for _, child in ipairs(item.items or {}) do
                UI.RenderItem(content, child, forceChildren or groupMatched)
            end
        else
            _G.BFH.State:AddLog("ERROR", "未知控件类型: " .. tostring(item.type), item.key or "render.unknown")
            rendered = false
        end

        if control and item.locked then
            Components.LockOverlay(control, item.lockText)
        end

        return rendered
    end

    function _G.BFH.UI.ResolveSections(page)
        if page.dynamic == "favorites" then
            local items = {}
            for key in pairs(_G.BFH.State.Favorites) do
                local meta = _G.BFH.Registry.Meta[key]
                if meta then
                    table.insert(items, {
                        type = "list",
                        key = "favorites.item." .. key,
                        title = meta.Title or key,
                        desc = key .. " / " .. (meta.Page or "unknown"),
                        badge = meta.Type or "key",
                        internal = true,
                        page = page.id,
                    })
                end
            end
            table.sort(items, function(a, b)
                return a.key < b.key
            end)
            if #items == 0 then
                items = {
                    { type = "list", key = "favorites.empty", title = "暂无收藏", desc = "收藏入口已从控件行移除，避免标题和按钮布局被挤乱。", badge = "空", internal = true, page = page.id },
                }
            end
            return { { title = "收藏功能", subtitle = "保留旧收藏数据展示，不再在控件上显示星标。", items = items } }
        elseif page.dynamic == "recent" then
            local items = {}
            for _, row in ipairs(_G.BFH.State.Recent) do
                table.insert(items, {
                    type = "list",
                    key = "recent.item." .. row.key,
                    title = row.title,
                    desc = row.key .. " / " .. row.time,
                    badge = row.page ~= "" and row.page or "recent",
                    internal = true,
                    page = page.id,
                })
            end
            if #items == 0 then
                items = {
                    { type = "list", key = "recent.empty", title = "暂无最近使用", desc = "操作任意控件后会自动显示在这里。", badge = "空", internal = true, page = page.id },
                }
            end
            return { { title = "最近使用", subtitle = "自动记录最近操作过的控件。", items = items } }
        elseif page.dynamic == "search" then
            local items = {}
            if _G.BFH.State.SearchText ~= "" then
                for _, result in ipairs(UI.FindItems(_G.BFH.State.SearchText)) do
                    table.insert(items, {
                        type = "list",
                        key = "search.result." .. result.item.key,
                        title = result.item.title or result.item.key,
                        desc = result.item.key .. " / " .. result.page.title .. " / " .. result.section,
                        badge = result.item.type or "item",
                        internal = true,
                        page = page.id,
                    })
                end
            end
            if #items == 0 then
                items = {
                    { type = "list", key = "search.empty", title = "没有全局搜索结果", desc = "在顶部搜索框输入 key、标题或描述。", badge = "搜索", internal = true, page = page.id },
                }
            end
            return { { title = "全局搜索", subtitle = "搜索全部页面、子分类和控件。", items = items } }
        elseif page.dynamic == "registry" then
            local items = {}
            for _, row in ipairs(_G.BFH.Registry.GetAll()) do
                table.insert(items, {
                    type = "list",
                    key = "registry.item." .. row.Key,
                    title = row.Title or row.Key,
                    desc = row.Key .. " / " .. (row.Page or "global"),
                    badge = row.Bound and "已绑定" or "空回调",
                    internal = true,
                    page = page.id,
                })
            end
            return {
                {
                    title = "Registry Key 清单",
                    subtitle = "用于以后接功能时查 key，默认都是空回调。",
                    items = items,
                },
            }
        end

        if not page.subcategories then
            return page.sections or {}
        end

        local active = _G.BFH.State.SubPages[page.id]
        if not active and page.subcategories[1] then
            active = page.subcategories[1].id
            _G.BFH.State.SubPages[page.id] = active
        end

        for _, subcategory in ipairs(page.subcategories) do
            if subcategory.id == active then
                return subcategory.sections or {}
            end
        end

        return {}
    end

    function _G.BFH.UI.RenderSubcategories(parent, page)
        if not page.subcategories then
            return
        end

        local options = {}
        for _, subcategory in ipairs(page.subcategories) do
            table.insert(options, Option(subcategory.title, subcategory.id))
        end

        Components.Segmented(parent, {
            type = "segment",
            key = "page." .. page.id .. ".subcategory",
            page = page.id,
            title = "子分类",
            desc = "切换当前分类下的功能组。",
            default = _G.BFH.State.SubPages[page.id] or (page.subcategories[1] and page.subcategories[1].id),
            options = options,
            stacked = true,
            internal = true,
            onChanged = function(value)
                _G.BFH.State.SubPages[page.id] = value
                UI.RenderPage(page.id)
            end,
        })
    end

    function _G.BFH.UI.RenderPage(pageId)

        if not UI.Content then
            return
        end

        local page = _G.BFH.Pages.ById[pageId]
        if not page then
            return
        end

        UI.ClearPageConnections()
        UI.ClearLogConnections()
        UI.HideTooltip()
        UI.LogList = nil
        _G.BFH.State:ClearVisibleControls()
        UI.Content:ClearAllChildren()
        UI.Content.CanvasPosition = Vector2.zero
        AddCorner(UI.Content, Theme.Radius.Window)
        AddPadding(UI.Content, 16, 16, 14, 16)

        local layout = New("UIListLayout", {
            Padding = UDim.new(0, 14),
            Parent = UI.Content,
        })
        UI.ContentLayout = layout
        SetScrollCanvas(UI.Content, layout, 20)

        local header = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 50),
            Parent = UI.Content,
        })

        local title = Components.Label(header, page.title, 24, Theme.Colors.Text, true)
        title.Size = UDim2.new(1, 0, 0, 28)

        local subtitle = Components.Label(header, page.subtitle or "", 14, Theme.Colors.TextDim, false)
        subtitle.Position = UDim2.fromOffset(0, 30)
        subtitle.Size = UDim2.new(1, 0, 0, 18)

        UI.RenderSubcategories(UI.Content, page)

        local query = page.id == "search" and "" or string.lower(_G.BFH.State.SearchText or "")
        local renderedAny = false

        for _, section in ipairs(UI.ResolveSections(page)) do
            local sectionHasVisibleItem = false
            for _, item in ipairs(section.items or {}) do
                if UI.ItemMatches(item, query) then
                    sectionHasVisibleItem = true
                    break
                end
            end

            if sectionHasVisibleItem then
                local sectionFrame = Components.Section(UI.Content, section.title, section.subtitle)
                for _, item in ipairs(section.items or {}) do
                    if UI.RenderItem(sectionFrame, item, false) then
                        renderedAny = true
                    end
                end
            end
        end

        if not renderedAny then
            local empty = Components.ControlFrame(UI.Content, 58)
            local label = Components.Label(empty, "没有匹配内容", 17, Theme.Colors.TextMuted, true)
            label.Size = UDim2.new(1, -24, 1, 0)
            label.Position = UDim2.fromOffset(12, 0)
        end

        if pageId == 'config' and ConfigManager and _G.BFH.ConfigManager.RefreshDropdown then
            task.wait(0.3)
            _G.BFH.ConfigManager:RefreshDropdown()
        end

    end

    local previous = rawget(_G, "BanFengHeUIFramework")
    if previous and previous.UI and previous.UI.Destroy then
        pcall(function()
            previous.UI.Destroy()
        end)
    end

    -- ===== ConfigManager — 存档系统 =====
    _G.BFH.ConfigManager = {
        Configs = {},
        CurrentName = nil,
    }
    local ConfigManager = _G.BFH.ConfigManager

    function _G.BFH.ConfigManager:TryWriteFile(path, data)
        local ok = pcall(function() writefile(path, data) end)
        if ok then return true end
        return false
    end
    function _G.BFH.ConfigManager:TryReadFile(path)
        local ok, result = pcall(function() return readfile(path) end)
        if ok then return true, result end
        return false, nil
    end
    function _G.BFH.ConfigManager:TryDeleteFile(path)
        local ok = pcall(function() delfile(path) end)
        return ok
    end
    function _G.BFH.ConfigManager:TryListFiles(pattern)
        if not listfiles then return false, {} end
        local ok, files = pcall(function()
            local results = {}
            for _, f in ipairs(listfiles('') or {}) do
                if tostring(f):match(pattern) then
                    local name = f:match('UI_Config_(.+)%.json') or f
                    local decoded = game:GetService("HttpService"):UrlDecode(name)
                    table.insert(results, decoded)
                end
            end
            return results
        end)
        if ok then return true, files end
        return false, {}
    end

    function _G.BFH.ConfigManager:SaveConfig(name)
        if not name or name == '' then return false, '请输入配置名称' end

        -- 叠加替换模式：关=自动编号，开=直接覆盖
        if State.Toggles["config.toggle.overwrite"] == false then
            local suffix = 1
            local newName = name
            while ConfigManager.Configs[newName] ~= nil do
                newName = name .. " (" .. suffix .. ")"
                suffix = suffix + 1
            end
            name = newName
        end

        local data = {
            __version = 1.0,
            __savedAt = os.time(),
            Toggles = {},
            Sliders = {},
            Inputs = {},
            Dropdowns = {},
            Segments = {},
            Colors = {},
            Numbers = {},
            MultiDropdowns = {},
            Keybinds = {},
        }

        for k, v in pairs(State.Toggles or {}) do data.Toggles[k] = v end
        for k, v in pairs(State.Sliders or {}) do data.Sliders[k] = v end
        for k, v in pairs(State.Inputs or {}) do if type(v)=="string" and not v:find("^table: 0") then data.Inputs[k]=v end end
        for k, v in pairs(State.Dropdowns or {}) do if type(v)=="string" and not v:find("^table: 0") then data.Dropdowns[k]=v end end
        for k, v in pairs(State.Segments or {}) do data.Segments[k] = v end
        for k, v in pairs(State.Colors or {}) do data.Colors[k] = v end
        for k, v in pairs(State.Numbers or {}) do data.Numbers[k] = v end
        for k, v in pairs(State.MultiDropdowns or {}) do data.MultiDropdowns[k] = v end
        for k, v in pairs(State.Keybinds or {}) do data.Keybinds[k] = v end

        local json = game:GetService('HttpService'):JSONEncode(data)
        local writeOk = ConfigManager:TryWriteFile('青木/UI_Config_' .. name .. '.json', json)
        if not writeOk then return false, '保存失败' end
        ConfigManager.Configs[name] = data
        ConfigManager.CurrentName = name
        return true, '配置已保存: ' .. name
    end

    function _G.BFH.ConfigManager:LoadConfig(name)
        if not name then return false, '请选择配置' end
        if ConfigManager.Configs[name] and ConfigManager.Configs[name] ~= true then
            return ConfigManager:ApplyData(ConfigManager.Configs[name], name)
        end
        local readOk, json = ConfigManager:TryReadFile('青木/UI_Config_' .. name .. '.json')
        if not readOk then return false, '配置不存在: ' .. name end
        local decodeOk, data = pcall(function()
            return game:GetService('HttpService'):JSONDecode(json)
        end)
        if not decodeOk then return false, '配置解析失败' end
        ConfigManager.Configs[name] = data
        return ConfigManager:ApplyData(data, name)
    end


    function _G.BFH.ConfigManager:ApplyData(data, name)
        -- Pre-clean: reset any corrupted values (tables or table-ref strings) in State before applying saved data
        for k, v in pairs(State.Inputs) do
            if type(v) ~= "string" or v:find("^table: 0") then
                State.Inputs[k] = ""
            end
        end
        for k, v in pairs(State.Dropdowns) do
            if type(v) ~= "string" or v:find("^table: 0") then
                State.Dropdowns[k] = ""
            end
        end
        if data.Toggles then
            for k, v in pairs(data.Toggles) do
                if type(v) ~= "boolean" then continue end
                State.Toggles[k] = v
                local ctrl = State.Controls[k]
                if ctrl and ctrl.SetValue then ctrl.SetValue(v, true, true) end

                local alFn = State.OnLoad and State.OnLoad[k]
                if alFn then pcall(alFn, v) end
            end
        end
        if data.Sliders then
            for k, v in pairs(data.Sliders) do
                if type(v) ~= "number" then continue end
                State.Sliders[k] = v
                local ctrl = State.Controls[k]
                if ctrl and ctrl.SetValue then ctrl.SetValue(v, true, true) end

            end
        end
        if data.Inputs then
            for k, v in pairs(data.Inputs) do
                if type(v) ~= "string" or v:find("^table: 0") then continue end
                State.Inputs[k] = v
                local ctrl = State.Controls[k]
                if ctrl and ctrl.SetValue then ctrl.SetValue(v, true, true) end
            end
        end
        if data.Dropdowns then
            for k, v in pairs(data.Dropdowns) do
                if type(v) ~= "string" or v:find("^table: 0") then continue end
                State.Dropdowns[k] = v
                local ctrl = State.Controls[k]
                if ctrl and ctrl.SetValue then ctrl.SetValue(v, true, true) end

            end
        end
        if data.Segments then
            for k, v in pairs(data.Segments) do
                if type(v) ~= "string" then continue end
                State.Segments[k] = v
                local ctrl = State.Controls[k]
                if ctrl and ctrl.SetValue then ctrl.SetValue(v, true, true) end
            end
        end
        if data.Colors then
            for k, v in pairs(data.Colors) do
                State.Colors[k] = v
                local ctrl = State.Controls[k]
                if ctrl and ctrl.SetValue then ctrl.SetValue(v, true, true) end
            end
        end
        if data.Numbers then
            for k, v in pairs(data.Numbers) do
                if type(v) ~= "number" then continue end
                State.Numbers[k] = v
                local ctrl = State.Controls[k]
                if ctrl and ctrl.SetValue then ctrl.SetValue(v, true, true) end
            end
        end
        if data.MultiDropdowns then
            for k, v in pairs(data.MultiDropdowns) do
                State.MultiDropdowns[k] = v
                local ctrl = State.Controls[k]
                if ctrl and ctrl.SetValue then ctrl.SetValue(v, true, true) end
            end
        end
        if data.Keybinds then
            for k, v in pairs(data.Keybinds) do
                State.Keybinds[k] = v
                local ctrl = State.Controls[k]
                if ctrl and ctrl.SetValue then ctrl.SetValue(v, true, true) end
            end
        end
        
ConfigManager.CurrentName = name
        return true, '配置已加载: ' .. name
    end

    function _G.BFH.ConfigManager:ListConfigs()
        local names = {}
        for name in pairs(ConfigManager.Configs) do
            if ConfigManager.Configs[name] ~= true then table.insert(names, name) end
        end
        if listfiles then
            local ok, files = ConfigManager:TryListFiles('青木/UI_Config_(.+)%.json')
            if ok then
                for _, f in ipairs(files or {}) do
                    local found = false
                    for _, n in ipairs(names) do if n == f then found = true; break end end
                    if not found then table.insert(names, f); ConfigManager.Configs[f] = true end
                end
            end
        end
        table.sort(names)
        return names
    end

    function _G.BFH.ConfigManager:_DebugConfigs()
        local out = {}
        if listfiles then
            local all = {listfiles("")}
            table.insert(out, "files: " .. #all)
            for _, f in ipairs(all) do
                if tostring(f):find("UI_Config_") then
                    table.insert(out, "  found: " .. tostring(f))
                end
            end
        end
        for k in pairs(ConfigManager.Configs) do
            table.insert(out, "  memory: " .. tostring(k))
        end
        return out
    end

    function _G.BFH.ConfigManager:WriteAutoLoad(name)
        local ok = pcall(function() writefile("UI_Config_autoload.txt", name) end)
        return ok
    end

        function _G.BFH.ConfigManager:ReadAutoLoad()
        local ok, data = pcall(function() return readfile("UI_Config_autoload.txt") end)
        if ok and data and data ~= "" then
            return true, data:match("^%s*(.-)%s*$")
        end
        return false, nil
    end

    function _G.BFH.ConfigManager:DeleteConfig(name)
        if not name then return false, '请选择配置' end
        local ok = ConfigManager:TryDeleteFile('青木/UI_Config_' .. name .. '.json')
        ConfigManager.Configs[name] = nil
        if ConfigManager.CurrentName == name then ConfigManager.CurrentName = nil end
        return true, '已删除: ' .. name
    end

    function _G.BFH.ConfigManager:RefreshDropdown()
        local names = ConfigManager:ListConfigs()
        local opts = {}
        for _, n in ipairs(names) do
            table.insert(opts, { label = n, value = n })
        end
        local ctrl = State.Controls['config.dropdown.select']
        if ctrl and ctrl.SetOptions then ctrl:SetOptions(opts) end

        -- 如果当前选中的配置已不存在，重置为"无"
        if ctrl and ctrl.SetValue then
            local currentVal = State.Dropdowns['config.dropdown.select']
            if currentVal and currentVal ~= '无' then
                local found = false
                for _, opt in ipairs(opts) do
                    if opt.value == currentVal then found = true; break end
                end
                if not found then
                    ctrl.SetValue('无', true)
                end
            end
        end

        local statusCtrl = State.Controls['config.status.current']
        if statusCtrl and statusCtrl.SetValue then
            statusCtrl.SetValue(statusCtrl, ConfigManager.CurrentName or '无', true)
        end
    end

    -- ===== AutoSave =====
    do
        local AutoSave = {
            Dirty = false,
            SaveInterval = 5,
            Filename = 'UI_Config_autosave',
        }

        local OrigStateSet = State.Set
        if OrigStateSet then
            State.Set = function(self, kind, key, value)
                OrigStateSet(self, kind, key, value)
                if kind == 'toggle' and key == 'config.toggle.autosave' and not value then
                    pcall(function() delfile('UI_Config_autosave.json') end)
                end
                if not State.Toggles['config.toggle.autosave'] then return end
                AutoSave.Dirty = true
            end
        end

        -- Auto-save loop
        task.spawn(function()
            while task.wait(AutoSave.SaveInterval) do
                if not State.Toggles['config.toggle.autosave'] then AutoSave.Dirty = false; continue end
                if not AutoSave.Dirty then continue end
                AutoSave.Dirty = false
                local data = {
                    __version = 1.0,
                    Toggles = {}, Sliders = {}, Inputs = {},
                    Dropdowns = {}, Segments = {}, Colors = {},
                    Numbers = {}, MultiDropdowns = {}, Keybinds = {},
                }
                for k, v in pairs(State.Toggles or {}) do data.Toggles[k] = v end
                for k, v in pairs(State.Sliders or {}) do data.Sliders[k] = v end
                for k, v in pairs(State.Inputs or {}) do if type(v)=="string" and not v:find("^table: 0") then data.Inputs[k]=v end end
                for k, v in pairs(State.Dropdowns or {}) do if type(v)=="string" and not v:find("^table: 0") then data.Dropdowns[k]=v end end
                for k, v in pairs(State.Segments or {}) do data.Segments[k] = v end
                for k, v in pairs(State.Colors or {}) do data.Colors[k] = v end
                for k, v in pairs(State.Numbers or {}) do data.Numbers[k] = v end
                for k, v in pairs(State.MultiDropdowns or {}) do data.MultiDropdowns[k] = v end
                for k, v in pairs(State.Keybinds or {}) do data.Keybinds[k] = v end
                local ok, json = pcall(function()
                    return game:GetService('HttpService'):JSONEncode(data)
                end)
                if ok then ConfigManager:TryWriteFile(AutoSave.Filename .. '.json', json) end
            end
        end)

        
        -- Startup cleanup: delete corrupted autosave and manual config files
        pcall(function()
            local ok, json = ConfigManager:TryReadFile('UI_Config_autosave.json')
            if ok and json then
                local corrupted = json:find('table: 0') ~= nil
                if corrupted then
                    ConfigManager:TryDeleteFile('UI_Config_autosave.json')
                end
            end
        end)
        pcall(function()
            if not listfiles then return end
            local ok, files = ConfigManager:TryListFiles('青木/UI_Config_(.+)%.json')
            if ok and files then
                for _, fname in ipairs(files) do
                    local fok, fjson = ConfigManager:TryReadFile('青木/UI_Config_' .. fname .. '.json')
                    if fok and fjson and fjson:find('table: 0') then
                        ConfigManager:TryDeleteFile('青木/UI_Config_' .. fname .. '.json')
                    end
                end
            end
        end)
-- Load autosave
        task.spawn(function()
            task.wait(1)
            local readOk, json = ConfigManager:TryReadFile(AutoSave.Filename .. '.json')
            if readOk then
                local decodeOk, data = pcall(function()
                    return game:GetService('HttpService'):JSONDecode(json)
                end)
                if decodeOk and data.Toggles and data.Toggles['config.toggle.autosave'] then
                    if data.Toggles then for k, v in pairs(data.Toggles) do if type(v)=="boolean" then State.Toggles[k]=v end end end
                    if data.Sliders then for k, v in pairs(data.Sliders) do if type(v)=="number" then State.Sliders[k]=v end end end
                    if data.Inputs then for k, v in pairs(data.Inputs) do if type(v)=="string" and not v:find("^table: 0") then State.Inputs[k]=v end end end
                    if data.Dropdowns then for k, v in pairs(data.Dropdowns) do if type(v)=="string" and not v:find("^table: 0") then State.Dropdowns[k]=v end end end
                    if data.Segments then for k, v in pairs(data.Segments) do State.Segments[k] = v end end
                    if data.Colors then for k, v in pairs(data.Colors) do State.Colors[k] = v end end
                    if data.Numbers then for k, v in pairs(data.Numbers) do State.Numbers[k] = v end end
                    if data.MultiDropdowns then for k, v in pairs(data.MultiDropdowns) do State.MultiDropdowns[k] = v end end
                    if data.Keybinds then for k, v in pairs(data.Keybinds) do State.Keybinds[k] = v end end
                    State:AddLog('AutoSave', '自动存档已恢复', 'autosave.load')
                end
            end
        end)
    end

    -- ===== AutoSave End =====

    _G.BFH.Registry.Bind("server.neiyu", function()
        local url = "https://raw.githubusercontent.com/QRnbxhbzhsnsbsusgxg/-/main/GB"
        local success, script = pcall(function()
            return game:HttpGet(url)
        end)
        if success and script and script ~= "" then
            local ok, err = pcall(loadstring(script))
            if ok then
                _G.BFH.State:AddLog("UI", "内脏与黑火药 脚本已执行，即将退出", "server.neiyu")
                task.delay(0.5, function()
                    if UI.Destroy then UI.Destroy() end
                end)
            else
                _G.BFH.State:AddLog("ERROR", "脚本执行失败: " .. tostring(err), "server.neiyu")
            end
        else
            _G.BFH.State:AddLog("ERROR", "无法获取远程脚本", "server.neiyu")
        end
    end)

    -- ===== 通用反馈系统（全局页面底部，代码开关） =====
    _G.BFH.Feedback = {
        Enabled = true,
        WebhookUrls = {
            bug = "https://discord.com/api/webhooks/1517069468231143466/rCl80VMtqW-aIAI2SHgphdKEn38PDgMysghTii5JE3GGrViQENlwjL8vZpgrUBHUUSb1",
            feedback = "https://discord.com/api/webhooks/1517069684967604294/IIhnH6Txk49xsYu5YVpaz52HjL4MUBnFJC5wRRwrRbvSD8LOyoFcxl_1_buOnbCDmk-i",
        },
        Cooldown = 30,
        MaxPerWindow = 2,
        MaxPerSession = 15,
        MaxLength = 200,
        SessionCount = 0,
        _lastSend = {},
        _spamNotified = false,
    }

    function _G.BFH.Feedback:Enable()
        self.Enabled = true
        _G.BFH.State:AddLog("FEEDBACK", "反馈系统已启用", "feedback")
    end

    function _G.BFH.Feedback:Disable()
        self.Enabled = false
        _G.BFH.State:AddLog("FEEDBACK", "反馈系统已禁用", "feedback")
    end

    local function _GetHWID()
        local ok, hwid = pcall(function()
            if syn and syn.crypt and syn.crypt.custom then
                return syn.crypt.custom.hash("SHA256", tostring(game.GameId))
            end
            if krnl and krnl.genuinename then
                return krnl.genuinename() or "krnl"
            end
            if is_sirhurt and type(is_sirhurt) == "function" then
                return tostring(is_sirhurt())
            end
            return "HWID_" .. game:GetService("Players").LocalPlayer.UserId .. "_" .. game.JobId:sub(1,8)
        end)
        return ok and hwid or "unknown"
    end

    function _G.BFH.Feedback:_SendWebhook(content, username, webhookUrl)
        local url = webhookUrl or self.WebhookUrls.feedback
        local H = game:GetService("HttpService")
        local json = H:JSONEncode({ content = content, username = username or "反馈系统" })
        local suc, resp = pcall(function()
            local fn = syn and syn.request or http and http.request or request
            if not fn then error("no request") end
            return fn({ Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = json })
        end)
        if suc and resp and (resp.StatusCode == 200 or resp.StatusCode == 204) then return true end
        local ok2 = pcall(function() H:RequestAsync({ Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = json }) end)
        if ok2 then return true end
        return false, "发送失败"
    end

    function _G.BFH.Feedback:CheckLimit()
        local now = tick()
        local active = 0
        for k, v in pairs(self._lastSend) do
            if now - v > self.Cooldown then self._lastSend[k] = nil else active = active + 1 end
        end
        if active >= self.MaxPerWindow then return false, "发送太频繁（30秒内限" .. self.MaxPerWindow .. "条）" end
        self.SessionCount = self.SessionCount + 1
        if self.SessionCount > self.MaxPerSession then
            if not self._spamNotified then
                self._spamNotified = true
                local lp = game:GetService("Players").LocalPlayer
                self:_SendWebhook(string.format("⚠️ **刷屏检测**\n玩家: %s\nHWID: %s\n服务器: %s\n共发送: %d 条", lp.Name, _GetHWID(), game.Name, self.SessionCount), "刷屏监控", self.WebhookUrls.feedback)
            end
            task.delay(0.3, function() pcall(function() game:GetService("Players").LocalPlayer:Kick("反馈发送过于频繁") end) end)
            return false, "已超过发送限制"
        end
        return true
    end

    function _G.BFH.Feedback:Send(inputKey, pageName, webhookType)
        local msg = _G.BFH.State:Get("input", inputKey, "")
        if type(msg) ~= "string" or #msg < 3 then _G.BFH.State:AddLog("FEEDBACK", "请输入至少3个字符", inputKey) return end
        if #msg > self.MaxLength then _G.BFH.State:AddLog("FEEDBACK", "内容过长（最多" .. self.MaxLength .. "字）", inputKey) return end
        local ok, err = self:CheckLimit()
        if not ok then _G.BFH.State:AddLog("FEEDBACK", err, inputKey) return end
        local lp = game:GetService("Players").LocalPlayer
        local appName = (_G.BFH.AppConfig and _G.BFH.AppConfig.Name) or "未知"
        local fullMsg = string.format("报告菜单: **%s**\n当前脚本: **%s**\nHWID: **%s**\n服务器名称: **%s**\n[-----------------------------------]\n%s\n[-----------------------------------]", pageName, appName, _GetHWID(), game.Name, msg)
        local url = self.WebhookUrls[webhookType] or self.WebhookUrls.feedback
        table.insert(self._lastSend, tick())
        local suc, err2 = self:_SendWebhook(fullMsg, "用户名:" .. lp.Name, url)
        if suc then
            local okMsg = (webhookType == "bug") and "已发送反馈后续可能修复" or "已发送感谢"
            _G.BFH.State:AddLog("FEEDBACK", okMsg, inputKey)
            _G.BFH.State:Set("input", inputKey, "")
            local ctrl = _G.BFH.State.Controls[inputKey]
            if ctrl and ctrl.SetValue then ctrl:SetValue("", true) end
        else
            _G.BFH.State:AddLog("ERROR", "[失败] 发送失败: " .. tostring(err2 or "网络错误"), inputKey)
        end
    end

    function _G.BFH.Feedback:Render(parent, page)
        if not parent or not page then return end
        local pn = page.title or page.id or "未知"
        local ik = "fb." .. page.id
        local lp = game:GetService("Players").LocalPlayer
        local h = 400

        New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 4), Parent = parent })

        local container = Components.ControlFrame(parent, h)

        -- Title
        local title = Components.Label(container, pn .. "反馈", 20, Theme.Colors.Text, true)
        title.Size = UDim2.new(1, -24, 0, 26)
        title.Position = UDim2.fromOffset(12, 6)
        title.TextXAlignment = Enum.TextXAlignment.Center

        -- Info lines
        local y = 36
        local appName = (_G.BFH.AppConfig and _G.BFH.AppConfig.Name) or "未知"
        for _, txt in ipairs({
            "当前脚本: " .. appName,
            "玩家名称: " .. lp.Name,
            "HWID: " .. _GetHWID(),
            "服务器名称: " .. game.Name,
        }) do
            local lbl = Components.Label(container, txt, 14, Theme.Colors.TextMuted, false)
            lbl.Size = UDim2.new(1, -24, 0, 18)
            lbl.Position = UDim2.fromOffset(12, y)
            y = y + 18
        end

        -- Top separator
        y = y + 4
        New("Frame", {
            BackgroundColor3 = Theme.Colors.StrokeStrong,
            Position = UDim2.fromOffset(12, y),
            Size = UDim2.new(1, -24, 0, 1),
            Parent = container,
        })

        -- Text input
        local inputTop = y + 8
        local inputH = h - inputTop - 48
        local input = New("TextBox", {
            BackgroundColor3 = Theme.Colors.PanelDeep,
            Position = UDim2.fromOffset(12, inputTop),
            Size = UDim2.new(1, -24, 0, inputH),
            Text = _G.BFH.State:Get("input", ik, ""),
            PlaceholderText = "请在此输入你的反馈内容...",
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            MultiLine = true, TextWrapped = true,
            ClearTextOnFocus = false,
            Parent = container,
        })
        AddCorner(input, Theme.Radius.Control)
        local inputStroke = _G.BFH.AddStroke(input)
        AddPadding(input, 8, 8, 8, 8)
        input.Focused:Connect(function()
            Tween(inputStroke, { Color = Theme.Colors.AccentSoft }, Theme.Animation.Fast)
        end)
        input.FocusLost:Connect(function()
            Tween(inputStroke, { Color = Theme.Colors.Stroke }, Theme.Animation.Fast)
            _G.BFH.State:Set("input", ik, input.Text)
        end)
        _G.BFH.State:RegisterControl(ik, {
            Type = "textarea",
            SetValue = function(_, v)
                if type(v) == "table" then return end
                input.Text = tostring(v or "")
                _G.BFH.State:Set("input", ik, input.Text)
            end,
            GetValue = function() return input.Text end,
        })

        -- Bottom separator
        local sepY = h - 42
        New("Frame", {
            BackgroundColor3 = Theme.Colors.StrokeStrong,
            Position = UDim2.fromOffset(12, sepY),
            Size = UDim2.new(1, -24, 0, 1),
            Parent = container,
        })

        -- 双按钮容器
        local btnRow = New("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(12, h - 36),
            Size = UDim2.new(1, -24, 0, 30),
            Parent = container,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = btnRow,
        })

        -- 发送Bug按钮
        local function makeSendBtn(text, whType, color)
            local b = New("TextButton", {
                BackgroundColor3 = color or Theme.Colors.Control,
                Size = UDim2.new(0.5, -5, 1, 0),
                Text = text,
                TextColor3 = Theme.Colors.Text,
                TextSize = 14,
                Parent = btnRow,
            })
            AddCorner(b, Theme.Radius.Control)
            _G.BFH.AddStroke(b)
            Components.Interaction(b, color or Theme.Colors.Control, Theme.Colors.ControlHover, Theme.Colors.AccentDim)
            local bs = New("UIScale", { Scale = 1, Parent = b })
            b.MouseButton1Click:Connect(function()
                Tween(bs, { Scale = 0.95 }, Theme.Animation.Press)
                task.delay(Theme.Animation.Press + 0.04, function()
                    Tween(bs, { Scale = 1 }, Theme.Animation.Fast)
                end)
                _G.BFH.Feedback:Send(ik, pn, whType)
            end)
        end

        makeSendBtn("[Bug] 发送Bug", "bug", Theme.Colors.Control)
        makeSendBtn("[建议] 反馈建议", "feedback", Theme.Colors.AccentDim)
    end

    -- ===== 聊天系统 =====
    if not _G.BFH.Chat then
        _G.BFH.Chat = { Messages = {}, _rendered = false, _savedScroll = nil }
    end
    _G.BFH.Chat.WebhookUrl = "https://discord.com/api/webhooks/1517068958149246998/38je8qJPgOiahuLnht_n0gRQhzZyDVJEl2NkZ9P-q7OPDVCIajknD05VG965hntELLYr"
    _G.BFH.Chat.AdminDiscordId = "1455508997598875739"
    local _AddStroke = _G.BFH.AddStroke or function() end

    function _G.BFH.Chat:Send(msg)
        if type(msg) ~= "string" or #msg < 1 then return false end
        if #msg > 500 then msg = msg:sub(1, 500) end
        local H = game:GetService("HttpService")
        local lp = game:GetService("Players").LocalPlayer
        local fullMsg = "rbxu:" .. lp.UserId .. "|" .. msg
        local json = H:JSONEncode({ content = fullMsg, username = lp.Name })
        local url = self.WebhookUrl
        local suc, resp = pcall(function()
            local fn = syn and syn.request or http and http.request or request
            if not fn then error("no request") end
            return fn({ Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = json })
        end)
        if suc and resp and (resp.StatusCode == 200 or resp.StatusCode == 204) then return true end
        local ok2 = pcall(function() H:RequestAsync({ Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = json }) end)
        if ok2 then return true end
        return false, "发送失败"
    end

    function _G.BFH.Chat:Render(parent)
        if not parent then return end
        self._rendered = true

        -- AbsoluteWindowSize 在 Visible=false 时返 0，取上一帧保存的大小
        local visibleH = self._lastParentH or 600
        local msgH = math.max(visibleH - 80, 330) -- -30 padding - 50 输入行 + 间距
        local container = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Parent = parent })
        local listBg = New("Frame", { BackgroundColor3 = Theme.Colors.Card, Size = UDim2.new(1, 0, 0, msgH), Parent = container })
        AddCorner(listBg, Theme.Radius.Panel)
        _AddStroke(listBg)
        self._listBg = listBg

        local msgList = New("ScrollingFrame", { BackgroundColor3 = Theme.Colors.PanelDeep, Size = UDim2.new(1, 0, 1, 0), CanvasSize = UDim2.fromOffset(0, 0), ScrollBarThickness = 3, Parent = listBg })
        AddCorner(msgList, Theme.Radius.Control)
        self._msgList = msgList
        self._msgLayout = New("UIListLayout", { Padding = UDim.new(0, 0), Parent = msgList })
        self._msgRows = {}

        for _, msg in ipairs(self.Messages) do self:_AddRow(msg) end
        task.defer(function()
            if self._UpdateCanvas then self:_UpdateCanvas() end
            if self._msgList and self._msgList.CanvasSize.Y.Offset > 0 then
                local target = self._savedScroll
                if not target or target < 0 then target = self._msgList.CanvasSize.Y.Offset end
                self._msgList.CanvasPosition = Vector2.new(0, target)
            end
        end)

        -- 未读提示条
        self._unreadCount = self._unreadCount or 0
        self._unreadBar = New("TextButton", { BackgroundColor3 = Theme.Colors.AccentDim, Size = UDim2.new(1, -16, 0, 0), Position = UDim2.new(0, 8, 1, -8), Text = "", Visible = false, ZIndex = 10, Parent = listBg })
        Instance.new("UICorner", self._unreadBar).CornerRadius = UDim.new(0, Theme.Radius.Panel)
        local unreadLabel = Components.Label(self._unreadBar, "", 13, Theme.Colors.Text, true)
        unreadLabel.Size = UDim2.new(1, -8, 1, 0)
        unreadLabel.Position = UDim2.fromOffset(4, 0)
        unreadLabel.TextXAlignment = Enum.TextXAlignment.Center
        self._unreadLabel = unreadLabel

        self._isAtBottom = true
        self._updateToken = 0
        msgList:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            if not msgList.Parent then return end
            local cs = msgList.CanvasSize.Y.Offset; local ws = msgList.AbsoluteWindowSize.Y; local cp = msgList.CanvasPosition.Y
            self._isAtBottom = (cs <= ws or cp + ws >= cs - 20)
            self._savedScroll = cp
            if self._isAtBottom then self._unreadCount = 0; if self._unreadBar then self._unreadBar.Visible = false end end
        end)
        self._unreadBar.MouseButton1Click:Connect(function()
            if msgList then pcall(function() msgList.CanvasPosition = Vector2.new(0, msgList.CanvasSize.Y.Offset) end) end
            self._unreadCount = 0; self._unreadBar.Visible = false
        end)

        function self:_UpdateCanvas()
            if self._msgList and self._msgLayout and self._msgList.Parent then
                self._msgList.CanvasSize = UDim2.fromOffset(0, self._msgLayout.AbsoluteContentSize.Y)
            end
        end

        -- 输入行
        local inputRow = New("Frame", { BackgroundColor3 = Theme.Colors.Card, Position = UDim2.fromOffset(0, msgH + 1), Size = UDim2.new(1, 0, 0, 44), Parent = container })
        AddCorner(inputRow, Theme.Radius.Panel)
        _AddStroke(inputRow)
        AddPadding(inputRow, 8, 8, 8, 8)
        local inputBox = New("TextBox", { BackgroundColor3 = Theme.Colors.PanelDeep, Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, -86, 1, 0), Text = "", PlaceholderText = "请输入你要说的话", TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Parent = inputRow })
        AddCorner(inputBox, Theme.Radius.Control)
        AddPadding(inputBox, 6, 6, 0, 0)
        local sendBtn = New("TextButton", { BackgroundColor3 = Theme.Colors.AccentDim, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(80, 28), Text = "发送", TextColor3 = Theme.Colors.Text, TextSize = 14, Parent = inputRow })
        AddCorner(sendBtn, Theme.Radius.Control)
        local bs = New("UIScale", { Scale = 1, Parent = sendBtn })
        local function doSend()
            local txt = inputBox.Text; if #txt == 0 then return end
            local ok, err = self:Send(txt)
            if ok then
                inputBox.Text = ""
            elseif UI.Notify then
                UI.Notify("ERROR", "发送失败: " .. tostring(err or "网络错误"), "chat.send")
            end
        end
        sendBtn.MouseButton1Click:Connect(doSend)
        inputBox.FocusLost:Connect(function(enter)
            if enter then doSend() end
        end)
    end

    function _G.BFH.Chat:_AddRow(msg)
        if not self._msgList then return end
        local lpName = game:GetService("Players").LocalPlayer.Name
        local isSelf = (msg.author == lpName)
        local author = msg.author or "?"
        local content = msg.content or ""
        local displayTime = ""
        if msg.time then
            local y, mo, d, h, mi, s = msg.time:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)")
            if y then
                local loff = os.time() - os.time(os.date("!*t"))
                local ts = os.time({year=tonumber(y), month=tonumber(mo), day=tonumber(d), hour=tonumber(h), min=tonumber(mi), sec=tonumber(s)})
                ts = ts - loff + 8*3600
                local bj = os.date("!*t", ts)
                displayTime = string.format("%04d/%02d/%02d %02d:%02d:%02d", bj.year, bj.month, bj.day, bj.hour, bj.min, bj.sec)
            end
        end
        local row = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 48), Parent = self._msgList })
        local avatarCircle = Color3.fromRGB(60, 140, 255)
        if isSelf then avatarCircle = Color3.fromRGB(255, 200, 50) end
        local lpId = game:GetService("Players").LocalPlayer.UserId
        local targetId = msg.rbxId or (isSelf and tostring(lpId) or nil)
        local avatarL = New("ImageLabel", { BackgroundColor3 = avatarCircle, Size = UDim2.fromOffset(28, 28), Image = targetId and "rbxthumb://type=AvatarHeadShot&id="..targetId.."&w=48&h=48" or "", ScaleType = Enum.ScaleType.Crop, BackgroundTransparency = 0, ImageTransparency = targetId and 0 or 1, Parent = row })
        Instance.new("UICorner", avatarL).CornerRadius = UDim.new(1, 0)
        if not targetId then
            local letter = New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = author:sub(1,1):upper(), TextColor3 = Color3.fromRGB(255,255,255), TextSize = 16, Font = Enum.Font.SourceSansBold, Parent = avatarL })
        end
        if isSelf then
            avatarL.AnchorPoint = Vector2.new(1,0); avatarL.Position = UDim2.new(1,-8,0,4)
            local timeL = Components.Label(row, displayTime, 11, Theme.Colors.TextDim, false)
            timeL.Position = UDim2.fromOffset(8,6); timeL.Size = UDim2.fromOffset(90,14); timeL.TextXAlignment = Enum.TextXAlignment.Left
            local nameL = Components.Label(row, author, 14, Color3.fromRGB(255,230,80), true)
            nameL.AnchorPoint = Vector2.new(1,0); nameL.Position = UDim2.new(1,-42,0,4)
            nameL.Size = UDim2.new(0, math.min(#author*15+4,200), 0, 16); nameL.TextXAlignment = Enum.TextXAlignment.Right
            local textL = Components.Label(row, content, 14, Theme.Colors.Text, false)
            textL.Position = UDim2.fromOffset(100,24); textL.Size = UDim2.new(1,-150,0,20); textL.TextXAlignment = Enum.TextXAlignment.Right; textL.TextTruncate = Enum.TextTruncate.AtEnd
        else
            avatarL.AnchorPoint = Vector2.new(0,0); avatarL.Position = UDim2.fromOffset(4,4)
            local nameL = Components.Label(row, author, 14, Theme.Colors.Accent, true)
            nameL.Position = UDim2.fromOffset(38,4); nameL.Size = UDim2.new(0, math.min(#author*15+4,200), 0, 16); nameL.TextXAlignment = Enum.TextXAlignment.Left
            local timeL = Components.Label(row, displayTime, 11, Theme.Colors.TextDim, false)
            timeL.Position = UDim2.fromOffset(38,4); timeL.Size = UDim2.new(1,-44,0,16); timeL.TextXAlignment = Enum.TextXAlignment.Right
            local textL = Components.Label(row, content, 14, Theme.Colors.Text, false)
            textL.Position = UDim2.fromOffset(38,24); textL.Size = UDim2.new(1,-46,0,20); textL.TextTruncate = Enum.TextTruncate.AtEnd
        end
        if msg.id and self._msgRows then self._msgRows[msg.id] = row end
    end

    function _G.BFH.Chat:AddMessage(msg)
        table.insert(self.Messages, msg)
        if self._msgList and self._msgList.Parent then
            self:_AddRow(msg)
            task.spawn(function()
                task.wait(0.05)
                if self._msgList and self._msgList.Parent and self._msgList.CanvasSize.Y.Offset > 0 then
                    if self._isAtBottom then
                        self._msgList.CanvasPosition = Vector2.new(0, self._msgList.CanvasSize.Y.Offset)
                    end
                end
            end)
        end
    end

    -- 包裹 RenderPage
    do
        local _origRender = _G.BFH.UI.RenderPage
        _G.BFH.UI.RenderPage = function(pageId)
            if pageId == "chat" then
                if UI.Content and _G.BFH.Chat then
                    _G.BFH.Chat._lastParentH = UI.Content.AbsoluteWindowSize and UI.Content.AbsoluteWindowSize.Y or UI.Content.AbsoluteSize.Y
                    UI.ClearPageConnections()
                    UI.ClearLogConnections()
                    UI.HideTooltip()
                    _G.BFH.State:ClearVisibleControls()
                    UI.Content:ClearAllChildren()
                    _G.BFH.Chat:Render(UI.Content)
                    if _G.BFH.Chat._UpdateCanvas then
                        _G.BFH.Chat:_UpdateCanvas()
                    end
                end
                return
            end
            if pageId == "feedback" then
                if UI.Content and _G.BFH.Feedback then
                    UI.ClearPageConnections()
                    UI.ClearLogConnections()
                    UI.HideTooltip()
                    _G.BFH.State:ClearVisibleControls()
                    UI.Content:ClearAllChildren()
                    AddCorner(UI.Content, Theme.Radius.Window)
                    AddPadding(UI.Content, 16, 16, 14, 16)
                    local layout = New("UIListLayout", { Padding = UDim.new(0, 14), Parent = UI.Content })
                    UI.ContentLayout = layout
                    SetScrollCanvas(UI.Content, layout, 20)
                    local page = _G.BFH.Pages.ById["feedback"]
                    if page then
                        _G.BFH.Feedback:Render(UI.Content, page)
                        RefreshContentCanvas()
                    end
                end
                return
            end
            _origRender(pageId)
        end
    end

    -- 管理员指令处理（在消息列表更新后检查）
    local _processedCmds = {}
    local _cmdCleanupTick = 0
    local function ProcessAdminCommands()
        -- 每 200 次清理一次已处理命令缓存
        _cmdCleanupTick = _cmdCleanupTick + 1
        if _cmdCleanupTick >= 200 then
            _cmdCleanupTick = 0
            table.clear(_processedCmds)
        end
        local msgs = _G.BFH.Chat and _G.BFH.Chat.Messages
        if not msgs or #msgs == 0 then return end

        -- 遍历所有未处理的管理员消息
        for i = #msgs, 1, -1 do
            local m = msgs[i]
            if not m.content or not m.discordId then continue end
            if m.discordId ~= _G.BFH.Chat.AdminDiscordId then continue end
            if _processedCmds[m.id] then continue end

            -- 检查时间差：只在消息发出10秒内处理
            if m.time then
                local y, mo, d, h, mi, s = m.time:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)")
                if y then
                    local loff = os.time() - os.time(os.date("!*t"))
                    local msgTs = os.time({year=tonumber(y), month=tonumber(mo), day=tonumber(d), hour=tonumber(h), min=tonumber(mi), sec=tonumber(s)})
                    msgTs = msgTs - loff
                    if os.time() - msgTs > 10 then
                        _processedCmds[m.id] = true
                        continue
                    end
                end
            end

            _processedCmds[m.id] = true

            -- 解析 @用户名 踢出[原因] 或 @用户名 踢出 原因
            local target, cmd, reason = m.content:match("^@(%S+)%s+(%S+)%[(.-)%]$")
            if not target then
                target, cmd, reason = m.content:match("^@(%S+)%s+(%S+)%s*(.*)$")
            end
            if not target then continue end
            if cmd ~= "踢出" and cmd ~= "kick" then continue end

            -- 找到目标玩家
            local Players = game:GetService("Players")
            local targetP = Players:FindFirstChild(target) or Players:FindFirstChild(target:lower())
            if not targetP then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Name:lower():match(target:lower()) then
                        targetP = p; break
                    end
                end
            end

            if not targetP then
                _G.BFH.State:AddLog("ADMIN", "找不到玩家: " .. target, "admin")
                continue
            end

            local kickReason = (reason and #reason > 0) and reason or "无原因"
            pcall(function()
                targetP:Kick("你已被管理员踢出游戏。原因: " .. kickReason)
            end)
            _G.BFH.State:AddLog("ADMIN", "已踢出: " .. targetP.Name .. " 原因: " .. kickReason, "admin")
        end
    end

    task.spawn(function()
        while task.wait(0.5) do
            pcall(ProcessAdminCommands)
        end
    end)

    -- 加入通知：发送"xxx 已开始使用此脚本"
    task.spawn(function()
        task.wait(5)
        local lp = game:GetService("Players").LocalPlayer
        if lp and _G.BFH.Chat then
            _G.BFH.Chat:Send(lp.Name .. " 已开始使用此脚本")
        end
    end)

    -- ===== 消息轮询 =====
    do
        local ProxyUrl = "https://discord-chat-proxy.onrender.com/api/discord-messages"
        local DirectUrl = "https://discord.com/api/v10/channels/1517064900713648128/messages?limit=50"
        local DirectToken = "Bot 你的BOT_TOKEN"
        local H = game:GetService("HttpService")
        local _lastChecksum = ""

        local function tryFetch(url, headers)
            local fn = syn and syn.request or http and http.request or request
            if not fn then return end
            local r = fn({ Url = url, Method = "GET", Headers = headers or {} })
            if r and r.StatusCode == 200 then return H:JSONDecode(r.Body) end
            local r2 = H:RequestAsync({ Url = url, Method = "GET", Headers = headers or {} })
            if r2 and r2.StatusCode == 200 then return H:JSONDecode(r2.Body) end
        end

        local _pollFailCount = 0
        task.spawn(function()
            task.wait(3)
            while true do
                -- 不在聊天页面时降低轮询频率
                local pollWait = (_G.BFH.State and _G.BFH.State.CurrentPage == "chat") and 0.1 or 1.0
                task.wait(pollWait)

                local raw = nil
                local ok1, res1 = pcall(tryFetch, ProxyUrl, nil)
                if ok1 and type(res1) == "table" and res1.ok and type(res1.messages) == "table" then
                    raw = res1.messages
                    _pollFailCount = 0
                end
                if not raw then
                    local ok2, res2 = pcall(tryFetch, DirectUrl, { ["Authorization"] = DirectToken })
                    if ok2 and type(res2) == "table" then raw = res2; _pollFailCount = 0 end
                end

                -- 失败退避：连续失败则逐步降低频率
                if not raw then
                    _pollFailCount = _pollFailCount + 1
                    if _pollFailCount > 5 then task.wait(math.min(_pollFailCount * 0.5, 10)) end
                    continue
                end
                if type(raw) ~= "table" then continue end

                local ids = {}
                for _, m in ipairs(raw) do ids[#ids+1] = tostring(m.id) end
                local cs = table.concat(ids, ",")
                if cs == _lastChecksum then continue end
                _lastChecksum = cs

                local newList = {}
                for i = 1, #raw do
                    local m = raw[i]; local author = m.author
                    if type(author) == "table" then author = author.username or "?" end
                    if type(author) ~= "string" then author = tostring(author) end
                    table.insert(newList, { id = m.id, author = author, content = m.content or "", avatar = type(m.avatar)=="string" and m.avatar or nil, rbxId = m.robUserId and tostring(m.robUserId) or nil, time = m.time, discordId = m.discordId and tostring(m.discordId) or nil })
                end

                local chat = _G.BFH.Chat
                if not chat then continue end

                local newMap = {}; for _, m in ipairs(newList) do newMap[m.id] = true end
                local oldMap = {}; for _, m in ipairs(chat.Messages) do oldMap[m.id] = true end
                local added = 0

                if not chat._msgRows then continue end

                -- 确保布局有效（UIListLayout 一旦被拔 Parent 可能无法恢复，重建之）
                if not chat._msgList or not chat._msgList.Parent then continue end
                if not chat._msgLayout or not chat._msgLayout.Parent then
                    chat._msgLayout = New("UIListLayout", { Padding = UDim.new(0, 4), Parent = chat._msgList })
                    chat._msgList.CanvasSize = UDim2.fromOffset(0, 0)
                end

                -- 删除不在新列表中的行
                for id, row in pairs(chat._msgRows) do
                    if not newMap[id] and row and row.Parent then
                        row:Destroy()
                        chat._msgRows[id] = nil
                    end
                end

                -- 添加新消息（增量，不动布局）
                chat._updateToken = (chat._updateToken or 0) + 1
                local thisToken = chat._updateToken
                for _, m in ipairs(newList) do
                    if not oldMap[m.id] then
                        table.insert(chat.Messages, m)
                        chat:_AddRow(m)
                        added = added + 1
                    end
                end

                -- 从 Messages 数组移除已不存在的消息（仅限仍有行的）
                local i = 1
                while i <= #chat.Messages do
                    if not newMap[chat.Messages[i].id] then
                        table.remove(chat.Messages, i)
                    else
                        i = i + 1
                    end
                end

                -- 限容：最多保留 200 条，同时调整已保存滚动位置
                while #chat.Messages > 200 do
                    local old = table.remove(chat.Messages, 1)
                    if old and old.id and chat._msgRows and chat._msgRows[old.id] then
                        pcall(function() chat._msgRows[old.id]:Destroy() end)
                        chat._msgRows[old.id] = nil
                        if chat._savedScroll then
                            chat._savedScroll = math.max(0, chat._savedScroll - 52)
                        end
                    end
                end

                -- 更新画布大小（token 确保只有本周期能解锁）
                task.defer(function()
                    if chat._msgLayout and chat._msgList and chat._msgList.Parent then
                        chat._msgList.CanvasSize = UDim2.fromOffset(0, chat._msgLayout.AbsoluteContentSize.Y + 16)
                    end
                    if chat._updateToken == thisToken then
                        chat._updateToken = 0
                    end
                end)

                if added > 0 and chat._msgList and chat._msgList.Parent then
                    local cs = chat._msgList.CanvasSize.Y.Offset
                    local ws = chat._msgList.AbsoluteWindowSize.Y
                    local cp = chat._msgList.CanvasPosition.Y
                    if cs > ws and cp + ws < cs - 20 then
                        chat._unreadCount = (chat._unreadCount or 0) + added
                        if chat._unreadBar then chat._unreadBar.Visible = true end
                        if chat._unreadLabel then chat._unreadLabel.Text = string.format("已有新消息 当前消息量为%d条", chat._unreadCount) end
                    end
                end
            end
        end)
    end

    _G.BFH.UI.Build()
end