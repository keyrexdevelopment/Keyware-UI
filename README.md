<div align="center">

# Keyware UI

**A high-performance, minimalist Luau user interface framework for Roblox.**

[![Luau](https://img.shields.io/badge/Luau-000000?style=flat-square&logo=lua&logoColor=white)](https://luau-lang.org/)
[![License](https://img.shields.io/badge/License-MIT-000000?style=flat-square)](LICENSE)
[![Version](https://img.shields.io/badge/Version-2.0.0-000000?style=flat-square)](#)

</div>

---

## Overview

Keyware UI is an open-source, modular interface framework engineered specifically for Luau environments in Roblox. Built with performance, minimalism, and visual consistency in mind, it provides a comprehensive set of input components, layout containers, notification overlays, and status indicators out of the box.

## Quick Start

Load the library directly into your script using `loadstring`:

```lua
local Keyware = loadstring(game:HttpGet("https://raw.githubusercontent.com/keyrexdevelopment/Keyware-UI/main/KeywareLibrary.lua"))()
```

## Features

- **Performance**: Built strictly with native `TweenService` and hardware-accelerated GUI primitives. Zero polling loops or redundant renders.
- **Design System**: Dark monochrome palette, subtle border highlights, consistent typography, and fluid micro-animations.
- **Dual-Column Layout**: Multi-column organization inside tabs with automatic canvas height calculation.
- **Floating Overlays**: Dropdowns and color pickers render on an elevated overlay plane to prevent clipping by parent boundaries.
- **Notifications**: Queue-managed toast notifications with progress bars, tag badges, and enter/exit transitions.
- **Status Panel**: Optional left-side draggable status HUD displaying player metadata, connection status, and progress bars.
- **Security & Compatibility**: Built-in safe parenting mechanism supporting `gethui`, `get_hidden_gui`, `CoreGui`, and `protectgui`.

## Basic Usage

```lua
local Keyware = loadstring(game:HttpGet("https://raw.githubusercontent.com/keyrexdevelopment/Keyware-UI/main/KeywareLibrary.lua"))()

local Window = Keyware:CreateWindow({
    Title = "KEYWARE",
    Subtitle = "Universal Edition",
    Keybind = Enum.KeyCode.RightControl,
    StatusHUD = true
})

Window:Notify({
    Title = "System",
    Message = "Interface loaded successfully.",
    Duration = 3.5,
    Tag = "INFO"
})

Window:CreateCategory("MAIN")
local Tab = Window:CreateTab("General")

local Card = Tab:CreateCard("Configuration", 1)

Card:AddToggle("Enabled", true, function(state)
    print("State:", state)
end)

Card:AddSlider("Smoothing", 1, 20, 5, 1, "", function(value)
    print("Smoothing:", value)
end)

Card:AddDropdown("Target", { "Head", "Torso", "HumanoidRootPart" }, "Head", function(selected)
    print("Target:", selected)
end)

Card:AddKeybind("Activation Key", Enum.KeyCode.E, function(key)
    print("Key bound:", key.Name)
end)

Card:AddColorPicker("Accent Color", Color3.fromRGB(0, 225, 255), function(color)
    print("Color:", color)
end)

Card:AddButton("Execute Action", "Run", function()
    print("Action executed.")
end)
```

## API Reference

### Window Initialization

```lua
local Window = Keyware:CreateWindow(configuration)
```

| Parameter | Type | Default | Description |
|---|---|---|---|
| `Title` | `string` | `"KEYWARE"` | Top header window title |
| `Subtitle` | `string` | `"Global (Default)"` | Subtitle badge text beside the title |
| `Keybind` | `Enum.KeyCode` | `Enum.KeyCode.RightControl` | Keyboard key to toggle window visibility |
| `StatusHUD` | `boolean` | `true` | Enables draggable status HUD panel |
| `UserProfile` | `table` | Local player data | Table containing `{ Name, Sub, UserId }` |

### Window Methods

| Method | Parameters | Description |
|---|---|---|
| `Window:Notify(data)` | `data: table` | Dispatches toast notification with `{ Title, Message, Duration, Tag }` |
| `Window:CreateCategory(title)` | `title: string` | Inserts category header in the sidebar |
| `Window:CreateTab(title)` | `title: string` | Creates a new tab page with two content columns |
| `Window:Toggle(state)` | `state: boolean?` | Toggles or sets window visibility |
| `Window:SetTitle(title)` | `title: string` | Dynamically updates the window title |
| `Window:SetSubtitle(subtitle)` | `subtitle: string` | Dynamically updates the subtitle badge |
| `Window:Unload()` | None | Cleans up all connections and destroys GUI instances |

### Tab Methods

| Method | Parameters | Description |
|---|---|---|
| `Tab:CreateCard(title, column)` | `title: string, column: number` | Creates container card in column `1` (left) or `2` (right) |
| `Tab:CreateSection(title, column)` | `title: string, column: number` | Alias for `Tab:CreateCard` |

### Card Components

#### Toggle
```lua
local Toggle = Card:AddToggle(title, defaultValue, callback)
Toggle:Set(true)
local current = Toggle:Get()
```

#### Slider
```lua
local Slider = Card:AddSlider(title, min, max, default, step, suffix, callback)
Slider:Set(50)
local current = Slider:Get()
```

#### Dropdown
```lua
local Dropdown = Card:AddDropdown(title, options, default, callback)
Dropdown:Set("Option")
Dropdown:Refresh({ "New1", "New2" }, "New1")
local current = Dropdown:Get()
```

#### Keybind
```lua
local Keybind = Card:AddKeybind(title, defaultKey, callback)
Keybind:Set(Enum.KeyCode.F)
local current = Keybind:Get()
```

#### Textbox
```lua
local Textbox = Card:AddTextbox(title, placeholder, defaultText, callback)
Textbox:Set("Text")
local current = Textbox:Get()
```

#### ColorPicker
```lua
local ColorPicker = Card:AddColorPicker(title, defaultColor, callback)
ColorPicker:Set(Color3.fromRGB(255, 0, 0))
local current = ColorPicker:Get()
```

#### Button
```lua
local Button = Card:AddButton(title, buttonText, callback)
```

#### Informational Elements
```lua
local Label = Card:AddLabel("Informational text message")
Label:SetText("Updated text message")

local Paragraph = Card:AddParagraph("Header", "Descriptive content block")
Paragraph:SetTitle("New Header")
Paragraph:SetDesc("New description")

Card:AddDivider()
```

## License

This project is licensed under the [MIT License](LICENSE).
