--[[--------------------------------------------------------------------
	PhanxConfig-OptionsPanel
	Simple options panel frame generator.
	Requires LibStub.

	This library is not intended for use by other authors. Absolutely no
	support of any kind will be provided for other authors using it, and
	its internals may change at any time without notice.
----------------------------------------------------------------------]]

local MINOR_VERSION = tonumber( string.match( "$Revision: 28 $", "%d+" ) )

local lib, oldminor = LibStub:NewLibrary( "PhanxConfig-OptionsPanel", MINOR_VERSION )
if not lib then return end

local OptionsPanel_OnShow = function( self )
	if type( self.runOnce ) == "function" then
		self.runOnce( self )
	end
	if type( self.refresh ) == "function" then
		self.refresh()
	end
	self.runOnce = nil
	self:SetScript( "OnShow", nil )
end

local function OptionsPanel_OnClose( self )
	if InCombatLockdown() then return end

	local target = self.parent or self.name

	local i = 1
	while true do
		local button = _G[ "InterfaceOptionsFrameAddOnsButton" .. i ]
		if not button then break end

		local element = button.element
		if element.name == target and element.hasChildren and not element.collapsed then
			local selection = InterfaceOptionsFrameAddOns.selection
			if not selection or selection.parent ~= target then
				_G[ "InterfaceOptionsFrameAddOnsButton" .. i .. "Toggle" ]:Click()
			end
			return
		end

		i = i + 1
	end
end

function lib.CreateOptionsPanel( name, parent, construct, refresh )
	if type( name ) ~= "string" then return end
	if type( parent ) ~= "string" then parent = nil end
	if type( construct ) ~= "function" then construct = nil end
	if type( refresh ) ~= "function" then refresh = nil end

	local f = CreateFrame( "Frame", nil, InterfaceOptionsFramePanelContainer )
	f:Hide()

	f.name = name
	f.parent = parent
	f.refresh = refresh

	f.okay = OptionsPanel_OnClose
	f.cancel = OptionsPanel_OnClose

	f.runOnce = construct
	f:SetScript( "OnShow", OptionsPanel_OnShow )

	InterfaceOptions_AddCategory( f, parent )

	return f
end