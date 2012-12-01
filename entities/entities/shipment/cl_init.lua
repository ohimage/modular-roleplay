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
end

surface.CreateFont( "ShipmentFont",{
	font      = "Akbar",
	size      = 120,
	weight    = 700,
	outline = true,
	antialias = false
})

function ENT:Draw()
	self:DrawModel()
	
	local obbmaxs = self:OBBMaxs()
	
	if(self.modelent)then
		local ang = self:GetAngles()
		ang:RotateAroundAxis( self:GetAngles():Up(), RealTime() * 70 ) 
		self.modelent:SetPos( self:GetPos() + self:GetAngles():Up() * ( obbmaxs.z + 20) - ang:Forward() * ( self.modelent:OBBMaxs().x ) )
		self.modelent:SetAngles( ang )
		self.modelent:DrawModel()
	end
	
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