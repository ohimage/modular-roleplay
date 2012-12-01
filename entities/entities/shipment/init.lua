AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local spawnTime = NRP.cfg.ShipmentSpawnTime

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	phys:Wake()
	
	timer.Simple( spawnTime, function()
		self.canspawn = true
	end)
	
	-- NeoRP player protection
	self.notool = true
	self.nophysgun = true
	self.nospawn = true
	
	self.hp = 100
end

function ENT:OnTakeDamage(dmg)
	self.hp = self.hp - dmg:GetDamage()
	if( self.hp <= 0 )then
		local max = 0
		while( max > 20 and IsValid( self.Entity ) and self.canspawn )do
			max = max + 1
			self:SpawnEntity()
		end
		self:Remove()
	end
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

function ENT:SpawnEntity( offset )
	if( not IsValid( self ) )then return end
	local curShip = NRP.shipments[ self.dt.item ]
	
	local e = ents.Create("weapon")
	
	e:SetModel( curShip.model )
	e:Spawn()
	e:Activate()
	
	e:SetAngles(self:GetAngles())
	local height = self:OBBMaxs().z + e:OBBMaxs().z + 5
	e:SetPos( self:GetPos() + self:GetAngles():Up() * height + ( offset or Vector( 0, 0, 0 )) )
	e.itemtbl = curShip
	
	self.dt.count = self.dt.count - 1
	if( self.dt.count <= 0 )then
		self.canspawn = false
		self:Remove()
	end
end