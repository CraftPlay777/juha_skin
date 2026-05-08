-- juha_skin | juha_game (CraftPlay777)
-- Selector de skins como pestaña sfinv de minetest_game

juha_skin      = {}
juha_skin.list = {}
juha_skin.cur  = {}

local MODPATH  = minetest.get_modpath("juha_skin")
local PER_PAGE = 10

-- carga skins desde /skins/*.txt
local function load_skins()
    local dir   = MODPATH .. "/skins/"
    local files = minetest.get_dir_list(dir, false)
    if not files then return end
    for _, fname in ipairs(files) do
        if fname:sub(-4) == ".txt" then
            local id   = fname:sub(1, -5)
            local meta = { nombre = id, creador = "Desconocido", licencia = "MIT" }
            local f = io.open(dir .. fname, "r")
            if f then
                for line in f:lines() do
                    local k, v = line:match("^([^:]+):%s*(.+)$")
                    if k and v then meta[k:lower():gsub("%s+", "")] = v end
                end
                f:close()
            end
            table.insert(juha_skin.list, {
                id       = id,
                nombre   = meta.nombre,
                creador  = meta.creador,
                licencia = meta.licencia,
                tex      = "juha_skin_" .. id .. ".png",
                tex_ver  = "juha_skin_" .. id .. "_ver.png",
            })
        end
    end
    table.sort(juha_skin.list, function(a, b) return a.id < b.id end)
    minetest.log("action", "[juha_skin] " .. #juha_skin.list .. " skin(s) cargada(s)")
end

load_skins()

-- aplica skin: cuerpo, mano e hijos
function juha_skin.apply(player, skin_id)
    local name  = player:get_player_name()
    local valid = false
    for _, s in ipairs(juha_skin.list) do
        if s.id == skin_id then valid = true; break end
    end
    if not valid then return false end

    juha_skin.cur[name] = skin_id
    local tex = "juha_skin_" .. skin_id .. ".png"

    local function do_apply()
        local p = minetest.get_player_by_name(name)
        if not p then return end
        if player_api and player_api.set_textures then
            player_api.set_textures(p, { tex })
        end
        p:set_properties({ textures = { tex }, visual = "mesh" })
        if player_api and player_api.update_wielded_item then
            player_api.update_wielded_item(p)
        end
        for _, obj in ipairs(p:get_children()) do
            if obj and obj:get_luaentity() then
                obj:set_properties({ textures = { tex } })
            end
        end
    end

    do_apply()
    minetest.after(0.3, do_apply)
    minetest.after(0.8, do_apply)
    player:get_meta():set_string("juha_skin:current", skin_id)
    return true
end

function juha_skin.get_id(name)
    if juha_skin.cur[name] then return juha_skin.cur[name] end
    local p = minetest.get_player_by_name(name)
    if p then
        local saved = p:get_meta():get_string("juha_skin:current")
        if saved ~= "" then return saved end
    end
    return juha_skin.list[1] and juha_skin.list[1].id or "prede"
end

function juha_skin.get_tex(name)
    return "juha_skin_" .. juha_skin.get_id(name) .. ".png"
end

-- construye el contenido de la pestaña
local COLS    = 5
local CW      = 1.5
local CH      = 2.2
local START_X = 0.1
local START_Y = 0.3

local function build_tab(player, context)
    local name     = player:get_player_name()
    local total    = #juha_skin.list
    local max_page = math.max(1, math.ceil(total / PER_PAGE))
    local page     = context.jskin_page or 1
    local cur      = juha_skin.get_id(name)
    local fs       = ""

    if page > 1 then
        fs = fs .. "button[0.1,4.6;1.4,0.5;jskin_prev;< Ant]"
    end
    fs = fs .. "label[1.7,4.8;Pág " .. page .. "/" .. max_page .. "]"
    if page < max_page then
        fs = fs .. "button[3.0,4.6;1.4,0.5;jskin_next;Sig >]"
    end

    local si = (page - 1) * PER_PAGE + 1
    local ei = math.min(total, si + PER_PAGE - 1)

    for i = si, ei do
        local skin = juha_skin.list[i]
        local li   = i - si
        local col  = li % COLS
        local row  = math.floor(li / COLS)
        local cx   = START_X + col * CW
        local cy   = START_Y + row * CH

        if skin.id == cur then
            fs = fs .. "box[" .. cx .. "," .. cy .. ";"
                    .. (CW - 0.05) .. "," .. (CH - 0.05) .. ";#FFD93D55]"
        end

        fs = fs .. "image_button["
                .. (cx + 0.05) .. "," .. cy .. ";"
                .. (CW - 0.15) .. "," .. (CH - 0.5) .. ";"
                .. skin.tex_ver .. ";jskin_" .. skin.id .. ";]"
                .. "tooltip[jskin_" .. skin.id .. ";"
                .. minetest.formspec_escape(
                       "Nombre: "   .. skin.nombre   .. "\n"
                    .. "Creador: "  .. skin.creador  .. "\n"
                    .. "Licencia: " .. skin.licencia
                   ) .. "]"

        fs = fs .. "label["
                .. (cx + 0.1) .. "," .. (cy + CH - 0.4) .. ";"
                .. minetest.formspec_escape(skin.nombre) .. "]"
    end

    return fs
end

-- pestaña en sfinv (minetest_game)
sfinv.register_page("juha_skin:skins", {
    title = "Skins",

    get = function(self, player, context)
        context.jskin_page = context.jskin_page or 1
        return sfinv.make_formspec(player, context,
            build_tab(player, context), true)
    end,

    on_player_receive_fields = function(self, player, context, fields)
        local page     = context.jskin_page or 1
        local max_page = math.max(1, math.ceil(#juha_skin.list / PER_PAGE))
        local changed  = false

        if fields.jskin_prev then
            context.jskin_page = math.max(1, page - 1)
            changed = true
        elseif fields.jskin_next then
            context.jskin_page = math.min(max_page, page + 1)
            changed = true
        else
            for _, skin in ipairs(juha_skin.list) do
                if fields["jskin_" .. skin.id] then
                    juha_skin.apply(player, skin.id)
                    changed = true
                    break
                end
            end
        end

        if changed then
            sfinv.set_player_inventory_formspec(player, context)
        end
    end,
})

-- persistencia al conectar
minetest.register_on_joinplayer(function(player)
    minetest.after(1.2, function()
        local p = minetest.get_player_by_name(player:get_player_name())
        if not p then return end
        local saved = p:get_meta():get_string("juha_skin:current")
        local id = (saved ~= "") and saved
               or (juha_skin.list[1] and juha_skin.list[1].id)
        if id then
            juha_skin.apply(p, id)
            minetest.after(0.5, function()
                local p2 = minetest.get_player_by_name(p:get_player_name())
                if p2 then juha_skin.apply(p2, id) end
            end)
        end
    end)
end)

-- limpieza al salir
minetest.register_on_leaveplayer(function(player)
    juha_skin.cur[player:get_player_name()] = nil
end)