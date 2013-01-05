-- RRPX Money Printer reworked for DarkRP by philxyz
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local u = PrinterUpgrades

ENT.SeizeReward = 100

local ValidEntity = function( ent )
	if( ent and ent.IsValid and ent:IsValid() )then
		return true
	else
		return false
	end
end

local PrintMore
function ENT:Initialize()
	self:SetModel("models/props_c17/consolebox01a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	phys:Wake()
	self:SetUseType( SIMPLE_USE )
	
	self.sparking = false
	self.damage = 100
	self.IsMoneyPrinter = true
	timer.Simple(math.random(30, 35), function() PrintMore(self) end)
	
	self.IsLockPickable = true
	self.CrashRecovery = true
	
	self:SetNWInt("Amount",1)
	self:SetNWInt("Speed",1)
	self:SetNWInt("Durability",1)
end

util.AddNetworkString( "PrinterMenuOpen" )
-- added by TheLastPenguin for upgrades.
function ENT:Use(activator,caller)
	if(self.clicked)then
		net.Start("PrinterMenuOpen")
			net.WriteEntity( self )
		net.Send( activator )
		
		self.clicked = false
	else
		self.clicked = true
		timer.Simple(0.4 + activator:Ping() / 1000,function()
			self.clicked = false
		end)
	end
end

function ENT:OnTakeDamage(dmg)
	if self.burningup then return end
	self:SetColor(Color(255,(self.damage/100)*255,(self.damage/100)*255,255))
	
	self.damage = (self.damage or 100) - dmg:GetDamage()
	if self.damage <= 0 then
		local rnd = math.random(1, 10)
		if rnd < 3 then
			self:BurstIntoFlames()
		else
			if( dmg:GetAttacker())then
				NRP.Notice(dmg:GetAttacker(), 5, "Press use on scrapmetal to melt it down for money.", NOTIFY_HINT)
			end
			self:Destruct()
			self:Remove()
		end
	end
end

local randVec = function( min, max )
	return Vector( math.random( min, max ),math.random( min, max ), math.random( min, max ))
end

function ENT:Destruct()
	local vPoint = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(vPoint)
	effectdata:SetOrigin(vPoint)
	effectdata:SetScale(1)
	util.Effect("Explosion", effectdata)
	for i = 0, math.random( 1, 4 ) do
		DarkRPCreateScrapMetal( self:GetPos() + randVec( - 20, 20 ), math.random( 30, 200 ) ):SetVelocity( randVec( -40, 40 ) )
	end
	NRP.Notice(self.dt.owning_ent, 6, "Your money printer has exploded!", NOTIFY_ERROR )
end

function ENT:BurstIntoFlames()
	NRP.Notice(self.dt.owning_ent, 6, "Your money printer is overheating!", NOTIFY_ERROR)
	self.burningup = true
	local burntime = math.random(8, 18)
	self:Ignite(burntime, 0)
	timer.Simple(burntime, function() self:Fireball() end)
end

function ENT:Fireball()
	if not self:IsOnFire() then self.burningup = false return end
	local dist = math.random(20, 280) -- Explosion radius
	self:Destruct()
	for k, v in pairs(ents.FindInSphere(self:GetPos(), dist)) do
		if not v:IsPlayer() and not v:IsWeapon() and v:GetClass() ~= "predicted_viewmodel" and not v.IsMoneyPrinter and not v:GetClass() == "scrap_metal" then
			v:Ignite(math.random(5, 22), 0)
		elseif v:IsPlayer() then
			local distance = v:GetPos():Distance(self:GetPos())
			v:TakeDamage(distance / dist * 100, self, self)
		end
	end
	self:Remove()
end

PrintMore = function(ent)
	if IsValid(ent) then
		ent.sparking = true
		timer.Simple(3, function() ent:CreateMoneybag() end)
	end
end

function ENT:CreateMoneybag()
	if not IsValid(self) then return end
	if self:IsOnFire() then return end
	local MoneyPos = self:GetPos()
	
	if math.random(1, u.Durability[self:GetNWInt("Durability",1)]["chance"]) == 3 then self:BurstIntoFlames() end

	local amount = u.Amount[self:GetNWInt("Amount",1)]["amount"]
	if not amount then
		amount = 250
	end

	NRP.CreateMoneyBag(Vector(MoneyPos.x + 15, MoneyPos.y, MoneyPos.z + 15), amount)
	self.sparking = false
	timer.Simple(math.random(100, 350) * u.Speed[self:GetNWInt("Speed",1)]["percent"], function() PrintMore(self) end)
end

function ENT:Think()

	if self:WaterLevel() > 0 then
		self:Destruct()
		self:Remove()
		return
	end

	if not self.sparking then return end
	
	local effectdata = EffectData()
	effectdata:SetOrigin(self:GetPos())
	effectdata:SetMagnitude(1)
	effectdata:SetScale(1)
	effectdata:SetRadius(2)
	util.Effect("Sparks", effectdata)
end

local function confetti(pos) -- make the baloon burst effect. 
						-- tf2 bday mode would be good but not everyone has that
	for i = 0, 5 do
		local effectdata = EffectData()
		effectdata:SetOrigin( pos)
		effectdata:SetStart( Vector( math.random(1,255), math.random(1,255), math.random(1,255) ) )
		util.Effect( "balloon_pop", effectdata )
	end
end

util.AddNetworkString("Printer.Upgrade")
net.Receive("Printer.Upgrade",function( length, ply )
	local ent = net.ReadEntity()
	if( not ply == ent.dt.owning_ent )then return end
	local field = net.ReadString()
	if( not u[ field ] )then 
		ErrorNoHalt("Invalid Field "..field )
		return
	end
	local level = ent:GetNWInt(field,1)
	
	-- make sure we're not maxed out on upgrades
	if( not u[ field ][ level + 1 ] )then
		ErrorNoHalt("Maxed out on upgrades in catagory "..field )
		return
	end
	local CurUpgrade = u[ field ][ level + 1 ]
	if( ply:CanAfford( CurUpgrade.cost ) )then
		ply:AddMoney( -CurUpgrade.cost )
		ent:SetNWInt( field, ent:GetNWInt( field ) + 1 )
		NRP.Notice(ply, 5, "Upgraded "..field.."!")
		confetti( ent:GetPos() )
	else
		NRP.Notice(ply, 5, "You cant afford this.", NOTIFY_ERROR)
	end
end) 

function ENT:OnLockPicked( ply )
	NRP.Notice(self.dt.owning_ent, 4, "Someone has stolen your printer!")
	self.dt.owning_ent = ply
	NRP.Notice(self.dt.owning_ent, 4, "This printer is now yours!")
	confetti( self:GetPos() ) -- You have a new printer... lets party!!!
end
