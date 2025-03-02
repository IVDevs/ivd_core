Events.Subscribe("ivd_core:playerJoined", function(RocstarID)
    local IsAdmin = IVD.Functions.IsPlayerAdmin(RocstarID)
    if Config.Server.ClosedServer and not IsAdmin then
        IVD.Functions.DebugMode('[DEBUG] Kicking player...')
        Player.Kick(Events.GetSource())
    else
        local source = Events.GetSource()
        local result = MySQL.Select("SELECT * FROM players WHERE RockstarID = ?", { RocstarID })
        if #result > 0 then
            IVD.Functions.DebugMode('[DEBUG] Player just joined')
            result[1].position = IVD.JSON.Decode(result[1].position)
            result[1].money = IVD.JSON.Decode(result[1].money)
            result[1].Items = IVD.JSON.Decode(result[1].Items)
            Events.CallRemote("ivd_core:UpdatePlayerData", source, { result[1] })
        else
            IVD.Functions.DebugMode('[DEBUG] Its First time player is playing on server')
            MySQL.Insert("INSERT INTO players (RockstarID, money, Items, position) VALUES (?,?,?,?)", { RocstarID, tostring(IVD.JSON.Encode(Config.NewCharacterSettings.Starting_Cash)), tostring(IVD.JSON.Encode(Config.NewCharacterSettings.Starting_Items)), tostring(IVD.JSON.Encode(Config.NewCharacterSettings.Starting_Position)) }, function(data)
                local result = MySQL.Select("SELECT * FROM players WHERE RockstarID = ?", { RocstarID })
                result[1].position = IVD.JSON.Decode(result[1].position)
                result[1].money = IVD.JSON.Decode(result[1].money)
                result[1].Items = IVD.JSON.Decode(result[1].Items)
                Events.CallRemote("ivd_core:FirstPlayerData", source, { result[1] })
                Events.CallRemote("ivd_identity:showRegisterIdentity", source, { })
            end)
        end
    end
end, true)

Events.Subscribe("ivd_core:playerSpawned", function()

end, true)

Events.Subscribe("ivd_core:UpdatePlayerServerData", function(RocstarID, PlayerData)
    IVD.Functions.DebugMode('[DEBUG] Updating player data...')
    local source = Events.GetSource()
    MySQL.Execute("UPDATE players SET position=?, money=?, Items=? WHERE RockstarID=?", { IVD.JSON.Encode(PlayerData.position), IVD.JSON.Encode(PlayerData.money), IVD.JSON.Encode(PlayerData.Items), RocstarID }, function(affectedRows)
       --Do some here when updated
    end)
end, true)