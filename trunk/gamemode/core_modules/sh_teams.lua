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
local teamPlayers = {} -- table of who's on what teams.

function NRP:GetTeamByID( teamid )
	return teams[ teamid ]
end
function NRP:GetAllTeams( )
	return teams
end

local plymeta = FindMetaTable("Player")
function plymeta:TeamTbl()
	return NRP:GetTeamByID( self:Team() )
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

-- FUNCTION FOR PLAYER CHAT COMMANDS TO CHANGE TEAMS.
local function ChangeTeamChatCMD( ply, tbl, arg)
	NRP:ChatMessage(ply,NRP.color.white, "You changed your job to ", tbl.color, tbl.name )
	NRP:Notice( player.GetAll(), 5, ply:Name().." changed his job to "..( tbl.name or 'unknown' ) )
	NRP:ChangeTeam( ply, tbl.id ) -- change the team
	if( arg )then -- allow model picker.
		if( string.match( arg, '[0-9]') == arg and tbl.model[ tonumber( arg ) ])then
			local m = tbl.model[ tonumber( arg ) ]
			ply:SetModel( m )
			ply.NRPModel = m
		else
			NRP:Notice( ply, 4, 'Invalid team model ID given.', NOTIFY_ERROR )
		end
	end
end

--[[
OTHER VALUES:
CustomCheck - function passed the player as the only arguement.
IsVisible - can it be seen on the menu. Default will be true.
MustChangeFrom - list of teams that are required to be this one.
HOOK_<name> - hooks coming soon
]]

function NRP:AddCustomTeam( name, tbl )
	NRP:MsgC(NRP.color.white,"Registered team "..name )
	tbl['name'] = name
	for k,v in pairs( requiredValues )do
		if( tbl[ v[1] ] == nil )then
			if( v[2] == nil )then
				NRP:MsgC( NRP.color.red, "TEAM ERROR: MISSING REQUIRED PROPERTY "..v[1].. " IN TEAM "..name )
				ErrorNoHalt("Team Error.")
				return
			else
				NRP:MsgC( NRP.color.orange, "Set Property "..v[1].." to default "..tostring( v[2]))
				tbl[ v[1] ] = v[2] 
			end
		end
	end
	tbl.id = #teams + 1
	teams[ tbl.id ] = tbl
	team.SetUp( tbl.id, tbl.name, tbl.color )
	if(SERVER)then
		NRP:AddChatCommand( tbl.command, function( ply, arg )
			local r, reason = hook.Call("NeoRP_CanChangeTeam", GAMEMODE, ply, tbl )
			if( r == nil or r == true )then
				ChangeTeamChatCMD( ply, tbl, arg )
			else
				NRP:Notice( ply, 6, reason or "Team change denied.", NOTIFY_ERROR )
			end
		end)
	end
	
	if( type( tbl.model ) == 'string')then
		util.PrecacheModel( tbl.model )
	end
	
	return tbl.id
end

-- raw set the team.
function NRP:SetPlayerTeam( ply, teamid )
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

-- set with other functionality.
function NRP:ChangeTeam( ply, teamid )
	if( NRP.cfg.RequireRespawn )then
		ply:Kill()
	else
		GAMEMODE:PlayerSpawn( ply )
	end
	NRP:SetPlayerTeam( ply, teamid )
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

function GM:PlayerInitialSpawn( ply )
	timer.Simple(1,function()
		NRP:SetPlayerTeam( ply, NRP.cfg.DefaultTeam)
		hook.Call("PlayerLoadout",GAMEMODE, ply)
	end)
end

function GM:PlayerLoadout( ply )
	ply:StripWeapons()
	ply:StripAmmo()
	
	local t = NRP:GetTeamByID( ply:Team() )
	for k,v in pairs( NRP.cfg.DefaultWeapons )do
		ply:Give( v )
	end
	if( t )then
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

if(SERVER)then
	local paydaytime = NRP.cfg.PayDayTimer
	timer.Create("NeoRP_PayDay",paydaytime, 0, function()
		for k,v in pairs( player.GetAll() )do
			local t = v:TeamTbl()
			if( t )then
				if( t.salery and t.salery > 0 )then
					v:GiveMoney( t.salery )
					NRP:Notice( v, 4, "Pay day! You recieved $"..t.salery.."!" )
				else
					NRP:Notice(v, 4, "Pay day skipped. You are unemployed.",NOTIFY_ERROR)
				end
			end
		end
	end)
end