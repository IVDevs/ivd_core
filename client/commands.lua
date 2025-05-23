--Used for IVD.Commands.Add
Events.Subscribe("chatCommand", function(fullcommand)
    local command = stringsplit(fullcommand, " ")
    local commandName = command[1]
    local player = Game.GetPlayerId() -- Get the calling player

    -- Check if command exists in registered commands
    if IVD.CommandHandlers[commandName] then
        local handler = IVD.CommandHandlers[commandName]

        -- Check permission
        if not IVD.Functions.HasPermission(player, handler.permissionLevel) then
            return Chat.AddMessage("Error: You do not have permission to use this command.")
        end

        -- If arguments are required but not provided
        if handler.argsRequired and #command < 2 then
            Chat.AddMessage("Usage: " .. handler.helpText)
        else
            -- Execute the command function with player and arguments
            handler.callback(player, command)
        end
    else
        Chat.AddMessage("Error: Unknown command")
    end
end)

-- Helper function to split strings
function stringsplit(inputstr, sep)
    if sep == nil then sep = "%s" end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

-- Commands
IVD.Commands.Add("/car", function(player, args)
    local model = Game.GetHashKey(args[2])
    local x, y, z = Game.GetCharCoordinates(Game.GetPlayerChar(Game.GetPlayerId()))
    local heading = Game.GetCharHeading(Game.GetPlayerChar(Game.GetPlayerId()))
    IVD.Functions.LoadModel(model)
    local car = Game.CreateCar(model, x, y, z, true)
    Game.SetCarHeading(car, heading)
    Game.SetCarOnGroundProperly(car)
    Game.WarpCharIntoCar(Game.GetPlayerChar(Game.GetPlayerId()), car)
    Game.MarkModelAsNoLongerNeeded(model)
    Game.MarkCarAsNoLongerNeeded(car)
end, true, "/car [car_model]", "admin")

IVD.Commands.Add("/dv", function(player, args)
    IVD.Functions.DeleteVehicle(Game.GetCarCharIsUsing(Game.GetPlayerChar(Game.GetPlayerId())))
end, false, "/dv", "admin")

IVD.Commands.Add("/weather", function(player, args)
    Game.ForceWeatherNow(tonumber(args[2]))
    Chat.AddMessage("Changed weather to " .. IVD.Functions.WeatherName(tonumber(args[2])))
end, true, "/weather [WEATHER_TYPE]", "mod")

IVD.Commands.Add("/fix", function(player, args)
    local playerId = Game.GetPlayerId()
    local playerChar = Game.GetPlayerChar(playerId)
    if Game.IsCharInAnyCar(playerChar) then
        local playerCar = Game.GetCarCharIsUsing(playerChar)
        Game.FixCar(playerCar)
        Chat.AddMessage("Vehicle repaired")
    end
end, false, "/fix", "mod")

IVD.Commands.Add("/time", function(player, args)
    Game.ForwardToTimeOfDay(tonumber(args[2]), tonumber(args[3]))
end, true, "/time [hours] [minutes]", "mod")

IVD.Commands.Add("/coords", function(player, args)
    local x, y, z = Game.GetCharCoordinates(Game.GetPlayerChar(Game.GetPlayerId()))
    local heading = Game.GetCharHeading(Game.GetPlayerChar(Game.GetPlayerId()))
    Chat.AddMessage(x..' '..y..' '..z..' '..heading)
end, false, "/coords", "admin")

IVD.Commands.Add("/setjob", function(player, args)
    local PlayerID = Player.GetServerID(tonumber(args[2]) - 1)
    local Job = args[3]
    local Job_Grade = args[4]
    if Shared.Jobs[Job] then
        if Shared.Jobs[Job].grades[Job_Grade] then
            Chat.AddMessage('You have set job: '..Shared.Jobs[Job].label..' for ID: '..PlayerID)
            Events.CallRemote('ivd_core:Server:JobCommand', { PlayerID, Job, Job_Grade })
        else
            Chat.AddMessage('This job grade is not valid')
        end
    else
        Chat.AddMessage('This job is not valid')
    end
end, true, "/setjob [id] [job] [grade]", "mod")

IVD.Commands.Add("/ping", function(player, args)
    Events.CallRemote('ivd_core:PlayerPing', {})
end, false, "/ping")