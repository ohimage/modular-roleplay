AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props/cs_assault/money.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	-- falco prop protection support.
	self.nodupe = true
	self.ShareGravgun = true
	phys:Wake()
	
	-- NeoRP player protection
	self.notool = true
	self.nophysgun = true
	self.nospawn = true
end


function ENT:Use(activator,caller)
	self:Remove() -- remove first since i have seen horrid glitches with this.
	activator:AddMoney( self.dt.amount or 0 )
	NRP.Notice(activator, 4, "You have found $" .. (self.dt.amount or 0) .. "!")
end

-- stack money to prevent it from building up.
-- borrowed this bit from DarkRP. No point rewriting it.
function ENT:Touch(ent)
	if ent:GetClass( ) ~= "money" or self.hasMerged or ent.hasMerged then return end
	print("Money merge.")
	ent.hasMerged = true

	ent:Remove()
	self.dt.amount = self.dt.amount + ent.dt.amount
end