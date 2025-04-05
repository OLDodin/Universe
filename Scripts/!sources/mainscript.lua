Global("g_debugSubsrb", false)
Global("g_tagTextValue", toWString("textViewValue"))

local IsAOPanelEnabled = true
local IsBtnInAOPanelNow = false
function onAOPanelStart( params )
	if IsAOPanelEnabled then
	
		local SetVal = { val = userMods.ToWString( "U") }
		local params = { header = SetVal, ptype = "button", size = 30 }
		userMods.SendEvent( "AOPANEL_SEND_ADDON",
			{ name = common.GetAddonName(), sysName = common.GetAddonName(), param = params } )

		DnD.HideWdg(getChild(mainForm, "UniverseButton"))
		IsBtnInAOPanelNow = true
	end
end

function onAOPanelLeftClick( params )
	if params.sender == common.GetAddonName() then
		SwapMainSettingsForm()
	end
end

function onAOPanelRightClick( params )
	if params.sender == common.GetAddonName() then
		local SetVal = { val = userMods.ToWString( "U" )}
		userMods.SendEvent( "AOPANEL_UPDATE_ADDON", { sysName = common.GetAddonName(), header = SetVal } )
	end
	
end

function onAOPanelChange( params )
	if params.state == ADDON_STATE_NOT_LOADED and string.find(params.name, "AOPanel") then
		DnD.ShowWdg(getChild(mainForm, "UniverseButton"))
		IsBtnInAOPanelNow = false
	end
end


function onInterfaceToggle(aParams)
	if aParams.toggleTarget == ENUM_InterfaceToggle_Target_All then
		if not IsBtnInAOPanelNow then
			if aParams.hide then
				DnD.HideWdg(getChild(mainForm, "UniverseButton"))
			else
				DnD.ShowWdg(getChild(mainForm, "UniverseButton"))
			end
		end
	end
end


local function Init()
	g_myAvatarID = avatar.GetId()
	GUIControllerInit()

	common.RegisterEventHandler( onAOPanelStart, "AOPANEL_START" )
	common.RegisterEventHandler( onAOPanelLeftClick, "AOPANEL_BUTTON_LEFT_CLICK" )
	common.RegisterEventHandler( onAOPanelRightClick, "AOPANEL_BUTTON_RIGHT_CLICK" )
	common.RegisterEventHandler( onAOPanelChange, "EVENT_ADDON_LOAD_STATE_CHANGED" )
	common.RegisterEventHandler( onInterfaceToggle, "EVENT_INTERFACE_TOGGLE" )
end


if (avatar.IsExist()) then
	Init()
else
	common.RegisterEventHandler(Init, "EVENT_AVATAR_CREATED")
end