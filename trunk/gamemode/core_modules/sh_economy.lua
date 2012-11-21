--[[
<xml>
	<module>
		<name>sh_economy</name>
		<author>TheLastPenguin</author>
		<desc>Client side chat system.</desc>
		<instance>SHARED</instance>
		<require>sh_player,sv_data,sv_chat,cl_chat,util</require>
	</module>
</xml>
]]
local PLYMETA = FindMetaTable('Player')

if(SERVER)then
	function PLYMETA:AddMoney( amount )
		self.SQLDATA.money = self.SQLDATA.money + amount
		self.NETDATA.money = self.SQLDATA.money
	end
	function PLYMETA:SetMoney( amount )
		self.SQLDATA.money = amount
		self.NETDATA.money = self.SQLDATA.money
	end
	function PLYMETA:TakeMoney( amount )
		self:AddMoney( -amount )
	end
	function PLYMETA:CanAfford( amount )
		return self.SQLDATA.money >= amount 
	end
	-- will automatically try to take payment, returns true on success. False on failur.
	function PLYMETA:ProcessPayment( amount )
		if( self:CanAfford( amount ))then
			self:TakeMoney( amount )
			return true
		else
			return false
		end
	end
	
	function NRP:CreateMoneyBag(pos, amount)
		local e = ents.Create("money")
		e:SetPos(pos)
		e.dt.amount = amount
		e:Spawn()
		e:Activate()
		return e
	end
	
	-- drop some money.
	NRP:AddChatCommand('dropmoney',function( ply, amount )
		if( not amount )then
			NRP:Notice( ply, 4, 'You must specify how much money to drop. EX: /dropmoney 100', NOTIFY_ERROR )
			return
		elseif( string.match( amount, '[0-9]*') ~= amount )then
			NRP:Notice( ply, 4, 'Amount must be a number. '.. string.match( amount, '[0-9]*'), NOTIFY_ERROR )
			return
		end
		local amount = tonumber( amount )
		if( amount <= 2 )then
			NRP:Notice( ply, 4, 'Amount must be greater than or equal to 2')
			return
		elseif( not ( ply:CanAfford( amount ) ) )then
			NRP:Notice( ply, 4, NRP:FormatString( "You can not afford to drop <cur>" .. amount .. "."), NOTIFY_ERROR )
			return
		end
		ply:TakeMoney( amount )
		NRP:CreateMoneyBag( ply:GetEyeTrace().HitPos, amount )
	end)
	
	-- give someone some money.
	NRP:AddChatCommand('give',function( ply, amount )
		if( not amount )then
			NRP:Notice( ply, 4, 'You must specify how much money to drop. EX: /dropmoney 100', NOTIFY_ERROR )
			return
		elseif( string.match( amount, '[0-9]*') ~= amount )then
			NRP:Notice( ply, 4, 'Amount must be a number.', NOTIFY_ERROR )
			return
		elseif( tonumber( amount ) <= 2 )then
			NRP:Notice( ply, 4, 'Amount must be greater than or equal to 2', NOTIFY_ERROR)
			return
		end
		if( not ply:CanAfford( amount ) )then
			NRP:Notice( ply, 4, 'You can not afford this.', NOTIFY_ERROR )
			return
		end
		local e = ply:GetEyeTrace().Entity
		if( not ( IsValid( e ) and e:IsPlayer() ))then
			NRP:Notice( ply, 4, 'You must be looking at a player.', NOTIFY_ERROR)
			return
		end
		e:AddMoney( tonumber( amount ) )
		ply:TakeMoney( tonumber( amount ) )
	end)
else
	NRP:ChatAutocomplete( 'dropmoney', '<amount to drop>' )
	NRP:ChatAutocomplete( 'give', function( cmd, text )
		local e = LocalPlayer():GetEyeTrace().Entity
		if( IsValid( e ) and e:IsPlayer() )then
			if( not ( text and tonumber( text ) > 0 ))then
				return '/give', 'Must specify amount to give.'
			end
			return '/give','Summery: Give $'..text..' to '..e:Name()
		else
			return '/give','You must be looking at a player.'
		end
	end)
	
end 