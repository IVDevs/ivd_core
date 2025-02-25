IVD.JSON = {}

function IVD.JSON.Decode(json)
    -- Remove leading/trailing spaces
    json = json:match("^%s*(.-)%s*$")

    -- Check if it's a number
    if json:match("^%-?%d+%.?%d*$") then
        return tonumber(json)
    
    -- Check if it's a boolean
    elseif json == "true" then
        return true
    elseif json == "false" then
        return false

    -- Check if it's null
    elseif json == "null" then
        return nil

    -- Check if it's a string
    elseif json:match('^".*"$') then
        return json:sub(2, -2)  -- Remove surrounding quotes

    -- Check if it's an array
    elseif json:match("^%[.*%]$") then
        local arr = {}
        local content = json:sub(2, -2)  -- Remove brackets
        for value in content:gmatch('[^,]+') do
            table.insert(arr, IVD.JSON.Decode(value))  -- Recursively decode elements
        end
        return arr

    -- Check if it's an object
    elseif json:match("^%{.*%}$") then
        local obj = {}
        local content = json:sub(2, -2)  -- Remove curly braces
        for key, value in content:gmatch('"([^"]+)":%s*([^,]+)') do
            obj[key] = IVD.JSON.Decode(value)  -- Recursively decode key-value pairs
        end
        return obj
    end

    -- If the format is invalid
    error("Invalid JSON format: " .. tostring(json))
end

function IVD.JSON.Encode(value)
    local function escape_str(s)
        return '"' .. s:gsub('"', '\\"'):gsub('\n', '\\n'):gsub('\r', '\\r') .. '"'
    end

    if type(value) == "nil" then
        return "null"
    elseif type(value) == "boolean" then
        return value and "true" or "false"
    elseif type(value) == "number" then
        return tostring(value)  -- directly return the number as a string representation of the number
    elseif type(value) == "string" then
        return escape_str(value)
    elseif type(value) == "table" then
        local is_array = true
        local index = 1
        for k, _ in pairs(value) do
            if k ~= index then
                is_array = false
                break
            end
            index = index + 1
        end

        local result = {}
        if is_array then
            for _, v in ipairs(value) do
                table.insert(result, IVD.JSON.Encode(v))
            end
            return "[" .. table.concat(result, ",") .. "]"
        else
            for k, v in pairs(value) do
                -- Ensure numbers are encoded as numbers, not strings
                if type(v) == "number" then
                    table.insert(result, escape_str(tostring(k)) .. ":" .. tostring(v))
                else
                    table.insert(result, escape_str(tostring(k)) .. ":" .. IVD.JSON.Encode(v))
                end
            end
            return "{" .. table.concat(result, ",") .. "}"
        end
    else
        error("Unsupported data type: " .. type(value))
    end
end

