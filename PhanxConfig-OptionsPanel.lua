--[[--------------------------------------------------------------------
	PhanxConfig-OptionsPanel
	Simple options panel frame generator. Requires LibStub.
	https://github.com/Phanx/PhanxConfig-OptionsPanel

	Copyright (c) 2009-2014 Phanx <addons@phanx.net>. All rights reserved.

	Permission is granted for anyone to use, read, or otherwise interpret
	this software for any purpose, without any restrictions.

	Permission is granted for anyone to embed or include this software in
	another work not derived from this software that makes use of the
	interface provided by this software for the purpose of creating a
	package of the work and its required libraries, and to distribute such
	packages as long as the software is not modified in any way, including
	by modifying or removing any files.

	Permission is granted for anyone to modify this software or sample from
	it, and to distribute such modified versions or derivative works as long
	as neither the names of this software nor its authors are used in the
	name or title of the work or in any other way that may cause it to be
	confused with or interfere with the simultaneous use of this software.

	This software may not be distributed standalone or in any other way, in
	whole or in part, modified or unmodified, without specific prior written
	permission from the authors of this software.

	The names of this software and/or its authors may not be used to
	promote or endorse works derived from this software without specific
	prior written permission from the authors of this software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
	IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
	OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
	ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	OTHER DEALINGS IN THE SOFTWARE.
----------------------------------------------------------------------]]

local MINOR_VERSION = 172

local lib, oldminor = LibStub:NewLibrary("PhanxConfig-OptionsPanel", MINOR_VERSION)
if not lib then return end

lib.objects = lib.objects or {}

local function OptionsPanel_OnShow(self)
	if InCombatLockdown() then return end
	local i, target = 1, self.parent or self.name
	while true do
		local button = _G["InterfaceOptionsFrameAddOnsButton"..i]
		if not button then break end
		local element = button.element
		if element and element.name == target then
			if element.hasChildren and element.collapsed then
				_G["InterfaceOptionsFrameAddOnsButton"..i.."Toggle"]:Click()
			end
			return
		end
		i = i + 1
	end
end

local function OptionsPanel_OnFirstShow(self)
	if type(self.runOnce) == "function" then
		local success, err = pcall(self.runOnce, self)
		self.runOnce = nil
		if not success then error(err) end
	end

	if type(self.refresh) == "function" then
		self.refresh(self)
	end

	self:SetScript("OnShow", OptionsPanel_OnShow)
	if self:IsShown() then
		OptionsPanel_OnShow(self)
	end
end

local function OptionsPanel_OnClose(self)
	if InCombatLockdown() then return end
	local i, target = 1, self.parent or self.name
	while true do
		local button = _G["InterfaceOptionsFrameAddOnsButton"..i]
		if not button then break end
		local element = button.element
		if element.name == target then
			if element.hasChildren and not element.collapsed then
				local selection = InterfaceOptionsFrameAddOns.selection
				if not selection or selection.parent ~= target then
					_G["InterfaceOptionsFrameAddOnsButton"..i.."Toggle"]:Click()
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
	"Slider",
}

function lib:New(name, parent, construct, refresh)
	local frame
	if type(name) == "table" and name.IsObjectType and name:IsObjectType("Frame") then
		frame = name
	else
		assert(type(name) == "string", "PhanxConfig-OptionsPanel: Name is not a string!")
		if type(parent) ~= "string" then parent = nil end
		frame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
		frame:Hide()
		frame.name = name
		frame.parent = parent
		InterfaceOptions_AddCategory(frame, parent)
	end

	if type(construct) ~= "function" then construct = nil end
	if type(refresh) ~= "function" then refresh = nil end

	for _, widget in pairs(widgetTypes) do
		local lib = LibStub("PhanxConfig-"..widget, true)
		if lib then
			local method = "Create"..widget
			frame[method] = lib[method]
		end
	end

	frame.refresh = refresh
	frame.okay = OptionsPanel_OnClose
	frame.cancel = OptionsPanel_OnClose

	frame.runOnce = construct

	if frame:IsShown() then
		OptionsPanel_OnFirstShow(frame)
	else
		frame:SetScript("OnShow", OptionsPanel_OnFirstShow)
	end

	if InterfaceOptionsFrame:IsShown() and not InCombatLockdown() then
		InterfaceAddOnsList_Update()
		if parent then
			local parentFrame = self:GetOptionsPanel(parent)
			if parentFrame then
				OptionsPanel_OnShow(parentFrame)
			end
		end
	end

	tinsert(self.objects, frame)
	return frame
end

function lib:GetOptionsPanel(name, parent)
	local panels = self.objects
	for i = 1, #panels do
		if panels[i].name == name and panels[i].parent == parent then
			return panels[i]
		end
	end
end

function lib.CreateOptionsPanel(...) return lib:New(...) end