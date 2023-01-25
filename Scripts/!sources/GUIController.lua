local m_raidSubSystemLoaded = false
local m_targetSubSystemLoaded = false
local m_buffGroupSubSystemLoaded = false
local m_bindSubSystemLoaded = false
local m_castSubSystemLoaded = false

local m_mainSettingForm = nil
local m_profilesForm = nil
local m_raidSettingsForm = nil
local m_targeterSettingsForm = nil
local m_buffSettingsForm = nil
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
local m_colorForm = nil

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




function DeleteProfile(aWdg)
	local index = GetIndexForWidget(aWdg)
	if index == 0 then
		return
	end
	
	local allProfiles = GetAllProfiles()
	DeleteContainer(allProfiles, aWdg, m_profilesForm)
	SaveProfiles(allProfiles)
	ProfileWasDeleted(index+1)
	LoadForms()
	ReloadAll()
end

function LoadProfilesFormSettings()
	local allProfiles = GetAllProfiles()
	ShowValuesFromTable(allProfiles, m_profilesForm)
end

local function SaveProfileByIndex(anIndex, aList)
	if not aList then 
		aList = GetAllProfiles()
	end

	aList[anIndex].mainFormSettings = SaveMainFormSettings(m_mainSettingForm)
	aList[anIndex].raidFormSettings = SaveRaidFormSettings(m_raidSettingsForm)
	aList[anIndex].targeterFormSettings = SaveTargeterFormSettings(m_targeterSettingsForm)
	aList[anIndex].buffFormSettings = SaveBuffFormSettings(m_buffSettingsForm)
	aList[anIndex].buffFormSettings = SaveConfigGroupBuffsForm(m_configGroupBuffForm, true)
	aList[anIndex].bindFormSettings = SaveBindFormSettings(m_bindSettingsForm)
	aList[anIndex].castFormSettings = SaveProgressCastFormSettings(m_progressCastSettingsForm)
	aList[anIndex].version = GetSettingsVersion()
	
	SaveProfiles(aList)
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
	AddElementFromForm(allProfiles, m_profilesForm)
	
	SaveProfileByIndex(GetTableSize(allProfiles), allProfiles)
end

function LoadProfile(aWdg)
	local index = GetIndexForWidget(aWdg)
	
	LoadSettings(index+1)
	LoadForms()
	
	ReloadAll()
end

function SaveProfile(aWdg)
	local index = GetIndexForWidget(aWdg)

	SaveProfileByIndex(index+1)
end

function SaveAll()
	SaveProfileByIndex(GetCurrentProfileInd())
end

function SaveAllAndApply()
	SaveProfileByIndex(GetCurrentProfileInd())
	
	ReloadAll()
end

function ExportProfile(aWdg)
	local index = GetIndexForWidget(aWdg)
	
	SetEditText(m_exportProfileForm, ExportProfileByIndex(index+1))
end

function ImportProfile()
	local importedProfile = StartDeserialize(GetImportText(m_importProfileForm))
	if not importedProfile then
		ShowImportError()
		return
	else	
		importedProfile.name = ConcatWString(toWString(importedProfile.name), userMods.ToWString("-import"))
		local allProfiles = GetAllProfiles()
		
		AddElementFromFormWithText(allProfiles, m_profilesForm, importedProfile.name)
		
		allProfiles[GetTableSize(allProfiles)] = importedProfile
		SaveProfiles(allProfiles)
		
		hide(m_importProfileForm)
	end
end

function ShowImportProfile(aWdg)
	show(m_importProfileForm)
end

function LoadForms()
	LoadMainFormSettings(m_mainSettingForm)
	LoadProfilesFormSettings()
	LoadRaidFormSettings(m_raidSettingsForm)
	LoadBindFormSettings(m_bindSettingsForm)
	LoadProgressCastFormSettings(m_progressCastSettingsForm)
	LoadTargeterFormSettings(m_targeterSettingsForm)
	LoadBuffFormSettings(m_buffSettingsForm)
	hide(m_configGroupBuffForm)
	ResetConfigGroupBuffsActiveNum()
	DestroyColorForm()
end

function UndoAll()
	LoadForms()
end

function DestroyColorForm()
	if m_colorForm then
		DnD.Remove(m_colorForm)
		destroy(m_colorForm)
	end
	m_colorForm = nil
end

function SetColorBuffGroup(aWdg)
	SetColorBuffHighlight(aWdg, GROUP_COLOR_TYPE)
end

function SetColorBuffRaid(aWdg)
	SetColorBuffHighlight(aWdg, RAID_COLOR_TYPE)
end

function SetColorBuffTargeter(aWdg)
	SetColorBuffHighlight(aWdg, TARGET_COLOR_TYPE)
end

function SetColorBuffHighlight(aWdg, aSaveLoadType)
	DestroyColorForm()
	local index = GetIndexForWidget(aWdg)
	m_colorForm = CreateColorSettingsForm(aSaveLoadType, GetConfigGroupBuffsActiveNum(), index+1)
	show(m_colorForm)
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
	local profile = GetCurrentProfile()
	AddElementFromForm(profile.raidFormSettings.raidBuffs.customBuffs, m_raidSettingsForm, nil, getChild(m_raidSettingsForm, "container") ) 
end

function AddTargetBuffButton(aWdg)
	local profile = GetCurrentProfile()
	AddElementFromForm(profile.targeterFormSettings.raidBuffs.customBuffs, m_targeterSettingsForm, "EditLine1", getChild(m_targeterSettingsForm, "container1") ) 
end

function AddTargetButton(aWdg)
	local profile = GetCurrentProfile()
	AddElementFromForm(profile.targeterFormSettings.myTargets, m_targeterSettingsForm, "EditLine2", getChild(m_targeterSettingsForm, "container2") ) 
end

function AddBuffsGroupButton(aWdg)
	local profile = GetCurrentProfile()
	local result = AddElementFromForm(profile.buffFormSettings.buffGroups, m_buffSettingsForm, nil, getChild(m_buffSettingsForm, "container") ) 
	if not result then
		return
	end
	local buffGroupCnt = GetTableSize(profile.buffFormSettings.buffGroups)
	profile.buffFormSettings.buffGroupsUnicCnt = profile.buffFormSettings.buffGroupsUnicCnt + 1
	profile.buffFormSettings.buffGroups[buffGroupCnt].buffGroupWdgName = BUFF_GROUP_WDG_NAME_PREFIX..tostring(profile.buffFormSettings.buffGroupsUnicCnt)
	LoadConfigGroupBuffsForm(m_configGroupBuffForm, buffGroupCnt)
	show(m_configGroupBuffForm)
end

function AddBuffsInsideGroupButton(aWdg)
	local profile = GetCurrentProfile()
	profile.buffFormSettings = SaveBuffFormSettings(m_buffSettingsForm)
	profile.buffFormSettings = SaveConfigGroupBuffsForm(m_configGroupBuffForm, false)
	AddElementFromForm(profile.buffFormSettings.buffGroups[GetConfigGroupBuffsActiveNum()].buffs, m_configGroupBuffForm, "EditLine5", getChild(m_configGroupBuffForm, "container") ) 
end

function AddIgnoreCastsButton(aWdg)
	local profile = GetCurrentProfile()
	AddElementFromForm(profile.castFormSettings.ignoreList, m_progressCastSettingsForm, "EditLine1", getChild(m_progressCastSettingsForm, "container1") ) 
end

function DeleteIgnoreCastElement(aWdg)
	local profile = GetCurrentProfile()
	DeleteContainer(profile.castFormSettings.ignoreList, aWdg, m_progressCastSettingsForm)
end

function DeleteRaidBuffElement(aWdg)
	local profile = GetCurrentProfile()
	DeleteContainer(profile.raidFormSettings.raidBuffs.customBuffs, aWdg, m_raidSettingsForm)
end

function DeleteTargetWndElement(aWdg)
	local profile = GetCurrentProfile()
	local container = getParent(getParent(getParent(getParent(aWdg))))
	local containerName = getName(container)
	if containerName == "container1" then
		DeleteContainer(profile.targeterFormSettings.raidBuffs.customBuffs, aWdg, m_targeterSettingsForm)
	elseif containerName == "container2" then
		DeleteContainer(profile.targeterFormSettings.myTargets, aWdg, m_targeterSettingsForm)
	end
end

function EditBuffGroup(aWdg)
	local index = GetIndexForWidget(aWdg) + 1
	LoadConfigGroupBuffsForm(m_configGroupBuffForm, index)
	show(m_configGroupBuffForm)
end

function DeleteBuffGroup(aWdg)
	local profile = GetCurrentProfile()
	DeleteContainer(profile.buffFormSettings.buffGroups, aWdg, m_buffSettingsForm)
end

function DeleteBuffInsideGroup(aWdg)
	local profile = GetCurrentProfile()
	profile.buffFormSettings = SaveBuffFormSettings(m_buffSettingsForm)
	profile.buffFormSettings = SaveConfigGroupBuffsForm(m_configGroupBuffForm, false)
	DeleteContainer(profile.buffFormSettings.buffGroups[GetConfigGroupBuffsActiveNum()].buffs, aWdg, m_configGroupBuffForm)
end

function SwitchActionBtn(aWdg)
	SwitchActionClickBtn(getParent(aWdg))
end

function BuffOnMeCheckedOn()
	ConfigGroupBuffsBuffOnMeCheckedOn(m_configGroupBuffForm)
end

function BuffOnTargetCheckedOn()
	ConfigGroupBuffsBuffOnTargetCheckedOn(m_configGroupBuffForm)
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
	RaidChanged()
end

local function OnShopChange()
	GetBuffConditionForRaid():SwitchShowShop()
	
	RaidChanged()
end

local function OnAssertChange(aParams)
	local alreadyHandled = false
	if m_castSubSystemLoaded and (m_progressActionPanel:IsEqual(getParent(aParams.widget, 2)) or m_progressBuffPanel:IsEqual(getParent(aParams.widget, 2))) then
		--пока не подтвердим пложение на обеих панельках не сбрасываем флаг перемещния
		if isVisible(m_progressActionPanel) and isVisible(m_progressBuffPanel) then
			hide(getParent(aParams.widget, 2))
			return
		end
		local profile = GetCurrentProfile()
		profile.castFormSettings.fixed = true
		LoadProgressCastFormSettings(m_progressCastSettingsForm)
		alreadyHandled = true
	end
	if not alreadyHandled then
		SetPanelFixed(getParent(aParams.widget, 2))
	end
	SaveAllAndApply()
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
	if profile.raidFormSettings.highlightSelectedButton then
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
	if profile.targeterFormSettings.highlightSelectedButton then
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
				actionType = profile.bindFormSettings.actionRightSwitchProgressCastSimple
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
	
	if bindAction and not common.IsEmptyWString(bindAction) then
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
	
	if not playerBar then
		playerBar = FindClickedInTarget(aParams.widget)
	end
	if playerBar then
		if aParams.active then
			show(playerBar.highlightWdg)
		else
			hide(playerBar.highlightWdg)
		end
	end
	
	local profile = GetCurrentProfile()
	if not profile.raidFormSettings.showRollOverInfo and not profile.targeterFormSettings.showRollOverInfo then
		return
	end
	
	if not aParams.active then
		hide(m_playerShortInfoForm)
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
	local members = raid.GetMembers()
	local maxPeopleCnt = 0
	local partyCnt = GetTableSize(members)
	
	local currGroupSize = getGroupSizeFromPersId(m_movingUniqueID)
	local currGroupNum = getGroupFromPersId(m_movingUniqueID)
			
	for i=0, partyCnt-1 do
		local subParty = members[i]
		maxPeopleCnt = math.max(maxPeopleCnt, GetTableSize(subParty))
		local peopleCnt = GetTableSize(subParty)
		if peopleCnt < 6 and (currGroupNum and i < currGroupNum or currGroupSize and currGroupSize > 1) and currGroupNum ~= i then	
			show(m_raidPlayerPanelList[i][peopleCnt].raidMoveWdg)
			maxPeopleCnt = maxPeopleCnt + 1
		end
	end
	if partyCnt < 4 and currGroupSize and currGroupSize > 1 then
		local subParty = members[partyCnt]
		show(m_raidPlayerPanelList[partyCnt][0].raidMoveWdg)
		partyCnt = partyCnt + 1
	end
	
	ResizeRaidPanel(partyCnt, maxPeopleCnt)
end

function HideHighlight()
	for i=0, GetTableSize(m_raidPlayerPanelList)-1 do
		local subParty = m_raidPlayerPanelList[i]
		for j=0, GetTableSize(subParty)-1 do
			local playerBar = subParty[j]
			hide(playerBar.highlightWdg)
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
		show(playerBar.highlightWdg)
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

local function BuildRaidGUI(aCurrentRaid)
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
				SetBaseInfoPlayerPanel(playerBar, playerInfo, (i == leaderInd),  profile.raidFormSettings, FRIEND_PANEL)
				if playerInfo.state == GROUP_MEMBER_STATE_OFFLINE then 
					playerInfo.id = nil
				end
				FabricMakeRaidPlayerInfo(playerInfo.id, playerBar)
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
			if not m_raidPartyButtons[i+1].active then
				maxPartyCnt = maxPartyCnt - 1
			end
			
			if m_raidPartyButtons[i+1].active then
				for j=0, GetTableSize(subParty)-1 do
					local playerInfo = subParty[j]
					local playerBar = m_raidPlayerPanelList[partyCnt][j]
					playerBar.isUsed = true
					SetBaseInfoPlayerPanel(playerBar, playerInfo, playerInfo.uniqueId:IsEqual(raidLeaderID),  profile.raidFormSettings, FRIEND_PANEL)
					if playerInfo.state == RAID_MEMBER_STATE_OFFLINE then 
						playerInfo.id = nil
					end
					FabricMakeRaidPlayerInfo(playerInfo.id, playerBar)
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

function RaidChanged(aParams)
	UnsubscribeRaidListeners()
	
	for i=0, GetTableSize(m_raidPlayerPanelList)-1 do
		local subParty = m_raidPlayerPanelList[i]
		for j=0, GetTableSize(subParty)-1 do
			local playerBar = subParty[j]
			playerBar.isUsed = false
		end
	end
	
	local raidList = {}
	if raid.IsExist() then
		local members = raid.GetMembers()
		m_currentRaid.type = RAID_TYPE
		m_currentRaid.members = members
		ShowPartyBtns(GetTableSize(members))
	elseif group.IsExist() then
		local members = group.GetMembers()
		m_currentRaid.type = PARTY_TYPE
		m_currentRaid.members = members
		ShowPartyBtns(1)
		StopMove()
	else
		m_currentRaid.type = SOLO_TYPE
		m_currentRaid.members = {}
		StopMove()
		HidePartyBtns()
	end
	
	BuildRaidGUI(m_currentRaid)
	ReadyCheckChanged()
	
	local canMovePlayers = CanMovePlayers(avatar.GetUniqueId())
	for i=0, GetTableSize(m_raidPlayerPanelList)-1 do
		local subParty = m_raidPlayerPanelList[i]
		for j=0, GetTableSize(subParty)-1 do
			local playerBar = subParty[j]
			if not playerBar.isUsed then
				playerBar.playerID = nil
				hide(playerBar.wdg)
				hide(playerBar.highlightWdg)
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
				hide(playerBar.raidMoveWdg)
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
	hide(m_raidPlayerMovePanel.wdg)
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
	
	ShowMoveIfNeeded()
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
	for i=1, GetTableSize(anObjArr) do
		if anObjArr[i].objID == anObjID then
			return true
		end
	end
	return false
end

local function FindTarget(anObjID)
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
	if profile.targeterFormSettings.hideUnselectableButton and not isPlayer and not isPet then
		if not unit.CanSelectTarget(anObjID) then
			m_targetUnselectable[anObjID] = true
			return
		end
	end
	m_targetUnselectable[anObjID] = nil
	--object.CanAttack(
	local isEnemy = object.IsEnemy(anObjID)
	local isFriend = isEnemy and false or object.IsFriend(anObjID)
	local isNeitral = not isEnemy and not isFriend
	
	local newValue = {}
	newValue.objID = anObjID
	newValue.inCombat = anInCombat

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
	
	for i = TARGETS_LIMIT, TARGETS_LIMIT*2-1 do
		local playerPanel = CreatePlayerPanel(m_targetPanel, 1, i, false, profile.targeterFormSettings, i)
		m_targeterPlayerPanelList[i] = playerPanel
		if profile.targeterFormSettings.twoColumnMode then
			align(playerPanel.wdg, WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW)
		end
	end
end

local function ClearTargetPanels()
	UnsubscribeTargetListener()
	
	for i = 0, GetTableSize(m_targeterPlayerPanelList)-1 do
		local playerBar = m_targeterPlayerPanelList[i]
		hide(playerBar.wdg)
		hide(playerBar.highlightWdg)
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
	
	SetTargetType(m_currTargetType, true)
end

local function TargetWorkSwitch()
	local profile = GetCurrentProfile()
	if m_currTargetType ~= TARGETS_DISABLE then
		m_lastTargetType = m_currTargetType
		m_currTargetType = TARGETS_DISABLE
		ResizeTargetPanel(1, 0)
		SwitchTargetsBtn(TARGETS_DISABLE)
		ClearTargetPanels()
		
		local selectPanelWdg = GetTargetModeSelectPanel()
		hide(selectPanelWdg)
		
		profile.targeterFormSettings.lastTargetType = m_lastTargetType
		profile.targeterFormSettings.lastTargetWasActive = false
		SaveAll()
	else
		m_currTargetType = m_lastTargetType
		LoadTargeterData()
		
		profile.targeterFormSettings.lastTargetWasActive = true
		SaveAll()
	end
end

local function SelectTargetTypePressed(aParams)
	local selectPanelWdg = GetTargetModeSelectPanel()
	hide(selectPanelWdg)
	
	if m_currTargetType == TARGETS_DISABLE then
		return
	end
	
	local pressedWdgName = getName(aParams.widget)
	local prefixStr = "modeBtn"
	local indexStr = pressedWdgName:sub(prefixStr:len()+1, pressedWdgName:len())
	
	m_currTargetType = tonumber(indexStr)
	SetTargetType(m_currTargetType, true)
	local profile = GetCurrentProfile()
	profile.targeterFormSettings.lastTargetType = m_currTargetType
	SaveAll()
end

local function ShowSelectTargetTypePanel()
	if m_currTargetType == TARGETS_DISABLE then
		return
	end
	
	local selectPanelWdg = GetTargetModeSelectPanel()
	swap(selectPanelWdg)
end

local function SeparateTargeterPanelList(anObjList, aPanelListShift)
	local finededList = {} 
	local freeList = {}
	for i = aPanelListShift, TARGETS_LIMIT+aPanelListShift-1 do
		local playerBar = m_targeterPlayerPanelList[i]
		local found = false
		for k = 1, GetTableSize(anObjList) do
			if playerBar.playerID == anObjList[k].objID
			and (playerBar.formSettings.classColorModeButton or playerBar.panelColorType == anObjList[k].relationType)
			then
				finededList[playerBar.playerID] = playerBar
				found = true
				break
			end			
		end
		if not found then
			table.insert(freeList, playerBar)
		end
	end
	return finededList, freeList
end

local function SortBySettings(anArr)
	local profile = GetCurrentProfile()

	if profile.targeterFormSettings.sortByName then
		table.sort(anArr, SortByName)
	end
	
	for i = 1, GetTableSize(anArr) do
		anArr[i].sortWeight = i
	end
		
	if profile.targeterFormSettings.sortByHP then
		for i = 1, GetTableSize(anArr) do
			anArr[i].sortWeight = anArr[i].sortWeight + anArr[i].hp * TARGETS_LIMIT
		end
	end
	
	if profile.targeterFormSettings.sortByClass then
		local shiftMult = 101 * TARGETS_LIMIT
		for i = 1, GetTableSize(anArr) do
			anArr[i].sortWeight = anArr[i].sortWeight + anArr[i].classPriority * shiftMult
		end
	end
	
	if profile.targeterFormSettings.sortByDead then
		local shiftMult = 101 * TARGETS_LIMIT * (GetTableSize(g_classPriority) + 1)
		for i = 1, GetTableSize(anArr) do
			anArr[i].sortWeight = anArr[i].sortWeight + anArr[i].isDead * shiftMult
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
				hide(playerBar.wdg)
				hide(playerBar.highlightWdg)
			end
			playerBar.playerID = nil
		end
	end
	return cnt-aPanelListShift
end

local function GetArrByCombatStatus(aStatus, aType)
	local objArr = m_targetUnitsByType[aType]
	local resultArr = {}
	for i=1, GetTableSize(objArr) do
		if objArr[i].inCombat == aStatus then
			table.insert(resultArr, objArr[i])
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
	
function SetTargetType(aType, anIsTypeChanged)
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
			SetTargetType(m_currTargetType)
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

local function UnitHPChanged(aParams)
	local profile = GetCurrentProfile()
	if not profile.targeterFormSettings.sortByHP then
		return
	end
	local playerID = aParams.unitId or aParams.id
	if isExist(playerID) then
		-- пока не получили EVENT_UNITS_CHANGED данные по могут быть невалидными
		if FindTarget(playerID) then
			EraseTarget(playerID)
			local isCombat = false
			if profile.targeterFormSettings.twoColumnMode then
				isCombat = object.IsInCombat(playerID)
			end
			SetNecessaryTargets(playerID, isCombat)
			SetTargetType(m_currTargetType)
		end
	end
end

local function UnitDeadChanged(aParams)
	local profile = GetCurrentProfile()
	if not profile.targeterFormSettings.sortByDead then
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
			SetTargetType(m_currTargetType)
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
	
	local progressName = aParams.buffName or aParams.name
	for _, ignoreObj in pairs(profile.castFormSettings.ignoreList) do
		if common.CompareWString(progressName, ignoreObj.name) == 0 then
			return
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

local function UnitChanged(aParams)
	if m_buffGroupSubSystemLoaded then
		UnitsChangedForAboveHead(aParams.spawned, aParams.despawned)
	end
	
	local profile = GetCurrentProfile()
	
	if m_targetSubSystemLoaded then
		if m_currTargetType == TARGETS_DISABLE then
			return
		end
		
		for i=0, GetTableSize(aParams.spawned)-1 do
			if isExist(aParams.spawned[i]) then
				local isCombat = false
				if profile.targeterFormSettings.twoColumnMode then
					isCombat = object.IsInCombat(aParams.spawned[i])
				end
				EraseTarget(aParams.spawned[i])
				SetNecessaryTargets(aParams.spawned[i], isCombat)
				--LogInfo("sp ", aParams.spawned[i])
			end
		end
		
		for i=0, GetTableSize(aParams.despawned)-1 do
			if aParams.despawned[i] then
				EraseTarget(aParams.despawned[i])
			end
		end
			
		SetTargetType(m_currTargetType)
	end
	
	if m_castSubSystemLoaded and profile.castFormSettings.showImportantCasts then
		for i=0, GetTableSize(aParams.spawned)-1 do
			if isExist(aParams.spawned[i]) and not unit.IsPlayer(aParams.spawned[i]) then
				local mobActionProgressInfo = unit.GetMobActionProgress(aParams.spawned[i])
				if mobActionProgressInfo then
					mobActionProgressInfo.id = aParams.spawned[i]
					ActionProgressStart(mobActionProgressInfo)
				end
			end
		end
		for i=0, GetTableSize(aParams.despawned)-1 do
			if aParams.despawned[i] then
				StopShowProgressNow(aParams.despawned[i])
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

local function SwitchPartyGUIToRaidGUI()
	options.Update()
	local pageIds = options.GetPageIds()
	for pageIndex = 0, GetTableSize( pageIds ) - 1 do
		local pageId = pageIds[pageIndex]
		if pageIndex == 1 or pageIndex == 3 then
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
							local optionInfo = options.GetOptionInfo( optionId )
	
							if pageIndex == 3 and blockIndex == 0 and optionIndex == 4 then 
								options.SetOptionCurrentIndex( optionId, 1 )
							end
						end
					end
				end		
			end
			options.Apply( pageId )
		end
	end
end

local function ApplyUnloadRaidSettings(anIsUnloadRaidSubsystem)
	local profile = GetCurrentProfile()
	if anIsUnloadRaidSubsystem or profile.raidFormSettings.showStandartRaidButton then
		if raid.IsExist() or group.IsExist() then
			show(getChild(stateMainForm, "Raid"))
			show(getChild(getChild(stateMainForm, "Raid"), "Raid"))
		end
	else
		SwitchPartyGUIToRaidGUI()

		hide(getChild(stateMainForm, "Raid"))
		hide(getChild(getChild(stateMainForm, "Raid"), "Raid"))
	end	
end

local function GUIInit()
	CreateMainBtn()
	m_mainSettingForm = CreateMainSettingsForm()
	m_profilesForm = CreateProfilesForm()
	m_raidSettingsForm = CreateRaidSettingsForm()
	m_targeterSettingsForm = CreateTargeterSettingsForm()
	m_bindSettingsForm = CreateBindSettingsForm()
	m_buffSettingsForm = CreateBuffSettingsForm()
	m_configGroupBuffForm = CreateConfigGroupBuffsForm()
	m_buffsGroupParentForm = CreateGroupsParentForm()
	m_exportProfileForm = CreateExportProfilesForm()
	m_importProfileForm = CreateImportProfilesForm()
	m_progressCastSettingsForm = CreateProgressCastSettingsForm()
	m_helpForm = CreateHelpForm()
	m_playerShortInfoForm = CreatePlayerShortInfoForm()

	m_raidPanel = CreateRaidPanel()
	m_targetPanel = CreateTargeterPanel()
	m_raidPartyButtons = CreateRaidPartyBtn(m_raidPanel)
	m_progressActionPanel = CreateProgressActionPanel()
	m_progressBuffPanel = CreateProgressBuffPanel()
end

local function OnEventSecondTimer()
	-- затычка №1 - скрываем дефолтовый интерфейс рейда, тк он переодически появляется
	local profile = GetCurrentProfile()
	if not profile.raidFormSettings.showStandartRaidButton and m_raidSubSystemLoaded then
		local raidForm = getChild(stateMainForm, "Raid")
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
			SetTargetType(m_currTargetType)
		end
	end
	if m_buffGroupSubSystemLoaded then
		RemovePanelForNotExistObj(unitList)
	end
	FabicLogInfo()
end

local m_unselectableCheckTick = true
local function UpdateUnselectable()
	--проверяем что CanSelectTarget для проигнорированных изменился через 1 update
	if m_targetSubSystemLoaded then
		if m_unselectableCheckTick then
			local unitList = avatar.GetUnitList()
			local eraseSomeTarget = false
			local profile = GetCurrentProfile()
			for _, objID in pairs(unitList) do
				if objID and m_targetUnselectable[objID] then
					if object.IsExist(objID) and unit.CanSelectTarget(objID) then
						local isCombat = false
						if profile.targeterFormSettings.twoColumnMode then
							isCombat = object.IsInCombat(objID)
						end
						EraseTarget(objID)
						SetNecessaryTargets(objID, isCombat)
						eraseSomeTarget = true
					end
				end
			end
			
			if eraseSomeTarget then
				SetTargetType(m_currTargetType)
			end
		end
		m_unselectableCheckTick = not m_unselectableCheckTick
	end
end

local function Update()
	g_myAvatarID = avatar.GetId()
	updateCachedTimestamp()
	UpdateUnselectable()
	UpdateFabric()
end

function InitRaidSubSystem()
	if m_raidSubSystemLoaded then
		UnloadRaidSubSystem()
	end
	m_raidSubSystemLoaded = true
	CreateRaidPanelCache()
	
	common.RegisterEventHandler(RaidChanged, "EVENT_GROUP_CHANGED")
	common.RegisterEventHandler(RaidChanged, "EVENT_GROUP_CONVERTED")
	common.RegisterEventHandler(RaidChanged, "EVENT_GROUP_APPEARED")
	common.RegisterEventHandler(RaidChanged, "EVENT_GROUP_DISAPPEARED")
	common.RegisterEventHandler(RaidChanged, "EVENT_GROUP_LEADER_CHANGED")
	common.RegisterEventHandler(RaidChanged, "EVENT_GROUP_MEMBER_ADDED")
	common.RegisterEventHandler(RaidChanged, "EVENT_GROUP_MEMBER_CHANGED")
	common.RegisterEventHandler(RaidChanged, "EVENT_GROUP_MEMBER_REMOVED")
	
	common.RegisterEventHandler(RaidChanged, "EVENT_RAID_APPEARED")
	common.RegisterEventHandler(RaidChanged, "EVENT_RAID_CHANGED")
	common.RegisterEventHandler(RaidChanged, "EVENT_RAID_DISAPPEARED")
	common.RegisterEventHandler(RaidChanged, "EVENT_RAID_LEADER_CHANGED")
	common.RegisterEventHandler(RaidChanged, "EVENT_RAID_MEMBER_ADDED")
	common.RegisterEventHandler(RaidChanged, "EVENT_RAID_MEMBER_CHANGED")
	common.RegisterEventHandler(RaidChanged, "EVENT_RAID_MEMBER_REMOVED")
	
	common.RegisterEventHandler(ReadyCheckEnded, "EVENT_GROUP_APPEARED")
	common.RegisterEventHandler(ReadyCheckEnded, "EVENT_GROUP_DISAPPEARED")
	common.RegisterEventHandler(ReadyCheckEnded, "EVENT_RAID_APPEARED")
	common.RegisterEventHandler(ReadyCheckEnded, "EVENT_RAID_DISAPPEARED")
	common.RegisterEventHandler(ReadyCheckStarted, "EVENT_READY_CHECK_STARTED")
	common.RegisterEventHandler(ReadyCheckChanged, "EVENT_READY_CHECK_INFO_CHANGED")
	common.RegisterEventHandler(ReadyCheckEnded, "EVENT_READY_CHECK_ENDED")
	
	show(m_raidPanel)
	
	RaidChanged()
	
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
	
	DestroyColorForm()
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
	
	hide(m_raidPanel)
	
	ApplyUnloadRaidSettings(true)
end

function InitTargeterSubSystem(aReload)
	if m_targetSubSystemLoaded then
		UnloadTargeterSubSystem()
	end
	m_targetSubSystemLoaded = true
	CreateTargeterPanelCache()
	
	show(m_targetPanel)
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
	
	DestroyColorForm()
	ClearTargetPanels()
	for i = 0, GetTableSize(m_targeterPlayerPanelList)-1 do
		DestroyPlayerPanel(m_targeterPlayerPanelList[i])
	end
	m_targeterPlayerPanelList = {}
	hide(m_targetPanel)
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
	UnitsChangedForAboveHead(unitList, {})
end

function UnloadGroupBuffSubSystem()
	if not m_buffGroupSubSystemLoaded then
		return
	end
	
	common.UnRegisterEventHandler(CannotAttachPanelAboveHead, "EVENT_CANNOT_ATTACH_WIDGET_3D")
	
	hide(m_buffsGroupParentForm)
	DestroyColorForm()
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
	resize(aPanel, tonumber(profile.castFormSettings.panelWidthText), tonumber(profile.castFormSettings.panelHeightText)*PROGRESS_PANELS_LIMIT)
	if profile.castFormSettings.fixed then
		hide(getChild(aPanel, "MoveModePanel"))
	else
		show(getChild(aPanel, "MoveModePanel"))
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
	
	hide(m_progressActionPanel)
	hide(m_progressBuffPanel)
	
	common.UnRegisterEventHandler(ActionProgressStart, "EVENT_MOB_ACTION_PROGRESS_START")
	common.UnRegisterEventHandler(ActionProgressEnd, "EVENT_MOB_ACTION_PROGRESS_FINISH")
	common.UnRegisterEventHandler(BuffProgressStart, "EVENT_OBJECT_BUFF_PROGRESS_ADDED")
	common.UnRegisterEventHandler(BuffProgressEnd, "EVENT_OBJECT_BUFF_PROGRESS_REMOVED")
	common.UnRegisterEventHandler(ClearProgressPanelOnEndAnimation, "EVENT_EFFECT_FINISHED")
end


function UniverseBtnPressed()
	swap(m_mainSettingForm)
end

function GUIControllerInit()	
	InitClassIconsTexture()
	InitCheckTextures()
	InitButtonTextures()
	
	GUIInit()
	
	InitializeDefaultSetting()
	LoadLastUsedSetting()
	LoadForms()
	InitBuffConditionMgr()
	InitSpellConditionMgr()
	
	
	common.RegisterReactionHandler(ButtonPressed, "execute")
	common.RegisterReactionHandler(CheckBoxChangedOn, "CheckBoxChangedOn")
	common.RegisterReactionHandler(CheckBoxChangedOff, "CheckBoxChangedOff")
	
	AddReaction("closeButton", function (aWdg) swap(getParent(aWdg)) end)
	AddReaction("UniverseButton", UniverseBtnPressed)
	AddReaction("okButton", function (aWdg) swap(getParent(aWdg)) SaveAllAndApply() end)
	AddReaction("closeExprotBtn", function (aWdg) swap(getParent(aWdg)) end)
	AddReaction("closeButtonOK", function (aWdg) swap(getParent(aWdg)) end)
	AddReaction("profilesButton", function () swap(m_profilesForm) end)
	AddReaction("deleteButtonconfigProfilesForm", DeleteProfile)
	AddReaction("saveAsProfileButton", SaveProfileAs)
	AddReaction("loadProfileButton", LoadProfile)
	AddReaction("saveProfileButton", SaveProfile)
	AddReaction("exportProfileButton", ExportProfile)
	AddReaction("importProfileButton", ShowImportProfile)
	AddReaction("importBtn", ImportProfile)
	AddReaction("raidButton", function () swap(m_raidSettingsForm) end)
	AddReaction("saveButton", function (aWdg) swap(getParent(aWdg)) SaveAllAndApply() end)
	AddReaction("targeterButton", function () swap(m_targeterSettingsForm) end)
	AddReaction("bindButton", function () swap(m_bindSettingsForm) end)
	AddReaction("progressCastButton", function () swap(m_progressCastSettingsForm) end)
	AddReaction("helpButton", function () swap(m_helpForm) end)
	AddReaction("closeSomeSettingsButton", function (aWdg) swap(getParent(aWdg)) UndoAll() end)
	AddReaction("addRaidBuffButton", AddRaidBuffButton)
	AddReaction("addTargeterBuffButton", AddTargetBuffButton)
	AddReaction("addTargetButton", AddTargetButton)
	AddReaction("addGroupBuffsButton", AddBuffsGroupButton)
	AddReaction("addIgnoreCastsButton", AddIgnoreCastsButton)
	AddReaction("deleteButtoncastSettingsForm", DeleteIgnoreCastElement)
	AddReaction("deleteButtontargeterSettingsForm", DeleteTargetWndElement)
	AddReaction("deleteButtonraidSettingsForm", DeleteRaidBuffElement)
	AddReaction("buffsButton", function () swap(m_buffSettingsForm) end)
	AddReaction("editButtonbuffSettingsForm", EditBuffGroup)
	AddReaction("deleteButtonbuffSettingsForm", DeleteBuffGroup)
	AddReaction("addBuffsButton", AddBuffsInsideGroupButton)
	AddReaction("deleteButtonconfigGroupBuffsForm", DeleteBuffInsideGroup)
	AddReaction("actionLeftSwitchRaidSimple", SwitchActionBtn)
	AddReaction("actionLeftSwitchRaidShift", SwitchActionBtn)
	AddReaction("actionLeftSwitchRaidAlt", SwitchActionBtn)
	AddReaction("actionLeftSwitchRaidCtrl", SwitchActionBtn)
	AddReaction("actionLeftSwitchTargetSimple", SwitchActionBtn)
	AddReaction("actionLeftSwitchTargetShift", SwitchActionBtn)
	AddReaction("actionLeftSwitchTargetAlt", SwitchActionBtn)
	AddReaction("actionLeftSwitchTargetCtrl", SwitchActionBtn)
	AddReaction("actionRightSwitchRaidSimple", SwitchActionBtn)
	AddReaction("actionRightSwitchRaidShift", SwitchActionBtn)
	AddReaction("actionRightSwitchRaidAlt", SwitchActionBtn)
	AddReaction("actionRightSwitchRaidCtrl", SwitchActionBtn)
	AddReaction("actionRightSwitchTargetSimple", SwitchActionBtn)
	AddReaction("actionRightSwitchTargetShift", SwitchActionBtn)
	AddReaction("actionRightSwitchTargetAlt", SwitchActionBtn)
	AddReaction("actionRightSwitchTargetCtrl", SwitchActionBtn)
	AddReaction("actionLeftSwitchProgressCastSimple", SwitchActionBtn)
	AddReaction("actionLeftSwitchProgressCastShift", SwitchActionBtn)
	AddReaction("actionLeftSwitchProgressCastAlt", SwitchActionBtn)
	AddReaction("actionLeftSwitchProgressCastCtrl", SwitchActionBtn)
	AddReaction("actionRightSwitchProgressCastSimple", SwitchActionBtn)
	AddReaction("actionRightSwitchProgressCastShift", SwitchActionBtn)
	AddReaction("actionRightSwitchProgressCastAlt", SwitchActionBtn)
	AddReaction("actionRightSwitchProgressCastCtrl", SwitchActionBtn)
	AddReaction("setHighlightColorButtonconfigGroupBuffsForm", SetColorBuffGroup)
	AddReaction("setHighlightColorButtonraidSettingsForm", SetColorBuffRaid)
	AddReaction("setHighlightColorButtontargeterSettingsForm", SetColorBuffTargeter)
	AddReaction("setColorButton", function (aWdg) swap(getParent(aWdg)) SaveBuffColorHighlight(m_colorForm) DestroyColorForm() end)
	AddReaction("resetPanelBuffPosButton", ResetGroupBuffPanelPos)
	AddReaction("resetPanelCastPosButton", ResetProgressCastPanelPos)
	AddReaction("nextHelpBtn", NextHelp)
	AddReaction("prevHelpBtn", PrevHelp)
	AddReaction("distanceButton", DistanceBtnPressed)
	AddReaction("closeDistanceFormButton", function (aWdg) swap(getParent(aWdg)) end)
	AddReaction("buffOnMe", BuffOnMeCheckedOn)
	AddReaction("buffOnTarget", BuffOnTargetCheckedOn)
	
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
	
	
	common.RegisterEventHandler(UnitHPChanged, "EVENT_UNIT_HEALTH_CHANGED")
	common.RegisterEventHandler(UnitHPChanged, "EVENT_OBJECT_HEALTH_CHANGED")

	common.RegisterEventHandler(OnDragTo, "EVENT_DND_DRAG_TO")
	common.RegisterEventHandler(OnDragEnd, "EVENT_DND_DROP_ATTEMPT")
	common.RegisterEventHandler(OnDragCancelled, "EVENT_DND_DRAG_CANCELLED")
	common.RegisterEventHandler(UnitDeadChanged, "EVENT_UNIT_DEAD_CHANGED")

	common.RegisterEventHandler(effectDone, "EVENT_EFFECT_FINISHED")

	
	--из-за лимита в 500 подписок на события какие не требуют привязки по ID вынесены из PlayerInfo
	common.RegisterEventHandler(AfkChanged, "EVENT_AFK_STATE_CHANGED")
	common.RegisterEventHandler(UnitDead, "EVENT_UNIT_DEAD_CHANGED")
	common.RegisterEventHandler(WoundsChanged, "EVENT_UNIT_WOUNDS_COMPLEXITY_CHANGED")
	
	common.RegisterReactionHandler(OnLeftClick, "OnPlayerBarLeftClick")
	common.RegisterReactionHandler(OnRightClick, "OnPlayerBarRightClick" )
	common.RegisterReactionHandler(OnPlayerBarPointing, "OnPlayerBarPointing" )
	common.RegisterReactionHandler(MoveModeClick, "addClick")
	common.RegisterReactionHandler(ShowSelectTargetTypePanel, "GetModeBtnReaction")
	common.RegisterReactionHandler(SelectTargetTypePressed, "SelectModeBtnReaction")
	common.RegisterReactionHandler(TargetWorkSwitch, "GetModeBtnRightClick")
	common.RegisterReactionHandler(TargetLockChanged, "OnTargetLockChanged")
	common.RegisterReactionHandler(function () RaidLockBtn(m_raidPanel) end, "OnRaidLockChanged")
	common.RegisterReactionHandler(function () swap(m_raidSettingsForm) end, "OnConfigRaidChange")
	common.RegisterReactionHandler(function () swap(m_targeterSettingsForm) end, "OnConfigTargeterChange")
	common.RegisterReactionHandler(OnCheckChange, "OnCheckChange")
	common.RegisterReactionHandler(OnRaidFilter, "OnRaidFilter")
	common.RegisterReactionHandler(OnShopChange, "OnShopChange")
	common.RegisterReactionHandler(OnAssertChange, "OnAssertChange")
	
end