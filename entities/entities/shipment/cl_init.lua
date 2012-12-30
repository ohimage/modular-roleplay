include("shared.lua")
local spawnTime = NRP.cfg.ShipmentSpawnTime
local shipments = NRP.shipments

function ENT:Initialize()
	NRP:ChangeModelScale( self, 0, 1, spawnTime)
	local tbl = NRP.shipments[ self.dt.item ]
	self.itemname = tbl.name
	self.modelent = ClientsideModel( tbl.model or "error.mdl", RENDER_GROUP_OTHER )
	self.modelent:SetNoDraw( true )
	self.modelent:SetPos( self:GetPos() + self:GetAngles():Up() * ( self:OBBMaxs().z + 20) )
	self.modelent:SetAngles( self:GetAngles() )
	NRP:ChangeModelScale( self.modelent, 0, 1, spawnTime)
	
	self.spawning = nil
end

surface.CreateFont( "ShipmentFont",{
	font      = "Akbar",
	size      = 120,
	weight    = 700,
	outline = true,
	antialias = false
})

local matBallGlow = Material("models/props_combine/tpballglow")
function ENT:DrawWeaponPreview()
	local modelent = self.modelent
	if( not modelent )then
		self:Initialize() -- make sure we have a model ent.
		modelent = self.modelent
	end
	local obbmaxs = self:OBBMaxs()
	local OBBCLModel = modelent:OBBMaxs()
	
	-- position calculations are always the same.
	local ang = self:GetAngles()
	ang:RotateAroundAxis( self:GetAngles():Up(), CurTime() * 70 )
	local entpos = self:GetPos() + self:GetAngles():Up() * ( obbmaxs.z + 10 + math.cos( CurTime() * 3 ) * 5)
	modelent:SetPos( entpos )
	modelent:SetAngles( ang )
		
	if( self.spawning ~= nil)then
		local colr = 1 - ((CurTime() - self.spawning) / spawnTime)
		local colg = (CurTime() - self.spawning) / spawnTime
		
		-- Draw the spawning effect
		local delta = CurTime() - self.spawning
		local min, max = modelent:OBBMins(), modelent:OBBMaxs()
		min, max = modelent:LocalToWorld(min), modelent:LocalToWorld(max)

		-- Draw the ghosted weapon
		render.MaterialOverride(matBallGlow)
		render.SetColorModulation(1 - delta, delta, 0) -- From red to green
		modelent:DrawModel()
		render.MaterialOverride()
		render.SetColorModulation(1, 1, 1)

		-- Draw the cut-off weapon
		render.EnableClipping(true)
		-- The clipping plane only draws objects that face the plane
		local normal = -modelent:GetAngles():Forward()
		local cutPosition = LerpVector(delta, max, min) -- Where it cuts
		local cutDistance = normal:Dot(cutPosition)-- Project the vector onto the normal to get the shortest distance between the plane and origin

		-- Activate the plane
		render.PushCustomClipPlane(normal, cutDistance);
		-- Draw the partial model
		modelent:DrawModel()
		-- Remove the plane
		render.PopCustomClipPlane()

		render.EnableClipping(false)
		
		if( CurTime() - self.spawning > spawnTime )then
			self.spawning = nil
		end
	else
		modelent:DrawModel()
	end
end

function ENT:Draw()
	self:DrawModel()
	self:DrawWeaponPreview()
	
	
	local obbmaxs = self:OBBMaxs()
	local pos = self:GetPos()
	local angle = self:GetAngles()
	
	surface.SetFont("ShipmentFont")
	local width1 = surface.GetTextSize( self.itemname or "<unknown>")
	
	local height = obbmaxs.z
	
	cam.Start3D2D(pos + angle:Up() * height, angle, 0.1 * self:GetModelScale()) -- first we draw the amount on the top.
		--draw.WordBox(2, -width1*0.5, -10, self.itemname or "<unknown>", "ShipmentFont", Color(0, 0, 140, 100), Color(255,255,255,255))
		draw.SimpleText(self.itemname or "<unknown>", "ShipmentFont", 0, -40, Color(255,255,255,255), TEXT_ALIGN_CENTER)
		draw.SimpleText(self.dt.count or "<nil>", "ShipmentFont", 0, 40, Color(255,255,255,255), TEXT_ALIGN_CENTER)
	cam.End3D2D()
end

function ENT:OnRemove()
	self.modelent:Remove()
	print("Removed clientside gun icon.")
end

net.Receive("NeoRP_ShipSpawning",function()
	print("RECIEVED SPAWNING FLAG!")
	local s = net.ReadEntity( )
	s.spawning = CurTime()
end)