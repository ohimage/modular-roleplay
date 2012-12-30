/*
Changes by TheLastPenguin:
if you set ent.IsLockPickable to true on serverside and clientside for an entity it will be shown as lock pickable.
When the lockpick is successful ent.OnLockPicked is called
When it starts ent.OnLockPickStart is called.
*/
if CLIENT then
	SWEP.PrintName = "Lock Pick"
	SWEP.Slot = 5
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
	SWEP.Category = "NeoRP Weapons"
end

-- Variables that are used on both client and server

SWEP.Author = "Rickster"
SWEP.Instructions = "Left click to pick a lock"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = Model("models/weapons/v_crowbar.mdl")
SWEP.WorldModel = Model("models/weapons/w_crowbar.mdl")

SWEP.Spawnable = false
SWEP.AdminSpawnable = true

SWEP.Sound = Sound("physics/wood/wood_box_impact_hard3.wav")

SWEP.Primary.ClipSize = -1      -- Size of a clip
SWEP.Primary.DefaultClip = 0        -- Default number of bullets in a clip
SWEP.Primary.Automatic = false      -- Automatic/Semi Auto
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1        -- Size of a clip
SWEP.Secondary.DefaultClip = -1     -- Default number of bullets in a clip
SWEP.Secondary.Automatic = false        -- Automatic/Semi Auto
SWEP.Secondary.Ammo = ""
SWEP.LockPickTime = 30


local picking = false
if CLIENT then
	usermessage.Hook("lockpick_time", function(um)
		local wep = um:ReadEntity()
		local time = um:ReadLong()
		MsgN("Recieved lockpick time.")
		wep.StartPick = CurTime()
		wep.LockPickTime = time
		wep.EndPick = CurTime() + time
		
		picking = true
		
		wep.Dots = wep.Dots or ""
		timer.Create("LockPickDots", 0.5, 0, function()
			if not wep:IsValid() then timer.Destroy("LockPickDots") return end
			local len = string.len(wep.Dots)
			local dots = {[0]=".", [1]="..", [2]="...", [3]=""}
			wep.Dots = dots[len]
		end)
	end)
	
	usermessage.Hook("lockpick_failed", function( um )
		picking = false
		if CLIENT then timer.Destroy("LockPickDots") end
	end)

	usermessage.Hook("IsFadingDoor", function(um) -- Set isFadingDoor clientside (this is the best way I could think of to do this, if anyone can think of a better way feel free to change it.
		local door = um:ReadEntity()
		if IsValid(door) then
			door.isFadingDoor = true
		end
	end)
end

/*---------------------------------------------------------
Name: SWEP:PrimaryAttack()
Desc: +attack1 has been pressed
---------------------------------------------------------*/
local lockpicking = false
function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + 2)
	if self.IsLockPicking then return end

	local trace = self.Owner:GetEyeTrace()
	local e = trace.Entity
	if SERVER and e.isFadingDoor then SendUserMessage("IsFadingDoor", self.Owner, e) end -- The fading door tool only sets isFadingDoor serverside, for the lockpick to work we need this to be set clientside too.
	if IsValid(e) and trace.HitPos:Distance(self.Owner:GetShootPos()) <= 100 and (e:IsDoor() or e:IsVehicle() or string.find(string.lower(e:GetClass()), "vehicle") or e.isFadingDoor or e.IsLockPickable) then
		self.IsLockPicking = true
		self.StartPick = CurTime()
		if SERVER then
			self.LockPickTime = math.Rand(10, 30)
			umsg.Start("lockpick_time", self.Owner)
				umsg.Entity(self)
				umsg.Long(self.LockPickTime)
			umsg.End()
		end
		
		self.EndPick = CurTime() + self.LockPickTime

		self:SetWeaponHoldType("pistol")

		if SERVER then
			timer.Create("LockPickSounds", 1, self.LockPickTime, function()
				if not IsValid(self) then return end
				local snd = {1,3,4}
				self:EmitSound("weapons/357/357_reload".. tostring(snd[math.random(1, #snd)]) ..".wav", 50, 100)
			end)
		elseif CLIENT then
		end
		MsgN("Started lockpicking..")
		if( e.OnLockPickStart )then
			e.OnLockPickStart( self.Owner )
		end
	end
end

function SWEP:Holster()
	if(SERVER)then
		umsg.Start("lockpick_failed", self.Owner)
		umsg.End()
		timer.Destroy("LockPickSounds")
	end
	if CLIENT then timer.Destroy("LockPickDots") end
	return true
end

function SWEP:Succeed()
	print("Lock pick succeeded.")
	self.IsLockPicking = false
	self:SetWeaponHoldType("normal")
	local trace = self.Owner:GetEyeTrace()
	if trace.Entity.isFadingDoor and trace.Entity.fadeActivate then
		if not trace.Entity.fadeActive then
			trace.Entity:fadeActivate()
			--timer.Simple(5, function() if trace.Entity.fadeActive then trace.Entity:fadeDeactivate() end end)
		end
	elseif( trace.Entity.IsLockPickable )then
		if(trace.Entity.OnLockPicked)then
			trace.Entity:OnLockPicked( self.Owner )
		end
	elseif IsValid(trace.Entity) and trace.Entity.Fire then
		trace.Entity:Fire("unlock", "", .5)
		trace.Entity:Fire("open", "", .6)
		trace.Entity:Fire("setanimation","open",.6)
	end
	if SERVER then timer.Destroy("LockPickSounds") end
	if CLIENT then timer.Destroy("LockPickDots") end
end

function SWEP:Fail()
	self.IsLockPicking = false
	umsg.Start("lockpick_failed", self.Owner)
	umsg.End()
	self:SetWeaponHoldType("normal")
	if SERVER then timer.Destroy("LockPickSounds") end
	if CLIENT then timer.Destroy("LockPickDots") end
end

function SWEP:Think()
	if(CLIENT)then LocalPlayer().lockpicking = self.IsLockPicking end
	if self.IsLockPicking == true then
		local trace = self.Owner:GetEyeTrace()
		if not IsValid(trace.Entity) then
			self:Fail()
		end
		if trace.HitPos:Distance(self.Owner:GetShootPos()) > 100 or (not trace.Entity:IsDoor() and not trace.Entity:IsVehicle() and not string.find(string.lower(trace.Entity:GetClass()), "vehicle") and not trace.Entity.isFadingDoor and not trace.Entity.IsLockPickable) then
			self:Fail()
		end
		if self.EndPick <= CurTime() then
			self:Succeed()
		end
	end
end
if(CLIENT)then
	surface.CreateFont ("lockpick_text", {
		size = 32,
		weight = 600,
		antialias = true,
		shadow = true,
		font = "coolvetica"})
end

function SWEP:DrawHUD()
	local trace = LocalPlayer():GetEyeTrace()
	local e = trace.Entity
	
	if picking then
		if( CurTime() > self.EndPick )then
			picking = false
		end
		self.Dots = self.Dots or ""
		local w = ScrW()
		local h = ScrH()
		local x,y,width,height = w/2-w/10, h/ 2, w/5, h/15
		draw.RoundedBox(8, x, y, width, height, Color(10,10,10,120))
		
		local time = self.EndPick - self.StartPick
		local curtime = CurTime() - self.StartPick
		local status = curtime/time
		local BarWidth = status * (width - 16) + 8
		draw.RoundedBox(8, x+8, y+8, BarWidth, height - 16, Color(255-(status*255), 0+(status*255), 0, 255))

		draw.SimpleText("Picking lock"..self.Dots, "Trebuchet24", w/2, h/2 + height/2, Color(255,255,255,255), 1, 1)
	elseif( IsValid(e) and trace.HitPos:Distance(self.Owner:GetShootPos()) <= 100 and (e:IsDoor() or e:IsVehicle() or string.find(string.lower(e:GetClass()), "vehicle") or e.isFadingDoor or e.IsLockPickable) )then
		draw.SimpleText( "Click to Lock Pick","lockpick_text", ScrW()/2, ScrH() /2, Color( 155, 255, 155, 255 ), TEXT_ALIGN_CENTER )
	end
end

function SWEP:SecondaryAttack()
	self:PrimaryAttack()
end