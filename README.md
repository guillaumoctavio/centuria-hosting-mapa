# CENTURIA — Portal de Inteligencia Geoespacial

Portal de análisis territorial y electoral para la **Comuna 5 de Buenos Aires**. Visualización interactiva de datos demográficos y resultados electorales a escala de radio censal.

**Demo:** [centuria.vercel.app](https://centuria.vercel.app) _(actualizar con la URL real tras el deploy)_

---

## Stack

| Capa | Tecnología |
|---|---|
| Portal / Login | Three.js r128 + GSAP 3.12 |
| Mapas | MapLibre GL JS 4 |
| Basemaps | CartoDB (Oscuro, GPS, Blanco) + ESRI World Imagery (Satélite) |
| Datos | GeoJSON estático (225 radios censales) |
| Hosting | Vercel (sitio estático, sin backend) |

---

## Estructura

```
/
├── index.html              # Portal de entrada con animación 3D + login
├── mapa1.html              # Densidad poblacional
├── mapa2.html              # Composición social (género, edad)
├── mapa3.html              # Puente estratégico (población → electores → votos)
├── mapa4.html              # Elecciones PASO 2023
├── mapa5.html              # Elecciones Generales 2023
├── mapa6.html              # Balotaje 2023
├── mapa7.html              # Legislativas 2025
├── vercel.json             # Headers HTTP y configuración de cache
└── data/
    ├── comuna5_demografia.geojson      # Datos demográficos + padrones
    ├── comuna5_paso2023.geojson        # Resultados PASO 2023 por partido
    ├── comuna5_generales2023.geojson   # Resultados Generales 2023
    └── comuna5_balotaje2023.geojson    # Resultados Balotaje 2023
```

---

## Funcionalidades

### Portal (`index.html`)
- Animación 3D de ciudad con **InstancedMesh** (edificios, tráfico, peatones) — 1 draw call por tipo de objeto
- Login con contraseña — autenticación en `sessionStorage` para no repetirla al volver de un mapa
- Carrusel de módulos con accordion por categoría

### Mapas (`mapa*.html`)
- **Choropleth** por campo de datos con paletas de color configuradas por mapa
- **Extrusión 3D** en capas de densidad y votos
- **Panel lateral** con toggle de capas por sección
- **Modo edición** (✦ EDITAR): ajuste de opacidad (slider) y colores (color picker por stop) en tiempo real — con botón Reset y exportación de configuración
- **Selector de mapa base**: Oscuro / GPS / Blanco / Satélite — las capas de datos persisten al cambiar
- **Zoom del panel**: botones − / + (60%–160%), persiste en localStorage
- **Tooltip** on-hover con datos del radio censal
- **Click** en un radio censal: lo resalta con outline cian y centra la vista sobre él

---

## Datos

Todos los datos están pre-procesados como GeoJSON estático. Los archivos originales provenían de Kepler.gl y fueron extraídos y convertidos.

| Dataset | Campos clave |
|---|---|
| `comuna5_demografia.geojson` | Población, electores 2023/2025, votos, edad, género, grupos etarios |
| `comuna5_paso2023.geojson` | Votos y % por partido: JxC (Bullrich/Larreta), UxP (Massa/Grabois), LLA, FIT, HxNP |
| `comuna5_generales2023.geojson` | Votos y % presidenciales, fuerza ganadora por radio |
| `comuna5_balotaje2023.geojson` | Votos y % LLA vs UxP, ganador por radio |

---

## Deploy en Vercel

El proyecto es un sitio **100% estático** — sin build step, sin dependencias npm.

### Desde la CLI

```bash
npm i -g vercel
vercel          # primer deploy (sigue el wizard)
vercel --prod   # deploys siguientes
```

### Desde GitHub (recomendado)

1. Crear repositorio en GitHub y hacer push
2. Entrar a [vercel.com/new](https://vercel.com/new)
3. Importar el repositorio
4. **Framework Preset**: Other (sin build)
5. **Root Directory**: `/` (raíz)
6. Deploy → Vercel asigna una URL automáticamente

Cada push a `main` redeploya automáticamente.

---

## Generador de mapas

Los 7 archivos `mapa*.html` se generan con el script Python en `/tmp/gen_mapas_v2.py`. Para regenerar tras modificar datos o estilos:

```bash
python3 /tmp/gen_mapas_v2.py
```

El generador define las capas como estructuras de datos Python (colores, opacidades, campos, stops) y produce HTML/CSS/JS completo para cada mapa.

---

## Seguridad

- La contraseña (`centuria2026`) vive en el cliente — es una barrera de presentación, no seguridad real
- No hay API keys expuestas (CartoDB y ESRI no requieren token para uso básico)
- Headers HTTP configurados vía `vercel.json`: `X-Content-Type-Options`, `X-Frame-Options`, cache diferenciado
