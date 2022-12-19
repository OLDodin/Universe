local m_redWdg = nil
local m_greenWdg = nil
local m_blueWdg = nil
local m_alphaWdg = nil
local m_colorPreview = nil
local m_loadedWndGroupBuffsNum = 0
local m_loadedWndBuffInd = 0
local m_loadedWndType = 0
local m_template = getChild(mainForm, "Template")


Global("GROUP_COLOR_TYPE", 1)
Global("RAID_COLOR_TYPE", 2)
Global("TARGET_COLOR_TYPE", 3)

local function GetColorFromColorSettingsForm()
	local color = {}
	color.r = m_redWdg:Get()
	color.g = m_greenWdg:Get()
	color.b = m_blueWdg:Get()
	--color.a = m_alphaWdg:Get()
	color.a = 1
	
	return color
end

local function OnColorChanged()
	m_colorPreview:SetBackgroundColor(GetColorFromColorSettingsForm())
end

function CreateColorSettingsForm(aSaveLoadType, aGroupBuffsNum, aBuffInd)
	m_loadedWndGroupBuffsNum = aGroupBuffsNum
	m_loadedWndBuffInd = aBuffInd
	m_loadedWndType = aSaveLoadType
	local profile = GetCurrentProfile()
	local info = nil 
	if m_loadedWndType == GROUP_COLOR_TYPE then
		info = profile.buffFormSettings.buffGroups[m_loadedWndGroupBuffsNum].buffs[m_loadedWndBuffInd]
	elseif m_loadedWndType == RAID_COLOR_TYPE then
		info = profile.raidFormSettings.raidBuffs.customBuffs[m_loadedWndBuffInd]
	elseif m_loadedWndType == TARGET_COLOR_TYPE then
		info = profile.targeterFormSettings.raidBuffs.customBuffs[m_loadedWndBuffInd]
	end
	
	if info.useHighlightBuff == nil then
		info.useHighlightBuff = false
	end
	if info.blinkHighlight == nil then
		info.blinkHighlight = false
	end
	if info.highlightColor == nil then
		info.highlightColor = {r=0, g=1, b=0, a=1}
	end
	
	setTemplateWidget(m_template)
	
	local form=createWidget(mainForm, "colorSettingsForm", "Panel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 400, 260, 200, 100)
	priority(form, 7)
	hide(form)
	
	setLocaleText(createWidget(form, "useHighlightBuffCheckBox", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 345, 25, 10, 150), info.useHighlightBuff)
	setLocaleText(createWidget(form, "blinkHighlightCheckBox", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 345, 25, 10, 180), info.blinkHighlight)
	
	setText(createWidget(form, "closeButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 20, 20, 20, 20), "x")
	setLocaleText(createWidget(form, "setColorButton", "Button", WIDGET_ALIGN_CENTER, WIDGET_ALIGN_HIGH, 200, 30, nil, 20))
	setLocaleText(createWidget(form, "headerColor", "TextView", WIDGET_ALIGN_CENTER, WIDGET_ALIGN_LOW, 250, 25, 20, 15))
	setText(createWidget(form, "buffName", "TextView", WIDGET_ALIGN_BOTH, WIDGET_ALIGN_LOW, nil, 25, 20, 40), info.name, "ColorYellow", "center", 18)
	
	m_colorPreview = createWidget(form, "colorPreview", "ImageBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 75, 75, 280, 70)	
	
	m_redWdg = CreateSlider(form, "redSlider", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 250, 25, 10, 70, 120)
	m_greenWdg = CreateSlider(form, "greenSlider", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 250, 25, 10, 95, 120)
	m_blueWdg = CreateSlider(form, "blueSlider", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 250, 25, 10, 120, 120)
	--m_alphaWdg = CreateSlider(form, "alphaSlider", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 250, 25, 10, 145, 120)
	
	local sliderParams	= {
							valueMin	= 0,
							valueMax	= 1.0,
							stepsCount	= 20,
							value		= 1.0,
							execute		= function( value ) OnColorChanged() end
						}
	
	
	sliderParams.description = getLocale()["red"]
	sliderParams.value = info.highlightColor.r
	m_redWdg:Set(sliderParams)
	sliderParams.description = getLocale()["green"]
	sliderParams.value = info.highlightColor.g
	m_greenWdg:Set(sliderParams)
	sliderParams.description = getLocale()["blue"]
	sliderParams.value = info.highlightColor.b
	m_blueWdg:Set(sliderParams)
	--sliderParams.description = getLocale()["alpha"]
	--sliderParams.value = info.highlightColor.a
	--m_alphaWdg:Set(sliderParams)
	

	DnD.Init(form, form, true)
	m_colorPreview:SetBackgroundColor(GetColorFromColorSettingsForm())
	
	return form
end

function SaveBuffColorHighlight(aForm)
	local profile = GetCurrentProfile()
	local info = nil
	if m_loadedWndType == GROUP_COLOR_TYPE then
		info = profile.buffFormSettings.buffGroups[m_loadedWndGroupBuffsNum].buffs[m_loadedWndBuffInd]
	elseif m_loadedWndType == RAID_COLOR_TYPE then
		info = profile.raidFormSettings.raidBuffs.customBuffs[m_loadedWndBuffInd]
	elseif m_loadedWndType == TARGET_COLOR_TYPE then
		info = profile.targeterFormSettings.raidBuffs.customBuffs[m_loadedWndBuffInd]
	end
	
	info.highlightColor = GetColorFromColorSettingsForm()
	info.useHighlightBuff = getCheckBoxState(getChild(aForm, "useHighlightBuffCheckBox"))
	info.blinkHighlight = getCheckBoxState(getChild(aForm, "blinkHighlightCheckBox"))
end

