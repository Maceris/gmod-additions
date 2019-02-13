--[[----------------------------------------------------------------------------
Cached network strings
------------------------------------------------------------------------------]]

util.AddNetworkString( "SpawnWeapon" )
util.AddNetworkString( "ErrInvalidWeapName" )

--[[----------------------------------------------------------------------------
Message callbacks
------------------------------------------------------------------------------]]

function Msg_Rec_SpawnWeapon (len, pl) 
	local pla = player.GetBySteamID64 (pl:SteamID64())
	local name = net.ReadString()
	local weap_check = weapons.Get(name)
	if (weap_check == nil) then 
		net.Start("ErrInvalidWeapName")
		net.Send(pla)
		return
	end
	ForceWeapon( pla, name)
end

--[[----------------------------------------------------------------------------
Utility functions
------------------------------------------------------------------------------]]
function ForceWeapon (ply, weapon_name)
	local slot = weapons.Get(weapon_name).Kind
	RemoveWeapon(ply, slot)
	local weap_given = ply:Give(weapon_name)
	
	if (IsValid(weap_given)) then
		local ammo_type = weap_given:GetPrimaryAmmoType()
		local clip_sz = weap_given:GetMaxClip1()
		ply:GiveAmmo(clip_sz * 5, ammo_type)
	end
end

function RemoveWeapon (ply, slot)
	local weptbl = ply:GetWeapons() -- get all the weapons the player has

	for k, v in pairs( weptbl ) do -- loop through them
		if v.Kind == slot then
			ply:StripWeapon(v:GetClass())
			print(v)
			ply:RemoveAmmo(1000, v:GetPrimaryAmmoType())
		end 
	end

end

--[[----------------------------------------------------------------------------
Net message handlers
------------------------------------------------------------------------------]]
net.Receive( "SpawnWeapon", function (len, pl) Msg_Rec_SpawnWeapon(len, pl) end )