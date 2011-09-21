function BetterUtils_removebyval(tab, val)
	for k,v in pairs(tab) do
		if v == val then
			table.remove(tab, k)
			return true
		end
	end
	return false
end
