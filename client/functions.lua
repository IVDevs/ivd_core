IVD.Commands = {}
IVD.Functions = {}
IVD.CommandHandlers = {}
IVD.SpawnLock = false
IVD.DrawHelper = {}
IVD.Functions.UsableItems = {}
local PlayerSpawned = false

function IVD.Functions.LoadModel(model)
    if Game.HasModelLoaded(model) then return end
    Game.RequestModel(model)
    while not Game.HasModelLoaded(model) do
        Thread.Pause(0)
    end
end

function IVD.Functions.DeleteVehicle(vehicle)
    Game.DeleteCar(vehicle)
end

function IVD.Functions.GetTime()
    local h, m = Game.GetTimeOfDay()
    return h, m
end

function IVD.Functions.GetPlayerPermissionLevel(player)
    local playerID = tostring(Player.GetRockstarID(player))

    for _, ownerID in ipairs(Config.Permissions.Owners) do
        if playerID == tostring(ownerID) then
            return "god"
        end
    end

    for _, adminID in ipairs(Config.Permissions.Admins) do
        if playerID == tostring(adminID) then
            return "admin"
        end
    end

    for _, modID in ipairs(Config.Permissions.Mods) do
        if playerID == tostring(modID) then
            return "mod"
        end
    end

    return "user"
end

function IVD.Functions.HasPermission(player, requiredLevel)
    local levels = { user = 0, mod = 1, admin = 2, god = 3 }
    local playerLevel = IVD.Functions.GetPlayerPermissionLevel(player)

    return levels[playerLevel] >= levels[requiredLevel]
end

function IVD.Commands.Add(name, callback, argsRequired, helpText, permissionLevel)
    IVD.CommandHandlers[name] = {
        callback = callback,
        argsRequired = argsRequired or false,
        helpText = helpText or "No description provided.",
        permissionLevel = permissionLevel or "user" -- Default to public command
    }
end

function IVD.Functions.FreezePlayer(id, freeze)
	local playerIndex = Game.ConvertIntToPlayerindex(id)
	Game.SetPlayerControlForNetwork(playerIndex, not freeze, false)

	local playerChar = Game.GetPlayerChar(playerIndex)
	Game.SetCharVisible(playerChar, not freeze)

	if not freeze then
		if not Game.IsCharInAnyCar(playerChar) then
			Game.SetCharCollision(playerChar, true)
		end

		Game.FreezeCharPosition(playerChar, false)
		Game.SetCharNeverTargetted(playerChar, false)
		Game.SetPlayerInvincible(playerIndex, false)
	else
		Game.SetCharCollision(playerChar, false)
		Game.FreezeCharPosition(playerChar, true)
		Game.SetCharNeverTargetted(playerChar, true)
		Game.SetPlayerInvincible(playerIndex, true)
		Game.RemovePtfxFromPed(playerChar)

		if not Game.IsCharFatallyInjured(playerChar) then
			Game.ClearCharTasksImmediately(playerChar)
		end
	end
end

function IVD.Functions.GivePlayerAllWeapons(charIndex)
    local givenWeapons = {}  -- Track given weapons
    
    for weaponKey, weaponDataList in pairs(IVD.PlayerData.Weapons) do
        if type(weaponDataList) == "table" then
            for _, weaponData in ipairs(weaponDataList) do
                if weaponData.AMMO ~= nil then
                    local ammoCount = (weaponData.AMMO == -1) and 0 or weaponData.AMMO -- Give large ammo if unlimited
                    
                    -- Ensure only one of each weapon type is given
                    if not givenWeapons[weaponKey] then
                        givenWeapons[weaponKey] = true
                        
                        Game.GiveWeaponToChar(charIndex, tonumber(Shared.Weapons[weaponKey].id), ammoCount, false)
                    else
                        Chat.AddMessage("Skipping duplicate weapon: " .. weaponKey)
                    end
                else
                    Chat.AddMessage("Warning: Missing AMMO key in weaponData for " .. tostring(weaponKey))
                end
            end
        else
            Chat.AddMessage("Warning: Invalid weapon data structure for key: " .. tostring(weaponKey))
        end
    end
end

function IVD.Functions.SpawnPlayer(coords)
    if IVD.SpawnLock then
        return
    end
    IVD.SpawnLock = true
    if not Game.IsScreenFadedOut() then
        Game.DoScreenFadeOut(500)
        while Game.IsScreenFadingOut() do
            Thread.Pause(0)
        end
    end

    local spawnModel = Game.GetHashKey('M_Y_MULTIPLAYER')
    if not Game.IsModelInCdimage(spawnModel) then
        Console.Log("spawnPlayer: invalid spawn model")
        return
    end

    local playerId = Game.GetPlayerId()
    local playerChar = Game.GetPlayerChar(playerId)
    IVD.Functions.FreezePlayer(playerId, true)

    if not Game.IsCharModel(playerChar, spawnModel) then
        Game.RequestModel(spawnModel)
        Game.LoadAllObjectsNow()

        while not Game.HasModelLoaded(spawnModel) do
            Game.RequestModel(spawnModel)

            Thread.Pause(0)
        end

        Game.ChangePlayerModel(playerId, spawnModel)
        Game.MarkModelAsNoLongerNeeded(spawnModel)

        playerChar = Game.GetPlayerChar(playerId)
    end

    Game.SetNoResprays(true)
    Game.RequestCollisionAtPosn(tonumber(coords.x), tonumber(coords.y), tonumber(coords.z))
    Game.ResurrectNetworkPlayer(playerId, tonumber(coords.x), tonumber(coords.y), tonumber(coords.z), tonumber(coords.h))
    Game.ClearCharTasksImmediately(playerChar)
    Game.RemoveAllCharWeapons(playerChar)
    Game.SetPoliceIgnorePlayer(playerId, true)
    Game.SetDeadPedsDropWeapons(false)
    Game.SetMoneyCarriedByAllNewPeds(0)
    Game.CamRestoreJumpcut()
    Game.ForceLoadingScreen(false)
    Game.DoScreenFadeIn(500)
    IVD.Functions.FreezePlayer(playerId, false)
    Events.Call("playerSpawn", {})

    if not PlayerSpawned then
        Game.SetCharHealth(playerChar, IVD.PlayerData.Health.health);
        Game.AddArmourToChar(playerChar, IVD.PlayerData.Health.armour);
        IVD.Functions.GivePlayerAllWeapons(playerChar)
        Events.Call("ivd_core:playerSpawned", {})
        PlayerSpawned = true
    end

    IVD.SpawnLock = false
end

function IVD.Functions.WeatherName(id)
    if id == 0 then return "Extra sunny"
    elseif id == 1 then return "Sunny"
    elseif id == 2 then return "Sunny and windy"
    elseif id == 3 then return "Cloudy"
    elseif id == 4 then return "Raining"
    elseif id == 5 then return "Drizzle"
    elseif id == 6 then return "Foggy"
    elseif id == 7 then return "Thunderstorm"
    elseif id == 8 then return "Extra sunny 2"
    elseif id == 9 then return "Sunny and windy 2"
    else return "Unknown"
    end
end

function IVD.DrawHelper.ShowHelper(text)
    IVD.DrawHelper.State = true
    Text.AddEntry("FrameworkHelper", text)
end

function IVD.DrawHelper.HideHelper()
    IVD.DrawHelper.State = false
end

function IVD.Functions.Debug(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
           if type(k) ~= 'number' then k = '"'..k..'"' end
           s = s .. '['..k..'] = ' .. IVD.Functions.Debug(v) .. ','
        end
        return s .. '} '
     else
        return tostring(o)
     end
end

function IVD.Functions.RegisterUsableItem(itemName, callback)
    IVD.Functions.UsableItems[itemName] = callback
end

function IVD.Functions.AddItem(itemName, quantity)
    IVD.DrawHelper.ShowHelper('+'..quantity..' '..itemName)
    if IVD.PlayerData.Items[itemName] then
        IVD.PlayerData.Items[itemName] = IVD.PlayerData.Items[itemName] + quantity
    else
        IVD.PlayerData.Items[itemName] = quantity
    end
    IVD.DrawHelper.HideHelper()
end

function IVD.Functions.RemoveItem(itemName, quantity)
    IVD.DrawHelper.ShowHelper('-'..quantity..' '..itemName)
    if IVD.PlayerData.Items[itemName] then
        IVD.PlayerData.Items[itemName] = IVD.PlayerData.Items[itemName] - quantity
        if IVD.PlayerData.Items[itemName] <= 0 then
            IVD.PlayerData.Items[itemName] = nil
        end
    end
    IVD.DrawHelper.HideHelper()
end

function IVD.Functions.AddMoney(type, amount)
    if IVD.PlayerData.money[type] then
        IVD.PlayerData.money[type] = IVD.PlayerData.money[type] + amount
        IVD.DrawHelper.ShowHelper('+'..amount..' '..type)
    else
        Chat.AddMessage('Invalid money type')
    end
    IVD.DrawHelper.HideHelper()
end

function IVD.Functions.RemoveMoney(type, amount)
    if IVD.PlayerData.money[type] then
        IVD.PlayerData.money[type] = IVD.PlayerData.money[type] - amount
        if IVD.PlayerData.money[type] < 0 then
            IVD.PlayerData.money[type] = 0
        end
        IVD.DrawHelper.ShowHelper('-'..amount..' '..type)
    else
        Chat.AddMessage('Invalid money type')
    end
    IVD.DrawHelper.HideHelper()
end
