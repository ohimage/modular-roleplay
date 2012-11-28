include("shared.lua")
local spawnTime = NRP.cfg.ShipmentSpawnTime
local shipments = NRP.shipments

function ENT:Initialize()
	self.ModelScale = RealTime()
	self:SetModelScale( 0.01, 0 )
	print( self.dt.item )
	self.itemname = NRP.shipments[ self.dt.item ].name
end

surface.CreateFont( "ShipmentFont",{
	font      = "Ariel",
	size      = 60,
	weight    = 700
})

function ENT:Draw()
	self:DrawModel()
	
	if( spawnTime and self.ModelScale != 0 )then
		local scale = math.min( ( RealTime() - self.ModelScale ) / spawnTime, 1 )
		self:SetModelScale( scale, 0)
		if( scale == 1 )then
			self.ModelScale = 0
		end
	end
	
	local pos = self:GetPos()
	local angle = self:GetAngles()

	surface.SetFont("ShipmentFont")
	local width1 = surface.GetTextSize( self.itemname or "<unknown>")
	local width2 = surface.GetTextSize( self.dt.count or "<nil>")
	
	local height = self:OBBMaxs().z
	
	cam.Start3D2D(pos + angle:Up() * height, angle, 0.2) -- first we draw the amount on the top.
		draw.WordBox(2, -width1*0.5, -10, self.itemname or "<unknown>", "ShipmentFont", Color(0, 0, 140, 100), Color(255,255,255,255))
		draw.WordBox(2, -width2*0.5, 40, self.dt.count or "<unknown>", "ShipmentFont", Color(0, 0, 140, 100), Color(255,255,255,255))
	cam.End3D2D()
end
