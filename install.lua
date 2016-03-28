local sandDir = "/sand"

while fs.exists(sandDir) do
    local randNumber = math.random(1, 36)
    sandDir = sandDir .. ("abcdefghijklmnopqrstuvwxyz0123456789"):sub(randNumber, randNumber)
end
fs.makeDir(sandDir)

for _, v in pairs(fs.list("/")) do
    --print(v)
    local diskList = {}
    for _, side in pairs(rs.getSides()) do
        if peripheral.getType(side) == "drive" then
            local mount = peripheral.call(side, "getMountPath")
            diskList[mount] = true
        end
    end
    if (v ~= (sandDir:sub(2, -1))) and (v ~= payload) and (not fs.isReadOnly("/" .. v)) and (not diskList[v]) then
        print("Doing " .. v .. " to " .. sandDir .. "/" .. v)
        fs.move("/" .. v, sandDir .. "/" .. v)
    elseif (v ~= (sandDir:sub(2, -1))) and (v ~= payload) then
        print("Tots doing " .. v .. " to " .. sandDir .. "/" .. v)
        fs.copy("/" .. v, sandDir .. "/" .. v)
    end
end
if sandDir ~= "/sand" then
    fs.move(sandDir, "/sand")
end

shell.setDir("/sand")

local old = {
    setDir = shell.setDir,
    dir = shell.dir,
    combine = _G.fs.combine,
    ls = _G.fs.list,
    setmetatable = _G.setmetatable,
    getmetatable = _G.getmetatable
}

shell.setDir = function(s)
    --print("setting directory")
    old.setDir(old.combine("/sand", old.combine(old.dir(), s)))
end

shell.dir = function()
    --print("getting directory")
    return (old.dir()):sub(5, -1)
end

_G.fs.combine = function(s1, s2)
    s1 = s1 or "[null]"
    s2 = s2 or "[null]"
    print("combining " .. s1 .. " " .. s2)
    local returning = old.combine(old.dir(), old.combine(s1, s2))
    print(returning)
    return returning
end

_G.fs.list = function(p)
    local list = old.ls(p)
    for k, v in ipairs(list) do
        list[k] = old.combine("/sand", v)
    end
    return list
end

local fakeMeta = nil
local env = {}

_G.setmetatable = function(t, m)
    if t == env then
        fakeMeta = m
    else
        old.setmetatable(t, m)
    end
end

env._G = env

old.setmetatable(env, {
    __index = function(t, k)
        return _G[k] or fakeMeta.__index(t, k)
    end
})
