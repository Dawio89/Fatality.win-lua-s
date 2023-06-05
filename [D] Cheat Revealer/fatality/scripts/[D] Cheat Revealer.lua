--lmao crash
--disclaimer, I do not guarantee for this to work perfectly, as I just quickly pasted it just so that it works('ish lol)
local images_path = "file://{images}/icons/revealer/%s.png"
local panorama = require('panorama')
local js = panorama.loadstring([[
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
            print(("Error: %s"):format(f))
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

local cheat = {
    fatality = "ft",
    nixware = "nw",
    neverlose = "nl",
    gamesense = "gs",
    evolve = "ev",
    onetap = "ot",
    pandora = "pd",
    plague = "pl",
    rifk = "r7",
    airflow = "af"
}

local cheat_names = {
    [cheat.fatality] = "Fatality",
    [cheat.nixware] = "Nixware",
    [cheat.neverlose] = "Neverlose",
    [cheat.gamesense] = "Gamesense",
    [cheat.evolve] = "Evolve",
    [cheat.onetap] = "Onetap",
    [cheat.pandora] = "Pandora",
    [cheat.plague] = "Plague",
    [cheat.rifk] = "Rifk",
    [cheat.airflow] = "Airflow"
}

local detection_storage_table = {
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

local detector_table = {

    [cheat.neverlose] = function(packet, target)
        if packet.xuid_high == 0 then
            return
        end
        local sig = ("%.02X"):format(ffi.cast("uint16_t*", ffi.cast("uintptr_t", packet) + 22)[0])
        if sig == detection_storage_table.current_signature then
            detection_storage_table.nl.sig_count[target] = (detection_storage_table.nl.sig_count[target] or 0) + 1
            if detection_storage_table.nl.sig_count[target] > 24 then
                detection_storage_table.nl.found[target] = 1
                return true
            else
                detection_storage_table.nl.sig_count[target] = nil
            end
        end
        if #detection_storage_table.nl.found > 3 then
            return false
        end
        if not detection_storage_table.nl[target] then
            detection_storage_table.nl[target] = {}
        end
        detection_storage_table.nl[target][#detection_storage_table.nl[target] + 1] = packet.xuid_high
        if #detection_storage_table.nl[target] > 24 then
            if c:find_duplicate_element(detection_storage_table.nl[target], 4) and packet.xuid_high ~= 0 then
                detection_storage_table.current_signature = sig
                detection_storage_table.nl[target] = {}
                return true
            end
            table.remove(detection_storage_table.nl[target], 1)
        end
        return false
    end,

    [cheat.nixware] = function(packet, target)
        if not detection_storage_table.nw[target] then
            detection_storage_table.nw[target] = 0
        end
        if detection_storage_table.nw[target] > 34 then
            detection_storage_table.nw[target] = nil
            return true
        elseif packet.xuid_high == 0 then
            detection_storage_table.nw[target] = detection_storage_table.nw[target] + 1
        else
            detection_storage_table.nw[target] = 0
        end
        return false
    end,

    [cheat.pandora] = function(packet, target)
        if not detection_storage_table.pd[target] then
            detection_storage_table.pd[target] = 0
        end
        local sig = ("%.02X"):format(ffi.cast("uint16_t*", ffi.cast("uintptr_t", packet) + 16)[0])
        if detection_storage_table.pd[target] > 24 then
            return true
        elseif sig == "695B" or sig == "1B39" then
            detection_storage_table.pd[target] = detection_storage_table.pd[target] + 1
        else
            detection_storage_table.pd[target] = 0
        end
        return false
    end,

    [cheat.onetap] = function(packet, target)
        if not detection_storage_table.ot[target] then
            detection_storage_table.ot[target] = {}
        end
        detection_storage_table.ot[target][#detection_storage_table.ot[target] + 1] = {
            sequence_bytes = packet.sequence_bytes,
            xuid_low = packet.xuid_low,
            section_number = packet.section_number,
            umcompressed_sample_offset = packet.uncompressed_sample_offset
        }
        if #detection_storage_table.ot[target] > 16 then
            local x = detection_storage_table.ot[target][1]
            for y = 2, #detection_storage_table.ot[target] do
                local z = detection_storage_table.ot[target][y]
                if
                    z.xuid_low ~= x.xuid_low or z.section_number ~= x.section_number or
                        z.uncompressed_sample_offset ~= x.uncompressed_sample_offset
                 then
                    table.remove(detection_storage_table.ot[target], 1)
                    return false
                end
            end
            table.remove(detection_storage_table.ot[target], 1)
            return true
        end
        return false
    end,

    [cheat.fatality] = function(packet, target)
        if not detection_storage_table.ft[target] then
            detection_storage_table.ft[target] = 0
        end
        local sig = ("%.02X"):format(ffi.cast("uint16_t*", ffi.cast("uintptr_t", packet) + 16)[0])
        if detection_storage_table.ft[target] > 36 then
            return true
        elseif sig == "7FFA" or sig == "7FFB" then
            detection_storage_table.ft[target] = detection_storage_table.ft[target] + 1
        end
        return false
    end,

    [cheat.plague] = function(packet, target)
        if not detection_storage_table.pl[target] then
            detection_storage_table.pl[target] = 0
        end
        if detection_storage_table.pl[target] > 24 then
            return true
        elseif ("%.02X"):format(ffi.cast("uint16_t*", ffi.cast("uintptr_t", packet) + 44)[0]) == "7275" then
            detection_storage_table.pl[target] = detection_storage_table.pl[target] + 1
        else
            detection_storage_table.pl[target] = 0
        end
        return false
    end,

    [cheat.evolve] = function(packet, target)
        if not detection_storage_table.ev[target] then
            detection_storage_table.ev[target] = {}
        end
        detection_storage_table.ev[target][#detection_storage_table.ev[target] + 1] = packet.xuid_high
        if #detection_storage_table.ev[target] > 44 then
            for y = 1, #detection_storage_table.ev[target] - 4 do
                local A = detection_storage_table.ev[target][y]
                if detection_storage_table.ev[target][y + 1] + detection_storage_table.ev[target][y + 2] == detection_storage_table.ev[target][y] * 2 and detection_storage_table.ev[target][y + 4] == A + 1 then
                    detection_storage_table.ev[target] = {}
                    return true
                end
            end
            table.remove(detection_storage_table.ev[target], 1)
        end
        return false
    end,

    [cheat.rifk] = function(packet, target)
        if not detection_storage_table.r7[target] then
            detection_storage_table.r7[target] = 0
        end
        local sig = ("%.02X"):format(ffi.cast("uint16_t*", ffi.cast("uintptr_t", packet) + 16)[0])
        if detection_storage_table.r7[target] > 24 then
            return true
        elseif sig == "234" or sig == "134" then
            detection_storage_table.r7[target] = detection_storage_table.r7[target] + 1
        else
            detection_storage_table.r7[target] = 0
        end
        return false
    end,

    [cheat.airflow] = function(packet, target)
        if not detection_storage_table.af[target] then
            detection_storage_table.af[target] = 0
        end
        if detection_storage_table.af[target] > 24 then
            return true
        elseif ("%.02X"):format(ffi.cast("uint16_t*", ffi.cast("uintptr_t", packet) + 16)[0]) == "AFF1" then
            detection_storage_table.af[target] = detection_storage_table.af[target] + 1
        else
            detection_storage_table.af[target] = 0
        end
        return false
    end,

    [cheat.gamesense] = function(packet, target)
        local sig = ("%.02X"):format(ffi.cast("uint16_t*", ffi.cast("uintptr_t", packet) + 22)[0])
        local sequence_bytes = string.sub(packet.sequence_bytes, 1, 4)
        if not detection_storage_table.gs[target] then
            detection_storage_table.gs[target] = {repeated = 0, packet = sig, bytes = sequence_bytes}
        end
        if sequence_bytes ~= detection_storage_table.gs[target].bytes and sig ~= detection_storage_table.gs[target].packet then
            detection_storage_table.gs[target].packet = sig
            detection_storage_table.gs[target].bytes = sequence_bytes
            detection_storage_table.gs[target].repeated = detection_storage_table.gs[target].repeated + 1
        else
            detection_storage_table.gs[target].repeated = 0
        end
        if detection_storage_table.gs[target].repeated >= 36 then
            detection_storage_table.gs[target] = {repeated = 0, packet = sig, bytes = sequence_bytes}
            return true
        end
        return false
    end
}

local main_data_table = {users = {}}

local data = {

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
        self.icons[cheat.fatality] = render.create_texture("csgo/materials/panorama/images/icons/revealer/ft.jpg")
        self.icons[cheat.neverlose] = render.create_texture("csgo/materials/panorama/images/icons/revealer/nl.jpg")
        self.icons[cheat.nixware] = render.create_texture("csgo/materials/panorama/images/icons/revealer/nw.jpg")
        self.icons[cheat.gamesense] = render.create_texture("csgo/materials/panorama/images/icons/revealer/gs.jpg")
        self.icons[cheat.evolve] = render.create_texture("csgo/materials/panorama/images/icons/revealer/ev.jpg")
        self.icons[cheat.onetap] = render.create_texture("csgo/materials/panorama/images/icons/revealer/ot.jpg")
        self.icons[cheat.pandora] = render.create_texture("csgo/materials/panorama/images/icons/revealer/pd.jpg")
        self.icons[cheat.plague] = render.create_texture("csgo/materials/panorama/images/icons/revealer/pl.jpg")
        self.icons[cheat.rifk] = render.create_texture("csgo/materials/panorama/images/icons/revealer/r7.jpg")
        self.icons[cheat.airflow] = render.create_texture("csgo/materials/panorama/images/icons/revealer/af.jpg")
    end,

    on_level_init = function(self)
        main_data_table.users = {}
    end,
    
    on_paint = function(self)
        if not engine.is_in_game() then
            return
        end
        entities.for_each_player(
            function(player)

                if not player or not player:is_alive() then
                    return
                end

                local target = player:get_index()

                local user = main_data_table.users[target]

                if not user then
                    return
                end

                local cheat_d = main_data_table.users[target].cheat
                if self.icons[cheat_d] ~= nil then
                    js.update(target, images_path:format(cheat_d and cheat_d or target == engine.get_local_player() and "ft" or "wh"))
                end

            end
        )
    end,

    on_voice_data = function(self, event)
        local packet = ffi.cast(self.voice_data_t, event)
        local target = packet.client + 1
        if not main_data_table.users[target] then
            main_data_table.users[target] = {}
        end
        local user = main_data_table.users[target]
        for detector_table, cheat_detection_function in pairs(detector_table) do
            repeat
                local cheat_d = user.cheat
                if
                    user.cheat ~= detector_table and
                        (detector_table ~= cheat.neverlose or
                            user.cheat ~= cheat.evolve and user.cheat ~= cheat.gamesense and user.cheat ~= cheat.plague and
                                user.cheat ~= cheat.pandora and
                                user.cheat ~= cheat.rifk and
                                user.cheat ~= cheat.airflow and
                                user.cheat ~= cheat.fatality) and
                        (detector_table ~= cheat.nixware or user.cheat ~= "nl") and
                        (detector_table ~= cheat.evolve or
                            user.cheat ~= cheat.pandora and user.cheat ~= "nl" and user.cheat ~= cheat.fatality) and
                        (detector_table ~= cheat.gamesense or
                            user.cheat ~= cheat.evolve and user.cheat ~= cheat.onetap and user.cheat ~= cheat.plague and
                                user.cheat ~= cheat.pandora and
                                user.cheat ~= cheat.rifk and
                                user.cheat ~= cheat.fatality) and
                        (detector_table ~= cheat.onetap or
                            user.cheat ~= cheat.nixware and user.cheat ~= cheat.fatality and user.cheat ~= cheat.pandora and
                                user.cheat ~= cheat.plague)
                 then
                    if detector_table == cheat.fatality and (user.cheat == cheat.nixware or user.cheat == cheat.pandora) then
                        break
                    end
                    if cheat_detection_function(packet, target) then
                        user.cheat = detector_table
                        user.icon_set = false
                    end
                end
            until true
        end
    end
}

local cheatRevealer = {}

do
    cheatRevealer.function_t = ffi.typeof("bool(__fastcall*)(void*, void*, void*)")
    cheatRevealer.function_ptr = nil
    cheatRevealer.original = nil
    cheatRevealer.old_prot = ffi.new("unsigned long[1]")
    cheatRevealer.hooked = false
    cheatRevealer.VirtualProtect =
        ffi.cast(
        "int (__stdcall*)(void* lpAddress, unsigned long dwSize, unsigned long flNewProtect, unsigned long* lpflOldProtect)",
        ffi.cast("uint32_t**", utils.find_pattern("gameoverlayrenderer.dll", "8B 1D ?? ?? ?? ?? 90") + 2)[0][0]
    )
    cheatRevealer.hooked = function(U, V, event)
        c:safe_call(data.on_voice_data, data, event)
        return cheatRevealer.original(U, V, event)
    end
    cheatRevealer.init = function()
        cheatRevealer.function_ptr =
            utils.find_pattern("engine.dll", "A1 ?? ?? ?? ?? 81 EC 84 01 00 00 53 56 8B F1") - 6 or
                error("Pattern not found!")
            cheatRevealer.original = ffi.cast(cheatRevealer.function_t, ffi.cast("uint32_t*", cheatRevealer.function_ptr + 1)[0] + cheatRevealer.function_ptr + 5)
        local W = tonumber(ffi.cast("intptr_t", ffi.cast("void*", ffi.cast(cheatRevealer.function_t, cheatRevealer.hooked))))
        local X = W - cheatRevealer.function_ptr - 5
        local Y = ffi.cast("void*", cheatRevealer.function_ptr + 1)
            cheatRevealer.VirtualProtect(Y, 0x4, 0x40, cheatRevealer.old_prot)
            ffi.cast("uint32_t*", cheatRevealer.function_ptr + 1)[0] = X
            cheatRevealer.VirtualProtect(Y, 0x4, cheatRevealer.old_prot[0], cheatRevealer.old_prot)
            cheatRevealer.hooked = true
                print("Cheat revealer loaded")
    end
    cheatRevealer.destroy = function()
        if not cheatRevealer.hooked then
            return
        end
        local Y = ffi.cast("void*", cheatRevealer.function_ptr + 1)
            cheatRevealer.VirtualProtect(Y, 0x4, 0x40, cheatRevealer.old_prot)
        local X = tonumber(ffi.cast("intptr_t", ffi.cast("void*", cheatRevealer.original))) - cheatRevealer.function_ptr - 5
            ffi.cast("uint32_t*", cheatRevealer.function_ptr + 1)[0] = X
            cheatRevealer.VirtualProtect(Y, 0x4, cheatRevealer.old_prot[0], cheatRevealer.old_prot)
                print("Cheat revealer unloaded")
    end
end

c:safe_call(data.init, data)
c:safe_call(cheatRevealer.init)

function on_level_init()
    c:safe_call(data.on_level_init, data)
end

function on_paint()
    c:safe_call(data.on_paint, data)
end

function on_shutdown()
    c:safe_call(cheatRevealer.destroy)
    js.clear()
    js.destroy()
end
