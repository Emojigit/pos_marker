local mod_storage = minetest.get_mod_storage()
local mark_priv = {interact=true}
local gmark_edit = {server=true}
local gmark_go = {interact=true}
local tp_priv = {teleport=true}
pos_marker = {}
local function tl(t)
	local c = 0
	for k,v in pairs(t) do
		c = c + 1
	end
	return c
end

pos_marker.set = function(user, name, pos)
	local markers = minetest.deserialize(mod_storage:get_string(tostring(user)))
	if markers == nil then
		markers = {}
	end
	markers[tostring(name)] = vector.round(pos)
	mod_storage:set_string(tostring(user), minetest.serialize(markers))
end

pos_marker.del = function(user, name)
	local markers = minetest.deserialize(mod_storage:get_string(tostring(user)))
	if markers == nil then
		markers = {}
	end
	markers[tostring(name)] = nil
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


subcommands.register_command_with_subcommand("marker",{
	description = "Control Markers",
	_sc_def = {
		set = {
			description = "Set a marker",
			privs = mark_priv,
			params = "<marker name>",
			func = function(name,param)
				local player = minetest.get_player_by_name(name)
				if not(player) then
					return false, "Not a player!"
				end
				local pos = player:get_pos()
				local markers = minetest.deserialize(mod_storage:get_string(tostring(name)))
				if markers and markers[param] then
					return false, "Can't set marker: Use `override` subcommand to override."
				end
				pos_marker.set(name,param,pos)
				return true, "Marker set!"
			end
		},
		override = {
			description = "Override a marker",
			privs = mark_priv,
			params = "<marker name>",
			func = function(name,param)
				local player = minetest.get_player_by_name(name)
				if not(player) then
					return false, "Not a player!"
				end
				local pos = player:get_pos()
				local markers = minetest.deserialize(mod_storage:get_string(tostring(name)))
				if not(markers and markers[param]) then
					return false, "Can't override marker: Use `set` subcommand to add a marker."
				end
				pos_marker.set(name,param,pos)
				return true, "Overrided!"
			end
		},
		delete = {
			description = "Delete a marker",
			privs = mark_priv,
			params = "<marker name>",
			func = function(name,param)
				local markers = minetest.deserialize(mod_storage:get_string(tostring(name)))
				if not(markers and markers[param]) then
					return false, "Can't delete marker: Marker not exist!"
				end
				pos_marker.del(name,param)
				return true, "Deleted!"
			end
		},
		list = {
			description = "List all markers",
			privs = mark_priv,
			params = "",
			func = function(name,param)
				local RSTR = "-".."- Marker List Start -".."-\n"
				local markers = minetest.deserialize(mod_storage:get_string(tostring("\\SERVER\\")))
				if not markers then
					return false, "No markers!"
				end
				for k,v in pairs(markers) do
					RSTR = RSTR .. k .. minetest.pos_to_string(mpos) .. "\n"
				end
				RSTR = RSTR .. "-".."- Marker List End, Total "..tostring(tl(markers)).." Markers -".."-"
				return true, RSTR
			end,
		},
		get = {
			description = "Get a marker's pos",
			privs = mark_priv,
			params = "<marker name>",
			func = function(name,param)
				local mpos = pos_marker.get(name,param)
				if mpos then
					return true, "The marker "..param.." is at "..minetest.pos_to_string(mpos)
				end
				return false, "No this marker!"
			end
		},
		tp = {
			description = "Teleport to a marker",
			params = "<marker name>",
			privs = tp_priv,
			func = function(name,param)
				local player = minetest.get_player_by_name(name)
				if not(player) then
					return false, "Not a player!"
				end
				local mpos = pos_marker.get(name,param)
				if mpos then
					player:set_pos(mpos)
					return true, "The marker "..param.." is at "..minetest.pos_to_string(mpos)
				end
				return false, "No this marker!"
			end
		},
	},
})


subcommands.register_command_with_subcommand("gmarker",{
	description = "Control Global Markers",
	_sc_def = {
		set = {
			description = "Set a marker",
			privs = gmark_edit,
			params = "<marker name>",
			func = function(name,param)
				local player = minetest.get_player_by_name(name)
				if not(player) then
					return false, "Not a player!"
				end
				local pos = player:get_pos()
				local markers = minetest.deserialize(mod_storage:get_string(tostring("\\SERVER\\")))
				if markers and markers[param] then
					return false, "Can't set marker: Use `override` subcommand to override."
				end
				pos_marker.set("\\SERVER\\",param,pos)
				return true, "Marker set!"
			end
		},
		override = {
			description = "Override a marker",
			privs = gmark_edit,
			params = "<marker name>",
			func = function(name,param)
				local player = minetest.get_player_by_name(name)
				if not(player) then
					return false, "Not a player!"
				end
				local pos = player:get_pos()
				local markers = minetest.deserialize(mod_storage:get_string(tostring("\\SERVER\\")))
				if not(markers and markers[param]) then
					return false, "Can't override marker: Use `set` subcommand to add a marker."
				end
				pos_marker.set("\\SERVER\\",param,pos)
				return true, "Overrided!"
			end
		},
		delete = {
			description = "Delete a marker",
			privs = gmark_edit,
			params = "<marker name>",
			func = function(name,param)
				local markers = minetest.deserialize(mod_storage:get_string(tostring(name)))
				if not(markers and markers[param]) then
					return false, "Can't override marker: Marker not exist!"
				end
				pos_marker.del("\\SERVER\\",param)
				return true, "Deleted!"
			end
		},
		list = {
			description = "List all markers",
			privs = mark_priv,
			params = "",
			func = function(name,param)
				local RSTR = "-".."- Marker List Start -".."-\n"
				local markers = minetest.deserialize(mod_storage:get_string(tostring("\\SERVER\\")))
				if not markers then
					return false, "No markers!"
				end
				for k,v in pairs(markers) do
					RSTR = RSTR .. k .. minetest.pos_to_string(mpos) .. "\n"
				end
				RSTR = RSTR .. "-".."- Marker List End, Total "..tostring(tl(markers)).." Markers -".."-"
				return true, RSTR
			end,
		},
		get = {
			description = "Get a marker's pos",
			privs = mark_priv,
			params = "<marker name>",
			func = function(name,param)
				local mpos = pos_marker.get("\\SERVER\\",param)
				if mpos then
					return true, "The marker "..param.." is at "..minetest.pos_to_string(mpos)
				end
				return false, "No this marker!"
			end
		},
		tp = {
			description = "Teleport to a marker",
			params = "<marker name>",
			privs = gmark_go,
			func = function(name,param)
				local player = minetest.get_player_by_name(name)
				if not(player) then
					return false, "Not a player!"
				end
				local mpos = pos_marker.get("\\SERVER\\",param)
				if mpos then
					player:set_pos(mpos)
					return true, "The marker "..param.." is at "..minetest.pos_to_string(mpos)
				end
				return false, "No this marker!"
			end
		},
	},
})

minetest.register_chatcommand("gmarks",minetest.registered_chatcommands.gmarker)
minetest.register_chatcommand("marks",minetest.registered_chatcommands.marker)
