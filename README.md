# Scramble Reborn

An original, from-scratch recreation of the *look, feel and rules* of a
1978-style side-scrolling cave-shooter (in the spirit of Konami's classic
arcade game *Scramble*), built for Android in Godot 4 / GDScript.

No original ROM data, sprites, sound files or code were used. Every
graphic is generated at runtime from small hand-authored pixel grids
(`scripts/visuals/Sprites.gd`), every sound effect and the background music
loop are synthesised at startup from raw waveforms (`scripts/autoload/SFX.gd`),
and the terrain/enemy layout for each stage is hand-authored data
(`data/stages/*.gd`).

## Requirements

- [Godot Engine 4.3+](https://godotengine.org/) (GDScript, not .NET/C# build)
- Android build template + Android SDK/JDK configured in Godot, if you want
  to export an APK/AAB (see below). Not required to just run the game in
  the editor.

## Running it

1. Open Godot 4.3+, choose **Import**, and select this folder's `project.godot`.
2. Press **F5** (or the Play button). The game boots straight to the title
   screen at the fixed 256x224 logical resolution, scaled to your window.
3. Desktop testing uses the keyboard as a stand-in for touch:
   - Arrow keys / WASD: move (vertical dodge + horizontal thrust)
   - Z / Space / Ctrl: fire
   - X / Alt: drop bomb
   - Escape / P: pause
   - Mouse clicks are automatically treated as touch (see
     `input_devices/pointing/emulate_touch_from_mouse` in `project.godot`),
     so the on-screen joystick/buttons are also clickable with a mouse.

## Controls (device)

- Bottom-left: virtual joystick (or a 4-way D-pad, selectable in Settings) -
  up/down dodges, left/right decelerates/accelerates the scroll speed.
- Bottom-right: **FIRE** (forward gun) and **BOMB** (drops straight down)
  buttons.
- Top-right corner: small pause icon.

## Gameplay notes

- The ship has inertia on both axes rather than instant digital movement,
  matching the era's arcade feel.
- Horizontal thrust doesn't just move the ship on screen - it also scales
  the world's scroll speed, so speeding up/slowing down is a real tactical
  choice (per the "accelerate/decelerate" mechanic in the brief).
- Fuel drains continuously and is shown as a bar in the HUD; bomb a fuel
  tank to refill it. Running out destroys the ship, same as touching
  terrain or an enemy/enemy shot.
- Four hand-authored stages (mountains -> caves -> approach -> base, ending
  with a large rocket to bomb) loop with increasing difficulty
  (`Game.difficulty_multiplier()`), matching classic arcade looping.

## Project layout

```
project.godot            - engine/display/autoload configuration
scenes/Main.tscn          - minimal root scene (everything else is built from code)
scripts/
  Main.gd                 - top-level state orchestration
  autoload/                - singletons: Palette, PixelArt, Controls, SFX, Save, Game
  player/                  - Player, Bullet, Bomb
  enemies/                 - EnemyBase + FlyingEnemy, GroundTurret, FuelTank,
                             RisingMissile, BaseRocket, EnemyProjectile
  terrain/                 - TerrainSystem (heightmap -> collision + rendering)
  level/                   - LevelManager (scroll/spawn/pools), Stages registry
  ui/                      - HUD, TouchControls, TitleScreen, PauseMenu,
                             GameOverScreen, SettingsScreen, StageBanner
  effects/                 - Explosion, generic ObjectPool
  visuals/Sprites.gd       - authored pixel-art grids + palettes
data/stages/               - one file per stage: terrain heightmap + enemy list
```

Almost everything is a plain GDScript class (`class_name`) instantiated in
code rather than a `.tscn` per object; this keeps the project easy to
review as text and avoids hand-maintaining dozens of small scene files.
`data/stages/*.gd` is the one place meant to be tweaked/extended - add a
`Stage5Data.gd` with the same `get_data()` shape and register it in
`scripts/level/Stages.gd` to add a new stage.

## Building an APK

1. In Godot: **Editor > Manage Export Templates** and install the
   templates matching your engine version (or **Editor > Export Templates
   Manager**, download).
2. **Editor > Editor Settings > Export > Android**: point `Android SDK
   Path` at your installed SDK (needs `cmdline-tools`, a platform, and
   `build-tools`), and make sure a JDK 17 is available.
3. **Project > Install Android Build Template...** - required once per
   clone/Godot-version, since `android/build/` is gitignored (it's ~85MB of
   generated Gradle sources). This writes `android/build/` and
   `android/.build_version`.
   - *CLI note:* `godot --headless --install-android-build-template` has
     been unreliable in some 4.7 builds (hangs indefinitely with no
     output). If that happens, do it from the editor UI instead, or
     extract `<export_templates>/android_source.zip` to `android/build/`
     yourself and write `android/.build_version` containing just the
     engine version string (e.g. `4.7.stable`) - that's all the menu
     command does under the hood.
4. Open **Project > Export**. This project already ships an `Android`
   preset in `export_presets.cfg` (package id
   `com.gothamvillage.scramblereborn`, landscape, min SDK 24 / target 34,
   arm64-v8a + x86_64, gradle build). Select it.
5. The first debug export will prompt Godot to generate a debug keystore
   automatically - accept that, or point it at your own in Editor Settings.
6. Click **Export Project**, choose a debug build, and pick an output path
   (defaults to `build/android/ScrambleReborn.apk`, already gitignored).
7. Install with `adb install build/android/ScrambleReborn.apk` or drag it
   onto a device/emulator. Same steps work headless:
   `godot --headless --path . --export-debug "Android" build/android/ScrambleReborn.apk`.

## Building an Android App Bundle (AAB) for Play Store

1. Same setup as above.
2. In the Android preset's export options, set **Gradle Build > Export
   Format** to **App Bundle** (or use **Project > Export > Export
   PCK/ZIP**'s sibling **Export As... > Android App Bundle** entry in
   newer Godot versions - the option lives next to "Export Project").
3. For a release AAB you need a real signing keystore (Play Store does not
   accept the auto-generated debug keystore): create one with
   `keytool -genkey -v -keystore release.keystore -alias scramble -keyalg RSA -keysize 2048 -validity 10000`,
   then set it under the preset's **Keystore** release fields (or Editor
   Settings for a global default) before exporting a **Release** build.
4. Export - Godot/Gradle produces the signed `.aab`, ready to upload to
   the Play Console.

## Display architecture

Gameplay, HUD and every arcade-style screen (title/pause/game over/
settings) render into a fixed 256x224 `SubViewport` so the pixel art stays
crisp and the aspect ratio stays authentic on any device - it's displayed
through a `SubViewportContainer` that Main.gd keeps letterboxed and
centred in the real window. `TouchControls` is the one thing that lives
*outside* that sub-view, positioned as fractions of the actual screen size
in `scripts/ui/TouchControls.gd`, so the joystick/fire/bomb buttons always
land in the true reachable corners of the phone instead of being squeezed
into the same narrow letterboxed strip as the game view.

## Known simplifications

- Text uses Godot's default font with retro colours/outlines rather than a
  bespoke bitmap font, to keep every glyph guaranteed-legible without a
  Godot editor available to visually proof a hand-authored pixel font.
- Forward bullets don't collide with terrain (only with flying enemies);
  bombs do check the ground height each frame. This mirrors how forgiving
  most home ports of the genre are about gunfire vs. terrain.
- A "screen scaling option" beyond the automatic fixed-aspect viewport
  scaling was left out of Settings as it wouldn't add anything the
  automatic letterboxing doesn't already handle.
