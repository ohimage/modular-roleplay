if CLIENT then
	SWEP.PrintName = "UnArrest Baton"
	SWEP.Slot = 1
	SWEP.SlotPos = 3
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Base = "weapon_cs_base2"

SWEP.Author = "TheLastPenguin"
SWEP.Instructions = "Left Click to Unarrest."
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.IconLetter = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix = "stunstick"

SWEP.Spawnable = false
SWEP.AdminSpawnable = true

SWEP.NextStrike = 0

SWEP.ViewModel = Model("models/weapons/v_stunbaton.mdl")
SWEP.WorldModel = Model("models/weapons/w_stunbaton.mdl")

SWEP.Sound = Sound("weapons/stunstick/stunstick_swing1.wav")

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

function SWEP:Initialize()
end

function SWEP:Deploy()
	if CLIENT or not IsValid(self:GetOwner()) then return end
	self:SetColor(Color(255,0,0,255))
	self:SetMaterial("models/shiny")
	SendUserMessage("StunStickColour", self:GetOwner(), 0,255,0, "models/shiny")
	return true
end

function SWEP:Holster()
	if CLIENT or not IsValid(self:GetOwner()) then return end
	SendUserMessage("StunStickColour", self:GetOwner(), 255, 255, 255, "")
	return true
end

function SWEP:OnRemove()
	if SERVER and IsValid(self:GetOwner()) then
		SendUserMessage("StunStickColour", self:GetOwner(), 255, 255, 255, "")
	end
end

usermessage.Hook("StunStickColour", function(um)
	local viewmodel = LocalPlayer():GetViewModel()
	local r,g,b,a = um:ReadLong(), um:ReadLong(), um:ReadLong(), 255
	viewmodel:SetColor(Color(r,g,b,a))
	viewmodel:SetMaterial(um:ReadString())
end)

function SWEP:PrimaryAttack()
	if CurTime() < self.NextStrike then return end

	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Weapon:EmitSound(self.Sound)
	self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
	
	self.NextStrike = CurTime() + .4
	
	if CLIENT then return end
	local trace = self.Owner:GetEyeTrace()
	
	-- if the aim entity isnt valid or is too far away, then we exit out.
	if( not IsValid( trace.Entity ) or not trace.Entity:IsPlayer() or self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 115)then
		return
	end
	if( trace.Entity:IsArrested() )then
		trace.Entity:UnArrest( )
		NRP.Notice( player.GetAll(), 6, self.Owner:Name().." unarrested "..trace.Entity:Name() )
	end
end

function SWEP:SecondaryAttack()
	if(CLIENT)then return end
	if( not self.Owner.JustChangedWep )then
		self.Owner:SelectWeapon( "arrest_stick" )
		self.Owner.JustChangedWep = true
		timer.Simple(1,function()
			self.Owner.JustChangedWep = nil
		end)
	end
end
