IVD = {}

-- MYSQL LOGIN --
MySQL.Connect("IP", 33060, "LOGIN", "PASSWORD", "DATABASE")

function GetCoreObject()
    return IVD
end