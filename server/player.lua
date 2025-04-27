Events.Subscribe("ivd_core:playerJoined", function(RocstarID)
    local IsAdmin = IVD.Functions.IsPlayerAdmin(RocstarID)
    local source = Events.GetSource()

    if Config.Server.ClosedServer and not IsAdmin then
        IVD.Functions.DebugMode('[DEBUG] Kicking player...')
        Player.Kick(source)
        return
    end

    -- First, check if player exists
    MySQL.Select("SELECT * FROM players WHERE RockstarID = ?", { RocstarID }, function(result)
        if result and #result > 0 then
            -- Player exists
            IVD.Functions.DebugMode('[DEBUG] Player just joined')
            local playerData = result[1]
            playerData.position = IVD.JSON.Decode(playerData.position)
            playerData.money = IVD.JSON.Decode(playerData.money)
            playerData.Items = IVD.JSON.Decode(playerData.Items)
            playerData.Weapons = IVD.JSON.Decode(playerData.Weapons)
            playerData.Health = IVD.JSON.Decode(playerData.Health)

            Events.CallRemote("ivd_core:UpdatePlayerData", source, { playerData })
            Events.CallRemote("ivd_identity:notNewPlayer", source, { })
        else
            -- First time player
            IVD.Functions.DebugMode('[DEBUG] It`s first time player is playing on server')
            local moneyJson = tostring(IVD.JSON.Encode(Config.NewCharacterSettings.Starting_Cash))
            local itemsJson = tostring(IVD.JSON.Encode(Config.NewCharacterSettings.Starting_Items))
            local positionJson = tostring(IVD.JSON.Encode(Config.NewCharacterSettings.Starting_Position))

            MySQL.Insert("INSERT INTO players (RockstarID, money, Items, position) VALUES (?,?,?,?)", { RocstarID, moneyJson, itemsJson, positionJson }, function(insertResult)
                -- After inserting, fetch again
                MySQL.Select("SELECT * FROM players WHERE RockstarID = ?", { RocstarID }, function(newResult)
                    if newResult and #newResult > 0 then
                        local newPlayerData = newResult[1]
                        newPlayerData.position = IVD.JSON.Decode(newPlayerData.position)
                        newPlayerData.money = IVD.JSON.Decode(newPlayerData.money)
                        newPlayerData.Items = IVD.JSON.Decode(newPlayerData.Items)
                        newPlayerData.Weapons = IVD.JSON.Decode(newPlayerData.Weapons)
                        newPlayerData.Health = IVD.JSON.Decode(newPlayerData.Health)

                        Events.CallRemote("ivd_core:FirstPlayerData", source, { newPlayerData })
                        Events.CallRemote("ivd_identity:showRegisterIdentity", source, { })
                    else
                        IVD.Functions.DebugMode('[DEBUG] Failed to fetch newly created player')
                    end
                end)
            end)
        end
    end)
end, true)

Events.Subscribe("ivd_core:playerSpawned", function()
    -- empty handler
end, true)

Events.Subscribe("ivd_core:UpdatePlayerServerData", function(RocstarID, PlayerData)
    IVD.Functions.DebugMode('[DEBUG] Updating player data...')
    local source = Events.GetSource()

    local positionJson = IVD.JSON.Encode(PlayerData.position)
    local moneyJson = IVD.JSON.Encode(PlayerData.money)
    local itemsJson = IVD.JSON.Encode(PlayerData.Items)
    local weaponsJson = IVD.JSON.Encode(PlayerData.Weapons)
    local healthJson = IVD.JSON.Encode(PlayerData.Health)

    MySQL.Execute("UPDATE players SET position=?, money=?, Items=?, Weapons=?, Health=? WHERE RockstarID=?", {
        positionJson, moneyJson, itemsJson, weaponsJson, healthJson, RocstarID
    }, function(affectedRows)
        -- Updated
    end)
end, true)