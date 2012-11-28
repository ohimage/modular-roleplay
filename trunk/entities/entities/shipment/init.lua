AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	-- falco prop protection support.
	self.nodupe = true
	self.ShareGravgun = true
	phys:Wake()
	
	self.canspawn = true
end


function ENT:Use(activator,caller)
	if( self.canspawn )then
		self.canspawn = false
		timer.Simple( 1, function()
			self.canspawn = true
			self:SpawnEntity()
		end)
	end
end

function ENT:SpawnEntity()
	local curShip = NRP.shipments[ self.dt.item ]
	
	local e = ents.Create("weapon")
	
	e:SetModel( curShip.model )
	e:Spawn()
	e:Activate()
	
	e:SetAngles(self:GetAngles())
	local height = self:OBBMaxs().z + e:OBBMaxs().z + 5
	e:SetPos( self:GetPos() + self:GetAngles():Up() * height )
	e.itemtbl = curShip
end