function CreatePanelRaidMoveBar(aRaidPanel, aX, aY)
	setTemplateWidget(aRaidPanel)
	local profile = GetCurrentProfile()
	
	local panelWidth = tonumber(profile.raidFormSettings.raidWidthText)
	local panelHeight = tonumber(profile.raidFormSettings.raidHeightText)
	local mod1 = profile.raidFormSettings.gorisontalModeButton and aY or aX
	local mod2 = profile.raidFormSettings.gorisontalModeButton and aX or aY
	
	local addBar = createWidget(aRaidPanel, nil, "AddBar", nil, nil, panelWidth, panelHeight, mod1*panelWidth, mod2*panelHeight+30)
	resize(getChild(addBar, "HealthBarBackground"), panelWidth, panelHeight)
	setBackgroundTexture(addBar, nil)
	local addBarColor = {r=0.8, g=1, b=0.5, a=0.8}
	setBackgroundColor(addBar, addBarColor)
	hide(addBar)
	
	return addBar
end