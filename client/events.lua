local MenuID = Game.GenerateRandomIntInRange(1, 10000)

Events.Subscribe("scriptInit", function()
    local RocstarID = Player.GetRockstarID()
    Events.CallRemote("ivd_core:playerJoined", { RocstarID })
end)

Events.Subscribe("ivd_core:UpdatePlayerData", function(result)
    IVD.PlayerData = result
    IVD.Functions.SpawnPlayer(IVD.PlayerData.position)
end, true)

Events.Subscribe("ivd_core:PassPlayerRIDForJob", function(job, grade)
    local RocstarID = Player.GetRockstarID()
    Events.CallRemote("ivd_core:Server:UpdatePlayerJob", { RocstarID, job, grade })
end, true)

Events.Subscribe("ivd_core:Client:UpdatePlayerJob", function(job, grade)
    IVD.PlayerData.Job = job
    IVD.PlayerData.Grade = grade
end, true)

Events.Subscribe("ivd_core:FirstPlayerData", function(result)
    IVD.PlayerData = result
    IVD.Functions.SpawnPlayer(IVD.PlayerData.position)
end, true)

Events.Subscribe("IVMenu_Setup_" .. MenuID, function() 
    IVMenu.ItemCore.menu_len = 0

    if IVMenu.ItemCore.menu_level == 0 then
        IVMenu.ItemCore.title = "INVENTORY"
        IVMenu.ItemCore.footer = "Main"
        IVMenu.ItemType.add_item("------------- MONEY -------------")
        IVMenu.ItemType.add_item("Cash: $" .. IVD.PlayerData.money.cash)
        if IVD.PlayerData.money.black_money > 0 then
            IVMenu.ItemType.add_item("Black Money: $" .. IVD.PlayerData.money.black_money)
        end
        IVMenu.ItemType.add_item("------------- ITEMS -------------")
        for key, value in pairs(IVD.PlayerData.Items) do
            IVMenu.ItemType.add_submenu(Shared.Items[key].lable .. ' x' .. value)
        end
        
        if next(IVD.PlayerData.Weapons) then
            IVMenu.ItemType.add_item("------------- WEAPONS -------------")
            local weaponCounts = {}
        
            for weaponKey, weaponDataList in pairs(IVD.PlayerData.Weapons) do
                if type(weaponDataList) == "table" then
                    for _, weaponData in ipairs(weaponDataList) do
                        if weaponData.AMMO ~= nil then  -- Ensure AMMO key exists
                            local ammoCount = (weaponData.AMMO == -1) and "INFINITY" or weaponData.AMMO
        
                            if not weaponCounts[weaponKey] then
                                weaponCounts[weaponKey] = {}
                            end
                            table.insert(weaponCounts[weaponKey], ammoCount)
                        else
                            Chat.AddMessage("Warning: Missing AMMO key in weaponData "..weaponData) -- Debugging log
                        end
                    end
                else
                    Chat.AddMessage("Warning: Invalid weapon data structure for key: " .. tostring(weaponKey))
                end
            end
        
            for weaponKey, ammoList in pairs(weaponCounts) do
                local weaponName = Shared.Weapons[weaponKey] and Shared.Weapons[weaponKey].lable or "Unknown Weapon"
                local weaponCount = #ammoList
        
                for _, ammo in ipairs(ammoList) do
                    IVMenu.ItemType.add_submenu(weaponName .. " x" .. weaponCount .. " (" .. ammo .. ")")
                end
            end
        end        
    elseif IVMenu.ItemCore.menu_level == 3 then
        --Here give item stuff
    else
        local selectedItem = IVMenu.ItemCore.last_text 
        local selectedItem2 = selectedItem:gsub("%s*x%d+$", "")

        for key, data in pairs(Shared.Items) do
            if data.lable == selectedItem2 then
                selectedItem2 = key
                break
            end
        end

        -- Convert first letter to lowercase (optional but safe)
        selectedItem2 = selectedItem2:sub(1,1):lower() .. selectedItem2:sub(2)

        IVMenu.ItemCore.title = tostring(selectedItem)
        IVMenu.ItemCore.footer = "Item"

        if IVD.Functions.UsableItems[selectedItem2] then
            IVMenu.ItemType.add_item('Use')
        end

        IVMenu.ItemType.add_submenu('Give') -- Find a way to Setup player list and give
        IVMenu.ItemType.add_item('Drop')
    end
end, true)

Events.Subscribe("IVMenu_function_" .. MenuID, function(I)   
    if (IVMenu.ItemCore.menu_level == 1) then
        local itemName = IVMenu.ItemCore.last_text:gsub("%s*[xX]%d+$", "")

        local selectedItem = nil
        for key, data in pairs(Shared.Items) do
            if data.lable == itemName then
                selectedItem = key
                break
            end
        end

        selectedItem = selectedItem or (itemName:sub(1,1):lower() .. itemName:sub(2))

        if (I == 1) and IVD.Functions.UsableItems[selectedItem] then
            IVD.Functions.UsableItems[selectedItem]()
        elseif (I == 2) then
            local newQuant = IVD.PlayerData.Items[selectedItem]-1
            IVMenu.ItemCore.title = tostring(selectedItem..' x'..newQuant)
            IVD.Functions.RemoveItem(selectedItem, '1')
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
    Text.SetLoadingText("Your game might have longer loading time...")
end)

Events.Subscribe("scriptInit", function()
    Thread.Create(function()
        while true do
            local playerId = Game.GetPlayerId()

            if Game.IsNetworkPlayerActive(playerId) then
                if Game.HowLongHasNetworkPlayerBeenDeadFor(playerId) > 2000 and Resource.GetState('ivd_ambulancejob') == 'unknown' then
                    IVD.Functions.SpawnPlayer(Config.Hospital)
                end
            end

            Thread.Pause(0)
        end
    end)
end)