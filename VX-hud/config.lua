Config = {}

--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║                      YOS HUD CONFIG                       ║
    ║               Modern Circular HUD for QBCore              ║
    ╚═══════════════════════════════════════════════════════════╝
]]

-- Default Position: 'left', 'center', or 'right'
Config.Position = 'left'

-- Default Colors (HEX format)
Config.Colors = {
    primary = '#4ade80',
    health = '#4ade80',
    armor = '#4ade80',
    hunger = '#4ade80',
    thirst = '#4ade80',
    fuel = '#4ade80',
    voiceNormal = '#fbbf24',  -- Yellow
    voiceRadio = '#22d3ee'    -- Cyan
}

-- Speedometer Settings
Config.Speedometer = {
    unit = 'kmh', -- 'kmh' or 'mph'
    maxSpeed = 300
}

-- Voice Range Settings (Z key to cycle)
-- 1 = Whisper, 2 = Normal, 3 = Shout
Config.VoiceRanges = {
    [1] = { range = 2.0, name = 'Whisper' },
    [2] = { range = 5.0, name = 'Normal' },
    [3] = { range = 10.0, name = 'Shout' }
}
Config.DefaultVoiceRange = 2

-- Opacity (0.0 - 1.0)
Config.Opacity = 0.95

-- Scale (0.5 - 1.5)
Config.Scale = 1.0

-- Hide Default HUD (health bar, armor bar on minimap)
Config.HideDefaultHud = true

-- Hide Minimap completely (false = keep minimap visible)
Config.HideMinimap = false

-- Open Settings Command
Config.OpenSettingsCommand = 'hud'

-- Fuel Script
Config.FuelScript = 'LegacyFuel' -- 'LegacyFuel', 'ox_fuel', 'ps-fuel'

-- Update Interval (milliseconds)
Config.UpdateInterval = 100

-- Voice Range Key (Z = 20)
Config.VoiceRangeKey = 20
