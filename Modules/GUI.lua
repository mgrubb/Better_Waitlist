Better_Waitlist_GUI = Better_Waitlist:NewModule('Better_Waitlist_GUI',
												'AceEvent-3.0',
												'AceTimer-3.0',
												'AceGUI-3.0')
local module = Better_Waitlist_GUI
local addon = Better_Waitlist
local ScrollingTable = LibStub('ScrollingTable')
local AceGUI = LibStub('AceGUI-3.0')

local function cellUpdate(...) module:UpdateCell(...) end

local COLUMNS = {
	{
		name = 'Name',
		width = 50,
		align = 'LEFT',
		defaultsort = 'dsc',
		sortnext = 3,
		DoCellUpdate = cellUpdate,
	},
	{
		name = 'Class',
		width = 50,
		align = 'LEFT',
		defaultsort = 'dsc',
		DoCellUpdate = cellUpdate,
	},
	{
		name = 'Level',
		width = '20',
		align = 'RIGHT'
		defaultsort = 'dsc',
	},
	{
		name = 'Invite',
		width = '20',
		align = 'CENTER',
	},
}

function module:OnInitialize()
	self.list = select(3, addon:GetWaitlist())
	self:CreateGUI()
end

function module:CreateGUI()
	local f = AceGUI:Create('Frame')
	f:SetCallback('OnClose', function(widget) AceGUI:Release(widget) end)
	f:SetTitle('Waitlist')
	f:SetStatusText('Active: ' .. tostring(addon:IsActive()))
	f:SetLayout('Fill')
	self.frame = f
	self.dataview = ScrollingTable:CreateST(COLUMNS,nil,nil,nil,f)
	f:AddChild(self.dataview)

end
