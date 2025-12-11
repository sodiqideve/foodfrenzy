# Food Truck Frenzy: Asset List

This file lists all custom assets needed for the game with generation prompts.

---

## IMAGES

### 1. Food Truck (Player)

**File:** `truck.png`  
**Size:** 256x256px (transparent PNG)

**Prompt:**
```
Cute cartoon food truck, top-down isometric view at 45-degree angle, bright blue body with orange and yellow accents, small serving window on the side, visible wheels, simple windshield, clean vector style with black outlines, soft drop shadow, white background, game asset sprite, 2D mobile game art style similar to Crossy Road
```

---

### 2. Ingredients (5 assets)

#### 2.1 Tomato
**File:** `tomato.png`  
**Size:** 128x128px (transparent PNG)

**Prompt:**
```
Cartoon tomato icon, bright red with small green stem, shiny highlight, simple 3D-styled 2D look, black outline, soft shadow, top-down slightly angled view, game item pickup sprite, clean vector style, white background, mobile game asset
```

#### 2.2 Cheese
**File:** `cheese.png`  
**Size:** 128x128px (transparent PNG)

**Prompt:**
```
Cartoon cheese slice icon, yellow-orange cheddar with small holes, triangular wedge shape, shiny highlight, simple 3D-styled 2D look, black outline, soft shadow, slightly angled top-down view, game item pickup sprite, clean vector style, white background, mobile game asset
```

#### 2.3 Lettuce
**File:** `lettuce.png`  
**Size:** 128x128px (transparent PNG)

**Prompt:**
```
Cartoon lettuce leaf icon, bright green with wavy edges, fresh and crisp looking, shiny highlight, simple 3D-styled 2D look, black outline, soft shadow, slightly angled top-down view, game item pickup sprite, clean vector style, white background, mobile game asset
```

#### 2.4 Burger Patty
**File:** `patty.png`  
**Size:** 128x128px (transparent PNG)

**Prompt:**
```
Cartoon cooked burger patty icon, brown grilled meat with subtle grill marks, round flat shape, shiny highlight, simple 3D-styled 2D look, black outline, soft shadow, slightly angled top-down view, game item pickup sprite, clean vector style, white background, mobile game asset
```

#### 2.5 Burger Bun
**File:** `bun.png`  
**Size:** 128x128px (transparent PNG)

**Prompt:**
```
Cartoon burger bun top icon, golden-brown with sesame seeds on top, round dome shape, shiny highlight, simple 3D-styled 2D look, black outline, soft shadow, slightly angled top-down view, game item pickup sprite, clean vector style, white background, mobile game asset
```

---

### 3. Obstacles (3 assets)

#### 3.1 Traffic Cone
**File:** `cone.png`  
**Size:** 96x96px (transparent PNG)

**Prompt:**
```
Cartoon traffic cone, orange with white stripes, top-down isometric view, simple 3D-styled 2D look, black outline, soft shadow, road hazard game obstacle sprite, clean vector style, white background, mobile game asset
```

#### 3.2 Pothole
**File:** `pothole.png`  
**Size:** 96x96px (transparent PNG)

**Prompt:**
```
Cartoon pothole in road, dark gray circular hole with cracked asphalt edges, top-down view, simple 2D game style, black outline, subtle depth shading, road hazard game obstacle sprite, clean vector style, white background, mobile game asset
```

#### 3.3 Construction Barrier
**File:** `barrier.png`  
**Size:** 128x96px (transparent PNG)

**Prompt:**
```
Cartoon wooden construction barrier, yellow and black diagonal stripes, horizontal barricade, top-down isometric view, simple 3D-styled 2D look, black outline, soft shadow, road hazard game obstacle sprite, clean vector style, white background, mobile game asset
```

---

### 4. Background Buildings (Optional - for parallax)

**File:** `buildings.png`  
**Size:** 512x256px (seamless horizontal tile, transparent PNG)

**Prompt:**
```
Cartoon city buildings silhouette row, colorful storefronts and shops, top-down isometric angle, simple flat 2D style, pastel colors (pink, blue, yellow, mint), no fine details, suitable for background parallax layer, seamless horizontal tile, clean vector style, transparent background, mobile game asset
```

---

## AUDIO

### Sound Effects (SFX)

| File | Description | Generation Notes |
|------|-------------|------------------|
| `collect.wav` | Ingredient pickup | Bright pop/pling sound, 0.3s, satisfying and rewarding |
| `deliver.wav` | Order delivered | Cash register cha-ching, 0.5s, celebratory |
| `hit.wav` | Obstacle collision | Soft bonk/thud, 0.3s, not harsh |
| `swoosh.wav` | Lane change | Quick whoosh, 0.2s, smooth |
| `combo.wav` | Combo achieved | Ascending chime (3 notes), 0.4s, exciting |
| `click.wav` | Button tap | Light click, 0.1s, responsive |
| `win.wav` | Level complete | Victory fanfare, 2-3s, triumphant |
| `fail.wav` | Level failed | Gentle descending tone, 1-2s, not harsh |

**SFX Generation Prompt (for AI audio tools):**
```
8-bit retro arcade game sound effect, casual mobile game style, family-friendly, clean and clear tone, no distortion
```

---

### Background Music (2 tracks)

#### Menu Music
**File:** `menu_music.mp3`  
**Length:** 60-90 seconds (seamless loop)

**Prompt/Description:**
```
Upbeat cheerful background music for casual mobile game menu, light electronic with ukulele and hand claps, 120 BPM, happy and inviting mood, family-friendly, loopable, royalty-free game music style
```

#### Gameplay Music
**File:** `gameplay_music.mp3`  
**Length:** 90-120 seconds (seamless loop)

**Prompt/Description:**
```
Energetic but not overwhelming background music for casual mobile arcade game, electronic beat with marimba or pizzicato melody, 130 BPM, focused and encouraging mood, not distracting, loopable, royalty-free game music style
```

---

## Asset Summary

| Category | Count | Files |
|----------|-------|-------|
| Images | 10 | truck, 5 ingredients, 3 obstacles, buildings |
| SFX | 8 | collect, deliver, hit, swoosh, combo, click, win, fail |
| Music | 2 | menu, gameplay |
| **Total** | **20** | |

---

## Notes

- All images should have transparent backgrounds
- Use consistent art style across all sprites (black outlines, soft shadows)
- SFX should be short and non-intrusive
- Music should loop seamlessly without noticeable cut points
- Customers use emoji/code-generated avatars (no custom asset needed)
- Road, lanes, HUD elements are code-generated (no custom asset needed)

