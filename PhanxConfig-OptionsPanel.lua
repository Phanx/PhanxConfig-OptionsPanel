--[[--------------------------------------------------------------------
	PhanxConfig-OptionsPanel
	Simple options panel frame generator.
	Requires LibStub.

	This library is not intended for use by other authors. Absolutely no
	support of any kind will be provided for other authors using it, and
	its internals may change at any time without notice.
----------------------------------------------------------------------]]

local MINOR_VERSION = tonumber( string.match( "$Revision$", "%d+" ) )

local lib, oldminor = LibStub:NewLibrary( "PhanxConfig-OptionsPanel", MINOR_VERSION )
if not lib then return end

lib.objects = lib.objects or {}

local function OptionsPanel_OnShow( self )
	if InCombatLockdown() then return end

	local target = self.parent or self.name

	local i = 1
	while true do
		local button = _G[ "InterfaceOptionsFrameAddOnsButton" .. i ]
		if not button then break end

		local element = button.element
		if element.name == target then
			if element.hasChildren and element.collapsed then
				_G[ "InterfaceOptionsFrameAddOnsButton" .. i .. "Toggle" ]:Click()
			end
			return
		end

		i = i + 1
	end
end

local function OptionsPanel_OnFirstShow( self )
	if type( self.runOnce ) == "function" then
		local success, err = pcall( self.runOnce, self )
		self.runOnce = nil
		if not success then error( err ) end
	end

	if type( self.refresh ) == "function" then
		self.refresh( self )
	end

	if self:IsShown() then
		OptionsPanel_OnShow( self )
	end
	self:SetScript( "OnShow", OptionsPanel_OnShow )
end

local function OptionsPanel_OnClose( self )
	if InCombatLockdown() then return end

	local target = self.parent or self.name

	local i = 1
	while true do
		local button = _G[ "InterfaceOptionsFrameAddOnsButton" .. i ]
		if not button then break end

		local element = button.element
		if element.name == target then
			if element.hasChildren and not element.collapsed then
				local selection = InterfaceOptionsFrameAddOns.selection
				if not selection or selection.parent ~= target then
					_G[ "InterfaceOptionsFrameAddOnsButton" .. i .. "Toggle" ]:Click()
				end
			end
			return
		end

		i = i + 1
	end
end

local widgetTypes = {
	"Button",
	"Checkbox",
	"ColorPicker",
	"Dropdown",
	"EditBox",
	"Header",
	"KeyBinding",
	"Panel",
	"ScrollingDropdown",
	"Slider",
}

function lib:New( name, parent, construct, refresh )
	local frame
	if type( name ) == "table" and name.IsObjectType and name:IsObjectType( "Frame" ) then
		frame = name
	else
		assert( type( name ) == "string", "PhanxConfig-OptionsPanel: Name is not a string!" )
		if type( parent ) ~= "string" then parent = nil end
		frame = CreateFrame( "Frame", nil, InterfaceOptionsFramePanelContainer )
		frame.name = name
		frame.name = parent
		InterfaceOptions_AddCategory( frame, parent )
	end

	if type( construct ) ~= "function" then construct = nil end
	if type( refresh ) ~= "function" then refresh = nil end

	for _, widget in pairs( widgetTypes ) do
		local lib = LibStub( "PhanxConfig-"..widget, true )
		if lib then
			local method = "Create"..widget
			frame[method] = lib[method]
		end
	end

	frame.refresh = refresh
	frame.okay = OptionsPanel_OnClose
	frame.cancel = OptionsPanel_OnClose

	frame.runOnce = construct

	local shown = frame:IsVisible()
	frame:Hide()
	frame:SetScript( "OnShow", OptionsPanel_OnFirstShow )
	if shown then
		frame:Show()
	end

	tinsert( self.objects, frame )
	return frame
end

function lib:GetOptionsPanel( name, parent )
	local panels = self.objects
	for i = 1, #panels do
		if panels[i].name == name and panels[i].parent = parent then
			return panels[i]
		end
	end
end

function lib.CreateOptionsPanel( ... ) return lib:New( ... ) end