local cachedIsPlayer = unit.IsPlayer
local cachedIsPet = unit.IsPet
local cachedCanSelectTarget = unit.CanSelectTarget
local cachedIsEnemy = object.IsEnemy
local cachedIsFriend = object.IsFriend
local cachedGetReputationLevel = unit.GetReputationLevel
local cachedGetName = object.GetName
local cachedGetClass = unit.GetClass
local cachedGetHealthInfo = object.GetHealthInfo

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
local m_targeterInfoForm = nil
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
local m_progressActionQueue = {}
local m_progressBuffQueue = {}
local m_raidPlayerPanelList = {}
local m_raidPlayerMovePanel = nil
local m_targeterPlayerPanelList = {}
local m_moveMode = false
local m_movingUniqueID = nil
local m_lastRaidPanelSize = {}
local m_lastTargetPanelSize = {}

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

function OnTalentsChanged()
	if IsProfileIndexChanged() then
		LoadLastUsedSetting()
		LoadForms()
		ReloadAll()
	end
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
	if not m_exportProfileForm then
		m_exportProfileForm = CreateExportProfilesForm()
	end
	SetEditText(m_exportProfileForm, ExportProfileByIndex(index+1))
	WndMgr.ShowWdg(m_exportProfileForm)
end

function ImportProfile()
	local importedProfile = StartDeserialize(GetImportText(m_importProfileForm))
	if not importedProfile then
		if not m_importErrorForm then
			m_importErrorForm = CreateImportError()
		end
		WndMgr.ShowWdg(m_importErrorForm)
		return
	else	
		importedProfile.name = ConcatWString(toWString(importedProfile.name), userMods.ToWString("-import"))
		local allProfiles = GetAllProfiles()
		
		AddElementFromFormWithText(allProfiles, m_profilesForm, importedProfile.name, getChild(m_profilesForm, "configProfilesContainer"))
		
		allProfiles[GetTableSize(allProfiles)] = importedProfile
		SaveAllSettings(allProfiles)
		
		WndMgr.HideWdg(m_importProfileForm)
	end
end

function ShowImportProfile(aWdg)
	if not m_importProfileForm then
		m_importProfileForm = CreateImportProfilesForm()
	end
	WndMgr.ShowWdg(m_importProfileForm)
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
		WndMgr.HideWdg(m_raidSettingsForm)
	end
	if not profile.mainFormSettings.useTargeterSubSystem then
		WndMgr.HideWdg(m_targeterSettingsForm)
	end
	if not profile.mainFormSettings.useBuffMngSubSystem then
		WndMgr.HideWdg(m_configGroupBuffForm)
	end
	if not profile.mainFormSettings.useBindSubSystem then
		WndMgr.HideWdg(m_bindSettingsForm)
	end
	if not profile.mainFormSettings.useCastSubSystem then
		WndMgr.HideWdg(m_progressCastSettingsForm)
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
	WndMgr.SwapWnd(getParent(aWdg))
	UndoSubsystemSettingsForm(getParent(aWdg))
end

function SaveButtonPressed(aWdg)
	local index = GetCurrentProfileInd()
	local profilesList = GetAllProfiles()

	local needSwapWnd = true
	local nameSettingForm = getName(getParent(aWdg))
	if nameSettingForm == "bindSettingsForm" then
		profilesList[index].bindFormSettings = SaveBindFormSettings(m_bindSettingsForm)
	elseif nameSettingForm == "configGroupBuffsForm" then
		profilesList[index].buffFormSettings = SaveConfigGroupBuffsForm(m_configGroupBuffForm, true)
	elseif findSimpleString(nameSettingForm, "BuffGroup") then
		profilesList[index].buffFormSettings = SaveConfigGroupBuffsForm(m_configGroupBuffForm, false)
		needSwapWnd = false
	elseif nameSettingForm == "castSettingsForm" then
		profilesList[index].castFormSettings = SaveProgressCastFormSettings(m_progressCastSettingsForm)
	elseif nameSettingForm == "ProgressActionPanel" or nameSettingForm == "ProgressBuffPanel" then
		profilesList[index].castFormSettings = SaveProgressCastFormSettings(m_progressCastSettingsForm)
		needSwapWnd = false
	elseif nameSettingForm == "raidSettingsForm" then
		profilesList[index].raidFormSettings = SaveRaidFormSettings(m_raidSettingsForm)
	elseif nameSettingForm == "targeterSettingsForm" then
		profilesList[index].targeterFormSettings = SaveTargeterFormSettings(m_targeterSettingsForm)
	elseif nameSettingForm == "mainSettingsForm" then
		profilesList[index].mainFormSettings = SaveMainFormSettings(m_mainSettingForm)
	end
	profilesList[index].version = GetSettingsVersion()
	if needSwapWnd then
		--скрываем окно после сохранения - иначе setfocus(false) не сработают
		WndMgr.SwapWnd(getParent(aWdg))
	end
	
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
	--обновляем m_currentProfile
	LoadLastUsedSetting()
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
	WndMgr.SwapWnd(m_helpForm)
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
		WndMgr.HideWdg(aForm)
	else
		WndMgr.ShowWdg(aForm)
	end
end

function SwapRaidSettingsForm(aWdg)
	if not m_raidSettingsForm then
		m_raidSettingsForm = CreateRaidSettingsForm()
		LoadRaidFormSettings(m_raidSettingsForm)
	end
	SwapSettingsForm(m_raidSettingsForm)
end

function SwapTargeterSettingsForm(aWdg)
	if not m_targeterSettingsForm then
		m_targeterSettingsForm = CreateTargeterSettingsForm()
		LoadTargeterFormSettings(m_targeterSettingsForm)
	end
	SwapSettingsForm(m_targeterSettingsForm)
end

function SwapProgressCastSettingsForm(aWdg)
	if not m_progressCastSettingsForm then
		m_progressCastSettingsForm = CreateProgressCastSettingsForm()
		LoadProgressCastFormSettings(m_progressCastSettingsForm)
	end
	SwapSettingsForm(m_progressCastSettingsForm)
end

function SwapBindSettingsForm(aWdg)
	if not m_bindSettingsForm then
		m_bindSettingsForm = CreateBindSettingsForm()
		LoadBindFormSettings(m_bindSettingsForm)
	end
	SwapSettingsForm(m_bindSettingsForm)
end

function SwapGroupBuffsSettingsForm(aWdg)
	if not m_configGroupBuffForm then
		m_configGroupBuffForm = CreateConfigGroupBuffsForm()
		LoadConfigGroupBuffsForm(m_configGroupBuffForm, 1, true)
	elseif not m_configGroupBuffForm:IsVisible() then	
		LoadConfigGroupBuffsForm(m_configGroupBuffForm, 1, true)
	end
	SwapSettingsForm(m_configGroupBuffForm)
end

function SwapMainSettingsForm(aWdg)
	if not m_mainSettingForm then
		m_mainSettingForm = CreateMainSettingsForm()
		LoadMainFormSettings(m_mainSettingForm)
	end
	UpdateMainFormButtons(m_mainSettingForm)
	SwapSettingsForm(m_mainSettingForm)
end

function SwapProfileForm(aWdg)
	if not m_profilesForm then
		m_profilesForm = CreateProfilesForm()	
		LoadProfilesFormSettings(m_profilesForm)
	end
	WndMgr.SwapWnd(m_profilesForm)
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
	for _, partyButton in ipairs(m_raidPartyButtons) do
		if partyButton.showed then
			partyButton.wdg:Show(false)
			partyButton.showed = false
		end
	end
end

local function ShowPartyBtns(aPartyCnt)
	for i, partyButton in ipairs(m_raidPartyButtons) do
		if not partyButton.showed then
			partyButton.wdg:Show(true)
			partyButton.showed = true
		end
		if i == aPartyCnt then
			break
		end
	end
end

function OnRaidFilter(aParams)
	for _, partyButton in ipairs(m_raidPartyButtons) do
		if aParams.widget:IsEqual(partyButton.wdg) then
			partyButton.active = not partyButton.active
			if partyButton.active then
				setBackgroundColor(partyButton.wdg, { r = 1; g = 1, b = 1; a = 1 })
			else
				setBackgroundColor(partyButton.wdg, { r = 0.3; g = 0.3; b = 0.3; a = 1 })
			end
		end
	end
	RaidChanged(nil, true)
end

function OnShopChange()
	GetBuffConditionForRaid():SwitchShowShop()
	
	RaidChanged(nil, true)
end

function OnAssertChange(aParams)
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

function EditLineEsc(aParams)
	aParams.widget:SetFocus(false)
end

function OnCheckChange()
	if raid.IsExist() then
		raid.StartReadyCheck()
	elseif group.IsExist() then
		group.StartReadyCheck()
	end
end

function ReadyCheckEnded()
	HideReadyCheck()
end

function ReadyCheckChanged()
	local checkInfo = nil
	if raid.IsExist() then
		checkInfo = raid.GetReadyCheckInfo()
	elseif group.IsExist() then
		checkInfo = group.GetReadyCheckInfo()
	end
	ShowReadyCheck(checkInfo, m_currentRaid)
end

function ReadyCheckStarted()
	ReadyCheckChanged()
end

local function FindClickedInProgressCast(anWdg, aPanelList)
	for _, playerBar in ipairs(aPanelList) do
		if playerBar.isUsed and anWdg:IsEqual(playerBar.wdg) then
			return playerBar
		end
	end
end

local function FindClickedInTarget(anWdg)
	for _, statusGroup in ipairs(m_targeterPlayerPanelList) do
		for _, playerBar in ipairs(statusGroup) do
			if playerBar.isUsed and anWdg:IsEqual(playerBar.wdg) then
				return playerBar
			end
		end
	end
end

local function FindClickedInRaid(anWdg)
	for _, party in ipairs(m_raidPlayerPanelList) do
		for _, playerBar in ipairs(party) do
			if playerBar.isUsed and anWdg:IsEqual(playerBar.wdg) then
				return playerBar
			end
		end
	end
end

local function FindMyUniqueIDInRaid()
	for _, party in ipairs(m_raidPlayerPanelList) do
		for _, playerBar in ipairs(party) do
			if playerBar.isUsed and playerBar.playerID == g_myAvatarID then
				return playerBar.uniqueID
			end
		end
	end
end

local function FindClickedInRaidMove(anWdg)
	for i, party in ipairs(m_raidPlayerPanelList) do
		for _, playerBar in ipairs(party) do
			if anWdg:IsEqual(playerBar.raidMoveWdg) then
				return i - 1
			end
		end
	end
end

local function FindRaidMoveBarByCoordinateInRaid(aGlobalX, aGlobalY)
	if not m_moveMode then 
		return
	end
	
	for _, party in ipairs(m_raidPlayerPanelList) do
		for _, playerBar in ipairs(party) do
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
	
	for _, party in ipairs(m_raidPlayerPanelList) do
		for _, playerBar in ipairs(party) do
			if playerBar.isUsed then
				local realRect = playerBar.wdg:GetRealRect()
				if realRect.x1 < aGlobalX and realRect.x2 > aGlobalX and realRect.y1 < aGlobalY and realRect.y2 > aGlobalY then
					return playerBar
				end
			end
		end
	end
end

function TargetChangedForTargeter(aTargetID)
	local profile = GetCurrentProfile()
	if m_targetSubSystemLoaded and profile.targeterFormSettings.highlightSelectedButton then
		for _, statusGroup in ipairs(m_targeterPlayerPanelList) do
			for _, playerBar in ipairs(statusGroup) do
				if aTargetID and playerBar.isUsed and playerBar.playerID and aTargetID == playerBar.playerID then
					PlayerTargetsHighlightChanged(true, playerBar)
				elseif playerBar.highlight then
					PlayerTargetsHighlightChanged(false, playerBar)
				end
			end
		end
	end
end

function TargetChangedForRaid(aTargetID)
	local profile = GetCurrentProfile()
	if m_raidSubSystemLoaded and profile.raidFormSettings.highlightSelectedButton then
		for _, party in ipairs(m_raidPlayerPanelList) do
			for _, playerBar in ipairs(party) do
				if aTargetID and playerBar.isUsed and aTargetID == playerBar.playerID then
					PlayerTargetsHighlightChanged(true, playerBar)
				elseif playerBar.highlight then
					PlayerTargetsHighlightChanged(false, playerBar)
				end
			end
		end
	end
end

function TargetChanged()
	local targetID = avatar.GetTarget()
	
	TargetChangedForRaid(targetID)
	TargetChangedForTargeter(targetID)
	
	if m_buffGroupSubSystemLoaded then
		SetGroupBuffPanelsInfoForTarget(targetID)
	end
	if m_castSubSystemLoaded then
		ShowProgressBuffForTarget(targetID, m_progressActionPanelList, m_progressActionQueue)
		ShowProgressBuffForTarget(targetID, m_progressBuffPanelList, m_progressBuffQueue)
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

function OnLeftClick(aParams)
	OnPlayerSelect(aParams, true)
end

function OnRightClick(aParams)
	OnPlayerSelect(aParams, false)
end

function OnPlayerBarPointing(aParams)
	if not aParams.widget:IsValid() then
		return
	end
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
		if not m_playerShortInfoForm then
			m_playerShortInfoForm = CreatePlayerShortInfoForm()
		end
		InitPlayerShortInfoForm(playerBar.playerID)
		show(m_playerShortInfoForm)
	end
end

function OnDropDownBtnPointing(aParams) 
	if aParams.sender == "targeterModeBtn" then
		if aParams.active and m_currTargetType == TARGETS_DISABLE then
			if not m_targeterInfoForm then
				m_targeterInfoForm = CreateTargeterInfoForm()
			end
			local targeterPlace = m_targetPanel:GetPlacementPlain()
			move(m_targeterInfoForm, targeterPlace.posX+30, targeterPlace.posY+30)
			show(m_targeterInfoForm)
		else
			hide(m_targeterInfoForm)
		end
	end
end

function TargetLockChanged(aParams)
	TargetLockBtn(m_targetPanel)
end

local function CreateProgressCastCache(aPanelList, aParentWdg)
	local profile = GetCurrentProfile()
	for i = 1, PROGRESS_PANELS_LIMIT do
		local progressCastPanel = CreateProgressCastPanel(aParentWdg, i-1)
		if profile.castFormSettings.selectable then
			progressCastPanel.wdg:SetTransparentInput(false)
		else
			progressCastPanel.wdg:SetTransparentInput(true)
		end
		aPanelList[i] = progressCastPanel
	end
end

local function GetProgressCastPanel(anID, aPanelList)
	for _, progressPanel in ipairs(aPanelList) do
		if progressPanel.isUsed and progressPanel.playerID == anID then
			return progressPanel
		end
	end
end

local function GetFreeProgressCastPanel(aPanelList)
	for _, progressPanel in ipairs(aPanelList) do
		if not progressPanel.isUsed then
			return progressPanel
		end
	end
end

local function ClearProgressPanelOnEndAnimationInPanelList(aParams, aPanelList, aProgressQueue)
	if aParams.effectType ~= ET_RESIZE then
		return
	end
	for _, progressPanel in ipairs(aPanelList) do
		if progressPanel.isUsed and aParams.wtOwner:IsEqual(progressPanel.barWdg) then
			StopShowProgressForPanel(progressPanel, aPanelList, aProgressQueue)
			break
		end
	end
end

local function ClearProgressPanelOnEndAnimation(aParams)
	ClearProgressPanelOnEndAnimationInPanelList(aParams, m_progressActionPanelList, m_progressActionQueue)
	ClearProgressPanelOnEndAnimationInPanelList(aParams, m_progressBuffPanelList, m_progressBuffQueue)
end

local function CreateRaidPanelCache()
	local profile = GetCurrentProfile()
	m_raidPlayerMovePanel = CreatePlayerPanel(m_raidPanel, 0, 0, true, profile.raidFormSettings, 111)
	m_raidPlayerMovePanel.wdg:SetTransparentInput(true)
	for i = 1, 4 do
		m_raidPlayerPanelList[i] = {}
		for j = 1, 6 do
			local playerPanel = CreatePlayerPanel(m_raidPanel, i-1, j-1, true, profile.raidFormSettings, i*j)
			DnD.Init(m_raidPlayerMovePanel.wdg, playerPanel.wdg, false)
			DnD.Enable(playerPanel.wdg, false)
			m_raidPlayerPanelList[i][j] = playerPanel
		end
	end
end

local function ResizePanelForm(aGroupsCnt, aMaxPeopleCnt, aFormSettings, aForm, aLastSize)
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
	
	if not aLastSize.w or aLastSize.w < width or not aLastSize.h or aLastSize.h < height then
		width = math.max(200, width)
		height = math.max(390, height)
		
		aLastSize.w = width
		aLastSize.h = height
		resize(aForm, width, height)
		DnD.UpdatePadding(aForm, {0,-(width-200),-(height-60),0})
	end
end

local function ResizeTargetPanel(aGroupsCnt, aMaxPeopleCnt)
	local profile = GetCurrentProfile()
	ResizePanelForm(aGroupsCnt, aMaxPeopleCnt, profile.targeterFormSettings, m_targetPanel, m_lastTargetPanelSize)
end

local function ResizeRaidPanel(aGroupsCnt, aMaxPeopleCnt)
	local profile = GetCurrentProfile()
	ResizePanelForm(aGroupsCnt, aMaxPeopleCnt, profile.raidFormSettings, m_raidPanel, m_lastRaidPanelSize)
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
	
	for i, party in ipairs(members) do 
		local peopleCnt = GetTableSize(party)
		maxPeopleCnt = math.max(maxPeopleCnt, peopleCnt)
		if peopleCnt < 6 and (currGroupNum and i < currGroupNum or currGroupSize and currGroupSize > 1) and currGroupNum ~= i then	
			DnD.ShowWdg(m_raidPlayerPanelList[i][peopleCnt+1].raidMoveWdg)
			maxPeopleCnt = maxPeopleCnt + 1
		end
	end
	if partyCnt < 4 and currGroupSize and currGroupSize > 1 then
		DnD.ShowWdg(m_raidPlayerPanelList[partyCnt+1][1].raidMoveWdg)
		partyCnt = partyCnt + 1
	end
	
	ResizeRaidPanel(partyCnt, maxPeopleCnt)
end

function HideHighlight()
	for _, party in ipairs(m_raidPlayerPanelList) do
		for _, playerBar in ipairs(party) do
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

	if aParams.targetWidget and aParams.targetWidget:IsValid() then
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
		playerInfo.id = g_myAvatarID
		playerInfo.name = cachedGetName(playerInfo.id)
		playerInfo.state = GROUP_MEMBER_STATE_NEAR
		playerInfo.className = cachedGetClass(playerInfo.id).className
		m_raidPlayerPanelList[1][1].isUsed = true
		SetBaseInfoPlayerPanel(m_raidPlayerPanelList[1][1], playerInfo, true, profile.raidFormSettings, FRIEND_PANEL)
		FabricMakeRaidPlayerInfo(playerInfo.id, m_raidPlayerPanelList[1][1])
		ResizeRaidPanel(1, 1)
	elseif aCurrentRaid.type == PARTY_TYPE then
		-- EVENT_GROUP_CONVERTED - приходит когда еще не рейд но уже members группы - nil
		if aCurrentRaid.members then
			for i, playerInfo in ipairs(aCurrentRaid.members) do
				if m_raidPartyButtons[1].active then
					local playerBar = m_raidPlayerPanelList[1][i]
					playerBar.isUsed = true
					if (playerInfo.id and not aReusedRaidListeners[playerInfo.id]) or not playerInfo.id then
						local isLeader = false
						if playerInfo.id and cachedIsPlayer(playerInfo.id) then
							isLeader = playerInfo.uniqueId:IsEqual(m_currentRaid.currentLeaderUniqueID)
						end
						SetBaseInfoPlayerPanel(playerBar, playerInfo, isLeader, profile.raidFormSettings, FRIEND_PANEL)
						if playerInfo.state == GROUP_MEMBER_STATE_OFFLINE then 
							playerInfo.id = nil
						end
					
						FabricMakeRaidPlayerInfo(playerInfo.id, playerBar)
					end
				end
			end
		end
		ResizeRaidPanel(1, GetTableSize(aCurrentRaid.members))
	elseif aCurrentRaid.type == RAID_TYPE then
		local maxPeopleCnt = 0
		local maxPartyCnt = GetTableSize(aCurrentRaid.members)
		local partyCnt = 1
		if aCurrentRaid.members then
			for i, party in ipairs(aCurrentRaid.members) do
				maxPeopleCnt = math.max(maxPeopleCnt, GetTableSize(party))
				if m_raidPartyButtons[i].active or m_moveMode then
					for j, playerInfo in ipairs(party) do
						local playerBar = m_raidPlayerPanelList[partyCnt][j]
						playerBar.isUsed = true
						if (playerInfo.id and not aReusedRaidListeners[playerInfo.id]) or not playerInfo.id then
							SetBaseInfoPlayerPanel(playerBar, playerInfo, playerInfo.uniqueId:IsEqual(m_currentRaid.currentLeaderUniqueID),  profile.raidFormSettings, FRIEND_PANEL)
							if playerInfo.state == RAID_MEMBER_STATE_OFFLINE then 
								playerInfo.id = nil
							end
						
							FabricMakeRaidPlayerInfo(playerInfo.id, playerBar)
						end
					end
					partyCnt = partyCnt + 1
				else
					maxPartyCnt = maxPartyCnt - 1
				end
			end
		end
		ResizeRaidPanel(maxPartyCnt, maxPeopleCnt)
		ShowMoveIfNeeded()
	end
	TargetChangedForRaid(avatar.GetTarget())
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
	for _, party in ipairs(m_raidPlayerPanelList) do
		for _, playerBar in ipairs(party) do
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
		for i, playerInfo in ipairs(aCurrentRaid.members) do
			local playerReadyState = FindMemberStateByUniqueID(aCheckInfo.members, playerInfo.uniqueId)
			ShowReadyStateInGUI(m_raidPlayerPanelList[1][i], playerReadyState)
		end
		ResizeRaidPanel(1, GetTableSize(aCurrentRaid.members))
	elseif aCurrentRaid.type == RAID_TYPE then
		for i, party in ipairs(aCurrentRaid.members) do
			for j, playerInfo in ipairs(party) do
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
		local members = raid.GetMembers()
		m_currentRaid.type = RAID_TYPE
		m_currentRaid.members = members
		m_currentRaid.currentLeaderUniqueID = raid.GetLeader()
		ShowPartyBtns(GetTableSize(members))
	elseif group.IsExist() then
		local members = group.GetMembers()
		m_currentRaid.type = PARTY_TYPE
		m_currentRaid.members = members
		m_currentRaid.currentLeaderUniqueID = group.GetLeader()
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
	if prevRaidMembers and not aFullUpdate and m_currentRaid.type == prevRaidType and m_currentRaid.type ~= SOLO_TYPE and prevLeaderUniqueID and prevLeaderUniqueID:IsEqual(m_currentRaid.currentLeaderUniqueID) then
		if raid.IsExist() then
			for i, party in ipairs(prevRaidMembers) do
				for j, prevRaidMember in ipairs(party) do
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
			for j, prevRaidMember in ipairs(prevRaidMembers) do
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
	
	for _, party in ipairs(m_raidPlayerPanelList) do
		for _, playerBar in ipairs(party) do
			playerBar.isUsed = false
		end
	end

	BuildRaidGUI(m_currentRaid, reusedRaidListeners)
	ReadyCheckChanged()

	local canMovePlayers = CanMovePlayers(avatar.GetUniqueId())
	for _, party in ipairs(m_raidPlayerPanelList) do
		for _, playerBar in ipairs(party) do
			if not playerBar.isUsed then
				HidePlayerBar(playerBar)
				playerBar.playerID = nil
			else
				DnD.Enable(playerBar.wdg, canMovePlayers)
			end
		end
	end
	
	FabricDestroyUnused()
end

function HideMove()
	if m_moveMode then
		for _, party in ipairs(m_raidPlayerPanelList) do
			for _, playerBar in ipairs(party) do
				DnD.HideWdg(playerBar.raidMoveWdg)
			end
		end
	end
end

function StopMove()
	if m_moveMode then
		if DnD.Dragging and DnD.Widgets[ DnD.Dragging ] then
			DnD.Widgets[ DnD.Dragging ].wtReacting:DNDCancelDrag()
		end
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
	if A.objNameLower == "" or B.objNameLower == "" then
		if A.objNameLower > B.objNameLower then
			return true
		elseif A.objNameLower == B.objNameLower then
			return A.objID < B.objID
		end
		return false
	end
	
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
	for i, info in ipairs(objArr) do
		if info.objID == anObjID then
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
	local profile = GetCurrentProfile()
	local isPlayer = cachedIsPlayer(anObjID)
	local isPet = isPlayer and false or cachedIsPet(anObjID)
	local isCanSelect = cachedCanSelectTarget(anObjID)
	if profile.targeterFormSettings.hideUnselectableButton and not isPlayer and not isPet then
		if not isCanSelect then
			m_targetUnselectable[anObjID] = true
			return
		end
	end
	m_targetUnselectable[anObjID] = nil
	
	local isEnemy = cachedIsEnemy(anObjID)
	local isFriend = isEnemy and false or cachedIsFriend(anObjID)
	local isNeitral = not isEnemy and not isFriend
	
	if not isPlayer and not isPet and not isEnemy then
		if cachedGetReputationLevel(anObjID) == REPUTATION_LEVEL_NEUTRAL then
			isFriend = false
			isNeitral = true
		end
	end
	
	local newValue = {}
	newValue.objID = anObjID
	newValue.inCombat = anInCombat
	newValue.isCanSelect = ((isPlayer or isCanSelect) and 0) or 1

	newValue.objName = cachedGetName(newValue.objID)
	newValue.objNameLower = toLowerString(newValue.objName)
		
	if profile.targeterFormSettings.sortByClass then
		newValue.className = cachedGetClass(anObjID).className
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
		local healthInfo = cachedGetHealthInfo(anObjID)
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
	elseif not isPlayer and not isPet then
		if isEnemy then
			objArr = m_targetUnitsByType[ENEMY_MOBS_TARGETS]
		elseif isFriend then
			objArr = m_targetUnitsByType[FRIEND_MOBS_TARGETS]
		else
			objArr = m_targetUnitsByType[NEITRAL_MOBS_TARGETS]
		end
	elseif isPet then
		if isEnemy then
			objArr = m_targetUnitsByType[ENEMY_PETS_TARGETS]
		elseif isFriend then
			objArr = m_targetUnitsByType[FRIEND_PETS_TARGETS]
		else
			objArr = m_targetUnitsByType[NEITRAL_MOBS_TARGETS]
		end
	end
	AddTargetInList(newValue, objArr)
	
	objArr = m_targetUnitsByType[MY_SETTINGS_TARGETS]
	for _, targetsFromSettings in ipairs(profile.targeterFormSettings.myTargets) do
		if not FindInListTarget(anObjID, objArr) and newValue.objNameLower == targetsFromSettings.nameLowerStr then
			AddTargetInList(newValue, objArr)
		end
	end
end

local function CreateTargeterSubPanelCache(aProfile, aParentArr, aX)
	for i = 1, TARGETS_LIMIT do
		local playerPanel = CreatePlayerPanel(m_targetPanel, aX, i-1, false, aProfile.targeterFormSettings, i)
		table.insert(aParentArr, playerPanel)
		if aProfile.targeterFormSettings.twoColumnMode and not aProfile.targeterFormSettings.gorisontalModeButton then
			align(playerPanel.wdg, WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW)
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
	--normal
	table.insert(m_targeterPlayerPanelList, {})
	--combat
	table.insert(m_targeterPlayerPanelList, {})
	
	CreateTargeterSubPanelCache(profile, m_targeterPlayerPanelList[1], 0)
	if profile.targeterFormSettings.twoColumnMode then
		CreateTargeterSubPanelCache(profile, m_targeterPlayerPanelList[2], 1)
	end
end

local function ClearTargetPanels()
	UnsubscribeTargetListener()
	for _, statusGroup in ipairs(m_targeterPlayerPanelList) do
		for _, playerBar in ipairs(statusGroup) do
			HidePlayerBar(playerBar)
			playerBar.playerID = nil
		end
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
	table.insert(unitList, g_myAvatarID)
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
		SwitchTargetsBtn(TARGETS_DISABLE)
		ResizeTargetPanel(1, 0)
		ClearTargetPanels()
		
		HideTargetDropDownSelectPanel()
		
		UpdateLastTargetType(m_lastTargetType)
		UpdateLastTargetWasActive(false)		
	else
		m_currTargetType = m_lastTargetType
		LoadTargeterData()
		
		UpdateLastTargetWasActive(true)
	end
	ApplyTargetSettingsToGUI(m_targetPanel)
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

local function SetTargetPanels(aSortedTargetList, aTargeterPanelList, aReusedPanels, aFreePanels, aPanelPosShift)
	local cnt = 1
	local listOfObjToUpdate = {}
	local newTargeterPlayerPanelList = {}
	local profile = GetCurrentProfile()
	local playerBar = nil

	--собираем панели в новом порядке, используя как подходящие так и обновляя инфу
	for _, targetInfo in ipairs(aSortedTargetList) do
		local objID = targetInfo.objID
		playerBar = aReusedPanels[objID]
		if not playerBar then
			playerBar = table.remove(aFreePanels)
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
		aTargeterPanelList[cnt] = playerBar

		cnt = cnt + 1
	end
	local usedCnt = cnt
	--в список всех панелей добавляем все оставшиеся
	for i = cnt, TARGETS_LIMIT do
		aTargeterPanelList[cnt] = table.remove(aFreePanels)
		cnt = cnt + 1
	end
	--обновляем инфу на панелях
	for _, updateInfo in ipairs(listOfObjToUpdate) do
		local playerInfo = {}
		playerInfo.id = updateInfo.objID
		playerInfo.name = updateInfo.objName
		playerInfo.state = GROUP_MEMBER_STATE_NEAR
		SetBaseInfoPlayerPanel(updateInfo.playerBar, playerInfo, false,  profile.targeterFormSettings, updateInfo.relationType)
		FabricMakeTargetPlayerInfo(playerInfo.id, updateInfo.playerBar)
	end

	--расставляем панели и скрываем не используемые
	for i, playerBar in ipairs(aTargeterPanelList) do
		if playerBar.isUsed then
			ResetPlayerPanelPosition(playerBar, aPanelPosShift, i-1, profile.targeterFormSettings)
		else
			if playerBar.playerID then
				UnsubscribeTargetListener(playerBar.playerID)
				HidePlayerBar(playerBar)
			end
			playerBar.playerID = nil
		end
	end
	return usedCnt
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
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, ENEMY_PETS_TARGETS))
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, FRIEND_PETS_TARGETS))
	elseif aType == ENEMY_TARGETS then
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, ENEMY_PLAYERS_TARGETS))
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, ENEMY_MOBS_TARGETS))
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, ENEMY_PETS_TARGETS))
	elseif aType == FRIEND_TARGETS then
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, FRIEND_PLAYERS_TARGETS))
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, FRIEND_MOBS_TARGETS))
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, FRIEND_PETS_TARGETS))
	elseif aType == ENEMY_MOBS_TARGETS then
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, ENEMY_MOBS_TARGETS))
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, ENEMY_PETS_TARGETS))
	elseif aType == FRIEND_MOBS_TARGETS then
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, FRIEND_MOBS_TARGETS))
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, FRIEND_PETS_TARGETS))
	elseif aType == NOT_FRIENDS_TARGETS then
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, ENEMY_PLAYERS_TARGETS))
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, NEITRAL_PLAYERS_TARGETS))
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, ENEMY_MOBS_TARGETS))
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, ENEMY_PETS_TARGETS))
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, NEITRAL_MOBS_TARGETS))
	elseif aType == NOT_FRIENDS_PLAYERS_TARGETS then	
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, ENEMY_PLAYERS_TARGETS))
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, NEITRAL_PLAYERS_TARGETS))
	elseif aType == ENEMY_WITHOUT_PETS_TARGETS then
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, ENEMY_PLAYERS_TARGETS))
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, ENEMY_MOBS_TARGETS))
	else
		table.insert(targetUnion, GetArrByCombatStatus(aStatus, aType))
	end
	return targetUnion
end

local function GetObjListToDisplay(aTargetUnion)
	local cnt = 0
	local listOfObjForDisplay = {}
	--формируем список для отображения
	for _, unitsByType in ipairs(aTargetUnion) do
		SortBySettings(unitsByType)
		for _, targetInfo in pairs(unitsByType) do
			if cnt < TARGETS_LIMIT and isExist(targetInfo.objID) then
				table.insert(listOfObjForDisplay, targetInfo)
				cnt = cnt + 1
			end
		end
	end
	return listOfObjForDisplay
end

local function IsSameTargetPanel(anObjList, aPlayerBar)
	for _, info in ipairs(anObjList) do
		if aPlayerBar.playerID == info.objID
		and (aPlayerBar.formSettings.classColorModeButton or aPlayerBar.panelColorType == info.relationType)
		then
			return true
		end			
	end
	return false
end

local function SeparateTargeterPanelList(anObjList1, anObjList2)
	local findedList = {} 
	local freeList = {}
	for _, statusGroup in ipairs(m_targeterPlayerPanelList) do
		for _, playerBar in ipairs(statusGroup) do
			local found = IsSameTargetPanel(anObjList1, playerBar)
			found = found or IsSameTargetPanel(anObjList2, playerBar)
			if found then
				findedList[playerBar.playerID] = playerBar
			else
				table.insert(freeList, playerBar)
			end
		end
	end
	return findedList, freeList
end

function TryRedrawTargeter(aType, aDelayRedraw)
	-- под мышью - обновим список целей раз в 2 сек
	-- aDelayRedraw - обновим список целей раз в 0,1 сек

	if not m_targeterUnderMouseNow and not aDelayRedraw then
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
	for _, statusGroup in ipairs(m_targeterPlayerPanelList) do
		for _, playerBar in ipairs(statusGroup) do
			playerBar.isUsed = false
		end
	end
	
	local targetUnion = MakeTargetUnion(aType, false)
	local targetUnionCombat = {}
	if profile.targeterFormSettings.twoColumnMode then
		targetUnionCombat = MakeTargetUnion(aType, true)
	end
	
	local nonCombatListToDisplay = GetObjListToDisplay(targetUnion)
	local combatListToDisplay = GetObjListToDisplay(targetUnionCombat)
	--находим панели уже отображаемых игроков
	local reusedPanels, freePanels = SeparateTargeterPanelList(nonCombatListToDisplay, combatListToDisplay)

	local cntSimple = 0
	local cntCombat = 0
	if profile.targeterFormSettings.twoColumnMode then
		cntSimple = SetTargetPanels(nonCombatListToDisplay, m_targeterPlayerPanelList[1], reusedPanels, freePanels, 0)
		cntCombat = SetTargetPanels(combatListToDisplay, m_targeterPlayerPanelList[2], reusedPanels, freePanels, 1)
	else
		cntSimple = SetTargetPanels(nonCombatListToDisplay, m_targeterPlayerPanelList[1], reusedPanels, freePanels, 0)
	end

	local maxPeopleCnt = math.min(math.max(cntSimple, cntCombat), TARGETS_LIMIT)
	FabricDestroyUnused()
	if profile.targeterFormSettings.twoColumnMode then
		ResizeTargetPanel(2, maxPeopleCnt)
	else
		ResizeTargetPanel(1, maxPeopleCnt)
	end
	TargetChangedForTargeter(avatar.GetTarget())
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
		
		-- пока не получили EVENT_UNITS_CHANGED данные могут быть невалидными
		if FindTarget(paramsID) and isExist(paramsID) then
			if not profile.targeterFormSettings.twoColumnMode then
				aParams.inCombat = false
			else
				if aParams.inCombat == nil then
					aParams.inCombat = object.IsInCombat(paramsID)
				end
			end
		
			EraseTarget(paramsID)
			SetNecessaryTargets(paramsID, aParams.inCombat)
			TryRedrawTargeter(m_currTargetType, true)
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
		-- пока не получили EVENT_UNITS_CHANGED данные могут быть невалидными
		if FindTarget(playerID) and isExist(playerID) then
			EraseTarget(playerID)
			local isCombat = false
			if profile.targeterFormSettings.twoColumnMode then
				isCombat = object.IsInCombat(playerID)
			end
			SetNecessaryTargets(playerID, isCombat)
			someTargetUpdated = true
		end
	end
	if someTargetUpdated then
		TryRedrawTargeter(m_currTargetType, true)
	end
end

local function UnitDeadChangedForTargeter(aParams)
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
	-- пока не получили EVENT_UNITS_CHANGED данные могут быть невалидными
	if FindTarget(aParams.unitId) and isExist(aParams.unitId) then
		EraseTarget(aParams.unitId)
		local isCombat = false
		if profile.targeterFormSettings.twoColumnMode then
			isCombat = object.IsInCombat(aParams.unitId)
		end
		SetNecessaryTargets(aParams.unitId, isCombat)
		TryRedrawTargeter(m_currTargetType, true)
	end
end

local function UnitDeadChanged(aParams)
	UnitDeadChangedForTargeter(aParams)
	UnitDead(aParams)
end

local function ProgressStart(aParams, aPanelList, aProgressQueue)
	local profile = GetCurrentProfile()
	local actionType = GetProgressActionType(aParams)
	
	if actionType == BUFF_PROGRESS and isExist(aParams.objectId) and cachedIsPlayer(aParams.objectId) then
		return false
	end
	
	local objID = aParams.objectId or aParams.id
	local queuedParams = aProgressQueue[objID]
	
	local correctInfo = CheckCorrectInfo(queuedParams)
	if not correctInfo then
		return false
	end

	if profile.castFormSettings.showOnlyMyTarget then
		local targetID = avatar.GetTarget()
		if objID ~= targetID then
			return false
		end
	end

	if isExist(objID) then
		local progressName = queuedParams.buffName or queuedParams.name
		local objNameLower = toLowerString(cachedGetName(objID))
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
					return false
				end
			end
		end
	end
	local cnt = 0
	for _, progressPanel in ipairs(aPanelList) do
		if progressPanel.isUsed then
			cnt = cnt + 1
		end
	end
	
	local panel = GetProgressCastPanel(objID, aPanelList)
	if panel then 
		SetBaseInfoProgressCastPanel(panel, queuedParams, actionType, queuedParams.buffInfo)
		queuedParams.isShowedInGuiSlot = true
		return true
	else
		panel = GetFreeProgressCastPanel(aPanelList)
		if panel then 
			SetBaseInfoProgressCastPanel(panel, queuedParams, actionType, queuedParams.buffInfo)
			UpdatePositionProgressCastPanels(aPanelList)
			queuedParams.isShowedInGuiSlot = true
			return true
		else
			return false
		end	
	end
end

local function ProgressEnd(aParams, aPanelList, aProgressQueue)
	local panel = GetProgressCastPanel(aParams.objectId or aParams.id, aPanelList)
	--несколько длительных контролей на цели, отображаем (а значит и удаляем) только последний
	if panel and panel.buffID == aParams.buffId then
		StopShowProgressForPanel(panel, aPanelList, aProgressQueue)
	end
end

local function ActionProgressStart(aParams)
	local profile = GetCurrentProfile()
	if not profile.castFormSettings.showImportantCasts then 
		return
	end
	m_progressActionQueue[aParams.id] = table.sclone(aParams)
	m_progressActionQueue[aParams.id].queueTimestamp_h = g_cachedTimestamp
	ProgressStart(aParams, m_progressActionPanelList, m_progressActionQueue)
end

local function ActionProgressEnd(aParams)
	m_progressActionQueue[aParams.id] = nil
	ProgressEnd(aParams, m_progressActionPanelList, m_progressActionQueue)
	TryShowProgressFromQueue(m_progressActionPanelList, m_progressActionQueue)
end

local function BuffProgressStart(aParams)
	local profile = GetCurrentProfile()
	if not profile.castFormSettings.showImportantBuffs then 
		return
	end
	--при появлении длительного контроля сбрасываем отображение каста этого моба
	StopShowProgressForPanel(GetProgressCastPanel(aParams.objectId, m_progressActionPanelList), m_progressActionPanelList, m_progressActionQueue)
	
	m_progressBuffQueue[aParams.objectId] = table.sclone(aParams)
	m_progressBuffQueue[aParams.objectId].queueTimestamp_h = g_cachedTimestamp
	m_progressBuffQueue[aParams.objectId].buffInfo = aParams.buffId and object.GetBuffInfo(aParams.buffId)
	ProgressStart(aParams, m_progressBuffPanelList, m_progressBuffQueue)
end

local function BuffProgressEnd(aParams)
	m_progressBuffQueue[aParams.objectId] = nil
	ProgressEnd(aParams, m_progressBuffPanelList, m_progressBuffQueue)
	TryShowProgressFromQueue(m_progressBuffPanelList, m_progressBuffQueue)
end

function TryShowProgressFromQueue(aPanelList, aProgressQueue)
	for objID, info in pairs(aProgressQueue) do
		if not info.isShowedInGuiSlot and ProgressStart(info, aPanelList, aProgressQueue) then	
			return
		end
	end
end

function StopShowProgressForPanel(aPanel, aPanelList, aProgressQueue)
	if aPanel then
		if aPanel.playerID then
			aProgressQueue[aPanel.playerID] = nil
		end
		ClearProgressCastPanel(aPanel)
		UpdatePositionProgressCastPanels(aPanelList)
	end
end

function StopShowProgressNow(anObjID)
	StopShowProgressForPanel(GetProgressCastPanel(anObjID, m_progressActionPanelList), m_progressActionPanelList, m_progressActionQueue)
	StopShowProgressForPanel(GetProgressCastPanel(anObjID, m_progressBuffPanelList), m_progressBuffPanelList, m_progressBuffQueue)
	m_progressActionQueue[anObjID] = nil
	m_progressBuffQueue[anObjID] = nil
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
		for _, objID in ipairs(aParams.spawned) do
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
		for _, objID in ipairs(aParams.despawned) do
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
		for _, objID in ipairs(aParams.despawned) do
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
		TryRedrawTargeter(m_currTargetType, false)
	end

	if m_castSubSystemLoaded and profile.castFormSettings.showImportantCasts then
		for _, objID in pairs(existSpawned) do
			if not cachedIsPlayer(objID) then
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
	if isExist(aParams.id) then
		local param = {}
		param.spawned = {}
		param.spawned[1] = aParams.id
		param.despawned = {}
	
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
			TryRedrawTargeter(m_currTargetType, true)
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
	local raidForm = common.GetAddonMainForm("Raid")
	if anIsUnloadRaidSubsystem or profile.raidFormSettings.showStandartRaidButton then
		if raid.IsExist() or group.IsExist() then
			if IsRaidGUIEnabled() or raid.IsExist() then
				show(getChild(raidForm, "Raid"))
				show(getChild(raidForm, "Toolbar"))
			else
				show(getChild(common.GetAddonMainForm("Plates"), "Party"))
				show(getChild(common.GetAddonMainForm("Buffs"), "Party"))
			end
		end
	else
		SwitchPartyGUIToRaidGUI()

		hide(getChild(raidForm, "Raid"))
		hide(getChild(raidForm, "Toolbar"))
	end	
end

local function GUIInit()
	CreateMainBtn()

	m_buffsGroupParentForm = InitGroupsParentForm()
	m_raidPanel = InitRaidPanel()
	m_targetPanel = InitTargeterPanel()
	m_raidPartyButtons = CreateRaidPartyBtn(m_raidPanel)
	m_progressActionPanel = InitProgressActionPanel()
	m_progressBuffPanel = InitProgressBuffPanel()
end

--при отключении нашего аддона возвращаем дефолтовый интерфейс рейда
function AddonStateChanged(aParams)
	if aParams.name == common.GetAddonSysName() and aParams.state == ADDON_STATE_UNLOADING then
		if not GetCurrentProfile().raidFormSettings.showStandartRaidButton and m_raidSubSystemLoaded then
			if (raid.IsExist() or group.IsExist()) and IsRaidGUIEnabled() then
				local raidForm = common.GetAddonMainForm("Raid")
				show(getChild(raidForm, "Raid"))
				show(getChild(raidForm, "Toolbar"))
			end
		end
	end
end

function OnEventSecondTimer()
	--при таргетере под курсором мыши перерисовываем лишь раз в 2 секунды (чтобы легче выбрать)
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
		hide(getChild(raidForm, "Raid"))
		hide(getChild(raidForm, "Toolbar"))
	end
	-- затычка №2 - бывает что не приходит событие что юнит исчез, проверяем актуальность отображаемых персонажей в таргетере
	local unitList = avatar.GetUnitList()
	table.insert(unitList, g_myAvatarID)
	if m_targetSubSystemLoaded then
		local eraseSomeTarget = false
		for _, statusGroup in ipairs(m_targeterPlayerPanelList) do
			for _, playerBar in ipairs(statusGroup) do
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
		end
			
		if eraseSomeTarget then
			TryRedrawTargeter(m_currTargetType, false)
		end
	end
	if m_buffGroupSubSystemLoaded then
		RemovePanelForNotExistObj(unitList)
	end
	if m_castSubSystemLoaded then
		RemoveProgressForNotExistObj(unitList, m_progressActionPanelList, m_progressActionQueue)
		RemoveProgressForNotExistObj(unitList, m_progressBuffPanelList, m_progressBuffQueue)
	end
	
	FabicLogInfo()
end

-- затычка №3 бывает что после выхода с БГ остаётся пустой рейд и иногда (но всегда) он сам чинится без событий
function FixRaid()
	if m_raidSubSystemLoaded and m_currentRaid.type ~= SOLO_TYPE then
		if GetTableSize(m_currentRaid.members) == 0 then
			RaidChanged(nil, true)
		end
	end
end

local function Update()
	updateCachedTimestamp()
	UpdateFabric()
	
	if m_targetSubSystemLoaded and not m_targeterUnderMouseNow and m_needRedrawTargeter then
		RedrawTargeter(m_currTargetType)
		m_needRedrawTargeter = false
		m_redrawPauseCnt = 0
	end
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
	
	ApplyRaidSettingsToGUI(m_raidPanel)
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
	for _, party in ipairs(m_raidPlayerPanelList) do
		for _, playerBar in ipairs(party) do
			DestroyPlayerPanel(playerBar)
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
	InitTargeterData()
	TargetWorkSwitch()
end

function UnloadTargeterSubSystem()
	if not m_targetSubSystemLoaded then
		return
	end
	m_targetSubSystemLoaded = false
	
	ClearTargetPanels()
	for _, statusGroup in ipairs(m_targeterPlayerPanelList) do
		for _, playerBar in ipairs(statusGroup) do
			DestroyPlayerPanel(playerBar)
		end
	end
	m_targeterPlayerPanelList = {}
	DnD.HideWdg(m_targetPanel)
end

function InitGroupBuffSubSystem()
	if m_buffGroupSubSystemLoaded then
		UnloadGroupBuffSubSystem()
	end
	m_buffGroupSubSystemLoaded = true
	
	InitAboveHeadPanelsCache(m_buffsGroupParentForm)
	
	common.RegisterEventHandler(CannotAttachPanelAboveHead, "EVENT_CANNOT_ATTACH_WIDGET_3D")
	
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
	--PROGRESS_PANELS_LIMIT+1 - moveheader + PROGRESS_PANELS_LIMIT
	resize(aPanel, tonumber(profile.castFormSettings.panelWidthText), tonumber(profile.castFormSettings.panelHeightText+1)*(PROGRESS_PANELS_LIMIT+1))
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
			if isExist(objID) and not cachedIsPlayer(objID) then
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
	
	for _, progressPanel in ipairs(m_progressActionPanelList) do
		hide(progressPanel.wdg)
		destroy(progressPanel.wdg)
	end
	for _, progressPanel in ipairs(m_progressBuffPanelList) do
		hide(progressPanel.wdg)
		destroy(progressPanel.wdg)
	end
	m_progressActionPanelList = {}
	m_progressBuffPanelList = {}
	m_progressActionQueue = {}
	m_progressBuffQueue = {}
	
	DnD.HideWdg(m_progressActionPanel)
	DnD.HideWdg(m_progressBuffPanel)
	
	common.UnRegisterEventHandler(ActionProgressStart, "EVENT_MOB_ACTION_PROGRESS_START")
	common.UnRegisterEventHandler(ActionProgressEnd, "EVENT_MOB_ACTION_PROGRESS_FINISH")
	common.UnRegisterEventHandler(BuffProgressStart, "EVENT_OBJECT_BUFF_PROGRESS_ADDED")
	common.UnRegisterEventHandler(BuffProgressEnd, "EVENT_OBJECT_BUFF_PROGRESS_REMOVED")
	common.UnRegisterEventHandler(ClearProgressPanelOnEndAnimation, "EVENT_EFFECT_FINISHED")
end




function GUIControllerInit()
	initTimeAbbr()
	
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
	
	AddReaction("closeButton", function (aWdg) WndMgr.SwapWnd(getParent(aWdg)) end)
	AddReaction("UniverseButton", SwapMainSettingsForm)
	AddReaction("closeExprotBtn", function (aWdg) WndMgr.SwapWnd(getParent(aWdg)) end)
	AddReaction("closeButtonOK", function (aWdg) WndMgr.SwapWnd(getParent(aWdg)) end)
	AddReaction("profilesButton", SwapProfileForm)
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
	
	startTimer("fixRaid", FixRaid, 30)
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

	common.RegisterEventHandler(effectDone, "EVENT_EFFECT_FINISHED")
	
	common.RegisterEventHandler(OnInterfaceToggle, "EVENT_INTERFACE_TOGGLE" )
	common.RegisterEventHandler(OnTalentsChanged, "EVENT_TALENTS_CHANGED" )
	
	common.RegisterEventHandler(AvatarClassFormChanged, "EVENT_AVATAR_CLASS_FORM_CHANGED" )
	
	common.RegisterEventHandler(AddonStateChanged, "EVENT_ADDON_LOAD_STATE_CHANGED")
		
	--EVENT_TRACK_ADDED

	
	--из-за лимита в 500 подписок на события какие не требуют привязки по ID вынесены из PlayerInfo
	common.RegisterEventHandler(AfkChanged, "EVENT_AFK_STATE_CHANGED")
	common.RegisterEventHandler(UnitDeadChanged, "EVENT_UNIT_DEAD_CHANGED")
	common.RegisterEventHandler(WoundsChanged, "EVENT_UNIT_WOUNDS_COMPLEXITY_CHANGED")
	common.RegisterEventHandler(UpdateUnselectable, "EVENT_OBJECT_SELECTABLE_CHANGED")
	
	common.RegisterReactionHandler(OnLeftClick, "OnPlayerBarLeftClick")
	common.RegisterReactionHandler(OnRightClick, "OnPlayerBarRightClick" )
	common.RegisterReactionHandler(OnLeftClick, "OnProgressBarLeftClick")
	common.RegisterReactionHandler(OnRightClick, "OnProgressBarRightClick" )
	common.RegisterReactionHandler(OnPlayerBarPointing, "OnPlayerBarPointing" )
	common.RegisterReactionHandler(OnDropDownBtnPointing, "DropDownBtnOnPointing")
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
	common.RegisterReactionHandler(function (aParams) WndMgr.OnWndClicked(aParams.widget) end, "PanelWndClick")
end