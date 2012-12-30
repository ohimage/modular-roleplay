AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")



function ENT:Initialize()
	self:SetModel("models/gibs/metal_gib" .. math.random(1,5) .. ".mdl")
	
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	
	local phys = self.Entity:GetPhysicsObject()
	self.nodupe = true
	self.ShareGravgun = true
	
	if(self:IsOnFire())then self:Extinguish() end
	
	if phys and phys:IsValid() then phys:Wake() end
end


function ENT:Use(activator,caller)
	local amount = self.dt.amount

	activator:AddMoney(amount or 0)
	NRP.Notice(activator, 6, "You melt down and sell scrapmetal for $"..amount)
	self:Remove()
end

function DarkRPCreateScrapMetal(pos, amount)
	local scrap = ents.Create("scrap_metal")
	scrap:SetPos(pos)
	scrap.dt.amount = amount
	scrap:Spawn()
	scrap:Activate()
	return scrap
end
	
