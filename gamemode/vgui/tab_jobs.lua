--[[
<xml>
	<module>
		<name>vgui_tab_jobs</name>
		<instance>CLIENT</instance>
		<require>menu_loader</require>
	</module>
</xml>
]]

local JOBTAB = {}
JOBTAB.name = "Jobs"
JOBTAB.icon = "icon16/user_red.png"

local drawFill = function( panel ) -- custom look for the Property Sheet Tabs.
	surface.SetDrawColor( panel.fillColor or Color( 255, 255, 255 ) )
	local x,y = panel:GetPos()
	local w, h = panel:GetSize()
	surface.DrawRect( 0, 0, w, h )
end

local JobInfo = nil

surface.CreateFont( "NRP_TeamTitleFont",
	{
		font      = "roboto",
		size      = 60,
		weight    = 100
	}
 )
surface.CreateFont( "NRP_TeamDesc",
	{
		font      = "roboto",
		size      = 18,
		weight    = 100
	}
 )
 
local function MakeTeamInfo( team, TeamIcon )
	JobInfo:Clear()
	local title = vgui.Create("DLabel", JobInfo )
	title:SetPos( 5, 5 )
	title:SetText( team.name )
	title:SetFont('NRP_TeamTitleFont')
	title:SetColor( Color( 0, 0, 0))
	title:SizeToContents( true )
	
	local desc = vgui.Create("DLabel", JobInfo )
	desc:SetText( team.desc or "<no description>" )
	desc:SetFont('NRP_TeamDesc')
	desc:SetColor( Color( 0, 0, 0))
	desc:SetWide( JobInfo:GetWide() - 10 )
	desc:SetAutoStretchVertical( true )
	desc:SetWrap( true )
	desc:InvalidateLayout()
	desc:SetPos( 5, 5 + title:GetTall() )
	

	local ModelPreview = vgui.Create( "DModelPanel", JobInfo )
	ModelPreview:SetSize( 300,300 )
	ModelPreview:SetPos( JobInfo:GetWide() / 2 - ModelPreview:GetWide() / 2, JobInfo:GetTall() - 300 )
	ModelPreview:SetModel( TeamIcon.team_models[1]) -- you can only change colors on playermodels
	ModelPreview.model_id = 1
	ModelPreview.DoClick = TeamIcon.ChangeTeam
	ModelPreview:SetToolTip("Click to change team with this model.")
	
	if( #TeamIcon.team_models <= 1 )then return end -- we dont need buttons to cycle through models for just one model... so we can stop here.
	
	local nextModel = vgui.Create("DButton", JobInfo)
	nextModel:SetText('Next')
	nextModel:SizeToContents()
	nextModel:SetPos(JobInfo:GetWide() - 50 - nextModel:GetWide(), JobInfo:GetTall() - 150 )
	nextModel.DoClick = function()
		ModelPreview.model_id = ModelPreview.model_id + 1
		if( ModelPreview.model_id > #TeamIcon.team_models )then
			ModelPreview.model_id = 1
		end
		TeamIcon.model_id = ModelPreview.model_id
		ModelPreview:SetModel( TeamIcon.team_models[ ModelPreview.model_id ] )
    end
	
	local prevModel = vgui.Create("DButton", JobInfo)
	prevModel:SetText('Prev')
	prevModel:SizeToContents()
	prevModel:SetPos( 50 , JobInfo:GetTall() - 150 )
	prevModel.DoClick = function()
		ModelPreview.model_id = ModelPreview.model_id - 1
		if( ModelPreview.model_id == 0 )then
			ModelPreview.model_id = #TeamIcon.team_models
		end
		TeamIcon.model_id = ModelPreview.model_id
		ModelPreview:SetModel( TeamIcon.team_models[ ModelPreview.model_id ] )
    end
end

local function CreateJobPanel( cteam, dlist )
	print("Building menu for team "..cteam.name)
	local icon = vgui.Create( "NRP_SpawnIcon" ) -- SpawnIcon
	local size = math.floor( dlist:GetWide() / 3 ) - dlist:GetSpacing()
	icon:SetSize( size, size )
	icon:InvalidateLayout( true ); 
	icon.team = cteam
	if( type( cteam.model ) == 'table' )then
		icon.team_models = cteam.model
	else
		icon.team_models = {cteam.model}
	end
	icon.model_id = math.random( 1, #icon.team_models )
	icon:SetModel( icon.team_models[ icon.model_id ] )
	icon:SetText( cteam.name )
	
	icon.ChangeTeam = function()
		LocalPlayer():ConCommand("say /"..cteam.name.." "..tostring( icon.model_id ) )
		NRP.mainmenu:Close()
	end
	icon:AddButton( "Join Team!", icon.ChangeTeam )
	
	function icon:OnCursorEntered()
		timer.Simple(0.2, function() -- if the cursor actually rests in side lets show the info. Otherwise it was just passing over.
			if( self.Hovered )then
				MakeTeamInfo( cteam, icon )
			end
		end)
	end
	return icon
end



JOBTAB.make = function( panel )
	local w, h = panel:GetWide(), panel:GetTall()
	local dlist = vgui.Create( "DPanelList", panel )
	dlist:SetPos( 5, 5 )
	dlist:SetSize( w / 2 - 3, h - 10)
	dlist:SetSpacing( 5 )
	dlist:EnableHorizontal( true )
	dlist:EnableVerticalScrollbar( true )
	panel.dlist = dlist
	
	local teams = NRP.GetAllTeams()
	local vteams = {} -- table of team VGUI panels.
	
	for k,v in pairs( teams )do
		local p = CreateJobPanel( v, dlist )
		dlist:AddItem( p )
		table.insert( vteams, p )
	end
	
	panel.vteams = vteams
	
	-- Job info panel.
	JobInfo = vgui.Create("DPanel", panel )
	JobInfo:SetPos( w / 2 + 5, 5 )
	JobInfo:SetSize( w / 2 - 3, h - 10)
end
JOBTAB.update = function( panel )
	
end
NRP.AddMenuTab( JOBTAB )