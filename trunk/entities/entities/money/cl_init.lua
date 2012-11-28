include("shared.lua")

function ENT:Initialize()
	NRP:ChangeModelScale( self, 0, 1, 2)
end

surface.CreateFont( "MoneyFont",{
	font      = "Ariel",
	size      = 14,
	weight    = 700
})

function ENT:Draw()
	self:DrawModel()

	local pos = self:GetPos()
	local angle = self:GetAngles()

	surface.SetFont("MoneyFont")
	local width = surface.GetTextSize("$"..tostring(self.dt.amount))

	cam.Start3D2D(pos + angle:Up() * 0.9, angle, 0.1) -- first we draw the amount on the top.
		draw.WordBox(2, -width*0.5, -10, "$"..tostring(self.dt.amount), "MoneyFont", Color(0, 0, 140, 100), Color(255,255,255,255))
	cam.End3D2D()

	angle:RotateAroundAxis(angle:Right(), 180)

	cam.Start3D2D(pos, angle, 0.1) -- then the bottom.
		draw.WordBox(2, -width*0.5, -10, "$"..tostring(self.dt.amount), "MoneyFont", Color(0, 0, 140, 100), Color(255,255,255,255))
	cam.End3D2D()
end
