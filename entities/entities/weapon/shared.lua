ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "NeoRP Shipment"
ENT.Author = "TheLastPenguin"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	self:DTVar("Int",0,"item")
end