local QBCore = exports['qb-core']:GetCoreObject()

-- Save Settings
RegisterNetEvent('Vx-hud:saveSettings', function(settings)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local identifier = Player.PlayerData.citizenid
        MySQL.Async.execute([[
            INSERT INTO yos_hud_settings (identifier, settings) 
            VALUES (@identifier, @settings) 
            ON DUPLICATE KEY UPDATE settings = @settings
        ]], {
            ['@identifier'] = identifier,
            ['@settings'] = json.encode(settings)
        })
    end
end)

-- Get Settings
QBCore.Functions.CreateCallback('Vx-hud:getSettings', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        local identifier = Player.PlayerData.citizenid
        MySQL.Async.fetchAll([[
            SELECT settings FROM yos_hud_settings WHERE identifier = @identifier
        ]], {
            ['@identifier'] = identifier
        }, function(result)
            if result[1] then
                cb(json.decode(result[1].settings))
            else
                cb(nil)
            end
        end)
    else
        cb(nil)
    end
end)

-- Create Table
MySQL.ready(function()
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS `yos_hud_settings` (
            `id` INT(11) NOT NULL AUTO_INCREMENT,
            `identifier` VARCHAR(50) NOT NULL,
            `settings` LONGTEXT NOT NULL,
            PRIMARY KEY (`id`),
            UNIQUE KEY `identifier` (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    print('^2[Vx-hud]^7 Started successfully!')
end)
