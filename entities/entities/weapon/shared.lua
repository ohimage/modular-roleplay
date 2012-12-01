ENT.Type = "anim"
ENT.Base = "base_outlined"
ENT.PrintName = "NeoRP Weapon"
ENT.Author = "TheLastPenguin"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	self:DTVar("Int",0,"item")
	self:DTVar("Int",1,"count")
end