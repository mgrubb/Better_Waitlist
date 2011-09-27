local addon = select(2, ...);
local ScrollingTable = LibStub('ScrollingTable');
local AceGUI = LibStub('AceGUI-3.0');

local COLUMNS = {
	{
		name = 'Name',
		width = 50,
		align = 'LEFT',
		defaultsort = 'dsc',
		sortnext = 3,
	},
	{
		name = 'Class',
		width = 50,
		align = 'LEFT',
		defaultsort = 'dsc',
	},
	{
		name = 'Role',
		width = 50,
		align = 'LEFT',
		defaultsort = 'dsc',
	{
		name = 'Level',
		width = '20',
		align = 'RIGHT',
		defaultsort = 'dsc',
	},
	{
		name = 'Invite',
		width = '20',
		align = 'CENTER',
	},
};

function addon:CreateGUI()
	local f = AceGUI:Create('Frame');
	f:SetCallback('OnClose', function(widget) AceGUI:Release(widget) end);
	f:SetTitle('Waitlist');
	f:SetStatusText('Active: ' .. tostring(addon:IsActive()));
	f:SetLayout('Fill');
	self.frame = f;
	self.dataview = AceGUI:Create('lib-st');
	self.dataview:CreateST(COLUMNS,nil,nil,nil);
	f:AddChild(self.dataview);

	--[[ section overall control ]]--
	--[[
		Button to open config
		Raid Size Slider
		Start Button
		Stop Button
		Invite All Button
		Invite Selected Button
	--]]


end

function addon:AddSampleData()
	local data = {
		{
			cols = {
				{
					value = 'Kelebros',
					color = RAID_CLASS_COLORS['DRUID'],
				},
				{
					value = 'Druid',
					color = RAID_CLASS_COLORS['DRUID'],
				},
				{
					value = "85",
				},
			},
		},
		{
			cols = {
				{
					value = 'Humbaba',
					color = RAID_CLASS_COLORS['WARLOCK'],
				},
				{
					value = 'Warlock',
					color = RAID_CLASS_COLORS['WARLOCK'],
				},
				{
					value = '85',
				},
			},
		},
	};

	self.dataview.st:SetData(data);
end

