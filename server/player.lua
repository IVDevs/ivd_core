Events.Subscribe("ivd_core:playerJoined", function(RocstarID)
    local source = Events.GetSource()
    local result = MySQL.Select("SELECT * FROM players WHERE RockstarID = ?", { RocstarID })
    if #result > 0 then
        result[1].position = IVD.JSON.Decode(result[1].position)
        result[1].money = IVD.JSON.Decode(result[1].money)
        Events.CallRemote("ivd_core:UpdatePlayerData", source, { result[1] })
    else
        MySQL.Insert("INSERT INTO players (RockstarID) VALUES (?)", { RocstarID }, function(data)
            local result = MySQL.Select("SELECT * FROM players WHERE RockstarID = ?", { RocstarID })
            result[1].position = IVD.JSON.Decode(result[1].position)
            result[1].money = IVD.JSON.Decode(result[1].money)
            Events.CallRemote("ivd_core:FirstPlayerData", source, { result[1] })
            Events.CallRemote("ivd_identity:showRegisterIdentity", source, { })
        end)
    end
end, true)

Events.Subscribe("ivd_core:playerSpawned", function()

end, true)

Events.Subscribe("ivd_core:UpdatePlayerServerData", function(RocstarID, PlayerData)
    local source = Events.GetSource()
    MySQL.Execute("UPDATE players SET position=?, money=? WHERE RockstarID=?", { IVD.JSON.Encode(PlayerData.position), IVD.JSON.Encode(PlayerData.money), RocstarID }, function(affectedRows)
       --Do some here when updated
    end)
end, true)