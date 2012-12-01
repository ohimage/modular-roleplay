include("shared.lua")
local spawnTime = NRP.cfg.WeaponSpawnTime

ENT.ColorModulation = Color(0.15, 0.8, 1)

function ENT:Initialize()
	NRP:ChangeModelScale( self, 0, 1, spawnTime)
	self.BaseClass.Initialize( self )
end