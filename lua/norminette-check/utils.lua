local M = {}

local function tablesAreEqual(t1, t2)
    if t1 == t2 then
		return true
	end

    if type(t1) ~= "table" or type(t2) ~= "table" then
		return false
	end

    for k, v in pairs(t1) do
        if t2[k] ~= v then
            return false
        end
    end

    for k in pairs(t2) do
        if t1[k] == nil then
            return false
        end
    end

    return true
end

M.uniqTables = function (t1, t2)
	if t1 == nil then
		return t2
	end

	if t2 == nil then
		return t1
	end

    local unique = {}
    local seen = {}

    local function addUniqueTable(tbl)
        for _, seenTbl in ipairs(seen) do
            if tablesAreEqual(tbl, seenTbl) then
                return
            end
        end
        table.insert(unique, tbl)
        table.insert(seen, tbl)
    end

    for _, tbl in ipairs(t1) do
        addUniqueTable(tbl)
    end

    for _, tbl in ipairs(t2) do
        addUniqueTable(tbl)
    end

    return unique
end

return M
