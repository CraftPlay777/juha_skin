# juha_skin

Mod para [minetest](https://www.luanti.org/) que permite a los jugadores elegir su skin desde una pestaña del inventario de Minetest Game.

---

## Características

- Pestaña "Skins" integrada al inventario de Minetest Game vía `sfinv`
- Soporte para múltiples skins con paginación
- Resalta la skin activa del jugador
- Persistencia entre sesiones
- Tooltips con nombre, creador y licencia de cada skin

---

## Dependencias

| Mod | Tipo |
|-----|------|
| `player_api` | Requerida |
| `sfinv` | Requerida (incluida en Minetest Game) |

---

## Instalación

1. Copiar la carpeta `juha_skin` en el directorio `mods/` de tu mundo o juego.
2. Asegurarse de que `player_api` y `sfinv` estén activos.
3. Activar el mod desde el menú de configuración del mundo.

---

## Agregar skins

Cada skin requiere dos archivos de textura y un archivo de metadatos:

```
juha_skin/
├── textures/
│   ├── juha_skin_<id>.png       -- textura plana (aplicada al modelo)
│   └── juha_skin_<id>_ver.png   -- vista previa vertical (mostrada en el selector)
└── skins/
    └── <id>.txt                 -- metadatos de la skin
```

### Formato del archivo `.txt`

```
nombre: Mi Skin
creador: TuNombre
licencia: MIT
```

---

## API pública

```lua
-- aplica una skin al jugador
juha_skin.apply(player, skin_id)  -- devuelve true/false

-- obtiene el id de la skin activa de un jugador
juha_skin.get_id(name)  -- devuelve string

-- obtiene el nombre de la textura activa de un jugador
juha_skin.get_tex(name)  -- devuelve "juha_skin_<id>.png"
```

---

## Licencia

MIT — ver [LICENSE](LICENSE)

## Créditos

Juha (CraftPlay777)
