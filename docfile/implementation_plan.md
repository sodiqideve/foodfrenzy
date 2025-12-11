# Food Truck Frenzy: Implementation Plan

**Timeline:** 2-3 weeks  
**Tech Stack:** Flutter + Flame Engine

---

## Phase 1: Project Setup & Core Infrastructure (Days 1-2)

### Tasks:
- [ ] Create Flutter project with Flame engine
- [ ] Set up project folder structure
- [ ] Configure Android build settings (API 23+, portrait lock)
- [ ] Add dependencies: `flame`, `flame_audio`, `shared_preferences`
- [ ] Create basic game loop and main entry point
- [ ] Implement screen navigation system (main menu → game → results)

### Deliverable:
App launches with placeholder screens and navigation working.

---

## Phase 2: Core Gameplay Mechanics (Days 3-7)

### 2.1 Road & Movement System (Day 3)
- [ ] Create scrolling road background (3 lanes)
- [ ] Implement vertical scrolling at configurable speed
- [ ] Add sidewalks on left and right sides
- [ ] Add lane line markers

### 2.2 Food Truck & Controls (Day 4)
- [ ] Add food truck sprite (fixed Y position, lower third of screen)
- [ ] Implement swipe detection (left/right)
- [ ] Create smooth lane-switching animation (0.2s ease-in-out)
- [ ] Prevent lane change during active transition

### 2.3 Ingredients (Day 5)
- [ ] Create 5 ingredient sprites (tomato, cheese, lettuce, patty, bun)
- [ ] Implement ingredient spawning system (random lane, random interval)
- [ ] Add collision detection for collection
- [ ] Create inventory system (max 10 items)
- [ ] Display inventory in HUD

### 2.4 Customers & Delivery (Day 6)
- [ ] Create customer sprites on sidewalks
- [ ] Add order bubbles showing required ingredients
- [ ] Implement delivery trigger zone detection
- [ ] Check inventory against order requirements
- [ ] Remove delivered ingredients from inventory
- [ ] Add delivery counter to HUD

### 2.5 Obstacles (Day 7)
- [ ] Create 3 obstacle types (cone, pothole, barrier)
- [ ] Implement obstacle spawning system
- [ ] Add collision detection with truck
- [ ] Apply speed reduction penalty on hit
- [ ] Add visual feedback (red flash)

### Deliverable:
Playable single level with all core mechanics working.

---

## Phase 3: Scoring & Progression (Days 8-10)

### 3.1 Scoring System (Day 8)
- [ ] Implement point system (+10 ingredients, +100 delivery)
- [ ] Add combo system (1.5x, 2x, 2.5x multipliers)
- [ ] Display score and combo in HUD
- [ ] Add distance-based scoring

### 3.2 Level System (Day 9)
- [ ] Create level configuration (distance, deliveries required, speed)
- [ ] Implement level completion check
- [ ] Calculate star rating (1-3 stars)
- [ ] Create Level Complete screen
- [ ] Create Level Failed screen

### 3.3 Level Progression (Day 10)
- [ ] Implement 15 levels with increasing difficulty
- [ ] Create level select screen with grid layout
- [ ] Add level unlock logic
- [ ] Implement Endless Mode (unlocks after Level 15)

### Deliverable:
Full level progression with 15 playable levels and endless mode.

---

## Phase 4: Save System & Settings (Days 11-12) ✅

### 4.1 Save Data (Day 11)
- [x] Save level progress (unlocked levels)
- [x] Save star ratings per level
- [x] Save high scores
- [x] Save endless mode best score
- [x] Load saved data on app start

### 4.2 Settings (Day 12)
- [x] Create settings screen
- [x] Add sound effects toggle
- [x] Add music toggle
- [x] Add vibration toggle (uses HapticFeedback - NO permissions required)
- [x] Add reset progress option (with confirmation)

### Deliverable:
Progress persists between sessions, settings work. ✅

---

## Phase 5: Audio & Visual Polish (Days 13-15) ✅

### 5.1 Sound Effects (Day 13)
- [x] Add collection sound (pop/pling)
- [x] Add delivery sound (cha-ching)
- [x] Add obstacle hit sound (bonk)
- [x] Add lane switch sound (whoosh)
- [x] Add combo sound (chime)
- [x] Add UI button sounds
- [x] Add level complete/failed sounds

### 5.2 Music (Day 14)
- [x] Add main menu background music
- [x] Add gameplay background music
- [x] Implement music toggle from settings
- [x] Handle audio pause/resume on app background

### 5.3 Visual Effects (Day 15)
- [x] Add collection particle effects (sparkles)
- [x] Add delivery particle effects (coins/stars)
- [x] Add truck idle animation (subtle bounce)
- [x] Add ingredient bobbing animation
- [x] Add parallax scrolling for background buildings (with lit windows)

### Deliverable:
Game feels complete with audio and visual feedback. ✅

---

## Phase 6: UI Completion & Polish (Days 16-17) ✅

### 6.1 UI Screens (Day 16)
- [x] Polish main menu design (animated title, bouncing truck, staggered buttons)
- [x] Add tutorial/info screen (accessible from "HOW TO PLAY" button)
- [x] Implement pause menu
- [x] Polish all result screens

### 6.2 HUD & Feedback (Day 17)
- [x] Finalize HUD layout (level indicator, enhanced score display)
- [x] Add temporary message displays ("PERFECT!", "NICE!", "-SPEED", "COMBO LOST", "INVENTORY FULL!")
- [x] Add progress bar for level distance
- [x] Polish transitions between screens (slide + fade animations)

### Deliverable:
All UI screens complete and polished. ✅

---

## Phase 7: Testing & Bug Fixes (Days 18-21)

### Tasks:
- [ ] Test all 15 levels for balance
- [ ] Test endless mode scaling
- [ ] Fix any collision detection issues
- [ ] Test on multiple screen sizes
- [ ] Performance optimization if needed
- [ ] Fix critical bugs

### Deliverable:
Stable, bug-free game ready for release.

---

## File Structure

```
lib/
├── main.dart
├── game/
│   ├── food_truck_game.dart      # Main game class
│   ├── components/
│   │   ├── truck.dart
│   │   ├── ingredient.dart
│   │   ├── customer.dart
│   │   ├── obstacle.dart
│   │   ├── road.dart
│   │   └── hud.dart
│   ├── managers/
│   │   ├── spawn_manager.dart
│   │   ├── collision_manager.dart
│   │   └── level_manager.dart
│   └── config/
│       └── level_config.dart
├── screens/
│   ├── main_menu_screen.dart
│   ├── level_select_screen.dart
│   ├── game_screen.dart
│   ├── pause_screen.dart
│   ├── level_complete_screen.dart
│   ├── level_failed_screen.dart
│   ├── settings_screen.dart
│   └── tutorial_screen.dart
├── services/
│   ├── audio_service.dart
│   └── save_service.dart
└── utils/
    └── constants.dart

assets/
├── images/
│   ├── truck.png
│   ├── ingredients/
│   ├── obstacles/
│   ├── customers/
│   └── backgrounds/
└── audio/
    ├── sfx/
    └── music/
```

---

## Priority Order

If time is limited, focus on these in order:

1. **Must Have (MVP):**
   - Core gameplay (truck, lanes, swipe controls)
   - Ingredients and collection
   - Customers and delivery
   - Obstacles
   - Basic scoring
   - 5 playable levels
   - Save progress

2. **Should Have:**
   - All 15 levels
   - Endless mode
   - Star ratings
   - Sound effects
   - Settings screen

3. **Nice to Have:**
   - Particle effects
   - Animations
   - Background music
   - Tutorial screen
   - Parallax backgrounds

