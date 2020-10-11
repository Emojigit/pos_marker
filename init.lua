local mod_storage = minetest.get_mod_storage()
local mark_priv = "interact"
local gmark_edit = "server"
local gmark_go = "interact"
local tp_priv = "teleport"
pos_marker = {}
-- minetest.registered_chatcommands
-- ObjectRef:set_pos(pos)

pos_marker.set = function(user, name, pos)
	local markers = minetest.deserialize(mod_storage:get_string(tostring(user)))
	if markers == nil then
		markers = {}
	end
	markers[tostring(name)] = vector.round(pos)
	mod_storage:set_string(tostring(user), minetest.serialize(markers))
end

pos_marker.get = function(user, name)
	local markers = minetest.deserialize(mod_storage:get_string(tostring(user)))
	if markers == nil then
		markers = {}
	end
	local pos = markers[tostring(name)]
	if pos then
		return pos
	else
		return false
	end
end

minetest.register_chatcommand("marker",{
	description = "Config Markers",
	params = "<get/set/tp> <marker name>",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not(player) then
			return false, "Not a player!"
		end
		local pos = player:getpos()
		local subcommand, markName = param:match('^(%S+)%s(.+)$')
		if param == "" or not(subcommand) or not(markName) then
			return false, "Invalid usage, see /help marker"
		end
		if subcommand == "set" then
			if minetest.check_player_privs(name, mark_priv) then
				local markers = minetest.deserialize(mod_storage:get_string(tostring(name)))
				if markers[markName] then
					return false, "Can't set marker: Use `override` subcommand to override."
				end
				pos_marker.set(name,markName,pos)
				return true, "Setted!"
			else
				return false, "No priv to do this!"
			end
		elseif subcommand == "override" then
			if minetest.check_player_privs(name, mark_priv) then
				local markers = minetest.deserialize(mod_storage:get_string(tostring(name)))
				if not(markers[markName]) then
					return false, "Can't override marker: Use `set` subcommand to add a marker."
				end
				pos_marker.set(name,markName,pos)
				return true, "Overrided!"
			else
				return false, "No priv to do this!"
			end
		elseif subcommand == "get" then
			if minetest.check_player_privs(name, mark_priv) then
				local mpos = pos_marker.get(name,markName)
				if mpos then
					return true, "The marker "..markName.." is at "..minetest.pos_to_string(mpos)
				end
				return false, "No this marker!"
			else
				return false, "No priv to do this!"
			end
		elseif subcommand == "tp" then
			if minetest.check_player_privs(name, tp_priv) then
				local mpos = pos_marker.get(name,markName)
				if mpos then
					player:set_pos(mpos)
					return true, "The marker "..markName.." is at "..minetest.pos_to_string(mpos)
				end
				return false, "No this marker!"
			end
		else
			return false, "Invalid subcommand, see /help marker"
		end
	end,
})
minetest.register_chatcommand("marks",minetest.registered_chatcommands.marker)

minetest.register_chatcommand("gmarker",{
	description = "Config Global Markers",
	params = "<get/set/tp> <marker name>",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not(player) then
			return false, "Not a player!"
		end
		local pos = player:getpos()
		local subcommand, markName = param:match('^(%S+)%s(.+)$')
		if param == "" or not(subcommand) or not(markName) then
			return false, "Invalid usage, see /help marker"
		end
		if subcommand == "set" then
			if minetest.check_player_privs(name, gmark_edit) then
				local markers = minetest.deserialize(mod_storage:get_string(tostring("\\SERVER\\")))
				if markers[markName] then
					return false, "Can't set marker: Use `override` subcommand to override."
				end
				pos_marker.set("\\SERVER\\",markName,pos)
				return true, "Setted!"
			else
				return false, "No priv to do this!"
			end
		elseif subcommand == "override" then
			if minetest.check_player_privs(name, mark_priv) then
				local markers = minetest.deserialize(mod_storage:get_string(tostring("\\SERVER\\")))
				if not(markers[markName]) then
					return false, "Can't override marker: Use `set` subcommand to add a marker."
				end
				pos_marker.set("\\SERVER\\",markName,pos)
				return true, "Overrided!"
			else
				return false, "No priv to do this!"
			end
		elseif subcommand == "get" then
			if minetest.check_player_privs(name, mark_priv) then
				local mpos = pos_marker.get("\\SERVER\\",markName)
				if mpos then
					return true, "The marker "..markName.." is at "..minetest.pos_to_string(mpos)
				end
				return false, "No this marker!"
			else
				return false, "No priv to do this!"
			end
		elseif subcommand == "tp" then
			if minetest.check_player_privs(name, gmark_go) then
				local mpos = pos_marker.get("\\SERVER\\",markName)
				if mpos then
					player:set_pos(mpos)
					return true, "The marker "..markName.." is at "..minetest.pos_to_string(mpos)
				end
				return false, "No this marker!"
			else
				return false, "No priv to do this!"
			end
		else
			return false, "Invalid subcommand, see /help marker"
		end
	end,
})

minetest.register_chatcommand("gmarks",minetest.registered_chatcommands.gmarker)


