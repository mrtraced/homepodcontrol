# HomePod Control — Roadmap

## v0.5 ✅
- AirPlay device discovery & selection (persisted)
- Play Favorite Songs playlist on HomePod
- Now playing: track, artist, album, artwork
- Playback controls: play/pause, skip, previous
- Favorite (star) toggle
- Volume slider

## v0.6 ✅
- Searchable playlist picker (138+ playlists)
- Radio stations (Apple Music 1, Hits, Country, Chill)
- Tabbed Playlists / Radio UI
- Star icon (matches Music.app Tahoe)
- Fixed radio station switching
- Fixed favorite sync delay

## Phase 2
- **Custom Speaker Sets** — name a group of AirPlay devices (e.g. "Whole House" = Black Pod + White Pod + Kitchen TV), activate all with one tap. Never been done before — currently requires manually checking each device in AirPlay menu.
  - Create/edit/delete sets
  - Persist sets across launches
  - One-tap activate a set (routes audio to all devices in the set)
  - Volume control per-device within a set
- **Keyboard shortcuts** — space for play/pause, arrows for skip, +/- for volume
- **Menu bar mode** — always-accessible popover
- **Type-to-Siri for HomePod**
- **More verified radio stations** — find and verify IDs for genre stations (Hip-Hop, Rock, Pop, Classical, R&B, Electronic)
- **Fix play button disappearing on window focus loss**

## Phase 3
- **macOS Desktop Widget — Radio Quick Play**
  - Widget configuration: pick a HomePod (or custom set) + a station
  - Single click: starts playing that station on that device/set
  - Click again: pauses
  - Multiple widget instances for different combos (e.g. "Kitchen Morning Chill", "Office Apple Music 1")
- **Desktop Widget — Now Playing**
  - Shows current track, artist, artwork
  - Mini controls (play/pause, skip)
