include("scp_two_thousand/sh_scptwothousand.lua")

util.AddNetworkString("gScp2000_RewindTime")
net.Receive("gScp2000_RewindTime", function(len, ply)
    if (not IsValid(ply)) then
        return 
    end

    local team = ply:Team()

    if (not gScp2000.AllowedTeams[team]) then
        print("Invalid Team")
        return 
    end

    local num = net.ReadUInt(3)
    if (num < 1 or num > gScp2000.MaxNodes) then --Invalid data, user might be evil.
        return 
    end

    gScp2000.LoadState(num)
end)