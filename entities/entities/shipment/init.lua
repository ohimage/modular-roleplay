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
		while( max <= 10 and IsValid( self.Entity ) and self.canspawn )do
			max = max + 1
			self:SpawnEntity( max * 10)
			self.dt.count = self.dt.count - 1
		end
		self:Remove()
	end
end

util.AddNetworkString("NeoRP_ShipSpawning")
function ENT:Use(activator,caller)
	if( self.canspawn )then
		self.canspawn = false
		net.Start("NeoRP_ShipSpawning")
			net.WriteEntity( self )
		net.Send( player.GetAll() )
		timer.Simple( 1, function()
			self.canspawn = true
			self:SpawnEntity()
		end)
		self.dt.count = self.dt.count - 1
	end
end

function ENT:SpawnEntity( offset )
	if( not IsValid( self ) )then return end
	local curShip = NRP.shipments[ self.dt.item ]
	
	local e = ents.Create("weapon")
	
	e:SetModel( curShip.model )
	e:Spawn()
	e:Activate()
	e.itemtbl = curShip
	
	e:SetAngles(self:GetAngles()) -- give ammo for picking up more guns.
	local wepTbl = weapons.Get( curShip.class )
	if( wepTbl and wepTbl.Primary )then
		e.ammo = wepTbl.Primary.DefaultClip
	end
	
	-- position calculations are always the same.
	local ang = self:GetAngles()
	ang:RotateAroundAxis( self:GetAngles():Up(), CurTime() * 70 )
	local entpos = self:GetPos() + self:GetAngles():Up() * ( self:OBBMaxs().z + 10)
	e:SetPos( entpos )
	
	if( self.dt.count <= 0 )then
		self.canspawn = false
		self:Remove()
	end
end