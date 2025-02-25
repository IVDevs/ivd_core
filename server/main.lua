IVD = {}

-- MYSQL LOGIN --
MySQL.Connect("IP", 33060, "DATABASE", "PASSWORD", "DATABASE")

function GetCoreObject()
    return IVD
end