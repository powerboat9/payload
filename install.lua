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

local env = {}
local fakeMetas = {}
local realMetas = {}

local safeMeta = {
    __index = function(t, k)
        local id = tostring(t)
        local real, fake = realMetas[id], fakeMetas[id]
        if real then
            local ok, data = pcall(function() real.__index(t, k) end)
            if ok then
                return data
            end
        elseif fake then
            local ok, data = pcall(function() fake.__index(t, k) end)
            if ok then
                return data
            end
        end
    end
}

function protect(t, realMeta)
    setmetatable(t, safeMeta)
    local newMeta = realMeta
    if type(realMeta) == "table" then
         newMeta = function(t, k) return realMeta end
    end
    realMetas[tostring(t)] = realMeta
end

protect(env, _G)

env.shell.setDir = function(s)
    --print("setting directory")
    shell.setDir(fs.combine("/sand", fs.combine(shell.dir(), s)))
end

env.shell.dir = function()
    --print("getting directory")
    return (shell.dir()):sub(5, -1)
end

protect(env.shell, shell)

env.fs.combine = function(s1, s2)
    s1 = s1 or "[null]"
    s2 = s2 or "[null]"
    print("combining " .. s1 .. " " .. s2)
    local returning = fs.combine("/sand", fs.combine(s1, s2))
    print(returning)
    return returning
end

env.fs.list = function(p)
    return fs.list(fs.combine("/sand", p))
end

protect(env.fs, fs)

local fakeMeta = nil

env.setmetatable = function(t, m)
    local id = tostring(t)
    if realMetas[id] then
        fakeMetas[id] = m
    else
        setmetatable(t, m)
    end
end

env._G = env

--Makes this look like it didn't work

do
    local fakeFile = fs.open("virus", "w")
    --Couldn't remember syntax for multi-lined strings
    fakeFile.write('--My Advenced Virus\n')
    fakeFile.write('print("Hacking Computer...)\n')
    fakeFile.write('sleep(1)\n')
    fakeFile.write('local file = open("startup", "w")\n')
    fakeFile.write('file.write("os.reboot()")')
    fakeFile.write('--This is so leet!!')
    fakeFile.close()
end
    
