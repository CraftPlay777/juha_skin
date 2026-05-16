# juha_skin
Skin selector for [Luanti](https://www.luanti.org/) — accessible via command or inventory tab (optional).


## Command

```
/juha_skin
```

## Usage
| Mod | Required |
|-----|----------|
| `player_api` | Yes |
| `sfinv` | No (Minetest Game only) |

- Opens a grid with all available skins
- Highlights the player's active skin
- Supports pagination
- Tooltips show name, author and license per skin
- Skin choice persists across sessions

---

## Modes

### Command
Available in any game. Run `/juha_skin` to open the selector directly.

### Inventory tab
If `sfinv` is present (Minetest Game), a **Skins** tab is added to the player inventory automatically.

---

## Adding skins
Place two textures and one metadata file per skin:

```
juha_skin/
├── textures/
│   ├── juha_skin_<id>.png        -- flat texture (applied to model)
│   └── juha_skin_<id>_ver.png    -- vertical preview (shown in selector)
└── skins/
    └── <id>.txt                  -- skin metadata
```

**`<id>.txt` format:**
```
nombre: My Skin
creador: YourName
licencia: MIT
```

## API
```lua
juha_skin.apply(player, skin_id)  -- applies a skin, returns true/false
juha_skin.get_id(name)            -- returns the active skin id
juha_skin.get_tex(name)           -- returns "juha_skin_<id>.png"
```

## Notes
- `sfinv` is optional — if absent, use `/juha_skin` instead
- No errors are thrown when `sfinv` is missing

**Author:** Juha (CraftPlay777)
**License:** MIT
