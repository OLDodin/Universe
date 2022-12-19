function CreateExportProfilesForm()
	local form=createWidget(mainForm, "exportProfilesForm", "Panel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 600, 280, 800, 450)
	priority(form, 6)
	hide(form)
	
	setLocaleText(createWidget(form, "exportProfilesHeader", "TextView",  WIDGET_ALIGN_CENTER, nil, 450, 20, nil, 20))
	setText(createWidget(form, "closeButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 20, 20, 20, 20), "x")


	setLocaleText(createWidget(form, "closeExprotBtn", "Button", WIDGET_ALIGN_CENTER, WIDGET_ALIGN_HIGH, 150, 25, 0, 10))
	createWidget(form, "EditBox1", "EditBox", nil, nil, 560, 180, 20, 50)
	

	DnD.Init(form, form, true)

	return form
end

function SetEditText(aForm, aTxt)
	setText(getChild(aForm, "EditBox1"), aTxt)
	show(aForm)
end