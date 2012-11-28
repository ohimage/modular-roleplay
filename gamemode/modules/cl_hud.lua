--[[
<xml>
	<module>
		<name>cl_hud</name>
		<author>TheLastPenguin</author>
		<desc>Client side sexyness</desc>
		<instance>CLIENT</instance>
	</module>
</xml>
]]
/*==========================================
SETTINGS
==========================================*/
local HudHeight = 50

/*==========================================
Frequently Used Variables
==========================================*/
local w, h, center
local hudY

NameTab = {{ },{ },{ },{ }} --create the two dimensional table

/*==========================================
DRAWING CODE
==========================================*/
local GRADIENT_UP = Material("vgui/gradient_up")
local BACK_COLOR = Color( 75, 75, 75 )

local function CalculateVariables()
	w, h = ScrW(), ScrH()
	center = w / 2
	hudY = h - HudHeight
	
	NameTab[1]["x"] = 0
	NameTab[1]["y"] = hudY - 30

	NameTab[2]["x"] = 200
	NameTab[2]["y"] = hudY - 30

	NameTab[3]["x"] = 230
	NameTab[3]["y"] = hudY

	NameTab[4]["x"] = 0
	NameTab[4]["y"] = hudY
end

local function PaintBackground()
	// The gray bar at the very bottom.
	surface.SetMaterial( GRADIENT_UP )
	// Draw the underlayer of gray.
	surface.SetDrawColor(  50,  50,  50,  255 )
	surface.DrawRect(  0, hudY, w,  HudHeight )
	// Draw the gradient overlay.
	surface.SetDrawColor(  0,  0,  0,  255 )
	surface.DrawTexturedRect(  0, hudY, w,  HudHeight )
end

local function PaintName()
	// Draw the name spot thingy.
	draw.NoTexture()
	surface.SetDrawColor( 70, 70, 70, 255)
	surface.DrawPoly( NameTab )
	
	// Player Name
	draw.DrawText(  "Name: "..LocalPlayer():Name(),  "Trebuchet18",  15,  hudY - 25,  Color(255,255,255,255), TEXT_ALIGN_LEFT )
end

/*====================================
DRAW INFO BOXES WITH MONEY, HEALTH ETC
====================================*/

local hudItems = {}
function NRP_AddHUDProperty( width, func, checkFunc )
	hudItems[#hudItems + 1 ] = { w = width, f = func, check = checkFunc }
end

local function drawBarMesure(Val, MaxVal,x,y, Width, Height, colfor, colback)
	local DrawVal = math.Min(Val / MaxVal, 1)
	local Border = math.Min(6, math.pow(2, math.Round(3*DrawVal)))
	draw.RoundedBox(Border, x , y , Width , Height, colback)
	draw.RoundedBox(Border, x + 1, y + 1, Width * DrawVal - 2, Height - 2, colfor)
end

local function drawInfoBox(x, y, width, height)
	surface.SetDrawColor( 255, 255, 255, 100 )
	surface.DrawRect( x, y, width, height )
	surface.SetDrawColor( 100, 100, 100, 200 )
	surface.DrawRect( x + 2, y + 2, width - 4, height - 4 )
end


local function drawInfo()
	local yheight = hudY + 5
	local middle = ScrW() / 2
	
	local widthTotal = 0
	for k,v in pairs( hudItems )do
		if( ( v.check and v.check() == true ) or not v.check )then
			widthTotal = widthTotal + v.w + 5
		end
	end
	local pos = middle - ( widthTotal / 2 )
	for k,v in pairs( hudItems )do
		if( ( v.check and v.check() == true ) or not v.check )then
			drawInfoBox( pos, yheight, v.w + 4, 30)
			pcall( v.f, pos + 2, yheight + 2, v.w, 26)
			pos = pos + v.w + 10
		end
	end
end


// CUSTOM HUD PROPERTIES:
-- JOB
NRP_AddHUDProperty( 200, function(x, y, w, h)
	draw.DrawText(  "Job: "..team.GetName( LocalPlayer():Team() ) ,  "Trebuchet20",  x + w / 2,  y + 2.5,  Color(255, 255, 255, 255),  TEXT_ALIGN_CENTER )
end)

-- Health
NRP_AddHUDProperty( 200, function(x, y, w, h)
	surface.SetDrawColor( 255, 0, 0, 255 )
	surface.DrawRect( x, y, math.Min( LocalPlayer():Health(), 100 ) / 100 * w , h )
	draw.DrawText(  "Health: "..LocalPlayer():Health(),  "Trebuchet20",  x + w / 2,  y + 2.5,  Color(255, 255, 255, 255),  TEXT_ALIGN_CENTER )
end)

-- Armor
NRP_AddHUDProperty( 200, function(x, y, w, h)
	surface.SetDrawColor( 255, 0, 0, 255 )
	surface.DrawRect( x, y, math.Min( LocalPlayer():Armor(), 100 ) / 100 * w , h )
	draw.DrawText(  "Armor: "..LocalPlayer():Armor(),  "Trebuchet20",  x + w / 2,  y + 2.5,  Color(255, 255, 255, 255),  TEXT_ALIGN_CENTER )
end)

-- Money
NRP_AddHUDProperty( 200, function(x, y, w, h)
	local money = LocalPlayer().NETDATA.money
	local outOf = math.pow( 10, (math.floor( math.log10( money ) ) + 1 ))
	surface.SetDrawColor( 0, 155, 0, 255 )
	surface.DrawRect( x, y, ( money / outOf ) * w , h ) 
	draw.DrawText(  "Wallet: $"..money,  "Trebuchet20",  x + w / 2,  y + 2.5,  Color(255, 255, 255, 255),  TEXT_ALIGN_CENTER )
end)

-- Bullets
NRP_AddHUDProperty( 200, function(x, y, w, h)
	local wep = LocalPlayer():GetActiveWeapon()
	if( not wep ) then return end
	local ammo = wep:Clip1()
	local ammoReserve = LocalPlayer():GetAmmoCount( wep:GetPrimaryAmmoType( ) )
	local text = nil
	local col = nil
	if( ammo > 0 )then
		text = string.format( "Ammo: %d/%d", ammo, ammoReserve )
		col = Color(255, 255, 255, 255)
	else
		if( ammoReserve > 0 )then
			text = "RELOAD"
			col = Color( 255, 255, 0, 255 )
		else
			text = "NO AMMO"
			col = Color( 255, 0, 0, 255 )
		end
	end
	draw.DrawText( text ,  "Trebuchet20",  x + w / 2,  y + 2.5, col ,  TEXT_ALIGN_CENTER )
end, function()
	local w = LocalPlayer():GetActiveWeapon()
	if( not( w and IsValid( w ) and w.Clip1 ))then return false end
	return LocalPlayer():GetActiveWeapon():Clip1() >= 0
end)

/*==========================================
GAMEMODE FUNCTIONS
==========================================*/
-- The HUD should draw below anything else really since it's the least important thing on the screen.
function GM:HUDPaintBackground()
	CalculateVariables()
	PaintBackground()
	PaintName()
	drawInfo()
end

local tohide = { -- This is a table where the keys are the HUD items to hide
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudAmmo"] = false,
	["CHudSecondaryAmmo"] = true,
	["CHudSuitPower"] = true,
	["CHudBattery"] = true
}

hook.Add("HUDShouldDraw","LPRP_HudShouldDraw",function(name)
	if(tohide[name] == nil)then
		return true
	elseif(tohide[name]==true)then
		return false
	end
	return true
end)
/*==========================================
NAME TAGS OVER PLAYER HEADS
==========================================*/
local offsetVec = Vector(0, 0, 17 )
local offsetVec2 = Vector(0, 0, 25 )

surface.CreateFont( "PlayerNameTags30",
	{
		font      = "Ariel",
		size      = 60,
		weight    = 1000,
		outline = true,
		antialias = false
	})
surface.CreateFont( "PlayerNameTags20",
	{
		font      = "Ariel",
		size      = 40,
		weight    = 1000,
		outline = true,
		antialias = false
	})
surface.CreateFont( "PlayerNameTags10",
	{
		font      = "Ariel",
		size      = 20,
		weight    = 1000,
		outline = true,
		antialias = false
	})

local function getHeadPos( ply )
	if( not ( IsValid( ply ) and ply:Alive() ))then	
		return nil
	end
	local lookup = ply:LookupBone("ValveBiped.Bip01_Head1")
	if( lookup )then
		return ply:GetBonePosition( lookup )
	else
		return nil
	end
end

function GM:PostDrawOpaqueRenderables()
	if( not LocalPlayer():Alive() )then return end
	local myview = getHeadPos( LocalPlayer() )
	if( not myview )then return end
	local aimEnt = LocalPlayer():GetEyeTrace().Entity
	for k,v in pairs(player.GetAll())do
		local status, headpos = pcall( getHeadPos, v )
		if( status == true )then
			if( v ~= LocalPlayer() and v ~= aimEnt and headpos and myview:Distance( headpos ) < 500 and v:GetColor().a > 20 )then
				local vecdir = myview - headpos + offsetVec
				local angle =  Angle( 0, vecdir:Angle().yaw + 90, 90 )
				cam.Start3D2D(headpos + offsetVec, angle, 0.1)
					if( v.DarkRPVars )then
						draw.DrawText( v:Name(),  "PlayerNameTags30",  0,  0,team.GetColor( v:Team() ) ,  TEXT_ALIGN_CENTER )
					end
				cam.End3D2D()
			end
		end
	end
	if( IsValid( aimEnt ) and aimEnt:IsPlayer() )then
		local headpos = getHeadPos( aimEnt )
		local vecdir = myview - headpos + offsetVec * 2
		local angle =  Angle( 0, vecdir:Angle().yaw + 90, 90 )
		cam.Start3D2D(headpos + offsetVec2, angle, 0.1)
			draw.DrawText( aimEnt:Name() ,  "PlayerNameTags30",  0,  0,team.GetColor( aimEnt:Team() ) ,  TEXT_ALIGN_CENTER )
			local teamName = team.GetName( aimEnt:Team() ) or "<unknown>"
			draw.DrawText( teamName,  "PlayerNameTags20",  0,  60,team.GetColor( aimEnt:Team() ) ,  TEXT_ALIGN_CENTER )
			
			-- the health bar.
			local healthWidth = 200
			local hc = ( aimEnt:Health() / 100 ) * 255
			surface.SetDrawColor( 255 - hc, hc, 0 )
			surface.DrawRect(healthWidth / -2, -10 + 120, ( math.min( aimEnt:Health(), 100 ) / 100 ) * healthWidth, 20 )
			surface.SetDrawColor( 255, 255, 255 )
			surface.DrawOutlinedRect( healthWidth / -2, -10 + 120, healthWidth, 20 )
			
			draw.DrawText( aimEnt:Health(),  "PlayerNameTags10", 0, 110,Color( 255, 255, 255 ) ,  TEXT_ALIGN_CENTER )
		cam.End3D2D()
	end
end
