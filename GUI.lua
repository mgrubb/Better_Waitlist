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
	},
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
	f:SetLayout('Flow');
	f:SetStatusTable({width=900, height=550});
	f:PauseLayout();

	--[[ section overall control ]]--
	local rhs_width = 0.20;
	local sg = AceGUI:Create('SimpleGroup');
	sg:SetLayout('Flow');
	sg:SetRelativeWidth(rhs_width);
	sg.alignoffset = 25
	sg:PauseLayout();

	local h = AceGUI:Create('Heading');
	h:SetFullWidth(true);
	h:SetText('Main');
	sg:AddChild(h);

	h = AceGUI:Create('Spacer');
	h:SetFullWidth(true);
	h:SetHeight(10);
	sg:AddChild(h);

	--[[ Button to open config ]]--
	local btn = AceGUI:Create('Button');
	btn:SetText('Config');
	btn:SetFullWidth(true);
	btn:SetCallback('OnClick', function() addon:OpenConfigWindow() end);
	sg:AddChild(btn);

	--[[ Button to start waitlist ]]--
	btn = AceGUI:Create('Button');
	btn:SetText('Start');
	btn:SetFullWidth(true);
	btn:SetCallback('OnClick', function() addon:StartWaitlist() end);
	btn:SetDisabled(addon:IsActive());
	sg:AddChild(btn);

	--[[ Button to stop waitlist ]]--
	btn = AceGUI:Create('Button');
	btn:SetText('Stop');
	btn:SetFullWidth(true);
	btn:SetCallback('OnClick', function() addon:StopWaitlist() end);
	btn:SetDisabled(not addon:IsActive());
	sg:AddChild(btn);

	--[[ Button to Invite all in list ]]--
	btn = AceGUI:Create('Button');
	btn:SetText('Invite All');
	btn:SetFullWidth(true);
	btn:SetCallback('OnClick', function() addon:InviteAll() end);
	btn:SetDisabled(true);
	sg:AddChild(btn);

	--[[ Button to Invite selected in list ]]--
	btn = AceGUI:Create('Button');
	btn:SetText('Invite Selected');
	btn:SetFullWidth(true);
	btn:SetCallback('OnClick', function() addon:InviteSelected() end);
	btn:SetDisabled(true);
	sg:AddChild(btn);

	--[[ Slider to set raid size ]]--
	local slider = AceGUI:Create('Slider');
	slider:SetLabel('Raid Size');
	slider:SetFullWidth(true);
	slider:SetSliderValues(10, 40, 5);
	slider:SetValue(10);
	sg:AddChild(slider);
	sg:ResumeLayout();
	f:AddChild(sg);

	--[[ Data view section ]]--
	local sg = AceGUI:Create('SimpleGroup');
	sg:SetLayout('Fill');
	sg:SetRelativeWidth(0.99 - rhs_width);
	sg:SetFullHeight(true);
	sg.alignoffset = 25;

	local dataview = AceGUI:Create('lib-st');
	dataview:CreateST(COLUMNS,12,15);
	-- sg:SetHeight(dataview.st.displayRows * dataview.st.rowHeight * 2);
	-- sg:AddChild(dataview);
	-- f:AddChild(sg);
	sg:AddChild(dataview);
	f:AddChild(sg);


	f:ResumeLayout();
	f:DoLayout();
	f:ApplyStatus();
	print(slider.frame:GetWidth());
	self.dataview = dataview;
	self.frame = f;

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

