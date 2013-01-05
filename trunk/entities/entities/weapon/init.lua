AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	
	local phys = self:GetPhysicsObject()
	-- falco prop protection support.
	self.nodupe = true
	self.ShareGravgun = true
	phys:Wake()
	
	-- NeoRP player protection
	self.notool = true
	self.nophysgun = true
	self.nospawn = true
	self:DropToFloor( )
end

function ENT:Use(activator,caller)
	if self.PlayerUse == false then return end
	local class = self.itemtbl.class
	NRP.Notice(activator, 4, "Picked up "..self.itemtbl.name.."!")
	
	local weapon = ents.Create(class)

	if not weapon:IsValid() then return false end

	if not weapon:IsWeapon() then
		weapon:SetPos(self:GetPos())
		weapon:SetAngles(self:GetAngles())
		weapon:Spawn()
		weapon:Activate()
		weapon:Use( activator, caller, USE_TOGGLE, 0 )
		self:Remove()
		return
	end

	local CanPickup = hook.Call("PlayerCanPickupWeapon", GAMEMODE, activator, weapon)
	if not CanPickup then return end
	weapon:Remove()

	activator:Give(class)
	weapon = activator:GetWeapon(class)
	
	if self.clip1 then
		weapon:SetClip1(self.clip1)
		weapon:SetClip2(self.clip2 or -1)
	end
	if self.ammo then
		activator:GiveAmmo( self.ammo, weapon:GetPrimaryAmmoType())
	end

	-- The ammo bullshit gets as bad as having four variables to handle ammo exploits
	activator:GiveAmmo(self.ammoadd or 0, weapon:GetPrimaryAmmoType())
	
	self:Remove()
end