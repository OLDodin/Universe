local m_currentFormSettings = nil

function CreateProgressCastSettingsForm()
	setTemplateWidget(getChild(mainForm, "Template"))
	
	local form=createWidget(mainForm, "castSettingsForm", "Panel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 700, 410, 200, 100)
	hide(form)
	priority(form, 505)
	
	setText(createWidget(form, "closeSomeSettingsButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 20, 20, 20, 20), "x")

	setLocaleText(createWidget(form, "castSettingsFormHeader", "TextView",  WIDGET_ALIGN_CENTER, nil, 150, 20, nil, 16))
	
	setLocaleText(createWidget(form, "saveButton", "Button", WIDGET_ALIGN_CENTER, WIDGET_ALIGN_HIGH, 200, 30, nil, 20))
	
	createWidget(form, "showImportantCasts", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 330, 25, 20, 80)
	createWidget(form, "showImportantBuffs", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 330, 25, 20, 110)
	createWidget(form, "selectablePanel", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 330, 25, 20, 140)
	createWidget(form, "progressCastFixButton", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 330, 25, 20, 170)
	createWidget(form, "showOnlyMyTarget", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 330, 25, 20, 200)
	
	setLocaleText(createWidget(form, "panelWidthText", "TextView", nil, nil, 200, 25, 20, 230))
	createWidget(form, "panelWidthEdit", "EditLine", nil, nil, 70, 25, 280, 230)
	
	setLocaleText(createWidget(form, "panelHeightText", "TextView", nil, nil, 200, 25, 20, 260))
	createWidget(form, "panelHeightEdit", "EditLine", nil, nil, 70, 25, 280, 260)
	
	setLocaleText(createWidget(form, "resetPanelCastPosButton", "Button", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 200, 30, 20, 290))
	
	setLocaleText(createWidget(form, "ignoreListTxt", "TextView", nil, nil, 200, 25, 370, 50))
	createWidget(form, "ignoreListContainer", "ScrollableContainer", nil, nil, 310, 215, 370, 70)
	setLocaleText(createWidget(form, "addIgnoreCastsButton", "Button", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 280, 25, 385, 290))
	
	DnD.Init(form, form, true)
		
	return form
end

function SaveProgressCastFormSettings(aForm)
	if not aForm then
		return m_currentFormSettings
	end
	
	m_currentFormSettings.showImportantCasts = getCheckBoxState(getChild(aForm, "showImportantCasts"))
	m_currentFormSettings.showImportantBuffs = getCheckBoxState(getChild(aForm, "showImportantBuffs"))
	m_currentFormSettings.selectable = getCheckBoxState(getChild(aForm, "selectablePanel"))
	m_currentFormSettings.fixed = not getCheckBoxState(getChild(aForm, "progressCastFixButton"))
	m_currentFormSettings.showOnlyMyTarget = getCheckBoxState(getChild(aForm, "showOnlyMyTarget"))
	
	m_currentFormSettings.panelWidthText = getTextString(getChild(aForm, "panelWidthEdit"))
	m_currentFormSettings.panelHeightText = getTextString(getChild(aForm, "panelHeightEdit"))
	
	local container = getChild(aForm, "ignoreListContainer")
	if container and m_currentFormSettings.ignoreList then
		for i, j in ipairs(m_currentFormSettings.ignoreList) do
			j.name = getText(getChild(container, "Name"..tostring(i), true))
			j.exceptionsEditText = getText(getChild(aForm, "exceptionsEdit"..tostring(i), true))
		end
	end
	
	return m_currentFormSettings
end

function LoadProgressCastFormSettings(aForm)
	local profile = GetCurrentProfile()
	m_currentFormSettings = deepCopyTable(profile.castFormSettings)
	
	if not aForm then
		return
	end
	
		
	setLocaleText(getChild(aForm, "showImportantCasts"), m_currentFormSettings.showImportantCasts)
	setLocaleText(getChild(aForm, "showImportantBuffs"), m_currentFormSettings.showImportantBuffs)
	setLocaleText(getChild(aForm, "selectablePanel"), m_currentFormSettings.selectable)
	setLocaleText(getChild(aForm, "progressCastFixButton"), not m_currentFormSettings.fixed)
	setLocaleText(getChild(aForm, "showOnlyMyTarget"), m_currentFormSettings.showOnlyMyTarget)
	
	setText(getChild(aForm, "panelWidthEdit"), m_currentFormSettings.panelWidthText)
	setText(getChild(aForm, "panelHeightEdit"), m_currentFormSettings.panelHeightText)
	
	ShowValuesFromTable(m_currentFormSettings.ignoreList, aForm, getChild(aForm, "ignoreListContainer"))
end

function SetProgressCastPanelFixed(aForm)
	m_currentFormSettings.fixed = true
	setCheckBox(getChild(aForm, "progressCastFixButton"), not m_currentFormSettings.fixed)
end

function AddIgnoreCastToSroller(aForm)
	AddElementFromForm(m_currentFormSettings.ignoreList, aForm, getChild(aForm, "ignoreListContainer")) 
end

function DeleteIgnoreCastFromSroller(aForm, aDeletingWdg)
	DeleteContainer(m_currentFormSettings.ignoreList, aDeletingWdg, aForm)
end