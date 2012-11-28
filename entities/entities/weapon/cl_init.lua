include("shared.lua")
local spawnTime = NRP.cfg.WeaponSpawnTime

function ENT:Initialize()
	NRP:ChangeModelScale( self, 0, 1, spawnTime)
end

function ENT:Draw()
	self:DrawModel()
end