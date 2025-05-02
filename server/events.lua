Events.Subscribe("ivd_core:Server:UpdatePlayerJob", function(RocstarID, Job, grade)
    local source = Events.GetSource()
    IVD.Functions.DebugMode('[DEBUG] Updated Platyer Job')
    MySQL.Execute("UPDATE players SET Job=?, Grade=? WHERE RockstarID=?", { Job, grade, RocstarID }, function(affectedRows)
        Events.CallRemote("ivd_core:Client:UpdatePlayerJob", source, { job, grade })
    end)
end, true)

Events.Subscribe("ivd_core:Server:JobCommand", function(id, job, grade)
    local source = Events.GetSource()
    IVD.Functions.DebugMode('[DEBUG] Job command has been ran')
    Events.CallRemote("ivd_core:PassPlayerRIDForJob", id, { job, grade })
end, true)

Events.Subscribe("ivd_core:PlayerPing", function()
    local source = Events.GetSource()

    Chat.SendMessage(source, "Your ping is: {0000FF}" .. Player.GetPing(source))
end, true)