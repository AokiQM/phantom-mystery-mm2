_G.BFH = _G.BFH or {}
do
    local Theme = {
        Colors = {
            Background = Color3.fromRGB(10, 10, 10),
            Window = Color3.fromRGB(15, 15, 15),
            Panel = Color3.fromRGB(18, 18, 18),
            PanelDeep = Color3.fromRGB(8, 8, 8),
            Card = Color3.fromRGB(20, 20, 20),
            CardHover = Color3.fromRGB(26, 26, 26),
            Control = Color3.fromRGB(24, 24, 24),
            ControlHover = Color3.fromRGB(32, 32, 32),
            Stroke = Color3.fromRGB(34, 34, 34),
            StrokeStrong = Color3.fromRGB(48, 48, 48),
            Text = Color3.fromRGB(242, 242, 242),
            TextMuted = Color3.fromRGB(156, 156, 156),
            TextDim = Color3.fromRGB(112, 112, 112),
            Accent = Color3.fromRGB(60, 140, 255),
            AccentSoft = Color3.fromRGB(32, 72, 132),
            AccentDim = Color3.fromRGB(22, 44, 76),
            Success = Color3.fromRGB(82, 180, 126),
            Warning = Color3.fromRGB(226, 176, 74),
            Danger = Color3.fromRGB(235, 92, 92),
            ToggleOff = Color3.fromRGB(52, 52, 52),
            Overlay = Color3.fromRGB(0, 0, 0),
            Transparent = Color3.fromRGB(255, 255, 255),
        },

        Radius = {
            Window = 8,
            Panel = 6,
            Control = 5,
            Pill = 999,
        },

        Font = Enum.Font.SourceSans,
        FontBold = Enum.Font.SourceSansBold,

        Animation = {
            Press = 0.08,
            Fast = 0.12,
            Normal = 0.18,
            Slow = 0.26,
            TooltipDelay = 0,
            TouchTooltipDelay = 0.42,
            ToastDuration = 2.6,
            Style = Enum.EasingStyle.Quad,
            EmphasisStyle = Enum.EasingStyle.Back,
            Direction = Enum.EasingDirection.Out,
        },
    }

    local UI = {
        RootGui = nil,
        Main = nil,
        ShowButton = nil,
        Content = nil,
        ContentLayout = nil,
        Sidebar = nil,
        SidebarCollapsed = false,
        SidebarButtons = {},
        ShowButtonDragged = false,
        LogList = nil,
        ToastRoot = nil,
        ToastId = 0,
        ToastThrottle = {},
        Tooltip = nil,
        TooltipSource = nil,
        TooltipToken = 0,
        VisibleToken = 0,
        ModalRoot = nil,
        MarqueeToken = 0,
        Scale = nil,
        ToastScale = nil,
        TooltipScale = nil,
        ModalScale = nil,
        ShowScale = nil,
        Connections = {},
        PageConnections = {},
        LogConnections = {},
    }

    local Components = {}

    local Services = {
        TweenService = game:GetService("TweenService"),
        UserInputService = game:GetService("UserInputService"),
        TextService = game:GetService("TextService"),
        Players = game:GetService("Players"),
        CoreGui = game:GetService("CoreGui"),
    }

    local DefaultProperties = {
        Frame = {
            BorderSizePixel = 0,
        },
        ScrollingFrame = {
            BorderSizePixel = 0,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.fromOffset(0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Colors.StrokeStrong,
            ScrollingDirection = Enum.ScrollingDirection.Y,
        },
        TextLabel = {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Font = Theme.Font,
            TextColor3 = Theme.Colors.Text,
            TextSize = 15,
            TextWrapped = false,
        },
        TextButton = {
            AutoButtonColor = false,
            BorderSizePixel = 0,
            Font = Theme.Font,
            TextColor3 = Theme.Colors.Text,
            TextSize = 15,
            Text = "",
        },
        TextBox = {
            BorderSizePixel = 0,
            ClearTextOnFocus = false,
            Font = Theme.Font,
            TextColor3 = Theme.Colors.Text,
            TextSize = 15,
            PlaceholderColor3 = Theme.Colors.TextDim,
        },
        ImageButton = {
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
        },
        ImageLabel = {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
        },
        UIListLayout = {
            SortOrder = Enum.SortOrder.LayoutOrder,
        },
    }

    local function New(className, properties)
        local object = Instance.new(className)

        for key, value in pairs(DefaultProperties[className] or {}) do
            object[key] = value
        end

        for key, value in pairs(properties or {}) do
            object[key] = value
        end

        return object
    end

    local function Tween(object, properties, duration, easingStyle, easingDirection)
        if not object then
            return nil
        end

        local tweenInfo = TweenInfo.new(
            duration or Theme.Animation.Normal,
            easingStyle or Theme.Animation.Style,
            easingDirection or Theme.Animation.Direction
        )
        local tween = Services.TweenService:Create(object, tweenInfo, properties)
        tween:Play()
        return tween
    end

    local function IsPointerInput(input)
        return input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
    end

    local function AddCorner(parent, radius)
        return New("UICorner", {
            CornerRadius = UDim.new(0, radius or Theme.Radius.Control),
            Parent = parent,
        })
    end

    local function AddStroke(parent, color, thickness)
        local s = New("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = color or Theme.Colors.Stroke,
            Transparency = 1,
            Parent = parent,
        })
        if thickness then s.Thickness = thickness end
        return s
    end

    local function AddPadding(parent, left, right, top, bottom)
        return New("UIPadding", {
            PaddingLeft = UDim.new(0, left or 0),
            PaddingRight = UDim.new(0, right or left or 0),
            PaddingTop = UDim.new(0, top or 0),
            PaddingBottom = UDim.new(0, bottom or top or 0),
            Parent = parent,
        })
    end

    local function UpdateScrollCanvas(scroller, layout, extra)
        if scroller and scroller.Parent and layout and layout.Parent then
            local contentHeight = layout.AbsoluteContentSize.Y + (extra or 48)
            local viewportHeight = scroller.AbsoluteWindowSize and scroller.AbsoluteWindowSize.Y or scroller.AbsoluteSize.Y
            scroller.CanvasSize = UDim2.new(0, 0, 0, math.max(contentHeight, viewportHeight + 1))
        end
    end

    local function SetScrollCanvas(scroller, layout, extra, scope)
        local function update()
            UpdateScrollCanvas(scroller, layout, extra)
        end

        local connection = layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
        if UI.Track then
            UI.Track(connection, scope or "page")
        end

        local sizeConnection = scroller:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
        if UI.Track then
            UI.Track(sizeConnection, scope or "page")
        end

        update()
        task.defer(update)
        task.delay(0.15, update)
    end

    local function DisconnectConnections(connections)
        for _, connection in ipairs(connections) do
            if connection and connection.Connected then
                connection:Disconnect()
            end
        end

        table.clear(connections)
    end

    local function ContainsText(value, query)
        if query == "" then
            return true
        end

        if value == nil then
            return false
        end

        return string.find(string.lower(tostring(value)), query, 1, true) ~= nil
    end

    local function ShallowCopy(source)
        local copy = {}
        for key, value in pairs(source or {}) do
            copy[key] = value
        end
        return copy
    end

    local function ColorToHex(color)
        local r = math.floor(color.R * 255 + 0.5)
        local g = math.floor(color.G * 255 + 0.5)
        local b = math.floor(color.B * 255 + 0.5)
        return string.format("#%02X%02X%02X", r, g, b)
    end

    local function RefreshContentCanvas()
        if UI.Content and UI.ContentLayout then
            UpdateScrollCanvas(UI.Content, UI.ContentLayout, 20)
            task.defer(function()
                UpdateScrollCanvas(UI.Content, UI.ContentLayout, 20)
            end)
            task.delay(Theme.Animation.Normal + 0.04, function()
                UpdateScrollCanvas(UI.Content, UI.ContentLayout, 20)
            end)
        end
    end

    local function ResolveOptionValue(option)
        if type(option) == "table" then
            return option.value
        end
        return option
    end

    local function ResolveOptionLabel(option)
        if type(option) == "table" then
            return option.label or tostring(option.value)
        end
        return tostring(option)
    end

    local function ClampFrameToScreen(frame, position)
        if not frame or not UI.RootGui then
            return position
        end

        local container = frame.Parent or UI.RootGui
        local rootSize = container.AbsoluteSize
        local frameSize = frame.AbsoluteSize
        local anchor = frame.AnchorPoint
        local minX = math.floor(frameSize.X * anchor.X)
        local minY = math.floor(frameSize.Y * anchor.Y)
        local maxX = math.max(minX, rootSize.X - math.floor(frameSize.X * (1 - anchor.X)))
        local maxY = math.max(minY, rootSize.Y - math.floor(frameSize.Y * (1 - anchor.Y)))
        local scaledX = rootSize.X * position.X.Scale
        local scaledY = rootSize.Y * position.Y.Scale
        local absoluteX = math.clamp(scaledX + position.X.Offset, minX, maxX)
        local absoluteY = math.clamp(scaledY + position.Y.Offset, minY, maxY)
        local x = absoluteX - scaledX
        local y = absoluteY - scaledY

        return UDim2.new(position.X.Scale, x, position.Y.Scale, y)
    end

    function Components.Hover(object, normalColor, hoverColor)
        object.MouseEnter:Connect(function()
            Tween(object, { BackgroundColor3 = hoverColor }, Theme.Animation.Fast)
        end)

        object.MouseLeave:Connect(function()
            Tween(object, { BackgroundColor3 = normalColor }, Theme.Animation.Fast)
        end)
    end

    function Components.Interaction(object, normalColor, hoverColor, pressedColor)
        if not object then
            return
        end

        local function resolve(value)
            if type(value) == "function" then
                return value()
            end
            return value
        end

        local isHovering = false
        local isPressed = false

        object.MouseEnter:Connect(function()
            isHovering = true
            local color = resolve(hoverColor)
            if not isPressed and color then
                Tween(object, { BackgroundColor3 = color }, Theme.Animation.Fast)
            end
        end)

        object.MouseLeave:Connect(function()
            isHovering = false
            local color = resolve(normalColor)
            if not isPressed and color then
                Tween(object, { BackgroundColor3 = color }, Theme.Animation.Fast)
            end
        end)

        object.InputBegan:Connect(function(input)
            if not IsPointerInput(input) then
                return
            end

            isPressed = true
            local color = resolve(pressedColor) or resolve(hoverColor)
            if color then
                Tween(object, { BackgroundColor3 = color }, Theme.Animation.Press)
            end
        end)

        object.InputEnded:Connect(function(input)
            if not IsPointerInput(input) then
                return
            end

            isPressed = false
            local color = isHovering and (resolve(hoverColor) or resolve(normalColor)) or resolve(normalColor)
            if color then
                Tween(object, { BackgroundColor3 = color }, Theme.Animation.Fast)
            end
        end)
    end

    function Components.Tooltip(object, text)
        if not text or text == "" then
            return
        end

        local touchToken = 0
        local touchStart = nil

        object.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch and UI.ShowTooltip then
                touchToken += 1
                local token = touchToken
                touchStart = input.Position
                task.delay(Theme.Animation.TouchTooltipDelay, function()
                    if token == touchToken and touchStart and UI.ShowTooltip then
                        UI.ShowTooltip(text, object)
                    end
                end)
            end
        end)

        object.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch and touchStart then
                local delta = input.Position - touchStart
                if math.abs(delta.X) > 8 or math.abs(delta.Y) > 8 then
                    touchToken += 1
                    touchStart = nil
                    if UI.HideTooltip then
                        UI.HideTooltip(object)
                    end
                end
            end
        end)

        object.MouseLeave:Connect(function()
            if UI.HideTooltip then
                UI.HideTooltip()
            end
        end)

        object.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                touchToken += 1
                touchStart = nil
                if UI.HideTooltip then
                    UI.HideTooltip(object)
                end
            end

            if IsPointerInput(input) and UI.HideTooltip then
                UI.HideTooltip(object)
            end
        end)

        object.SelectionGained:Connect(function()
            if UI.ShowTooltip then
                UI.ShowTooltip(text, object)
            end
        end)

        object.SelectionLost:Connect(function()
            if UI.HideTooltip then
                UI.HideTooltip(object)
            end
        end)
    end

    function Components.Label(parent, text, size, color, bold)
        return New("TextLabel", {
            Font = bold and Theme.FontBold or Theme.Font,
            Text = text or "",
            TextColor3 = color or Theme.Colors.Text,
            TextSize = size or 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            Parent = parent,
        })
    end

    function Components.IconButton(parent, key, iconText, tooltipText, onClick)
        _G.BFH.Registry.Ensure(key, {
            Type = "icon-button",
            Title = tooltipText,
            Internal = true,
        })

        local button = New("TextButton", {
            Name = key,
            BackgroundColor3 = Theme.Colors.Control,
            Size = UDim2.fromOffset(28, 28),
            Text = iconText or "?",
            TextSize = 14,
            TextColor3 = Theme.Colors.TextMuted,
            Parent = parent,
        })
        AddCorner(button, Theme.Radius.Control)
        AddStroke(button)
        Components.Interaction(button, Theme.Colors.Control, Theme.Colors.ControlHover, Theme.Colors.AccentDim)
        Components.Tooltip(button, tooltipText or key)
        local icnScale = New("UIScale", { Scale = 1, Parent = button })

        button.MouseButton1Click:Connect(function()
            Tween(icnScale, { Scale = 0.92 }, Theme.Animation.Press)
            task.delay(Theme.Animation.Press + 0.04, function()
                Tween(icnScale, { Scale = 1 }, Theme.Animation.Fast)
            end)
            if onClick then
                onClick()
            end
        end)

        return button
    end

    function Components.Section(parent, title, subtitle)
        local section = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = parent,
        })

        local layout = New("UIListLayout", {
            Padding = UDim.new(0, 8),
            Parent = section,
        })

        local header = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, subtitle and 42 or 24),
            Parent = section,
        })

        local titleLabel = Components.Label(header, title, 18, Theme.Colors.Text, true)
        titleLabel.Size = UDim2.new(1, 0, 0, 20)
        titleLabel.Position = UDim2.fromOffset(0, 0)

        if subtitle then
            local subtitleLabel = Components.Label(header, subtitle, 14, Theme.Colors.TextDim, false)
            subtitleLabel.Size = UDim2.new(1, 0, 0, 18)
            subtitleLabel.Position = UDim2.fromOffset(0, 22)
        end

        return section, layout
    end

    function Components.ControlFrame(parent, height)
        local frame = New("Frame", {
            BackgroundColor3 = Theme.Colors.Card,
            Size = UDim2.new(1, 0, 0, height or 48),
            Parent = parent,
        })
        AddCorner(frame, Theme.Radius.Panel)
        AddStroke(frame)
        return frame
    end

    function Components.TitleBlock(parent, item, rightWidth)
        local title = Components.Label(parent, item.title or item.key, 16, Theme.Colors.Text, false)
        title.Position = UDim2.fromOffset(8, item.desc and 4 or 0)
        title.Size = UDim2.new(1, -(rightWidth or 110) - 24, 0, item.desc and 19 or 1)
        title.TextTruncate = Enum.TextTruncate.AtEnd

        if not item.desc then
            title.Size = UDim2.new(1, -(rightWidth or 110) - 24, 1, 0)
        end

        if item.desc then
            local desc = Components.Label(parent, item.desc, 15, Theme.Colors.TextDim, false)
            desc.Position = UDim2.fromOffset(8, 23)
            desc.Size = UDim2.new(1, -(rightWidth or 110) - 24, 0, 16)
            desc.TextTruncate = Enum.TextTruncate.AtEnd
        end

        Components.Tooltip(parent, (item.desc or item.title or item.key) .. "\nkey: " .. tostring(item.key or "无"))

        return title
    end

    function Components.InvokeItem(item, payload)
        payload = payload or {}
        payload.key = item.key
        payload.item = item
        payload.state = State
        _G.BFH.State:TouchRecent(item.key, item.title, item.page)

        if item.onChanged then
            local ok, err = pcall(item.onChanged, payload.value, payload)
            if not ok then
                _G.BFH.State:AddLog("ERROR", tostring(err), item.key)
            end
        end

        if not item.internal then
            _G.BFH.Registry.Invoke(item.key, payload)
        end
    end

    function Components.Button(parent, item)
        _G.BFH.Registry.Ensure(item.key, {
            Type = "button",
            Title = item.title,
            Page = item.page,
        })

        local button = New("TextButton", {
            Name = item.key,
            BackgroundColor3 = Theme.Colors.Card,
            Size = UDim2.new(1, 0, 0, 46),
            Text = "",
            Parent = parent,
        })
        AddCorner(button, Theme.Radius.Panel)
        AddStroke(button)
        Components.Interaction(button, Theme.Colors.Card, Theme.Colors.CardHover, Theme.Colors.ControlHover)
        local btnScale = New("UIScale", { Scale = 1, Parent = button })

        Components.TitleBlock(button, item, 88)

        local action = Components.Label(button, item.actionText or "执行", 13, Theme.Colors.TextMuted, true)
        action.AnchorPoint = Vector2.new(1, 0.5)
        action.BackgroundColor3 = Theme.Colors.Control
        action.BackgroundTransparency = 0
        action.Position = UDim2.new(1, -10, 0.5, 0)
        action.Size = UDim2.fromOffset(62, 24)
        action.TextXAlignment = Enum.TextXAlignment.Center
        AddCorner(action, Theme.Radius.Control)
        AddStroke(action)

        local function runButton()
            Tween(btnScale, { Scale = 0.96 }, Theme.Animation.Press)
            task.delay(Theme.Animation.Press + 0.04, function()
                Tween(btnScale, { Scale = 1 }, Theme.Animation.Normal)
            end)
            if not item.internal then
                _G.BFH.State:AddLog("ACTION", item.title or "按钮触发", item.key)
            end
            Components.InvokeItem(item, {
                type = "button",
            })
        end

        button.MouseButton1Click:Connect(function()
            if item.confirm and UI.Confirm then
                UI.Confirm(item.confirmTitle or item.title or "确认操作", item.confirmText or item.desc or "确认执行这个 UI 操作？", runButton)
            else
                runButton()
            end
        end)

        return button
    end

    function Components.Toggle(parent, item)
        _G.BFH.Registry.Ensure(item.key, {
            Type = "toggle",
            Title = item.title,
            Page = item.page,
        })

        local row = New("TextButton", {
            Name = item.key,
            BackgroundColor3 = Theme.Colors.Card,
            Size = UDim2.new(1, 0, 0, 48),
            Text = "",
            Parent = parent,
        })
        AddCorner(row, Theme.Radius.Panel)
        AddStroke(row)
        Components.Interaction(row, Theme.Colors.Card, Theme.Colors.CardHover, Theme.Colors.ControlHover)

        Components.TitleBlock(row, item, 72)

        local track = New("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = Theme.Colors.ToggleOff,
            Position = UDim2.new(1, -12, 0.5, 0),
            Size = UDim2.fromOffset(42, 22),
            Parent = row,
        })
        AddCorner(track, Theme.Radius.Pill)

        local knob = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Theme.Colors.Text,
            Size = UDim2.fromOffset(18, 18),
            Parent = track,
        })
        AddCorner(knob, Theme.Radius.Pill)

        local value = _G.BFH.State:Get("toggle", item.key, item.default == true)

        local function paint(instant)
            local targetColor = value and Theme.Colors.Accent or Theme.Colors.ToggleOff
            local targetPosition = value and UDim2.new(1, -11, 0.5, 0) or UDim2.new(0, 11, 0.5, 0)
            local targetSize = value and UDim2.fromOffset(19, 19) or UDim2.fromOffset(18, 18)
            local stroke = row:FindFirstChildOfClass("UIStroke")
            local strokeColor = value and Theme.Colors.AccentSoft or Theme.Colors.Stroke

            if instant then
                track.BackgroundColor3 = targetColor
                knob.Position = targetPosition
                knob.Size = targetSize
                if stroke then
                    stroke.Color = strokeColor
                end
            else
                Tween(track, { BackgroundColor3 = targetColor }, Theme.Animation.Normal)
                Tween(knob, { Position = targetPosition, Size = targetSize }, Theme.Animation.Normal)
                if stroke then
                    Tween(stroke, { Color = strokeColor }, Theme.Animation.Normal)
                end
            end
        end

        local function setValue(newValue, silent)
            value = newValue == true
            _G.BFH.State:Set("toggle", item.key, value)
            paint(false)

            if not silent then
                local logMsg = (item.title or item.key) .. " 已" .. (value and "开启" or "关闭")
                _G.BFH.State:AddLog("TOGGLE", logMsg, item.key)
                Components.InvokeItem(item, {
                    type = "toggle",
                    value = value,
                })
            end
        end

        row.MouseButton1Click:Connect(function()
            setValue(not value, false)
        end)

        _G.BFH.State:RegisterControl(item.key, {
            Type = "toggle",
            SetValue = setValue,
            GetValue = function()
                return value
            end,
        })
        if item.onChanged then
            _G.BFH.State.OnLoad = _G.BFH.State.OnLoad or {}
            _G.BFH.State.OnLoad[item.key] = item.onChanged
        end

        paint(true)
        return row
    end

    function Components.Slider(parent, item)
        _G.BFH.Registry.Ensure(item.key, {
            Type = "slider",
            Title = item.title,
            Page = item.page,
        })

        local minValue = item.min or 0
        local maxValue = item.max or 100
        if maxValue < minValue then
            minValue, maxValue = maxValue, minValue
        end
        local step = tonumber(item.step) or 1
        if step <= 0 then
            step = 1
        end

        local row = Components.ControlFrame(parent, 64)
        Components.TitleBlock(row, item, 132)

        local valueLabel = Components.Label(row, "", 13, Theme.Colors.TextMuted, true)
        valueLabel.AnchorPoint = Vector2.new(1, 0)
        valueLabel.Position = UDim2.new(1, -12, 0, 9)
        valueLabel.Size = UDim2.fromOffset(90, 18)
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right

        local bar = New("TextButton", {
            BackgroundColor3 = Theme.Colors.PanelDeep,
            Position = UDim2.new(0, 12, 1, -20),
            Size = UDim2.new(1, -24, 0, 5),
            Text = "",
            Parent = row,
        })
        AddCorner(bar, Theme.Radius.Pill)

        local fill = New("Frame", {
            BackgroundColor3 = Theme.Colors.Accent,
            Size = UDim2.new(0, 0, 1, 0),
            Parent = bar,
        })
        AddCorner(fill, Theme.Radius.Pill)

        local knob = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Theme.Colors.Text,
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.fromOffset(10, 10),
            Parent = bar,
        })
        AddCorner(knob, Theme.Radius.Pill)

        local dragging = false
        local changedWhileDragging = false
        local value = _G.BFH.State:Get("slider", item.key, item.default or minValue)

        local function normalize(raw)
            raw = math.clamp(raw, minValue, maxValue)
            local stepped = math.floor(((raw - minValue) / step) + 0.5) * step + minValue
            return math.clamp(stepped, minValue, maxValue)
        end

        local function formatValue(nextValue)
            if item.format then
                return string.format(item.format, nextValue)
            end

            if math.floor(nextValue) == nextValue then
                return tostring(nextValue)
            end

            return string.format("%.2f", nextValue)
        end

        local function paint(instant)
            local percent = 0
            if maxValue ~= minValue then
                percent = (value - minValue) / (maxValue - minValue)
            end
            percent = math.clamp(percent, 0, 1)
            valueLabel.Text = formatValue(value)

            local fillSize = UDim2.new(percent, 0, 1, 0)
            local knobPosition = UDim2.new(percent, 0, 0.5, 0)

            if instant then
                fill.Size = fillSize
                knob.Position = knobPosition
                valueLabel.TextColor3 = Theme.Colors.TextMuted
            else
                Tween(fill, { Size = fillSize }, Theme.Animation.Fast)
                Tween(knob, { Position = knobPosition }, Theme.Animation.Fast)
                Tween(valueLabel, { TextColor3 = Theme.Colors.Text }, Theme.Animation.Fast)
            end
        end

        local function setValue(nextValue, silent, instant)
            value = normalize(nextValue)
            _G.BFH.State:Set("slider", item.key, value)
            paint(instant == true)

            if not silent then
                _G.BFH.State:AddLog("SLIDER", (item.title or item.key) .. " = " .. formatValue(value), item.key)
                Components.InvokeItem(item, {
                    type = "slider",
                    value = value,
                })
            end
            task.delay(Theme.Animation.Slow, function()
                if valueLabel and valueLabel.Parent then
                    Tween(valueLabel, { TextColor3 = Theme.Colors.TextMuted }, Theme.Animation.Fast)
                end
            end)
        end

        local function setFromInput(input)
            local x = input.Position.X - bar.AbsolutePosition.X
            local percent = math.clamp(x / math.max(bar.AbsoluteSize.X, 1), 0, 1)
            setValue(minValue + (maxValue - minValue) * percent, true)
            if item.onChanged then pcall(item.onChanged, value) end
            changedWhileDragging = true
        end

        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                setFromInput(input)
            end
        end)

        UI.Track(Services.UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                setFromInput(input)
            end
        end), "page")

        UI.Track(Services.UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if dragging and changedWhileDragging then
                    setValue(value, false)
                end
                dragging = false
                changedWhileDragging = false
            end
        end), "page")

        _G.BFH.State:RegisterControl(item.key, {
            Type = "slider",
            SetValue = setValue,
            GetValue = function()
                return value
            end,
        })
        if item.onChanged then
            _G.BFH.State.OnLoad = _G.BFH.State.OnLoad or {}
            _G.BFH.State.OnLoad[item.key] = item.onChanged
        end

        value = normalize(value)
        paint(true)
        return row
    end

    function Components.TextInput(parent, item)
        _G.BFH.Registry.Ensure(item.key, {
            Type = "input",
            Title = item.title,
            Page = item.page,
        })

        local row = Components.ControlFrame(parent, 50)
        Components.TitleBlock(row, item, 220)

        local input = New("TextBox", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = Theme.Colors.PanelDeep,
            PlaceholderText = item.placeholder or "",
            Position = UDim2.new(1, -12, 0.5, 0),
            Size = UDim2.fromOffset(item.width or 190, 28),
            Text = _G.BFH.State:Get("input", item.key, item.default or ""),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = row,
        })
        AddCorner(input, Theme.Radius.Control)
        local inputStroke = AddStroke(input)
        AddPadding(input, 8, 8, 0, 0)

        input.Focused:Connect(function()
            Tween(inputStroke, { Color = Theme.Colors.AccentSoft }, Theme.Animation.Fast)
        end)

        input.FocusLost:Connect(function()
            Tween(inputStroke, { Color = Theme.Colors.Stroke }, Theme.Animation.Fast)
            _G.BFH.State:Set("input", item.key, input.Text)
            _G.BFH.State:AddLog("INPUT", (item.title or item.key) .. " = " .. input.Text, item.key)
            Components.InvokeItem(item, {
                type = "input",
                value = input.Text,
            })
        end)

        _G.BFH.State:RegisterControl(item.key, {
            Type = "input",
            SetValue = function(value)
                if type(value) == "table" then return end
                input.Text = tostring(value or "")
                _G.BFH.State:Set("input", item.key, input.Text)
            end,
            GetValue = function()
                return input.Text
            end,
        })

        return row
    end

    function Components.TextArea(parent, item)
        _G.BFH.Registry.Ensure(item.key, {
            Type = "textarea",
            Title = item.title,
            Page = item.page,
        })

        local row = Components.ControlFrame(parent, item.height or 180)

        -- 居中标题
        local titleLabel = Components.Label(row, item.title or "", 18, Theme.Colors.Text, true)
        titleLabel.Size = UDim2.new(1, -24, 0, 22)
        titleLabel.Position = UDim2.fromOffset(12, 6)
        titleLabel.TextXAlignment = Enum.TextXAlignment.Center

        -- 居中描述
        if item.desc then
            local descLabel = Components.Label(row, item.desc, 14, Theme.Colors.TextDim, false)
            descLabel.Size = UDim2.new(1, -24, 0, 18)
            descLabel.Position = UDim2.fromOffset(12, 30)
            descLabel.TextXAlignment = Enum.TextXAlignment.Center
        end

        local input = New("TextBox", {
            AnchorPoint = Vector2.new(0, 0),
            BackgroundColor3 = Theme.Colors.PanelDeep,
            PlaceholderText = item.placeholder or "输入内容",
            Position = UDim2.fromOffset(12, 52),
            Size = UDim2.new(1, -24, 1, -66),
            Text = _G.BFH.State:Get("input", item.key, item.default or ""),
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Top,
            MultiLine = true,
            TextWrapped = true,
            ClearTextOnFocus = false,
            Parent = row,
        })
        AddCorner(input, Theme.Radius.Control)
        local inputStroke = AddStroke(input)
        AddPadding(input, 8, 8, 8, 8)

        input.Focused:Connect(function()
            Tween(inputStroke, { Color = Theme.Colors.AccentSoft }, Theme.Animation.Fast)
        end)

        input.FocusLost:Connect(function()
            Tween(inputStroke, { Color = Theme.Colors.Stroke }, Theme.Animation.Fast)
            _G.BFH.State:Set("input", item.key, input.Text)
        end)

        _G.BFH.State:RegisterControl(item.key, {
            Type = "textarea",
            SetValue = function(value)
                if type(value) == "table" then return end
                input.Text = tostring(value or "")
                _G.BFH.State:Set("input", item.key, input.Text)
            end,
            GetValue = function()
                return input.Text
            end,
        })

        return row
    end

    function Components.Dropdown(parent, item)
        _G.BFH.Registry.Ensure(item.key, {
            Type = "dropdown",
            Title = item.title,
            Page = item.page,
        })

        local options = item.options or {}

        local root = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 50),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = parent,
        })

        local layout = New("UIListLayout", {
            Padding = UDim.new(0, 6),
            Parent = root,
        })

        local row = Components.ControlFrame(root, 50)
        Components.TitleBlock(row, item, 190)

        local display = New("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = Theme.Colors.PanelDeep,
            Position = UDim2.new(1, -12, 0.5, 0),
            Size = UDim2.fromOffset(170, 28),
            Text = "",
            Parent = row,
        })
        AddCorner(display, Theme.Radius.Control)
        local displayStroke = AddStroke(display)
        Components.Interaction(display, Theme.Colors.PanelDeep, Theme.Colors.Control, Theme.Colors.ControlHover)

        local displayLabel = Components.Label(display, "", 14, Theme.Colors.TextMuted, false)
        displayLabel.Position = UDim2.fromOffset(8, 0)
        displayLabel.Size = UDim2.new(1, -28, 1, 0)
        displayLabel.TextTruncate = Enum.TextTruncate.AtEnd

        local arrow = Components.Label(display, "v", 13, Theme.Colors.TextDim, true)
        arrow.AnchorPoint = Vector2.new(1, 0.5)
        arrow.Position = UDim2.new(1, -8, 0.5, 0)
        arrow.Size = UDim2.fromOffset(14, 16)
        arrow.TextXAlignment = Enum.TextXAlignment.Center

        local optionsFrame = New("ScrollingFrame", {
            BackgroundColor3 = Theme.Colors.PanelDeep,
            Size = UDim2.new(1, 0, 0, 0),
            Visible = false,
            CanvasSize = UDim2.fromOffset(0, 0),
            ScrollBarThickness = 3,
            Parent = root,
        })
        AddCorner(optionsFrame, Theme.Radius.Panel)
        AddStroke(optionsFrame)
        AddPadding(optionsFrame, 8, 8, 8, 8)

        local optionsLayout = New("UIListLayout", {
            Padding = UDim.new(0, 8),
            Parent = optionsFrame,
        })
        SetScrollCanvas(optionsFrame, optionsLayout, 16, "page")

        local function optionText(option)
            if type(option) == "table" then
                return option.label or tostring(option.value)
            end
            return tostring(option)
        end

        local function optionValue(option)
            if type(option) == "table" then
                return option.value
            end
            return option
        end

        local value = _G.BFH.State:Get("dropdown", item.key, item.default or optionValue(options[1]) or "")
        local openToken = 0
        local optionButtons = {}

        local function findLabel(nextValue)
            if type(nextValue) == "table" then return "(无效)" end
            for _, option in ipairs(options) do
                if optionValue(option) == nextValue then
                    return optionText(option)
                end
            end

            return tostring(nextValue or "")
        end

        local function setOpen(open)
            openToken += 1
            local token = openToken
            local itemH = 34; local gap = 8; local count = #options
            local contentH = count * itemH + (count > 0 and (count - 1) * gap or 0) + 16
            local height = contentH
            if open then
                optionsFrame.Visible = true
                optionsFrame.BackgroundTransparency = 1
                optionsFrame.CanvasPosition = Vector2.zero
                optionsFrame.Size = UDim2.new(1, 0, 0, 0)
                Tween(optionsFrame, {
                    BackgroundTransparency = 0,
                    Size = UDim2.new(1, 0, 0, height),
                }, Theme.Animation.Normal)
                Tween(root, { Size = UDim2.new(1, 0, 0, 56 + height) }, Theme.Animation.Normal)
                arrow.Text = "^"
            else
                Tween(optionsFrame, {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                }, Theme.Animation.Fast)
                Tween(root, { Size = UDim2.new(1, 0, 0, 50) }, Theme.Animation.Fast)
                task.delay(Theme.Animation.Fast + 0.02, function()
                    if optionsFrame and optionsFrame.Parent and token == openToken and not open then
                        optionsFrame.Visible = false
                    end
                end)
                arrow.Text = "v"
            end
            RefreshContentCanvas()
        end

        local function setValue(nextValue, silent)
            if type(nextValue) == "table" then return end
            value = nextValue
            _G.BFH.State:Set("dropdown", item.key, value)
            displayLabel.Text = findLabel(value)
            Tween(displayLabel, { TextColor3 = Theme.Colors.Text }, Theme.Animation.Fast)
            Tween(arrow, { TextColor3 = Theme.Colors.Accent }, Theme.Animation.Fast)
            Tween(displayStroke, { Color = Theme.Colors.AccentSoft }, Theme.Animation.Fast)
            for nextOptionValue, data in pairs(optionButtons) do
                local active = nextOptionValue == value
                Tween(data.Button, { BackgroundColor3 = active and Theme.Colors.AccentDim or Theme.Colors.Control }, Theme.Animation.Fast)
                Tween(data.Label, { TextColor3 = active and Theme.Colors.Text or Theme.Colors.TextMuted }, Theme.Animation.Fast)
                if data.Stroke then
                    Tween(data.Stroke, { Color = active and Theme.Colors.AccentSoft or Theme.Colors.Stroke }, Theme.Animation.Fast)
                end
            end
            setOpen(false)

            if not silent then
                _G.BFH.State:AddLog("DROPDOWN", (item.title or item.key) .. " = " .. displayLabel.Text, item.key)
                Components.InvokeItem(item, {
                    type = "dropdown",
                    value = value,
                    label = displayLabel.Text,
                })
            end
        end

        for _, option in ipairs(options) do
            local nextOptionValue = optionValue(option)
            local optionButton = New("TextButton", {
                BackgroundColor3 = Theme.Colors.Control,
                Size = UDim2.new(1, 0, 0, 34),
                Text = "",
                Parent = optionsFrame,
            })
            AddCorner(optionButton, Theme.Radius.Control)
            local optionStroke = AddStroke(optionButton)
            Components.Interaction(
                optionButton,
                function()
                    return nextOptionValue == value and Theme.Colors.AccentDim or Theme.Colors.Control
                end,
                function()
                    return nextOptionValue == value and Theme.Colors.AccentDim or Theme.Colors.ControlHover
                end,
                Theme.Colors.AccentDim
            )

            local optionLabel = Components.Label(optionButton, optionText(option), 14, Theme.Colors.TextMuted, false)
            optionLabel.Position = UDim2.fromOffset(8, 0)
            optionLabel.Size = UDim2.new(1, -16, 1, 0)
            optionLabel.TextTruncate = Enum.TextTruncate.AtEnd
            optionButtons[nextOptionValue] = {
                Button = optionButton,
                Label = optionLabel,
                Stroke = optionStroke,
            }

            optionButton.MouseButton1Click:Connect(function()
                setValue(nextOptionValue, false)
            end)
        end

        display.MouseButton1Click:Connect(function()
            setOpen(not optionsFrame.Visible)
        end)

        function item.SetOptions(_, newOptions)
            options = newOptions or {}
            for _, child in ipairs(optionsFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            optionButtons = {}
            for _, option in ipairs(options) do
                local nextOptionValue = optionValue(option)
                local optionButton = New("TextButton", {
                    BackgroundColor3 = Theme.Colors.Control,
                    Size = UDim2.new(1, 0, 0, 34),
                    Text = "",
                    Parent = optionsFrame,
                })
                AddCorner(optionButton, Theme.Radius.Control)
                local optionStroke = AddStroke(optionButton)
                Components.Interaction(
                    optionButton,
                    function()
                        return nextOptionValue == value and Theme.Colors.AccentDim or Theme.Colors.Control
                    end,
                    function()
                        return nextOptionValue == value and Theme.Colors.AccentDim or Theme.Colors.ControlHover
                    end,
                    Theme.Colors.AccentDim
                )
                local optionLabel = Components.Label(optionButton, optionText(option), 14, Theme.Colors.TextMuted, false)
                optionLabel.Position = UDim2.fromOffset(8, 0)
                optionLabel.Size = UDim2.new(1, -16, 1, 0)
                optionLabel.TextTruncate = Enum.TextTruncate.AtEnd
                optionButtons[nextOptionValue] = {
                    Button = optionButton,
                    Label = optionLabel,
                    Stroke = optionStroke,
                }
                optionButton.MouseButton1Click:Connect(function()
                    setValue(nextOptionValue, false)
                end)
            end
            displayLabel.Text = findLabel(value)
            for nextOptValue, data in pairs(optionButtons) do
                local active = nextOptValue == value
                data.Button.BackgroundColor3 = active and Theme.Colors.AccentDim or Theme.Colors.Control
                data.Label.TextColor3 = active and Theme.Colors.Text or Theme.Colors.TextMuted
                if data.Stroke then
                    data.Stroke.Color = active and Theme.Colors.AccentSoft or Theme.Colors.Stroke
                end
            end
        end

        _G.BFH.State:RegisterControl(item.key, {
            Type = "dropdown",
            SetValue = setValue,
            SetOptions = item.SetOptions,
            GetValue = function()
                return value
            end,
        })
        if item.onChanged then
            _G.BFH.State.OnLoad = _G.BFH.State.OnLoad or {}
            _G.BFH.State.OnLoad[item.key] = item.onChanged
        end

        setValue(value, true)
        return root
    end

    function Components.Segmented(parent, item)
        _G.BFH.Registry.Ensure(item.key, {
            Type = "segment",
            Title = item.title,
            Page = item.page,
            Internal = item.internal == true,
        })

        local options = item.options or {}
        local stacked = item.stacked == true
        local containerWidth = item.width or 284
        local root = Components.ControlFrame(parent, stacked and (item.desc and 92 or 74) or (item.desc and 72 or 54))
        local titleLabel = Components.TitleBlock(root, item, stacked and 24 or (containerWidth + 24))
        if stacked and not item.desc then
            titleLabel.Position = UDim2.fromOffset(12, 6)
            titleLabel.Size = UDim2.new(1, -48, 0, 22)
        end

        local container = New("Frame", {
            AnchorPoint = stacked and Vector2.new(0, 0) or Vector2.new(1, 0.5),
            BackgroundColor3 = Theme.Colors.PanelDeep,
            Position = stacked and UDim2.new(0, 12, 1, -40) or UDim2.new(1, -12, 0.5, item.desc and 10 or 0),
            Size = stacked and UDim2.new(1, -24, 0, 30) or UDim2.fromOffset(containerWidth, 30),
            Parent = root,
        })
        AddCorner(container, Theme.Radius.Control)
        AddStroke(container)
        AddPadding(container, 3, 3, 3, 3)

        local layout = New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 4),
            Parent = container,
        })

        local buttons = {}

        local function optionText(option)
            return type(option) == "table" and (option.label or tostring(option.value)) or tostring(option)
        end

        local function optionValue(option)
            return type(option) == "table" and option.value or option
        end

        local value = _G.BFH.State:Get("segment", item.key, item.default or optionValue(options[1]) or "")

        local function paint()
            for nextValue, button in pairs(buttons) do
                local active = nextValue == value
                local label = button:FindFirstChild("SegmentLabel")
                Tween(button, {
                    BackgroundColor3 = active and Theme.Colors.Accent or Theme.Colors.Control,
                }, Theme.Animation.Fast)
                if label then
                    Tween(label, { TextColor3 = active and Theme.Colors.Text or Theme.Colors.TextMuted }, Theme.Animation.Fast)
                end
            end
        end

        local function setValue(nextValue, silent, instant)
            value = nextValue
            _G.BFH.State:Set("segment", item.key, value)
            paint()

            if not silent then
                _G.BFH.State:AddLog("SEGMENT", (item.title or item.key) .. " = " .. tostring(value), item.key)
                Components.InvokeItem(item, {
                    type = "segment",
                    value = value,
                })
            end
        end

        local buttonCount = math.max(#options, 1)
        local buttonWidth = math.floor((containerWidth - 6 - math.max(#options - 1, 0) * 4) / buttonCount)
        for _, option in ipairs(options) do
            local nextValue = optionValue(option)
            local button = New("TextButton", {
                BackgroundColor3 = Theme.Colors.Control,
                Size = stacked and UDim2.new(1 / buttonCount, -math.ceil((math.max(buttonCount - 1, 0) * 4) / buttonCount), 1, 0) or UDim2.new(0, buttonWidth, 1, 0),
                Text = "",
                Parent = container,
            })
            AddCorner(button, Theme.Radius.Control)
            Components.Interaction(
                button,
                function()
                    return nextValue == value and Theme.Colors.Accent or Theme.Colors.Control
                end,
                function()
                    return nextValue == value and Theme.Colors.Accent or Theme.Colors.ControlHover
                end,
                Theme.Colors.AccentDim
            )

            local buttonLabel = Components.Label(button, optionText(option), 13, Theme.Colors.TextMuted, false)
            buttonLabel.Name = "SegmentLabel"
            buttonLabel.Size = UDim2.fromScale(1, 1)
            buttonLabel.TextXAlignment = Enum.TextXAlignment.Center
            buttonLabel.TextTruncate = Enum.TextTruncate.AtEnd

            buttons[nextValue] = button

            button.MouseButton1Click:Connect(function()
                setValue(nextValue, false)
            end)
        end

        _G.BFH.State:RegisterControl(item.key, {
            Type = "segment",
            SetValue = setValue,
            GetValue = function()
                return value
            end,
        })
        if item.onChanged then
            _G.BFH.State.OnLoad = _G.BFH.State.OnLoad or {}
            _G.BFH.State.OnLoad[item.key] = item.onChanged
        end

        paint()
        UI.Track(layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(paint), "page")
        return root
    end

    function Components.NumberInput(parent, item)
        _G.BFH.Registry.Ensure(item.key, {
            Type = "number",
            Title = item.title,
            Page = item.page,
        })

        local minValue = item.min or -999999
        local maxValue = item.max or 999999
        if maxValue < minValue then
            minValue, maxValue = maxValue, minValue
        end
        local step = tonumber(item.step) or 1
        if step <= 0 then
            step = 1
        end
        local value = tonumber(_G.BFH.State:Get("number", item.key, item.default or 0)) or 0

        local row = Components.ControlFrame(parent, 50)
        Components.TitleBlock(row, item, 180)

        local box = New("TextBox", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = Theme.Colors.PanelDeep,
            Position = UDim2.new(1, -46, 0.5, 0),
            Size = UDim2.fromOffset(96, 28),
            Text = tostring(value),
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = row,
        })
        AddCorner(box, Theme.Radius.Control)
        AddStroke(box)

        local function format(nextValue)
            if item.format then
                return string.format(item.format, nextValue)
            end
            if math.floor(nextValue) == nextValue then
                return tostring(nextValue)
            end
            return string.format("%.2f", nextValue)
        end

        local function setValue(nextValue, silent)
            local raw = math.clamp(tonumber(nextValue) or value, minValue, maxValue)
            local stepped = math.floor(((raw - minValue) / step) + 0.5) * step + minValue
            value = math.clamp(stepped, minValue, maxValue)
            _G.BFH.State:Set("number", item.key, value)
            box.Text = format(value)
            Tween(box, { TextColor3 = Theme.Colors.Text }, Theme.Animation.Fast)
            if not silent then
                _G.BFH.State:AddLog("NUMBER", (item.title or item.key) .. " = " .. box.Text, item.key)
                Components.InvokeItem(item, { type = "number", value = value })
            end
        end

        local minus = New("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = Theme.Colors.Control,
            Position = UDim2.new(1, -148, 0.5, 0),
            Size = UDim2.fromOffset(28, 28),
            Text = "-",
            TextSize = 18,
            Parent = row,
        })
        AddCorner(minus, Theme.Radius.Control)
        AddStroke(minus)
        Components.Interaction(minus, Theme.Colors.Control, Theme.Colors.ControlHover, Theme.Colors.AccentDim)

        local plus = New("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = Theme.Colors.Control,
            Position = UDim2.new(1, -12, 0.5, 0),
            Size = UDim2.fromOffset(28, 28),
            Text = "+",
            TextSize = 18,
            Parent = row,
        })
        AddCorner(plus, Theme.Radius.Control)
        AddStroke(plus)
        Components.Interaction(plus, Theme.Colors.Control, Theme.Colors.ControlHover, Theme.Colors.AccentDim)

        minus.MouseButton1Click:Connect(function()
            setValue(value - step, false)
        end)
        plus.MouseButton1Click:Connect(function()
            setValue(value + step, false)
        end)
        box.FocusLost:Connect(function()
            setValue(box.Text, false)
        end)

        _G.BFH.State:RegisterControl(item.key, {
            Type = "number",
            SetValue = setValue,
            GetValue = function()
                return value
            end,
        })
        if item.onChanged then
            _G.BFH.State.OnLoad = _G.BFH.State.OnLoad or {}
            _G.BFH.State.OnLoad[item.key] = item.onChanged
        end

        setValue(value, true)
        return row
    end

    function Components.ColorPicker(parent, item)
        _G.BFH.Registry.Ensure(item.key, {
            Type = "color",
            Title = item.title,
            Page = item.page,
        })

        local presets = item.presets or {
            { label = "Trace 蓝", value = Color3.fromRGB(60, 140, 255) },
            { label = "冷白", value = Color3.fromRGB(230, 236, 245) },
            { label = "雾灰", value = Color3.fromRGB(120, 130, 145) },
            { label = "柔绿", value = Color3.fromRGB(82, 180, 126) },
            { label = "琥珀", value = Color3.fromRGB(226, 176, 74) },
        }
        local value = _G.BFH.State:Get("color", item.key, item.default or presets[1].value)

        local root = Components.ControlFrame(parent, 64)
        Components.TitleBlock(root, item, 236)

        local swatch = New("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = value,
            Position = UDim2.new(1, -204, 0.5, 0),
            Size = UDim2.fromOffset(30, 30),
            Parent = root,
        })
        AddCorner(swatch, Theme.Radius.Control)
        AddStroke(swatch, Theme.Colors.StrokeStrong)

        local holder = New("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -12, 0.5, 0),
            Size = UDim2.fromOffset(184, 30),
            Parent = root,
        })
        local layout = New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 6),
            Parent = holder,
        })

        local function setValue(nextValue, label, silent)
            value = nextValue
            _G.BFH.State:Set("color", item.key, value)
            Tween(swatch, { BackgroundColor3 = value }, Theme.Animation.Fast)
            if not silent then
                _G.BFH.State:AddLog("COLOR", (item.title or item.key) .. " = " .. (label or ColorToHex(value)), item.key)
                Components.InvokeItem(item, { type = "color", value = value, label = label, hex = ColorToHex(value) })
            end
        end

        for _, preset in ipairs(presets) do
            local button = New("TextButton", {
                BackgroundColor3 = preset.value,
                Size = UDim2.fromOffset(24, 24),
                Text = "",
                Parent = holder,
            })
            AddCorner(button, Theme.Radius.Pill)
            AddStroke(button, Theme.Colors.StrokeStrong)
            Components.Tooltip(button, preset.label .. " " .. ColorToHex(preset.value))
            button.MouseButton1Click:Connect(function()
                setValue(preset.value, preset.label, false)
            end)
        end

        _G.BFH.State:RegisterControl(item.key, {
            Type = "color",
            SetValue = setValue,
            GetValue = function()
                return value
            end,
        })
        if item.onChanged then
            _G.BFH.State.OnLoad = _G.BFH.State.OnLoad or {}
            _G.BFH.State.OnLoad[item.key] = item.onChanged
        end

        return root
    end

    function Components.MultiDropdown(parent, item)
        _G.BFH.Registry.Ensure(item.key, {
            Type = "multi-dropdown",
            Title = item.title,
            Page = item.page,
        })

        local root = Components.ControlFrame(parent, 56)
        Components.TitleBlock(root, item, 230)

        local selected = _G.BFH.State:Get("multi-dropdown", item.key, ShallowCopy(item.default or {}))
        local options = item.options or {}

        local display = New("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = Theme.Colors.PanelDeep,
            Position = UDim2.new(1, -12, 0, 30),
            Size = UDim2.fromOffset(220, 30),
            Text = "",
            Parent = root,
        })
        AddCorner(display, Theme.Radius.Control)
        local displayStroke = AddStroke(display)
        Components.Interaction(display, Theme.Colors.PanelDeep, Theme.Colors.Control, Theme.Colors.ControlHover)

        local label = Components.Label(display, "", 13, Theme.Colors.TextMuted, false)
        label.Position = UDim2.fromOffset(8, 0)
        label.Size = UDim2.new(1, -26, 1, 0)
        label.TextTruncate = Enum.TextTruncate.AtEnd

        local arrow = Components.Label(display, "v", 13, Theme.Colors.TextDim, true)
        arrow.AnchorPoint = Vector2.new(1, 0.5)
        arrow.Position = UDim2.new(1, -8, 0.5, 0)
        arrow.Size = UDim2.fromOffset(14, 16)
        arrow.TextXAlignment = Enum.TextXAlignment.Center

        local popup = New("ScrollingFrame", {
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundColor3 = Theme.Colors.PanelDeep,
            Position = UDim2.new(0.5, 0, 0, 52.5),
            Size = UDim2.new(1, -24, 0, 0),
            Visible = false,
            CanvasSize = UDim2.fromOffset(0, 0),
            ScrollBarThickness = 3,
            Parent = root,
            ZIndex = 35,
        })
        AddCorner(popup, Theme.Radius.Panel)
        AddStroke(popup, Theme.Colors.Stroke)
        AddPadding(popup, 7, 7, 7, 7)
        local popupLayout = New("UIListLayout", {
            Padding = UDim.new(0, 5),
            Parent = popup,
        })
        SetScrollCanvas(popup, popupLayout, 14, "page")

        local function selectedText()
            local names = {}
            for _, option in ipairs(options) do
                local optionValue = ResolveOptionValue(option)
                if selected[optionValue] then
                    local label = item.optionLabelCallback and item.optionLabelCallback(optionValue, ResolveOptionLabel(option)) or ResolveOptionLabel(option)
                    table.insert(names, label)
                end
            end
            return #names == 0 and "未选择" or table.concat(names, ", ")
        end

        local function syncLabel()
            label.Text = selectedText()
            local hasSelected = false
            for _, enabled in pairs(selected) do
                if enabled then
                    hasSelected = true
                    break
                end
            end
            Tween(label, { TextColor3 = hasSelected and Theme.Colors.Text or Theme.Colors.TextMuted }, Theme.Animation.Fast)
            Tween(arrow, { TextColor3 = hasSelected and Theme.Colors.Accent or Theme.Colors.TextDim }, Theme.Animation.Fast)
            Tween(displayStroke, { Color = hasSelected and Theme.Colors.AccentSoft or Theme.Colors.Stroke }, Theme.Animation.Fast)
        end

        local function fire(silent)
            _G.BFH.State:Set("multi-dropdown", item.key, selected)
            if silent then return end
            _G.BFH.State:AddLog("MULTI", (item.title or item.key) .. " = " .. selectedText(), item.key)
            Components.InvokeItem(item, { type = "multi-dropdown", value = selected, label = selectedText() })
        end

        local openToken = 0
        local optionRows = {}

        local function paintOptions()
            for optionValue, data in pairs(optionRows) do
                local disabled = item.isOptionDisabled and item.isOptionDisabled(optionValue)
                local active = selected[optionValue] == true and not disabled
                data.Check.Text = active and "✓" or ""
                local opt = data.option
                if opt and disabled and item.optionLabelCallback then
                    data.Text.Text = item.optionLabelCallback(optionValue, ResolveOptionLabel(opt))
                elseif opt and not disabled and item.optionLabelCallback then
                    data.Text.Text = ResolveOptionLabel(opt)
                end
                Tween(data.Button, { BackgroundColor3 = disabled and Theme.Colors.ControlDim or (active and Theme.Colors.AccentDim or Theme.Colors.Control) }, Theme.Animation.Fast)
                Tween(data.Text, { TextColor3 = disabled and Theme.Colors.TextDim or (active and Theme.Colors.Text or Theme.Colors.TextMuted) }, Theme.Animation.Fast)
                if data.Stroke then
                    Tween(data.Stroke, { Color = disabled and Theme.Colors.Stroke or (active and Theme.Colors.AccentSoft or Theme.Colors.Stroke) }, Theme.Animation.Fast)
                end
            end
        end

        for _, option in ipairs(options) do
            local optionValue = ResolveOptionValue(option)
            local defaultLabel = ResolveOptionLabel(option)
            local optionLabel = item.optionLabelCallback and item.optionLabelCallback(optionValue, defaultLabel) or defaultLabel
            local optionButton = New("TextButton", {
                BackgroundColor3 = Theme.Colors.Control,
                Size = UDim2.new(1, 0, 0, 26),
                Text = "",
                Parent = popup,
                ZIndex = 36,
            })
            AddCorner(optionButton, Theme.Radius.Control)
            local optionStroke = AddStroke(optionButton)
            Components.Interaction(
                optionButton,
                function()
                    return selected[optionValue] and Theme.Colors.AccentDim or Theme.Colors.Control
                end,
                function()
                    return selected[optionValue] and Theme.Colors.AccentDim or Theme.Colors.ControlHover
                end,
                Theme.Colors.AccentDim
            )

            local check = Components.Label(optionButton, selected[optionValue] and "✓" or "", 14, Theme.Colors.Accent, true)
            check.Position = UDim2.fromOffset(8, 0)
            check.Size = UDim2.fromOffset(20, 26)
            check.TextXAlignment = Enum.TextXAlignment.Center
            check.ZIndex = 37

            local text = Components.Label(optionButton, optionLabel, 13, Theme.Colors.TextMuted, false)
            text.Position = UDim2.fromOffset(34, 0)
            text.Size = UDim2.new(1, -42, 1, 0)
            text.TextTruncate = Enum.TextTruncate.AtEnd
            text.ZIndex = 37
            optionRows[optionValue] = {
                Button = optionButton,
                Check = check,
                Text = text,
                Stroke = optionStroke,
                option = option,
            }

            optionButton.MouseButton1Click:Connect(function()
                if item.isOptionDisabled and item.isOptionDisabled(optionValue) then return end
                selected[optionValue] = not selected[optionValue] or nil
                syncLabel()
                paintOptions()
                fire()
            end)
        end

        local popupHeight = 170

        local function setOpen(open)
            openToken += 1
            local token = openToken
            arrow.Text = open and "^" or "v"
            if open then
                popup.Visible = true
                popup.BackgroundTransparency = 1
                popup.Size = UDim2.new(1, -24, 0, 1)
                local optionCount = #options
                local itemH = 26
                local gap = 5
                local padding = 14
                local h = optionCount * itemH + math.max(optionCount - 1, 0) * gap + padding
                task.defer(function()
                    if token ~= openToken then return end
                    Tween(popup, {
                        BackgroundTransparency = 0,
                        Size = UDim2.new(1, -24, 0, h),
                    }, Theme.Animation.Normal)
                    Tween(root, { Size = UDim2.new(1, 0, 0, 60 + h) }, Theme.Animation.Normal)
                end)
            else
                Tween(popup, {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -24, 0, 1),
                }, Theme.Animation.Normal)
                Tween(root, { Size = UDim2.new(1, 0, 0, 56) }, Theme.Animation.Normal)
                task.delay(Theme.Animation.Normal + 0.03, function()
                    if popup and popup.Parent and token == openToken then
                        popup.Visible = false
                    end
                end)
            end
            RefreshContentCanvas()
        end

        display.MouseButton1Click:Connect(function()
            setOpen(not popup.Visible)
        end)

        _G.BFH.State:RegisterControl(item.key, {
            Type = "multi-dropdown",
            SetValue = function(nextValue, silent)
                selected = ShallowCopy(nextValue or {})
                syncLabel()
                paintOptions()
                fire(silent)
            end,
            GetValue = function()
                return selected
            end,
        })
        if item.onChanged then
            _G.BFH.State.OnLoad = _G.BFH.State.OnLoad or {}
            _G.BFH.State.OnLoad[item.key] = item.onChanged
        end

        syncLabel()
        paintOptions()
        return root
    end

    function Components.Keybind(parent, item)
        _G.BFH.Registry.Ensure(item.key, {
            Type = "keybind",
            Title = item.title,
            Page = item.page,
        })

        local value = _G.BFH.State.Keybinds[item.key] or item.default or "未绑定"
        local row = Components.ControlFrame(parent, 48)
        Components.TitleBlock(row, item, 140)

        local button = New("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = Theme.Colors.PanelDeep,
            Position = UDim2.new(1, -12, 0.5, 0),
            Size = UDim2.fromOffset(116, 28),
            Text = tostring(value),
            TextColor3 = Theme.Colors.TextMuted,
            TextSize = 13,
            Parent = row,
        })
        AddCorner(button, Theme.Radius.Control)
        AddStroke(button)
        Components.Interaction(button, Theme.Colors.PanelDeep, Theme.Colors.Control, Theme.Colors.ControlHover)

        local waiting = false
        local normalStroke = button:FindFirstChildOfClass("UIStroke")
        button.MouseButton1Click:Connect(function()
            waiting = true
            button.Text = "按下按键..."
            Tween(button, { BackgroundColor3 = Theme.Colors.AccentDim, TextColor3 = Theme.Colors.Text }, Theme.Animation.Fast)
            if normalStroke then
                Tween(normalStroke, { Color = Theme.Colors.AccentSoft }, Theme.Animation.Fast)
            end
            _G.BFH.State:AddLog("UI", "等待键位绑定: " .. (item.title or item.key), item.key)
        end)

        UI.Track(Services.UserInputService.InputBegan:Connect(function(input, processed)
            if not waiting or processed then
                return
            end
            if input.UserInputType ~= Enum.UserInputType.Keyboard then
                return
            end
            waiting = false
            value = input.KeyCode.Name
            _G.BFH.State.Keybinds[item.key] = value
            button.Text = value
            Tween(button, { BackgroundColor3 = Theme.Colors.PanelDeep, TextColor3 = Theme.Colors.TextMuted }, Theme.Animation.Fast)
            if normalStroke then
                Tween(normalStroke, { Color = Theme.Colors.Stroke }, Theme.Animation.Fast)
            end
            _G.BFH.State:AddLog("KEY", (item.title or item.key) .. " = " .. value, item.key)
            Components.InvokeItem(item, { type = "keybind", value = value })
        end), "page")

        return row
    end

    function Components.Progress(parent, item)
        if not item.internal then
            _G.BFH.Registry.Ensure(item.key, {
                Type = "progress",
                Title = item.title,
                Page = item.page,
                Internal = item.internal == true,
            })
        end

        local value = math.clamp(item.value or item.default or 0, 0, 1)
        local row = Components.ControlFrame(parent, 58)
        Components.TitleBlock(row, item, 120)

        local valueLabel = Components.Label(row, string.format("%d%%", value * 100), 13, Theme.Colors.TextMuted, true)
        valueLabel.AnchorPoint = Vector2.new(1, 0)
        valueLabel.Position = UDim2.new(1, -12, 0, 9)
        valueLabel.Size = UDim2.fromOffset(70, 18)
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right

        local bar = New("Frame", {
            BackgroundColor3 = Theme.Colors.PanelDeep,
            Position = UDim2.new(0, 12, 1, -20),
            Size = UDim2.new(1, -24, 0, 8),
            Parent = row,
        })
        AddCorner(bar, Theme.Radius.Pill)

        local fill = New("Frame", {
            BackgroundColor3 = item.color or Theme.Colors.Accent,
            Size = UDim2.new(value, 0, 1, 0),
            Parent = bar,
        })
        AddCorner(fill, Theme.Radius.Pill)

        return row
    end

    function Components.TagRow(parent, item)
        if not item.internal then
            _G.BFH.Registry.Ensure(item.key, {
                Type = "tags",
                Title = item.title,
                Page = item.page,
                Internal = true,
            })
        end

        local row = Components.ControlFrame(parent, 58)
        Components.TitleBlock(row, item, 300)

        local holder = New("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -12, 0.5, 0),
            Size = UDim2.fromOffset(280, 28),
            Parent = row,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 6),
            Parent = holder,
        })

        for _, tag in ipairs(item.tags or {}) do
            local tagLabel = Components.Label(holder, type(tag) == "table" and tag.label or tostring(tag), 12, Theme.Colors.TextMuted, true)
            tagLabel.BackgroundColor3 = type(tag) == "table" and (tag.color or Theme.Colors.Control) or Theme.Colors.Control
            tagLabel.BackgroundTransparency = 0
            tagLabel.Size = UDim2.fromOffset(type(tag) == "table" and (tag.width or 62) or 62, 24)
            tagLabel.TextXAlignment = Enum.TextXAlignment.Center
            AddCorner(tagLabel, Theme.Radius.Pill)
            AddStroke(tagLabel)
        end

        return row
    end

    function Components.Table(parent, item)
        if not item.internal then
            _G.BFH.Registry.Ensure(item.key, {
                Type = "table",
                Title = item.title,
                Page = item.page,
                Internal = true,
            })
        end

        local rows = item.rows or {}
        if type(rows) == "function" then
            local ok, result = pcall(rows)
            rows = ok and result or {}
        end

        local columns = item.columns or {
            { key = "name", label = "名称", width = 0.45 },
            { key = "value", label = "值", width = 0.55 },
        }

        local root = New("Frame", {
            BackgroundColor3 = Theme.Colors.Card,
            Size = UDim2.new(1, 0, 0, math.max(90, 34 + (#rows * 30))),
            Parent = parent,
        })
        AddCorner(root, Theme.Radius.Panel)
        AddStroke(root)
        AddPadding(root, 10, 10, 10, 10)

        local header = New("Frame", {
            BackgroundColor3 = Theme.Colors.PanelDeep,
            Size = UDim2.new(1, 0, 0, 34),
            Parent = root,
        })
        AddCorner(header, Theme.Radius.Control)

        local xOffset = 0
        for _, column in ipairs(columns) do
            local label = Components.Label(header, column.label, 12, Theme.Colors.TextDim, true)
            label.Position = UDim2.new(xOffset, 8, 0, 0)
            label.Size = UDim2.new(column.width, -10, 1, 0)
            xOffset += column.width
        end

        local y = 34
        for _, row in ipairs(rows) do
            local line = New("Frame", {
                BackgroundColor3 = Theme.Colors.Control,
                BackgroundTransparency = 0.25,
                Position = UDim2.fromOffset(0, y),
                Size = UDim2.new(1, 0, 0, 26),
                Parent = root,
            })
            AddCorner(line, Theme.Radius.Control)

            xOffset = 0
            for _, column in ipairs(columns) do
                local value = row[column.key]
                local cell = Components.Label(line, tostring(value or ""), 12, Theme.Colors.TextMuted, false)
                cell.Position = UDim2.new(xOffset, 8, 0, 0)
                cell.Size = UDim2.new(column.width, -10, 1, 0)
                cell.TextTruncate = Enum.TextTruncate.AtEnd
                xOffset += column.width
            end
            y += 30
        end

        return root
    end

    function Components.StatusLabel(parent, item)
        if not item.internal then
            _G.BFH.Registry.Ensure(item.key, {
                Type = "status",
                Title = item.title,
                Page = item.page,
                Internal = true,
            })
        end

        local row = Components.ControlFrame(parent, 44)
        Components.TitleBlock(row, item, 130)

        local resolvedValue = item.value
        if type(resolvedValue) == "function" then
            local ok, result = pcall(resolvedValue)
            resolvedValue = ok and result or "读取失败"
        end

        local badge = Components.Label(row, resolvedValue or "待定", 13, Theme.Colors.Text, true)
        badge.AnchorPoint = Vector2.new(1, 0.5)
        badge.BackgroundColor3 = Theme.Colors.AccentDim
        badge.BackgroundTransparency = 0
        badge.Position = UDim2.new(1, -12, 0.5, 0)
        badge.Size = UDim2.fromOffset(100, 24)
        badge.TextXAlignment = Enum.TextXAlignment.Center
        AddCorner(badge, Theme.Radius.Control)
        AddStroke(badge, Theme.Colors.AccentSoft)

        _G.BFH.State:RegisterControl(item.key, {
            Type = "status",
            SetValue = function(_, value)
                if type(value) ~= "string" then return end
                badge.Text = value
            end,
            GetValue = function()
                return badge.Text
            end,
        })

        return row
    end

    function Components.ListItem(parent, item)
        if not item.internal then
            _G.BFH.Registry.Ensure(item.key, {
                Type = "list-item",
                Title = item.title,
                Page = item.page,
                Internal = item.internal == true,
            })
        end

        local row = Components.ControlFrame(parent, item.desc and 52 or 36)
        Components.TitleBlock(row, item, item.badge and 110 or 24)

        if item.badge then
            local badge = Components.Label(row, item.badge, 12, Theme.Colors.TextMuted, true)
            badge.AnchorPoint = Vector2.new(1, 0.5)
            badge.BackgroundColor3 = Theme.Colors.Control
            badge.BackgroundTransparency = 0
            badge.Position = UDim2.new(1, -12, 0.5, 0)
            badge.Size = UDim2.fromOffset(86, 22)
            badge.TextXAlignment = Enum.TextXAlignment.Center
            AddCorner(badge, Theme.Radius.Control)
        end

        return row
    end

    function Components.CategoryCard(parent, item)
        _G.BFH.Registry.Ensure(item.key, {
            Type = "category-card",
            Title = item.title,
            Page = item.page,
            TargetPage = item.targetPage,
            Internal = true,
        })

        local button = New("TextButton", {
            BackgroundColor3 = Theme.Colors.Card,
            Size = UDim2.new(1, 0, 0, 58),
            Text = "",
            Parent = parent,
        })
        AddCorner(button, Theme.Radius.Panel)
        AddStroke(button)
        Components.Interaction(button, Theme.Colors.Card, Theme.Colors.CardHover, Theme.Colors.ControlHover)
        local cardScale = New("UIScale", { Scale = 1, Parent = button })
        button.MouseEnter:Connect(function()
            Tween(cardScale, { Scale = 1.02 }, Theme.Animation.Normal)
        end)
        button.MouseLeave:Connect(function()
            Tween(cardScale, { Scale = 1 }, Theme.Animation.Normal)
        end)

        local icon = Components.Label(button, item.icon or ">", 18, Theme.Colors.Accent, true)
        icon.BackgroundColor3 = Theme.Colors.AccentDim
        icon.BackgroundTransparency = 0
        icon.Position = UDim2.fromOffset(12, 11)
        icon.Size = UDim2.fromOffset(36, 36)
        icon.TextXAlignment = Enum.TextXAlignment.Center
        AddCorner(icon, Theme.Radius.Control)
        AddStroke(icon, Theme.Colors.AccentSoft)

        local title = Components.Label(button, item.title, 16, Theme.Colors.Text, true)
        title.Position = UDim2.fromOffset(58, 8)
        title.Size = UDim2.new(1, -112, 0, 20)

        local desc = Components.Label(button, item.desc, 13, Theme.Colors.TextDim, false)
        desc.Position = UDim2.fromOffset(58, 30)
        desc.Size = UDim2.new(1, -112, 0, 18)
        desc.TextTruncate = Enum.TextTruncate.AtEnd

        local arrow = Components.Label(button, ">", 18, Theme.Colors.TextDim, true)
        arrow.AnchorPoint = Vector2.new(1, 0.5)
        arrow.Position = UDim2.new(1, -14, 0.5, 0)
        arrow.Size = UDim2.fromOffset(20, 24)
        arrow.TextXAlignment = Enum.TextXAlignment.Center

        button.MouseButton1Click:Connect(function()
            if item.targetPage then
                UI.SetPage(item.targetPage)
            end
            _G.BFH.State:AddLog("UI", "进入 " .. (item.title or item.targetPage or ""), item.key)
        end)

        return button
    end

    function Components.Collapsible(parent, item)
        _G.BFH.Registry.Ensure(item.key, {
            Type = "collapsible-group",
            Title = item.title,
            Page = item.page,
            Internal = true,
        })

        local root = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = parent,
        })

        local layout = New("UIListLayout", {
            Padding = UDim.new(0, 8),
            Parent = root,
        })

        local header = New("TextButton", {
            BackgroundColor3 = Theme.Colors.Control,
            Size = UDim2.new(1, 0, 0, 38),
            Text = "",
            Parent = root,
        })
        AddCorner(header, Theme.Radius.Panel)
        AddStroke(header)
        Components.Interaction(header, Theme.Colors.Control, Theme.Colors.ControlHover, Theme.Colors.AccentDim)

        local arrow = Components.Label(header, "v", 14, Theme.Colors.TextDim, true)
        arrow.Position = UDim2.fromOffset(12, 0)
        arrow.Size = UDim2.fromOffset(18, 38)
        arrow.TextXAlignment = Enum.TextXAlignment.Center

        local title = Components.Label(header, item.title or "分组", 16, Theme.Colors.Text, true)
        title.Position = UDim2.fromOffset(36, 0)
        title.Size = UDim2.new(1, -48, 1, 0)

        local content = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            ClipsDescendants = true,
            Parent = root,
        })

        local contentLayout = New("UIListLayout", {
            Padding = UDim.new(0, 8),
            Parent = content,
        })

        local collapsed = _G.BFH.State.Collapsed[item.key] == true

        local function getContentHeight()
            return contentLayout.AbsoluteContentSize.Y + 8
        end

        local animToken = 0
        local function animate(expand)
            animToken += 1
            local token = animToken
            if expand then
                content.Visible = true
                content.Size = UDim2.new(1, 0, 0, 0)
                task.defer(function()
                    if token ~= animToken then return end
                    local h = getContentHeight()
                    Tween(content, { Size = UDim2.new(1, 0, 0, h) }, Theme.Animation.Normal)
                end)
            else
                local cur = content.AbsoluteSize.Y
                if cur > 0 then
                    Tween(content, { Size = UDim2.new(1, 0, 0, 1) }, Theme.Animation.Fast)
                    task.delay(Theme.Animation.Fast + 0.03, function()
                        if token == animToken then
                            content.Visible = false
                        end
                    end)
                else
                    content.Visible = false
                end
            end
        end

        header.MouseButton1Click:Connect(function()
            collapsed = not collapsed
            _G.BFH.State.Collapsed[item.key] = collapsed
            arrow.Text = collapsed and ">" or "v"
            animate(not collapsed)
            _G.BFH.State:AddLog("UI", (collapsed and "折叠 " or "展开 ") .. (item.title or item.key), item.key)
        end)

        if collapsed then
            content.Visible = false
            content.Size = UDim2.new(1, 0, 0, 0)
        else
            task.defer(function()
                local h = getContentHeight()
                content.Size = UDim2.new(1, 0, 0, h)
            end)
        end
        return root, content
    end

    function Components.LogOutput(parent, item)
        _G.BFH.Registry.Ensure(item.key, {
            Type = "log-output",
            Title = item.title,
            Page = item.page,
            Internal = true,
        })

        local root = New("Frame", {
            BackgroundColor3 = Theme.Colors.Card,
            Size = UDim2.new(1, 0, 0, 300),
            Parent = parent,
        })
        AddCorner(root, Theme.Radius.Panel)
        AddStroke(root)
        AddPadding(root, 10, 10, 10, 10)

        local header = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 32),
            Parent = root,
        })

        local title = Components.Label(header, item.title or "日志输出", 17, Theme.Colors.Text, true)
        title.Size = UDim2.new(1, -100, 1, 0)

        local clear = New("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = Theme.Colors.Control,
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.fromOffset(84, 26),
            Text = "清空",
            TextSize = 14,
            TextColor3 = Theme.Colors.TextMuted,
            Parent = header,
        })
        AddCorner(clear, Theme.Radius.Control)
        AddStroke(clear)
        Components.Interaction(clear, Theme.Colors.Control, Theme.Colors.ControlHover, Theme.Colors.AccentDim)

        _G.BFH.Registry.Ensure(item.clearKey or "logs.clear", {
            Type = "button",
            Title = "清空日志",
            Page = item.page,
            Internal = true,
        })

        clear.MouseButton1Click:Connect(function()
            _G.BFH.State:ClearLogs()
            _G.BFH.State:AddLog("UI", "日志已清空", item.clearKey or "logs.clear")
        end)

        local scroller = New("ScrollingFrame", {
            BackgroundColor3 = Theme.Colors.PanelDeep,
            Position = UDim2.fromOffset(0, 38),
            Size = UDim2.new(1, 0, 1, -38),
            CanvasSize = UDim2.fromOffset(0, 0),
            Parent = root,
        })
        AddCorner(scroller, Theme.Radius.Control)
        AddStroke(scroller)
        AddPadding(scroller, 8, 8, 8, 8)

        local layout = New("UIListLayout", {
            Padding = UDim.new(0, 5),
            Parent = scroller,
        })
        SetScrollCanvas(scroller, layout, 16, "log")

        UI.LogList = scroller
        UI.RefreshLogs()
        return root
    end

    function Components.SearchBox(parent)
        local box = New("TextBox", {
            BackgroundColor3 = Theme.Colors.PanelDeep,
            PlaceholderText = "搜索 key / 标题 / 描述",
            Size = UDim2.fromOffset(250, 30),
            Text = _G.BFH.State.SearchText,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = parent,
        })
        AddCorner(box, Theme.Radius.Control)
        AddStroke(box)
        AddPadding(box, 9, 9, 0, 0)

        box:GetPropertyChangedSignal("Text"):Connect(function()
            local previousText = _G.BFH.State.SearchText or ""
            _G.BFH.State.SearchText = box.Text
            if _G.BFH.State.SearchScope == "global" and box.Text ~= "" then
                if _G.BFH.State.CurrentPage ~= "search" then
                    _G.BFH.State.SearchReturnPage = _G.BFH.State.CurrentPage
                end
                _G.BFH.State.CurrentPage = "search"
                UI.UpdateSidebar()
            elseif _G.BFH.State.SearchScope == "global" and previousText ~= "" and box.Text == "" and _G.BFH.State.CurrentPage == "search" then
                local returnPage = _G.BFH.State.SearchReturnPage or _G.BFH.AppConfig.DefaultPage
                if _G.BFH.Pages.ById[returnPage] then
                    _G.BFH.State.CurrentPage = returnPage
                    UI.UpdateSidebar()
                end
            end
            if UI.RenderPage then
                UI.RenderPage(_G.BFH.State.CurrentPage)
            end
        end)

        return box
    end

    function Components.Marquee(parent, text)
        local root = New("Frame", {
            BackgroundColor3 = Theme.Colors.PanelDeep,
            ClipsDescendants = true,
            Size = UDim2.fromOffset(250, 30),
            Parent = parent,
        })
        AddCorner(root, Theme.Radius.Control)

        local label = Components.Label(root, text or "", 14, Theme.Colors.TextMuted, false)
        label.Name = "MarqueeText"
        label.AnchorPoint = Vector2.new(0, 0.5)
        label.Position = UDim2.new(0, 0, 0.5, 0)
        label.Size = UDim2.new(0, 0, 0, root.Size.Y.Offset)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Center
        label.TextTruncate = Enum.TextTruncate.None

        local function start()
            UI.MarqueeToken += 1
            local token = UI.MarqueeToken
            task.defer(function()
                task.wait()
                while root and root.Parent and token == UI.MarqueeToken do
                    local rootWidth = math.max(root.AbsoluteSize.X, 1)
                    local textWidth = Services.TextService:GetTextSize(label.Text, label.TextSize, label.Font, Vector2.new(math.huge, root.AbsoluteSize.Y)).X
                    label.Size = UDim2.fromOffset(textWidth, root.AbsoluteSize.Y)
                    label.Position = UDim2.new(0, rootWidth + 100, 0.5, 0)
                    task.wait()

                    local distance = rootWidth + textWidth + 100
                    local duration = math.max(distance / 72, 1.2) / 1.2
                    local tween = Tween(label, {
                        Position = UDim2.new(0, -textWidth, 0.5, 0),
                    }, duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                    if tween then
                        tween.Completed:Wait()
                    else
                        task.wait(duration)
                    end
                end
            end)
        end

        start()
        return root
    end


    function Components.LockOverlay(parent, text)
        local overlay = Instance.new("TextButton")
        overlay.BackgroundColor3 = Theme.Colors.Card
        overlay.BackgroundTransparency = 0.9
        overlay.Size = UDim2.fromScale(1, 1)
        overlay.Position = UDim2.fromOffset(0, 0)
        overlay.Text = ""
        overlay.AutoButtonColor = false
        overlay.BorderSizePixel = 0
        overlay.Parent = parent
        overlay.ZIndex = 50
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, Theme.Radius.Panel)
        corner.Parent = overlay
        local stroke = Instance.new("UIStroke")
        stroke.Color = Theme.Colors.Stroke
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = overlay
        -- Lock icon
        local icon = Instance.new("ImageLabel")
        icon.Image = "rbxassetid://124695679871798"
        icon.BackgroundTransparency = 1
        icon.Size = UDim2.new(0, 28, 0, 28)
        icon.Position = UDim2.new(0.5, -14, 0.32, -14)
        icon.ImageColor3 = Theme.Colors.TextMuted
        icon.ImageTransparency = 0.25
        icon.ZIndex = 51
        icon.Parent = overlay
        -- Hint text
        local hint = Instance.new("TextLabel")
        hint.Text = text or "当前功能未开发。后续将会挨个补齐。"
        hint.BackgroundTransparency = 1
        hint.Size = UDim2.new(1, -24, 0, 24)
        hint.Position = UDim2.new(0, 12, 0.58, 0)
        hint.TextSize = 15
        hint.TextColor3 = Theme.Colors.TextDim
        hint.TextXAlignment = Enum.TextXAlignment.Center
        hint.TextYAlignment = Enum.TextYAlignment.Top
        hint.Font = Theme.Font
        hint.ZIndex = 51
        hint.Parent = overlay
        return overlay
    end

    function UI.GetScreenParent()
        local candidates = {}

        local okHui, hui = pcall(function()
            if gethui then
                return gethui()
            end
            return nil
        end)

        if okHui and hui then
            table.insert(candidates, hui)
        end

        table.insert(candidates, Services.CoreGui)

        local localPlayer = Services.Players.LocalPlayer
        if localPlayer then
            table.insert(candidates, localPlayer:WaitForChild("PlayerGui"))
        end

        for _, candidate in ipairs(candidates) do
            local testGui = Instance.new("ScreenGui")
            local ok = pcall(function()
                testGui.Parent = candidate
            end)
            testGui:Destroy()

            if ok then
                return candidate
            end
        end

        return Services.Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    function UI.GetWindowPresetSize()
        for _, preset in ipairs(_G.BFH.AppConfig.WindowPresets) do
            if preset.value == _G.BFH.State.WindowPreset then
                return preset.size
            end
        end

        return _G.BFH.AppConfig.WindowSize
    end

    function UI.GetBoundedWindowSize(targetSize)
        targetSize = targetSize or UI.GetWindowPresetSize()
        if not UI.RootGui then
            return targetSize
        end

        local rootSize = UI.RootGui.AbsoluteSize
        if rootSize.X <= 0 or rootSize.Y <= 0 then
            return targetSize
        end

        local scale = math.max(_G.BFH.State.DpiScale or 1, 0.01)
        local maxWidth = math.max(1, math.floor((rootSize.X - 24) / scale))
        local maxHeight = math.max(1, math.floor((rootSize.Y - 24) / scale))

        return Vector2.new(math.min(targetSize.X, maxWidth), math.min(targetSize.Y, maxHeight))
    end

    function UI.ApplyWindowBounds()
        if UI.Main then
            local targetSize = UI.GetBoundedWindowSize(UI.GetWindowPresetSize())
            UI.Main.Size = UDim2.fromOffset(targetSize.X, targetSize.Y)
            UI.Main.Position = ClampFrameToScreen(UI.Main, UI.Main.Position)
        end

        if UI.ShowButton then
            UI.ShowButton.Position = ClampFrameToScreen(UI.ShowButton, UI.ShowButton.Position)
        end
    end

    function UI.SetDpi(scale)
        _G.BFH.State.DpiScale = math.clamp(scale or 1, _G.BFH.AppConfig.MinimumDpi / 100, _G.BFH.AppConfig.MaximumDpi / 100)
        local percent = math.floor(_G.BFH.State.DpiScale * 100 + 0.5)
        local presetValue = tostring(percent)
        _G.BFH.State.Sliders["settings.ui.dpi"] = percent
        _G.BFH.State.Segments["settings.ui.scale_preset"] = presetValue

        local dpiControl = _G.BFH.State.Controls["settings.ui.dpi"]
        if dpiControl and dpiControl.SetValue then
            dpiControl.SetValue(percent, true, true)
        end

        local presetControl = _G.BFH.State.Controls["settings.ui.scale_preset"]
        if presetControl and presetControl.SetValue then
            presetControl.SetValue(presetValue, true, true)
        end

        if UI.Scale then
            UI.Scale.Scale = _G.BFH.State.DpiScale
        end
        if UI.ToastScale then
            UI.ToastScale.Scale = _G.BFH.State.DpiScale
        end
        if UI.TooltipScale then
            UI.TooltipScale.Scale = _G.BFH.State.DpiScale
        end
        if UI.ModalScale then
            UI.ModalScale.Scale = _G.BFH.State.DpiScale
        end
        if UI.ShowScale then
            UI.ShowScale.Scale = _G.BFH.State.DpiScale
        end
        UI.ApplyWindowBounds()
    end

    function UI.SetWindowPreset(presetId)
        _G.BFH.State.WindowPreset = presetId or _G.BFH.State.WindowPreset
        _G.BFH.State.Dropdowns["settings.ui.window_preset"] = _G.BFH.State.WindowPreset

        local targetSize = UI.GetBoundedWindowSize(UI.GetWindowPresetSize())

        if UI.Main then
            Tween(UI.Main, {
                Size = UDim2.fromOffset(targetSize.X, targetSize.Y),
            }, Theme.Animation.Slow)
            task.delay(Theme.Animation.Slow + 0.02, function()
                if UI.Main then
                    UI.Main.Position = ClampFrameToScreen(UI.Main, UI.Main.Position)
                end
            end)
        end
    end

    function UI.SetWindowTransparency(value)
        _G.BFH.State.WindowTransparency = math.clamp(value or 0, 0, 45)
        local transparency = _G.BFH.State.WindowTransparency / 100

        if UI.Main then
            UI.Main.BackgroundTransparency = transparency
        end
        if UI.Sidebar then
            UI.Sidebar.BackgroundTransparency = 0
        end
        if UI.Content then
            UI.Content.BackgroundTransparency = 0
        end
    end

    function UI.SetVisible(visible)
        UI.VisibleToken = (UI.VisibleToken or 0) + 1
        local token = UI.VisibleToken
        local MinimizeDuration = 0.06

        if visible then
            if UI.Main then
                UI.Main.Visible = true
                UI.Main.Size = UDim2.fromOffset(1, 1)
                task.defer(function()
                    if token ~= UI.VisibleToken then return end
                    Tween(UI.Main, {
                        Size = UI._savedWindowSize or UDim2.fromOffset(760, 500),
                    }, Theme.Animation.Slow, Enum.EasingStyle.Back)
                end)
            end
            if UI.ShowButton then
                Tween(UI.ShowButton, { BackgroundTransparency = 1, ImageTransparency = 1 }, MinimizeDuration)
                if UI.ShowButtonStroke then Tween(UI.ShowButtonStroke, { Transparency = 1 }, MinimizeDuration) end
                task.delay(MinimizeDuration + 0.02, function()
                    if UI.ShowButton and token == UI.VisibleToken and visible then
                        UI.ShowButton.Visible = false
                        UI.ShowButton.ImageTransparency = 0
                    end
                end)
            end
        else
            if UI.Main then
                UI._savedWindowSize = UI.Main.Size
                Tween(UI.Main, {
                    Size = UDim2.fromOffset(1, 1),
                }, Theme.Animation.Normal)
                task.delay(Theme.Animation.Normal + 0.04, function()
                    if token == UI.VisibleToken and not visible then
                        UI.Main.Visible = false
                        UI.Main.Size = UI._savedWindowSize
                    end
                end)
            end
            if UI.ShowButton then
                UI.ShowButton.Visible = true
                UI.ShowButton.BackgroundTransparency = 1
                UI.ShowButton.ImageTransparency = 1
                Tween(UI.ShowButton, { BackgroundTransparency = 1, ImageTransparency = 0 }, MinimizeDuration)
                if UI.ShowButtonStroke then Tween(UI.ShowButtonStroke, { Transparency = 0 }, MinimizeDuration) end
            end
        end
        _G.BFH.State:AddLog("UI", visible and "已打开窗口" or "已隐藏窗口", "window.visibility")
    end

    function UI.ToggleSidebar()
        UI.SidebarCollapsed = not UI.SidebarCollapsed
        local width = UI.SidebarCollapsed and 56 or 150

        if UI.Sidebar then
            Tween(UI.Sidebar, { Size = UDim2.new(0, width - 1, 1, -43) }, Theme.Animation.Normal)
        end

        if UI.Content then
            Tween(UI.Content, {
                Position = UDim2.fromOffset(width, 42),
                Size = UDim2.new(1, -width, 1, -42),
            }, Theme.Animation.Normal)
        end

        for _, button in pairs(UI.SidebarButtons) do
            local label = button:FindFirstChild("PageName")
            if label then
                label.Visible = not UI.SidebarCollapsed
            end
        end

        _G.BFH.State:AddLog("UI", UI.SidebarCollapsed and "侧栏已折叠" or "侧栏已展开", "window.sidebar")
    end

    function UI.Track(connection, scope)
        if not connection then
            return nil
        end

        if scope == "page" then
            table.insert(UI.PageConnections, connection)
        elseif scope == "log" then
            table.insert(UI.LogConnections, connection)
        else
            table.insert(UI.Connections, connection)
        end
        return connection
    end

    function UI.ClearPageConnections()
        DisconnectConnections(UI.PageConnections)
    end

    function UI.ClearLogConnections()
        DisconnectConnections(UI.LogConnections)
    end

    function UI.Destroy()
        UI.ClearPageConnections()
        UI.ClearLogConnections()
        DisconnectConnections(UI.Connections)
        _G.BFH.State:ClearVisibleControls()

        if UI.RootGui then
            UI.RootGui:Destroy()
        end
        UI.RootGui = nil
        UI.Main = nil
        UI.ShowButton = nil
        UI.Content = nil
        UI.ContentLayout = nil
        UI.Sidebar = nil
        UI.LogList = nil
        UI.ToastRoot = nil
        UI.ToastThrottle = {}
        UI.ToastScale = nil
        UI.TooltipScale = nil
        UI.TooltipSource = nil
        UI.ModalScale = nil
        UI.ShowScale = nil
        UI.Livestream = nil
        UI.ShowButtonStroke = nil
        UI.Tooltip = nil
        UI.TooltipToken += 1
        UI.VisibleToken += 1
        UI.ModalRoot = nil
        UI.SidebarButtons = {}
        UI.Connections = {}
        UI.PageConnections = {}
        UI.LogConnections = {}
    end

    function UI.RefreshLogs()
        if not UI.LogList then
            return
        end

        UI.ClearLogConnections()
        for _, child in ipairs(UI.LogList:GetChildren()) do
            if not child:IsA("UICorner") and not child:IsA("UIStroke") and not child:IsA("UIPadding") then
                child:Destroy()
            end
        end

        if not UI.LogList:FindFirstChildOfClass("UIPadding") then
            AddPadding(UI.LogList, 8, 8, 8, 8)
        end

        local layout = New("UIListLayout", {
            Padding = UDim.new(0, 5),
            Parent = UI.LogList,
        })
        SetScrollCanvas(UI.LogList, layout, 16, "log")

        if #_G.BFH.State.Logs == 0 then
            local empty = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 34),
                Text = "暂无日志",
                TextColor3 = Theme.Colors.TextDim,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = UI.LogList,
            })
            return empty
        end

        for _, log in ipairs(_G.BFH.State.Logs) do
            local row = New("Frame", {
                BackgroundColor3 = Theme.Colors.Control,
                Size = UDim2.new(1, 0, 0, 30),
                Parent = UI.LogList,
            })
            AddCorner(row, Theme.Radius.Control)

            local level = Components.Label(row, log.Level, 12, Theme.Colors.Accent, true)
            level.Position = UDim2.fromOffset(8, 0)
            level.Size = UDim2.fromOffset(58, 30)

            local msgText = type(log.Message) == "string" and log.Message or tostring(log.Message or ""); local message = Components.Label(row, log.Time .. "  " .. msgText, 13, Theme.Colors.TextMuted, false)
            message.Position = UDim2.fromOffset(70, 0)
            message.Size = UDim2.new(1, -210, 1, 0)
            message.TextTruncate = Enum.TextTruncate.AtEnd

            local key = Components.Label(row, log.Key, 12, Theme.Colors.TextDim, false)
            key.AnchorPoint = Vector2.new(1, 0)
            key.Position = UDim2.new(1, -8, 0, 0)
            key.Size = UDim2.fromOffset(130, 30)
            key.TextXAlignment = Enum.TextXAlignment.Right
            key.TextTruncate = Enum.TextTruncate.AtEnd
        end
    end

    function UI.BuildToastRoot(parent)
        UI.ToastRoot = New("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -math.floor(8 * _G.BFH.State.DpiScale), 0, math.floor(10 * _G.BFH.State.DpiScale)),
            Size = UDim2.fromOffset(460, 420),
            Parent = parent,
            ZIndex = 80,
        })
        UI.ToastScale = New("UIScale", {
            Scale = _G.BFH.State.DpiScale,
            Parent = UI.ToastRoot,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6),
            Parent = UI.ToastRoot,
        })
    end

    function UI.Notify(level, message, key)
        if not UI.ToastRoot then
            return
        end

        key = tostring(key or "")
        message = tostring(message or "")

        local now = os.clock()
        local throttleKey = key ~= "" and key or message
        if throttleKey ~= "" and UI.ToastThrottle[throttleKey] and now - UI.ToastThrottle[throttleKey] < 0.1 then
            return
        end
        UI.ToastThrottle[throttleKey] = now

        UI.ToastId += 1
        local toastId = UI.ToastId
        local accent = level == "ERROR" and Color3.fromRGB(255, 96, 96) or Theme.Colors.Accent
        local textW = Services.TextService:GetTextSize(message, 16, Theme.Font, Vector2.new(math.huge, 22)).X
        local toastWidth = math.max(math.min(textW + 44, 420), 160)
        local toastHeight = 50
        local progressStart = Color3.fromRGB(70, 180, 255)
        local progressEnd = Color3.fromRGB(255, 80, 80)

        local wrapper = New("Frame", {
            BackgroundTransparency = 1,
            LayoutOrder = -toastId,
            Size = UDim2.fromOffset(toastWidth, toastHeight),
            Parent = UI.ToastRoot,
            ZIndex = 81,
        })

        local maskContainer = New("Frame", {
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Size = UDim2.new(0.98, 0, 1, 0),
            Parent = wrapper,
            ZIndex = 81,
        })
        AddCorner(maskContainer, Theme.Radius.Panel)

        local toast = New("Frame", {
            BackgroundColor3 = Theme.Colors.Window,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, 0, 0, 1),
            Size = UDim2.new(1, -2, 1, -2),
            Parent = maskContainer,
            ZIndex = 81,
        })
        AddCorner(toast, Theme.Radius.Panel)
        local stroke = AddStroke(toast, Color3.fromRGB(235, 235, 235))
        stroke.Transparency = 1

        local bar = New("Frame", {
            BackgroundColor3 = accent,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 4, 1, -12),
            Position = UDim2.fromOffset(8, 6),
            Parent = toast,
            ZIndex = 82,
        })
        AddCorner(bar, Theme.Radius.Pill)

        local title = Components.Label(toast, tostring(level or "INFO"), 13, accent, true)
        title.Position = UDim2.fromOffset(18, 4)
        title.Size = UDim2.fromOffset(74, 14)
        title.TextTruncate = Enum.TextTruncate.AtEnd
        title.TextTransparency = 1
        title.ZIndex = 82

        local text = Components.Label(toast, message, 16, Theme.Colors.Text, false)
        text.Position = UDim2.fromOffset(18, 18)
        text.Size = UDim2.new(1, -28, 0, 22)
        text.TextTruncate = Enum.TextTruncate.AtEnd
        text.TextTransparency = 1
        text.ZIndex = 82

        local progressBg = New("Frame", {
            BackgroundColor3 = Theme.Colors.StrokeStrong,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 18, 1, -8),
            Size = UDim2.new(1, -28, 0, 3),
            Parent = toast,
            ZIndex = 82,
        })
        AddCorner(progressBg, Theme.Radius.Pill)

        local progressClip = New("Frame", {
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = progressBg,
            ZIndex = 83,
        })
        AddCorner(progressClip, Theme.Radius.Pill)

        local progressBar = New("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = progressStart,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            Parent = progressClip,
            ZIndex = 84,
        })
        AddCorner(progressBar, Theme.Radius.Pill)

        Tween(toast, {
            BackgroundTransparency = 0,
            Position = UDim2.new(0, 1, 0, 1),
        }, 0.5)
        Tween(bar, { BackgroundTransparency = 0 }, 0.22)
        Tween(title, { TextTransparency = 0 }, 0.22)
        Tween(text, { TextTransparency = 0 }, 0.22)
        Tween(progressBg, { BackgroundTransparency = 0.35 }, 0.22)
        Tween(progressBar, { BackgroundTransparency = 0 }, 0.22)
        Tween(stroke, { Transparency = 0.38 }, 0.22)
        Tween(progressBar, {
            Size = UDim2.new(0, 0, 1, 0),
        }, Theme.Animation.ToastDuration, Enum.EasingStyle.Linear)
        task.delay(math.max(Theme.Animation.ToastDuration - 0.5, 0), function()
            if progressBar and progressBar.Parent then
                Tween(progressBar, { BackgroundColor3 = progressEnd }, 0.5)
            end
        end)

        task.delay(Theme.Animation.ToastDuration, function()
            if not wrapper or not wrapper.Parent or not toast or not toast.Parent then
                return
            end

            for _, child in ipairs(toast:GetDescendants()) do
                if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                    Tween(child, {
                        TextTransparency = 1,
                        BackgroundTransparency = 1,
                    }, Theme.Animation.Slow)
                elseif child:IsA("Frame") then
                    Tween(child, { BackgroundTransparency = 1 }, Theme.Animation.Slow)
                elseif child:IsA("UIStroke") then
                    Tween(child, { Transparency = 1 }, Theme.Animation.Slow)
                end
            end

            Tween(toast, {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 1.5, 0),
            }, 0.3)
            Tween(stroke, { Transparency = 1 }, 0.3)

            task.delay(0.3, function()
                if wrapper and wrapper.Parent then
                    wrapper:Destroy()
                end
            end)
        end)
    end

    function UI.ShowAnnouncement()
        if not UI.Main then return end
        if UI.Announcement and UI.Announcement.Parent then
            UI.Announcement:Destroy()
        end
        local WHITE = Color3.fromRGB(255, 255, 255)
        local STROKE_T = 0.8
        local mainSize = UI.Main.AbsoluteSize
        local width = math.max(math.floor(mainSize.X * 0.92), 550)
        local height = math.max(math.floor(mainSize.Y * 0.85), 350)
        local panel = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Theme.Colors.Window,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(width, height),
            Parent = UI.Main, ZIndex = 70,
        })
        UI.Announcement = panel
        AddCorner(panel, Theme.Radius.Window)
        do local s = AddStroke(panel, WHITE); s.Transparency = STROKE_T end -- ① 公告外边框
        local header = New("Frame", {
            BackgroundColor3 = Theme.Colors.PanelDeep,
            Position = UDim2.fromOffset(1, 1),
            Size = UDim2.new(1, -2, 0, 40),
            Parent = panel, ZIndex = 71,
        })
        AddCorner(header, Theme.Radius.Window)

        local title = New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.new(0.98, 0, 1.25, 0),
            Text = _G.BFH.AppConfig.AnnouncementTitle or "公告",
            TextColor3 = Theme.Colors.Text,
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            Font = Enum.Font.SourceSansBold,
            Parent = header, ZIndex = 72,
        })
        local close = Components.IconButton(header, "announcement.close", "X", "", function()
            if panel and panel.Parent then panel:Destroy() end
            if UI.Announcement == panel then UI.Announcement = nil end
        end)
        close.AnchorPoint = Vector2.new(1, 0.5)
        close.Position = UDim2.new(1, -8, 0.5, 0)
        close.Size = UDim2.fromOffset(28, 28)
        close.ZIndex = 72
        do local s = AddStroke(close, WHITE); s.Transparency = STROKE_T end -- ④ 关闭按钮
        local body = New("ScrollingFrame", {
            BackgroundColor3 = Theme.Colors.Background,
            Position = UDim2.fromOffset(12, 52),
            Size = UDim2.new(1, -24, 1, -64),
            CanvasSize = UDim2.fromOffset(0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Colors.StrokeStrong,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            Parent = panel, ZIndex = 71,
        })
        AddCorner(body, Theme.Radius.Panel)
        do local s = AddStroke(body, WHITE); s.Transparency = STROKE_T end -- ⑤ 内容区域外边框
        local text = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -30, 0, 0),
            Position = UDim2.fromOffset(14, 10),
            Text = _G.BFH.AppConfig.AnnouncementText or "",
            TextColor3 = Theme.Colors.TextMuted,
            TextSize = 15,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Top,
            Font = Theme.Font,
            Parent = body, ZIndex = 72,
        })
        local function updateCanvas()
            task.wait()
            if text and text.Parent then
                local h = Services.TextService:GetTextSize(text.Text, text.TextSize, text.Font, Vector2.new(text.AbsoluteSize.X, math.huge)).Y
                text.Size = UDim2.new(1, -30, 0, h)
                body.CanvasSize = UDim2.fromOffset(0, h + 24)
            end
        end
        task.spawn(updateCanvas)
        UI.Track(body:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateCanvas))
        UI.MakeDraggable(panel, header)
    end

    function UI.ShowCenterToast(text)
        if not UI.RootGui then return end
        text = text or "反馈脚本"

        local root = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0, -28),
            Size = UDim2.fromOffset(200, 28),
            Parent = UI.RootGui,
            ZIndex = 200,
        })
        root.Visible = false
        AddCorner(root, Theme.Radius.Panel)
        local stroke = AddStroke(root, Color3.fromRGB(255, 255, 255))
        stroke.Transparency = 0.8

        root.ClipsDescendants = false
        local label = Components.Label(root, text, 16, Color3.fromRGB(255, 255, 255), false)
        label.Size = UDim2.new(1, -8, 1, 0)
        label.Position = UDim2.fromOffset(4, 0)
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.ZIndex = 201

        -- slide down from off-screen
        root.Visible = true
        Tween(root, { BackgroundTransparency = 0, Position = UDim2.new(0.5, 0, 0, 16) }, 0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

        task.delay(5, function()
            if not root or not root.Parent then return end
            Tween(root, { BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0, -28) }, 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            task.delay(0.4, function()
                if root and root.Parent then root:Destroy() end
            end)
        end)
    end

    function UI.PositionTooltip(object)
        if not UI.Tooltip or not UI.RootGui then
            return
        end

        object = object or UI.TooltipSource
        if not object then
            return
        end

        local rootPosition = UI.RootGui.AbsolutePosition
        local objectPosition = object.AbsolutePosition
        local objectSize = object.AbsoluteSize
        local gap = 8
        local x = objectPosition.X - rootPosition.X + objectSize.X + gap
        local y = objectPosition.Y - rootPosition.Y + objectSize.Y + gap

        UI.Tooltip.Position = UDim2.fromOffset(math.floor(x + 0.5), math.floor(y + 0.5))
    end

    function UI.ShowTooltip(text, object)
        if not UI.RootGui then
            return
        end

        UI.TooltipToken += 1
        local token = UI.TooltipToken
        UI.TooltipSource = object
        UI.HideTooltip(nil, true)

        local function createTooltip()
            if token ~= UI.TooltipToken or UI.TooltipSource ~= object or not UI.RootGui then
                return
            end

            local textSize = Services.TextService:GetTextSize(tostring(text), 12, Theme.Font, Vector2.new(300, 120))
            local width = math.clamp(textSize.X + 22, 180, 320)
            local height = math.clamp(textSize.Y + 18, 38, 104)

            local tooltip = New("Frame", {
                BackgroundColor3 = Theme.Colors.PanelDeep,
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(width, math.max(1, height - 6)),
                Parent = UI.RootGui,
                ZIndex = 120,
            })
            UI.TooltipScale = New("UIScale", {
                Scale = _G.BFH.State.DpiScale,
                Parent = tooltip,
            })
            AddCorner(tooltip, Theme.Radius.Control)
            AddStroke(tooltip, Theme.Colors.StrokeStrong)
            AddPadding(tooltip, 10, 10, 7, 7)

            local label = Components.Label(tooltip, text, 12, Theme.Colors.TextMuted, false)
            label.Size = UDim2.fromScale(1, 1)
            label.TextWrapped = true
            label.TextYAlignment = Enum.TextYAlignment.Top
            label.TextTransparency = 1
            label.ZIndex = 121

            UI.Tooltip = tooltip
            UI.PositionTooltip(object)

            Tween(tooltip, {
                BackgroundTransparency = 0,
                Size = UDim2.fromOffset(width, height),
            }, Theme.Animation.Fast, Theme.Animation.EmphasisStyle)
            Tween(label, { TextTransparency = 0 }, Theme.Animation.Fast)
            local stroke = tooltip:FindFirstChildOfClass("UIStroke")
            if stroke then
                stroke.Transparency = 1
                Tween(stroke, { Transparency = 0 }, Theme.Animation.Fast)
            end
        end

        if Theme.Animation.TooltipDelay > 0 then
            task.delay(Theme.Animation.TooltipDelay, createTooltip)
        else
            createTooltip()
        end
    end

    function UI.HideTooltip(source, keepToken)
        if source and UI.TooltipSource and source ~= UI.TooltipSource then
            return
        end

        if not keepToken then
            UI.TooltipToken += 1
            UI.TooltipSource = nil
        end

        if UI.Tooltip then
            local tooltip = UI.Tooltip
            UI.Tooltip = nil
            local stroke = tooltip:FindFirstChildOfClass("UIStroke")
            for _, child in ipairs(tooltip:GetDescendants()) do
                if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                    Tween(child, { TextTransparency = 1 }, Theme.Animation.Fast)
                end
            end
            if stroke then
                Tween(stroke, { Transparency = 1 }, Theme.Animation.Fast)
            end
            Tween(tooltip, { BackgroundTransparency = 1 }, Theme.Animation.Fast)
            task.delay(Theme.Animation.Fast + 0.03, function()
                if tooltip and tooltip.Parent then
                    tooltip:Destroy()
                end
            end)
        end
    end

    function UI.Confirm(title, text, onConfirm)
        if not UI.RootGui then
            return
        end

        if not _G.BFH.State.ConfirmEnabled then
            if onConfirm then
                onConfirm()
            end
            return
        end

        if UI.ModalRoot then
            UI.ModalRoot:Destroy()
        end

        local overlay = New("TextButton", {
            BackgroundColor3 = Theme.Colors.Overlay,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            Parent = UI.Main,
            ZIndex = 100,
        })
        UI.ModalRoot = overlay
        AddCorner(overlay, Theme.Radius.Window)

        local modal = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Theme.Colors.Window,
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(447, 205),
            Parent = overlay,
            ZIndex = 101,
        })
        UI.ModalScale = New("UIScale", {
            Scale = _G.BFH.State.DpiScale,
            Parent = modal,
        })
        AddCorner(modal, Theme.Radius.Window)
        local modalStroke = AddStroke(modal, Theme.Colors.StrokeStrong)
        modalStroke.Transparency = 1

        local titleLabel = Components.Label(modal, title or "确认操作", 22, Theme.Colors.Text, true)
        titleLabel.Position = UDim2.fromOffset(0, 20)
        titleLabel.Size = UDim2.new(1, 0, 0, 32)
        titleLabel.TextXAlignment = Enum.TextXAlignment.Center
        titleLabel.TextTransparency = 1
        titleLabel.ZIndex = 102

        local desc = Components.Label(modal, text or "确认执行？", 18, Theme.Colors.TextMuted, false)
        desc.TextXAlignment = Enum.TextXAlignment.Center
        desc.Position = UDim2.fromOffset(24, 56)
        desc.Size = UDim2.new(1, -48, 0, 64)
        desc.TextWrapped = true
        desc.TextTransparency = 1
        desc.ZIndex = 102

        local cancel = New("TextButton", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Theme.Colors.Control,
            Position = UDim2.new(0.5, -65, 1, -48),
            Size = UDim2.fromOffset(90, 36),
            Text = "取消",
            TextSize = 16,
            TextColor3 = Theme.Colors.TextMuted,
            TextTransparency = 1,
            Parent = modal,
            ZIndex = 102,
        })
        AddCorner(cancel, Theme.Radius.Control)
        AddStroke(cancel)
        Components.Interaction(cancel, Theme.Colors.Control, Theme.Colors.ControlHover, Theme.Colors.AccentDim)

        local confirm = New("TextButton", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Theme.Colors.AccentDim,
            Position = UDim2.new(0.5, 65, 1, -48),
            Size = UDim2.fromOffset(90, 36),
            Text = "确认",
            TextSize = 16,
            TextColor3 = Theme.Colors.Text,
            TextTransparency = 1,
            Parent = modal,
            ZIndex = 102,
        })
        AddCorner(confirm, Theme.Radius.Control)
        AddStroke(confirm, Theme.Colors.AccentSoft)
        Components.Interaction(confirm, Theme.Colors.AccentDim, Theme.Colors.AccentSoft, Theme.Colors.Accent)

        local function close()
            local root = UI.ModalRoot
            if not root then
                return
            end
            UI.ModalRoot = nil
            Tween(overlay, { BackgroundTransparency = 1 }, Theme.Animation.Fast)
            Tween(modal, {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(447, 205),
            }, Theme.Animation.Fast)
            Tween(modalStroke, { Transparency = 1 }, Theme.Animation.Fast)
            Tween(titleLabel, { TextTransparency = 1 }, Theme.Animation.Fast)
            Tween(desc, { TextTransparency = 1 }, Theme.Animation.Fast)
            Tween(cancel, { TextTransparency = 1, BackgroundTransparency = 1 }, Theme.Animation.Fast)
            Tween(confirm, { TextTransparency = 1, BackgroundTransparency = 1 }, Theme.Animation.Fast)
            task.delay(Theme.Animation.Fast + 0.03, function()
                if root and root.Parent then
                    root:Destroy()
                end
            end)
        end

        cancel.Activated:Connect(close)
        overlay.Activated:Connect(close)
        confirm.Activated:Connect(function()
            close()
            if onConfirm then
                onConfirm()
            end
        end)

        Tween(overlay, { BackgroundTransparency = 0.45 }, Theme.Animation.Normal)
        Tween(modal, {
            BackgroundTransparency = 0,
            Size = UDim2.fromOffset(468, 221),
        }, Theme.Animation.Normal, Theme.Animation.EmphasisStyle)
        Tween(modalStroke, { Transparency = 0 }, Theme.Animation.Normal)
        Tween(titleLabel, { TextTransparency = 0 }, Theme.Animation.Normal)
        Tween(desc, { TextTransparency = 0 }, Theme.Animation.Normal)
        Tween(cancel, { TextTransparency = 0 }, Theme.Animation.Normal)
        Tween(confirm, { TextTransparency = 0 }, Theme.Animation.Normal)
    end

    function UI.MakeDraggable(frame, handle)
        local dragging = false
        local startMouse = nil
        local startPosition = nil
        local moved = false
        local dragInputType = nil

        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if frame == UI.ShowButton and UI.ShowButtonDragLock then return end
                dragging = true
                moved = false
                startMouse = input.Position
                startPosition = frame.Position
                dragInputType = input.UserInputType
            end
        end)

        UI.Track(Services.UserInputService.InputChanged:Connect(function(input)
            if not dragging then
                return
            end

            if dragInputType == Enum.UserInputType.Touch then
                if input.UserInputType ~= Enum.UserInputType.Touch then
                    return
                end
            elseif input.UserInputType ~= Enum.UserInputType.MouseMovement then
                return
            end

            local delta = input.Position - startMouse
            if math.abs(delta.X) > 8 or math.abs(delta.Y) > 8 then
                moved = true
                if frame == UI.ShowButton then
                    UI.ShowButtonDragged = true
                end
            end
            local nextPosition = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
            frame.Position = ClampFrameToScreen(frame, nextPosition)
        end))

        UI.Track(Services.UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if frame == UI.ShowButton and not moved and startMouse then
                    local totalDelta = input.Position - startMouse
                    if math.abs(totalDelta.X) > 8 or math.abs(totalDelta.Y) > 8 then
                        moved = true
                        UI.ShowButtonDragged = true
                    end
                end
                if frame == UI.ShowButton and moved then
                    task.delay(0.08, function()
                        UI.ShowButtonDragged = false
                    end)
                end
                dragging = false
                dragInputType = nil
            end
        end))
    end

    function UI.BuildSidebar(parent)
        UI.Sidebar = New("ScrollingFrame", {
            BackgroundColor3 = Theme.Colors.Window,
            Position = UDim2.fromOffset(1, 42),
            Size = UDim2.new(0, 149, 1, -43),
            CanvasSize = UDim2.fromOffset(0, 0),
            ScrollBarThickness = 3,
            Parent = parent,
        })
        AddCorner(UI.Sidebar, Theme.Radius.Window)

        local layout = New("UIListLayout", {
            Padding = UDim.new(0, 7),
            Parent = UI.Sidebar,
        })
        SetScrollCanvas(UI.Sidebar, layout, 28, "window")

        for _, page in ipairs(_G.BFH.Pages.List) do
            local button = New("TextButton", {
                BackgroundColor3 = Theme.Colors.Window,
                Size = UDim2.new(1, 0, 0, 36),
                Text = "",
                Parent = UI.Sidebar,
            })
            AddCorner(button, Theme.Radius.Panel)
            Components.Interaction(
                button,
                function()
                    return page.id == _G.BFH.State.CurrentPage and Theme.Colors.AccentDim or Theme.Colors.Window
                end,
                function()
                    return page.id == _G.BFH.State.CurrentPage and Theme.Colors.AccentDim or Theme.Colors.Control
                end,
                Theme.Colors.AccentDim
            )
            local sideScale = New("UIScale", { Scale = 1, Parent = button })

            local name = Components.Label(button, page.title, 13, Theme.Colors.TextMuted, true)
            name.Name = "PageName"
            name.Position = UDim2.fromOffset(0, 0)
            name.Size = UDim2.new(1, 0, 1, 0)
            name.TextXAlignment = Enum.TextXAlignment.Center
            name.Visible = not UI.SidebarCollapsed

            button.MouseButton1Click:Connect(function()
                Tween(sideScale, { Scale = 0.95 }, Theme.Animation.Press)
                task.delay(Theme.Animation.Press + 0.04, function()
                    Tween(sideScale, { Scale = 1 }, Theme.Animation.Fast)
                end)
                UI.SetPage(page.id)
                _G.BFH.State:AddLog("UI", "切换页面: " .. page.title, "sidebar." .. page.id)
            end)

            UI.SidebarButtons[page.id] = button
        end

        return layout
    end

    function UI.UpdateBtnPos()
        if not UI.ShowButton then return end
        if _G.BFH.State.Toggles["settings.toggle.custom_btn_pos"] then
            local x = _G.BFH.State.Sliders["settings.ui.btn_pos_x"] or 90
            local y = _G.BFH.State.Sliders["settings.ui.btn_pos_y"] or 50
            UI.ShowButton.Position = UDim2.new(1, -x, 0, y)
            UI.ShowButton.Visible = true
            UI.ShowButtonDragLock = true
        else
            if UI.Main and UI.Main.Visible then
                UI.ShowButton.Visible = false
            end
            UI.ShowButton.Position = UDim2.new(1, -90, 0, 50)
            UI.ShowButtonDragLock = false
        end
    end
    
    function UI.UpdateBtnSize()
        if not UI.ShowButton then return end
        local sz = _G.BFH.State.Sliders["settings.ui.btn_size"] or 80
        UI.ShowButton.Size = UDim2.fromOffset(sz, math.floor(sz * 0.5))
    end

    function UI.Build()
        UI.Destroy()
        _G.BFH.RegisterPageKeys()

        local root = New("ScreenGui", {
            Name = _G.BFH.AppConfig.GuiName,
            ResetOnSpawn = false,
            IgnoreGuiInset = true,
            Parent = UI.GetScreenParent(),
        })
        UI.RootGui = root
        UI.BuildToastRoot(root)

        local initialWindowSize = UI.GetBoundedWindowSize()
        local main = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Theme.Colors.Window,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(initialWindowSize.X, initialWindowSize.Y),
            Parent = root,
        })
        AddCorner(main, Theme.Radius.Window)
        AddStroke(main, Theme.Colors.StrokeStrong)
        main.ClipsDescendants = true
        UI.Main = main

        UI.Scale = New("UIScale", {
            Scale = _G.BFH.State.DpiScale,
            Parent = main,
        })

        local topbar = New("Frame", {
            BackgroundColor3 = Theme.Colors.PanelDeep,
            Position = UDim2.fromOffset(1, 1),
            Size = UDim2.new(1, -2, 0, 41),
            Parent = main,
        })
        AddCorner(topbar, Theme.Radius.Window)

        local logo = New("ImageLabel", {
            BackgroundTransparency = 1,
            Image = "rbxassetid://104393405110206",
            ScaleType = Enum.ScaleType.Fit,
            Position = UDim2.fromOffset(10, 8),
            Size = UDim2.fromOffset(125, 26),
            Parent = topbar,
        })

        local topRight = New("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -10, 0.5, 0),
            Size = UDim2.new(1, -150, 0, 30),
            Parent = topbar,
        })

        -- Top-right controls: buttons anchored to right edge
        local topRightLayout = {
            MarqueePosition = UDim2.fromOffset(0, 0),
            MarqueeSize = UDim2.new(1, -75, 0, 30),
            MinimizePosition = UDim2.new(1, -70, 0, -2.5),
            MinimizeSize = UDim2.fromOffset(35, 35),
            ClosePosition = UDim2.new(1, -30, 0, -2.5),
            CloseSize = UDim2.fromOffset(35, 35),
        }

        local closeButton = Components.IconButton(topRight, "window.close", "X", "关闭窗口", function()
            UI.Confirm("确认退出", "确定要关闭此脚本吗？", function()
                _G.BFH.State:AddLog("UI", "关闭窗口", "window.close")
                UI.Destroy()
            end)
        end)
        closeButton.Position = topRightLayout.ClosePosition
        closeButton.Size = topRightLayout.CloseSize

        local minimizeButton = Components.IconButton(topRight, "window.minimize", "-", "最小化窗口", function()
            UI.SetVisible(false)
        end)
        minimizeButton.Position = topRightLayout.MinimizePosition
        minimizeButton.Size = topRightLayout.MinimizeSize

        local marquee = Components.Marquee(topRight, _G.BFH.AppConfig.MarqueeText)
        marquee.Position = topRightLayout.MarqueePosition
        marquee.Size = topRightLayout.MarqueeSize

        UI.BuildSidebar(main)

        UI.Content = New("ScrollingFrame", {
            BackgroundColor3 = Theme.Colors.Background,
            Position = UDim2.fromOffset(150, 42),
            Size = UDim2.new(1, -150, 1, -42),
            CanvasSize = UDim2.fromOffset(0, 0),
            ScrollBarThickness = 3,
            Parent = main,
        })


        UI.ShowButton = New("ImageButton", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Position = UDim2.new(1, -90, 0, 50),
            Size = UDim2.fromOffset(80, 40),
            Image = "rbxassetid://106447267002508",
            BackgroundTransparency = 1,
            ZIndex = 999,
            Visible = false,
            Parent = root,
        })
        AddCorner(UI.ShowButton, 8)
        UI.ShowButtonStroke = AddStroke(UI.ShowButton, Color3.fromRGB(255, 255, 255))
        UI.ShowScale = New("UIScale", {
            Scale = _G.BFH.State.DpiScale,
            Parent = UI.ShowButton,
        })

        UI._showDragStart = nil
        UI.ShowButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                UI._showDragStart = input.Position
            end
        end)
        UI.ShowButton.InputEnded:Connect(function(input)
            if UI._showDragStart and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                local dx = math.abs(input.Position.X - UI._showDragStart.X)
                local dy = math.abs(input.Position.Y - UI._showDragStart.Y)
                if dx > 8 or dy > 8 then
                    UI.ShowButton.Active = false
                    task.delay(0.15, function() UI.ShowButton.Active = true end)
                end
                UI._showDragStart = nil
            end
        end)
        UI.ShowButton.Activated:Connect(function()
            Tween(UI.ShowButton, { Size = UDim2.fromOffset(72, 36) }, Theme.Animation.Press)
            task.delay(Theme.Animation.Press + 0.04, function()
                Tween(UI.ShowButton, { Size = UDim2.fromOffset(80, 40) }, Theme.Animation.Fast)
            end)
            UI.SetVisible(true)
        end)

        UI.MakeDraggable(main, topbar)
        UI.MakeDraggable(UI.ShowButton, UI.ShowButton)
        UI.Track(Services.UserInputService.InputBegan:Connect(function(input, processed)
            if processed or input.UserInputType ~= Enum.UserInputType.Keyboard then
                return
            end

            local toggleKeyName = _G.BFH.State.Keybinds["settings.keybind.toggle_ui"] or "RightShift"
            if input.KeyCode.Name == toggleKeyName then
                UI.SetVisible(not (UI.Main and UI.Main.Visible))
            end
        end))
        UI.Track(root:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            UI.ApplyWindowBounds()
        end))

        UI.SetPage(_G.BFH.AppConfig.DefaultPage)
        task.defer(function()
            UI.ShowAnnouncement()
        end)
        UI.UpdateBtnPos()
        _G.BFH.State:AddLog("UI", "新脚本已启动", "app.start")
        UI.ShowCenterToast("新脚本已启动")
    end

_G.BFH.Theme = Theme
_G.BFH.Components = Components
_G.BFH.Services = Services
_G.BFH.UI = UI
_G.BFH.Tween = Tween
_G.BFH.New = New
_G.BFH.AddCorner = AddCorner
_G.BFH.AddStroke = AddStroke
_G.BFH.AddPadding = AddPadding
_G.BFH.SetScrollCanvas = SetScrollCanvas
_G.BFH.UpdateScrollCanvas = UpdateScrollCanvas
_G.BFH.ContainsText = ContainsText
_G.BFH.DisconnectConnections = DisconnectConnections
_G.BFH.RefreshContentCanvas = RefreshContentCanvas
_G.BFH.ShallowCopy = ShallowCopy
_G.BFH.ClampFrameToScreen = ClampFrameToScreen
end