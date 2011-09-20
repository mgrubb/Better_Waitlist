Better_Waitlist = LibStub('AceAddon-3.0'):NewAddon('Better_Waitlist',
													'AceComm-3.0',
													'AceEvent-3.0',
													'AceConsole-3.0',
													'AceTimer-3.0')

local addon = Better_Waitlist
local strsplit, tinsert = strsplit, tinsert

local options = {
	name = 'Better_Waitlist',
	handler = 'Better_Waitlist',
	type = 'group',
	args = {
	},
}

local defaults = {
	profile = {
		advertIntervals = {
			before = 120,
			during = 600,
		},
		advertStrings = {
			before = "The %s raid is is currently open, please whisper %s '%s' to be added to the waitlist.",
			during = "The %s raid is currently in progress, please whisper %s '%s'to be added to the award list.",
			full = "The %s raid is now full.  Thank you for your attendenance.",
		},
		advertChannel = 'guild',
		autoInvite = {
			enabled = 'onlypw',
			passwd = 'inviteme',
		},
		enabled = true,
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
	LibStub('AceConfig-3.0'):RegisterOptionsTable('Better_Waitlist',
	AceComm:RegisterComm('Better_WaitlistCOMM')
	-- Enable the whisper listener
	self:RegisterEvent('CHAT_MSG_WHISPER')
end

function addon:OnEnable()
	-- If we are in a raid and the wait list is active when enabled then assume
	-- that this is from a reload/dc and keep the current list.
	if not UnitInRaid('player') and not self.db.factionrealm.wlist.active then
		wipe(self.db.factionrealm.wlist)
	else
		self:StartWaitlist()
	end
end

function addon:OnDisable()
end

function addon:OnCommReceived()
end

function addon:StartWaitlist()
	if self:CheckIfActive then
		print("[BWL] Waitlist already started.")
		return
	end

	self.db.factionrealm.wlist.list
	self.db.factionrealm.wlist.active = true
end

function addon:CheckIfActive()
	return self.db.factionrealm.wlist.active
end

function addon:SendWhisper(recipient, msg, ...)
	SendChatMessage("[BWL] " .. format(msg, ...), 'WHISPER', nil, recipient)
end

function addon:PlayerInRaidOrList(player)
	if UnitInRaid(player) or self.db.factionrealm.wlist[player] then
		return true
	end
	return false
end

function addon:InsertPlayer(player)
end

function addon:AddToList(player, password, ...)
	local config = self.db.profile
	if self:PlayerInRaidOrList(player) then
		addon:SendWhisper(player, "You are already on the list or in the raid")
		return
	end

	if config.autoInvite.enabled then
		if config.autoInvite.enabled == 'true' or
			(config.autoInvite.enabled == 'onlypw' and config.autoInvite.passwd == password) then
			InviteUnit(player)
			return
		end
	end

	self.db.factionrealm.wlist.list:tinsert(player)
end

function addon:CHAT_MSG_WHISPER(event, msg, sender)
	if not self:CheckIfActive() then
		self:SendWhisper(sender, 'The waitlist is currently inactive.');
		return
	end

	local command, args = strsplit(" ", msg)
	if whisper_handlers[command] then
		local handler = addon[whisper_handlers[command]]
		handler(self, sender, strsplit(" ", args))
	end
end

-- vim:ts=4:sw=4:ai
