include("shared.lua")
local spawnTime = NRP.cfg.WeaponSpawnTime

function ENT:Initialize()
	self.ModelScale = RealTime()
	self:SetModelScale( 0.01, 0 )
end

function ENT:Draw()
	self:DrawModel()
	
	if( spawnTime and self.ModelScale != 0 )then
		local scale = math.min( ( RealTime() - self.ModelScale ) / spawnTime, 1 )
		self:SetModelScale( scale, 0)
		if( scale == 1 )then
			self.ModelScale = 0
		end
	end
end