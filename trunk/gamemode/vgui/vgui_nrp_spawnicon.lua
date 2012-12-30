--[[
<xml>
	<module>
		<name>NRP_SpawnIcon</name>
		<instance>CLIENT</instance>
	</module>
</xml>
]]


local matHover = Material( "vgui/spawnmenu/hover" )

local PANEL = {}

AccessorFunc( PANEL, "m_strModelName", 		"ModelName" )
AccessorFunc( PANEL, "m_iSkin", 			"SkinID" )
AccessorFunc( PANEL, "m_strBodyGroups", 	"BodyGroup" )
AccessorFunc( PANEL, "m_strIconName", 		"IconName" )


--[[---------------------------------------------------------
   Name: Paint
-----------------------------------------------------------]]

function PANEL:Init()

	self:SetDoubleClickingEnabled( false )
	self.Buttons = {}
	self:SetText("")
	self:SetTitle("")
	self.Icon = vgui.Create( "ModelImage", self )
	self.Icon:SetMouseInputEnabled( false )
	self.Icon:SetKeyboardInputEnabled( false )
	self.Icon:SetText("")
	
	self:SetSize( 64, 64 )	
	
	self:SetToolTip( false )
	
	self.m_strBodyGroups = "000000000";

end

function PANEL:DoRightClick()
end

function PANEL:DoClick(...)
	if( #self.Buttons == 1 )then
		self.Buttons[1].onClicked()
	else
		for i = 1, #self.Buttons do
			local w, h = self:GetSize()
			local cbut = self.Buttons[ i ]
			local ypos = h - 20 * i
			local x, y = gui.MousePos()
			local iconx, icony = self:LocalToScreen()
			local scry = icony + ypos
			if( scry <= y and scry + 20 > y )then
				cbut.onClicked( ... )
			end
		end
	end
end

surface.CreateFont( "NRP_IconButton",
	{
		font      = "coolvetica",
		size      = 15,
		weight    = 100
	}
 )

function PANEL:SetTitle( text )
	self.text = text
	surface.SetFont( "NRP_IconButton" )
	self.text_size = { surface.GetTextSize( text ) }
end

function PANEL:Paint( w, h )
end

function PANEL:AddButton( text, onClicked )
	local new = {}
	new.text = text
	surface.SetFont( "NRP_IconButton" )
	new.text_size = { surface.GetTextSize( text ) }
	new.onClicked = onClicked
	table.insert( self.Buttons, 1, new )
end

function PANEL:PaintOver( w, h)
	surface.SetFont( "NRP_IconButton" )
	surface.SetTextColor( Color(255, 255, 255) )
	if( self.Hovered )then
		for i = 1, #self.Buttons do
			local cbut = self.Buttons[ i ]
			local ypos = h - 20 * i
			
			local w, h = self:GetSize()
			local x, y = gui.MousePos()
			local iconx, icony = self:LocalToScreen()
			local scry = icony + ypos
			if( scry <= y and scry + 20 > y )then
				surface.SetDrawColor( Color( 55, 55, 55 ) )
			else
				surface.SetDrawColor( Color( 0, 0, 0 ) )
			end
			
			surface.DrawRect( 0, ypos, w, 15)
			surface.SetTextPos( w / 2 - cbut.text_size[1] / 2, ypos)
			surface.DrawText( cbut.text )
		end
	else
		local ypos = h - 20
		surface.SetDrawColor( Color( 0, 0, 0 ) )
		surface.DrawRect( 0, ypos, w, 15)
		surface.SetTextPos( w / 2 - self.text_size[1] / 2, ypos )
		surface.DrawText( self.text )
	end
end

function PANEL:PerformLayout()
	
	if ( self:IsDown() && !self.Dragging ) then
		self.Icon:StretchToParent( 6, 6, 6, 6 )
	else
		self.Icon:StretchToParent( 0, 0, 0, 0 )
	end

end

function PANEL:SetSpawnIcon( name )
	self.m_strIconName = name
	self.Icon:SetSpawnIcon( name )
end

function PANEL:SetBodyGroup( k, v )

	if ( k < 0 ) then return end
	if ( k > 9 ) then return end
	if ( v < 0 ) then return end
	if ( v > 9 ) then return end
	
	self.m_strBodyGroups = self.m_strBodyGroups:SetChar( k+1, v )

end

function PANEL:SetModel( mdl, iSkin, BodyGorups )

	if (!mdl) then debug.Trace() return end

	self:SetModelName( mdl )
	self:SetSkinID( iSkin )
	
	if ( tostring(BodyGorups):len() != 9 ) then
		BodyGorups = "000000000"
	end
	
	self.m_strBodyGroups = BodyGorups;

	self.Icon:SetModel( mdl, iSkin, BodyGorups )
	
	/*
	if ( iSkin && iSkin > 0 ) then
		self:SetToolTip( Format( "%s (Skin %i)", mdl, iSkin+1 ) )
	else
		self:SetToolTip( Format( "%s", mdl ) )
	end
	*/
end

function PANEL:RebuildSpawnIcon()

	self.Icon:RebuildSpawnIcon()

end

function PANEL:RebuildSpawnIconEx( t )

	self.Icon:RebuildSpawnIconEx( t )

end
vgui.Register( "NRP_SpawnIcon", PANEL, "DButton" )
