--[[----------------------------------------------------------------------------
Debug console commands
------------------------------------------------------------------------------]]

concommand.Add("DBG_spawn_weapon", function(ply, cmd, args) 
	net.Start( "SpawnWeapon" )
	net.WriteString(args[1])
	net.SendToServer()
end)

concommand.Add("DBG_get_weapon_name", function() 
	print( LocalPlayer():GetActiveWeapon():GetClass() )
end)

concommand.Add("DBG_print_weapon_list", function() 
	for idc, weap in pairs(weapons.GetList()) do
		print(weap.ClassName)
	end
	PrintTable(weapons.GetList())
end)

--[[----------------------------------------------------------------------------
Net message handlers
------------------------------------------------------------------------------]]
net.Receive( "ErrInvalidWeapName", function (len, pl) 
	print("Invalid weapon name") 
end )

-- Creates an inventory frame and populates it with spawnable weapons
function CreateFrame()
	local Frame = vgui.Create( "DFrame" )
	Frame:SetPos(  ScrW() * 0.344, ScrH() * 0.222 )
	Frame:SetSize( ScrW() * 0.416, ScrH() * 0.554 )
	Frame:SetTitle( "Spawn window" )
	Frame:SetVisible( true )
	Frame:ShowCloseButton( true )
	Frame:MakePopup()
	function Frame:OnKeyCodeReleased(keyCode) 
		if (keyCode  == KEY_I ) then
			Frame:Close()
		end
	end
	
	local Scroll = vgui.Create( "DScrollPanel", Frame ) -- Create the Scroll panel
	Scroll:Dock( FILL )

	local List = vgui.Create( "DIconLayout", Scroll )
	List:Dock( FILL )
	List:SetSpaceY( 5 ) -- Sets the space in between the panels on the Y Axis by 5
	List:SetSpaceX( 5 ) -- Sets the space in between the panels on the X Axis by 5

	for idc, weap in pairs(weapons.GetList()) do
		if (weap.Icon == nil) then 
		else 
			local ListItem = List:Add( "DImageButton" ) 
			ListItem:SetSize( 80, 80 ) -- Set the size of it
			ListItem:SetMouseInputEnabled(true)
			ListItem:SetImage( weap.Icon )
			ListItem:SetTooltip(weap.PrintName)
			function ListItem:DoClick() -- Defines what should happen when the label is clicked
				net.Start( "SpawnWeapon" )
				net.WriteString(weap.ClassName)
				net.SendToServer()
			end
		end
	end

end

-- Allows 'i' to open inventory
hook.Add("PlayerButtonUp", "TestPBU", function(ply, btn)
	if not IsFirstTimePredicted() then return end
	if not IsValid( ply ) or ply != LocalPlayer() then return end
	
	if ( btn == KEY_I ) then
		CreateFrame()
	end
end)

