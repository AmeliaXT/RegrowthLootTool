---@type Regrowth
local _, Regrowth = ...;

function Regrowth:empty(mixed)
    mixed = mixed or false;

    ---@type string
    local varType = type(mixed);

    if (varType == "boolean") then
        return not mixed;
    end

    if (varType == "string") then
        return strtrim(mixed) == "";
    end

    if (varType == "table") then
        for _, val in pairs(mixed) do
            if (val ~= nil) then
                return false;
            end
        end

        return true;
    end

    if (varType == "number") then
        return mixed == 0;
    end

    if (varType == "function"
        or varType == "CFunction"
        or varType == "userdata"
    ) then
        return false;
    end

    return true;
end

function Regrowth:getFullyQualifiedName(name, realm)
    realm = not self:empty(realm) and realm or nil;
    name = tostring(name);

    if (self:empty(name)) then
        return "";
    end

    local nameHasRealmSeparator = name:match("-");

    if (nameHasRealmSeparator) then
        return name;
    end

    realm = realm or Regrowth.User.realm;
    return ("%s-%s"):format(name, realm), realm;
end

function Regrowth:explode(s, delimiter)
    local Result = {};

    -- No delimiter is provided, split all characters
    if (not delimiter) then
        s:gsub(".",function(character) table.insert(Result, character); end);
        return Result;
    end

    for match in (s .. delimiter):gmatch("(.-)%" .. delimiter) do
        tinsert(Result, strtrim(match));
    end

    return Result;
end

function Regrowth:tableGet(Table, keyString, default)
    if (type(keyString) ~= "string"
        or self:empty(keyString)
    ) then
        return default;
    end

    local keys = Regrowth:explode(keyString, ".");
    local numberOfKeys = #keys;
    local firstKey = keys[1];

    if (not numberOfKeys or not firstKey) then
        return default;
    end

    if (type(Table) == "table") then
        if (type(Table[firstKey]) == "nil") then
            firstKey = tonumber(firstKey);

            -- Make sure we're not looking for a numeric key instead of a string
            if (not firstKey or type(Table[firstKey]) == "nil") then
                return default;
            end
        end

        Table = Table[firstKey];
    else
        return Table or default;
    end

    -- Changed if (#keys == 1) then to below, saved this just in case we get weird behavior
    if (numberOfKeys == 1) then
        default = nil;
        return Table;
    end

    tremove(keys, 1);
    return self:tableGet(Table, strjoin(".", unpack(keys)), default);
end

function Regrowth:iEquals(reference, control)
    if (type(reference) ~= "string"
        or type(control) ~= "string"
    ) then
        return false
    end

    return string.lower(strtrim(reference)) == string.lower(strtrim(control));
end

function Regrowth:isSelf(senderName, senderFqn)
    return Regrowth:iEquals(senderName, Regrowth.User.name)
        or Regrowth:iEquals(senderFqn, Regrowth.User.fqn);
end

function Regrowth:strStartsWith(str, startStr, insensitive)
    str = tostring(str);
    startStr = tostring(startStr);

    if (insensitive ~= false) then
        str = strlower(str);
        startStr = strlower(startStr);
    end

    return string.sub(str, 1, string.len(startStr)) == startStr;
end

function Regrowth:message(...)
    print("|TInterface/TARGETINGFRAME/UI-RaidTargetingIcon_3:12|t|cff8aecff RegrowthLootTool : |r" .. table.concat({ ... }, " "));
end

function Regrowth:coloredMessage(color, ...)
    Regrowth:message(string.format("|c00%s%s", color, string.join(" ", ...)));
end

function Regrowth:success(...)
    Regrowth:coloredMessage("92FF00", ...);
end

function Regrowth:warning(...)
    Regrowth:coloredMessage("F7922E", ...);
end

function Regrowth:error(...)
    Regrowth:coloredMessage("BE3333", ...);
end

function Regrowth:debug(...)
    Regrowth:coloredMessage("F7922E", ...);
end
