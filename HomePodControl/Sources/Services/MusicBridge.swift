import Foundation

/// Bridges to Music.app via AppleScript for HomePod-specific control.
actor MusicBridge {
    static let shared = MusicBridge()

    private init() {}

    // MARK: - AirPlay Device Discovery

    func getAirPlayDevices() async throws -> [HomePodDevice] {
        let script = """
        tell application "Music"
            set output to ""
            repeat with d in AirPlay devices
                set output to output & name of d & "||" & kind of d & linefeed
            end repeat
            return output
        end tell
        """
        let result = try await runAppleScript(script)
        let trimmed = result.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        return trimmed.components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .compactMap { line in
                let parts = line.components(separatedBy: "||")
                let name = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
                guard !name.isEmpty else { return nil }
                let kind = parts.count > 1 ? parts[1].trimmingCharacters(in: .whitespacesAndNewlines) : ""
                return HomePodDevice(name: name, kind: kind)
            }
    }

    /// Routes audio to a specific AirPlay device
    func selectAirPlayDevice(named deviceName: String) async throws {
        let escaped = escapeForAppleScript(deviceName)
        let script = """
        tell application "Music"
            set targetDevice to AirPlay device "\(escaped)"
            set current AirPlay devices to {targetDevice}
        end tell
        """
        try await runAppleScript(script)
    }

    // MARK: - Volume

    func getDeviceVolume(named deviceName: String) async throws -> Int {
        let escaped = escapeForAppleScript(deviceName)
        let script = """
        tell application "Music"
            return sound volume of AirPlay device "\(escaped)"
        end tell
        """
        let result = try await runAppleScript(script)
        return Int(result.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 50
    }

    func setDeviceVolume(named deviceName: String, volume: Int) async throws {
        let clamped = max(0, min(100, volume))
        let escaped = escapeForAppleScript(deviceName)
        let script = """
        tell application "Music"
            set sound volume of AirPlay device "\(escaped)" to \(clamped)
        end tell
        """
        try await runAppleScript(script)
    }

    // MARK: - Playback

    func playPlaylist(named name: String, onDevice deviceName: String) async throws {
        let escapedDevice = escapeForAppleScript(deviceName)
        let escapedPlaylist = escapeForAppleScript(name)
        let script = """
        tell application "Music"
            set targetDevice to AirPlay device "\(escapedDevice)"
            set current AirPlay devices to {targetDevice}
            play playlist "\(escapedPlaylist)"
        end tell
        """
        try await runAppleScript(script)
    }

    func togglePlayPause() async throws {
        try await runAppleScript("tell application \"Music\" to playpause")
    }

    func nextTrack() async throws {
        try await runAppleScript("tell application \"Music\" to next track")
    }

    func previousTrack() async throws {
        try await runAppleScript("tell application \"Music\" to previous track")
    }

    // MARK: - Now Playing

    func getNowPlayingInfo() async throws -> NowPlayingInfo {
        let script = """
        tell application "Music"
            if player state is not stopped then
                set trackName to name of current track
                set artistName to artist of current track
                set albumName to album of current track
                set isFav to false
                try
                    set isFav to favorited of current track
                end try
                set trackDuration to duration of current track
                set trackPosition to player position
                set pState to player state
                if pState is playing then
                    set isPlaying to "true"
                else
                    set isPlaying to "false"
                end if
                return trackName & "||" & artistName & "||" & albumName & "||" & isFav & "||" & trackDuration & "||" & trackPosition & "||" & isPlaying
            else
                return "NOT_PLAYING"
            end if
        end tell
        """
        let result = try await runAppleScript(script)
        let trimmed = result.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed == "NOT_PLAYING" || trimmed.isEmpty {
            return .empty
        }

        let parts = trimmed.components(separatedBy: "||")
        guard parts.count >= 7 else { return .empty }

        return NowPlayingInfo(
            trackName: parts[0],
            artistName: parts[1],
            albumName: parts[2],
            isPlaying: parts[6] == "true",
            volume: 0.5,
            isLoved: parts[3] == "true",
            artworkData: nil,
            duration: Double(parts[4]) ?? 0,
            position: Double(parts[5]) ?? 0
        )
    }

    func getCurrentArtwork() async throws -> Data? {
        let tmpPath = NSTemporaryDirectory() + "homepod_artwork.jpg"
        let script = """
        tell application "Music"
            if player state is not stopped then
                try
                    if (count of artworks of current track) > 0 then
                        set artData to raw data of artwork 1 of current track
                        set filePath to POSIX file "\(tmpPath)"
                        set fileRef to open for access filePath with write permission
                        set eof fileRef to 0
                        write artData to fileRef
                        close access fileRef
                        return "OK"
                    end if
                on error
                    try
                        close access filePath
                    end try
                end try
            end if
            return "NONE"
        end tell
        """
        let result = try await runAppleScript(script)
        if result.trimmingCharacters(in: .whitespacesAndNewlines) == "OK" {
            return try? Data(contentsOf: URL(fileURLWithPath: tmpPath))
        }
        return nil
    }

    // MARK: - Love / Dislike

    func toggleLoveCurrentTrack() async throws {
        try await runAppleScript("""
        tell application "Music"
            set favorited of current track to not (favorited of current track)
        end tell
        """)
    }

    func dislikeCurrentTrack() async throws {
        try await runAppleScript("""
        tell application "Music"
            set disliked of current track to true
        end tell
        """)
    }

    // MARK: - Playlists

    func getPlaylists() async throws -> [String] {
        let script = """
        tell application "Music"
            set output to ""
            repeat with p in user playlists
                set k to special kind of p as string
                if k is "none" then
                    set output to output & name of p & linefeed
                end if
            end repeat
            return output
        end tell
        """
        let result = try await runAppleScript(script)
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    // MARK: - Radio Stations

    /// Plays a radio station via the music:// URL scheme
    func playRadioStation(url: String, onDevice deviceName: String) async throws {
        let escapedDevice = escapeForAppleScript(deviceName)
        let script = """
        tell application "Music"
            stop
            delay 0.5
            set targetDevice to AirPlay device "\(escapedDevice)"
            set current AirPlay devices to {targetDevice}
            open location "\(url)"
            delay 3
            play
        end tell
        """
        try await runAppleScript(script)
    }

    // MARK: - Script Execution

    @discardableResult
    private func runAppleScript(_ source: String) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let script = NSAppleScript(source: source)
                var error: NSDictionary?
                let result = script?.executeAndReturnError(&error)

                if let error = error {
                    let message = error[NSAppleScript.errorMessage] as? String ?? "Unknown AppleScript error"
                    continuation.resume(throwing: MusicBridgeError.scriptError(message))
                } else {
                    continuation.resume(returning: result?.stringValue ?? "")
                }
            }
        }
    }

    private func escapeForAppleScript(_ str: String) -> String {
        str.replacingOccurrences(of: "\\", with: "\\\\")
           .replacingOccurrences(of: "\"", with: "\\\"")
    }
}

enum MusicBridgeError: LocalizedError {
    case scriptError(String)

    var errorDescription: String? {
        switch self {
        case .scriptError(let message): return "Music.app: \(message)"
        }
    }
}
