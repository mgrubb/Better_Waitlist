Better_Waitlist = LibStub('AceAddon-3.0'):NewAddon('Better_Waitlist',
													'AceComm-3.0',
													'AceEvent-3.0',
													'AceConsole-3.0',
													'LibWho-2.0')

local addon = Better_Waitlist
local strsplit, tinsert, InviteUnit, GetChannelList = strsplit, tinsert, InviteUnit, GetChannelList
local UnitInRaid, GetRaidRosterInfo, SendChatMessage = UnitInRaid, GetRaidRosterInfo, SendChatMessage
local fmod, removebyval = math.fmod, BetterUtils_removebyval

local data_meta = {
	__index = function(t,i)
		for k,v in pairs(t) do
			if v.name == i then
				return v
			end
		end
		return nil
	end,
}

local function catenate_to_map(...)
	local t,k,v,n
	t = {}
	n = select('#', ...)
	assert(fmod(n,2) == 0)
	for i = 1, n, 2 do
		k,v = select(i, ...)
		t[tostring(k)] = v
	end
	return t
end

local function getChannelTable()
	return catenate_to_map('GUILD', 'Guild', GetChannelList())
end

local options = {
	name = 'Better_Waitlist',
	handler = Better_Waitlist,
	type = 'group',
	args = {
		sconfig = {
			type = 'execute',
			name = 'Standalone',
			desc = 'Open standalone config window',
			hidden = true,
			func = function() LibStub('AceConfigDialog-3.0'):Open('Better_Waitlist') end,
		},
		config = {
			name = 'Configuration',
			desc = 'Open the configuration window',
			type = 'execute',
			guiHidden = true,
			func = function() InterfaceOptionsFrame_OpenToCategory(addon.optionsFrame) end,
		},
		start = {
			name = 'Start',
			desc = 'Starts the waitlist',
			type = 'execute',
			guiHidden = true,
			disabled = 'IsActive',
			func = 'StartWaitlist'
		},
		stop = {
			name = 'Stop',
			desc = 'Stops the waitlist',
			type = 'execute',
			guiHidden = true,
			disabled = function() return not addon:IsActive() end,
			func = 'StopWaitlist',
		},
		delays = {
			name = 'Delay Settings',
			type = 'group',
			args = {
				open = {
					name = 'Open Delay',
					desc = 'Delay between messages advertising the start of the raid',
					type = 'input',
					get = function() return addon.db.profile.delays.open end,
					set = function(val) addon.db.profile.delays.open = val; return val end,
					pattern = '^%d+$',
					usage = 'Expects an integer value in seconds',
				},
				full = {
					name = 'Full Delay',
					desc = 'Delay between messages advertising the standby list, after the raid is full',
					type = 'input',
					get = function() return addon.db.profile.delays.full end,
					set = function(val) addon.db.profile.delays.full = val; return val end,
					pattern = '^%d+$',
					usage = 'Expects an integer value in seconds',
				},
			},
		},
		messages = {
			type = 'group',
			name = 'Message Settings',
			args = {
				open = {
					name = 'Open Message',
					desc = 'Message displayed while the list is open but the raid is not full',
					type = 'input',
					get = function() return addon.db.profile.messages.open end,
					set = function(val) addon.db.profile.messages.open = val; return val end,
				},
				full = {
						name = 'Full Message',
						desc = 'Message displayed while the raid is full',
						type = 'input',
						get = function() return addon.db.profile.messages.full end,
						set = function(val) addon.db.profile.messages.full = val; return val end,
				},
				filled = {
						name = 'Filled Message',
						desc = 'Message displayed when the raid has become filled.',
						type = 'input',
						get = function() return addon.db.profile.messages.filled end,
						set = function(val) addon.db.profile.messages.filled = val; return val end,
				},
			},
		},
		channel = {
			name = 'Channel',
			desc = 'Channel where messages are sent',
			type = 'select',
			values = function() return getChannelTable() end,
			get = function() return addon.db.profile.channel end,
			set = function(val) addon.db.profile.channel = val; return val end,
		},
		autoinvite = {
			type = 'group',
			name = 'Auto-Invitation Settings',
			args = {
				mode = {
					name = 'Auto Invite',
					desc = 'Setting to control if automatic raid invites should be given',
					type = 'select',
					values = { always = 'Always', onlypw = 'With Password', never = 'Never' },
					get = function() return addon.db.profile.autoInvite.mode end,
					set = function(val) addon.db.profile.autoInvite.mode = val; return val end,
				},
				password = {
					name = 'Password',
					desc = 'Password needed to give out auto-invitation',
					type = 'input',
					get = function() return addon.db.profile.autoInvite.password end,
					set = function(val) addon.db.profile.autoInvite.password = val; return val end,
				},
			},
		},
		enabled = {
			type = 'toggle',
			name = 'Enabled',
			desc = 'Addon Enabled',
			get = 'IsEnabled',
			set = 'Disable',
		},
	},
}

local defaults = {
	profile = {
		enabled = true,
		delays = {
			open = 120,
			full = 600,
		},
		messages = {
			open = "The %s raid is is currently open, please whisper %s '%s' to be added to the waitlist.",
			full = "The %s raid is currently in progress, please whisper %s '%s'to be added to the award list.",
			filled = "The %s raid is now full.  Thank you for your attendenance.",
		},
		channel = 'GUILD',
		autoInvite = {
			mode = 'onlypw',
			password = 'inviteme',
		},
	},
	factionrealm = {
		wlist = {
			active = false,
			list = {},
			queue = {},
		},
	},
}

local whisper_handlers = {
	invite = 'AddToList',
	add = 'AddToList',
	remove = 'RemoveFromList',
}


function addon:OnInitialize()
	self.db = LibStub('AceDB-3.0'):New('Better_WaitlistDB', defaults, true)
	options.args.profile = LibStub('AceDBOptions-3.0'):GetOptionsTable(self.db)
	LibStub('AceConfig-3.0'):RegisterOptionsTable('Better_Waitlist', options, {'betterwl', 'bwl'})
	self.optionsFrame = LibStub('AceConfigDialog-3.0'):AddToBlizOptions('Better_Waitlist', 'Better_Waitlist')
	setmetatable(self.db.factionrealm.wlist.list, data_meta)
	-- Register events
	self:RegisterComm('BetterWaitlist')
	self:RegisterEvent('CHAT_MSG_WHISPER')
	self:RegisterEvent('RAID_ROSTER_UPDATE')
	self:RegisterMessage('PLAYER_ADDED_TO_WAITLIST')
end

function addon:OnEnable()
	-- If we are in a raid and the wait list is active when enabled then assume
	-- that this is from a reload/dc and keep the current list.
	if not UnitInRaid('player') and not self:IsActive() then
		wipe(self.db.factionrealm.wlist.list)
		wipe(self.db.factionrealm.wlist.queue)
		setmetatable(self.db.factionrealm.wlist.list, data_meta)
	else
		self:StartWaitlist()
	end
end

function addon:OnDisable()
end

function addon:OnCommReceived()
end

function addon:SetActive(val)
	self.db.factionrealm.wlist.active = val
	return val
end

function addon:StartWaitlist()
	if self:IsActive() then
		print("[BWL] Waitlist already started.")
		return nil
	end
	self:SetActive(true)
	local config = self.db.profile
end

function addon:StopWaitlist()
	self:SetActive(false)
	wipe(self.db.factionrealm.wlist.list)
	wipe(self.db.factionrealm.wlist.queue)
	print("[BWL] Waitlist has been stopped")
end

function addon:IsActive()
	return self.db.factionrealm.wlist.active
end

function addon:SendWhisper(recipient, msg, ...)
	SendChatMessage("[BWL] " .. format(msg, ...), 'WHISPER', nil, recipient)
end

function addon:PlayerInRaidOrList(player)
	local queue, list = self:GetWaitlist()
	if UnitInRaid(player) or list[player] or queue[player] then
		return true
	end
	return false
end

function addon:GetWaitlist()
	return self.db.factionrealm.wlist, self.db.factionrealm.wlist.queue, self.db.factionrealm.wlist.list
end

function addon:UserInfoAvailable(data, time)
	if not self:IsActive() then
		return nil
	end
	local _, queue = self:GetWaitlist()
	for n,_ in pairs(queue) do
		if data and (data.Name == n) then
			queue[n] = nil
			self:AddPlayerToWaitlist(n, data)
		end
	end
end

function addon:AddPlayerToWaitlist(player, data)
	local wlist, queue, list = self:GetWaitlist()
	if not data then return nil end
	if queue[player] then
		queue[player] = nil
	end

	if not data.Name then
		data.Name = player
	end

	if self:PlayerInRaidOrList(player) then
		return nil
	end

	local ldata = {
		name = data.Name,
		cols = {
			{
				value = data.Name,
				color = RAID_CLASS_COLORS[data.NoLocaleClass]
			}, -- name column
			{
				value = data.Class,
				color = RAID_CLASS_COLORS[data.NoLocaleClass]
			}, -- class column
			{
				value = data.Level
			}, -- level column
		},
	}
	tinsert(list, ldata)
	self:SendMessage('PLAYER_ADDED_TO_WAITLIST', player, ldata)
	return true
end

function addon:PLAYER_ADDED_TO_WAITLIST(player, data)
	self:SendWhisper(player, 'You have been added to the waitlist.')
end

function addon:AddToList(player, password, ...)
	if not self:IsActive() then
		self:SendWhisper(sender, 'The waitlist is currently inactive.');
		return nil
	end
	local config = self.db.profile
	if self:PlayerInRaidOrList(player) then
		addon:SendWhisper(player, "You are already on the list or in the raid")
		return nil
	end

	if config.autoInvite.mode then
		if config.autoInvite.mode == 'enabled' or
			(config.autoInvite.mode == 'onlypw' and config.autoInvite.password == password) then
			InviteUnit(player)
			return nil
		end
	end

	local data = self:UserInfo(player, {timeout = 20, callback = 'UserInfoAvailable', handler = self})
	if data then
		self:AddPlayerToWaitlist(player, data)
	end
end

function addon:RAID_ROSTER_UPDATE()
	if not self:IsActive() then
		return nil
	end

	local _, queue, list = self:GetWaitlist()

	for i=1,40 do
		local name = GetRaidRosterInfo(i)
		queue[name] = nil
		list[name] = nil
	end
end

function addon:CHAT_MSG_WHISPER(event, msg, sender)
	if not self:IsActive() then
		return nil
	end

	local command, args = strsplit(" ", msg)
	if whisper_handlers[command] then
		local handler = addon[whisper_handlers[command]]
		handler(self, sender, strsplit(" ", args))
	end
end

-- vim:ts=4:sw=4:ai
