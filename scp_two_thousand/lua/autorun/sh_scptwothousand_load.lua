gScp2000 = gScp2000 or {}
gScp2000.BaseDir = "scp_two_thousand/"

function gScp2000.Log(...)
    local args = {...}
    print(table.concat(args, " "))
end

function gScp2000.LoadShared(f)
    gScp2000.Log("Loading File Shared " .. f)
    if SERVER then
        AddCSLuaFile(f)
        include(f)
    else
        include(f)
    end
end

function gScp2000.LoadServer(f)
    gScp2000.Log("Loading File Server " .. f)
    if SERVER then
        include(f)
    end
end

function gScp2000.LoadClient(f)
    gScp2000.Log("Loading File Client " .. f)
    if SERVER then
        AddCSLuaFile(f)
    else
        include(f)
    end
end

function gScp2000.LoadEverything(basePath)
    local files, directories = file.Find(basePath .. "*", "LUA")

    for k, v in pairs(files) do
        local path = basePath .. v
      
        if string.find(path, "sh_") then
            gScp2000.LoadShared(path)
        elseif string.find(path, "sv_") then
            gScp2000.LoadServer(path)
        elseif string.find(path, "cl_") then
            gScp2000.LoadClient(path)      
        end
    end

    for _, dir in ipairs(directories) do
        gScp2000.LoadEverything(basePath .. dir .. "/")
    end
end

gScp2000.LoadEverything(gScp2000.BaseDir)