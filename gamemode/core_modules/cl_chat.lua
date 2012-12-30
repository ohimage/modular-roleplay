--[[
<xml>
	<module>
		<name>cl_chat</name>
		<author>TheLastPenguin</author>
		<desc>Client side chat system.</desc>
		<instance>CLIENT</instance>
		<require>sh_teams</require>
	</module>
</xml>
]]
if(SERVER)then return end

local autoComplete = {}

-- takes a command name not including / and a function as the arguements.
-- function returns the list header, and a list of autocomplete values.
-- see the OCC chat handler for an example.
NRP.ChatAutocomplete = function( cmd, value )
	if( not value )then
		Error("INVALID AUTOCOMPLETE VALUE")
		return
	end
	autoComplete[ cmd ] = value
end

surface.CreateFont( "NeoRP_ChatOptions", {
	font 		= "Arial",
	size 		= 20,
	weight 		= 500,
	antialias 	= true,
	outline 	= true
} )

local chatting = false
local options = {}
local titleColor = NRP.color.cyan
local title = "<no title>"
local ListWidth, ListHeight = 0, 0

local function CalculateListSize( )
	surface.SetFont( "NeoRP_ChatOptions" )
	local h = 0
	local maxWidth = 0
	for k,v in ipairs( options )do
		local wid, height = surface.GetTextSize( v )
		h = h + height
		maxWidth = math.max( maxWidth, wid )
	end
	return maxWidth, h
end

function SetListOptions( _title, _tbl )
	title = _title
	options = _tbl
	ListWidth, ListHeight = CalculateListSize()
end

function GM:HUDPaint( )
	if( not options )then return end
	if( type( options ) == 'string' )then options = { options } end
	if( not chatting )then return end
	surface.SetFont( "NeoRP_ChatOptions" )
	
	local x, y = chat.GetChatBoxPos()
	
	surface.SetTextColor( titleColor )
	surface.SetTextPos( x, y - ListHeight - 30 )
	surface.DrawText( title )
	
	surface.SetTextColor( NRP.color.white )
	y = y - ListHeight
	for k,v in ipairs( options )do
		local wid, height = surface.GetTextSize( v )
		surface.SetTextPos( x, y )
		surface.DrawText( v )
		y = y + height
	end
end

function GM:StartChat()
	options = {}
	chatting = true
	timer.Start("NeoRP_GenPlysCanHear")
end
function GM:FinishChat()
	timer.Stop("NeoRP_GenPlysCanHear")
	chatting = false
end

local timerFunc = function()
	local r = NRP.cfg.ChatRadious or 400
	local p = {}
	for k,v in pairs( player.GetAll() )do
		if( v:GetPos():Distance(LocalPlayer():GetPos() ) <= r )then
			table.insert( p, v:Name() )
		end
	end
	SetListOptions("Can Hear", p )
end
timerFunc()

timer.Destroy("NeoRP_GenPlysCanHear")
timer.Create("NeoRP_GenPlysCanHear",0.1,0, timerFunc)
timer.Stop("NeoRP_GenPlysCanHear")

local curCommand = nil
function GM:OnChatTab()
	if( options )then
		local res = curCommand or ''
		if( options[1] )then
			res = res .. ' ' .. options[1]
			table.insert( options, options[1] )
			table.remove( options[1], 1 )
		end
		return res
	end
end

function GM:ChatTextChanged( text )
	text = string.Trim( text )
	titleColor = NRP.color.cyan
	if( text[ 1 ] == '/' )then
		timer.Stop("NeoRP_GenPlysCanHear")
		local sp = string.find( text, ' ' )
		local cmd, arg = nil, nil
		if( not sp )then
			curCommand = nil
			cmd = string.lower( string.sub( text, 2 ) )
			local cmd_len = string.len( cmd )
			local list = {}
			for k,v in pairs( autoComplete )do
				if( cmd_len <= string.len( k ) and string.sub( k, 1, cmd_len ) == cmd )then
					table.insert( list, '/'..k )
				end
			end
			SetListOptions("Commands:", list )
		else
			cmd, arg = string.lower( string.sub( text, 2, sp - 1 ) ), string.sub( text, sp + 1)
			curCommand = cmd
			if( autoComplete[ cmd ] )then
				if( type( autoComplete[ cmd ] ) == 'function' )then
					title, options = autoComplete[ cmd ]( cmd, arg )
				else
					title = cmd
					options = tostring( autoComplete[ cmd ] )
				end
			else
				options = nil
			end
		end
	else
		curCommand = nil
		timer.Start("NeoRP_GenPlysCanHear")
	end
end
local oocAuto = function(cmd, arg)
	titleColor = NRP.color.green
	return 'Players Can Hear', {'Everyone'}
end
autoComplete['ooc'] = oocAuto
autoComplete['/'] = oocAuto

timer.Simple(0,function()
	for k,v in pairs( NRP.GetAllTeams() )do
		autoComplete[ v.command ] = 'Change team.'
	end
end)