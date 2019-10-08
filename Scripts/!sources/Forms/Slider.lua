Global( "CSlider", {} )

function CreateSlider(aParent, aName, anAlignX, anAlignY, aWidth, aHeight, aPosX, aPosY, aSliderWidth)
	local slider = copyTable(CSlider)
	slider:Init(aParent, aName, anAlignX, anAlignY, aWidth, aHeight, aPosX, aPosY, aSliderWidth)
	common.RegisterReactionHandler(slider:GetReactionHandlers(), 'discrete_slider_changed')

	return slider
end

local function Round( number )
	local sign = number > 0 and 1 or -1
	return math.floor( math.abs( number ) + 0.5 ) * sign
end

function CSlider:Init(aParent, aName, anAlignX, anAlignY, aWidth, aHeight, aPosX, aPosY, aSliderWidth)
	self.widget	= createWidget(aParent, aName, "SliderPanel", anAlignX, anAlignY, aWidth, aHeight, aPosX, aPosY)
	
	self.description = self.widget:GetChildChecked( 'Description', false )
	self.valueText = self.widget:GetChildChecked( 'Value', false )
	self.slider = self.widget:GetChildChecked( 'DiscreteSlider', false )
	
	resize(self.slider, aSliderWidth)
	move(self.valueText, aSliderWidth+12)
end

function CSlider:Set( params )
	if type( params ) ~= 'table' then return end
	
	self.value		= params.value		or 0
	self.valueMin	= params.valueMin	or 0
	local valueMax	= params.valueMax	or 1
	
	self.execute	= params.execute
	
	local stepsCount	= params.stepsCount	or 10
	self.slider:SetStepsCount( stepsCount )
	
	self.step		= ( valueMax - self.valueMin ) / stepsCount
	
	self.format		= function( value )
		if ( Round( self.step ) - self.step ) ~= 0 then
			return common.FormatFloat( value, '%.2f' )
		end
		return common.FormatInt( value, '%d' )
	end
	
	self.slider:SetPos( Round( ( self.value - self.valueMin ) / self.step ) )
	
	self.description:SetVal( 'value', params.description )
	self.valueText:SetVal( 'value', self.format( self.valueMin + self.slider:GetPos() * self.step ) )
	self.widget:Show( true )
end

function CSlider:Get()
	return self.valueMin + self.slider:GetPos() * self.step
end

function CSlider:GetReactionHandlers( )
	return 
		function( params )
			if params.widget:IsEqual( self.slider ) then
				self.value = self.valueMin + params.widget:GetPos() * self.step
				self.valueText:SetVal( 'value', self.format( self.value ) )
				if self.execute then
					self.execute( self.value )
				end
			end
		end
end

function CSlider:Clear( )
	self.widget:Show( false )
	
	self.value		= nil
	self.valueMin	= nil
	
	self.execute	= nil
	
	self.step		= nil
	self.format		= nil
	
	self.description:ClearValues()
	self.valueText:ClearValues()
end