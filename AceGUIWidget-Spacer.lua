--[[-----------------------------------------------------------------------------
Spacer Widget

Spacer API

:SetImage(path,...)
   same as Label:SetImage

:SetImageSize(w,h)
   same as Label:SetImageSize

Because the whole point is to take up space, the most-used functions will
probably be the sizing routines from the base widget API.

-farmbuyer
-------------------------------------------------------------------------------]]
local Type, Version = "Spacer", 2
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs

-- WoW APIs
local CreateFrame = CreateFrame


--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]


--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]


--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function (self)
		self:SetHeight(110)
		self:SetWidth(110)
		self:SetImage(nil)
		self.frame:EnableMouse(true)  -- needed?
	end,

	--["OnRelease"] = function (self) end,

	["SetImage"] = function (self, path, ...)
		local space = self.space

		space:SetTexture (path or "Interface\\GLUES\\COMMON\\Glue-Tooltip-Background")
		local n = select('#', ...)
		if n == 4 or n == 8 then
			space:SetTexCoord(...)
		end
	end,

	["SetImageSize"] = function (self, width, height)
		self.frame:SetWidth(width)
		self.frame:SetHeight(height)
	end,
}


--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local frame = CreateFrame("Frame",nil,UIParent)

	local space = frame:CreateTexture(nil,"BACKGROUND")
	space:SetAllPoints(frame)
	space:SetTexture("Interface\\GLUES\\COMMON\\Glue-Tooltip-Background")
	space:SetBlendMode("ADD")

	local widget = {
		space   = space,
		frame   = frame,
		type    = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type,Constructor,Version)

