Thread.Create(function()
    while true do
        Thread.Pause(60000)
        local RocstarID = Player.GetRockstarID()
        local x, y, z = Game.GetCharCoordinates(Game.GetPlayerChar(Game.GetPlayerId()))
        local heading = Game.GetCharHeading(Game.GetPlayerChar(Game.GetPlayerId()))
        IVD.PlayerData.position.x = tostring(x)
        IVD.PlayerData.position.y = tostring(y)
        IVD.PlayerData.position.z = tostring(z)
        IVD.PlayerData.position.h = tostring(heading)
        Events.CallRemote("ivd_core:UpdatePlayerServerData", { RocstarID, IVD.PlayerData })
    end
end)

Thread.Create(function()
    while true do
        Thread.Pause(0)
        if IVD.DrawHelper.State == true then
            Game.DrawFrontendHelperText("", "FrameworkHelper", false)
        end

        local playerId = Game.GetPlayerId();
        if Game.IsWantedLevelGreater(playerId, 0) then
            Game.ClearWantedLevel(playerId)
            Game.AlterWantedLevel(playerId, 0)
            Game.ApplyWantedLevelChangeNow(playerId)
        end
    end
end)