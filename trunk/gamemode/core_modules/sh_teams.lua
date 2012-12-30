--[[
<xml>
	<module>
		<name>sh_teams</name>
		<author>TheLastPenguin</author>
		<desc>Functions to create and manage teams.</desc>
		<instance>SHARED</instance>
		<require>sh_notice,sv_chat</require>
	</module>
</xml>
]]

local teams = {}
local groups = {}
local teamPlayers = {} -- table of who's on what teams.

NRP.GetTeamByID = function( teamid )
	return teams[ teamid ]
end
NRP.GetAllTeams = function( )
	return teams
end
NRP.GetAllGroups = function()
	return groups
end

local plymeta = FindMetaTable("Player")
function plymeta:TeamTbl()
	return NRP.GetTeamByID( self:Team() )
end


-- FUNCTION FOR PLAYER CHAT COMMANDS TO CHANGE TEAMS.
local function ChangeTeamChatCMD( ply, tbl, arg)
	NRP.ChatMessage(ply,NRP.color.white, "You changed your job to ", tbl.color, tbl.name )
	NRP.Notice( player.GetAll(), 5, ply:Name().." changed his job to "..( tbl.name or 'unknown' ) )
	NRP.ChangeTeam( ply, tbl.id ) -- change the team
	if( arg )then -- allow model picker.
		if(tbl.model[ tonumber( arg ) ] ~= nil )then
			local m = tbl.model[ tonumber( arg ) ]
			ply:SetModel( m )
			ply.NRPModel = m
		else
			NRP.Notice( ply, 4, 'Invalid team model ID given.', NOTIFY_ERROR )
			print("INVALID MODEL ID ")
		end
	else	
		
	end
end

/*==================================================
Vote System
==================================================*/
local StartVote
if(SERVER)then
	util.AddNetworkString("NRP_StartTeamVote")
	util.AddNetworkString("NRP_TeamVoteSubmit")
	local votes = {}
	local curID = 0
	StartVote = function( ply, team, arg )
		local thisVoteID = curID
		curID = curID + 1
		-- open the vote menu on clients.
		net.Start("NRP_StartTeamVote")
			net.WriteInt( thisVoteID, 32 )
			votes[ thisVoteID ] = 0
			net.WriteEntity( ply )
			net.WriteInt( team.id, 32 )
		net.Send( player.GetAll() )
		
		-- process the vote results in 30 seconds.
		timer.Simple( 30, function()
			local count = votes[ thisVoteID ]
			votes[ thisVoteID ] = nil
			if( not IsValid( ply ) )then return end  
			local fraction = count / #player.GetAll()
			if( fraction >= 0.4 )then -- if they win we will check to make sure they can still change, then add them to team.
				local r, reason = hook.Call("NeoRP_CanChangeTeam", GAMEMODE, ply, team )
				if( r == nil or r == true )then
					ChangeTeamChatCMD( ply, team, arg )
				else
					NRP.Notice( ply, 6, reason or "Unable to change team. ERROR 912 (ERROR CODE NIL).", NOTIFY_ERROR )
				end
			else
				NRP.Notice( ply, 6, 'You were not voted in as '.. team.name, NOTIFY_ERROR)
			end
			ply:CoolDownTimer( 'JobVote', 80 )
		end)
	end
	
	net.Receive("NRP_TeamVoteSubmit", function( length, ply )
		if( length > 255 )then ply:Kick("BUFFER OVERFLOW.") end
		local voteID = net.ReadInt( 32 )
		local yes_no = net.ReadInt( 4 )
		if( not votes[ voteID ] )then return end
		if( yes_no == 0 )then
			print("Player "..ply:Name().." voted no.")
			votes[ voteID ] = votes[ voteID ] - 1
		else
			print("Player "..ply:Name().." voted yes.")
			votes[ voteID ] = votes[ voteID ] + 1
		end
	end)
elseif(CLIENT)then
	surface.CreateFont( "NRP_VoteFont",
		{
			font      = "roboto",
			size      = 20,
			weight    = 100
		}
	 )
	
	local vote_list = vgui.Create( "DPanelList", panel )
	vote_list:SetPos( 5, ScrH() / 3 )
	vote_list:SetSize( ScrW() / 3, 1000)
	vote_list:SetSpacing( 5 )
	vote_list:EnableHorizontal( true )
	vote_list.Paint = function() end
	vote_list:EnableVerticalScrollbar( false )
	
	net.Receive("NRP_StartTeamVote",function()
		local voteID = net.ReadInt( 32 )
		local ply = net.ReadEntity()
		local team = teams[ net.ReadInt( 32 ) ]
		if( not team )then return end
		if( not ply )then return end
		
		local panel = vgui.Create("DFrame")
		panel:SetSize( 150, 150 )
		panel:SetSkin("neorp")
		panel.voteID = voteID
		vote_list:AddItem( panel )
		panel.count = 30
		local function ChangeCounter( )
			if( not ValidPanel( panel ) )then return end
			panel:SetTitle("Time: "..panel.count )
			panel.count = panel.count - 1
			if( panel.count == 0 )then
				panel:Remove()
			else
				timer.Simple( 1, ChangeCounter )
			end
		end
		ChangeCounter()
		
		-- lastly since people like pictures right? well... lets give them a picture.
		local ModelPreview = vgui.Create( "DModelPanel", panel )
		ModelPreview:SetPos( 20, 40)
		ModelPreview:SetSize( 110,110 )
		local models = team.model
		if( type( models ) ~= 'table' )then
			models = { models }
		end
		ModelPreview:SetModel( models[ math.random(1,#models)] )
		
		-- vote buttons.
		local yes = vgui.Create("DButton", panel )
		yes:SetPos( 5, 150 - 30 )
		yes:SetSize( 50, 25 )
		yes:SetText("Yes")
		yes.DoClick = function()
			net.Start( "NRP_TeamVoteSubmit" )
				net.WriteInt( panel.voteID, 32 )
				net.WriteInt( 1, 4 )
			net.SendToServer( )
			panel:Close()
		end
		
		local no = vgui.Create("DButton", panel )
		no:SetPos( 150 - 55, 150 - 30 )
		no:SetSize( 50, 25 )
		no:SetText("No")
		no.DoClick = function()
			net.Start( "NRP_TeamVoteSubmit" )
				net.WriteInt( panel.voteID, 32 )
				net.WriteInt( 0, 4 )
			net.SendToServer( )
			panel:Close()
		end
		
		-- and people also should probably know who the player is and what the team is.
		local voteinfo = vgui.Create("DLabel", panel )
		voteinfo:SetPos( 5, 25 )
		voteinfo:SetText( team.name.."\n"..ply:Name() )
		voteinfo:SetFont('NRP_VoteFont')
		voteinfo:SetColor( Color( 0, 0, 0))
		voteinfo:SizeToContents( true )
	end)
end

local requiredValues = {
	{'name', nil },
	{'model', nil },
	{'vote', false },
	{'command', nil },
	{'color', Color(155,0,155) },
	{'limit',nil},
	{'salery',45}
}

--[[
OTHER VALUES:
CustomCheck - function passed the player as the only arguement.
IsVisible - can it be seen on the menu. Default will be true.
MustChangeFrom - list of teams that are required to be this one.
HOOK_<name> - hooks coming soon
]]

NRP.AddCustomTeam = function( name, tbl )
	tbl['name'] = name
	NRP.LoadMessage(NRP.color.white,"Registered team ", tbl.color or NRP.color.red, name )
	for k,v in pairs( requiredValues )do
		if( tbl[ v[1] ] == nil )then
			if( v[2] == nil )then
				NRP.LoadMessage( NRP.color.red, "TEAM ERROR: MISSING REQUIRED PROPERTY "..v[1].. " IN TEAM "..name )
				ErrorNoHalt("Team Error.")
				return
			else
				NRP.LoadMessage( NRP.color.grey, "Set Property "..v[1].." to default "..tostring( v[2]))
				tbl[ v[1] ] = v[2] 
			end
		end
	end
	tbl.id = #teams + 1
	teams[ tbl.id ] = tbl
	team.SetUp( tbl.id, tbl.name, tbl.color )
	if(SERVER)then
		NRP.AddChatCommand( tbl.command, function( ply, arg )
			local r, reason = hook.Call("NeoRP_CanChangeTeam", GAMEMODE, ply, tbl )
			if( r == nil or r == true )then
				if( tbl.vote == true )then
					StartVote( ply, tbl, arg )
				else
					ply:CoolDownTimer( 'JobVote', 40 )
					ChangeTeamChatCMD( ply, tbl, arg )
				end
			else
				NRP.Notice( ply, 6, reason or "Unable to change team. ERROR 912 (ERROR CODE NIL).", NOTIFY_ERROR )
			end
		end)
	end
	
	if( type( tbl.model ) == 'string')then
		util.PrecacheModel( tbl.model )
	end
	
	return tbl.id
end

NRP.AddTeamGroup = function( name, tbl )
	NRP.LoadMessage(NRP.color.white,"Registered team group ", name )
	tbl.name = name
	tbl.id = #groups + 1
	groups[ #groups + 1 ] = tbl
	return tbl.id
end

-- raw set the team.
NRP.SetPlayerTeam = function( ply, teamid )
	local curTeam = teams[ teamid ]
	if( not flags )then flags = {} end
	if( not curTeam )then
		ErrorNoHalt("Attempt to set team to invalid teamid.")
		return
	end
	ply:SetTeam( teamid )

	local model = nil
	if( type( curTeam.model ) == 'table' )then
		model = curTeam.model[math.random( 1, #(curTeam.model))]
	else
		model = curTeam.model
	end
	ply.NRPModel = model
	ply:SetModel( model )
end

-- this should be used to ensure players recieve all team items and proper checks are done.
NRP.ChangeTeam = function( ply, teamid )
	if( NRP.cfg.RequireRespawn )then
		ply:Kill()
	else
		GAMEMODE:PlayerSpawn( ply )
	end
	NRP.SetPlayerTeam( ply, teamid )
	GAMEMODE:PlayerSetModel( ply )
end

function GM:PlayerSpawn( ply )
	local curTeam = teams[ ply:Team() ]
	if( not curTeam )then return end
	-- other MISC properties.
	if( curTeam.JumpPower )then
		ply:SetJumpPower( curTeam.JumpPower )
	end
	if( curTeam.Gravity )then
		ply:SetGravity( curTeam.Gravity )
	end
	if( curTeam.ModelColor )then
		local c = curTeam.ModelColor
		ply:SetPlayerColor( Vector( c.r / 255, c.g / 255, c.b / 255 ) )
	end
	if( curTeam.PhysgunColor )then
		local c = curTeam.PhysgunColor
		ply:SetWeaponColor( Vector( c.r / 255, c.g / 255, c.b / 255 ) )
	else
		local col = curTeam.color
		ply:SetWeaponColor( Vector( col.r / 255, col.g / 255, col.b / 255 ) )
	end
	
	gamemode.Call("PlayerSetModel", ply)
	gamemode.Call("PlayerLoadout", ply)
	ply:AllowFlashlight(true)
	
	GAMEMODE:SetPlayerSpeed(ply, curTeam.WalkSpeed or NRP.cfg.WalkSpeed, curTeam.RunSpeed or NRP.cfg.WalkSpeed)
end

function GM:PlayerSetModel( ply )
	if( NRP.cfg.StrictModels )then
		ply:SetModel( ply.NRPModel )
	end
	return false
end

function GM:PlayerReadyForData( ply )
	NRP.SetPlayerTeam( ply, NRP.cfg.DefaultTeam)
	hook.Call("PlayerLoadout",GAMEMODE, ply)
end

function GM:PlayerLoadout( ply )
	ply:StripWeapons()
	ply:StripAmmo()
	
	local t = teams[ ply:Team() ]
	for k,v in pairs( NRP.cfg.DefaultWeapons )do
		ply:Give( v )
	end
	if( t )then
		print("Giving player team weapons!")
		if( not t.weapons )then return end
		if( type( t.weapons ) ~= 'table' )then return end
		for k,v in pairs( t.weapons )do
			ply:Give( v )
		end
	end
end

/*========================================
TEAM LIMITS AND OTHER SIMILAR RESTRICTIONS
========================================*/

-- make sure player isnt already that team.
hook.Add("NeoRP_CanChangeTeam","AlreadyAre",function( ply, tbl )
	if( ply:Team() == tbl.id )then
		return false, "You already are a "..tbl.name.."."
	end
end)

-- custom check.
hook.Add("NeoRP_CanChangeTeam","CustomCheck",function( ply, tbl )
	if( tbl.CustomCheck )then
		local res, reason = tbl.CustomCheck( ply, tbl )
		if( res )then
			return res, reason
		end
	end
end)

-- team limits.
hook.Add("NeoRP_CanChangeTeam","LimitReached",function( ply, tbl )
	if( tbl.limit < 0 )then
		return
	end
	local count = 0
	for k,v in pairs( player.GetAll() )do
		if( v:Team() == tbl.id )then
			count = count + 1
			if( count >= tbl.limit )then
				return false, "Team limit reached."
			end
		end
	end
	if( count >= tbl.limit )then
		return false, "Team limit reached."
	end
end)

-- must change from team.
hook.Add("NeoRP_CanChangeTeam","ChangeFrom",function( ply, tbl )
	if( tbl.ChangeFrom )then
		if( type( tbl.ChangeFrom ) ~= 'table' )then
			tbl.ChangeFrom = {tbl.ChangeFrom} -- just makes stuff easier.
		end
		local t = ply:Team() 
		for k,v in pairs( tbl.ChangeFrom )do
			if( t == v )then
				return nil
			end
		end
		local msg = {}
		for k,v in pairs( tbl.ChangeFrom )do
			table.insert( msg, v.name )
		end
		return false, string.format("You must be one of %s to be this team.", table.concat( msg, ', ' ) )
	else
		return
	end
end)

hook.Add("NeoRP_CanChangeTeam","CoolDown",function( ply, teamtbl )
	local res, remainder = ply:IsCooledDown('JobVote')
	if( res == false)then
		return false, "Please wait "..math.Round( remainder ).." seconds before changing your team."
	end
end)

if(SERVER)then
	local paydaytime = NRP.cfg.PayDayTimer
	timer.Create("NeoRP_PayDay",paydaytime, 0, function()
		for k,v in pairs( player.GetAll() )do
			local t = v:TeamTbl()
			if( t )then
				if( t.salery and t.salery > 0 )then
					v:GiveMoney( t.salery )
					NRP.Notice( v, 4, "Pay day! You recieved $"..t.salery.."!" )
				else
					NRP.Notice(v, 4, "Pay day skipped. You are unemployed.",NOTIFY_ERROR)
				end
			end
		end
	end)
end