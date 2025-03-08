Thread.Create(function()
    while true do
        Thread.Pause(60000)
        local RocstarID = Player.GetRockstarID()
        local PlayerChar = Game.GetPlayerChar(Game.GetPlayerId())
        local x, y, z = Game.GetCharCoordinates(PlayerChar)
        local heading = Game.GetCharHeading(PlayerChar)
        IVD.PlayerData.position.x = tostring(x)
        IVD.PlayerData.position.y = tostring(y)
        IVD.PlayerData.position.z = tostring(z)
        IVD.PlayerData.position.h = tostring(heading)
        IVD.PlayerData.Health.health = Game.GetCharHealth(PlayerChar)
        IVD.PlayerData.Health.armour = Game.GetCharArmour(PlayerChar)
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

-- Automatic Payments
Thread.Create(function()
    while true do
        Thread.Pause(3600000)
        IVD.Functions.AddMoney('bank', Shared.Jobs[IVD.PlayerData.Job].grades[IVD.PlayerData.Grade].payment)
    end
end)