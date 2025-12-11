# Food Truck Frenzy: Product Launch Document (PLD)

**Version:** 1.0 MVP  
**Platform:** Android (Google Play)  
**Technology Stack:** Flutter + Flame Engine  
**Target Audience:** Casual mobile gamers, ages 8+  
**Development Timeline:** 2-3 weeks for MVP  

---

## 1. EXECUTIVE SUMMARY

Food Truck Frenzy is a casual 2D top-down lane-runner mobile game where players control a food delivery truck, collecting ingredients and serving customers while avoiding obstacles. The game features simple swipe controls, colorful 3D-styled 2D graphics, and progressively challenging levels. The MVP focuses on core gameplay mechanics with 15 levels and an endless mode.

**Core Appeal:**
- Easy to learn, hard to master
- Satisfying collection and delivery mechanics
- Positive, family-friendly theme
- Quick play sessions (2-5 minutes per level)

---

## 2. GAME OVERVIEW

### 2.1 Core Concept
Players control a food truck that automatically moves forward on a three-lane road. By swiping left or right, players switch lanes to collect ingredient icons while avoiding obstacles. Customers wait on the sidewalks with order requests displayed above their heads. When the player drives near a customer with the required ingredients collected, the order is automatically delivered, earning points. The goal is to complete a target number of deliveries before reaching the end of each level.

### 2.2 Victory Conditions
- **Level Mode:** Complete the required number of deliveries (starts at 5, increases with difficulty) before reaching the level's end point
- **Endless Mode:** Survive as long as possible while maximizing score through deliveries and combos

### 2.3 Failure Conditions
- Hitting too many obstacles causes the truck to slow down significantly, making it impossible to complete deliveries in time
- In endless mode, the game continues until the player chooses to quit or the difficulty becomes unmanageable

---

## 3. GAMEPLAY MECHANICS

### 3.1 Player Controls

**Lane Switching:**
- The player swipes LEFT to move the truck to the left lane
- The player swipes RIGHT to move the truck to the right lane
- Lane changes are smooth and animated over 0.2 seconds using ease-in-out curve
- Players cannot change lanes while a lane change is already in progress
- The truck always stays in one of three distinct lanes (left, center, right)

**No Other Controls:**
- The truck automatically moves forward at a constant speed
- No acceleration, braking, or vertical movement control
- The game is entirely controlled through lane-switching only

### 3.2 Movement System

**Truck Movement:**
- The food truck is positioned at a fixed vertical position in the lower third of the screen
- The truck never moves up or down - it remains stationary on the Y-axis
- The road, obstacles, ingredients, and customers scroll downward toward the player, creating the illusion that the truck is moving forward
- Scrolling speed starts at a moderate pace (400 pixels per second) and increases slightly with each level

**Camera Perspective:**
- Top-down view with slight isometric angle for visual depth
- The camera is fixed and never moves
- All gameplay elements scroll vertically downward

### 3.3 Ingredient Collection

**Ingredient Spawning:**
- Ingredients appear in the three lanes ahead of the player
- They spawn at random intervals (every 0.8 to 1.5 seconds) in random lanes
- Only one ingredient type appears at a time on screen to avoid overwhelming the player
- Ingredients scroll down toward the player at the same speed as the road

**Collection Mechanic:**
- When the player's truck overlaps with an ingredient (collision detection using rectangular hitboxes), the ingredient is automatically collected
- Visual feedback: a bright particle burst effect appears at the collection point (yellow sparkles radiating outward)
- Audio feedback: a satisfying "pop" or "pling" sound plays
- The collected ingredient is added to the truck's inventory (displayed in the UI)
- Maximum inventory capacity: 10 ingredients total (any type)

**Ingredient Types:**
There are five ingredient types, each represented by a distinct 3D-styled icon:
1. Tomato (red)
2. Cheese (yellow-orange)
3. Lettuce (green)
4. Burger Patty (brown)
5. Burger Bun (golden-brown)

### 3.4 Customer Orders & Delivery

**Customer Placement:**
- Customers stand on the left and right sidewalks (never in the lanes)
- They appear at regular intervals (every 5-8 seconds)
- Each customer has a speech bubble above their head showing their order (1-3 ingredient icons)
- Customers remain stationary as they scroll down with the background

**Order Display:**
- Orders are shown as ingredient icons inside a white speech bubble with blue border
- Simple orders early on: one ingredient (e.g., just a tomato)
- Complex orders later: two or three ingredients (e.g., bun + patty + cheese)

**Delivery Mechanic:**
- When the player's truck is in the lane adjacent to a customer (left lane for left-side customers, right lane for right-side customers) AND the truck's Y-position aligns with the customer's Y-position (within a tolerance range of 100 pixels), the order check is triggered
- The game checks if the player has ALL the required ingredients in their inventory
- If YES: The order is delivered automatically
  - The required ingredients are removed from inventory
  - The customer disappears with a happy animation (optional: thumbs up or smile)
  - A cash register "cha-ching" sound plays
  - Points are awarded (base: 100 points per order)
  - Delivery counter increments by 1
  - Visual feedback: coins or stars burst from the customer's location
- If NO: The player passes by the customer without delivering, and the customer scrolls off-screen (no penalty, just missed opportunity)

**Combo System:**
- If the player delivers to two or more customers without missing any in between, a combo counter starts
- Combo multiplier: 1.5x for 2 deliveries, 2x for 3 deliveries, 2.5x for 4+ deliveries
- Combo breaks if a customer is missed or if the player hits an obstacle
- Visual indicator: "COMBO x2!" text appears briefly on screen with color change

### 3.5 Obstacles

**Obstacle Types:**
There are three obstacle types, all appearing randomly in the lanes:
1. **Traffic Cone:** Orange and white striped cone
2. **Pothole:** Dark circular hole with cracked edges
3. **Construction Barrier:** Yellow and black striped wooden barrier

**Obstacle Behavior:**
- Obstacles spawn in lanes at random intervals (every 2-4 seconds)
- Multiple obstacles can appear on screen simultaneously, but never in the same lane at the same time
- They scroll down toward the player at the same speed as other elements

**Collision Effects:**
- When the player's truck collides with an obstacle (rectangular hitbox collision):
  - A "bonk" sound effect plays
  - The truck flashes red briefly (0.1 seconds)
  - The truck's speed is reduced by 20% for 2 seconds
  - A "-20" or "-SPEED" indicator floats up from the collision point
  - No damage or health system - only speed reduction
- Multiple collisions stack the speed reduction penalty (can go down to 40% of normal speed)
- Speed gradually returns to normal after avoiding obstacles for 2 seconds

**Strategic Element:**
- Hitting too many obstacles makes it harder to align with customers for deliveries
- Players must balance ingredient collection with obstacle avoidance

### 3.6 Scoring System

**Points Breakdown:**
- Ingredient collected: +10 points each
- Order delivered: +100 points base
- Combo multiplier: 1.5x, 2x, or 2.5x applied to delivery points
- Distance traveled: +1 point per 10 pixels scrolled

**Star Rating (End of Level):**
- 1 Star: Complete minimum required deliveries
- 2 Stars: Complete 150% of required deliveries
- 3 Stars: Complete 200% of required deliveries + maintain 3x combo or higher

### 3.7 Level Progression

**Level Structure:**
- Each level has a defined length (measured in pixels: starts at 5000 pixels, increases by 1000 each level)
- Required deliveries increase: Level 1 = 5 deliveries, Level 2 = 6, Level 3 = 7, etc.
- Scrolling speed increases slightly each level (5% faster per level, capped at 2x starting speed)
- Obstacle density increases (more frequent spawning)
- Customer orders become more complex (more ingredients required)

**Level Completion:**
- When the player reaches the end of the level distance AND has completed the required deliveries: Level Complete screen appears with star rating
- If distance is reached but deliveries are insufficient: Level Failed screen appears with option to retry

**Progression Flow:**
1. Player completes Level 1
2. Level 2 unlocks automatically
3. Process repeats through all 15 levels
4. After Level 15, Endless Mode unlocks

---

## 4. GAME MODES

### 4.1 Level Mode (Main Mode)

**Description:**
Players progress through 15 handcrafted levels with increasing difficulty. Each level has specific delivery targets and defined lengths.

**Level Specifications:**

| Level | Distance | Deliveries | Speed | Order Complexity | Obstacle Freq | Customer Freq |
|-------|----------|------------|-------|------------------|---------------|---------------|
| 1-3   | 5000px   | 5-7        | 400px/s | 1 ingredient   | 2-4 sec       | 6-8 sec       |
| 4-6   | 6000px   | 7-9        | 440px/s | 1-2 ingredients| 1.8-3.5 sec   | 5.5-7.5 sec   |
| 7-9   | 7000px   | 9-11       | 480px/s | 2 ingredients  | 1.5-3 sec     | 5-7 sec       |
| 10-12 | 8000px   | 11-13      | 520px/s | 2-3 ingredients| 1.2-2.5 sec   | 4.5-6.5 sec   |
| 13-15 | 9000px   | 13-15      | 560px/s | 3 ingredients  | 1-2 sec       | 4-6 sec       |

**Unlocking:**
- Level 1 is unlocked by default
- Each subsequent level unlocks only after completing the previous level (any star rating)
- Players can replay any unlocked level to improve their star rating

### 4.2 Endless Mode

**Description:**
An infinite runner mode where the road never ends, and the goal is to survive as long as possible while maximizing score.

**Mechanics:**
- No level completion - game continues indefinitely
- Speed increases every 30 seconds (5% increment)
- Obstacle density increases every 30 seconds
- No delivery target - score is based purely on deliveries completed and distance traveled
- Game ends only when the player chooses to quit (pause menu → quit)

**Unlocking:**
- Unlocked after completing Level 15
- Always accessible once unlocked

**Leaderboard:**
- Local high score saved on device
- Display: "Your Best: 12,450 points, 2.5km traveled"

---

## 5. USER INTERFACE (UI)

### 5.1 Main Menu Screen

**Layout:**
- Game title at top: "Food Truck Frenzy" in bold, playful font
- Large "PLAY" button in center (starts Level Mode from current progress)
- "ENDLESS" button below (grayed out if not unlocked)
- "SETTINGS" button (gear icon) in top-right corner
- "INFO" button (question mark icon) in top-left corner

**Visual Style:**
- Bright, cheerful background (city street scene)
- Animated food truck in background (subtle idle animation)
- Upbeat background music playing

### 5.2 Level Select Screen

**Layout:**
- Grid of level buttons (3 columns x 5 rows = 15 levels)
- Each button shows:
  - Level number
  - Star rating earned (0-3 stars, grayed if not earned)
  - Lock icon if not yet unlocked
- "BACK" button to return to main menu

**Interaction:**
- Tap any unlocked level to start it
- Tapped locked levels show message: "Complete Level X to unlock"

### 5.3 In-Game HUD (Heads-Up Display)

**Elements Displayed During Gameplay:**

**Top-Left Corner:**
- Score counter with coin icon: "⭐ 1,250"
- Current combo multiplier (if active): "COMBO x2" in pulsing text

**Top-Right Corner:**
- Pause button (⏸️ icon)

**Bottom Center:**
- Ingredient inventory bar showing collected ingredients as small icons (horizontally arranged)
- Shows up to 10 ingredient icons
- Format: 🍅 🧀 🥬 🍔 🍞 (actual icons with quantities if multiples)

**Bottom-Left Corner:**
- Delivery counter: "Deliveries: 3/5"

**Bottom-Right Corner:**
- Progress bar showing distance traveled toward level end (thin horizontal bar)

**Screen Center (Temporary Messages):**
- "PERFECT!" when delivering an order
- "COMBO x2!" when achieving combos
- "-SPEED" when hitting obstacles

### 5.4 Pause Menu

**Triggered by:** Tapping pause button during gameplay

**Layout:**
- Semi-transparent dark overlay over game (game is frozen)
- White modal panel in center with:
  - "PAUSED" header
  - "RESUME" button (continues game)
  - "RESTART" button (restarts current level from beginning)
  - "QUIT" button (returns to main menu, level progress is lost)

### 5.5 Level Complete Screen

**Triggered by:** Successfully completing level delivery target

**Layout:**
- Celebratory background (confetti, stars, bright colors)
- "LEVEL COMPLETE!" header
- Star rating display (1-3 stars earned, animated)
- Score summary:
  - "Deliveries: 8"
  - "Score: 2,450"
  - "New Record!" (if applicable)
- Buttons:
  - "NEXT LEVEL" (primary button, proceeds to next level)
  - "REPLAY" (replay current level)
  - "MENU" (return to main menu)

**Sound:** Victory fanfare plays

### 5.6 Level Failed Screen

**Triggered by:** Reaching level end without completing delivery target

**Layout:**
- Gray/muted background
- "LEVEL FAILED" header
- Failure reason: "Only 3 out of 5 deliveries completed"
- Score display: "Score: 890"
- Buttons:
  - "RETRY" (primary button, restart level)
  - "MENU" (return to main menu)

**Sound:** Gentle "game over" sound (not harsh)

### 5.7 Settings Screen

**Options:**
- **Sound Effects:** Toggle on/off with visual switch
- **Music:** Toggle on/off with visual switch
- **Vibration:** Toggle on/off with visual switch
- **Reset Progress:** Button that asks for confirmation before deleting all save data
- **Credits:** Button leading to credits screen showing developer info

### 5.8 Tutorial/Info Screen

**Content:**
- Simple illustrated guide showing:
  - Swipe left/right to change lanes
  - Collect ingredients (icon examples)
  - Deliver to customers (icon example with speech bubble)
  - Avoid obstacles (icon examples)
- "GOT IT" button to close

**When Shown:**
- Automatically on first game launch
- Accessible anytime from main menu via INFO button

---

## 6. VISUAL DESIGN SPECIFICATIONS

### 6.1 Art Style

**Overall Aesthetic:**
- 3D-styled 2D graphics with isometric or pseudo-3D appearance
- Clean, colorful, cartoon-style rendering
- Similar visual references: Crossy Road, Monument Valley, Clash Royale
- Bright, saturated color palette
- All sprites have black outlines for clarity
- Soft drop shadows under all objects for depth

### 6.2 Color Palette

**Primary Colors:**
- Sky/Background: Light blue (#87CEEB) or gradient to lighter at top
- Road: Dark gray (#424242)
- Lane Lines: White (#FFFFFF)
- Sidewalks: Light gray (#BDBDBD)

**UI Colors:**
- Primary Button: Bright green (#4CAF50)
- Secondary Button: Blue (#2196F3)
- Warning/Negative: Red (#F44336)
- Success/Positive: Gold/Yellow (#FFC107)

**Element Colors:**
- Food Truck: Bright blue (#2196F3) with yellow/orange accents
- Ingredients: Natural food colors (red, yellow, green, brown)
- Obstacles: Orange (#FF6600), yellow (#FFEB3B), dark gray (#616161)

### 6.3 Asset Specifications

**Food Truck:**
- Size: 256x256 pixels
- Format: PNG with transparency
- Style: Isometric 3D-styled with visible depth
- Facing: Toward top-right corner in isometric view
- Details: Serving window, small wheels, windshield

**Ingredients (5 types):**
- Size: 128x128 pixels each
- Format: PNG with transparency
- Style: 3D-rendered appearance with lighting and shadows
- Clear visual distinction between types
- Readable at 64x64 display size

**Customers (3 variations):**
- Can use simple emoji characters: 👔 (business), 👷 (construction), 🎓 (student)
- OR simple geometric avatars (circle head + rectangle body)
- Size: 64x64 pixels if custom sprites
- Must be clearly visible against sidewalk background

**Obstacles (3 types):**
- Size: 64x64 to 128x128 pixels depending on obstacle
- Format: PNG with transparency
- Style: Matching 3D aesthetic of other elements
- Clearly recognizable as hazards

**Order Bubbles:**
- White rounded rectangle with blue border (3px thick)
- Size: Variable based on order complexity (80x60 to 120x80 pixels)
- Contains ingredient icons at 32x32 display size

### 6.4 Animation Requirements

**Truck:**
- Idle: Subtle bounce or wheel rotation (4-6 frame loop, 0.5 seconds)
- Lane Change: Smooth position interpolation (0.2 seconds with ease curve)
- Hit: Red flash overlay (0.1 seconds)

**Ingredients:**
- Idle: Gentle floating/bobbing animation (continuous sine wave)
- Collection: Particle burst effect (yellow sparkles, 8-12 particles radiating outward)

**Customers:**
- Idle: Subtle sway or breathing animation (optional, 2-second loop)
- Order Delivered: Quick jump or thumbs-up gesture (0.3 seconds)

**Obstacles:**
- Static (no animation required)
- On collision: Small shake or impact effect (0.1 seconds)

**Background:**
- Road: Vertical scrolling texture (seamless tile)
- Sidewalks: Vertical scrolling (synchronized with road)
- Buildings (background layer): Slower vertical scroll (parallax effect at 60% speed)

### 6.5 Particle Effects

**Collection Sparkle:**
- 8-12 yellow circular particles
- Emit from collection point
- Radiate outward in random directions
- Fade out over 0.3 seconds
- Size: 4-8 pixels diameter

**Delivery Success:**
- Coin or star icons burst upward from customer
- 5-7 icons
- Float upward while fading
- Duration: 0.5 seconds

**Speed Trail (Optional):**
- Fading motion lines behind truck when moving fast
- Light blue color
- 2-3 lines, fade over 0.2 seconds

---

## 7. AUDIO DESIGN

### 7.1 Sound Effects

**Required SFX:**

| Sound | Type | Mood |
|-------|------|------|
| Ingredient Collection | Bright "pop" or "pling" | Satisfying, rewarding |
| Order Delivery | Cash register "cha-ching" | Celebratory, rewarding |
| Obstacle Hit | Soft "bonk" or "thud" | Gentle warning, not harsh |
| Lane Switch | Soft "whoosh" | Responsive, smooth |
| Combo Achievement | Ascending chime | Exciting, encouraging |
| Button Click/Tap | Light "click" | Responsive, clear |
| Level Complete | Victory fanfare | Triumphant, celebratory |
| Level Failed | Gentle descending tone | Gentle disappointment |

### 7.2 Background Music

| Context | Style | Mood |
|---------|-------|------|
| Main Menu | Upbeat, cheerful, light electronic | Fun, welcoming |
| Gameplay | Energetic but not overwhelming | Focused, encouraging |
| Victory | Short celebratory jingle | Success, achievement |

- All music should loop seamlessly
- Gameplay music should not distract or become annoying with repetition

### 7.3 Audio Settings

**Volume Controls:**
- Sound Effects: On/Off toggle (saved to device)
- Music: On/Off toggle (saved to device)
- Default: Both ON

**Audio Behavior:**
- All audio stops when app goes to background
- Audio resumes when app returns to foreground (if settings are ON)
- Tutorial/settings screens play UI sounds only (no music)

---

## 8. TECHNICAL REQUIREMENTS

### 8.1 Platform Specifications

**Target Platform:**
- Android 6.0 (API level 23) and above
- Phone and tablet support (responsive layout)

**Screen Orientations:**
- Portrait mode only (locked)
- Support for various aspect ratios (16:9, 18:9, 19.5:9, etc.)

**Performance Targets:**
- Minimum 30 FPS (frames per second)
- Target 60 FPS on modern devices
- Smooth animations and transitions
- No lag during lane switching or collision detection

### 8.2 Technology Stack

**Framework:**
- Flutter (latest stable version)
- Flame Engine for 2D game development

**Key Packages/Libraries:**
- flame: Core game engine
- flame_audio: Audio playback
- shared_preferences: Save data persistence
- flutter_svg: Vector graphics (if needed for UI)

### 8.3 File Size & Performance

**Target App Size:**
- APK size: Under 50 MB
- Focus on optimized assets (compressed PNG, efficient audio formats)

**Memory Management:**
- Efficient sprite loading (load only active screen elements)
- Dispose unused assets when switching screens
- No memory leaks during extended gameplay sessions

### 8.4 Save Data & Persistence

**Data to Save (locally on device):**
- Level progression (highest unlocked level)
- Star ratings for each level (0-3 stars)
- High scores for each level
- Endless mode high score
- Settings preferences (sound, music, vibration)

**Save Mechanism:**
- Use SharedPreferences for simple key-value storage
- Save triggers:
  - After completing a level
  - When returning to main menu
  - When closing the app
- Auto-save during pause (prevent progress loss)

**No Cloud/Account System:**
- No user accounts or login required
- No online leaderboards (MVP only has local high scores)
- All data stored locally only

### 8.5 Collision Detection

**Hitbox System:**
- Use rectangular bounding boxes for all collision detection
- Truck hitbox: Slightly smaller than visual sprite (80% of sprite size) for forgiving gameplay
- Ingredient hitbox: Matches sprite size
- Obstacle hitbox: Matches sprite size
- Customer trigger zone: Wide horizontal range (150 pixels) to make deliveries easier

**Collision Checks (every frame):**
- Truck vs. Ingredients (collection check)
- Truck vs. Obstacles (collision check)
- Truck vs. Customer trigger zones (delivery check)

### 8.6 Difficulty Scaling

See **Section 4.1** for level-by-level difficulty parameters.

**Endless Mode Scaling:**
- Every 30 seconds: Increase scroll speed by 5% (cap at 2x starting speed)
- Every 30 seconds: Decrease obstacle spawn interval by 0.1 seconds (cap at 0.5 sec minimum)
- Order complexity increases every 2 minutes (1 → 2 → 3 items, then stays at 3)

---

## 9. USER EXPERIENCE (UX) FLOW

### 9.1 First Launch Experience

**Step 1: App Opens**
- Splash screen with game logo (1-2 seconds)
- Loads to Main Menu

**Step 2: Tutorial Auto-Display**
- Tutorial/Info screen appears automatically
- Shows basic controls and objectives
- Player taps "GOT IT" to dismiss

**Step 3: First Gameplay**
- Player taps "PLAY" button
- Level 1 starts immediately (no level select for first play)
- Gentle difficulty to let player learn

### 9.2 Typical Play Session

**Flow:**
1. Player opens app → Main Menu
2. Taps "PLAY" → Goes to Level Select (or continues from last level)
3. Selects a level → Level starts
4. Plays level (2-5 minutes)
5. Completes or fails level → Result screen
6. Chooses: Next Level, Replay, or Menu
7. Repeats or exits

**Session Length:**
- Expected: 10-20 minutes per session
- Single level: 2-5 minutes
- Players should feel satisfied after completing 2-3 levels

### 9.3 Onboarding & Learning Curve

- **Level 1-3:** Gentle introduction with 1-ingredient orders, low obstacle density, slow speed
- **Level 4+:** Full complexity introduced gradually as players become comfortable
