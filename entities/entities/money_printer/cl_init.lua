include("shared.lua")

local u = PrinterUpgrades
local PrinterUpgradeIcons = PrinterUpgradeIcons

function ENT:Initialize()
	self.IsLockPickable = true
end

local UserIcon = Material("icon16/user.png")

local PRINTER_FONT = NRP.RequestFont( 30 )
function ENT:Draw()
	self:DrawModel()

	local Pos = self:GetPos()
	local Ang = self:GetAngles()

	local owner = self.dt.owning_ent
	owner = (IsValid(owner) and owner:Nick()) or "unknown"

	surface.SetFont( PRINTER_FONT)
	local TextWidth = surface.GetTextSize("Money printer")
	local TextWidth2 = surface.GetTextSize(owner)

	Ang:RotateAroundAxis(Ang:Up(), 90)

	cam.Start3D2D(Pos + Ang:Up() * 11.5, Ang, 0.11)
		
		local i = 0
		if( LocalPlayer():GetEyeTrace().Entity == self )then
			draw.DrawText(  "Double press 'e' to show\nupgrade menu.",  PRINTER_FONT,  0, -100,  Color(255, 255, 255, 255),  TEXT_ALIGN_CENTER )
			for k,v in pairs( u )do
				-- icon width is 45. Icon height is 48
				local CurUpgrade = v[ self:GetNWInt( k, 1 ) ]
				local str = k..": ".. CurUpgrade.name or "<none>"
				local Width = surface.GetTextSize(str)
				local IconWidth = 38 * self:GetNWInt( k, 1 )
				local YPos = ( 48 + 40 ) * i - 40
				draw.WordBox(2, -Width*0.5, YPos, str, PRINTER_FONT, Color(0, 0, 200, 100), Color(255,255,255,255))
				surface.SetDrawColor( Color( 255, 255, 255, 200 ))
				surface.SetMaterial( PrinterUpgradeIcons[ k ] )
				for b = 1, self:GetNWInt( k, 1 ) do
					surface.DrawTexturedRect( -IconWidth*0.5 + ( b - 1 ) * 38, YPos + 38, 32, 32 )
				end
				surface.DrawOutlinedRect( -Width*0.5, YPos, Width, 48 + 24)
				i = i + 1
			end
		else
			surface.SetMaterial( UserIcon )
			if(LocalPlayer()==self.dt.owning_ent)then
				surface.SetDrawColor( Color( 255, 255, 255, 200 ))
			else
				surface.SetDrawColor( Color( 255, 0, 0, 200 ))
			end
			surface.DrawTexturedRect( -TextWidth2*0.5 - 45, 18, 40, 40 )
			draw.WordBox(2, -TextWidth*0.5, -30, "Money Printer", PRINTER_FONT, Color(0, 0, 170, 100), Color(255,255,255,255))
			draw.WordBox(2, -TextWidth2*0.5, 18, owner, PRINTER_FONT, Color(0, 0, 170, 100), Color(255,255,255,255))
		end
	cam.End3D2D()
end

function ENT:Think()
end

local w, h = 400, 200	//*ScrW() * 0.5, ScrH() * 0.5
local lastMouse = {( ScrW() ) / 2, ScrH() - h * 0.5}

local function UpgradeMenu( ent )
	if( not ent )then return end

	local UPanel = vgui.Create( "DFrame" ) -- Creates the frame itself
	UPanel:SetPos( ( ScrW() - w ) / 2, ScrH() - h - 20)//( ScrH() - h ) / 2 ) -- Position on the players screen
	gui.SetMousePos( unpack( lastMouse ) )
	PrintTable( lastMouse )
	UPanel:SetSize( w, h ) -- Size of the frame
	UPanel:SetTitle( "Printer Upgrade" ) -- Title of the frame
	UPanel:SetVisible( true )
	UPanel:SetDraggable( true )
	UPanel:ShowCloseButton( true )
	UPanel:MakePopup()
	UPanel:SetSkin("neorp")
	
	local List = vgui.Create("DPanelList", UPanel )
	List:SetPos( 15, 30 )
	List:SetSize( w - 30, h - 45 )
	List:SetPadding( 5 )
	local w = w - 30
	local h = h - 45
	
	-- Upgrades Catagory.
		local UpgradeCatagory= vgui.Create("DCollapsibleCategory" )
		UpgradeCatagory:SetLabel("  Upgrades")
		UpgradeCatagory:SetExpanded( true )
		UpgradeCatagory:SetPos( 15, 15 )
		UpgradeCatagory:SetSize( w - 30, 50 )
		List:AddItem( UpgradeCatagory ) -- add it to the catagory list.
		
		-- DListLayout which formats the list.
		local UpgradeLayout = vgui.Create("DListLayout")
		UpgradeLayout:SetSize( 0, 200 )
		UpgradeCatagory:SetContents( UpgradeLayout ) -- put it in the catagory.
		
		local UpgradeList = vgui.Create("DPanelList", UpgradeLayout)
		UpgradeList:SetPos( 15, 15 )
		UpgradeList:SetSize( w - 30, 200 )
		UpgradeList:SetPadding( 5 )
		UpgradeLayout:Add( UpgradeList )
			
			if( u.Amount[ ent:GetNWInt("Amount",1) + 1 ] )then
				-- Button to Upgrade Amount.
				local UAB = vgui.Create("DButton", UpgradeList)
				UAB:SetSize( 200, 30 )
				UAB:SetPos( 50, 30 )
				UAB:SetImage("icon16/coins.png")
				local CurUpgrade = (u.Amount[ent:GetNWInt("Amount",1) + 1] or {} )
				UAB:SetText( "Amount: ".. (CurUpgrade.name or "--Error--" ) .." $"..CurUpgrade.cost)
				UAB.DoClick = function( button )
					net.Start( "Printer.Upgrade" )
						net.WriteEntity( ent )
						net.WriteString("Amount")
					net.SendToServer()
					UPanel:Close()
					lastMouse = {input.GetCursorPos()}
				end
				UpgradeList:AddItem(UAB)
			end
			
			if( u.Speed[ ent:GetNWInt("Speed",1) + 1 ] )then
				-- Button to Upgrade Speed.
				local USB = vgui.Create("DButton", UpgradeList)
				USB:SetSize( 200, 30 )
				USB:SetPos( 50, 30 )
				USB:SetImage("icon16/cog.png")
				local CurUpgrade = u.Speed[ent:GetNWInt("Speed",1) + 1] or {}
				USB:SetText( "Speed: "..(CurUpgrade.name or "--Error--" ).." $"..CurUpgrade.cost)
				USB.DoClick = function( button )
					net.Start( "Printer.Upgrade" )
						net.WriteEntity( ent )
						net.WriteString("Speed")
					net.SendToServer()
					UPanel:Close()
					lastMouse = {input.GetCursorPos()}
				end
				UpgradeList:AddItem(USB)
			end
			
			if( u.Durability[ ent:GetNWInt("Durability",1) + 1 ] )then
				-- Button to Upgrade Speed.
				local UDB = vgui.Create("DButton", UpgradeList)
				UDB:SetSize( 200, 30 )
				UDB:SetPos( 50, 30 )
				UDB:SetImage("icon16/wrench.png")
				local CurUpgrade = u.Speed[ent:GetNWInt("Durability",1) + 1] or {} 
				UDB:SetText( "Durability: "..(CurUpgrade.name or "--Error--" ) .." $"..CurUpgrade.cost )
				UDB.DoClick = function( button )
					net.Start( "Printer.Upgrade" )
						net.WriteEntity( ent )
						net.WriteString("Durability")
					net.SendToServer()
					UPanel:Close()
					lastMouse = {input.GetCursorPos()}
				end
				UpgradeList:AddItem(UDB)
			end
end

net.Receive( "PrinterMenuOpen", function()
	local ent = net.ReadEntity()
	UpgradeMenu( ent )
end)