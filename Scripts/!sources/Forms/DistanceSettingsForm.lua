

function CreateDistanceSettingsForm()
	local form=createWidget(mainForm, "distanceSettingsForm", "Panel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 350, 200, 200, 100)
	hide(form)
	priority(form, 507)
		
	setLocaleText(createWidget(form, "distanceSettingsFormHeader", "TextView",  WIDGET_ALIGN_CENTER, nil, 250, 20, nil, 16))
	setText(createWidget(form, "closeDistanceFormButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 20, 20, 20, 20), "x")
	
	createWidget(form, "showGrayOnDistanceButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 20, 80)
	createWidget(form, "showFrameStripOnDistanceButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 300, 25, 20, 110)
	setLocaleText(createWidget(form, "distanceText", "TextView", nil, nil, 200, 25, 20, 50))
	createWidget(form, "distanceEdit", "EditLine", nil, nil, 80, 25, 240, 50, nil, nil)
	
	
	setLocaleText(createWidget(form, "closeDistanceFormButton", "Button", WIDGET_ALIGN_CENTER, WIDGET_ALIGN_HIGH, 200, 30, nil, 20))
	
	DnD.Init(form, form, true)
		
	return form
end


function SaveDistanceFormSettings(aForm, aSettings)
	aSettings.distanceText = getTextString(getChild(aForm, "distanceEdit"))
	aSettings.showGrayOnDistanceButton = getCheckBoxState(getChild(aForm, "showGrayOnDistanceButton"))
	aSettings.showFrameStripOnDistanceButton = getCheckBoxState(getChild(aForm, "showFrameStripOnDistanceButton"))
end

function LoadDistanceFormSettings(aForm)
	local profile = GetCurrentProfile()
	local mySettings = profile.raidFormSettings
	
	setText(getChild(aForm, "distanceEdit"), mySettings.distanceText)
	setLocaleText(getChild(aForm, "showGrayOnDistanceButton"), mySettings.showGrayOnDistanceButton, true)
	setLocaleText(getChild(aForm, "showFrameStripOnDistanceButton"), mySettings.showFrameStripOnDistanceButton, true)
end