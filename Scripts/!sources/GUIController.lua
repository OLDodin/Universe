local m_raidSubSystemLoaded = false
local m_targetSubSystemLoaded = false
local m_buffGroupSubSystemLoaded = false
local m_bindSubSystemLoaded = false
local m_castSubSystemLoaded = false

local m_mainSettingForm = nil
local m_profilesForm = nil
local m_raidSettingsForm = nil
local m_targeterSettingsForm = nil
local m_configGroupBuffForm = nil
local m_progressCastSettingsForm = nil
local m_helpForm = nil
local m_playerShortInfoForm = nil
local m_raidPanel = nil
local m_progressActionPanel = nil
local m_progressBuffPanel = nil
local m_targetPanel = nil
local m_raidPartyButtons = nil
local m_buffsGroupParentForm=nil
local m_bindSettingsForm  = nil
local m_exportProfileForm = nil
local m_importProfileForm = nil
local m_importErrorForm = nil

local m_progressActionPanelList = {}
local m_progressBuffPanelList = {}
local m_raidPlayerPanelList = {}
local m_raidPlayerMovePanel = nil
local m_targeterPlayerPanelList = {}
local m_moveMode = false
local m_movingUniqueID = nil
local m_lastRaidPanelSize = {}
local m_lastTargetPanelSize = {}
local m_usedProgressCastPanelCnt = 0
Global("RAID_TYPE", 1)
Global("PARTY_TYPE", 2)
Global("SOLO_TYPE", 3)

Global("RAID_CLICK", 1)
Global("TARGETER_CLICK", 2)
Global("PROGRESSCAST_CLICK", 3)

local m_currentRaid = {}

local TARGETS_LIMIT = 12
local m_currTargetType = ALL_TARGETS
local m_lastTargetType = ALL_TARGETS
local m_targetUnitsByType = {}
local m_targetUnselectable = {}

local m_redrawPauseCnt = 0
local m_needRedrawTargeter = false
local m_targeterUnderMouseNow = false


function DeleteProfile(aWdg)
	local index = GetIndexForWidget(aWdg)
	
	local allProfiles = GetAllProfiles()
	DeleteContainer(allProfiles, aWdg, m_profilesForm)
	ProfileWasDeleted(index+1)
	if GetTableSize(allProfiles) == 0 then
		local defaultProfile = GetDefaultSettings()
		local currentDate = common.GetLocalDateTime()
		defaultProfile.name = "default_"..tostring(currentDate.y).."_"..tostring(currentDate.m).."_"..tostring(currentDate.d).."_"..tostring(currentDate.h)..":"..tostring(currentDate.m)..":"..tostring(currentDate.s)
		table.insert(allProfiles, defaultProfile)
	end
	SaveAllSettings(allProfiles)
	LoadLastUsedSetting()
	LoadForms()
	ReloadAll()
end
--[[
local function SaveAllByIndex(anIndex, aList)
	if not aList then 
		aList = GetAllProfiles()
	end

	aList[anIndex].mainFormSettings = SaveMainFormSettings(m_mainSettingForm)
	aList[anIndex].raidFormSettings = SaveRaidFormSettings(m_raidSettingsForm)
	aList[anIndex].targeterFormSettings = SaveTargeterFormSettings(m_targeterSettingsForm)
	aList[anIndex].buffFormSettings = SaveConfigGroupBuffsForm(m_configGroupBuffForm, true)
	aList[anIndex].bindFormSettings = SaveBindFormSettings(m_bindSettingsForm)
	aList[anIndex].castFormSettings = SaveProgressCastFormSettings(m_progressCastSettingsForm)
	aList[anIndex].version = GetSettingsVersion()
	--save profiles names
	SaveProfilesFormSettings(m_profilesForm, aList)
		
	SaveAllSettings(aList)
end
]]
function OnTalentsChanged()
	LoadLastUsedSetting()
	LoadForms()
	ReloadAll()
end

function ReloadAll()
	LoadLastUsedSetting()
	
	FabricClearAll()
	local profile = GetCurrentProfile()
	
	InitBuffConditionMgr()
	InitSpellConditionMgr()
	
	if profile.mainFormSettings.useRaidSubSystem then
		InitRaidSubSystem()
	else
		UnloadRaidSubSystem()
	end
	if profile.mainFormSettings.useTargeterSubSystem then
		InitTargeterSubSystem(true)
	else
		UnloadTargeterSubSystem()
	end
	if profile.mainFormSettings.useBuffMngSubSystem then
		InitGroupBuffSubSystem()
	else
		UnloadGroupBuffSubSystem()
	end
	if profile.mainFormSettings.useBindSubSystem then
		InitBindSubSystem()
	else
		UnloadBindSubSystem()
	end
	if profile.mainFormSettings.useCastSubSystem then
		InitCastSubSystem()
	else
		UnloadCastSubSystem()
	end
	
	
	TargetChanged()
end

function SaveProfileAs()
	local allProfiles = GetAllProfiles()
	local res = AddElementFromFormWithEditLine(allProfiles, m_profilesForm, getChild(m_profilesForm, "EditLine1"), getChild(m_profilesForm, "configProfilesContainer"))
	if res then
		local newProfileInd = GetTableSize(allProfiles)
		local newProfileName = allProfiles[newProfileInd].name
		allProfiles[newProfileInd] = deepCopyTable(GetCurrentProfile())
		allProfiles[newProfileInd].name = newProfileName
		SaveAllSettings(allProfiles)
	end
end

function LoadProfileBtnPressed(aWdg)
	LoadSettings(GetIndexForWidget(aWdg) + 1)
	LoadForms()
	ReloadAll()
	HideFormsOfUnusedSubsystems()
end

function SaveProfileBtnPressed(aWdg)
	local allProfiles = GetAllProfiles()
	SaveProfilesFormSettings(m_profilesForm, allProfiles)
	SaveAllSettings(allProfiles)
end

function ExportProfile(aWdg)
	local index = GetIndexForWidget(aWdg)
	
	SetEditText(m_exportProfileForm, ExportProfileByIndex(index+1))
end

function ImportProfile()
	local importedProfile = StartDeserialize(GetImportText(m_importProfileForm))
	if not importedProfile then
		DnD.ShowWdg(m_importErrorForm)
		return
	else	
		importedProfile.name = ConcatWString(toWString(importedProfile.name), userMods.ToWString("-import"))
		local allProfiles = GetAllProfiles()
		
		AddElementFromFormWithText(allProfiles, m_profilesForm, importedProfile.name, getChild(m_profilesForm, "configProfilesContainer"))
		
		allProfiles[GetTableSize(allProfiles)] = importedProfile
		SaveAllSettings(allProfiles)
		
		DnD.HideWdg(m_importProfileForm)
	end
end

function ShowImportProfile(aWdg)
	DnD.ShowWdg(m_importProfileForm)
end

function LoadForms()
	LoadMainFormSettings(m_mainSettingForm)
	LoadProfilesFormSettings(m_profilesForm)
	LoadRaidFormSettings(m_raidSettingsForm)
	LoadBindFormSettings(m_bindSettingsForm)
	LoadProgressCastFormSettings(m_progressCastSettingsForm)
	LoadTargeterFormSettings(m_targeterSettingsForm)
	LoadConfigGroupBuffsForm(m_configGroupBuffForm, 1, true)
end

function HideFormsOfUnusedSubsystems()
	local profile = GetCurrentProfile()
	if not profile.mainFormSettings.useRaidSubSystem then
		DnD.HideWdg(m_raidSettingsForm)
	end
	if not profile.mainFormSettings.useTargeterSubSystem then
		DnD.HideWdg(m_targeterSettingsForm)
	end
	if not profile.mainFormSettings.useBuffMngSubSystem then
		DnD.HideWdg(m_configGroupBuffForm)
	end
	if not profile.mainFormSettings.useBindSubSystem then
		DnD.HideWdg(m_bindSettingsForm)
	end
	if not profile.mainFormSettings.useCastSubSystem then
		DnD.HideWdg(m_progressCastSettingsForm)
	end
end

local function UndoSubsystemSettingsForm(aForm)
	local formName = getName(aForm)
	if formName == "bindSettingsForm" then
		LoadBindFormSettings(m_bindSettingsForm)
	elseif formName == "configGroupBuffsForm" then
		LoadConfigGroupBuffsForm(m_configGroupBuffForm, 1, true)
		UpdateVisibleForPanelFixed()
	elseif formName == "castSettingsForm" then
		LoadProgressCastFormSettings(m_progressCastSettingsForm)
		ProgressCastFixButtonChecked(getChild(m_progressCastSettingsForm, "progressCastFixButton"))
	elseif formName == "raidSettingsForm" then
		LoadRaidFormSettings(m_raidSettingsForm)
	elseif formName == "targeterSettingsForm" then
		LoadTargeterFormSettings(m_targeterSettingsForm)
	elseif formName == "mainSettingsForm" then
		LoadMainFormSettings(m_mainSettingForm)
	end
end

function UndoButtonPressed(aWdg) 
	DnD.SwapWdg(getParent(aWdg))
	UndoSubsystemSettingsForm(getParent(aWdg))
end

function SaveButtonPressed(aWdg)
	DnD.SwapWdg(getParent(aWdg))
	local index = GetCurrentProfileInd()
	local profilesList = GetAllProfiles()
	
	local nameSettingForm = getName(getParent(aWdg))
	if nameSettingForm == "bindSettingsForm" then
		profilesList[index].bindFormSettings = SaveBindFormSettings(m_bindSettingsForm)
	elseif nameSettingForm == "configGroupBuffsForm" then
		profilesList[index].buffFormSettings = SaveConfigGroupBuffsForm(m_configGroupBuffForm, true)
	elseif findSimpleString(nameSettingForm, "BuffGroup") then
		profilesList[index].buffFormSettings = SaveConfigGroupBuffsForm(m_configGroupBuffForm, false)
	elseif nameSettingForm == "castSettingsForm" or nameSettingForm == "ProgressActionPanel" or nameSettingForm == "ProgressBuffPanel" then
		profilesList[index].castFormSettings = SaveProgressCastFormSettings(m_progressCastSettingsForm)
	elseif nameSettingForm == "raidSettingsForm" then
		profilesList[index].raidFormSettings = SaveRaidFormSettings(m_raidSettingsForm)
	elseif nameSettingForm == "targeterSettingsForm" then
		profilesList[index].targeterFormSettings = SaveTargeterFormSettings(m_targeterSettingsForm)
	elseif nameSettingForm == "mainSettingsForm" then
		profilesList[index].mainFormSettings = SaveMainFormSettings(m_mainSettingForm)
	end
	profilesList[index].version = GetSettingsVersion()
	
	SaveAllSettings(profilesList)
	ReloadAll()
	
	if nameSettingForm == "mainSettingsForm" then
		HideFormsOfUnusedSubsystems()
	end
end

function SaveTargeterChanges()
	local profilesList = GetAllProfiles()
	profilesList[GetCurrentProfileInd()].targeterFormSettings = SaveTargeterFormSettings(m_targeterSettingsForm)
	SaveAllSettings(profilesList)
end

function SetColorBuffGroup(aWdg)
	CreateColorSettingsForBuffsGroupScroller(m_configGroupBuffForm, GetIndexForWidget(aWdg))
end

function SetColorBuffRaid(aWdg)
	CreateColorSettingsForRaidBuffScroller(m_raidSettingsForm, GetIndexForWidget(aWdg))
end

function SetColorBuffTargeter(aWdg)
	CreateColorSettingsForTargetBuffScroller(m_targeterSettingsForm, GetIndexForWidget(aWdg))
end

function ApplyColor(aWdg)
	local container = getParent(aWdg, 5)
	local containerName = getName(container)
	local index = GetIndexForWidget(aWdg)
	if containerName == "groupBuffContainer" then
		UpdateColorSettingsForBuffsGroupScroller(m_configGroupBuffForm, index)
	elseif containerName == "raidBuffContainer" then
		UpdateColorSettingsForRaidBuffScroller(m_raidSettingsForm, index)
	elseif containerName == "targetBuffContainer" then
		UpdateColorSettingsForTargetBuffScroller(m_targeterSettingsForm, index)
	end
end

function HelpButtonPressed()
	if not m_helpForm then 
		m_helpForm = CreateHelpForm() 
	end 
	DnD.SwapWdg(m_helpForm)
end

function ResetGroupBuffPanelPos(aWdg)
	if m_buffGroupSubSystemLoaded then
		ResetPanelPos(GetConfigGroupBuffsActiveNum())
	end
end

function ResetProgressCastPanelPos(aWdg)
	DnD.Remove(m_progressActionPanel)
	SetConfig("DnD:"..DnD.GetWidgetTreePath(m_progressActionPanel), {posX = 300, posY = 200, highPosX = 0, highPosY = 0})
	DnD.Init(m_progressActionPanel, getChild(m_progressActionPanel, "MoveModePanel"), true, false)
	
	DnD.Remove(m_progressBuffPanel)
	SetConfig("DnD:"..DnD.GetWidgetTreePath(m_progressBuffPanel), {posX = 300, posY = 250, highPosX = 0, highPosY = 0})
	DnD.Init(m_progressBuffPanel, getChild(m_progressBuffPanel, "MoveModePanel"), true, false)
end


function AddRaidBuffButton(aWdg)
	AddRaidBuffToSroller(m_raidSettingsForm)
end

function AddTargetBuffButton(aWdg)
	AddTargetBuffToSroller(m_targeterSettingsForm)
end

function AddTargetButton(aWdg)
	AddMyTargetsToSroller(m_targeterSettingsForm)
end

function AddBuffsGroupButton(aWdg)
	LoadConfigGroupBuffsForm(m_configGroupBuffForm, AddBuffsGroup(m_configGroupBuffForm))
end

function AddBuffsInsideGroupButton(aWdg)
	AddBuffsInsideGroupToSroller(m_configGroupBuffForm)
end

function AddIgnoreCastsButton(aWdg)
	AddIgnoreCastToSroller(m_progressCastSettingsForm)
end

function DeleteIgnoreCastElement(aWdg)
	DeleteIgnoreCastFromSroller(m_progressCastSettingsForm, aWdg)
end

function DeleteRaidBuffElement(aWdg)
	DeleteRaidBuffFromSroller(m_raidSettingsForm, aWdg)
end

function DeleteTargetBuffElement(aWdg)
	DeleteTargetBuffFromSroller(m_targeterSettingsForm, aWdg)
end

function DeleteMyTargetsElement(aWdg)
	DeleteMyTargetsFromSroller(m_targeterSettingsForm, aWdg)
end

local function SwapSettingsForm(aForm)
	if aForm:IsVisible() then
		UndoSubsystemSettingsForm(aForm)
	end
	DnD.SwapWdg(aForm)
end

function SwapRaidSettingsForm(aWdg)
	SwapSettingsForm(m_raidSettingsForm)
end

function SwapTargeterSettingsForm(aWdg)
	SwapSettingsForm(m_targeterSettingsForm)
end

function SwapProgressCastSettingsForm(aWdg)
	SwapSettingsForm(m_progressCastSettingsForm)
end

function SwapBindSettingsForm(aWdg)
	SwapSettingsForm(m_bindSettingsForm)
end

function SwapGroupBuffsSettingsForm(aWdg)
	if not m_configGroupBuffForm:IsVisible() then 
		LoadConfigGroupBuffsForm(m_configGroupBuffForm, 1, true)
	end
	SwapSettingsForm(m_configGroupBuffForm)
end

function SwapMainSettingsForm(aWdg)
	UpdateMainFormButtons(m_mainSettingForm)
	SwapSettingsForm(m_mainSettingForm)
end


function EditBuffGroup(aWdg, anIndex)
	LoadConfigGroupBuffsForm(m_configGroupBuffForm, anIndex)
end

function DeleteBuffsGroup(aWdg)
	SetVisibleForGroupBuffTopPanel(GetConfigGroupBuffsActiveNum(), false)
	DeleteCurrentBuffsGroup(m_configGroupBuffForm)
	LoadConfigGroupBuffsForm(m_configGroupBuffForm, 1)
end

function DeleteBuffInsideGroup(aWdg)
	DeleteBuffsInsideGroupFromSroller(m_configGroupBuffForm, aWdg)
end

function BuffOnMeChecked()
	ConfigGroupBuffsBuffOnMeChecked(m_configGroupBuffForm)
end

function BuffOnTargetChecked()
	ConfigGroupBuffsBuffOnTargetChecked(m_configGroupBuffForm)
end

function СolorDebuffButtonChecked()
	RaidSettingsСolorDebuffButtonChecked(m_raidSettingsForm)
end

function СheckFriendCleanableButtonChecked()
	RaidSettingsСheckFriendCleanableButtonChecked(m_raidSettingsForm)
end

function BuffsFixButtonChecked(aWdg)
	if not m_buffGroupSubSystemLoaded then
		return
	end
	SetVisibleForGroupBuffTopPanel(GetConfigGroupBuffsActiveNum(), getCheckBoxState(aWdg))
end

function ProgressCastFixButtonChecked(aWdg)
	if not m_castSubSystemLoaded then
		return
	end
	if getCheckBoxState(aWdg) then
		DnD.ShowWdg(getChild(m_progressActionPanel, "MoveModePanel"))
		DnD.ShowWdg(getChild(m_progressBuffPanel, "MoveModePanel"))
	else
		DnD.HideWdg(getChild(m_progressActionPanel, "MoveModePanel"))
		DnD.HideWdg(getChild(m_progressBuffPanel, "MoveModePanel"))
	end
end

function UseRaidSubSystemChecked()
	UpdateUseRaidSubSystemMainForm(m_mainSettingForm)
end

function UseTargeterSubSystemChecked()
	UpdateUseTargeterSubSystemMainForm(m_mainSettingForm)
end

function UseBuffMngSubSystemChecked()
	UpdateUseBuffMngSubSystemMainForm(m_mainSettingForm)
end

function UseBindSubSystemChecked()
	UpdateUseBindSubSystemMainForm(m_mainSettingForm)
end

function UseCastSubSystemChecked()
	UpdateUseProgressCastSubSystemMainForm(m_mainSettingForm)
end

local function HidePartyBtns()
	for i = 1, 4 do
		if m_raidPartyButtons[i].showed then
			m_raidPartyButtons[i].wdg:Show(false)
			m_raidPartyButtons[i].showed = false
		end
	end
end

local function ShowPartyBtns(aPartyCnt)
	for i = 1, aPartyCnt do
		if not m_raidPartyButtons[i].showed then
			m_raidPartyButtons[i].wdg:Show(true)
			m_raidPartyButtons[i].showed = true
		end
	end
end

local function OnRaidFilter(aParams)
	for i = 1, 4 do
		if aParams.widget:IsEqual(m_raidPartyButtons[i].wdg) then
			m_raidPartyButtons[i].active = not m_raidPartyButtons[i].active
			if m_raidPartyButtons[i].active then
				setBackgroundColor(m_raidPartyButtons[i].wdg, { r = 1; g = 1, b = 1; a = 1 })
			else
				setBackgroundColor(m_raidPartyButtons[i].wdg, { r = 0.3; g = 0.3; b = 0.3; a = 1 })
			end
		end
	end
	RaidChanged(nil, true)
end

local function OnShopChange()
	GetBuffConditionForRaid():SwitchShowShop()
	
	RaidChanged(nil, true)
end

local function OnAssertChange(aParams)
	local wdgOwnerName = getName(getParent(aParams.widget, 2))
	if wdgOwnerName == "ProgressActionPanel" or wdgOwnerName == "ProgressBuffPanel" then
		--пока не подтвердим пложение на обеих панельках не сбрасываем флаг перемещния
		if isVisible(m_progressActionPanel) and isVisible(m_progressBuffPanel) then
			DnD.HideWdg(getParent(aParams.widget, 2))
			return
		end
		SetProgressCastPanelFixed(m_progressCastSettingsForm)		
	else
		SetGroupBuffPanelFixed(getParent(aParams.widget, 2))
	end
	SaveButtonPressed(getParent(aParams.widget))
end

local function EditLineEsc(aParams)
	aParams.widget:SetFocus(false)
end

local function OnCheckChange()
	if raid.IsExist() then
		raid.StartReadyCheck()
	elseif group.IsExist() then
		group.StartReadyCheck()
	end
end

local function ReadyCheckEnded()
	HideReadyCheck()
end

local function ReadyCheckChanged()
	local checkInfo = nil
	if raid.IsExist() then
		checkInfo = raid.GetReadyCheckInfo()
	elseif group.IsExist() then
		checkInfo = group.GetReadyCheckInfo()
	end
	ShowReadyCheck(checkInfo, m_currentRaid)
end

local function ReadyCheckStarted()
	ReadyCheckChanged()
end

local function FindClickedInProgressCast(anWdg, aPanelList)
	for i=0, GetTableSize(aPanelList)-1 do
		local playerBar = aPanelList[i]
		if playerBar.isUsed and anWdg:IsEqual(playerBar.wdg) then
			return playerBar
		end
	end
end

local function FindClickedInTarget(anWdg)
	for i=0, GetTableSize(m_targeterPlayerPanelList)-1 do
		local playerBar = m_targeterPlayerPanelList[i]
		if playerBar.isUsed and anWdg:IsEqual(playerBar.wdg) then
			return playerBar
		end
	end
end

local function FindClickedInRaid(anWdg)
	for i=0, GetTableSize(m_raidPlayerPanelList)-1 do
		local subParty = m_raidPlayerPanelList[i]
		for j=0, GetTableSize(subParty)-1 do
			local playerBar = subParty[j]
			if playerBar.isUsed and anWdg:IsEqual(playerBar.wdg) then
				return playerBar
			end
		end
	end
end

local function FindMyUniqueIDInRaid()
	for i=0, GetTableSize(m_raidPlayerPanelList)-1 do
		local subParty = m_raidPlayerPanelList[i]
		for j=0, GetTableSize(subParty)-1 do
			local playerBar = subParty[j]
			if playerBar.isUsed and playerBar.playerID == avatar.GetId() then
				return playerBar.uniqueID
			end
		end
	end
end

local function FindClickedInRaidMove(anWdg)
	for i=0, GetTableSize(m_raidPlayerPanelList)-1 do
		local subParty = m_raidPlayerPanelList[i]
		for j=0, GetTableSize(subParty)-1 do
			local playerBar = subParty[j]
			if anWdg:IsEqual(playerBar.raidMoveWdg) then
				return i
			end
		end
	end
end

local function FindRaidMoveBarByCoordinateInRaid(aGlobalX, aGlobalY)
	if not m_moveMode then 
		return
	end
	
	for i=0, GetTableSize(m_raidPlayerPanelList)-1 do
		local subParty = m_raidPlayerPanelList[i]
		for j=0, GetTableSize(subParty)-1 do
			local playerBar = subParty[j]
			if playerBar.raidMoveWdg:IsVisible() then
				local realRect = playerBar.raidMoveWdg:GetRealRect()
				if realRect.x1 < aGlobalX and realRect.x2 > aGlobalX and realRect.y1 < aGlobalY and realRect.y2 > aGlobalY then
					return playerBar
				end
			end
		end
	end
end

local function FindBarByCoordinateInRaid(aGlobalX, aGlobalY)
	if not m_moveMode then 
		return
	end
	
	for i=0, GetTableSize(m_raidPlayerPanelList)-1 do
		local subParty = m_raidPlayerPanelList[i]
		for j=0, GetTableSize(subParty)-1 do
			local playerBar = subParty[j]
			if playerBar.isUsed then
				local realRect = playerBar.wdg:GetRealRect()
				if realRect.x1 < aGlobalX and realRect.x2 > aGlobalX and realRect.y1 < aGlobalY and realRect.y2 > aGlobalY then
					return playerBar
				end
			end
		end
	end
end

function TargetChanged()
	local targetID = avatar.GetTarget()
	local profile = GetCurrentProfile()
	if m_raidSubSystemLoaded and profile.raidFormSettings.highlightSelectedButton then
		for i=0, GetTableSize(m_raidPlayerPanelList)-1 do
			local subParty = m_raidPlayerPanelList[i]
			for j=0, GetTableSize(subParty)-1 do
				local playerBar = subParty[j]
				if targetID and playerBar.isUsed and targetID == playerBar.playerID then
					PlayerTargetsHighlightChanged(true, playerBar)
				elseif playerBar.highlight then
					PlayerTargetsHighlightChanged(false, playerBar)
				end
			end
		end
	end
	if m_targetSubSystemLoaded and profile.targeterFormSettings.highlightSelectedButton then
		for i=0, GetTableSize(m_targeterPlayerPanelList)-1 do
			local playerBar = m_targeterPlayerPanelList[i]
			if targetID and playerBar.isUsed and playerBar.playerID and targetID == playerBar.playerID then
				PlayerTargetsHighlightChanged(true, playerBar)
			elseif playerBar.highlight then
				PlayerTargetsHighlightChanged(false, playerBar)
			end
		end
	end
	if m_buffGroupSubSystemLoaded then
		SetGroupBuffPanelsInfoForTarget(targetID)
	end
	if m_castSubSystemLoaded then
		ShowProgressBuffForTarget(targetID, m_progressActionPanelList)
		ShowProgressBuffForTarget(targetID, m_progressBuffPanelList)
	end
end

local function MoveModeClick(aParams)
	local clickedPartyNum = FindClickedInRaidMove(aParams.widget)
	MoveTo(clickedPartyNum, m_movingUniqueID, FindMyUniqueIDInRaid())
	StopMove()
end


local function MakeBindAction(aParams, aPlayerBar, aLeftClick, aTypeBind)
	local profile = GetCurrentProfile()
	local isCtrl, isAlt, isShift = getModFromFlags(aParams.kbFlags)
	
	local actionType = DISABLE_CLICK
	local bindAction = nil
	if aTypeBind == RAID_CLICK then
		if aLeftClick then
			if isShift then
				actionType = profile.bindFormSettings.actionLeftSwitchRaidShift
				bindAction = profile.bindFormSettings.actionLeftRaidShiftBind
			elseif isAlt then
				actionType = profile.bindFormSettings.actionLeftSwitchRaidAlt
				bindAction = profile.bindFormSettings.actionLeftRaidAltBind
			elseif isCtrl then
				actionType = profile.bindFormSettings.actionLeftSwitchRaidCtrl
				bindAction = profile.bindFormSettings.actionLeftRaidCtrlBind
			else
				actionType = profile.bindFormSettings.actionLeftSwitchRaidSimple
				bindAction = profile.bindFormSettings.actionLeftRaidSimpleBind
			end
		else
			if isShift then
				actionType = profile.bindFormSettings.actionRightSwitchRaidShift
				bindAction = profile.bindFormSettings.actionRightRaidShiftBind
			elseif isAlt then
				actionType = profile.bindFormSettings.actionRightSwitchRaidAlt
				bindAction = profile.bindFormSettings.actionRightRaidAltBind
			elseif isCtrl then
				actionType = profile.bindFormSettings.actionRightSwitchRaidCtrl
				bindAction = profile.bindFormSettings.actionRightRaidCtrlBind
			else
				actionType = profile.bindFormSettings.actionRightSwitchRaidSimple
				bindAction = profile.bindFormSettings.actionRightRaidSimpleBind
			end
		end
	elseif aTypeBind == TARGETER_CLICK then
		if aLeftClick then
			if isShift then
				actionType = profile.bindFormSettings.actionLeftSwitchTargetShift
				bindAction = profile.bindFormSettings.actionLeftTargetShiftBind
			elseif isAlt then
				actionType = profile.bindFormSettings.actionLeftSwitchTargetAlt
				bindAction = profile.bindFormSettings.actionLeftTargetAltBind
			elseif isCtrl then
				actionType = profile.bindFormSettings.actionLeftSwitchTargetCtrl
				bindAction = profile.bindFormSettings.actionLeftTargetCtrlBind
			else
				actionType = profile.bindFormSettings.actionLeftSwitchTargetSimple
				bindAction = profile.bindFormSettings.actionLeftTargetSimpleBind
			end
		else
			if isShift then
				actionType = profile.bindFormSettings.actionRightSwitchTargetShift
				bindAction = profile.bindFormSettings.actionRightTargetShiftBind
			elseif isAlt then
				actionType = profile.bindFormSettings.actionRightSwitchTargetAlt
				bindAction = profile.bindFormSettings.actionRightTargetAltBind
			elseif isCtrl then
				actionType = profile.bindFormSettings.actionRightSwitchTargetCtrl
				bindAction = profile.bindFormSettings.actionRightTargetCtrlBind
			else
				actionType = profile.bindFormSettings.actionRightSwitchTargetSimple
				bindAction = profile.bindFormSettings.actionRightTargetSimpleBind
			end
		end
	elseif aTypeBind == PROGRESSCAST_CLICK then
		if aLeftClick then
			if isShift then
				actionType = profile.bindFormSettings.actionLeftSwitchProgressCastShift
				bindAction = profile.bindFormSettings.actionLeftProgressCastShiftBind
			elseif isAlt then
				actionType = profile.bindFormSettings.actionLeftSwitchProgressCastAlt
				bindAction = profile.bindFormSettings.actionLeftProgressCastAltBind
			elseif isCtrl then
				actionType = profile.bindFormSettings.actionLeftSwitchProgressCastCtrl
				bindAction = profile.bindFormSettings.actionLeftProgressCastCtrlBind
			else
				actionType = profile.bindFormSettings.actionLeftSwitchProgressCastSimple
				bindAction = profile.bindFormSettings.actionLeftProgressCastSimpleBind
			end
		else
			if isShift then
				actionType = profile.bindFormSettings.actionRightSwitchProgressCastShift
				bindAction = profile.bindFormSettings.actionRightProgressCastShiftBind
			elseif isAlt then
				actionType = profile.bindFormSettings.actionRightSwitchProgressCastAlt
				bindAction = profile.bindFormSettings.actionRightProgressCastAltBind
			elseif isCtrl then
				actionType = profile.bindFormSettings.actionRightSwitchProgressCastCtrl
				bindAction = profile.bindFormSettings.actionRightProgressCastCtrlBind
			else
				actionType = profile.bindFormSettings.actionRightSwitchProgressCastSimple
				bindAction = profile.bindFormSettings.actionRightProgressCastSimpleBind
			end
		end
	end
	
	if actionType == DISABLE_CLICK then
		return
	end
	
	if actionType == TARGET_CLICK and isExist(aPlayerBar.playerID) then
		selectTarget(unit.GetTarget(aPlayerBar.playerID))
	elseif actionType == SELECT_CLICK then
		selectTarget(aPlayerBar.playerID)
	elseif actionType == MENU_CLICK then
		ShowMenu(aPlayerBar, aParams, m_raidPanel, m_lastRaidPanelSize, avatar.GetUniqueId())
	elseif actionType == RESSURECT_CLICK and isExist(aPlayerBar.playerID) and object.IsDead(aPlayerBar.playerID) then
		ressurect(aPlayerBar.playerID)
	end

	if not isExist(aPlayerBar.playerID) then 
		return nil 
	end
	
	if bindAction and not bindAction:IsEmpty() then
		local res = cast(bindAction, aPlayerBar.playerID) or useItem(bindAction, aPlayerBar.playerID)
	end
end

local function OnPlayerSelect(aParams, aLeftClick)
	local playerBar = FindClickedInRaid(aParams.widget)
	if playerBar then
		if not m_moveMode then
			--if playerBar.playerID then
				if m_bindSubSystemLoaded then
					MakeBindAction(aParams, playerBar, aLeftClick, RAID_CLICK)
				else	
					if aLeftClick then
						selectTarget(playerBar.playerID)
					else
						ShowMenu(playerBar, aParams, m_raidPanel, m_lastRaidPanelSize, avatar.GetUniqueId())
					end
				end
			--end
		else
			SwapPlayers(m_movingUniqueID, playerBar.uniqueID, avatar.GetUniqueId())
			StopMove()
		end		
		return
	end

	if aLeftClick or m_bindSubSystemLoaded then
		local typeBind = TARGETER_CLICK
		playerBar = FindClickedInTarget(aParams.widget)
		if not playerBar then
			playerBar = FindClickedInProgressCast(aParams.widget, m_progressActionPanelList) or FindClickedInProgressCast(aParams.widget, m_progressBuffPanelList)
			typeBind = PROGRESSCAST_CLICK
		end
		if playerBar then
			if m_bindSubSystemLoaded then
				MakeBindAction(aParams, playerBar, aLeftClick, typeBind)
			else
				selectTarget(playerBar.playerID)
			end
		end
	end
	
	
end

local function OnLeftClick(aParams)
	OnPlayerSelect(aParams, true)
end

local function OnRightClick(aParams)
	OnPlayerSelect(aParams, false)
end

local function OnPlayerBarPointing(aParams)
	local playerBar = nil
	playerBar = FindClickedInRaid(aParams.widget)
	m_targeterUnderMouseNow = false
	if not playerBar then
		playerBar = FindClickedInTarget(aParams.widget)
		if playerBar then
			m_targeterUnderMouseNow = aParams.active
		end
	end
	if playerBar then
		if aParams.active then
			show(playerBar.rollOverHighlightWdg)
		else
			hide(playerBar.rollOverHighlightWdg)
		end
	end

	if not aParams.active then
		hide(m_playerShortInfoForm)
		return
	end
	
	local profile = GetCurrentProfile()
	if not profile.raidFormSettings.showRollOverInfo and not m_targeterUnderMouseNow then
		return
	end
	if not profile.targeterFormSettings.showRollOverInfo and m_targeterUnderMouseNow then
		return
	end
	
	if playerBar and not m_moveMode and playerBar.playerID then
		InitPlayerShortInfoForm(playerBar.playerID)
		show(m_playerShortInfoForm)
	end
end

local function TargetLockChanged(aParams)
	TargetLockBtn(m_targetPanel)
end

local function CreateProgressCastCache(aPanelList, aParentWdg)
	local profile = GetCurrentProfile()
	for i = 0, PROGRESS_PANELS_LIMIT do
		aPanelList[i] = CreateProgressCastPanel(aParentWdg, i)
		if profile.castFormSettings.selectable then
			aPanelList[i].wdg:SetTransparentInput(false)
		else
			aPanelList[i].wdg:SetTransparentInput(true)
		end
	end
end

local function GetProgressCastPanelCastedByMe(aPanelList)
	local profile = GetCurrentProfile()
	local panelHeight = tonumber(profile.castFormSettings.panelHeightText)
	
	local cnt = 0
	for i = 0, PROGRESS_PANELS_LIMIT do
		if aPanelList[i].isUsed and aPanelList[i].castedByMe then
			if not profile.castFormSettings.showOnlyMyTarget or IsProgressCastPanelVisible(aPanelList[i]) then
				return aPanelList[i]
			end
		end
	end
end

local function UpdatePositionProgressCastPanels(aPanelList)
	local profile = GetCurrentProfile()
	local panelHeight = tonumber(profile.castFormSettings.panelHeightText)
	
	local cnt = 0
	local panelCastedByMe = GetProgressCastPanelCastedByMe(aPanelList)
	if panelCastedByMe then
		move(panelCastedByMe.wdg, 0, 40)
		cnt = 1
	end
	for i = 0, PROGRESS_PANELS_LIMIT do
		if aPanelList[i].isUsed and not aPanelList[i].castedByMe then
			if not profile.castFormSettings.showOnlyMyTarget or IsProgressCastPanelVisible(aPanelList[i]) then
				local posY = 40 + cnt*(panelHeight+1)
				move(aPanelList[i].wdg, 0, posY)
				cnt = cnt + 1
			end
		end
	end
end

local function GetProgressCastPanel(anID, aPanelList)
	for i = 0, PROGRESS_PANELS_LIMIT do
		if aPanelList[i].isUsed and aPanelList[i].playerID == anID then
			return aPanelList[i]
		end
	end
end

local function GetFreeProgressCastPanel(aPanelList)
	for i = 0, PROGRESS_PANELS_LIMIT do
		if not aPanelList[i].isUsed then
			return aPanelList[i]
		end
	end
end

local function ClearProgressPanelOnEndAnimationInPanelList(aParams, aPanelList)
	if aParams.effectType ~= ET_RESIZE then
		return
	end
	for i = 0, PROGRESS_PANELS_LIMIT do
		if aPanelList[i].isUsed and equals(aParams.wtOwner, aPanelList[i].barWdg) then
			ClearProgressCastPanel(aPanelList[i])
			UpdatePositionProgressCastPanels(aPanelList)
			break
		end
	end
end

local function ClearProgressPanelOnEndAnimation(aParams)
	ClearProgressPanelOnEndAnimationInPanelList(aParams, m_progressActionPanelList)
	ClearProgressPanelOnEndAnimationInPanelList(aParams, m_progressBuffPanelList)
end

function ShowProgressBuffForTarget(aTargetID, aPanelList)
	local profile = GetCurrentProfile()
	if not profile.castFormSettings.showOnlyMyTarget then
		return
	end
	for i = 0, PROGRESS_PANELS_LIMIT do
		if aPanelList[i].isUsed then
			if aPanelList[i].playerID == aTargetID then
				SetProgressCastPanelVisible(aPanelList[i], true)
			else
				SetProgressCastPanelVisible(aPanelList[i], false)
			end
		end
	end
	UpdatePositionProgressCastPanels(aPanelList)
end

local function CreateRaidPanelCache()
	local profile = GetCurrentProfile()
	m_raidPlayerMovePanel = CreatePlayerPanel(m_raidPanel, 0, 0, true, profile.raidFormSettings, 111)
	m_raidPlayerMovePanel.wdg:SetTransparentInput(true)
	for i = 0, 3 do
		m_raidPlayerPanelList[i] = {}
		for j = 0, 5 do
			local playerPanel = CreatePlayerPanel(m_raidPanel, i, j, true, profile.raidFormSettings, (i+1)*(j+1))
			DnD.Init(m_raidPlayerMovePanel.wdg, playerPanel.wdg, false)
			DnD.Enable(playerPanel.wdg, false)
			m_raidPlayerPanelList[i][j] = playerPanel
		end
	end
end

local function ResizePanelForm(aGroupsCnt, aMaxPeopleCnt, aFormSettings, aForm, aLastSize, aFormReacting)
	local panelWidth = tonumber(aFormSettings.raidWidthText)
	local panelHeight = tonumber(aFormSettings.raidHeightText)
	local width = 0
	local height = 30
	if aFormSettings.gorisontalModeButton then
		width = width + aMaxPeopleCnt*panelWidth
		height = height + aGroupsCnt*panelHeight
	else 
		width = width + aGroupsCnt*panelWidth
		height = height + aMaxPeopleCnt*panelHeight
	end
	if aLastSize.w ~= width or aLastSize.h ~= height then
		aLastSize.w = width
		aLastSize.h = height
	
		width = math.max(200, width)
		height = math.max(370, height)
		resize(aForm, width, height)
		DnD.Remove(aForm)
		DnD.Init(aForm, aFormReacting, true, true, {0,-(width-200),-(height-60),0})
		
	end
end

local function ResizeTargetPanel(aGroupsCnt, aMaxPeopleCnt)
	local profile = GetCurrentProfile()
	ResizePanelForm(aGroupsCnt, aMaxPeopleCnt, profile.targeterFormSettings, m_targetPanel, m_lastTargetPanelSize, getChild(m_targetPanel, "TopTargeterPanel"))
	ApplyTargetSettingsToGUI(m_targetPanel)
end

local function ResizeRaidPanel(aGroupsCnt, aMaxPeopleCnt)
	local profile = GetCurrentProfile()
	ResizePanelForm(aGroupsCnt, aMaxPeopleCnt, profile.raidFormSettings, m_raidPanel, m_lastRaidPanelSize, getChild(m_raidPanel, "TopPanel"))
	ApplyRaidSettingsToGUI(m_raidPanel)
end

local function ShowMoveIfNeeded()
	if not m_moveMode then
		return
	end
	HideMove()
	local members = GetRaidMembersInOldFormat()
	local maxPeopleCnt = 0
	local partyCnt = GetTableSize(members)
	
	local currGroupSize = getGroupSizeFromPersId(m_movingUniqueID)
	local currGroupNum = getGroupFromPersId(m_movingUniqueID)
			
	for i=0, partyCnt-1 do
		local subParty = members[i]
		maxPeopleCnt = math.max(maxPeopleCnt, GetTableSize(subParty))
		local peopleCnt = GetTableSize(subParty)
		if peopleCnt < 6 and (currGroupNum and i < currGroupNum or currGroupSize and currGroupSize > 1) and currGroupNum ~= i then	
			DnD.ShowWdg(m_raidPlayerPanelList[i][peopleCnt].raidMoveWdg)
			maxPeopleCnt = maxPeopleCnt + 1
		end
	end
	if partyCnt < 4 and currGroupSize and currGroupSize > 1 then
		local subParty = members[partyCnt]
		DnD.ShowWdg(m_raidPlayerPanelList[partyCnt][0].raidMoveWdg)
		partyCnt = partyCnt + 1
	end
	
	ResizeRaidPanel(partyCnt, maxPeopleCnt)
end

function HideHighlight()
	for i=0, GetTableSize(m_raidPlayerPanelList)-1 do
		local subParty = m_raidPlayerPanelList[i]
		for j=0, GetTableSize(subParty)-1 do
			local playerBar = subParty[j]
			hide(playerBar.rollOverHighlightWdg)
			hide(playerBar.raidMoveHighlightWdg)
		end
	end
end

function OnDragTo(aParams)
	if not m_moveMode then
		return
	end
	local playerBar = FindBarByCoordinateInRaid(aParams.posX, aParams.posY)
	HideHighlight()
	if playerBar then
		show(playerBar.rollOverHighlightWdg)
	else
		playerBar = FindRaidMoveBarByCoordinateInRaid(aParams.posX, aParams.posY)
		if playerBar then
			show(playerBar.raidMoveHighlightWdg)
		end
	end
end

function OnDragEnd(aParams)
	if not m_moveMode then
		return
	end

	if aParams.targetWidget then
		local playerBar = FindClickedInRaid(aParams.targetWidget)
		if playerBar then
			SwapPlayers(m_movingUniqueID, playerBar.uniqueID, avatar.GetUniqueId())
		else
			local clickedPartyNum = FindClickedInRaidMove(aParams.targetWidget)
			if clickedPartyNum ~= nil then
				MoveTo(clickedPartyNum, m_movingUniqueID, avatar.GetUniqueId())
			end
		end
	end
	StopMove()
end

function OnDragCancelled()
	StopMove()
end

function OnDNDPickAttempt(aParams)
	local playerBar = FindClickedInRaid(aParams.srcWidget)
	local profile = GetCurrentProfile()
	if playerBar then
		CloneBaseInfoPlayerPanel(playerBar, m_raidPlayerMovePanel)
		
		show(m_raidPlayerMovePanel.wdg)
		priority(m_raidPlayerMovePanel.wdg, 300)
		local panelWidth = tonumber(profile.raidFormSettings.raidWidthText)
		local panelHeight = tonumber(profile.raidFormSettings.raidHeightText)
		local realRect = m_raidPlayerMovePanel.wdg:GetRealRect()
		local localPlacement = m_raidPlayerMovePanel.wdg:GetPlacementPlain()
		move(m_raidPlayerMovePanel.wdg
		, aParams.posX - realRect.x1 + localPlacement.posX - panelWidth/2
		, aParams.posY - realRect.y1 + localPlacement.posY - panelHeight/2)
		StartMove(playerBar.uniqueID)
	end
end

function OnInterfaceToggle(aParams)
	if aParams.toggleTarget == ENUM_InterfaceToggle_Target_All then
		if aParams.hide then
			DnD.HideWdg(m_raidPanel)
			DnD.HideWdg(m_targetPanel)
			DnD.HideWdg(m_buffsGroupParentForm)
			DnD.HideWdg(m_progressActionPanel)
			DnD.HideWdg(m_progressBuffPanel)
		else
			if m_raidSubSystemLoaded then
				DnD.ShowWdg(m_raidPanel)
			end
			if m_targetSubSystemLoaded then
				DnD.ShowWdg(m_targetPanel)
			end
			if m_buffGroupSubSystemLoaded then
				DnD.ShowWdg(m_buffsGroupParentForm)
			end
			if m_castSubSystemLoaded then
				DnD.ShowWdg(m_progressActionPanel)
				DnD.ShowWdg(m_progressBuffPanel)
			end
		end
	end
end

local function BuildRaidGUI(aCurrentRaid, aReusedRaidListeners)
	local profile = GetCurrentProfile()
	
	if aCurrentRaid.type == SOLO_TYPE then
		local playerInfo = {}
		playerInfo.id = avatar.GetId()
		playerInfo.name = object.GetName(playerInfo.id)
		playerInfo.state = GROUP_MEMBER_STATE_NEAR
		playerInfo.className = unit.GetClass(playerInfo.id).className
		m_raidPlayerPanelList[0][0].isUsed = true
		SetBaseInfoPlayerPanel(m_raidPlayerPanelList[0][0], playerInfo, true, profile.raidFormSettings, FRIEND_PANEL)
		FabricMakeRaidPlayerInfo(playerInfo.id, m_raidPlayerPanelList[0][0])
		ResizeRaidPanel(1, 1)
	elseif aCurrentRaid.type == PARTY_TYPE then
		local leaderInd = group.GetLeaderIndex()
		for i=0, GetTableSize(aCurrentRaid.members)-1 do
			local playerInfo = aCurrentRaid.members[i]
			if m_raidPartyButtons[1].active then
				local playerBar = m_raidPlayerPanelList[0][i]
				playerBar.isUsed = true
				if (playerInfo.id and not aReusedRaidListeners[playerInfo.id]) or not playerInfo.id then
					SetBaseInfoPlayerPanel(playerBar, playerInfo, (i == leaderInd),  profile.raidFormSettings, FRIEND_PANEL)
					if playerInfo.state == GROUP_MEMBER_STATE_OFFLINE then 
						playerInfo.id = nil
					end
				
					FabricMakeRaidPlayerInfo(playerInfo.id, playerBar)
				end
			end
		end
		ResizeRaidPanel(1, GetTableSize(aCurrentRaid.members))
	elseif aCurrentRaid.type == RAID_TYPE then
		local maxPeopleCnt = 0
		local maxPartyCnt = GetTableSize(aCurrentRaid.members)
		local raidLeaderID = raid.GetLeader()
		local partyCnt = 0
		for i=0, GetTableSize(aCurrentRaid.members)-1 do
			local subParty = aCurrentRaid.members[i]
			maxPeopleCnt = math.max(maxPeopleCnt, GetTableSize(subParty))
			if not m_raidPartyButtons[i+1].active or m_moveMode then
				maxPartyCnt = maxPartyCnt - 1
			end
			
			if m_raidPartyButtons[i+1].active or m_moveMode then
				for j=0, GetTableSize(subParty)-1 do
					local playerInfo = subParty[j]
					local playerBar = m_raidPlayerPanelList[partyCnt][j]
					playerBar.isUsed = true
					if (playerInfo.id and not aReusedRaidListeners[playerInfo.id]) or not playerInfo.id then
						SetBaseInfoPlayerPanel(playerBar, playerInfo, playerInfo.uniqueId:IsEqual(raidLeaderID),  profile.raidFormSettings, FRIEND_PANEL)
						if playerInfo.state == RAID_MEMBER_STATE_OFFLINE then 
							playerInfo.id = nil
						end
					
						FabricMakeRaidPlayerInfo(playerInfo.id, playerBar)
					end
				end
				partyCnt = partyCnt + 1
			end
		end
		ResizeRaidPanel(maxPartyCnt, maxPeopleCnt)
		ShowMoveIfNeeded()
	end
	TargetChanged()
end

local function FindMemberStateByUniqueID(aList, anUnuqueID)
	if not anUnuqueID then
		return nil
	end
	for i = 0, GetTableSize(aList) do
		if aList[i] and anUnuqueID:IsEqual(aList[i].uniqueId) then
			return aList[i].state
		end
	end
	return nil
end

function HideReadyCheck()
	for i=0, GetTableSize(m_raidPlayerPanelList)-1 do
		local subParty = m_raidPlayerPanelList[i]
		for j=0, GetTableSize(subParty)-1 do
			local playerBar = subParty[j]
			HideReadyStateInGUI(playerBar)
		end
	end
end

function ShowReadyCheck(aCheckInfo, aCurrentRaid)
	if not aCheckInfo then
		return
	end
	if not aCheckInfo.isInProgress then
		return
	end
	
	if aCurrentRaid.type == PARTY_TYPE then
		for i=0, GetTableSize(aCurrentRaid.members)-1 do
			local playerInfo = aCurrentRaid.members[i]
			local playerReadyState = FindMemberStateByUniqueID(aCheckInfo.members, playerInfo.uniqueId)
			ShowReadyStateInGUI(m_raidPlayerPanelList[0][i], playerReadyState)
		end
		ResizeRaidPanel(1, GetTableSize(aCurrentRaid.members))
	elseif aCurrentRaid.type == RAID_TYPE then
		for i=0, GetTableSize(aCurrentRaid.members)-1 do
			local subParty = aCurrentRaid.members[i]
			for j=0, GetTableSize(subParty)-1 do
				local playerInfo = subParty[j]
				local playerReadyState = FindMemberStateByUniqueID(aCheckInfo.members, playerInfo.uniqueId)
				ShowReadyStateInGUI(m_raidPlayerPanelList[i][j], playerReadyState)
			end
		end
	end
end

function RaidChanged(aParams, aFullUpdate)
	local prevRaidType = m_currentRaid.type
	local prevRaidMembers = m_currentRaid.members
	local prevLeaderUniqueID = m_currentRaid.currentLeaderUniqueID
	if raid.IsExist() then
		local members = GetRaidMembersInOldFormat()
		m_currentRaid.type = RAID_TYPE
		m_currentRaid.members = members
		m_currentRaid.currentLeaderUniqueID = raid.GetLeader()
		ShowPartyBtns(GetTableSize(members))
	elseif group.IsExist() then
		local members = group.GetMembers()
		m_currentRaid.type = PARTY_TYPE
		m_currentRaid.members = members
		m_currentRaid.currentLeaderUniqueID = group.GetLeaderUniqueId()
		ShowPartyBtns(1)
		StopMove()
	else
		m_currentRaid.type = SOLO_TYPE
		m_currentRaid.members = {}
		m_currentRaid.currentLeaderUniqueID = nil
		StopMove()
		HidePartyBtns()
	end

	local reusedRaidListeners = {}
	if not aFullUpdate and m_currentRaid.type == prevRaidType and m_currentRaid.type ~= SOLO_TYPE and prevLeaderUniqueID and prevLeaderUniqueID:IsEqual(m_currentRaid.currentLeaderUniqueID) then
		if raid.IsExist() then
			for i=0, GetTableSize(prevRaidMembers)-1 do
				local subParty = prevRaidMembers[i]
				for j=0, GetTableSize(subParty)-1 do
					local prevRaidMember = subParty[j]
					if m_currentRaid.members and m_currentRaid.members[i] then
						local newRaidMember = m_currentRaid.members[i][j]	
						local playerBar = m_raidPlayerPanelList[i][j]
						if prevRaidMember.id then
							local noChangesInPos = newRaidMember and prevRaidMember and newRaidMember.id == prevRaidMember.id and newRaidMember.state == prevRaidMember.state and playerBar.isPlayerExist == isExist(prevRaidMember.id)
							if not noChangesInPos then
								UnsubscribeRaidListeners(prevRaidMember.id)
							else
								reusedRaidListeners[prevRaidMember.id] = true
							end
						end
					end
				end
			end
		elseif group.IsExist() then
			for j=0, GetTableSize(prevRaidMembers)-1 do
				local prevRaidMember = prevRaidMembers[j]
				local newRaidMember = m_currentRaid.members and m_currentRaid.members[j]		
				
				if prevRaidMember.id then
					local noChangesInPos = newRaidMember and prevRaidMember and newRaidMember.id == prevRaidMember.id and newRaidMember.state == prevRaidMember.state 
					if not noChangesInPos then
						UnsubscribeRaidListeners(prevRaidMember.id)
					else
						reusedRaidListeners[prevRaidMember.id] = true
					end
				end
			end
		end
	else
		UnsubscribeRaidListeners()
	end
	
	for i=0, GetTableSize(m_raidPlayerPanelList)-1 do
		local subParty = m_raidPlayerPanelList[i]
		for j=0, GetTableSize(subParty)-1 do
			local playerBar = subParty[j]
			playerBar.isUsed = false
		end
	end

	BuildRaidGUI(m_currentRaid, reusedRaidListeners)
	ReadyCheckChanged()

	local canMovePlayers = CanMovePlayers(avatar.GetUniqueId())
	for i=0, GetTableSize(m_raidPlayerPanelList)-1 do
		local subParty = m_raidPlayerPanelList[i]
		for j=0, GetTableSize(subParty)-1 do
			local playerBar = subParty[j]
			if not playerBar.isUsed then
				playerBar.playerID = nil
				DnD.HideWdg(playerBar.wdg)
				hide(playerBar.rollOverHighlightWdg)
			else
				DnD.Enable(playerBar.wdg, canMovePlayers)
			end
		end
	end
	
	FabricDestroyUnused()
end

function HideMove()
	if m_moveMode then
		for i=0, GetTableSize(m_raidPlayerPanelList)-1 do
			local subParty = m_raidPlayerPanelList[i]
			for j=0, GetTableSize(subParty)-1 do
				local playerBar = subParty[j]
				DnD.HideWdg(playerBar.raidMoveWdg)
			end
		end
	end
end

function StopMove()
	if m_moveMode then
		mission.DNDCancelDrag()
		DnD.OnDragCancelled()
	end
	HideMove()
	if m_raidPlayerMovePanel then 
		hide(m_raidPlayerMovePanel.wdg)
	end
	m_moveMode = false
	m_movingUniqueID = nil
end

function StartMove(anUniqueID)
	if not raid.IsExist() and not group.IsExist() then 
		m_moveMode = false 
		return 
	end

	m_moveMode = true
	m_movingUniqueID = anUniqueID
	
	--ShowMoveIfNeeded()
	RaidChanged(nil, true)
end


local function SortByObjID(A, B)
	return A.objID < B.objID
end

local function SortByName(A, B)
	if A.objNameLower < B.objNameLower then
		return true
	elseif A.objNameLower == B.objNameLower then
		return A.objID < B.objID
	end
	return false
end

local function SortByWeight(A, B)
	return A.sortWeight < B.sortWeight
end

local function EraseTargetInListTarget(anObjID, aType)
	local objArr = m_targetUnitsByType[aType]
	for i=1, GetTableSize(objArr) do
		if objArr[i].objID == anObjID then
			table.remove(objArr, i)
			return
		end
	end
	
end

local function EraseTarget(anObjID)
	if not anObjID then
		return
	end
	if not m_targetSubSystemLoaded then
		return
	end
	EraseTargetInListTarget(anObjID, ENEMY_PLAYERS_TARGETS)
	EraseTargetInListTarget(anObjID, FRIEND_PLAYERS_TARGETS)
	EraseTargetInListTarget(anObjID, NEITRAL_PLAYERS_TARGETS)
	EraseTargetInListTarget(anObjID, ENEMY_MOBS_TARGETS)
	EraseTargetInListTarget(anObjID, FRIEND_MOBS_TARGETS)
	EraseTargetInListTarget(anObjID, NEITRAL_MOBS_TARGETS)
	EraseTargetInListTarget(anObjID, ENEMY_PETS_TARGETS)
	EraseTargetInListTarget(anObjID, FRIEND_PETS_TARGETS)
	EraseTargetInListTarget(anObjID, MY_SETTINGS_TARGETS)
	
	m_targetUnselectable[anObjID] = nil
end

local function FindInListTarget(anObjID, anObjArr)
	for _, info in ipairs(anObjArr) do
		if info.objID == anObjID then
			return true
		end
	end
	return false
end

local function FindTarget(anObjID)
	if not m_targetSubSystemLoaded then
		return
	end
	local res = FindInListTarget(anObjID, m_targetUnitsByType[ENEMY_PLAYERS_TARGETS])
	res = res or FindInListTarget(anObjID, m_targetUnitsByType[FRIEND_PLAYERS_TARGETS])
	res = res or FindInListTarget(anObjID, m_targetUnitsByType[NEITRAL_PLAYERS_TARGETS])
	res = res or FindInListTarget(anObjID, m_targetUnitsByType[ENEMY_MOBS_TARGETS])
	res = res or FindInListTarget(anObjID, m_targetUnitsByType[FRIEND_MOBS_TARGETS])
	res = res or FindInListTarget(anObjID, m_targetUnitsByType[NEITRAL_MOBS_TARGETS])
	res = res or FindInListTarget(anObjID, m_targetUnitsByType[ENEMY_PETS_TARGETS])
	res = res or FindInListTarget(anObjID, m_targetUnitsByType[FRIEND_PETS_TARGETS])
	res = res or FindInListTarget(anObjID, m_targetUnitsByType[MY_SETTINGS_TARGETS])
	
	return res
end

local function AddTargetInList(aNewTargetInfo, anObjArr)
	if not anObjArr then
		return
	end
	
	table.insert(anObjArr, aNewTargetInfo)
	table.sort(anObjArr, SortByObjID)
end

local function SetNecessaryTargets(anObjID, anInCombat)
	if not object.IsExist(anObjID) then
		return
	end
	local profile = GetCurrentProfile()
	local isPlayer = unit.IsPlayer(anObjID)
	local isPet = isPlayer and false or unit.IsPet(anObjID)
	local isCanSelect = unit.CanSelectTarget(anObjID)
	if profile.targeterFormSettings.hideUnselectableButton and not isPlayer and not isPet then
		if not isCanSelect then
			m_targetUnselectable[anObjID] = true
			return
		end
	end
	m_targetUnselectable[anObjID] = nil
	
	local isEnemy = object.IsEnemy(anObjID)
	local isFriend = isEnemy and false or object.IsFriend(anObjID)
	local isNeitral = not isEnemy and not isFriend
	
	local newValue = {}
	newValue.objID = anObjID
	newValue.inCombat = anInCombat
	newValue.isCanSelect = ((isPlayer or isCanSelect) and 0) or 1


	newValue.objName = object.GetName(newValue.objID)
	newValue.objNameLower = toLowerString(newValue.objName)

	if profile.targeterFormSettings.sortByClass then
		newValue.className = unit.GetClass(anObjID).className
		newValue.classPriority = g_classPriority[newValue.className] or g_classPriority["UNKNOWN"]
	end
	if profile.targeterFormSettings.sortByDead then
		if object.IsDead(anObjID) then
			newValue.isDead = 1
		else
			newValue.isDead = 0
		end
	end
	if profile.targeterFormSettings.sortByHP then
		local healthInfo = object.GetHealthInfo(anObjID)
		newValue.hp = healthInfo and healthInfo.valuePercents
	end
	if isEnemy then
		newValue.relationType = ENEMY_PANEL
	elseif isFriend then
		newValue.relationType = FRIEND_PANEL
	else
		newValue.relationType = NEITRAL_PANEL
	end

	local objArr = nil

	if isPlayer then
		if isEnemy then
			objArr = m_targetUnitsByType[ENEMY_PLAYERS_TARGETS]
		elseif isFriend then
			objArr = m_targetUnitsByType[FRIEND_PLAYERS_TARGETS]
		else
			objArr = m_targetUnitsByType[NEITRAL_PLAYERS_TARGETS]
		end
	end
	AddTargetInList(newValue, objArr)
	objArr = nil
	if not isPlayer then
		if isEnemy then
			objArr = m_targetUnitsByType[ENEMY_MOBS_TARGETS]
		elseif isFriend then
			objArr = m_targetUnitsByType[FRIEND_MOBS_TARGETS]
		else
			objArr = m_targetUnitsByType[NEITRAL_MOBS_TARGETS]
		end
	end
	AddTargetInList(newValue, objArr)
	objArr = nil
	if isPet then
		if isEnemy then
			objArr = m_targetUnitsByType[ENEMY_PETS_TARGETS]
		elseif isFriend then
			objArr = m_targetUnitsByType[FRIEND_PETS_TARGETS]
		end
	end
	AddTargetInList(newValue, objArr)
	
	objArr = m_targetUnitsByType[MY_SETTINGS_TARGETS]
	for _, targetsFromSettings in  ipairs(profile.targeterFormSettings.myTargets) do
		if not FindInListTarget(anObjID, objArr) and newValue.objNameLower == targetsFromSettings.nameLowerStr then
			AddTargetInList(newValue, objArr)
		end
	end
end

local function CreateTargeterPanelCache()
	local profile = GetCurrentProfile()
	if profile.targeterFormSettings.targetLimit then
		TARGETS_LIMIT = tonumber(profile.targeterFormSettings.targetLimit)
	else
		TARGETS_LIMIT = 12
	end
		
	for i = 0, TARGETS_LIMIT-1 do
		local playerPanel = CreatePlayerPanel(m_targetPanel, 0, i, false, profile.targeterFormSettings, i)
		m_targeterPlayerPanelList[i] = playerPanel
		if profile.targeterFormSettings.twoColumnMode then
			align(playerPanel.wdg, WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW)
		end
	end
	
	if profile.targeterFormSettings.twoColumnMode then
		for i = TARGETS_LIMIT, TARGETS_LIMIT*2-1 do
			local playerPanel = CreatePlayerPanel(m_targetPanel, 1, i, false, profile.targeterFormSettings, i)
			m_targeterPlayerPanelList[i] = playerPanel
			if profile.targeterFormSettings.twoColumnMode then
				align(playerPanel.wdg, WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW)
			end
		end
	end
end

local function ClearTargetPanels()
	UnsubscribeTargetListener()
	
	for i = 0, GetTableSize(m_targeterPlayerPanelList)-1 do
		local playerBar = m_targeterPlayerPanelList[i]
		DnD.HideWdg(playerBar.wdg)
		hide(playerBar.rollOverHighlightWdg)
		playerBar.playerID = nil
	end
	
	FabricDestroyUnused()
end

local function LoadTargeterData()	
	if m_currTargetType == TARGETS_DISABLE then
		return
	end
	
	m_targetUnitsByType[ENEMY_PLAYERS_TARGETS] = {}
	m_targetUnitsByType[FRIEND_PLAYERS_TARGETS] = {}
	m_targetUnitsByType[NEITRAL_PLAYERS_TARGETS] = {}
	m_targetUnitsByType[ENEMY_MOBS_TARGETS] = {}
	m_targetUnitsByType[FRIEND_MOBS_TARGETS] = {}
	m_targetUnitsByType[NEITRAL_MOBS_TARGETS] = {}
	m_targetUnitsByType[ENEMY_PETS_TARGETS] = {}
	m_targetUnitsByType[FRIEND_PETS_TARGETS] = {}
	m_targetUnitsByType[MY_SETTINGS_TARGETS] = {}

	
	local profile = GetCurrentProfile()
	local isCombat = false
	local unitList = avatar.GetUnitList()
	table.insert(unitList, avatar.GetId())
	for _, objID in pairs(unitList) do
		if profile.targeterFormSettings.twoColumnMode then
			isCombat = object.IsInCombat(objID)
		end
		SetNecessaryTargets(objID, isCombat)
	end
	
	RedrawTargeter(m_currTargetType, true)
end

local function TargetWorkSwitch()
	if m_currTargetType ~= TARGETS_DISABLE then
		m_lastTargetType = m_currTargetType
		m_currTargetType = TARGETS_DISABLE
		ResizeTargetPanel(1, 0)
		SwitchTargetsBtn(TARGETS_DISABLE)
		ClearTargetPanels()
		
		HideTargetDropDownSelectPanel()
		
		UpdateLastTargetType(m_lastTargetType)
		UpdateLastTargetWasActive(false)		
	else
		m_currTargetType = m_lastTargetType
		LoadTargeterData()
		
		UpdateLastTargetWasActive(true)
	end
	SaveTargeterChanges()
end

local function SelectTargetTypePressed(aWdg, anIndex)
	HideTargetDropDownSelectPanel()
	
	if m_currTargetType == TARGETS_DISABLE then
		return
	end
		
	m_currTargetType = anIndex-1
	RedrawTargeter(m_currTargetType, true)
	UpdateLastTargetType(m_currTargetType)
	SaveTargeterChanges()
end

local function SeparateTargeterPanelList(anObjList, aPanelListShift)
	local findedList = {} 
	local freeList = {}
	for i = aPanelListShift, TARGETS_LIMIT+aPanelListShift-1 do
		local playerBar = m_targeterPlayerPanelList[i]
		local found = false
		for _, info in ipairs(anObjList) do
			if playerBar.playerID == info.objID
			and (playerBar.formSettings.classColorModeButton or playerBar.panelColorType == info.relationType)
			then
				findedList[playerBar.playerID] = playerBar
				found = true
				break
			end			
		end
		if not found then
			table.insert(freeList, playerBar)
		end
	end
	return findedList, freeList
end

local function SortBySettings(anArr)
	local profile = GetCurrentProfile()

	if profile.targeterFormSettings.sortByName then
		table.sort(anArr, SortByName)
	end
	for i, info in ipairs(anArr) do
		info.sortWeight = i
	end
		
	if profile.targeterFormSettings.sortByHP then
		for _, info in ipairs(anArr) do
			info.sortWeight = info.sortWeight + info.hp * TARGETS_LIMIT
		end
	end
	local classShiftMult = 101 * TARGETS_LIMIT
	if profile.targeterFormSettings.sortByClass then
		for _, info in ipairs(anArr) do
			info.sortWeight = info.sortWeight + info.classPriority * classShiftMult
		end
	end
	
	local selectShiftMult = classShiftMult * (GetTableSize(g_classPriority) + 1)
	for _, info in ipairs(anArr) do
		info.sortWeight = info.sortWeight + info.isCanSelect * selectShiftMult
	end
	
	local deadShiftMult = selectShiftMult * 2
	if profile.targeterFormSettings.sortByDead then
		for _, info in ipairs(anArr) do
			info.sortWeight = info.sortWeight + info.isDead * deadShiftMult
		end
	end
	
	table.sort(anArr, SortByWeight)
end

local function SortAndSetTarget(aTargetUnion, aPanelListShift, aPanelPosShift)
	local cnt = 0
	local listOfObjToUpdate = {}
	local newTargeterPlayerPanelList = {}
	local listOfObjForType = {}
	local profile = GetCurrentProfile()
	local playerBar = nil
	--формируем список для отображения
	for _, unitsByType in ipairs(aTargetUnion) do
		SortBySettings(unitsByType)
		for _, targetInfo in pairs(unitsByType) do
			local objID = targetInfo.objID
			if cnt < TARGETS_LIMIT and isExist(objID) then
				table.insert(listOfObjForType, targetInfo)
				cnt = cnt + 1
			end
		end
	end
	--находим панели уже отображаемых игроков
	local reusedPanels, freePanels = SeparateTargeterPanelList(listOfObjForType, aPanelListShift)
	local freePanelInd = 1
	cnt = aPanelListShift
	--собираем панели в новом порядке, используя как подходящие так и обновляя инфу
	for _, targetInfo in ipairs(listOfObjForType) do
		local objID = targetInfo.objID
		playerBar = reusedPanels[objID]
		if not playerBar then
			playerBar = freePanels[freePanelInd]
			freePanelInd = freePanelInd + 1
			if playerBar.playerID then
				UnsubscribeTargetListener(playerBar.playerID)
			end
			local updateInfo = {}
			updateInfo.playerBar = playerBar
			updateInfo.objID = objID
			updateInfo.objName = targetInfo.objName
			updateInfo.relationType = targetInfo.relationType
			table.insert(listOfObjToUpdate, updateInfo)
		end
		playerBar.isUsed = true
		m_targeterPlayerPanelList[cnt] = playerBar

		cnt = cnt + 1
	end
	--в список всех панелей добавляем все оставшиеся
	for _, bar in pairs(freePanels) do
		if not bar.isUsed then
			m_targeterPlayerPanelList[cnt] = bar
			cnt = cnt + 1
		end
	end
	--обновляем инфу на панелях
	for _, updateInfo in pairs(listOfObjToUpdate) do
		local playerInfo = {}
		playerInfo.id = updateInfo.objID
		playerInfo.name = updateInfo.objName
		playerInfo.state = GROUP_MEMBER_STATE_NEAR
		SetBaseInfoPlayerPanel(updateInfo.playerBar, playerInfo, false,  profile.targeterFormSettings, updateInfo.relationType)
		FabricMakeTargetPlayerInfo(playerInfo.id, updateInfo.playerBar)
	end

	--расставляем панели и скрываем не используемые
	for i = aPanelListShift, TARGETS_LIMIT+aPanelListShift-1 do
		playerBar = m_targeterPlayerPanelList[i]
		
		ResetPlayerPanelPosition(playerBar, aPanelPosShift, i-aPanelListShift, profile.targeterFormSettings)
		if not playerBar.isUsed then
			if playerBar.playerID then
				UnsubscribeTargetListener(playerBar.playerID)
				DnD.HideWdg(playerBar.wdg)
				hide(playerBar.rollOverHighlightWdg)
			end
			playerBar.playerID = nil
		end
	end
	return cnt-aPanelListShift
end

local function GetArrByCombatStatus(aStatus, aType)
	local objArr = m_targetUnitsByType[aType]
	local resultArr = {}
	for _, info in ipairs(objArr) do
		if info.inCombat == aStatus then
			table.insert(resultArr, info)
		end
	end
	return resultArr
end

local function MakeTargetUnion(aType, aStatus)
	local targetUnion = {}
	if aType == ALL_TARGETS then
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, ENEMY_PLAYERS_TARGETS))
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, NEITRAL_PLAYERS_TARGETS))
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, FRIEND_PLAYERS_TARGETS))
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, ENEMY_MOBS_TARGETS))
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, NEITRAL_MOBS_TARGETS))
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, FRIEND_MOBS_TARGETS))
	elseif aType == ENEMY_TARGETS then
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, ENEMY_PLAYERS_TARGETS))
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, ENEMY_MOBS_TARGETS))
	elseif aType == FRIEND_TARGETS then
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, FRIEND_PLAYERS_TARGETS))
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, FRIEND_MOBS_TARGETS))
	elseif aType == NOT_FRIENDS_TARGETS then
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, ENEMY_PLAYERS_TARGETS))
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, NEITRAL_PLAYERS_TARGETS))
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, ENEMY_MOBS_TARGETS))
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, NEITRAL_MOBS_TARGETS))
	elseif aType == NOT_FRIENDS_PLAYERS_TARGETS then	
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, ENEMY_PLAYERS_TARGETS))
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, NEITRAL_PLAYERS_TARGETS))
	else
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, aType))
	end
	return targetUnion
end

function TryRedrawTargeter(aType)
	if not m_targeterUnderMouseNow then
		RedrawTargeter(aType)
		m_needRedrawTargeter = false
		m_redrawPauseCnt = 0
	else
		m_needRedrawTargeter = true
	end
end
	
function RedrawTargeter(aType, anIsTypeChanged)
	if m_currTargetType == TARGETS_DISABLE then
		return
	end
	if anIsTypeChanged then
		SwitchTargetsBtn(aType)
	end
	local profile = GetCurrentProfile()
	for i = 0, GetTableSize(m_targeterPlayerPanelList)-1 do
		m_targeterPlayerPanelList[i].isUsed = false
	end
	
	local targetUnion = MakeTargetUnion(aType, false)
	
	
	local targetUnionCombat = {}
	if profile.targeterFormSettings.twoColumnMode then
		targetUnionCombat = MakeTargetUnion(aType, true)
	end
	
	local cntSimple = 0
	local cntCombat = 0
	if profile.targeterFormSettings.twoColumnMode then
		cntSimple = SortAndSetTarget(targetUnion, 0, 0)
		cntCombat = SortAndSetTarget(targetUnionCombat, TARGETS_LIMIT, 1)
	else
		cntSimple = SortAndSetTarget(targetUnion, 0, 0)
	end

	local maxPeopleCnt = math.min(math.max(cntSimple, cntCombat), TARGETS_LIMIT)
	FabricDestroyUnused()
	if profile.targeterFormSettings.twoColumnMode then
		ResizeTargetPanel(2, maxPeopleCnt)
	else
		ResizeTargetPanel(1, maxPeopleCnt)
	end
	TargetChanged()
end

local function RelationChanged(aParams)
	local paramsID = aParams.unitId or aParams.objectId
	
	if m_buffGroupSubSystemLoaded then
		RelationChangedForAboveHead(paramsID)
	end
	if m_targetSubSystemLoaded then
		if m_currTargetType == TARGETS_DISABLE then
			return
		end
		local profile = GetCurrentProfile()
		if not profile.targeterFormSettings.twoColumnMode then
			aParams.inCombat = false
		else
			if aParams.inCombat == nil then
				aParams.inCombat = object.IsInCombat(paramsID)
			end
		end
		
		-- пока не получили EVENT_UNITS_CHANGED данные по могут быть невалидными
		if FindTarget(paramsID) then
			EraseTarget(paramsID)
			SetNecessaryTargets(paramsID, aParams.inCombat)
			TryRedrawTargeter(m_currTargetType)
		end
	end
end

local function InitTargeterData()	
	local profile = GetCurrentProfile()
	m_lastTargetType = profile.targeterFormSettings.lastTargetType
	if profile.targeterFormSettings.lastTargetWasActive then
		m_currTargetType = TARGETS_DISABLE
	else
		m_currTargetType = m_lastTargetType
	end
	
	SwitchTargetsBtn(m_currTargetType)
end

--есть существа которые враждено-нейтральные и становятся враждебными без уведомлений
--поэтому затычка - при изменении хп проверяем существ всегда, не только при включенной сортировке по хп
local function UnitsHPChanged(aParams)
	local profile = GetCurrentProfile()
	if not m_targetSubSystemLoaded then
		return
	end
	if m_currTargetType == TARGETS_DISABLE then
		return
	end
	if not aParams then
		return
	end
	local someTargetUpdated = false
	for _, playerID in ipairs(aParams) do 
		if isExist(playerID) then
			-- пока не получили EVENT_UNITS_CHANGED данные по могут быть невалидными
			if FindTarget(playerID) then
				EraseTarget(playerID)
				local isCombat = false
				if profile.targeterFormSettings.twoColumnMode then
					isCombat = object.IsInCombat(playerID)
				end
				SetNecessaryTargets(playerID, isCombat)
				someTargetUpdated = true
			end
		end
	end
	if someTargetUpdated then
		TryRedrawTargeter(m_currTargetType)
	end
end

local function UnitDeadChanged(aParams)
	local profile = GetCurrentProfile()
	if not profile.targeterFormSettings.sortByDead then
		return
	end
	if not m_targetSubSystemLoaded then
		return
	end
	if m_currTargetType == TARGETS_DISABLE then
		return
	end
	if isExist(aParams.unitId) then
		-- пока не получили EVENT_UNITS_CHANGED данные по могут быть невалидными
		if FindTarget(aParams.unitId) then
			EraseTarget(aParams.unitId)
			local isCombat = false
			if profile.targeterFormSettings.twoColumnMode then
				isCombat = object.IsInCombat(aParams.unitId)
			end
			SetNecessaryTargets(aParams.unitId, isCombat)
			TryRedrawTargeter(m_currTargetType)
		end
	end
end

local function GetProgressActionType(aParams)
	local actionType = nil
	if aParams.id then
		actionType = ACTION_PROGRESS
	end
	if aParams.objectId then
		actionType = BUFF_PROGRESS
	end
	return actionType
end

local function CheckProgressCastPanelForMyTarget(aPanel)
	local profile = GetCurrentProfile()
	if aPanel and profile.castFormSettings.showOnlyMyTarget then
		local targetID = avatar.GetTarget()
		if aPanel.playerID ~= targetID then
			SetProgressCastPanelVisible(aPanel, false)
		end
	end
end

local function ProgressStart(aParams, aPanelList)
	local profile = GetCurrentProfile()
	local actionType = GetProgressActionType(aParams)
	if not profile.castFormSettings.showImportantCasts and aParams.id then 
		return
	end
	if not profile.castFormSettings.showImportantBuffs and aParams.objectId then 
		return
	end
	if isExist(aParams.objectId) and unit.IsPlayer(aParams.objectId) then
		return
	end
	
	if isExist(aParams.objectId or aParams.id) then
		local progressName = aParams.buffName or aParams.name
		local objNameLower = toLowerString(object.GetName(aParams.objectId or aParams.id))
		for _, ignoreObj in ipairs(profile.castFormSettings.ignoreList) do
			if progressName == ignoreObj.name then
				local skipIgnoreName = false
				for _, exceptionName in ipairs(splitString(ignoreObj.exceptionsEditText, ',')) do
					if objNameLower == exceptionName then
						skipIgnoreName = true
						break
					end
				end
				if not skipIgnoreName then
					return
				end
			end
		end
	end
	local panel = GetProgressCastPanel(aParams.objectId or aParams.id, aPanelList)
	if panel then 
		SetBaseInfoProgressCastPanel(panel, aParams, actionType)
		CheckProgressCastPanelForMyTarget(panel)
	else
		panel = GetFreeProgressCastPanel(aPanelList)
		if panel then 
			SetBaseInfoProgressCastPanel(panel, aParams, actionType)
			CheckProgressCastPanelForMyTarget(panel)
			UpdatePositionProgressCastPanels(aPanelList)
		end	
	end
end

local function ProgressEnd(aParams, aPanelList)
	local panel = GetProgressCastPanel(aParams.objectId or aParams.id, aPanelList)
	--несколько длительных контролей на цели, отображаем (а значит и удаляем) только последний
	if panel and panel.buffID == aParams.buffId then
		StopShowProgressForPanel(panel, aPanelList)
	end
end

local function ActionProgressStart(aParams)
	ProgressStart(aParams, m_progressActionPanelList)
end

local function ActionProgressEnd(aParams)
	ProgressEnd(aParams, m_progressActionPanelList)
end

local function BuffProgressStart(aParams)
	--при появлении длительного контроля сбрасываем отображение каста этого моба
	StopShowProgressForPanel(GetProgressCastPanel(aParams.objectId, m_progressActionPanelList), m_progressActionPanelList)
	ProgressStart(aParams, m_progressBuffPanelList)
end

function StopShowProgressForPanel(aPanel, aPanelList)
	if aPanel then 
		ClearProgressCastPanel(aPanel)
		UpdatePositionProgressCastPanels(aPanelList)
	end
end

local function StopShowProgressNow(anObjID)
	StopShowProgressForPanel(GetProgressCastPanel(anObjID, m_progressActionPanelList), m_progressActionPanelList)
	StopShowProgressForPanel(GetProgressCastPanel(anObjID, m_progressBuffPanelList), m_progressBuffPanelList)
end

local function BuffProgressEnd(aParams)
	ProgressEnd(aParams, m_progressBuffPanelList)
end

local function CheckSpawnAndDespawnAtSameTime(aParams)
	for _, despawnedObjID in pairs(aParams.despawned) do
		for _, spawnedObjID in pairs(aParams.spawned) do
			if despawnedObjID == spawnedObjID then
				LogInfo("SPAWN AND DESPAWN = ", despawnedObjID)
				return true
			end
		end
	end
	return false
end

local function UnitChanged(aParams)
	local profile = GetCurrentProfile()
	
	local existSpawned = {}
	if m_buffGroupSubSystemLoaded or m_targetSubSystemLoaded or m_castSubSystemLoaded then
		for _, objID in pairs(aParams.spawned) do
			if isExist(objID) then
				table.insert(existSpawned, objID)
			end
		end
	end
	
	--сначала все системы despawned
	if m_buffGroupSubSystemLoaded then
		DespawnedUnitsForAboveHead(aParams.despawned)
	end
	if m_targetSubSystemLoaded and m_currTargetType ~= TARGETS_DISABLE then	
		for _, objID in pairs(aParams.despawned) do
			if objID then
				EraseTarget(objID)
			end
		end
		--[[ по заверению разработчика такое невозможно
		--если один и тот же объект в spawned и в despawned, то нужно обязательно вызвать отписку всех для despawned, а лишь затем обработать spawned
		if CheckSpawnAndDespawnAtSameTime(aParams) then
			RedrawTargeter(m_currTargetType)
		end]]
	end
	
	if m_castSubSystemLoaded and profile.castFormSettings.showImportantCasts then
		for _, objID in pairs(aParams.despawned) do
			if objID then
				StopShowProgressNow(objID)
			end
		end
	end
	
	FabricDestroyUnused()
	
	--все системы spawned
	if m_buffGroupSubSystemLoaded then
		SpawnedUnitsForAboveHead(existSpawned)
	end
	
	if m_targetSubSystemLoaded and m_currTargetType ~= TARGETS_DISABLE then	
		for _, objID in pairs(existSpawned) do
			local isCombat = false
			if profile.targeterFormSettings.twoColumnMode then
				isCombat = object.IsInCombat(objID)
			end
			EraseTarget(objID)
			SetNecessaryTargets(objID, isCombat)
		end
			
		TryRedrawTargeter(m_currTargetType)
	end
	
	if m_castSubSystemLoaded and profile.castFormSettings.showImportantCasts then
		for _, objID in pairs(existSpawned) do
			if not unit.IsPlayer(objID) then
				local mobActionProgressInfo = unit.GetMobActionProgress(objID)
				if mobActionProgressInfo then
					mobActionProgressInfo.id = objID
					ActionProgressStart(mobActionProgressInfo)
				end
			end
		end
	end
end

local function UnitNameChanged(aParams)
	--LogInfo("UnitNameChanged ", aParams.id, "   ", object.GetName(aParams.id))
	local param = {}
	param.spawned = {}
	param.spawned[0] = aParams.id
	param.despawned = {}
	if isExist(aParams.id) then
		UnitChanged(param)
	end
end

local function UpdateUnselectable(aParams)
	if m_targetSubSystemLoaded then
		if isExist(aParams.objectId) and m_targetUnselectable[aParams.objectId] then
			local profile = GetCurrentProfile()
			local isCombat = false
			if profile.targeterFormSettings.twoColumnMode then
				isCombat = object.IsInCombat(aParams.objectId)
			end
			EraseTarget(aParams.objectId)
			SetNecessaryTargets(aParams.objectId, isCombat)
			TryRedrawTargeter(m_currTargetType)
		end
	end
	SelectableChanged(aParams)
end

local function GetPartyGUIToRaidGUIOptionsID()
	options.Update()
	local pageIds = options.GetPageIds()
	local pageId = pageIds[3]
	if pageId then
		local groupIds = options.GetGroupIds(pageId)
		if groupIds then
			for groupIndex = 0, GetTableSize( groupIds ) - 1 do
				local groupId = groupIds[groupIndex]
				local blockIds = options.GetBlockIds( groupId )
				for blockIndex = 0, GetTableSize( blockIds ) - 1 do
					local blockId = blockIds[blockIndex]
					local optionIds = options.GetOptionIds( blockId )
					for optionIndex = 0, GetTableSize( optionIds ) - 1 do
						local optionId = optionIds[optionIndex]

						if blockIndex == 0 and optionIndex == 6 then 
							return optionId
						end
					end
				end
			end		
		end
	end
end

local function SwitchPartyGUIToRaidGUI()
	local optionId = GetPartyGUIToRaidGUIOptionsID()
	if optionId then
		options.SetOptionCurrentIndex( optionId, 1 )
		local pageIds = options.GetPageIds()
		local pageId = pageIds[3]
		options.Apply(pageId)
	end
end

local function IsRaidGUIEnabled()
	local optionId = GetPartyGUIToRaidGUIOptionsID()
	if optionId then
		local optionInfo = options.GetOptionInfo( optionId )
		return optionInfo.currentIndex == 1
	end
	return false
end

local function ApplyUnloadRaidSettings(anIsUnloadRaidSubsystem)
	local profile = GetCurrentProfile()
	if anIsUnloadRaidSubsystem or profile.raidFormSettings.showStandartRaidButton then
		if raid.IsExist() or group.IsExist() then
			if IsRaidGUIEnabled() or raid.IsExist() then
				show(common.GetAddonMainForm("Raid"))
				show(getChild(common.GetAddonMainForm("Raid"), "Raid"))
			else
				show(getChild(common.GetAddonMainForm("Plates"), "Party"))
				show(getChild(common.GetAddonMainForm("Buffs"), "Party"))
			end
		end
	else
		SwitchPartyGUIToRaidGUI()

		hide(common.GetAddonMainForm("Raid"))
		hide(getChild(common.GetAddonMainForm("Raid"), "Raid"))
	end	
end

local function GUIInit()
	CreateMainBtn()
	m_mainSettingForm = CreateMainSettingsForm()
	m_profilesForm = CreateProfilesForm()
	m_raidSettingsForm = CreateRaidSettingsForm()
	m_targeterSettingsForm = CreateTargeterSettingsForm()
	m_bindSettingsForm = CreateBindSettingsForm()
	m_configGroupBuffForm = CreateConfigGroupBuffsForm()
	m_buffsGroupParentForm = CreateGroupsParentForm()
	m_exportProfileForm = CreateExportProfilesForm()
	m_importProfileForm = CreateImportProfilesForm()
	m_importErrorForm = CreateImportError()
	m_progressCastSettingsForm = CreateProgressCastSettingsForm()
	
	m_playerShortInfoForm = CreatePlayerShortInfoForm()

	m_raidPanel = CreateRaidPanel()
	m_targetPanel = CreateTargeterPanel()
	m_raidPartyButtons = CreateRaidPartyBtn(m_raidPanel)
	m_progressActionPanel = CreateProgressActionPanel()
	m_progressBuffPanel = CreateProgressBuffPanel()
end

local function OnEventSecondTimer()
	--при таргетере под курсором мыши перерисовываем лишь раз в секунду (чтобы легче выбрать)
	if m_targetSubSystemLoaded and m_needRedrawTargeter then
		m_redrawPauseCnt = m_redrawPauseCnt + 1
		if m_redrawPauseCnt == 2 then
			RedrawTargeter(m_currTargetType)
			m_needRedrawTargeter = false
			m_redrawPauseCnt = 0
		end
	end
	
	-- затычка №1 - скрываем дефолтовый интерфейс рейда, тк он переодически появляется
	local profile = GetCurrentProfile()
	if not profile.raidFormSettings.showStandartRaidButton and m_raidSubSystemLoaded then
		local raidForm = common.GetAddonMainForm("Raid")
		hide(raidForm)
		hide(getChild(raidForm, "Raid"))
	end
	-- затычка №2 - бывает что не приходит событие что юнит исчез, проверяем актуальность отображаемых персонажей в таргетере
	local unitList = avatar.GetUnitList()
	table.insert(unitList, avatar.GetId())
	if m_targetSubSystemLoaded then
		local eraseSomeTarget = false
		for i = 0, GetTableSize(m_targeterPlayerPanelList)-1 do
			local playerBar = m_targeterPlayerPanelList[i]
			local reallyExist = false
			if playerBar.isUsed then
				for _, objID in pairs(unitList) do
					if objID == playerBar.playerID then
						reallyExist = true
						break
					end
				end
				if not reallyExist then
					eraseSomeTarget = true
					EraseTarget(playerBar.playerID)
				end
			end
		end
			
		if eraseSomeTarget then
			TryRedrawTargeter(m_currTargetType)
		end
	end
	if m_buffGroupSubSystemLoaded then
		RemovePanelForNotExistObj(unitList)
	end
	FabicLogInfo()
end

local function Update()
	g_myAvatarID = avatar.GetId()
	updateCachedTimestamp()
	UpdateFabric()
end

function InitRaidSubSystem()
	if m_raidSubSystemLoaded then
		UnloadRaidSubSystem()
	end
	m_raidSubSystemLoaded = true
	CreateRaidPanelCache()
	
	--Событие на изменение состава группы (включая создание и роспуск).
	common.RegisterEventHandler(RaidChanged, "EVENT_GROUP_CHANGED")
	--Уведомление о смене агрегатного состояния группы: группа -> отряд, отряд -> группа.
	common.RegisterEventHandler(RaidChanged, "EVENT_GROUP_CONVERTED")
	--Событие на появление группы. Присылается не только на действительное создание группы, но и при вхождении игрока в состав уже существующей.
	common.RegisterEventHandler(RaidChanged, "EVENT_GROUP_APPEARED")
	--Событие на исчезновение группы. Присылается не только на роспуск группы, но и при выходе игрока из состава существующей.
	common.RegisterEventHandler(RaidChanged, "EVENT_GROUP_DISAPPEARED")
	--Уведомление о смене лидера группы главного игрока.
	common.RegisterEventHandler(RaidChanged, "EVENT_GROUP_LEADER_CHANGED")
	--Событие приходит при появлении нового члена группы.
	common.RegisterEventHandler(RaidChanged, "EVENT_GROUP_MEMBER_ADDED")
	--Событие на изменение состояния члена группы (онлайн-офлайн, лидер).
	common.RegisterEventHandler(RaidChanged, "EVENT_GROUP_MEMBER_CHANGED")
	--Событие приходит при выходе члена группы из ее состава.
	common.RegisterEventHandler(RaidChanged, "EVENT_GROUP_MEMBER_REMOVED")
	
	--Событие на появление рейда. Присылается не только на действительное создание рейда, но и при вхождении игрока в состав уже существующего.
	common.RegisterEventHandler(RaidChanged, "EVENT_RAID_APPEARED")
	--Событие на изменение состава рейда (включая создание и роспуск).
	common.RegisterEventHandler(RaidChanged, "EVENT_RAID_CHANGED")
	--Событие на исчезновение рейда. Присылается не только на роспуск рейда, но и при выходе игрока из состава существующего.
	common.RegisterEventHandler(RaidChanged, "EVENT_RAID_DISAPPEARED")
	--Присылается в случае изменения лидера рейда.
	common.RegisterEventHandler(RaidChanged, "EVENT_RAID_LEADER_CHANGED")
	--Присылается в случае появления игрока в отряде.
	common.RegisterEventHandler(RaidChanged, "EVENT_RAID_MEMBER_ADDED")
	--Присылается в случае изменения один или более параметров члена рейда
	common.RegisterEventHandler(RaidChanged, "EVENT_RAID_MEMBER_CHANGED")
	--Присылается в случае удаления или ухода игрока из отряда.
	common.RegisterEventHandler(RaidChanged, "EVENT_RAID_MEMBER_REMOVED")
	
	common.RegisterEventHandler(ReadyCheckEnded, "EVENT_GROUP_APPEARED")
	common.RegisterEventHandler(ReadyCheckEnded, "EVENT_GROUP_DISAPPEARED")
	common.RegisterEventHandler(ReadyCheckEnded, "EVENT_RAID_APPEARED")
	common.RegisterEventHandler(ReadyCheckEnded, "EVENT_RAID_DISAPPEARED")
	common.RegisterEventHandler(ReadyCheckStarted, "EVENT_READY_CHECK_STARTED")
	common.RegisterEventHandler(ReadyCheckChanged, "EVENT_READY_CHECK_INFO_CHANGED")
	common.RegisterEventHandler(ReadyCheckEnded, "EVENT_READY_CHECK_ENDED")
	
	DnD.ShowWdg(m_raidPanel)
	
	RaidChanged(nil, true)
	
	ApplyUnloadRaidSettings()
end

function UnloadRaidSubSystem()
	if not m_raidSubSystemLoaded then
		return
	end

	m_raidSubSystemLoaded = false
	common.UnRegisterEventHandler(RaidChanged, "EVENT_GROUP_CHANGED")
	common.UnRegisterEventHandler(RaidChanged, "EVENT_GROUP_CONVERTED")
	common.UnRegisterEventHandler(RaidChanged, "EVENT_GROUP_APPEARED")
	common.UnRegisterEventHandler(RaidChanged, "EVENT_GROUP_DISAPPEARED")
	common.UnRegisterEventHandler(RaidChanged, "EVENT_GROUP_LEADER_CHANGED")
	common.UnRegisterEventHandler(RaidChanged, "EVENT_GROUP_MEMBER_ADDED")
	common.UnRegisterEventHandler(RaidChanged, "EVENT_GROUP_MEMBER_CHANGED")
	common.UnRegisterEventHandler(RaidChanged, "EVENT_GROUP_MEMBER_REMOVED")
	
	common.UnRegisterEventHandler(RaidChanged, "EVENT_RAID_APPEARED")
	common.UnRegisterEventHandler(RaidChanged, "EVENT_RAID_CHANGED")
	common.UnRegisterEventHandler(RaidChanged, "EVENT_RAID_DISAPPEARED")
	common.UnRegisterEventHandler(RaidChanged, "EVENT_RAID_LEADER_CHANGED")
	common.UnRegisterEventHandler(RaidChanged, "EVENT_RAID_MEMBER_ADDED")
	common.UnRegisterEventHandler(RaidChanged, "EVENT_RAID_MEMBER_CHANGED")
	common.UnRegisterEventHandler(RaidChanged, "EVENT_RAID_MEMBER_REMOVED")
	
	common.UnRegisterEventHandler(ReadyCheckEnded, "EVENT_GROUP_APPEARED")
	common.UnRegisterEventHandler(ReadyCheckEnded, "EVENT_GROUP_DISAPPEARED")
	common.UnRegisterEventHandler(ReadyCheckEnded, "EVENT_RAID_APPEARED")
	common.UnRegisterEventHandler(ReadyCheckEnded, "EVENT_RAID_DISAPPEARED")
	common.UnRegisterEventHandler(ReadyCheckStarted, "EVENT_READY_CHECK_STARTED")
	common.UnRegisterEventHandler(ReadyCheckChanged, "EVENT_READY_CHECK_INFO_CHANGED")
	common.UnRegisterEventHandler(ReadyCheckEnded, "EVENT_READY_CHECK_ENDED")
	
	UnsubscribeRaidListeners()
	FabricDestroyUnused()
	StopMove()
	for i=0, GetTableSize(m_raidPlayerPanelList)-1 do
		local subParty = m_raidPlayerPanelList[i]
		for j=0, GetTableSize(subParty)-1 do
			DestroyPlayerPanel(subParty[j])
		end
	end
	m_raidPlayerPanelList = {}
	DestroyPlayerPanel(m_raidPlayerMovePanel)
	m_raidPlayerMovePanel = nil
	
	DnD.HideWdg(m_raidPanel)
	
	ApplyUnloadRaidSettings(true)
end

function InitTargeterSubSystem(aReload)
	if m_targetSubSystemLoaded then
		UnloadTargeterSubSystem()
	end
	m_targetSubSystemLoaded = true
	CreateTargeterPanelCache()
	
	DnD.ShowWdg(m_targetPanel)
	--local needActive = m_currTargetType ~= TARGETS_DISABLE
	InitTargeterData()
	--if aReload and needActive then
		TargetWorkSwitch()
	--end
end

function UnloadTargeterSubSystem()
	if not m_targetSubSystemLoaded then
		return
	end
	m_targetSubSystemLoaded = false
	
	ClearTargetPanels()
	for i = 0, GetTableSize(m_targeterPlayerPanelList)-1 do
		DestroyPlayerPanel(m_targeterPlayerPanelList[i])
	end
	m_targeterPlayerPanelList = {}
	DnD.HideWdg(m_targetPanel)
end

function InitGroupBuffSubSystem()
	if m_buffGroupSubSystemLoaded then
		UnloadGroupBuffSubSystem()
	end
	m_buffGroupSubSystemLoaded = true
	
	InitPanelsCache(m_buffsGroupParentForm)
	common.RegisterEventHandler(CannotAttachPanelAboveHead, "EVENT_CANNOT_ATTACH_WIDGET_3D")
	
	g_myAvatarID = avatar.GetId()
	CreateGroupBuffPanels(m_buffsGroupParentForm)
	SetGroupBuffPanelsInfoForMe()
	show(m_buffsGroupParentForm)
	
	local unitList = avatar.GetUnitList()
	table.insert(unitList, g_myAvatarID)
	SpawnedUnitsForAboveHead(unitList)
end

function UnloadGroupBuffSubSystem()
	if not m_buffGroupSubSystemLoaded then
		return
	end
	
	common.UnRegisterEventHandler(CannotAttachPanelAboveHead, "EVENT_CANNOT_ATTACH_WIDGET_3D")
	
	hide(m_buffsGroupParentForm)
	UnsubscribeGroupBuffListeners()
	DestroyGroupBuffPanels()
	m_buffGroupSubSystemLoaded = false
	RemoveAllAboveHeadPanels()
	FabricDestroyUnused()
end

function InitBindSubSystem()
	if m_bindSubSystemLoaded then
		UnloadBindSubSystem()
	end
	m_bindSubSystemLoaded = true
end

function UnloadBindSubSystem()
	m_bindSubSystemLoaded = false
end

local function InitCastPanel(aPanel)
	local profile = GetCurrentProfile()
	resize(aPanel, tonumber(profile.castFormSettings.panelWidthText), tonumber(profile.castFormSettings.panelHeightText+1)*PROGRESS_PANELS_LIMIT)
	if profile.castFormSettings.fixed then
		DnD.HideWdg(getChild(aPanel, "MoveModePanel"))
	else
		DnD.ShowWdg(getChild(aPanel, "MoveModePanel"))
	end
	show(aPanel)
end

function InitCastSubSystem()
	if m_castSubSystemLoaded then
		UnloadCastSubSystem()
	end
	m_castSubSystemLoaded = true
	
	CreateProgressCastCache(m_progressActionPanelList, m_progressActionPanel)
	CreateProgressCastCache(m_progressBuffPanelList, m_progressBuffPanel)
	local profile = GetCurrentProfile()
	InitCastPanel(m_progressActionPanel)
	InitCastPanel(m_progressBuffPanel)
	
	if profile.castFormSettings.showImportantCasts then
		local unitList = avatar.GetUnitList()
		for _, objID in pairs(unitList) do
			if isExist(objID) and not unit.IsPlayer(objID) then
				local mobActionProgressInfo = unit.GetMobActionProgress(objID)
				if mobActionProgressInfo then
					mobActionProgressInfo.id = objID
					ActionProgressStart(mobActionProgressInfo)
				end
			end
		end
	end
	
	-- эти события приходят очень редко и только для единичных юнитов (слушать всех юнитов по одиночке через PlayerInfo не даст выгоды) 
	-- и к тому же для EVENT_OBJECT_BUFF_PROGRESS_ADDED невозможно узнать если уже на юните такой бафф (если бафф повесился до spawn-а юнита у нас)
	common.RegisterEventHandler(ActionProgressStart, "EVENT_MOB_ACTION_PROGRESS_START")
	common.RegisterEventHandler(ActionProgressEnd, "EVENT_MOB_ACTION_PROGRESS_FINISH")
	common.RegisterEventHandler(BuffProgressStart, "EVENT_OBJECT_BUFF_PROGRESS_ADDED")
	common.RegisterEventHandler(BuffProgressEnd, "EVENT_OBJECT_BUFF_PROGRESS_REMOVED")
	common.RegisterEventHandler(ClearProgressPanelOnEndAnimation, "EVENT_EFFECT_FINISHED")
end

function UnloadCastSubSystem()
	if not m_castSubSystemLoaded then
		return
	end
	m_castSubSystemLoaded = false
	
	for i = 0, PROGRESS_PANELS_LIMIT do
		hide(m_progressActionPanelList[i].wdg)
		destroy(m_progressActionPanelList[i].wdg)
		
		hide(m_progressBuffPanelList[i].wdg)
		destroy(m_progressBuffPanelList[i].wdg)
	end
	m_progressActionPanelList = {}
	m_progressBuffPanelList = {}
	
	DnD.HideWdg(m_progressActionPanel)
	DnD.HideWdg(m_progressBuffPanel)
	
	common.UnRegisterEventHandler(ActionProgressStart, "EVENT_MOB_ACTION_PROGRESS_START")
	common.UnRegisterEventHandler(ActionProgressEnd, "EVENT_MOB_ACTION_PROGRESS_FINISH")
	common.UnRegisterEventHandler(BuffProgressStart, "EVENT_OBJECT_BUFF_PROGRESS_ADDED")
	common.UnRegisterEventHandler(BuffProgressEnd, "EVENT_OBJECT_BUFF_PROGRESS_REMOVED")
	common.UnRegisterEventHandler(ClearProgressPanelOnEndAnimation, "EVENT_EFFECT_FINISHED")
end




function GUIControllerInit()	
	InitClassIconsTexture()
	InitCheckTextures()
	InitButtonTextures()
	InitBackgroundsTextures()
	
	GUIInit()
	
	InitializeDefaultSetting()
	LoadLastUsedSetting()
	LoadForms()
	InitBuffConditionMgr()
	InitSpellConditionMgr()
	
	
	common.RegisterReactionHandler(ButtonPressed, "execute")
	common.RegisterReactionHandler(CheckBoxChangedOn, "CheckBoxChangedOn")
	common.RegisterReactionHandler(CheckBoxChangedOff, "CheckBoxChangedOff")
	common.RegisterReactionHandler(DropDownBtnPressed, "DropDownBtnPressed")
	common.RegisterReactionHandler(DropDownBtnRightClick, "DropDownBtnRightClick")
	common.RegisterReactionHandler(SelectDropDownBtnPressed, "SelectDropDownBtnPressed")
	
	AddReaction("closeButton", function (aWdg) DnD.SwapWdg(getParent(aWdg)) end)
	AddReaction("UniverseButton", SwapMainSettingsForm)
	AddReaction("closeExprotBtn", function (aWdg) DnD.SwapWdg(getParent(aWdg)) end)
	AddReaction("closeButtonOK", function (aWdg) DnD.SwapWdg(getParent(aWdg)) end)
	AddReaction("profilesButton", function () DnD.SwapWdg(m_profilesForm) end)
	AddReaction("deleteButtonconfigProfilesContainer", DeleteProfile)
	AddReaction("saveAsProfileButton", SaveProfileAs)
	AddReaction("loadProfileButton", LoadProfileBtnPressed)
	AddReaction("saveProfileButton", SaveProfileBtnPressed)
	AddReaction("exportProfileButton", ExportProfile)
	AddReaction("importProfileButton", ShowImportProfile)
	AddReaction("importBtn", ImportProfile)
	AddReaction("raidButton", SwapRaidSettingsForm)
	AddReaction("saveButton", SaveButtonPressed)
	AddReaction("targeterButton", SwapTargeterSettingsForm)
	AddReaction("bindButton", SwapBindSettingsForm)
	AddReaction("progressCastButton", SwapProgressCastSettingsForm)
	AddReaction("buffsButton", SwapGroupBuffsSettingsForm)
	AddReaction("helpButton", HelpButtonPressed)
	AddReaction("closeSomeSettingsButton", UndoButtonPressed)
	AddReaction("closeShortInfo", function (aWdg) hide(getParent(aWdg)) end)
	AddReaction("addRaidBuffButton", AddRaidBuffButton)
	AddReaction("addTargeterBuffButton", AddTargetBuffButton)
	AddReaction("addTargetButton", AddTargetButton)
	AddReaction("addGroupBuffsButton", AddBuffsGroupButton)
	AddReaction("addIgnoreCastsButton", AddIgnoreCastsButton)
	AddReaction("deleteButtonignoreListContainer", DeleteIgnoreCastElement)
	AddReaction("deleteButtonmyTargetsContainer", DeleteMyTargetsElement)
	AddReaction("deleteButtontargetBuffContainer", DeleteTargetBuffElement)
	AddReaction("deleteButtonraidBuffContainer", DeleteRaidBuffElement)
	AddReaction("deleteGroupBuffsButton", DeleteBuffsGroup)
	AddReaction("addBuffsButton", AddBuffsInsideGroupButton)
	AddReaction("deleteButtongroupBuffContainer", DeleteBuffInsideGroup)
	AddReaction("setHighlightColorButtongroupBuffContainer", SetColorBuffGroup)
	AddReaction("setHighlightColorButtonraidBuffContainer", SetColorBuffRaid)
	AddReaction("setHighlightColorButtontargetBuffContainer", SetColorBuffTargeter)
	AddReaction("setColorButton", ApplyColor)
	AddReaction("resetPanelBuffPosButton", ResetGroupBuffPanelPos)
	AddReaction("resetPanelCastPosButton", ResetProgressCastPanelPos)
	AddReaction("nextHelpBtn", NextHelp)
	AddReaction("prevHelpBtn", PrevHelp)
	AddReaction("buffOnMe", BuffOnMeChecked)
	AddReaction("buffOnTarget", BuffOnTargetChecked)
	AddReaction("colorDebuffButton", СolorDebuffButtonChecked)
	AddReaction("checkFriendCleanableButton", СheckFriendCleanableButtonChecked)
	AddReaction("targeterDropDown", SelectTargetTypePressed)
	AddReaction("groupBuffSelector", EditBuffGroup)
	AddReaction("progressCastFixButton", ProgressCastFixButtonChecked)
	AddReaction("buffsFixButton", BuffsFixButtonChecked)
	AddReaction("useRaidSubSystem", UseRaidSubSystemChecked)
	AddReaction("useTargeterSubSystem", UseTargeterSubSystemChecked)
	AddReaction("useBuffMngSubSystem", UseBuffMngSubSystemChecked)
	AddReaction("useBindSubSystem", UseBindSubSystemChecked)
	AddReaction("useCastSubSystem", UseCastSubSystemChecked)
	
	AddRightClickReaction("targeterDropDown", TargetWorkSwitch)
	
	local profile = GetCurrentProfile()
	if profile.mainFormSettings.useRaidSubSystem then
		InitRaidSubSystem()	
	end
	if profile.mainFormSettings.useTargeterSubSystem then
		InitTargeterSubSystem()
	end
	if profile.mainFormSettings.useBuffMngSubSystem then
		InitGroupBuffSubSystem()
	end
	if profile.mainFormSettings.useBindSubSystem then
		InitBindSubSystem()
	end
	if profile.mainFormSettings.useCastSubSystem then
		InitCastSubSystem()
	end
	
	TargetChanged()
	DnD.SetDndCallbackFunc(OnDNDPickAttempt)
	
	
	startTimer("updateTimer", Update, 0.1)
	common.RegisterEventHandler(OnEventSecondTimer, "EVENT_SECOND_TIMER")
	
	common.RegisterEventHandler(TargetChanged, "EVENT_AVATAR_TARGET_CHANGED")
	common.RegisterEventHandler(BuffsChanged, "EVENT_OBJECT_BUFFS_ELEMENT_CHANGED")
	common.RegisterEventHandler(UnitChanged, "EVENT_UNITS_CHANGED")
	common.RegisterEventHandler(UnitNameChanged, "EVENT_OBJECT_NAME_CHANGED")
	common.RegisterEventHandler(clearSpellCache, "EVENT_SPELLBOOK_CHANGED")
	common.RegisterEventHandler(clearItemsCache, "EVENT_INVENTORY_CHANGED")
	
	common.RegisterEventHandler(RelationChanged, "EVENT_UNIT_ZONE_PVP_TYPE_CHANGED")
	common.RegisterEventHandler(RelationChanged, "EVENT_UNIT_PVP_FLAG_CHANGED")
	common.RegisterEventHandler(RelationChanged, "EVENT_UNIT_RELATION_CHANGED")
	common.RegisterEventHandler(RelationChanged, "EVENT_OBJECT_COMBAT_STATUS_CHANGED")
	
	common.RegisterEventHandler(UnitsHPChanged, "EVENT_OBJECTS_HEALTH_CHANGED")

	common.RegisterEventHandler(OnDragTo, "EVENT_DND_DRAG_TO")
	common.RegisterEventHandler(OnDragEnd, "EVENT_DND_DROP_ATTEMPT")
	common.RegisterEventHandler(OnDragCancelled, "EVENT_DND_DRAG_CANCELLED")
	common.RegisterEventHandler(UnitDeadChanged, "EVENT_UNIT_DEAD_CHANGED")

	common.RegisterEventHandler(effectDone, "EVENT_EFFECT_FINISHED")
	
	common.RegisterEventHandler(OnInterfaceToggle, "EVENT_INTERFACE_TOGGLE" )
	common.RegisterEventHandler(OnTalentsChanged, "EVENT_TALENTS_CHANGED" )
	
	--EVENT_TRACK_ADDED

	
	--из-за лимита в 500 подписок на события какие не требуют привязки по ID вынесены из PlayerInfo
	common.RegisterEventHandler(AfkChanged, "EVENT_AFK_STATE_CHANGED")
	common.RegisterEventHandler(UnitDead, "EVENT_UNIT_DEAD_CHANGED")
	common.RegisterEventHandler(WoundsChanged, "EVENT_UNIT_WOUNDS_COMPLEXITY_CHANGED")
	common.RegisterEventHandler(UpdateUnselectable, "EVENT_OBJECT_SELECTABLE_CHANGED")
	
	common.RegisterReactionHandler(OnLeftClick, "OnPlayerBarLeftClick")
	common.RegisterReactionHandler(OnRightClick, "OnPlayerBarRightClick" )
	common.RegisterReactionHandler(OnLeftClick, "OnProgressBarLeftClick")
	common.RegisterReactionHandler(OnRightClick, "OnProgressBarRightClick" )
	common.RegisterReactionHandler(OnPlayerBarPointing, "OnPlayerBarPointing" )
	common.RegisterReactionHandler(MoveModeClick, "addClick")
	common.RegisterReactionHandler(TargetLockChanged, "OnTargetLockChanged")
	common.RegisterReactionHandler(function () RaidLockBtn(m_raidPanel) end, "OnRaidLockChanged")
	common.RegisterReactionHandler(SwapRaidSettingsForm, "OnConfigRaidChange")
	common.RegisterReactionHandler(SwapTargeterSettingsForm, "OnConfigTargeterChange")
	common.RegisterReactionHandler(OnCheckChange, "OnCheckChange")
	common.RegisterReactionHandler(OnRaidFilter, "OnRaidFilter")
	common.RegisterReactionHandler(OnShopChange, "OnShopChange")
	common.RegisterReactionHandler(OnAssertChange, "OnAssertChange")
	common.RegisterReactionHandler(EditLineEsc, "EditLineEsc")
end