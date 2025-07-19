AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel( "models/props_lab/jar01a.mdl" ) 
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if phys:IsValid() then 
        phys:Wake() 
    end
end

util.AddNetworkString("scp_twothousand_open_menu")
function ENT:Use(act)
    local team = act:Team()

    if (not gScp2000.AllowedTeams[team]) then
        return 
    end

    net.Start("scp_twothousand_open_menu")
    net.Send(act)

end