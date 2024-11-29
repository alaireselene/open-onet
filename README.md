# open-onet
Onet (连连看), written in C# and Godot

Designing a **modular project structure** from the beginning is essential for future extensibility, especially for features like multiplayer, custom maps, or levels. Below is a standard **folder structure** for your **Onet clone project in Godot**, designed with modularity and scalability in mind:

---

### **Proposed Project Structure**

```plaintext
OnetClone/
├── addons/               # For Godot plugins or custom tools (optional)
├── assets/               # Game assets: images, sounds, fonts, etc.
│   ├── images/           # Tile textures, UI elements, backgrounds
│   ├── audio/            # Background music, sound effects
│   ├── fonts/            # Fonts used in UI
│   ├── maps/             # Map files (e.g., JSON, custom formats)
├── scenes/               # Scene files for game levels and UI
│   ├── main_menu/        # Main menu UI
│   ├── levels/           # Game levels (e.g., Level1.tscn, Level2.tscn)
│   ├── multiplayer/      # Scenes specific to multiplayer mode
│   └── templates/        # Scene templates for easy reuse
├── scripts/              # C# scripts for game logic
│   ├── core/             # Core systems (game manager, data manager, etc.)
│   ├── ui/               # Scripts for UI elements
│   ├── gameplay/         # Gameplay mechanics (e.g., tile matching, scoring)
│   ├── multiplayer/      # Multiplayer-specific logic
│   └── utils/            # Utility functions and helper classes
├── data/                 # Data files (maps, levels, config, etc.)
│   ├── config.json       # Game configuration (e.g., tile settings, rules)
│   ├── levels/           # Level-specific data
│   └── multiplayer/      # Multiplayer-specific data (if needed)
├── docs/                 # Documentation for the project
│   ├── design_doc.md     # Game design document
│   ├── api_reference.md  # Reference for important systems
├── tests/                # Unit tests or debugging scenes
├── project.godot         # Godot project file
├── .gitignore            # Files to ignore in Git
└── README.md             # Overview of the project
```

---

### **Key Design Principles**

#### **1. Separation of Concerns**
- Each folder serves a specific purpose, making it easy to navigate and modify.
- Core systems and game logic (like tile matching) are isolated from UI or multiplayer logic.

#### **2. Modularity**
- All components (e.g., levels, maps) are designed to be **plug-and-play**.
- Example: Custom maps can be stored as JSON files in the `data/maps/` folder, loaded dynamically.

#### **3. Scalability**
- Adding new features (e.g., online multiplayer) doesn’t disrupt the existing structure.
- Multiplayer scenes and logic are already separated into `multiplayer/`.

#### **4. Reusability**
- Templates and utility scripts allow for easy creation of new content without duplicating code.

---

### **Folder Details**

| Folder/Section         | Purpose                                                                 |
|-------------------------|-------------------------------------------------------------------------|
| **addons/**            | For optional Godot tools or plugins to improve productivity.           |
| **assets/**            | All static assets used in the game (organized by type).                |
| **scenes/**            | Game and UI scenes organized for clarity and reuse.                    |
| **scripts/core/**      | Core systems like GameManager, InputManager, and SaveManager.          |
| **scripts/ui/**        | Scripts for UI logic (e.g., menus, buttons, score display).            |
| **scripts/gameplay/**  | Core gameplay logic like matching tiles, timers, and level transitions.|
| **scripts/utils/**     | Helper scripts (e.g., math utilities, data parsing).                   |
| **data/**              | Game configuration, level data, and custom map files.                 |
| **docs/**              | Documentation to make future development easier for the team.          |
| **tests/**             | Debugging and testing for new mechanics or features.                   |

---

### **Important Classes to Plan**
1. **GameManager (core):**
   - Handles the overall game flow (e.g., state transitions between main menu, levels, multiplayer).
   - Example: Starting a new game, restarting, or transitioning to the next level.

2. **LevelManager (gameplay):**
   - Handles level-specific logic like generating the grid of tiles and loading custom maps.

3. **TileManager (gameplay):**
   - Controls the behavior of individual tiles and their matching rules.

4. **MultiplayerManager (multiplayer):**
   - Manages player connections, game synchronization, and real-time communication.

5. **UIManager (ui):**
   - Handles UI interactions, such as button clicks, score updates, and pause menus.

6. **DataManager (utils):**
   - Loads and saves game data (e.g., player progress, settings, custom maps).

---

### **Extending the Project**
To add future features:
1. **Custom Maps:**
   - Store map configurations in `data/maps/` as JSON files. Example schema:
	 ```json
	 {
	   "rows": 8,
	   "cols": 8,
	   "tiles": [
		 [1, 2, 3, 4, 1],
		 [2, 3, 4, 1, 2]
	   ]
	 }
	 ```

2. **Multiplayer:**
   - Add multiplayer-specific logic and data handling in the `scripts/multiplayer/` and `scenes/multiplayer/` folders.

3. **Custom Levels:**
   - Create new `.tscn` files in `scenes/levels/` and load them dynamically based on user selection.

---

### **Next Steps**
1. **Set up the folder structure in your GitHub repository.**
2. **Create the basic `GameManager` class to define the game’s flow.**
3. Let me know when you’re ready to discuss a specific feature (e.g., tile-matching logic).