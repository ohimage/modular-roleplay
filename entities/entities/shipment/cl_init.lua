include("shared.lua")
local spawnTime = NRP.cfg.ShipmentSpawnTime
local shipments = NRP.shipments

function ENT:Initialize()
	NRP:ChangeModelScale( self, 0, 1, spawnTime)
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
