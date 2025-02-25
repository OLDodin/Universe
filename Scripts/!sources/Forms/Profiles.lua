
function CreateProfilesForm()
	setTemplateWidget(getChild(mainForm, "Template"))
	
	local form=createWidget(mainForm, "configProfilesForm", "Panel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 600, 280, 800, 450)
	priority(form, 506)
	hide(form)

	setLocaleText(createWidget(form, "configProfilesHeader", "TextView",  WIDGET_ALIGN_CENTER, nil, 250, 20, nil, 20))
	setText(createWidget(form, "closeButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 20, 20, 20, 20), "x")

	createWidget(form, "configProfilesContainer", "ScrollableContainer", nil, nil, 560, 150, 20, 42)

	setLocaleText(createWidget(form, "saveAsProfileButton", "Button", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 330, 25, 20, 200))
	setLocaleText(createWidget(form, "importProfileButton", "Button", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 330, 25, 20, 230))
	createWidget(form, "EditLine1", "EditLine", nil, nil, 210, 25, 360, 200)


	DnD.Init(form, form, true)

	return form
end

function LoadProfilesFormSettings(aForm)
	if not aForm then
		return
	end
	
	local allProfiles = GetAllProfiles()
	ShowValuesFromTable(allProfiles, aForm, getChild(aForm, "configProfilesContainer"))
end

function SaveProfilesFormSettings(aForm, aList)
	if not aForm then
		return
	end
	
	UpdateTableValuesFromContainer(aList, aForm, getChild(aForm, "configProfilesContainer"))
end