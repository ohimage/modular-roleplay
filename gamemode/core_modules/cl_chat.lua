--[[
<info>
<name>cl_chat</name>
<author>TheLastPenguin</author>
<desc>Client side chat system.</desc>
<instance>CLIENT</instance>
</info>
]]
if(SERVER)then return end

local autoComplete = {}

-- takes a command name not including / and a function as the arguements.
-- function returns the list header, and a list of autocomplete values.
-- see the OCC chat handler for an example.
function MORP:AddAutoCompleteHandler( cmd,func )
	autoComplete[ cmd ] = func
end

function GM:ChatTextChanged( text )
	text = string.Trim( text )
	if( text[1] == '/' )then
		-- find the first space, used to devide up command and the arguement.
		local space = string.find( text, ' ' )
		if( space )then -- if we find a space, then go about getting a more specialised list for that command.
			local command = string.sub( text, 2, space )
			print("Command is "..command )
		else -- we didnt find a space, so lets generate a list of commands they could be looking for instead.
			local options = {}
			for k,v in pairs( autoComplete )do
				if( string.find( k, text ) )then
					table.insert( options, k )
				end
			end
		end
	else
		return
	end
end

hook.Add("Think","MOUSENDSHIT",function()
	if( input.IsKeyDown( MOUSE_WHEEL_DOWN ) or input.IsKeyDown( MOUSE_WHEEL_UP ))then
		print("MOUSE WEEL!")
	end
end)

local function OCCHandler( arg )
	return 'Players Can Hear:', 'Everyone'
end

function MORP:AddAutoCompleteHandler( '//,func )