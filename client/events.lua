local MenuID = Game.GenerateRandomIntInRange(1, 10000)

Events.Subscribe("scriptInit", function()
    local RocstarID = Player.GetRockstarID()
    Events.CallRemote("ivd_core:playerJoined", { RocstarID })
end)

Events.Subscribe("ivd_core:UpdatePlayerData", function(result)
    IVD.PlayerData = result
    IVD.Functions.SpawnPlayer(IVD.PlayerData.position)
end, true)

Events.Subscribe("ivd_core:PassPlayerRIDForJob", function(job, role)
    local RocstarID = Player.GetRockstarID()
    Chat.AddMessage('Your RID is: '..RocstarID)
    Events.CallRemote("ivd_core:Server:UpdatePlayerJob", { RocstarID, job, role })
end, true)

Events.Subscribe("ivd_core:Client:UpdatePlayerJob", function(job, role)
    IVD.PlayerData.Job = job
    IVD.PlayerData.Role = role
end, true)

Events.Subscribe("ivd_core:FirstPlayerData", function(result)
    IVD.PlayerData = result
    IVD.Functions.SpawnPlayer(IVD.PlayerData.position)
end, true)

Events.Subscribe("IVMenu_Setup_" .. MenuID, function() 
    IVMenu.ItemCore.menu_len = 0
    IVMenu.ItemCore.title = "INVENTORY"
    
    if IVMenu.ItemCore.menu_level == 0 then
        IVMenu.ItemCore.footer = "Main"
        IVMenu.ItemType.add_item("Cash: $"..IVD.PlayerData.money.cash)
        for key, value in pairs(IVD.PlayerData.Items) do
            IVMenu.ItemType.add_submenu(Shared.Items[key].lable..' x'..value)
        end
    end
end, true)

Events.Subscribe("scriptInit", function()
    Thread.Create(function()
        while true do 
            Thread.Pause(0)
            if Game.IsGameKeyboardKeyJustPressed(60) then
                Events.Call("Open_IVMenu", {MenuID})
            end 
        end
    end)
end)

Events.Subscribe("sessionInit", function()
    Text.SetLoadingText("Loading Your RolePlay Expiriance...")
end)
