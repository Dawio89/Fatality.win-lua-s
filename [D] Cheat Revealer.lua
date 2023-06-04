--disclaimer, I do not guarantee for this to work perfectly, as I just quickly pasted just so that it works('ish lol)
--get the icons yourself

local function requireJSON()
    local json = {}

	local function kind_of(obj)
		if type(obj) ~= 'table' then return type(obj) end
		local i = 1
		for _ in pairs(obj) do
		  if obj[i] ~= nil then i = i + 1 else return 'table' end
		end
		if i == 1 then return 'table' else return 'array' end
	  end
	  
	  local function escape_str(s)
		local in_char  = {'\\', '"', '/', '\b', '\f', '\n', '\r', '\t'}
		local out_char = {'\\', '"', '/',  'b',  'f',  'n',  'r',  't'}
		for i, c in ipairs(in_char) do
		  s = s:gsub(c, '\\' .. out_char[i])
		end
		return s
	  end
	  
	  local function skip_delim(str, pos, delim, err_if_missing)
		pos = pos + #str:match('^%s*', pos)
		if str:sub(pos, pos) ~= delim then
		  if err_if_missing then
			error('Expected ' .. delim .. ' near position ' .. pos)
		  end
		  return pos, false
		end
		return pos + 1, true
	  end
	  
	  local function parse_str_val(str, pos, val)
		val = val or ''
		local early_end_error = 'End of input found while parsing string.'
		if pos > #str then error(early_end_error) end
		local c = str:sub(pos, pos)
		if c == '"'  then return val, pos + 1 end
		if c ~= '\\' then return parse_str_val(str, pos + 1, val .. c) end
		local esc_map = {b = '\b', f = '\f', n = '\n', r = '\r', t = '\t'}
		local nextc = str:sub(pos + 1, pos + 1)
		if not nextc then error(early_end_error) end
		return parse_str_val(str, pos + 2, val .. (esc_map[nextc] or nextc))
	  end
	  
	  local function parse_num_val(str, pos)
		local num_str = str:match('^-?%d+%.?%d*[eE]?[+-]?%d*', pos)
		local val = tonumber(num_str)
		if not val then error('Error parsing number at position ' .. pos .. '.') end
		return val, pos + #num_str
	  end
	  
	  function json.stringify(obj, as_key)
		local s = {}
		local kind = kind_of(obj)
		if kind == 'array' then
		  if as_key then error('Can\'t encode array as key.') end
		  s[#s + 1] = '['
		  for i, val in ipairs(obj) do
			if i > 1 then s[#s + 1] = ', ' end
			s[#s + 1] = json.stringify(val)
		  end
		  s[#s + 1] = ']'
		elseif kind == 'table' then
		  if as_key then error('Can\'t encode table as key.') end
		  s[#s + 1] = '{'
		  for k, v in pairs(obj) do
			if #s > 1 then s[#s + 1] = ', ' end
			s[#s + 1] = json.stringify(k, true)
			s[#s + 1] = ':'
			s[#s + 1] = json.stringify(v)
		  end
		  s[#s + 1] = '}'
		elseif kind == 'string' then
		  return '"' .. escape_str(obj) .. '"'
		elseif kind == 'number' then
		  if as_key then return '"' .. tostring(obj) .. '"' end
		  return tostring(obj)
		elseif kind == 'boolean' then
		  return tostring(obj)
		elseif kind == 'nil' then
		  return 'null'
		else
		  error('Unjsonifiable type: ' .. kind .. '.')
		end
		return table.concat(s)
	  end
	  
	  json.null = {}
	  
	  function json.parse(str, pos, end_delim)
		pos = pos or 1
		if pos > #str then error('Reached unexpected end of input.') end
		local pos = pos + #str:match('^%s*', pos)
		local first = str:sub(pos, pos)
		if first == '{' then
		  local obj, key, delim_found = {}, true, true
		  pos = pos + 1
		  while true do
			key, pos = json.parse(str, pos, '}')
			if key == nil then return obj, pos end
			if not delim_found then error('Comma missing between object items.') end
			pos = skip_delim(str, pos, ':', true)
			obj[key], pos = json.parse(str, pos)
			pos, delim_found = skip_delim(str, pos, ',')
		  end
		elseif first == '[' then
		  local arr, val, delim_found = {}, true, true
		  pos = pos + 1
		  while true do
			val, pos = json.parse(str, pos, ']')
			if val == nil then return arr, pos end
			if not delim_found then error('Comma missing between array items.') end
			arr[#arr + 1] = val
			pos, delim_found = skip_delim(str, pos, ',')
		  end
		elseif first == '"' then
		  return parse_str_val(str, pos + 1)
		elseif first == '-' or first:match('%d') then
		  return parse_num_val(str, pos)
		elseif first == end_delim then
		  return nil, pos + 1
		else
		  local literals = {['true'] = true, ['false'] = false, ['null'] = json.null}
		  for lit_str, lit_val in pairs(literals) do
			local lit_end = pos + #lit_str - 1
			if str:sub(pos, lit_end) == lit_str then return lit_val, lit_end + 1 end
		  end
		  local pos_info_str = 'position ' .. pos .. ': ' .. str:sub(pos, pos + 10)
		  error('Invalid json syntax starting at ' .. pos_info_str)
		end
	  end
	  
	  return json;
end
local images_path = "file://{images}/icons/revealer/multicolored/%s.png"
local json = requireJSON();
local panorama = require('panorama')
local js = panorama.loadstring([[
// @ the guy trying to see what panorama i got (again?), chill bruh
let entity_panels = {}
let entity_data = {}
let event_callbacks = {}
	let SLOT_LAYOUT = `
		<root>
			<Panel style="min-width: 3px; padding-top: 2px; padding-left: 0px;" scaling='stretch-to-fit-y-preserve-aspect'>
				<Image id="smaller" textureheight="15" style="horizontal-align: center; opacity: 0.01; transition: opacity 0.1s ease-in-out 0.0s, img-shadow 0.12s ease-in-out 0.0s; overflow: noclip; padding: 3px 5px; margin: -3px -5px;"	/>
				<Image id="small" textureheight="17" style="horizontal-align: center; opacity: 0.01; transition: opacity 0.1s ease-in-out 0.0s, img-shadow 0.12s ease-in-out 0.0s; overflow: noclip; padding: 3px 5px; margin: -3px -5px;" />
				<Image id="image" textureheight="21" style="opacity: 0.01; transition: opacity 0.1s ease-in-out 0.0s, img-shadow 0.12s ease-in-out 0.0s; padding: 3px 5px; margin: -3px -5px; margin-top: -5px;" />
			</Panel>
		</root>
	`
	let _DestroyEntityPanel = function (key) {
		let panel = entity_panels[key]
		if(panel != null && panel.IsValid()) {
			var parent = panel.GetParent()
			let musor = parent.GetChild(0)
			musor.visible = true
			if(parent.FindChildTraverse("id-sb-skillgroup-image") != null) {
				parent.FindChildTraverse("id-sb-skillgroup-image").style.margin = "0px 0px 0px 0px"
			}
			panel.DeleteAsync(0.0)
		}
		delete entity_panels[key]
	}
	let _DestroyEntityPanels = function() {
		for(key in entity_panels){
			_DestroyEntityPanel(key)
		}
	}
	let _GetOrCreateCustomPanel = function(xuid) {
		if(entity_panels[xuid] == null || !entity_panels[xuid].IsValid()){
			entity_panels[xuid] = null
			let scoreboard_context_panel = $.GetContextPanel().FindChildTraverse("ScoreboardContainer").FindChildTraverse("Scoreboard") || $.GetContextPanel().FindChildTraverse("id-eom-scoreboard-container").FindChildTraverse("Scoreboard")
			if(scoreboard_context_panel == null){
				_Clear()
				_DestroyEntityPanels()
				return
			}
			scoreboard_context_panel.FindChildrenWithClassTraverse("sb-row").forEach(function(el){
				let scoreboard_el
				if(el.m_xuid == xuid) {
					el.Children().forEach(function(child_frame){
						let stat = child_frame.GetAttributeString("data-stat", "")
						if(stat == "rank")
							scoreboard_el = child_frame.GetChild(0)
					})
					if(scoreboard_el) {
						let scoreboard_el_parent = scoreboard_el.GetParent()
						let custom_icons = $.CreatePanel("Panel", scoreboard_el_parent, "revealer-icon", {
						})
						if(scoreboard_el_parent.FindChildTraverse("id-sb-skillgroup-image") != null) {
							scoreboard_el_parent.FindChildTraverse("id-sb-skillgroup-image").style.margin = "0px 0px 0px 0px"
						}
						scoreboard_el_parent.MoveChildAfter(custom_icons, scoreboard_el_parent.GetChild(1))
						let prev_panel = scoreboard_el_parent.GetChild(0)
						prev_panel.visible = false
						let panel_slot_parent = $.CreatePanel("Panel", custom_icons, `icon`)
						panel_slot_parent.visible = false
						panel_slot_parent.BLoadLayoutFromString(SLOT_LAYOUT, false, false)
						entity_panels[xuid] = custom_icons
						return custom_icons
					}
				}
			})
		}
		return entity_panels[xuid]
	}
	let _UpdatePlayer = function(entindex, path_to_image) {
		if(entindex == null || entindex == 0)
			return
		entity_data[entindex] = {
			applied: false,
			image_path: path_to_image
		}
	}
	let _ApplyPlayer = function(entindex) {
		let xuid = GameStateAPI.GetPlayerXuidStringFromEntIndex(entindex)
		let panel = _GetOrCreateCustomPanel(xuid)
		if(panel == null)
			return
		let panel_slot_parent = panel.FindChild(`icon`)
		panel_slot_parent.visible = true
		let panel_slot = panel_slot_parent.FindChild("image")
		panel_slot.visible = true
		panel_slot.style.opacity = "1"
		panel_slot.SetImage(entity_data[entindex].image_path)
		return true
	}
	let _ApplyData = function() {
		for(entindex in entity_data) {
			entindex = parseInt(entindex)
			let xuid = GameStateAPI.GetPlayerXuidStringFromEntIndex(entindex)
			if(!entity_data[entindex].applied || entity_panels[xuid] == null || !entity_panels[xuid].IsValid()) {
				if(_ApplyPlayer(entindex)) {
					entity_data[entindex].applied = true
				}
			}
		}
	}
	let _Create = function() {
		event_callbacks["OnOpenScoreboard"] = $.RegisterForUnhandledEvent("OnOpenScoreboard", _ApplyData)
		event_callbacks["Scoreboard_UpdateEverything"] = $.RegisterForUnhandledEvent("Scoreboard_UpdateEverything", function(){
			_ApplyData()
		})
		event_callbacks["Scoreboard_UpdateJob"] = $.RegisterForUnhandledEvent("Scoreboard_UpdateJob", _ApplyData)
	}
	let _Clear = function() { entity_data = {} }
	let _Destroy = function() {
		// clear entity data
		_Clear()
		_DestroyEntityPanels()
		for(event in event_callbacks){
			$.UnregisterForUnhandledEvent(event, event_callbacks[event])
			delete event_callbacks[event]
		}
	}
	return {
		create: _Create,
		destroy: _Destroy,
		clear: _Clear,
		update: _UpdatePlayer,
		destroy_panel: _DestroyEntityPanels
	}
]], "CSGOHud")()

js.create()

local main_data_table

local function get_players()
    local players = {}
    local local_player = engine.get_local_player()
    local max_players = info.server.max_players

    entities.for_each_player(function(player)
        if player:get_prop("m_bConnected") == 0 then
            if main_data_table.users[player:get_index()] then
                main_data_table.users[player:get_index()] = nil
            end
        else
            local flags = player:get_prop("m_fFlags", player:get_index())
            if flags and bit.band(flags, 512) ~= 512 then
                players[#players + 1] = player:get_index()
            end
        end
    end)

    return players
end

local c = {safe_call = function(self, d, ...)
        local e, f = pcall(d, ...)
        if not e then
            print(("~ Error: %s"):format(f))
            return nil
        end
        return f
    end, find_duplicate_element = function(self, g, h)
        local i = {}
        for j = 1, #g do
            local k = g[j]
            if not i[k] then
                i[k] = true
                for l = j + 4, #g do
                    if j % h == 0 then
                        if g[l] == k then
                            return true
                        end
                    elseif g[l] == k then
                        return false
                    end
                end
            end
        end
        return false
    end, HIWORD = function(self, m)
        local n = bit.lshift(0xFFFF, 16)
        local o = bit.rshift(bit.band(m, n), 16)
        return o
    end}
local p = {{}}
local q = {
    cheat_fatality = "ft",
    cheat_nixware = "nw",
    cheat_neverlose = "nl1",
    cheat_gamesense = "gs",
    cheat_evolve = "ev",
    cheat_onetap = "ot",
    cheat_pandora = "pd",
    cheat_plague = "pl",
    cheat_rifk = "r7",
    cheat_airflow = "af"
}
local r = {
    [q.cheat_fatality] = "Fatality",
    [q.cheat_nixware] = "Nixware",
    [q.cheat_neverlose] = "Neverlose",
    [q.cheat_gamesense] = "Gamesense",
    [q.cheat_evolve] = "Evolve",
    [q.cheat_onetap] = "Onetap",
    [q.cheat_pandora] = "Pandora",
    [q.cheat_plague] = "Plague",
    [q.cheat_rifk] = "Rifk",
    [q.cheat_airflow] = "Airflow"
}
local s = {
    nl = {sig_count = {}, found = {}},
    nw = {},
    pd = {},
    ot = {},
    ft = {},
    pl = {},
    ev = {},
    r7 = {},
    af = {},
    gs = {}
}
local t = {
    [q.cheat_neverlose] = function(u, v)
        if u.xuid_high == 0 then
            return
        end
        local w = ("%.02X"):format(ffi.cast("uint16_t*", ffi.cast("uintptr_t", u) + 22)[0])
        if w == s.current_signature then
            s.nl.sig_count[v] = (s.nl.sig_count[v] or 0) + 1
            if s.nl.sig_count[v] > 24 then
                s.nl.found[v] = 1
                return true
            else
                s.nl.sig_count[v] = nil
            end
        end
        if #s.nl.found > 3 then
            return false
        end
        if not s.nl[v] then
            s.nl[v] = {}
        end
        s.nl[v][#s.nl[v] + 1] = u.xuid_high
        if #s.nl[v] > 24 then
            if c:find_duplicate_element(s.nl[v], 4) and u.xuid_high ~= 0 then
                s.current_signature = w
                s.nl[v] = {}
                return true
            end
            table.remove(s.nl[v], 1)
        end
        return false
    end,
    [q.cheat_nixware] = function(u, v)
        if not s.nw[v] then
            s.nw[v] = 0
        end
        if s.nw[v] > 34 then
            s.nw[v] = nil
            return true
        elseif u.xuid_high == 0 then
            s.nw[v] = s.nw[v] + 1
        else
            s.nw[v] = 0
        end
        return false
    end,
    [q.cheat_pandora] = function(u, v)
        if not s.pd[v] then
            s.pd[v] = 0
        end
        local w = ("%.02X"):format(ffi.cast("uint16_t*", ffi.cast("uintptr_t", u) + 16)[0])
        if s.pd[v] > 24 then
            return true
        elseif w == "695B" or w == "1B39" then
            s.pd[v] = s.pd[v] + 1
        else
            s.pd[v] = 0
        end
        return false
    end,
    [q.cheat_onetap] = function(u, v)
        if not s.ot[v] then
            s.ot[v] = {}
        end
        s.ot[v][#s.ot[v] + 1] = {
            sequence_bytes = u.sequence_bytes,
            xuid_low = u.xuid_low,
            section_number = u.section_number,
            umcompressed_sample_offset = u.uncompressed_sample_offset
        }
        if #s.ot[v] > 16 then
            local x = s.ot[v][1]
            for y = 2, #s.ot[v] do
                local z = s.ot[v][y]
                if
                    z.xuid_low ~= x.xuid_low or z.section_number ~= x.section_number or
                        z.uncompressed_sample_offset ~= x.uncompressed_sample_offset
                 then
                    table.remove(s.ot[v], 1)
                    return false
                end
            end
            table.remove(s.ot[v], 1)
            return true
        end
        return false
    end,
    [q.cheat_fatality] = function(u, v)
        if not s.ft[v] then
            s.ft[v] = 0
        end
        local w = ("%.02X"):format(ffi.cast("uint16_t*", ffi.cast("uintptr_t", u) + 16)[0])
        if s.ft[v] > 36 then
            return true
        elseif w == "7FFA" or w == "7FFB" then
            s.ft[v] = s.ft[v] + 1
        end
        return false
    end,
    [q.cheat_plague] = function(u, v)
        if not s.pl[v] then
            s.pl[v] = 0
        end
        if s.pl[v] > 24 then
            return true
        elseif ("%.02X"):format(ffi.cast("uint16_t*", ffi.cast("uintptr_t", u) + 44)[0]) == "7275" then
            s.pl[v] = s.pl[v] + 1
        else
            s.pl[v] = 0
        end
        return false
    end,
    [q.cheat_evolve] = function(u, v)
        if not s.ev[v] then
            s.ev[v] = {}
        end
        s.ev[v][#s.ev[v] + 1] = u.xuid_high
        if #s.ev[v] > 44 then
            for y = 1, #s.ev[v] - 4 do
                local A = s.ev[v][y]
                if s.ev[v][y + 1] + s.ev[v][y + 2] == s.ev[v][y] * 2 and s.ev[v][y + 4] == A + 1 then
                    s.ev[v] = {}
                    return true
                end
            end
            table.remove(s.ev[v], 1)
        end
        return false
    end,
    [q.cheat_rifk] = function(u, v)
        if not s.r7[v] then
            s.r7[v] = 0
        end
        local w = ("%.02X"):format(ffi.cast("uint16_t*", ffi.cast("uintptr_t", u) + 16)[0])
        if s.r7[v] > 24 then
            return true
        elseif w == "234" or w == "134" then
            s.r7[v] = s.r7[v] + 1
        else
            s.r7[v] = 0
        end
        return false
    end,
    [q.cheat_airflow] = function(u, v)
        if not s.af[v] then
            s.af[v] = 0
        end
        if s.af[v] > 24 then
            return true
        elseif ("%.02X"):format(ffi.cast("uint16_t*", ffi.cast("uintptr_t", u) + 16)[0]) == "AFF1" then
            s.af[v] = s.af[v] + 1
        else
            s.af[v] = 0
        end
        return false
    end,
    [q.cheat_gamesense] = function(u, v)
        local w = ("%.02X"):format(ffi.cast("uint16_t*", ffi.cast("uintptr_t", u) + 22)[0])
        local B = string.sub(u.sequence_bytes, 1, 4)
        if not s.gs[v] then
            s.gs[v] = {repeated = 0, packet = w, bytes = B}
        end
        if B ~= s.gs[v].bytes and w ~= s.gs[v].packet then
            s.gs[v].packet = w
            s.gs[v].bytes = B
            s.gs[v].repeated = s.gs[v].repeated + 1
        else
            s.gs[v].repeated = 0
        end
        if s.gs[v].repeated >= 36 then
            s.gs[v] = {repeated = 0, packet = w, bytes = B}
            return true
        end
        return false
    end
}
local C = {users = {}}
local D = {
    icons = {},
    voice_data_t = ffi.typeof [[
        struct {
            char     pad_0000[8];
            int32_t  client;
            int32_t  audible_mask;
            uint32_t xuid_low;
            uint32_t xuid_high;
            void*    voice_data;
            bool     proximity;
            bool     caster;
            char     pad_001E[2];
            int32_t  format;
            int32_t  sequence_bytes;
            uint32_t section_number;
            uint32_t uncompressed_sample_offset;
            char     pad_0030[4];
            uint32_t has_bits;
        }*
    ]],
    init = function(self)
        self.icons[q.cheat_fatality] = render.create_texture("fatality/ft.jpg")
        self.icons[q.cheat_neverlose] = render.create_texture("fatality/nl1.jpg")
        self.icons[q.cheat_nixware] = render.create_texture("fatality/nw.jpg")
        self.icons[q.cheat_gamesense] = render.create_texture("fatality/gs.jpg")
        self.icons[q.cheat_evolve] = render.create_texture("fatality/ev.jpg")
        self.icons[q.cheat_onetap] = render.create_texture("fatality/ot.jpg")
        self.icons[q.cheat_pandora] = render.create_texture("fatality/pd.jpg")
        self.icons[q.cheat_plague] = render.create_texture("fatality/pl.jpg")
        self.icons[q.cheat_rifk] = render.create_texture("fatality/r7.jpg")
        self.icons[q.cheat_airflow] = render.create_texture("fatality/af.jpg")
    end,
    on_level_init = function(self)
        C.users = {}
    end,
    
    on_paint = function(self)
        if not engine.is_in_game() then
            return
        end
        entities.for_each_player(
            function(F)
                if not F or not F:is_alive() then
                    return
                end
                local G = F:get_index()
                local H = C.users[G]
                if not H then
                    return
                end
                local I, J, K, L = F:get_bbox()
                if not I or not J or not K or not L then
                    return
                end
                    local M, N = I + (K - I) / 2, J - 30
                    I = M - 10
                    K = M + 10
                    J = N - 10
                    L = N + 10
                local O = F:get_esp_alpha()
                local P = C.users[G].cheat
                if I and J and self.icons[P] ~= nil then
                    js.update(G, images_path:format(P and P or G == engine.get_local_player() and "ft" or "wh"))
                end
            end
        )
    end,
    on_voice_data = function(self, Q)
        local u = ffi.cast(self.voice_data_t, Q)
        local v = u.client + 1
        if not C.users[v] then
            C.users[v] = {}
        end
        local H = C.users[v]
        for R, S in pairs(t) do
            repeat
                local P = H.cheat
                if
                    H.cheat ~= R and
                        (R ~= q.cheat_neverlose or
                            H.cheat ~= q.cheat_evolve and H.cheat ~= q.cheat_gamesense and H.cheat ~= q.cheat_plague and
                                H.cheat ~= q.cheat_pandora and
                                H.cheat ~= q.cheat_rifk and
                                H.cheat ~= q.cheat_airflow and
                                H.cheat ~= q.cheat_fatality) and
                        (R ~= q.cheat_nixware or H.cheat ~= "nl") and
                        (R ~= q.cheat_evolve or
                            H.cheat ~= q.cheat_pandora and H.cheat ~= "nl" and H.cheat ~= q.cheat_fatality) and
                        (R ~= q.cheat_gamesense or
                            H.cheat ~= q.cheat_evolve and H.cheat ~= q.cheat_onetap and H.cheat ~= q.cheat_plague and
                                H.cheat ~= q.cheat_pandora and
                                H.cheat ~= q.cheat_rifk and
                                H.cheat ~= q.cheat_fatality) and
                        (R ~= q.cheat_onetap or
                            H.cheat ~= q.cheat_nixware and H.cheat ~= q.cheat_fatality and H.cheat ~= q.cheat_pandora and
                                H.cheat ~= q.cheat_plague)
                 then
                    if R == q.cheat_fatality and (H.cheat == q.cheat_nixware or H.cheat == q.cheat_pandora) then
                        break
                    end
                    if S(u, v) then
                        H.cheat = R
                        H.icon_set = false
                    end
                end
            until true
        end
    end
}
local T = {}
do
    T.function_t = ffi.typeof("bool(__fastcall*)(void*, void*, void*)")
    T.function_ptr = nil
    T.original = nil
    T.old_prot = ffi.new("unsigned long[1]")
    T.hooked = false
    T.VirtualProtect =
        ffi.cast(
        "int (__stdcall*)(void* lpAddress, unsigned long dwSize, unsigned long flNewProtect, unsigned long* lpflOldProtect)",
        ffi.cast("uint32_t**", utils.find_pattern("gameoverlayrenderer.dll", "8B 1D ?? ?? ?? ?? 90") + 2)[0][0]
    )
    T.hooked = function(U, V, Q)
        c:safe_call(D.on_voice_data, D, Q)
        return T.original(U, V, Q)
    end
    T.init = function()
        T.function_ptr =
            utils.find_pattern("engine.dll", "A1 ?? ?? ?? ?? 81 EC 84 01 00 00 53 56 8B F1") - 6 or
            error("~ Pattern not found!")
        T.original = ffi.cast(T.function_t, ffi.cast("uint32_t*", T.function_ptr + 1)[0] + T.function_ptr + 5)
        local W = tonumber(ffi.cast("intptr_t", ffi.cast("void*", ffi.cast(T.function_t, T.hooked))))
        local X = W - T.function_ptr - 5
        local Y = ffi.cast("void*", T.function_ptr + 1)
        T.VirtualProtect(Y, 0x4, 0x40, T.old_prot)
        ffi.cast("uint32_t*", T.function_ptr + 1)[0] = X
        T.VirtualProtect(Y, 0x4, T.old_prot[0], T.old_prot)
        T.hooked = true
        print("~ Cheat revealer loaded")
    end
    T.destroy = function()
        if not T.hooked then
            return
        end
        local Y = ffi.cast("void*", T.function_ptr + 1)
        T.VirtualProtect(Y, 0x4, 0x40, T.old_prot)
        local X = tonumber(ffi.cast("intptr_t", ffi.cast("void*", T.original))) - T.function_ptr - 5
        ffi.cast("uint32_t*", T.function_ptr + 1)[0] = X
        T.VirtualProtect(Y, 0x4, T.old_prot[0], T.old_prot)
        print("~ Cheat revealer unloaded")
    end
end
c:safe_call(D.init, D)
c:safe_call(T.init)
function on_level_init()
    c:safe_call(D.on_level_init, D)
end
function on_paint()
    c:safe_call(D.on_paint, D)
end
function on_shutdown()
    c:safe_call(T.destroy)
    js.clear()
    js.destroy()
end
