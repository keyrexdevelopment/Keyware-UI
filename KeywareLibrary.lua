--[[
    ═════════════════════════════════════════════════════════════════
    ██╗  ██╗███████╗██╗   ██╗██╗    ██╗ █████╗ ██████╗ ███████╗
    ██║ ██╔╝██╔════╝╚██╗ ██╔╝██║    ██║██╔══██╗██╔══██╗██╔════╝
    █████╔╝ █████╗   ╚████╔╝ ██║ █╗ ██║███████║██████╔╝█████╗  
    ██╔═██╗ ██╔══╝    ╚██╔╝  ██║███╗██║██╔══██║██╔══██╗██╔══╝  
    ██║  ██╗███████╗   ██║   ╚███╔███╔╝██║  ██║██║  ██║███████╗
    ╚═╝  ╚═╝╚══════╝   ╚═╝    ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝
    KEYWARE UI LIBRARY • STANDALONE MODULE
    High-Performance Modern Luau UI Framework
    ═════════════════════════════════════════════════════════════════
    Documentation & Quick Start:

    1. Load the Library:
       local Keyware = loadstring(game:HttpGet("https://raw.githubusercontent.com/keyrexdevelopment/Keyware-UI/main/KeywareLibrary.lua"))()
       -- or from local executor workspace:
       -- local Keyware = loadstring(readfile("KEYWARE/KeywareLibrary.lua"))()

    2. Create a Window:
       local Window = Keyware:CreateWindow({
           Title = "KEYWARE",
           Subtitle = "Combat Edition",
           Keybind = Enum.KeyCode.RightControl,
           StatusHUD = true,
           UserProfile = {
               Name = "Player1",
               Sub = "Lifetime",
               UserId = 1
           }
       })

    3. Notifications:
       Window:Notify({
           Title = "WELCOME",
           Message = "Script successfully loaded!",
           Duration = 3.5,
           Tag = "INFO"
       })

    4. Add Tabs & Categories:
       Window:CreateCategory("MAIN")
       local Tab1 = Window:CreateTab("Combat")
       local Card1 = Tab1:CreateCard("Aimbot", 1) -- Column 1 or 2

    5. Add Interactive Elements:
       local Toggle = Card1:AddToggle("Enable", false, function(v) print("Toggle:", v) end)
       local Slider = Card1:AddSlider("Smoothing", 1, 20, 5, 1, "", function(v) print("Slider:", v) end)
       local Dropdown = Card1:AddDropdown("Target", {"Head", "Torso"}, "Head", function(v) print("DD:", v) end)
       local Keybind = Card1:AddKeybind("Aim Key", Enum.KeyCode.E, function(k) print("Key:", k.Name) end)
       local Textbox = Card1:AddTextbox("Custom Name", "Type here...", "", function(t) print("Text:", t) end)
       local ColorPick = Card1:AddColorPicker("Accent Color", Color3.fromRGB(255, 50, 50), function(c) print("Color:", c) end)
       local Button = Card1:AddButton("Execute", "Click Me", function() print("Clicked!") end)
       Card1:AddLabel("Informational status label")
       Card1:AddParagraph("Notice", "This is a descriptive paragraph block.")
       Card1:AddDivider()
    ═════════════════════════════════════════════════════════════════
--]]

local Keyware = {}
Keyware.__index = Keyware
Keyware.Version = "2.0.0"

local ColorMap = {
    ["Keyware Red"] = Color3.fromRGB(255, 50, 50),
    ["Crimson Red"] = Color3.fromRGB(200, 20, 50),
    ["Blood Orange"] = Color3.fromRGB(255, 80, 20),
    ["Sunset Orange"] = Color3.fromRGB(255, 120, 30),
    ["Golden Yellow"] = Color3.fromRGB(255, 215, 0),
    ["Toxic Lime"] = Color3.fromRGB(130, 255, 0),
    ["Acid Green"] = Color3.fromRGB(65, 255, 90),
    ["Gamesense Green"] = Color3.fromRGB(150, 200, 60),
    ["Emerald Green"] = Color3.fromRGB(0, 200, 115),
    ["Mint Green"] = Color3.fromRGB(120, 255, 200),
    ["Cyberpunk Cyan"] = Color3.fromRGB(0, 225, 255),
    ["Deep Sky Blue"] = Color3.fromRGB(0, 170, 255),
    ["Skeet Blue"] = Color3.fromRGB(80, 140, 255),
    ["Lavender"] = Color3.fromRGB(190, 150, 255),
    ["Electric Purple"] = Color3.fromRGB(175, 75, 255),
    ["Hot Violet"] = Color3.fromRGB(210, 40, 230),
    ["Neon Pink"] = Color3.fromRGB(255, 60, 160),
    ["Pastel Coral"] = Color3.fromRGB(255, 140, 140),
    ["Ghost White"] = Color3.fromRGB(250, 250, 250),
    ["Pure White"] = Color3.fromRGB(255, 255, 255),
    ["Stealth Gray"] = Color3.fromRGB(140, 140, 140),
    ["Dark Slate"] = Color3.fromRGB(75, 85, 95)
}
_G.KeywareColorMap = ColorMap


local Services = {
    Players = game:GetService("Players"),
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    RunService = game:GetService("RunService"),
    CoreGui = game:GetService("CoreGui")
}

local LocalPlayer = Services.Players.LocalPlayer

local function getSafeGuiParent()
    if typeof(gethui) == "function" then
        local s, h = pcall(gethui)
        if s and h and h ~= Services.CoreGui then
            local canAccess = false
            pcall(function()
                local t = Instance.new("Frame")
                t.Parent = h
                t:Destroy()
                canAccess = true
            end)
            if canAccess then return h end
        end
    end

    if typeof(get_hidden_gui) == "function" then
        local s, h = pcall(get_hidden_gui)
        if s and h and h ~= Services.CoreGui then return h end
    end

    local pGui = LocalPlayer and (LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:FindFirstChild("PlayerGui"))
    if pGui then return pGui end

    return LocalPlayer and LocalPlayer:WaitForChild("PlayerGui", 5) or Services.CoreGui
end

function Keyware:CreateWindow(config)
    config = config or {}
    local Title = config.Title or "KEYWARE"
    local Subtitle = config.Subtitle or "Global (Default)"
    local DefaultToggleKey = config.Keybind or Enum.KeyCode.RightControl
    local HasStatusHUD = (config.StatusHUD ~= false)
    local UserProfileData = config.UserProfile or {
        Name = LocalPlayer and LocalPlayer.DisplayName or "User",
        Sub = "Till: Lifetime",
        UserId = LocalPlayer and LocalPlayer.UserId or 1
    }

    -- Cleanup existing
    pcall(function()
        local parent = getSafeGuiParent()
        if parent then
            for _, c in ipairs(parent:GetChildren()) do
                if c:IsA("ScreenGui") and (c.Name == "KeywareUI" or c.Name:find("Keyware")) then
                    c:Destroy()
                end
            end
        end
    end)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KeywareUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 2147483647
    ScreenGui.IgnoreGuiInset = true

    pcall(function()
        if typeof(protectgui) == "function" then
            protectgui(ScreenGui)
        elseif syn and typeof(syn.protect_gui) == "function" then
            syn.protect_gui(ScreenGui)
        end
    end)

    ScreenGui.Parent = getSafeGuiParent()

    local Window = {
        ScreenGui = ScreenGui,
        Connections = {},
        Pages = {},
        ActiveTab = nil,
        ActiveDropdown = nil,
        Visible = true,
        IsMinimized = false,
        ToggleKey = DefaultToggleKey,
        ListeningForToggleKey = false,
        HUD = nil
    }

    local NotificationContainer = Instance.new("Frame")
    NotificationContainer.Name = "NotificationContainer"
    NotificationContainer.Size = UDim2.new(0, 270, 1, -50)
    NotificationContainer.Position = UDim2.new(1, -286, 0, 24)
    NotificationContainer.BackgroundTransparency = 1
    NotificationContainer.BorderSizePixel = 0
    NotificationContainer.Parent = ScreenGui

    local notifLayout = Instance.new("UIListLayout")
    notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    notifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    notifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    notifLayout.Padding = UDim.new(0, 8)
    notifLayout.Parent = NotificationContainer

    local notifCount = 0
    function Window:Notify(data)
        if type(data) == "string" then
            data = { Title = "NOTIFICATION", Message = data, Duration = 3.0 }
        end
        local title = data.Title or "NOTIFICATION"
        local message = data.Message or ""
        local duration = data.Duration or 3.2
        local tag = data.Tag or ""

        notifCount = notifCount + 1
        local order = notifCount

        local card = Instance.new("Frame")
        card.Name = "Notif_" .. order
        card.Size = UDim2.new(1, 0, 0, 54)
        card.Position = UDim2.new(1, 40, 0, 0)
        card.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        card.BackgroundTransparency = 1
        card.BorderSizePixel = 0
        card.ClipsDescendants = true
        card.LayoutOrder = order
        card.Parent = NotificationContainer

        local cardCorner = Instance.new("UICorner")
        cardCorner.CornerRadius = UDim.new(0, 5)
        cardCorner.Parent = card

        local cardStroke = Instance.new("UIStroke")
        cardStroke.Color = Color3.fromRGB(34, 34, 34)
        cardStroke.Transparency = 1
        cardStroke.Thickness = 1
        cardStroke.Parent = card

        local accent = Instance.new("Frame")
        accent.Size = UDim2.new(0, 3, 1, -2)
        accent.Position = UDim2.new(0, 0, 0, 0)
        accent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        accent.BackgroundTransparency = 1
        accent.BorderSizePixel = 0
        accent.Parent = card

        if tag and tag ~= "" then
            local tagBadge = Instance.new("TextLabel")
            tagBadge.Size = UDim2.new(0, 50, 0, 14)
            tagBadge.Position = UDim2.new(1, -56, 0, 9)
            tagBadge.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            tagBadge.BackgroundTransparency = 1
            tagBadge.Font = Enum.Font.GothamBold
            tagBadge.Text = tag
            tagBadge.TextColor3 = Color3.fromRGB(180, 180, 180)
            tagBadge.TextSize = 8.5
            tagBadge.TextTransparency = 1
            tagBadge.Parent = card

            local tbCorner = Instance.new("UICorner")
            tbCorner.CornerRadius = UDim.new(0, 3)
            tbCorner.Parent = tagBadge

            local tbStroke = Instance.new("UIStroke")
            tbStroke.Color = Color3.fromRGB(38, 38, 38)
            tbStroke.Transparency = 1
            tbStroke.Thickness = 1
            tbStroke.Parent = tagBadge
        end

        local tLabel = Instance.new("TextLabel")
        tLabel.Size = UDim2.new(1, -64, 0, 15)
        tLabel.Position = UDim2.new(0, 12, 0, 8)
        tLabel.BackgroundTransparency = 1
        tLabel.Font = Enum.Font.GothamBold
        tLabel.Text = string.upper(title)
        tLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        tLabel.TextSize = 10.5
        tLabel.TextXAlignment = Enum.TextXAlignment.Left
        tLabel.TextTransparency = 1
        tLabel.Parent = card

        local mLabel = Instance.new("TextLabel")
        mLabel.Size = UDim2.new(1, -20, 0, 20)
        mLabel.Position = UDim2.new(0, 12, 0, 24)
        mLabel.BackgroundTransparency = 1
        mLabel.Font = Enum.Font.GothamMedium
        mLabel.Text = message
        mLabel.TextColor3 = Color3.fromRGB(165, 165, 165)
        mLabel.TextSize = 10
        mLabel.TextWrapped = true
        mLabel.TextXAlignment = Enum.TextXAlignment.Left
        mLabel.TextTransparency = 1
        mLabel.Parent = card

        local pTrack = Instance.new("Frame")
        pTrack.Size = UDim2.new(1, 0, 0, 2)
        pTrack.Position = UDim2.new(0, 0, 1, -2)
        pTrack.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
        pTrack.BackgroundTransparency = 1
        pTrack.BorderSizePixel = 0
        pTrack.Parent = card

        local pFill = Instance.new("Frame")
        pFill.Size = UDim2.new(1, 0, 1, 0)
        pFill.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
        pFill.BackgroundTransparency = 1
        pFill.BorderSizePixel = 0
        pFill.Parent = pTrack

        Services.TweenService:Create(card, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 0
        }):Play()
        Services.TweenService:Create(cardStroke, TweenInfo.new(0.24), {Transparency = 0}):Play()
        Services.TweenService:Create(accent, TweenInfo.new(0.24), {BackgroundTransparency = 0}):Play()
        Services.TweenService:Create(tLabel, TweenInfo.new(0.24), {TextTransparency = 0}):Play()
        Services.TweenService:Create(mLabel, TweenInfo.new(0.24), {TextTransparency = 0}):Play()
        Services.TweenService:Create(pTrack, TweenInfo.new(0.24), {BackgroundTransparency = 0}):Play()
        Services.TweenService:Create(pFill, TweenInfo.new(0.24), {BackgroundTransparency = 0}):Play()

        local shrinkTween = Services.TweenService:Create(pFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            Size = UDim2.new(0, 0, 1, 0)
        })
        shrinkTween:Play()

        task.delay(duration, function()
            if card and card.Parent then
                local exitTween = Services.TweenService:Create(card, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Position = UDim2.new(1, 40, 0, 0),
                    BackgroundTransparency = 1
                })
                Services.TweenService:Create(cardStroke, TweenInfo.new(0.22), {Transparency = 1}):Play()
                Services.TweenService:Create(accent, TweenInfo.new(0.22), {BackgroundTransparency = 1}):Play()
                Services.TweenService:Create(tLabel, TweenInfo.new(0.22), {TextTransparency = 1}):Play()
                Services.TweenService:Create(mLabel, TweenInfo.new(0.22), {TextTransparency = 1}):Play()
                Services.TweenService:Create(pTrack, TweenInfo.new(0.22), {BackgroundTransparency = 1}):Play()
                Services.TweenService:Create(pFill, TweenInfo.new(0.22), {BackgroundTransparency = 1}):Play()
                exitTween:Play()
                exitTween.Completed:Connect(function()
                    if card then card:Destroy() end
                end)
            end
        end)
    end

    Keyware.Notify = function(_, d) Window:Notify(d) end

    if HasStatusHUD then
        local LeftStatusHUD = Instance.new("Frame")
        LeftStatusHUD.Name = "LeftStatusHUD"
        LeftStatusHUD.Size = UDim2.new(0, 230, 0, 114)
        LeftStatusHUD.Position = UDim2.new(0, 22, 0.45, -57)
        LeftStatusHUD.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
        LeftStatusHUD.BackgroundTransparency = 0.05
        LeftStatusHUD.BorderSizePixel = 0
        LeftStatusHUD.ClipsDescendants = true
        LeftStatusHUD.Parent = ScreenGui

        local hudCorner = Instance.new("UICorner")
        hudCorner.CornerRadius = UDim.new(0, 5)
        hudCorner.Parent = LeftStatusHUD

        local hudStroke = Instance.new("UIStroke")
        hudStroke.Color = Color3.fromRGB(30, 30, 30)
        hudStroke.Thickness = 1
        hudStroke.Parent = LeftStatusHUD

        local HudTopBar = Instance.new("Frame")
        HudTopBar.Name = "HudTopBar"
        HudTopBar.Size = UDim2.new(1, 0, 0, 24)
        HudTopBar.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
        HudTopBar.BorderSizePixel = 0
        HudTopBar.Parent = LeftStatusHUD

        local hudTopBottomLine = Instance.new("Frame")
        hudTopBottomLine.Size = UDim2.new(1, 0, 0, 1)
        hudTopBottomLine.Position = UDim2.new(0, 0, 1, -1)
        hudTopBottomLine.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
        hudTopBottomLine.BorderSizePixel = 0
        hudTopBottomLine.Parent = HudTopBar

        local HudBrandLabel = Instance.new("TextLabel")
        HudBrandLabel.Size = UDim2.new(0, 120, 1, 0)
        HudBrandLabel.Position = UDim2.new(0, 10, 0, 0)
        HudBrandLabel.BackgroundTransparency = 1
        HudBrandLabel.Font = Enum.Font.GothamBold
        HudBrandLabel.Text = Title .. " • STATUS"
        HudBrandLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        HudBrandLabel.TextSize = 10
        HudBrandLabel.TextXAlignment = Enum.TextXAlignment.Left
        HudBrandLabel.Parent = HudTopBar

        local HudModeBadge = Instance.new("TextLabel")
        HudModeBadge.Size = UDim2.new(0, 90, 1, 0)
        HudModeBadge.Position = UDim2.new(1, -98, 0, 0)
        HudModeBadge.BackgroundTransparency = 1
        HudModeBadge.Font = Enum.Font.GothamBold
        HudModeBadge.RichText = true
        HudModeBadge.Text = "<font color='#FFFFFF'>[ACTIVE]</font>"
        HudModeBadge.TextColor3 = Color3.fromRGB(240, 240, 240)
        HudModeBadge.TextSize = 9.5
        HudModeBadge.TextXAlignment = Enum.TextXAlignment.Right
        HudModeBadge.Parent = HudTopBar

        local HudAvatarFrame = Instance.new("Frame")
        HudAvatarFrame.Size = UDim2.new(0, 44, 0, 44)
        HudAvatarFrame.Position = UDim2.new(0, 10, 0, 31)
        HudAvatarFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
        HudAvatarFrame.BorderSizePixel = 0
        HudAvatarFrame.Parent = LeftStatusHUD

        local avCorner = Instance.new("UICorner")
        avCorner.CornerRadius = UDim.new(0, 4)
        avCorner.Parent = HudAvatarFrame

        local avStroke = Instance.new("UIStroke")
        avStroke.Color = Color3.fromRGB(36, 36, 36)
        avStroke.Thickness = 1
        avStroke.Parent = HudAvatarFrame

        local HudAvatar = Instance.new("ImageLabel")
        HudAvatar.Size = UDim2.new(1, 0, 1, 0)
        HudAvatar.BackgroundTransparency = 1
        HudAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(UserProfileData.UserId) .. "&w=150&h=150"
        HudAvatar.Parent = HudAvatarFrame

        local avImgCorner = Instance.new("UICorner")
        avImgCorner.CornerRadius = UDim.new(0, 4)
        avImgCorner.Parent = HudAvatar

        local HudInfoContainer = Instance.new("Frame")
        HudInfoContainer.Size = UDim2.new(1, -70, 0, 44)
        HudInfoContainer.Position = UDim2.new(0, 62, 0, 31)
        HudInfoContainer.BackgroundTransparency = 1
        HudInfoContainer.Parent = LeftStatusHUD

        local HudNameLabel = Instance.new("TextLabel")
        HudNameLabel.Size = UDim2.new(1, 0, 0, 15)
        HudNameLabel.BackgroundTransparency = 1
        HudNameLabel.Font = Enum.Font.GothamBold
        HudNameLabel.Text = UserProfileData.Name
        HudNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        HudNameLabel.TextSize = 11.5
        HudNameLabel.TextXAlignment = Enum.TextXAlignment.Left
        HudNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
        HudNameLabel.Parent = HudInfoContainer

        local HudRoleLabel = Instance.new("TextLabel")
        HudRoleLabel.Size = UDim2.new(1, 0, 0, 14)
        HudRoleLabel.Position = UDim2.new(0, 0, 0, 15)
        HudRoleLabel.BackgroundTransparency = 1
        HudRoleLabel.Font = Enum.Font.GothamMedium
        HudRoleLabel.RichText = true
        HudRoleLabel.Text = "STATUS: <font color='#4ADE80'>ACTIVE</font>"
        HudRoleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        HudRoleLabel.TextSize = 10
        HudRoleLabel.TextXAlignment = Enum.TextXAlignment.Left
        HudRoleLabel.Parent = HudInfoContainer

        local HudStatusLabel = Instance.new("TextLabel")
        HudStatusLabel.Size = UDim2.new(1, 0, 0, 14)
        HudStatusLabel.Position = UDim2.new(0, 0, 0, 29)
        HudStatusLabel.BackgroundTransparency = 1
        HudStatusLabel.Font = Enum.Font.GothamMedium
        HudStatusLabel.RichText = true
        HudStatusLabel.Text = "SYSTEM: <font color='#FFFFFF'><b>READY</b></font>"
        HudStatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        HudStatusLabel.TextSize = 10
        HudStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
        HudStatusLabel.Parent = HudInfoContainer

        local HudCdBg = Instance.new("Frame")
        HudCdBg.Size = UDim2.new(1, -20, 0, 4)
        HudCdBg.Position = UDim2.new(0, 10, 0, 82)
        HudCdBg.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        HudCdBg.BorderSizePixel = 0
        HudCdBg.Parent = LeftStatusHUD

        local cdBgCorner = Instance.new("UICorner")
        cdBgCorner.CornerRadius = UDim.new(1, 0)
        cdBgCorner.Parent = HudCdBg

        local HudCdBar = Instance.new("Frame")
        HudCdBar.Size = UDim2.new(1, 0, 1, 0)
        HudCdBar.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
        HudCdBar.BorderSizePixel = 0
        HudCdBar.Parent = HudCdBg

        local cdBarCorner = Instance.new("UICorner")
        cdBarCorner.CornerRadius = UDim.new(1, 0)
        cdBarCorner.Parent = HudCdBar

        local HudTagsLabel = Instance.new("TextLabel")
        HudTagsLabel.Size = UDim2.new(1, -20, 0, 16)
        HudTagsLabel.Position = UDim2.new(0, 10, 0, 91)
        HudTagsLabel.BackgroundTransparency = 1
        HudTagsLabel.Font = Enum.Font.GothamMedium
        HudTagsLabel.RichText = true
        HudTagsLabel.Text = "<font color='#00E5FF'>[CONNECTED]</font>  <font color='#888888'>[LOADED]</font>"
        HudTagsLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        HudTagsLabel.TextSize = 9
        HudTagsLabel.TextXAlignment = Enum.TextXAlignment.Left
        HudTagsLabel.Parent = LeftStatusHUD

        -- HUD Dragging
        local hudDragging, hudDragInput, hudDragStart, hudStartPos
        HudTopBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                hudDragging = true
                hudDragStart = input.Position
                hudStartPos = LeftStatusHUD.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        hudDragging = false
                    end
                end)
            end
        end)
        HudTopBar.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                hudDragInput = input
            end
        end)
        table.insert(Window.Connections, Services.UserInputService.InputChanged:Connect(function(input)
            if input == hudDragInput and hudDragging then
                local delta = input.Position - hudDragStart
                LeftStatusHUD.Position = UDim2.new(hudStartPos.X.Scale, hudStartPos.X.Offset + delta.X, hudStartPos.Y.Scale, hudStartPos.Y.Offset + delta.Y)
            end
        end))

        Window.HUD = {
            Frame = LeftStatusHUD,
            RoleLabel = HudRoleLabel,
            StatusLabel = HudStatusLabel,
            TagsLabel = HudTagsLabel,
            ProgressBar = HudCdBar,
            SetVisible = function(vis) LeftStatusHUD.Visible = vis end
        }
    end

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 700, 0, 470)
    MainFrame.Position = UDim2.new(0.5, -350, 0.5, -235)
    MainFrame.BackgroundColor3 = Color3.fromRGB(6, 6, 6)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 6)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(28, 28, 28)
    MainStroke.Thickness = 1
    MainStroke.Parent = MainFrame

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 165, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(4, 4, 4)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local SidebarBorder = Instance.new("Frame")
    SidebarBorder.Name = "Border"
    SidebarBorder.Size = UDim2.new(0, 1, 1, 0)
    SidebarBorder.Position = UDim2.new(1, -1, 0, 0)
    SidebarBorder.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    SidebarBorder.BorderSizePixel = 0
    SidebarBorder.Parent = Sidebar

    local LogoLabel = Instance.new("TextLabel")
    LogoLabel.Name = "Logo"
    LogoLabel.Size = UDim2.new(1, -20, 0, 42)
    LogoLabel.Position = UDim2.new(0, 14, 0, 6)
    LogoLabel.BackgroundTransparency = 1
    LogoLabel.Font = Enum.Font.GothamBold
    LogoLabel.Text = Title
    LogoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogoLabel.TextSize = 16
    LogoLabel.TextXAlignment = Enum.TextXAlignment.Left
    LogoLabel.Parent = Sidebar

    local NavScroll = Instance.new("ScrollingFrame")
    NavScroll.Name = "NavScroll"
    NavScroll.Size = UDim2.new(1, 0, 1, -104)
    NavScroll.Position = UDim2.new(0, 0, 0, 48)
    NavScroll.BackgroundTransparency = 1
    NavScroll.BorderSizePixel = 0
    NavScroll.ScrollBarThickness = 2
    NavScroll.ScrollBarImageColor3 = Color3.fromRGB(28, 28, 28)
    NavScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    NavScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    NavScroll.Parent = Sidebar

    local NavLayout = Instance.new("UIListLayout")
    NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NavLayout.Padding = UDim.new(0, 2)
    NavLayout.Parent = NavScroll

    local NavPadding = Instance.new("UIPadding")
    NavPadding.PaddingLeft = UDim.new(0, 10)
    NavPadding.PaddingRight = UDim.new(0, 10)
    NavPadding.Parent = NavScroll

    local UserProfile = Instance.new("Frame")
    UserProfile.Name = "UserProfile"
    UserProfile.Size = UDim2.new(1, -16, 0, 44)
    UserProfile.Position = UDim2.new(0, 8, 1, -50)
    UserProfile.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    UserProfile.BorderSizePixel = 0
    UserProfile.Parent = Sidebar

    local uCorner = Instance.new("UICorner")
    uCorner.CornerRadius = UDim.new(0, 4)
    uCorner.Parent = UserProfile

    local uStroke = Instance.new("UIStroke")
    uStroke.Color = Color3.fromRGB(24, 24, 24)
    uStroke.Thickness = 1
    uStroke.Parent = UserProfile

    local uAvatar = Instance.new("ImageLabel")
    uAvatar.Size = UDim2.new(0, 32, 0, 32)
    uAvatar.Position = UDim2.new(0, 8, 0.5, -16)
    uAvatar.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    uAvatar.BorderSizePixel = 0
    uAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(UserProfileData.UserId) .. "&w=150&h=150"
    uAvatar.Parent = UserProfile

    local uAvCorner = Instance.new("UICorner")
    uAvCorner.CornerRadius = UDim.new(0, 3)
    uAvCorner.Parent = uAvatar

    local uName = Instance.new("TextLabel")
    uName.Size = UDim2.new(1, -48, 0, 16)
    uName.Position = UDim2.new(0, 46, 0, 8)
    uName.BackgroundTransparency = 1
    uName.Font = Enum.Font.GothamBold
    uName.Text = UserProfileData.Name
    uName.TextColor3 = Color3.fromRGB(255, 255, 255)
    uName.TextSize = 11.5
    uName.TextXAlignment = Enum.TextXAlignment.Left
    uName.TextTruncate = Enum.TextTruncate.AtEnd
    uName.Parent = UserProfile

    local uSub = Instance.new("TextLabel")
    uSub.Size = UDim2.new(1, -48, 0, 14)
    uSub.Position = UDim2.new(0, 46, 0, 24)
    uSub.BackgroundTransparency = 1
    uSub.Font = Enum.Font.GothamMedium
    uSub.Text = UserProfileData.Sub
    uSub.TextColor3 = Color3.fromRGB(160, 160, 160)
    uSub.TextSize = 10
    uSub.TextXAlignment = Enum.TextXAlignment.Left
    uSub.Parent = UserProfile

    -- TopBar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, -165, 0, 42)
    TopBar.Position = UDim2.new(0, 165, 0, 0)
    TopBar.BackgroundColor3 = Color3.fromRGB(6, 6, 6)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame

    local TopBottomBorder = Instance.new("Frame")
    TopBottomBorder.Size = UDim2.new(1, 0, 0, 1)
    TopBottomBorder.Position = UDim2.new(0, 0, 1, -1)
    TopBottomBorder.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TopBottomBorder.BorderSizePixel = 0
    TopBottomBorder.Parent = TopBar

    local MinTitleLabel = Instance.new("TextLabel")
    MinTitleLabel.Name = "MinTitle"
    MinTitleLabel.Size = UDim2.new(0, 140, 1, 0)
    MinTitleLabel.Position = UDim2.new(0, 14, 0, 0)
    MinTitleLabel.BackgroundTransparency = 1
    MinTitleLabel.Font = Enum.Font.GothamBold
    MinTitleLabel.Text = Title
    MinTitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinTitleLabel.TextSize = 15
    MinTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    MinTitleLabel.Visible = false
    MinTitleLabel.Parent = TopBar

    local TopBarLeft = Instance.new("Frame")
    TopBarLeft.Name = "TopBarLeft"
    TopBarLeft.Size = UDim2.new(1, -95, 1, 0)
    TopBarLeft.Position = UDim2.new(0, 12, 0, 0)
    TopBarLeft.BackgroundTransparency = 1
    TopBarLeft.Parent = TopBar

    local tblLayout = Instance.new("UIListLayout")
    tblLayout.FillDirection = Enum.FillDirection.Horizontal
    tblLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tblLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tblLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tblLayout.Padding = UDim.new(0, 8)
    tblLayout.Parent = TopBarLeft

    local SaveBtn = Instance.new("TextButton")
    SaveBtn.Name = "SaveBtn"
    SaveBtn.LayoutOrder = 1
    SaveBtn.Size = UDim2.new(0, 56, 0, 24)
    SaveBtn.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    SaveBtn.Font = Enum.Font.GothamBold
    SaveBtn.Text = "Save"
    SaveBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
    SaveBtn.TextSize = 11
    SaveBtn.AutoButtonColor = false
    SaveBtn.Parent = TopBarLeft

    local sCorner = Instance.new("UICorner")
    sCorner.CornerRadius = UDim.new(0, 4)
    sCorner.Parent = SaveBtn

    local sStroke = Instance.new("UIStroke")
    sStroke.Color = Color3.fromRGB(32, 32, 32)
    sStroke.Thickness = 1
    sStroke.Parent = SaveBtn

    SaveBtn.MouseButton1Click:Connect(function()
        Window:Notify({ Title = "CONFIG", Message = "Saved configuration!", Duration = 1.5, Tag = "CFG" })
    end)

    local ConfigPill = Instance.new("Frame")
    ConfigPill.Name = "ConfigPill"
    ConfigPill.LayoutOrder = 2
    ConfigPill.AutomaticSize = Enum.AutomaticSize.X
    ConfigPill.Size = UDim2.new(0, 0, 0, 24)
    ConfigPill.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    ConfigPill.BorderSizePixel = 0
    ConfigPill.ClipsDescendants = true
    ConfigPill.Parent = TopBarLeft

    local cpPadding = Instance.new("UIPadding")
    cpPadding.PaddingLeft = UDim.new(0, 10)
    cpPadding.PaddingRight = UDim.new(0, 10)
    cpPadding.Parent = ConfigPill

    local cpCorner = Instance.new("UICorner")
    cpCorner.CornerRadius = UDim.new(0, 4)
    cpCorner.Parent = ConfigPill

    local cpStroke = Instance.new("UIStroke")
    cpStroke.Color = Color3.fromRGB(32, 32, 32)
    cpStroke.Thickness = 1
    cpStroke.Parent = ConfigPill

    local cpText = Instance.new("TextLabel")
    cpText.AutomaticSize = Enum.AutomaticSize.X
    cpText.Size = UDim2.new(0, 0, 1, 0)
    cpText.BackgroundTransparency = 1
    cpText.Font = Enum.Font.GothamMedium
    cpText.Text = Subtitle
    cpText.TextColor3 = Color3.fromRGB(200, 200, 200)
    cpText.TextSize = 10.5
    cpText.TextXAlignment = Enum.TextXAlignment.Center
    cpText.Parent = ConfigPill

    local KeyHintLabel = Instance.new("TextLabel")
    KeyHintLabel.Name = "KeyHintLabel"
    KeyHintLabel.LayoutOrder = 3
    KeyHintLabel.AutomaticSize = Enum.AutomaticSize.X
    KeyHintLabel.Size = UDim2.new(0, 0, 0, 24)
    KeyHintLabel.BackgroundTransparency = 1
    KeyHintLabel.Font = Enum.Font.GothamMedium
    KeyHintLabel.Text = "[" .. Window.ToggleKey.Name .. ": Toggle]"
    KeyHintLabel.TextColor3 = Color3.fromRGB(110, 110, 110)
    KeyHintLabel.TextSize = 10.5
    KeyHintLabel.TextXAlignment = Enum.TextXAlignment.Left
    KeyHintLabel.Parent = TopBarLeft


    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Name = "MinimizeBtn"
    MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
    MinimizeBtn.Position = UDim2.new(1, -70, 0.5, -14)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.Text = "-"
    MinimizeBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
    MinimizeBtn.TextSize = 15
    MinimizeBtn.AutoButtonColor = false
    MinimizeBtn.ZIndex = 100
    MinimizeBtn.Parent = TopBar

    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 4)
    minCorner.Parent = MinimizeBtn

    local minStroke = Instance.new("UIStroke")
    minStroke.Color = Color3.fromRGB(36, 36, 36)
    minStroke.Thickness = 1
    minStroke.Parent = MinimizeBtn

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -36, 0.5, -14)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
    CloseBtn.TextSize = 11
    CloseBtn.AutoButtonColor = false
    CloseBtn.Modal = true
    CloseBtn.ZIndex = 100
    CloseBtn.Parent = TopBar

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 4)
    cCorner.Parent = CloseBtn

    local cStroke = Instance.new("UIStroke")
    cStroke.Color = Color3.fromRGB(36, 36, 36)
    cStroke.Thickness = 1
    cStroke.Parent = CloseBtn

    local QuickOpenPill = Instance.new("TextButton")
    QuickOpenPill.Name = "QuickOpenPill"
    QuickOpenPill.Size = UDim2.new(0, 150, 0, 26)
    QuickOpenPill.Position = UDim2.new(0.5, -75, 0, 10)
    QuickOpenPill.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    QuickOpenPill.BorderSizePixel = 0
    QuickOpenPill.Font = Enum.Font.GothamBold
    QuickOpenPill.Text = Title .. " • OPEN"
    QuickOpenPill.TextColor3 = Color3.fromRGB(230, 230, 230)
    QuickOpenPill.TextSize = 10.5
    QuickOpenPill.AutoButtonColor = false
    QuickOpenPill.Visible = false
    QuickOpenPill.ZIndex = 1000
    QuickOpenPill.Parent = ScreenGui

    local qCorner = Instance.new("UICorner")
    qCorner.CornerRadius = UDim.new(0, 13)
    qCorner.Parent = QuickOpenPill

    local qStroke = Instance.new("UIStroke")
    qStroke.Color = Color3.fromRGB(34, 34, 34)
    qStroke.Thickness = 1
    qStroke.Parent = QuickOpenPill

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -165, 1, -42)
    ContentContainer.Position = UDim2.new(0, 165, 0, 42)
    ContentContainer.BackgroundColor3 = Color3.fromRGB(6, 6, 6)
    ContentContainer.BorderSizePixel = 0
    ContentContainer.Parent = MainFrame

    local DropdownOverlay = Instance.new("Frame")
    DropdownOverlay.Name = "DropdownOverlay"
    DropdownOverlay.Size = UDim2.new(1, 0, 1, 0)
    DropdownOverlay.Position = UDim2.new(0, 0, 0, 0)
    DropdownOverlay.BackgroundTransparency = 1
    DropdownOverlay.ZIndex = 5000
    DropdownOverlay.Visible = true
    DropdownOverlay.Parent = MainFrame

    local OverlayBackdrop = Instance.new("TextButton")
    OverlayBackdrop.Name = "OverlayBackdrop"
    OverlayBackdrop.Size = UDim2.new(1, 0, 1, 0)
    OverlayBackdrop.BackgroundTransparency = 1
    OverlayBackdrop.Text = ""
    OverlayBackdrop.Visible = false
    OverlayBackdrop.ZIndex = 5000
    OverlayBackdrop.Parent = DropdownOverlay

    OverlayBackdrop.MouseButton1Click:Connect(function()
        if Window.ActiveDropdown and Window.ActiveDropdown.Close then
            pcall(Window.ActiveDropdown.Close)
        end
    end)

    Window.DropdownOverlay = DropdownOverlay
    Window.OverlayBackdrop = OverlayBackdrop

    -- Minimize & Visibility Logic
    local NormalMenuSize = UDim2.new(0, 700, 0, 470)
    local MinimizedMenuSize = UDim2.new(0, 270, 0, 42)
    local NormalMenuPos = UDim2.new(0.5, -350, 0.5, -235)
    local lastOpenPosition = NormalMenuPos

    local function toggleMenuVisibility(targetState)
        if targetState == nil then
            targetState = not MainFrame.Visible
        end
        Window.Visible = targetState
        MainFrame.Visible = targetState

        if targetState then
            if Window.IsMinimized then
                MainFrame.Size = MinimizedMenuSize
            else
                MainFrame.Size = NormalMenuSize
            end
            MainFrame.Position = lastOpenPosition or NormalMenuPos
        else
            if MainFrame.Position.Y.Scale >= 0 and MainFrame.Position.Y.Scale <= 1 then
                lastOpenPosition = MainFrame.Position
            end
        end

        QuickOpenPill.Visible = not targetState
        CloseBtn.Modal = targetState

        if not targetState then
            pcall(function()
                Services.UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
                Services.UserInputService.MouseIconEnabled = false
            end)
        else
            pcall(function()
                Services.UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                Services.UserInputService.MouseIconEnabled = true
            end)
        end
    end

    QuickOpenPill.MouseButton1Click:Connect(function() toggleMenuVisibility(true) end)
    CloseBtn.MouseButton1Click:Connect(function() toggleMenuVisibility(false) end)

    CloseBtn.MouseEnter:Connect(function()
        CloseBtn.BackgroundColor3 = Color3.fromRGB(190, 35, 35)
        CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    CloseBtn.MouseLeave:Connect(function()
        CloseBtn.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
        CloseBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
    end)

    local function handleMinimizeClick()
        Window.IsMinimized = not Window.IsMinimized
        if Window.IsMinimized then
            MinimizeBtn.Text = "+"
            Sidebar.Visible = false
            ContentContainer.Visible = false
            SaveBtn.Visible = false
            ConfigPill.Visible = false
            KeyHintLabel.Visible = false
            MinTitleLabel.Visible = true
            TopBar.Size = UDim2.new(1, 0, 1, 0)
            TopBar.Position = UDim2.new(0, 0, 0, 0)
            Services.TweenService:Create(MainFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = MinimizedMenuSize
            }):Play()
        else
            MinimizeBtn.Text = "-"
            MinTitleLabel.Visible = false
            SaveBtn.Visible = true
            ConfigPill.Visible = true
            KeyHintLabel.Visible = true
            Services.TweenService:Create(MainFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = NormalMenuSize
            }):Play()
            task.delay(0.12, function()
                if not Window.IsMinimized then
                    Sidebar.Visible = true
                    ContentContainer.Visible = true
                    TopBar.Size = UDim2.new(1, -165, 0, 42)
                    TopBar.Position = UDim2.new(0, 165, 0, 0)
                end
            end)
        end
    end
    MinimizeBtn.MouseButton1Click:Connect(handleMinimizeClick)

    -- Window Dragging
    local isDragging, dragInput, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if Window.ActiveDropdown and Window.ActiveDropdown.Close then
                pcall(Window.ActiveDropdown.Close)
            end
            local p = input.Position
            local function isOverInteractive(btn)
                if not btn or not btn.Visible then return false end
                local bp = btn.AbsolutePosition
                local bs = btn.AbsoluteSize
                return (p.X >= bp.X and p.X <= (bp.X + bs.X) and p.Y >= bp.Y and p.Y <= (bp.Y + bs.Y))
            end
            if isOverInteractive(CloseBtn) or isOverInteractive(MinimizeBtn) or isOverInteractive(SaveBtn) then return end

            isDragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
                end
            end)
        end
    end)
    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    table.insert(Window.Connections, Services.UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and isDragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))

    table.insert(Window.Connections, Services.UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if not Window.ListeningForToggleKey and input.KeyCode == Window.ToggleKey then
                toggleMenuVisibility()
            end
        end
    end))

    local categoryOrder = 0

    function Window:CreateCategory(catTitle)
        categoryOrder = categoryOrder + 1
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 22)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.Text = string.upper(catTitle)
        lbl.TextColor3 = Color3.fromRGB(110, 110, 110)
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.LayoutOrder = categoryOrder
        lbl.Parent = NavScroll
        return lbl
    end

    function Window:CreateTab(tabTitle)
        categoryOrder = categoryOrder + 1

        local page = Instance.new("ScrollingFrame")
        page.Name = tabTitle .. "Page"
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 4
        page.ScrollBarImageColor3 = Color3.fromRGB(45, 45, 45)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.ClipsDescendants = true
        page.Visible = false
        page.Parent = ContentContainer

        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 12)
        pad.PaddingBottom = UDim.new(0, 24)
        pad.PaddingLeft = UDim.new(0, 14)
        pad.PaddingRight = UDim.new(0, 14)
        pad.Parent = page

        local col1 = Instance.new("Frame")
        col1.Name = "Col1"
        col1.Size = UDim2.new(0.5, -21, 0, 0)
        col1.AutomaticSize = Enum.AutomaticSize.Y
        col1.Position = UDim2.new(0, 0, 0, 0)
        col1.BackgroundTransparency = 1
        col1.Parent = page

        local l1 = Instance.new("UIListLayout")
        l1.SortOrder = Enum.SortOrder.LayoutOrder
        l1.Padding = UDim.new(0, 14)
        l1.Parent = col1

        local col2 = Instance.new("Frame")
        col2.Name = "Col2"
        col2.Size = UDim2.new(0.5, -21, 0, 0)
        col2.AutomaticSize = Enum.AutomaticSize.Y
        col2.Position = UDim2.new(0.5, -7, 0, 0)
        col2.BackgroundTransparency = 1
        col2.Parent = page

        local l2 = Instance.new("UIListLayout")
        l2.SortOrder = Enum.SortOrder.LayoutOrder
        l2.Padding = UDim.new(0, 14)
        l2.Parent = col2

        local function updateCanvas()
            local h = math.max(l1.AbsoluteContentSize.Y, l2.AbsoluteContentSize.Y)
            page.CanvasSize = UDim2.new(0, 0, 0, h + 36)
        end
        l1:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
        l2:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
        page:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            if Window.ActiveDropdown and Window.ActiveDropdown.Close then
                pcall(Window.ActiveDropdown.Close)
            end
        end)

        local btn = Instance.new("TextButton")
        btn.Name = tabTitle .. "Btn"
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.BackgroundColor3 = Color3.fromRGB(4, 4, 4)
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.GothamMedium
        btn.Text = "  " .. tabTitle
        btn.TextColor3 = Color3.fromRGB(140, 140, 140)
        btn.TextSize = 12
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.LayoutOrder = categoryOrder
        btn.AutoButtonColor = false
        btn.Parent = NavScroll

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 4)
        bCorner.Parent = btn

        local Tab = {
            Page = page,
            Col1 = col1,
            Col2 = col2,
            Button = btn
        }

        local function selectTab()
            if Window.ActiveDropdown and Window.ActiveDropdown.Close then
                pcall(Window.ActiveDropdown.Close)
            end
            for _, otherTab in pairs(Window.Pages) do
                otherTab.Page.Visible = false
                otherTab.Button.BackgroundColor3 = Color3.fromRGB(4, 4, 4)
                otherTab.Button.TextColor3 = Color3.fromRGB(140, 140, 140)
            end
            Tab.Page.Visible = true
            Tab.Button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            Tab.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            Window.ActiveTab = Tab
        end

        btn.MouseButton1Click:Connect(selectTab)
        table.insert(Window.Pages, Tab)

        if #Window.Pages == 1 then
            selectTab()
        end

        function Tab:CreateCard(cardTitle, colIndex)
            local targetCol = (colIndex == 2 and col2) or col1

            local card = Instance.new("Frame")
            card.Name = cardTitle .. "Card"
            card.Size = UDim2.new(1, 0, 0, 0)
            card.AutomaticSize = Enum.AutomaticSize.Y
            card.BackgroundColor3 = Color3.fromRGB(11, 11, 11)
            card.BorderSizePixel = 0
            card.Parent = targetCol

            local cCorner = Instance.new("UICorner")
            cCorner.CornerRadius = UDim.new(0, 6)
            cCorner.Parent = card

            local cStroke = Instance.new("UIStroke")
            cStroke.Color = Color3.fromRGB(26, 26, 26)
            cStroke.Thickness = 1
            cStroke.Parent = card

            local layout = Instance.new("UIListLayout")
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.Padding = UDim.new(0, 10)
            layout.Parent = card

            local pad = Instance.new("UIPadding")
            pad.PaddingTop = UDim.new(0, 12)
            pad.PaddingBottom = UDim.new(0, 12)
            pad.PaddingLeft = UDim.new(0, 12)
            pad.PaddingRight = UDim.new(0, 12)
            pad.Parent = card

            local tLabel = Instance.new("TextLabel")
            tLabel.Size = UDim2.new(1, 0, 0, 18)
            tLabel.BackgroundTransparency = 1
            tLabel.Font = Enum.Font.GothamBold
            tLabel.Text = cardTitle
            tLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
            tLabel.TextSize = 12
            tLabel.TextXAlignment = Enum.TextXAlignment.Left
            tLabel.Parent = card

            local sep = Instance.new("Frame")
            sep.Size = UDim2.new(1, 0, 0, 1)
            sep.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            sep.BorderSizePixel = 0
            sep.Parent = card

            local CardObj = { Card = card }

            function CardObj:AddToggle(toggleTitle, defaultValue, callback)
                defaultValue = defaultValue or false
                callback = callback or function() end

                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 24)
                row.BackgroundTransparency = 1
                row.Parent = card

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, -44, 1, 0)
                label.BackgroundTransparency = 1
                label.Font = Enum.Font.GothamMedium
                label.Text = toggleTitle
                label.TextColor3 = Color3.fromRGB(200, 200, 200)
                label.TextSize = 11.5
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = row

                local switch = Instance.new("TextButton")
                switch.Size = UDim2.new(0, 36, 0, 18)
                switch.Position = UDim2.new(1, -36, 0.5, -9)
                switch.BackgroundColor3 = defaultValue and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(24, 24, 24)
                switch.Text = ""
                switch.AutoButtonColor = false
                switch.Parent = row

                local swCorner = Instance.new("UICorner")
                swCorner.CornerRadius = UDim.new(1, 0)
                swCorner.Parent = switch

                local knob = Instance.new("Frame")
                knob.Size = UDim2.new(0, 14, 0, 14)
                knob.Position = defaultValue and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
                knob.BackgroundColor3 = defaultValue and Color3.fromRGB(12, 12, 12) or Color3.fromRGB(140, 140, 140)
                knob.BorderSizePixel = 0
                knob.Parent = switch

                local kCorner = Instance.new("UICorner")
                kCorner.CornerRadius = UDim.new(1, 0)
                kCorner.Parent = knob

                local state = defaultValue
                local function setVal(newState)
                    state = newState
                    local targetSwitchCol = state and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(24, 24, 24)
                    local targetKnobCol = state and Color3.fromRGB(12, 12, 12) or Color3.fromRGB(140, 140, 140)
                    local targetPos = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)

                    Services.TweenService:Create(switch, TweenInfo.new(0.12), {BackgroundColor3 = targetSwitchCol}):Play()
                    Services.TweenService:Create(knob, TweenInfo.new(0.12), {Position = targetPos, BackgroundColor3 = targetKnobCol}):Play()
                    pcall(callback, state)
                end

                switch.MouseButton1Click:Connect(function()
                    setVal(not state)
                end)

                return {
                    Set = setVal,
                    Get = function() return state end
                }
            end

            function CardObj:AddSlider(sliderTitle, minVal, maxVal, defaultVal, stepVal, suffix, callback)
                minVal = minVal or 0
                maxVal = maxVal or 100
                stepVal = stepVal or 1
                suffix = suffix or ""
                defaultVal = math.clamp(defaultVal or minVal, minVal, maxVal)
                callback = callback or function() end

                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 44)
                row.BackgroundTransparency = 1
                row.Parent = card

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(0.7, 0, 0, 16)
                label.BackgroundTransparency = 1
                label.Font = Enum.Font.GothamMedium
                label.Text = sliderTitle
                label.TextColor3 = Color3.fromRGB(200, 200, 200)
                label.TextSize = 11.5
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = row

                local valLabel = Instance.new("TextLabel")
                valLabel.Size = UDim2.new(0.3, 0, 0, 16)
                valLabel.Position = UDim2.new(0.7, 0, 0, 0)
                valLabel.BackgroundTransparency = 1
                valLabel.Font = Enum.Font.GothamBold
                valLabel.Text = tostring(defaultVal) .. suffix
                valLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                valLabel.TextSize = 11.5
                valLabel.TextXAlignment = Enum.TextXAlignment.Right
                valLabel.Parent = row

                local track = Instance.new("Frame")
                track.Size = UDim2.new(1, 0, 0, 4)
                track.Position = UDim2.new(0, 0, 0, 26)
                track.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
                track.BorderSizePixel = 0
                track.Parent = row

                local trCorner = Instance.new("UICorner")
                trCorner.CornerRadius = UDim.new(1, 0)
                trCorner.Parent = track

                local initAlpha = math.clamp((defaultVal - minVal) / (maxVal - minVal), 0, 1)
                local fill = Instance.new("Frame")
                fill.Size = UDim2.new(initAlpha, 0, 1, 0)
                fill.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
                fill.BorderSizePixel = 0
                fill.Parent = track

                local fCorner = Instance.new("UICorner")
                fCorner.CornerRadius = UDim.new(1, 0)
                fCorner.Parent = fill

                local currentVal = defaultVal
                local sliding = false
                local function updateSlide(inputX)
                    local trackWidth = track.AbsoluteSize.X
                    local rel = math.clamp(inputX - track.AbsolutePosition.X, 0, trackWidth)
                    local alpha = rel / trackWidth
                    local rawVal = minVal + (maxVal - minVal) * alpha
                    local steppedVal = math.floor(rawVal / stepVal + 0.5) * stepVal
                    steppedVal = math.clamp(steppedVal, minVal, maxVal)

                    currentVal = steppedVal
                    fill.Size = UDim2.new(alpha, 0, 1, 0)
                    valLabel.Text = string.format(stepVal < 1 and "%.1f" or "%.0f", steppedVal) .. suffix
                    pcall(callback, steppedVal)
                end

                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = true
                        updateSlide(input.Position.X)
                        input.Changed:Connect(function()
                            if input.UserInputState == Enum.UserInputState.End then
                                sliding = false
                            end
                        end)
                    end
                end)

                table.insert(Window.Connections, Services.UserInputService.InputChanged:Connect(function(input)
                    if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        updateSlide(input.Position.X)
                    end
                end))

                return {
                    Set = function(newVal)
                        newVal = math.clamp(newVal, minVal, maxVal)
                        currentVal = newVal
                        local a = (newVal - minVal) / (maxVal - minVal)
                        fill.Size = UDim2.new(a, 0, 1, 0)
                        valLabel.Text = string.format(stepVal < 1 and "%.1f" or "%.0f", newVal) .. suffix
                        pcall(callback, newVal)
                    end,
                    Get = function() return currentVal end
                }
            end

            function CardObj:AddButton(btnTitle, btnText, callback)
                callback = callback or function() end

                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 28)
                row.BackgroundTransparency = 1
                row.Parent = card

                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, 0, 1, 0)
                btn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
                btn.BorderSizePixel = 0
                btn.Font = Enum.Font.GothamBold
                btn.Text = btnText or btnTitle
                btn.TextColor3 = Color3.fromRGB(240, 240, 240)
                btn.TextSize = 11.5
                btn.AutoButtonColor = false
                btn.Parent = row

                local bCorner = Instance.new("UICorner")
                bCorner.CornerRadius = UDim.new(0, 4)
                bCorner.Parent = btn

                local bStroke = Instance.new("UIStroke")
                bStroke.Color = Color3.fromRGB(36, 36, 36)
                bStroke.Thickness = 1
                bStroke.Parent = btn

                btn.MouseEnter:Connect(function()
                    Services.TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(26, 26, 26)}):Play()
                end)
                btn.MouseLeave:Connect(function()
                    Services.TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(18, 18, 18)}):Play()
                end)

                btn.MouseButton1Click:Connect(function()
                    pcall(callback)
                end)

                return btn
            end
            function CardObj:AddDropdown(ddTitle, options, defaultOpt, callback)
                options = options or {}
                defaultOpt = defaultOpt or options[1] or ""
                callback = callback or function() end

                local row = Instance.new("Frame")
                row.Name = (tostring(ddTitle) or "Dropdown") .. "_Row"
                row.Size = UDim2.new(1, 0, 0, 52)
                row.BackgroundTransparency = 1
                row.ClipsDescendants = false
                row.Parent = card

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 0, 16)
                label.BackgroundTransparency = 1
                label.Font = Enum.Font.GothamMedium
                label.Text = ddTitle
                label.TextColor3 = Color3.fromRGB(200, 200, 200)
                label.TextSize = 11.5
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = row

                local ddBtn = Instance.new("TextButton")
                ddBtn.Size = UDim2.new(1, 0, 0, 26)
                ddBtn.Position = UDim2.new(0, 0, 0, 22)
                ddBtn.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
                ddBtn.BorderSizePixel = 0
                ddBtn.Font = Enum.Font.GothamMedium
                ddBtn.Text = "  " .. tostring(defaultOpt)
                ddBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
                ddBtn.TextSize = 11
                ddBtn.TextXAlignment = Enum.TextXAlignment.Left
                ddBtn.AutoButtonColor = false
                ddBtn.ZIndex = 5
                ddBtn.Parent = row

                local dCorner = Instance.new("UICorner")
                dCorner.CornerRadius = UDim.new(0, 4)
                dCorner.Parent = ddBtn

                local dStroke = Instance.new("UIStroke")
                dStroke.Color = Color3.fromRGB(32, 32, 32)
                dStroke.Thickness = 1
                dStroke.Parent = ddBtn

                local btnDot = Instance.new("Frame")
                btnDot.Name = "ColorBadge"
                btnDot.Size = UDim2.new(0, 8, 0, 8)
                btnDot.Position = UDim2.new(0, 8, 0.5, -4)
                btnDot.BorderSizePixel = 0
                btnDot.Visible = false
                btnDot.ZIndex = 6
                btnDot.Parent = ddBtn

                local bDotCorner = Instance.new("UICorner")
                bDotCorner.CornerRadius = UDim.new(1, 0)
                bDotCorner.Parent = btnDot

                local arrow = Instance.new("TextLabel")
                arrow.Size = UDim2.new(0, 24, 1, 0)
                arrow.Position = UDim2.new(1, -24, 0, 0)
                arrow.BackgroundTransparency = 1
                arrow.Font = Enum.Font.GothamBold
                arrow.Text = "v"
                arrow.TextColor3 = Color3.fromRGB(140, 140, 140)
                arrow.TextSize = 10
                arrow.ZIndex = 6
                arrow.Parent = ddBtn

                local maxVisible = math.min(#options, 6)
                local itemHeight = 25
                local listHeight = maxVisible * itemHeight

                local listFrame = Instance.new("ScrollingFrame")
                listFrame.Name = (tostring(ddTitle) or "Dropdown") .. "_Popup"
                listFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
                listFrame.BorderSizePixel = 0
                listFrame.ScrollBarThickness = (#options > 6) and 3 or 0
                listFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
                listFrame.CanvasSize = UDim2.new(0, 0, 0, #options * itemHeight)
                listFrame.Visible = false
                listFrame.ZIndex = 5005
                listFrame.ClipsDescendants = true
                listFrame.Parent = Window.DropdownOverlay or MainFrame

                local lfCorner = Instance.new("UICorner")
                lfCorner.CornerRadius = UDim.new(0, 4)
                lfCorner.Parent = listFrame

                local lfStroke = Instance.new("UIStroke")
                lfStroke.Color = Color3.fromRGB(42, 42, 42)
                lfStroke.Thickness = 1
                lfStroke.Parent = listFrame

                local lfLayout = Instance.new("UIListLayout")
                lfLayout.SortOrder = Enum.SortOrder.LayoutOrder
                lfLayout.Parent = listFrame

                local selected = defaultOpt
                local isOpen = false
                local optionButtons = {}
                local DropdownInstance = {}

                local function getColorForOpt(opt)
                    if typeof(ColorMap) == "table" and ColorMap[opt] then
                        return ColorMap[opt]
                    end
                    if _G.KeywareColorMap and _G.KeywareColorMap[opt] then
                        return _G.KeywareColorMap[opt]
                    end
                    return nil
                end

                local function updateBtnVisual(opt)
                    local col = getColorForOpt(opt)
                    if col then
                        btnDot.BackgroundColor3 = col
                        btnDot.Visible = true
                        ddBtn.Text = "       " .. tostring(opt)
                    else
                        btnDot.Visible = false
                        ddBtn.Text = "  " .. tostring(opt)
                    end
                end

                local function setOpen(open)
                    if isOpen == open then return end
                    isOpen = open
                    if isOpen then
                        if Window and Window.ActiveDropdown and Window.ActiveDropdown ~= DropdownInstance then
                            pcall(function() Window.ActiveDropdown:Close() end)
                        end
                        if Window then Window.ActiveDropdown = DropdownInstance end

                        arrow.Text = "^"
                        arrow.TextColor3 = Color3.fromRGB(240, 240, 240)
                        dStroke.Color = Color3.fromRGB(70, 70, 70)

                        local absBtnPos = ddBtn.AbsolutePosition
                        local absMainPos = MainFrame.AbsolutePosition
                        local btnWidth = ddBtn.AbsoluteSize.X
                        local relX = absBtnPos.X - absMainPos.X
                        local relY = absBtnPos.Y - absMainPos.Y + ddBtn.AbsoluteSize.Y + 3

                        if (relY + listHeight) > (MainFrame.AbsoluteSize.Y - 10) then
                            relY = absBtnPos.Y - absMainPos.Y - listHeight - 3
                        end

                        listFrame.Position = UDim2.new(0, relX, 0, relY)
                        listFrame.Size = UDim2.new(0, btnWidth, 0, listHeight)
                        listFrame.Visible = true
                        if Window and Window.OverlayBackdrop then
                            Window.OverlayBackdrop.Visible = true
                        end
                    else
                        arrow.Text = "v"
                        arrow.TextColor3 = Color3.fromRGB(140, 140, 140)
                        dStroke.Color = Color3.fromRGB(32, 32, 32)
                        listFrame.Visible = false
                        if Window and Window.OverlayBackdrop then
                            Window.OverlayBackdrop.Visible = false
                        end
                        if Window and Window.ActiveDropdown == DropdownInstance then
                            Window.ActiveDropdown = nil
                        end
                    end
                end

                local function selectOpt(opt)
                    selected = opt
                    updateBtnVisual(opt)
                    for o, btn in pairs(optionButtons) do
                        local isCur = (o == opt)
                        btn.BackgroundColor3 = isCur and Color3.fromRGB(24, 24, 24) or Color3.fromRGB(12, 12, 12)
                        btn.TextColor3 = isCur and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(170, 170, 170)
                        btn.Font = isCur and Enum.Font.GothamBold or Enum.Font.GothamMedium
                    end
                    setOpen(false)
                    pcall(callback, opt)
                end

                for i, opt in ipairs(options) do
                    local optBtn = Instance.new("TextButton")
                    optBtn.Size = UDim2.new(1, 0, 0, itemHeight)
                    optBtn.BackgroundColor3 = (opt == selected) and Color3.fromRGB(24, 24, 24) or Color3.fromRGB(12, 12, 12)
                    optBtn.BorderSizePixel = 0
                    optBtn.Font = (opt == selected) and Enum.Font.GothamBold or Enum.Font.GothamMedium
                    optBtn.TextColor3 = (opt == selected) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(170, 170, 170)
                    optBtn.TextSize = 11
                    optBtn.TextXAlignment = Enum.TextXAlignment.Left
                    optBtn.ZIndex = 5006
                    optBtn.AutoButtonColor = false
                    optBtn.Parent = listFrame
                    optionButtons[opt] = optBtn

                    local col = getColorForOpt(opt)
                    if col then
                        local dot = Instance.new("Frame")
                        dot.Size = UDim2.new(0, 8, 0, 8)
                        dot.Position = UDim2.new(0, 8, 0.5, -4)
                        dot.BackgroundColor3 = col
                        dot.BorderSizePixel = 0
                        dot.ZIndex = 5007
                        dot.Parent = optBtn

                        local dDotCorner = Instance.new("UICorner")
                        dDotCorner.CornerRadius = UDim.new(1, 0)
                        dDotCorner.Parent = dot

                        optBtn.Text = "       " .. tostring(opt)
                    else
                        optBtn.Text = "  " .. tostring(opt)
                    end

                    optBtn.MouseEnter:Connect(function()
                        if selected ~= opt then
                            optBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
                            optBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
                        end
                    end)
                    optBtn.MouseLeave:Connect(function()
                        if selected ~= opt then
                            optBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
                            optBtn.TextColor3 = Color3.fromRGB(170, 170, 170)
                        end
                    end)
                    optBtn.MouseButton1Click:Connect(function()
                        selectOpt(opt)
                    end)
                end

                updateBtnVisual(defaultOpt)

                ddBtn.MouseButton1Click:Connect(function()
                    setOpen(not isOpen)
                end)

                DropdownInstance.Set = selectOpt
                DropdownInstance.Get = function() return selected end
                DropdownInstance.Close = function() setOpen(false) end

                function DropdownInstance:Refresh(newOptions, newDefault)
                    options = newOptions or {}
                    newDefault = newDefault or options[1] or ""
                    
                    for _, child in ipairs(listFrame:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    table.clear(optionButtons)

                    maxVisible = math.min(#options, 6)
                    listHeight = maxVisible * itemHeight
                    listFrame.ScrollBarThickness = (#options > 6) and 3 or 0
                    listFrame.CanvasSize = UDim2.new(0, 0, 0, #options * itemHeight)

                    for i, opt in ipairs(options) do
                        local optBtn = Instance.new("TextButton")
                        optBtn.Name = "Opt_" .. tostring(opt)
                        optBtn.Size = UDim2.new(1, 0, 0, itemHeight)
                        optBtn.Position = UDim2.new(0, 0, 0, (i - 1) * itemHeight)
                        optBtn.BackgroundColor3 = (opt == newDefault) and Color3.fromRGB(24, 24, 24) or Color3.fromRGB(12, 12, 12)
                        optBtn.BorderSizePixel = 0
                        optBtn.Font = (opt == newDefault) and Enum.Font.GothamBold or Enum.Font.GothamMedium
                        optBtn.Text = "  " .. tostring(opt)
                        optBtn.TextColor3 = (opt == newDefault) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(170, 170, 170)
                        optBtn.TextSize = 10.5
                        optBtn.TextXAlignment = Enum.TextXAlignment.Left
                        optBtn.AutoButtonColor = false
                        optBtn.ZIndex = 5006
                        optBtn.LayoutOrder = i
                        optBtn.Parent = listFrame

                        local col = getColorForOpt(opt)
                        if col then
                            local dot = Instance.new("Frame")
                            dot.Size = UDim2.new(0, 7, 0, 7)
                            dot.Position = UDim2.new(0, 8, 0.5, -3.5)
                            dot.BackgroundColor3 = col
                            dot.BorderSizePixel = 0
                            dot.ZIndex = 5007
                            dot.Parent = optBtn

                            local dCorner = Instance.new("UICorner")
                            dCorner.CornerRadius = UDim.new(1, 0)
                            dCorner.Parent = dot

                            optBtn.Text = "       " .. tostring(opt)
                        end

                        optionButtons[opt] = optBtn

                        optBtn.MouseEnter:Connect(function()
                            if selected ~= opt then
                                optBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                                optBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
                            end
                        end)
                        optBtn.MouseLeave:Connect(function()
                            if selected ~= opt then
                                optBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
                                optBtn.TextColor3 = Color3.fromRGB(170, 170, 170)
                            end
                        end)
                        optBtn.MouseButton1Click:Connect(function()
                            selectOpt(opt)
                        end)
                    end

                    selectOpt(newDefault)
                end

                return DropdownInstance
            end

            function CardObj:AddKeybind(kbTitle, defaultKey, callback)
                defaultKey = defaultKey or Enum.KeyCode.RightControl
                callback = callback or function() end

                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 28)
                row.BackgroundTransparency = 1
                row.Parent = card

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, -85, 1, 0)
                label.BackgroundTransparency = 1
                label.Font = Enum.Font.GothamMedium
                label.Text = kbTitle
                label.TextColor3 = Color3.fromRGB(200, 200, 200)
                label.TextSize = 11.5
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = row

                local bindBtn = Instance.new("TextButton")
                bindBtn.Size = UDim2.new(0, 80, 0, 22)
                bindBtn.Position = UDim2.new(1, -80, 0.5, -11)
                bindBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
                bindBtn.BorderSizePixel = 0
                bindBtn.Font = Enum.Font.GothamBold
                bindBtn.Text = defaultKey.Name
                bindBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
                bindBtn.TextSize = 10.5
                bindBtn.AutoButtonColor = false
                bindBtn.Parent = row

                local bCorner = Instance.new("UICorner")
                bCorner.CornerRadius = UDim.new(0, 4)
                bCorner.Parent = bindBtn

                local bStroke = Instance.new("UIStroke")
                bStroke.Color = Color3.fromRGB(36, 36, 36)
                bStroke.Thickness = 1
                bStroke.Parent = bindBtn

                local currentKey = defaultKey
                local listening = false

                bindBtn.MouseButton1Click:Connect(function()
                    listening = true
                    Window.ListeningForToggleKey = true
                    bindBtn.Text = "..."
                    bindBtn.TextColor3 = Color3.fromRGB(255, 255, 100)
                end)

                table.insert(Window.Connections, Services.UserInputService.InputBegan:Connect(function(input)
                    if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                        listening = false
                        Window.ListeningForToggleKey = false
                        currentKey = input.KeyCode
                        bindBtn.Text = input.KeyCode.Name
                        bindBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
                        if kbTitle:lower():find("toggle") or kbTitle:lower():find("menu") then
                            Window.ToggleKey = currentKey
                            KeyHintLabel.Text = "[" .. currentKey.Name .. ": Toggle]"
                        end
                        pcall(callback, currentKey)
                    end
                end))

                return {
                    Set = function(key)
                        currentKey = key
                        bindBtn.Text = key.Name
                    end,
                    Get = function() return currentKey end
                }
            end

            function CardObj:AddTextbox(tbTitle, placeholder, defaultText, callback)
                placeholder = placeholder or "Enter text..."
                defaultText = defaultText or ""
                callback = callback or function() end

                local row = Instance.new("Frame")
                row.Name = (tostring(tbTitle) or "Textbox") .. "_Row"
                row.Size = UDim2.new(1, 0, 0, 50)
                row.BackgroundTransparency = 1
                row.Parent = card

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 0, 16)
                label.BackgroundTransparency = 1
                label.Font = Enum.Font.GothamMedium
                label.Text = tbTitle
                label.TextColor3 = Color3.fromRGB(200, 200, 200)
                label.TextSize = 11.5
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = row

                local box = Instance.new("TextBox")
                box.Size = UDim2.new(1, 0, 0, 26)
                box.Position = UDim2.new(0, 0, 0, 22)
                box.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
                box.BorderSizePixel = 0
                box.Font = Enum.Font.GothamMedium
                box.PlaceholderText = placeholder
                box.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
                box.Text = defaultText
                box.TextColor3 = Color3.fromRGB(240, 240, 240)
                box.TextSize = 11
                box.TextXAlignment = Enum.TextXAlignment.Left
                box.ClearTextOnFocus = false
                box.Parent = row

                local bPad = Instance.new("UIPadding")
                bPad.PaddingLeft = UDim.new(0, 8)
                bPad.PaddingRight = UDim.new(0, 8)
                bPad.Parent = box

                local bCorner = Instance.new("UICorner")
                bCorner.CornerRadius = UDim.new(0, 4)
                bCorner.Parent = box

                local bStroke = Instance.new("UIStroke")
                bStroke.Color = Color3.fromRGB(32, 32, 32)
                bStroke.Thickness = 1
                bStroke.Parent = box

                box.Focused:Connect(function()
                    Services.TweenService:Create(bStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(70, 70, 70)}):Play()
                end)

                box.FocusLost:Connect(function(enterPressed)
                    Services.TweenService:Create(bStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(32, 32, 32)}):Play()
                    pcall(callback, box.Text, enterPressed)
                end)

                return {
                    Set = function(val)
                        box.Text = tostring(val or "")
                        pcall(callback, box.Text, false)
                    end,
                    Get = function()
                        return box.Text
                    end,
                    Instance = box
                }
            end

            function CardObj:AddColorPicker(cpTitle, defaultColor, callback)
                defaultColor = defaultColor or Color3.fromRGB(255, 50, 50)
                callback = callback or function() end

                local row = Instance.new("Frame")
                row.Name = (tostring(cpTitle) or "ColorPicker") .. "_Row"
                row.Size = UDim2.new(1, 0, 0, 28)
                row.BackgroundTransparency = 1
                row.Parent = card

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, -44, 1, 0)
                label.BackgroundTransparency = 1
                label.Font = Enum.Font.GothamMedium
                label.Text = cpTitle
                label.TextColor3 = Color3.fromRGB(200, 200, 200)
                label.TextSize = 11.5
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = row

                local colorBtn = Instance.new("TextButton")
                colorBtn.Size = UDim2.new(0, 36, 0, 18)
                colorBtn.Position = UDim2.new(1, -36, 0.5, -9)
                colorBtn.BackgroundColor3 = defaultColor
                colorBtn.BorderSizePixel = 0
                colorBtn.Text = ""
                colorBtn.AutoButtonColor = false
                colorBtn.Parent = row

                local cCorner = Instance.new("UICorner")
                cCorner.CornerRadius = UDim.new(0, 4)
                cCorner.Parent = colorBtn

                local cStroke = Instance.new("UIStroke")
                cStroke.Color = Color3.fromRGB(44, 44, 44)
                cStroke.Thickness = 1
                cStroke.Parent = colorBtn

                local currentColor = defaultColor

                local paletteFrame = Instance.new("Frame")
                paletteFrame.Name = (tostring(cpTitle) or "ColorPicker") .. "_Palette"
                paletteFrame.Size = UDim2.new(0, 180, 0, 110)
                paletteFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
                paletteFrame.BorderSizePixel = 0
                paletteFrame.Visible = false
                paletteFrame.ZIndex = 5005
                paletteFrame.ClipsDescendants = true
                paletteFrame.Parent = Window.DropdownOverlay or MainFrame

                local pfCorner = Instance.new("UICorner")
                pfCorner.CornerRadius = UDim.new(0, 4)
                pfCorner.Parent = paletteFrame

                local pfStroke = Instance.new("UIStroke")
                pfStroke.Color = Color3.fromRGB(42, 42, 42)
                pfStroke.Thickness = 1
                pfStroke.Parent = paletteFrame

                local pfGrid = Instance.new("UIGridLayout")
                pfGrid.CellSize = UDim2.new(0, 22, 0, 22)
                pfGrid.CellPadding = UDim2.new(0, 6, 0, 6)
                pfGrid.SortOrder = Enum.SortOrder.LayoutOrder
                pfGrid.Parent = paletteFrame

                local pfPad = Instance.new("UIPadding")
                pfPad.PaddingTop = UDim.new(0, 8)
                pfPad.PaddingBottom = UDim.new(0, 8)
                pfPad.PaddingLeft = UDim.new(0, 8)
                pfPad.PaddingRight = UDim.new(0, 8)
                pfPad.Parent = paletteFrame

                local presetColors = {
                    Color3.fromRGB(255, 50, 50),
                    Color3.fromRGB(255, 80, 20),
                    Color3.fromRGB(255, 215, 0),
                    Color3.fromRGB(130, 255, 0),
                    Color3.fromRGB(65, 255, 90),
                    Color3.fromRGB(0, 225, 255),
                    Color3.fromRGB(0, 170, 255),
                    Color3.fromRGB(80, 140, 255),
                    Color3.fromRGB(175, 75, 255),
                    Color3.fromRGB(255, 80, 180),
                    Color3.fromRGB(240, 240, 240),
                    Color3.fromRGB(100, 100, 100)
                }

                local isPaletteOpen = false
                local PickerInstance = {}

                local function setColor(newCol)
                    currentColor = newCol
                    colorBtn.BackgroundColor3 = currentColor
                    if isPaletteOpen then
                        isPaletteOpen = false
                        paletteFrame.Visible = false
                        if Window and Window.OverlayBackdrop then
                            Window.OverlayBackdrop.Visible = false
                        end
                        if Window and Window.ActiveDropdown == PickerInstance then
                            Window.ActiveDropdown = nil
                        end
                    end
                    pcall(callback, currentColor)
                end

                PickerInstance.Close = function()
                    if isPaletteOpen then
                        isPaletteOpen = false
                        paletteFrame.Visible = false
                        if Window and Window.OverlayBackdrop then
                            Window.OverlayBackdrop.Visible = false
                        end
                        if Window and Window.ActiveDropdown == PickerInstance then
                            Window.ActiveDropdown = nil
                        end
                    end
                end

                for _, pCol in ipairs(presetColors) do
                    local swatch = Instance.new("TextButton")
                    swatch.Text = ""
                    swatch.BackgroundColor3 = pCol
                    swatch.BorderSizePixel = 0
                    swatch.ZIndex = 5006
                    swatch.AutoButtonColor = false
                    swatch.Parent = paletteFrame

                    local swCorner = Instance.new("UICorner")
                    swCorner.CornerRadius = UDim.new(0, 3)
                    swCorner.Parent = swatch

                    swatch.MouseButton1Click:Connect(function()
                        setColor(pCol)
                    end)
                end

                colorBtn.MouseButton1Click:Connect(function()
                    if isPaletteOpen then
                        PickerInstance.Close()
                    else
                        if Window and Window.ActiveDropdown and Window.ActiveDropdown ~= PickerInstance then
                            pcall(function() Window.ActiveDropdown:Close() end)
                        end
                        if Window then Window.ActiveDropdown = PickerInstance end
                        isPaletteOpen = true

                        local absBtnPos = colorBtn.AbsolutePosition
                        local absMainPos = MainFrame.AbsolutePosition
                        local relX = absBtnPos.X - absMainPos.X - 144
                        local relY = absBtnPos.Y - absMainPos.Y + colorBtn.AbsoluteSize.Y + 4

                        if (relY + 110) > (MainFrame.AbsoluteSize.Y - 10) then
                            relY = absBtnPos.Y - absMainPos.Y - 110 - 4
                        end

                        paletteFrame.Position = UDim2.new(0, relX, 0, relY)
                        paletteFrame.Visible = true
                        if Window and Window.OverlayBackdrop then
                            Window.OverlayBackdrop.Visible = true
                        end
                    end
                end)

                PickerInstance.Set = setColor
                PickerInstance.Get = function() return currentColor end
                return PickerInstance
            end

            function CardObj:AddLabel(labelText)
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 0)
                row.AutomaticSize = Enum.AutomaticSize.Y
                row.BackgroundTransparency = 1
                row.Parent = card

                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, 0, 0, 0)
                lbl.AutomaticSize = Enum.AutomaticSize.Y
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.GothamMedium
                lbl.Text = labelText or ""
                lbl.TextColor3 = Color3.fromRGB(160, 160, 160)
                lbl.TextSize = 11
                lbl.TextWrapped = true
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Parent = row

                return {
                    SetText = function(newText)
                        lbl.Text = tostring(newText or "")
                    end,
                    Instance = lbl
                }
            end

            function CardObj:AddParagraph(pTitle, pDesc)
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 0)
                row.AutomaticSize = Enum.AutomaticSize.Y
                row.BackgroundTransparency = 1
                row.Parent = card

                local titleLbl = Instance.new("TextLabel")
                titleLbl.Size = UDim2.new(1, 0, 0, 16)
                titleLbl.BackgroundTransparency = 1
                titleLbl.Font = Enum.Font.GothamBold
                titleLbl.Text = pTitle or ""
                titleLbl.TextColor3 = Color3.fromRGB(240, 240, 240)
                titleLbl.TextSize = 11.5
                titleLbl.TextXAlignment = Enum.TextXAlignment.Left
                titleLbl.Parent = row

                local descLbl = Instance.new("TextLabel")
                descLbl.Size = UDim2.new(1, 0, 0, 0)
                descLbl.Position = UDim2.new(0, 0, 0, 18)
                descLbl.AutomaticSize = Enum.AutomaticSize.Y
                descLbl.BackgroundTransparency = 1
                descLbl.Font = Enum.Font.GothamMedium
                descLbl.Text = pDesc or ""
                descLbl.TextColor3 = Color3.fromRGB(150, 150, 150)
                descLbl.TextSize = 10.5
                descLbl.TextWrapped = true
                descLbl.TextXAlignment = Enum.TextXAlignment.Left
                descLbl.Parent = row

                return {
                    SetTitle = function(newTitle)
                        titleLbl.Text = tostring(newTitle or "")
                    end,
                    SetDesc = function(newDesc)
                        descLbl.Text = tostring(newDesc or "")
                    end
                }
            end

            function CardObj:AddDivider()
                local div = Instance.new("Frame")
                div.Size = UDim2.new(1, 0, 0, 1)
                div.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
                div.BorderSizePixel = 0
                div.Parent = card
                return div
            end

            return CardObj
        end


        Tab.CreateSection = Tab.CreateCard
        return Tab
    end

    function Window:Toggle(targetState)
        toggleMenuVisibility(targetState)
    end

    function Window:SetTitle(newTitle)
        LogoLabel.Text = newTitle
        MinTitleLabel.Text = newTitle
        QuickOpenPill.Text = newTitle .. " • OPEN"
    end

    function Window:SetSubtitle(newSub)
        cpText.Text = newSub
    end

    Window.Destroy = function()
        Window:Unload()
    end

    function Window:Unload()
        for _, conn in ipairs(Window.Connections) do
            if typeof(conn) == "RBXScriptConnection" and conn.Connected then
                conn:Disconnect()
            end
        end
        table.clear(Window.Connections)

        pcall(function()
            Services.UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            Services.UserInputService.MouseIconEnabled = true
        end)

        if ScreenGui and ScreenGui.Parent then
            ScreenGui:Destroy()
        end
    end

    return Window
end

return Keyware
