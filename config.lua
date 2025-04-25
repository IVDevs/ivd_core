Config = {}
Config.Server = {}

Config.Server.ClosedServer = false -- Permission based server lock only people who are in Config.Permissions will not get kicked
Config.Server.DebugMode = false -- Will log everything in console
Config.Hospital = {
    x = -1349.45,
    y = 1271.51,
    z = 23.38,
    h = 306.78	
}

Config.Permissions = {
    Mods = {  }, -- List of Mod Rockstar IDs
    Admins = {  }, -- List of Admin Rockstar IDs
    Owners = { '112830746' }, -- God (highest permission)
}

Config.NewCharacterSettings = {
    Starting_Items = {
        phone = 1,
        water = 5,
        hamburger = 4
    },
    Starting_Position = {
        x = -222.98,
        y = 430.16,
        z = 14.82,
        h = 122.23	
    },
    Starting_Cash = {
        bank = 1000,
        cash = 500,
        black_money = 50
    }
}