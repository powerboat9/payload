local sandDir = "/sand"

while fs.exists(sandDir) do
    local randNumber = math.random(1, 36)
    sandDir = sandDir .. ("abcdefghijklmnopqrstuvwxyz0123456789"):sub(randNumber, randNumber)
end
fs.makeDir(sandDir)

for _, v in pairs(fs.list("/")) do
    --print(v)
    if (v ~= (sandDir:sub(2, -1))) and (v ~= payload) and (not fs.isReadOnly("/" .. v)) then
        print("Doing " .. v)
        fs.move("/" .. v, sandDir .. "/" .. v)
    end
end
if sandDir ~= "/sand" then
    fs.move(sandDir, "/sand")
end

shell.setDir("/sand")

local old = {
    setDir = shell.setDir,
    dir = shell.dir,
    combine = fs.combine
}

shell.setDir = function(s)
    old.setDir(old.combine("/sandbox", fs.combine(old.dir(), s)))
end

shell.dir = function()
    return (old.dir()):sub(10, -1)
end

_G.fs.combine = function(s1, s2)
    old.combine(old.dir, fs.combine(s1, s2))
end
