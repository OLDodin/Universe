Global( "CSlider", {} )

function CreateSlider(aParent, aName, anAlignX, anAlignY, aWidth, aHeight, aPosX, aPosY)
	local slider = copyTable(CSlider)
	slider:Create(aParent, aName, anAlignX, anAlignY, aWidth, aHeight, aPosX, aPosY)
	slider.reactionFunc = slider:GetReactionHandlers()
	common.RegisterReactionHandler(slider.reactionFunc, 'discrete_slider_changed')

	return slider
end

local function Round( number )
	local sign = number > 0 and 1 or -1
	return math.floor( math.abs( number ) + 0.5 ) * sign
end

local tagFontName = toWString("fontname")
local tagAlignX = toWString("alignx")
local tagFontsize = toWString("fontsize")
local tagShadow = toWString("shadow")
local tagOutline = toWString("outline")
local tagColor = toWString("color")
local tagTextValue = toWString("value")

local function SetTextAttributes(aWdg, aParams, aTextValue)
	if aParams then
		local attributes = {}
		if aParams.fontName then
			attributes[ tagFontName ] = toStringUtils(aParams.fontName)
		end	
		if aParams.align then
			attributes[ tagAlignX ] = aParams.align
		end	
		if  aParams.fontSize then
			attributes[ tagFontsize ] = tostring(aParams.fontSize)
		end	
		if aParams.shadow then
			attributes[ tagShadow ] = tostring(aParams.shadow)
		end	
		if aParams.outline then
			attributes[ tagOutline ] = tostring(aParams.outline)
		end	
		if aParams.color then
			attributes[ tagColor ] = aParams.color
		end	
		if table.nkeys(attributes) > 0 then
			aWdg:SetTextAttributes(true, tagTextValue, attributes)
		end
	end

	if aTextValue then
		aWdg:SetVal(tagTextValue, toWString(aTextValue))
	end
end

function CSlider:Create(aParent, aName, anAlignX, anAlignY, aWidth, aHeight, aPosX, aPosY)
	self.widget	= createWidget(aParent, aName, "SliderPanel", anAlignX, anAlignY, aWidth, aHeight, aPosX, aPosY)
	
	self.inited = false
	self.description = self.widget:GetChildChecked( 'Description', false )
	self.valueText = self.widget:GetChildChecked( 'Value', false )
	self.slider = self.widget:GetChildChecked( 'DiscreteSlider', false )
	
	--fix broken WidgetDiscreteSlider in 15.2
	hide(self.widget)
	show(self.widget)
	--end fix
end

function CSlider:Init( aParams )
	if type( aParams ) ~= 'table' then return end
	
	self.value = aParams.value or 0
	self.valueMin = aParams.valueMin or 0
	local valueMax = aParams.valueMax or 1
	
	self.sliderChangedFunc = aParams.sliderChangedFunc
	
	local stepsCount = aParams.stepsCount or 10
	self.slider:SetStepsCount( stepsCount )
	
	self.step = ( valueMax - self.valueMin ) / stepsCount
	
	self.formatFunc = aParams.formatFunc 
	or function ( aValue )
		if ( Round( self.step ) - self.step ) ~= 0 then
			return common.FormatFloat( aValue, '%.2f' )
		end
		return common.FormatInt( aValue, '%d' )
	end
	
	self.slider:SetPos( Round( ( self.value - self.valueMin ) / self.step ) )
	
	SetTextAttributes(self.description, aParams.descTextAttr, aParams.description)
	SetTextAttributes(self.valueText, aParams.valueTextAttr, self.formatFunc( self.valueMin + self.slider:GetPos() * self.step ))
	
	if aParams.sliderWidth then
		resize(self.slider, aParams.sliderWidth)
		move(self.valueText, aParams.sliderWidth + 12)
	end
	
	self.inited = true
	self.widget:Show( true )
end

function CSlider:Set( aValue )
	if not self.inited then
		return
	end
	self.value = aValue
	self.slider:SetPos( Round( ( self.value - self.valueMin ) / self.step ) )
	self.valueText:SetVal( 'value', self.formatFunc( self.value ) )
end

function CSlider:Get()
	if not self.inited then
		return 0
	end
	return self.valueMin + self.slider:GetPos() * self.step
end

function CSlider:GetReactionHandlers( )
	return 
		function( aParams )
			if not self.slider:IsValid() then
				--wdg already destroyed
				self:PrepareDestroy()
				return
			end
			if aParams.widget == self.slider then
				self.value = self:Get()
				self.valueText:SetVal( 'value', self.formatFunc( self.value ) )
				if self.sliderChangedFunc then
					self.sliderChangedFunc( self.value )
				end
			end
		end
end

function CSlider:Clear( )
	self.widget:Show( false )
	
	self.value		= nil
	self.valueMin	= nil
	
	self.sliderChangedFunc	= nil
	
	self.step		= nil
	self.format		= nil
	
	self.description:ClearValues()
	self.valueText:ClearValues()
	
	self.inited = false
end

function CSlider:PrepareDestroy()
	common.UnRegisterReactionHandler(self.reactionFunc, 'discrete_slider_changed')
end