local m_template = nil

function CreateProfilesForm()
	local form=createWidget(nil, "configProfilesForm", "Form", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 600, 280, 800, 450)
	priority(form, 5500)
	hide(form)
	local panel=createWidget(form, nil, "Panel")
	setLocaleText(createWidget(form, "configProfilesHeader", "TextView",  WIDGET_ALIGN_CENTER, nil, 250, 20, nil, 20))
	setText(createWidget(form, "closeButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 20, 20, 20, 20), "x")

	createWidget(form, "container", "ScrollableContainer", nil, nil, 560, 150, 20, 40)

	setLocaleText(createWidget(form, "saveAsProfileButton", "Button", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 330, 25, 20, 200))
	createWidget(form, "EditLine1", "EditLine", nil, nil, 210, 25, 360, 200)


	DnD:Init(form, panel, true)

	return form
end