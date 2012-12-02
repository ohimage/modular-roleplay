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
	self:SetText( "" )
	
	self.Icon = vgui.Create( "ModelImage", self )
	self.Icon:SetMouseInputEnabled( false )
	self.Icon:SetKeyboardInputEnabled( false )
	
	self:SetSize( 64, 64 )	
	
	self.m_strBodyGroups = "000000000";

end

function PANEL:DoRightClick()
end

function PANEL:DoClick()
end

function PANEL:Paint( w, h )
	if ( !self.Hovered ) then return end
end

function PANEL:PaintOver( w, h)

	self:DrawSelections()
	
	if ( !self.Hovered ) then return end
	
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetMaterial( matHover )
	self:DrawTexturedRect()

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
vgui.Register( "nrp_spawnicon", PANEL, "DButton" )
