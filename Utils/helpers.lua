---@type Regrowth
local _, Regrowth = ...;

local msgPrefix = "|cff10b981[RegrowthLootTool]|r"

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

function Regrowth:isArray(tbl)
    local i = 0;

    for _ in pairs(tbl) do
        i = i + 1;
        if tbl[i] == nil then
            return false;
        end
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

function Regrowth:findByKeyInArray(array, key, value)
    for _, item in ipairs(array) do
        for k, v in pairs(item) do
            if k == key then
                if v == value then
                    return item;
                end
            end
        end
    end

    return nil;
end

function Regrowth:findByKey(tbl, key)
    for k, v in pairs(tbl) do
        if key == k then
            return v;
        end
    end

    return nil;
end

function Regrowth:deepCopyTable(orig)
	local originalType = type(orig)
	local copy

	if originalType == 'table' then
		copy = {}
		for key, value in pairs(orig) do
			copy[key] = self:deepCopyTable(value)
		end
	else
		copy = orig
	end

	return copy
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

function Regrowth:isCurrentVersion()
    return Regrowth.Data.Version.current and Regrowth.Data.Version.current == Regrowth.Data.Version.latest;
end

function Regrowth:message(...)
    print(msgPrefix .. " " .. table.concat({ ... }, " "));
end

function Regrowth:coloredMessage(color, ...)
    Regrowth:message(string.format("|c00%s%s", color, string.join(" ", ...)));
end

function Regrowth:success(...)
    Regrowth:coloredMessage("92FF00", ...);
end

function Regrowth:warning(...)
    Regrowth:coloredMessage("E9D502", ...);
end

function Regrowth:error(...)
    Regrowth:coloredMessage("BE3333", ...);
end

function Regrowth:debug(...)
    if Regrowth.Settings.DebugMode ~= "on" then
        return;
    end

    Regrowth:coloredMessage("F7922E", ...);
end

function Regrowth:dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. self.dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end
