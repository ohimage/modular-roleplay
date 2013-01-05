ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Money Printer"
ENT.Author = "Render Case and philxyz"
ENT.Spawnable = false
ENT.AdminSpawnable = false
local u = {}
u.Amount = {}
u.Speed = {}
u.Durability = {}
PrinterUpgrades = u

if(CLIENT)then
PrinterUpgradeIcons = {
["Amount"] = Material("icon16/coins.png" ),
["Speed"] = Material("icon16/cog.png" ),
["Durability"] = Material( "icon16/wrench.png" )
}
end

local function AddAmountUpgrade( name, cost, amount )
	table.insert( u.Amount , { ["name"] = name, ["cost"] = cost, ["amount"] = amount } )
end
local function AddSpeedUpgrade( name, cost, speed )
	table.insert( u.Speed , { ["name"] = name, ["cost"] = cost, ["percent"] = speed } )
end
local function AddDurabilityUpgrade( name, cost, probability )
	table.insert( u.Durability , { ["name"] = name, ["cost"] = cost, ["chance"] = probability } )
end
AddAmountUpgrade("HomeMade Printer", 1000, 250 ) -- default level
AddAmountUpgrade("Money Printer", 1000, 350 ) -- tier 1
AddAmountUpgrade("Bronze Money Printer", 2000, 600 ) -- tier 2
AddAmountUpgrade("Silver Money Printer", 4000, 900 ) -- tier 3
AddAmountUpgrade("Gold Money Printer", 6000, 1200 ) -- tier 4
AddAmountUpgrade("Platinum Money Printer", 10000, 1600 ) -- tier 5
AddAmountUpgrade("Diamond Money Printer", 14000, 2000 ) -- tier 6
AddAmountUpgrade("Nuclear Money Printer", 50000, 5000 ) -- tier 7

AddSpeedUpgrade( "Normal", 0, 1 ) -- default level
AddSpeedUpgrade( "Turbo Fan", 600, 0.8 )
AddSpeedUpgrade( "Ink Injector", 800, 0.7 )
AddSpeedUpgrade( "Paper Ram", 1200, 0.6 )
AddSpeedUpgrade( "Lazor Printing", 3000, 0.5 )
AddSpeedUpgrade( "Quantom Ink", 5000, 0.4 )

AddDurabilityUpgrade( "Normal", 0, 27 )
AddDurabilityUpgrade( "AntiStatic Paint", 200, 40 )
AddDurabilityUpgrade( "HeatSync", 300, 60 )
AddDurabilityUpgrade( "Water Coolant", 700, 100 )
AddDurabilityUpgrade( "CO2 Extinguisher", 1200, 200 )

function ENT:SetupDataTables()
	self:DTVar("Entity",1,"owning_ent")
	for k,v in pairs( u )do
		self:SetNWInt(k,1)
	end
	
	self.RES = {}
	self.RES.isConsumer = true
end