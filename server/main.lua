IVD = {}

-- MYSQL LOGIN --
Database.Connect(0, "mysqlx://user:password@host:port/database")

function GetCoreObject()
    return IVD
end