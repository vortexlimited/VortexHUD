local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local isLoggedIn = false
local inVehicle = false
local currentVehicle = nil
local isTalking = false
local isRadioTalking = false
local settingsOpen = false
local currentVoiceRange = Config.DefaultVoiceRange

local playerSettings = {
    position = Config.Position,
    colors = Config.Colors,
    opacity = Config.Opacity,
    scale = Config.Scale
}

-- Player Loaded
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    isLoggedIn = true
    Wait(1000)
    SendNUIMessage({
        action = 'show',
        settings = playerSettings
    })
    SendNUIMessage({
        action = 'updateVoiceRange',
        range = currentVoiceRange
    })
    loadPlayerSettings()
end)

-- Player Unloaded
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
    PlayerData = {}
    SendNUIMessage({ action = 'hide' })
end)

-- Update Player Data
RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)

-- Hide Default GTA HUD (Health, Armor bars on minimap) 
CreateThread(function()
    while true do
        Wait(0)
        
        -- Hide ALL default HUD elements
        for i = 1, 22 do
            HideHudComponentThisFrame(i)
        end
        
        -- Show minimap only when in vehicle
        if inVehicle then
            DisplayRadar(true)
        else
            DisplayRadar(false)
        end
    end
end)

-- Hide minimap health/armor/oxygen bars
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        -- Hide Player Ability bar
        SetAbilityBarVisibility(false)
        
        -- Hide health/armor around minimap (GTA Online style)
        N_0x6e0eb3eb47c8d7aa() -- _HUD_DISPLAY_LOADING_SCREEN_TIPS
    end
end)

-- Resource start - set minimap type
Citizen.CreateThread(function()
    Citizen.Wait(500)
    
    -- Request minimap without stats
    RequestStreamedTextureDict("circlemap", false)
    while not HasStreamedTextureDictLoaded("circlemap") do
        Citizen.Wait(100)
    end
    
    -- Minimap position/scale
    SetMinimapClipType(0)
end)

-- Get Fuel
function GetVehicleFuel(vehicle)
    local fuel = 0
    if Config.FuelScript == 'LegacyFuel' then
        if GetResourceState('LegacyFuel') == 'started' then
            fuel = exports['LegacyFuel']:GetFuel(vehicle)
        else
            fuel = GetVehicleFuelLevel(vehicle)
        end
    elseif Config.FuelScript == 'ox_fuel' then
        if GetResourceState('ox_fuel') == 'started' then
            fuel = exports['ox_fuel']:GetFuel(vehicle)
        else
            fuel = GetVehicleFuelLevel(vehicle)
        end
    elseif Config.FuelScript == 'ps-fuel' then
        if GetResourceState('ps-fuel') == 'started' then
            fuel = exports['ps-fuel']:GetFuel(vehicle)
        else
            fuel = GetVehicleFuelLevel(vehicle)
        end
    else
        fuel = GetVehicleFuelLevel(vehicle)
    end
    return fuel
end

-- Update HUD
CreateThread(function()
    while true do
        Wait(Config.UpdateInterval)
        if isLoggedIn then
            local ped = PlayerPedId()
            local health = GetEntityHealth(ped) - 100
            local maxHealth = GetEntityMaxHealth(ped) - 100
            local armor = GetPedArmour(ped)
            
            -- Stamina (Running) - only show when actually using stamina
            local stamina = GetPlayerStamina(PlayerId())
            local isRunning = IsPedRunning(ped) or IsPedSprinting(ped)
            local showStamina = isRunning and stamina < 100
            
            -- Oxygen (Underwater)
            local oxygen = GetPlayerUnderwaterTimeRemaining(PlayerId()) * 10
            local isUnderwater = IsPedSwimmingUnderWater(ped)
            
            local vehicleData = nil
            if inVehicle and currentVehicle then
                local speed = GetEntitySpeed(currentVehicle)
                if Config.Speedometer.unit == 'kmh' then
                    speed = speed * 3.6
                else
                    speed = speed * 2.236936
                end
                
                local rpm = GetVehicleCurrentRpm(currentVehicle)
                local fuel = GetVehicleFuel(currentVehicle)
                local gear = GetVehicleCurrentGear(currentVehicle)
                
                vehicleData = {
                    speed = math.floor(speed),
                    rpm = rpm,
                    fuel = math.floor(fuel),
                    gear = gear
                }
            end
            
            SendNUIMessage({
                action = 'update',
                health = math.floor((health / maxHealth) * 100),
                armor = armor,
                stamina = math.floor(stamina),
                showStamina = showStamina,
                oxygen = math.floor(oxygen),
                isUnderwater = isUnderwater,
                talking = isTalking,
                radioTalking = isRadioTalking,
                inVehicle = inVehicle,
                vehicle = vehicleData
            })
        end
    end
end)

-- Check Vehicle
CreateThread(function()
    while true do
        Wait(300)
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            if not inVehicle then
                inVehicle = true
                currentVehicle = GetVehiclePedIsIn(ped, false)
                SendNUIMessage({ action = 'enterVehicle' })
            end
        else
            if inVehicle then
                inVehicle = false
                currentVehicle = nil
                SendNUIMessage({ action = 'exitVehicle' })
            end
        end
    end
end)

-- Check Voice
CreateThread(function()
    while true do
        Wait(100)
        if isLoggedIn then
            isTalking = NetworkIsPlayerTalking(PlayerId())
        end
    end
end)

-- Voice Range Cycle (Z Key)
CreateThread(function()
    while true do
        Wait(0)
        if isLoggedIn and not settingsOpen then
            if IsControlJustPressed(0, Config.VoiceRangeKey) then
                currentVoiceRange = currentVoiceRange + 1
                if currentVoiceRange > 3 then
                    currentVoiceRange = 1
                end
                
                -- Update pma-voice proximity
                if GetResourceState('pma-voice') == 'started' then
                    exports['pma-voice']:setVoiceProperty('proximity', Config.VoiceRanges[currentVoiceRange].range)
                end
                
                -- Update HUD
                SendNUIMessage({
                    action = 'updateVoiceRange',
                    range = currentVoiceRange
                })
                
                -- Notification
                QBCore.Functions.Notify('Voice: ' .. Config.VoiceRanges[currentVoiceRange].name, 'primary', 1500)
            end
        else
            Wait(500)
        end
    end
end)

-- Radio
RegisterNetEvent('pma-voice:setTalkingOnRadio', function(state)
    isRadioTalking = state
end)

-- Settings Command
RegisterCommand(Config.OpenSettingsCommand, function()
    settingsOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openSettings',
        settings = playerSettings
    })
end, false)

-- Close Settings
RegisterNUICallback('closeSettings', function(data, cb)
    settingsOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Save Settings
RegisterNUICallback('saveSettings', function(data, cb)
    playerSettings = data.settings
    TriggerServerEvent('Vx-hud:saveSettings', playerSettings)
    SendNUIMessage({
        action = 'applySettings',
        settings = playerSettings
    })
    cb('ok')
end)

-- Load Player Settings
function loadPlayerSettings()
    QBCore.Functions.TriggerCallback('Vx-hud:getSettings', function(settings)
        if settings then
            playerSettings = settings
            SendNUIMessage({
                action = 'applySettings',
                settings = playerSettings
            })
        end
    end)
end

-- ESC to Close
CreateThread(function()
    while true do
        Wait(0)
        if settingsOpen then
            if IsControlJustPressed(0, 200) then
                settingsOpen = false
                SetNuiFocus(false, false)
                SendNUIMessage({ action = 'closeSettings' })
            end
        else
            Wait(500)
        end
    end
end)

-- On Resource Start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Wait(500)
        if QBCore.Functions.GetPlayerData().citizenid then
            isLoggedIn = true
            PlayerData = QBCore.Functions.GetPlayerData()
            SendNUIMessage({
                action = 'show',
                settings = playerSettings
            })
            SendNUIMessage({
                action = 'updateVoiceRange',
                range = currentVoiceRange
            })
        end
    end
end)
