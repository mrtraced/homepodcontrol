import Foundation
import SwiftUI

/// Central manager — simplified to just play a playlist on a HomePod.
@MainActor
@Observable
final class HomePodManager {
    // MARK: - State

    var nowPlaying: NowPlayingInfo = .empty
    var selectedDevice: HomePodDevice?
    var availableDevices: [HomePodDevice] = []
    var currentStation: RadioStation?
    var isConnected: Bool = false
    var errorMessage: String?
    var artworkImage: NSImage?
    var playlists: [String] = []

    // MARK: - Private

    private let bridge = MusicBridge.shared
    private var pollTimer: Timer?
    private let deviceKey = "selectedHomePodDevice"
    private var lastArtworkTrack: String = ""

    init() {
        loadSavedDevice()
    }

    // MARK: - Device Management

    func refreshDevices() async {
        do {
            let devices = try await bridge.getAirPlayDevices()
            self.availableDevices = devices
            if let saved = selectedDevice {
                self.isConnected = devices.contains(where: { $0.name == saved.name })
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func selectDevice(_ device: HomePodDevice) async {
        self.selectedDevice = device
        self.isConnected = true
        self.errorMessage = nil
        saveDevice(device)

        // Route audio to device
        do {
            try await bridge.selectAirPlayDevice(named: device.name)
        } catch {
            // OK if fails — will route when playback starts
        }
        await refreshVolume()
    }

    // MARK: - Playback

    func playFavorites() async {
        guard let device = selectedDevice else {
            self.errorMessage = "Select a device first"
            return
        }
        do {
            try await bridge.playPlaylist(named: "Favorite Songs", onDevice: device.name)
            self.errorMessage = nil
            try? await Task.sleep(for: .seconds(1))
            await refreshNowPlaying()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func playPlaylist(_ name: String) async {
        guard let device = selectedDevice else {
            self.errorMessage = "Select a device first"
            return
        }
        do {
            self.currentStation = nil
            try await bridge.playPlaylist(named: name, onDevice: device.name)
            self.errorMessage = nil
            try? await Task.sleep(for: .seconds(1))
            await refreshNowPlaying()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func playStation(_ station: RadioStation) async {
        guard let device = selectedDevice else {
            self.errorMessage = "Select a device first"
            return
        }
        do {
            self.currentStation = station
            try await bridge.playRadioStation(url: station.musicURL, onDevice: device.name)
            self.errorMessage = nil
            try? await Task.sleep(for: .seconds(3))
            await refreshNowPlaying()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func playPause() async {
        do {
            try await bridge.togglePlayPause()
            try? await Task.sleep(for: .milliseconds(300))
            await refreshNowPlaying()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func nextTrack() async {
        do {
            try await bridge.nextTrack()
            try? await Task.sleep(for: .milliseconds(500))
            await refreshNowPlaying()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func previousTrack() async {
        do {
            try await bridge.previousTrack()
            try? await Task.sleep(for: .milliseconds(500))
            await refreshNowPlaying()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - Volume

    func setVolume(_ volume: Double) async {
        guard let device = selectedDevice else { return }
        do {
            try await bridge.setDeviceVolume(named: device.name, volume: Int(volume * 100))
            self.nowPlaying.volume = volume
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func refreshVolume() async {
        guard let device = selectedDevice else { return }
        do {
            let vol = try await bridge.getDeviceVolume(named: device.name)
            self.nowPlaying.volume = Double(vol) / 100.0
        } catch {
            // OK — volume read can fail if device isn't active
        }
    }

    // MARK: - Love / Dislike

    func toggleLove() async {
        do {
            try await bridge.toggleLoveCurrentTrack()
            // Wait for Apple Music to sync the change, then re-read actual state
            try? await Task.sleep(for: .seconds(1))
            await refreshNowPlaying()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func addToLibrary() async {
        do {
            try await bridge.addCurrentTrackToLibrary()
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func dislike() async {
        do {
            try await bridge.dislikeCurrentTrack()
            try? await Task.sleep(for: .milliseconds(200))
            try await bridge.nextTrack()
            try? await Task.sleep(for: .milliseconds(500))
            await refreshNowPlaying()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - Playlists

    func refreshPlaylists() async {
        do {
            self.playlists = try await bridge.getPlaylists()
        } catch {
            // Best effort
        }
    }

    // MARK: - Polling

    func startPolling() {
        stopPolling()
        pollTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                await self.refreshNowPlaying()
            }
        }
        Task {
            await refreshNowPlaying()
            await refreshDevices()
            await refreshPlaylists()
        }
    }

    func stopPolling() {
        pollTimer?.invalidate()
        pollTimer = nil
    }

    func refreshNowPlaying() async {
        do {
            var info = try await bridge.getNowPlayingInfo()
            info.volume = nowPlaying.volume

            // Fetch artwork only when track changes
            if info.trackName != "Not Playing" && info.trackName != lastArtworkTrack {
                lastArtworkTrack = info.trackName
                self.nowPlaying = info
                await refreshArtwork()
            } else if info.trackName == "Not Playing" {
                lastArtworkTrack = ""
                self.artworkImage = nil
            }

            self.nowPlaying = info
            self.errorMessage = nil
        } catch {
            self.errorMessage = "Now playing: \(error.localizedDescription)"
        }
    }

    private func refreshArtwork() async {
        do {
            if let data = try await bridge.getCurrentArtwork() {
                self.artworkImage = NSImage(data: data)
            }
        } catch {
            // Best effort
        }
    }

    // MARK: - Persistence

    private func saveDevice(_ device: HomePodDevice) {
        if let data = try? JSONEncoder().encode(device) {
            UserDefaults.standard.set(data, forKey: deviceKey)
        }
    }

    private func loadSavedDevice() {
        if let data = UserDefaults.standard.data(forKey: deviceKey),
           let device = try? JSONDecoder().decode(HomePodDevice.self, from: data) {
            self.selectedDevice = device
        }
    }
}
