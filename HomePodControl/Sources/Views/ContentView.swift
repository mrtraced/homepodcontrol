import SwiftUI

enum SourceTab: String, CaseIterable {
    case playlists = "Playlists"
    case radio = "Radio"
}

struct ContentView: View {
    @State private var manager = HomePodManager()
    @State private var selectedTab: SourceTab = .playlists

    var body: some View {
        VStack(spacing: 0) {
            // Device selector
            DevicePickerView(
                devices: manager.availableDevices,
                selectedDevice: manager.selectedDevice,
                isConnected: manager.isConnected,
                onSelect: { device in Task { await manager.selectDevice(device) } },
                onRefresh: { Task { await manager.refreshDevices() } }
            )
            .padding(.top, 12)

            Divider().padding(.horizontal).padding(.top, 8)

            // Now Playing (compact)
            NowPlayingView(
                nowPlaying: manager.nowPlaying,
                artwork: manager.artworkImage,
                onPlayPause: { Task { await manager.playPause() } },
                onNext: { Task { await manager.nextTrack() } },
                onPrevious: { Task { await manager.previousTrack() } },
                onLove: { Task { await manager.toggleLove() } },
                onDislike: { Task { await manager.dislike() } }
            )
            .padding(.top, 8)

            // Volume
            VolumeControlView(
                volume: $manager.nowPlaying.volume,
                onVolumeChange: { vol in Task { await manager.setVolume(vol) } }
            )
            .padding(.top, 4)

            Divider().padding(.horizontal).padding(.top, 8)

            // Source tabs
            Picker("Source", selection: $selectedTab) {
                ForEach(SourceTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 8)

            // Tab content
            if selectedTab == .playlists {
                PlaylistPickerView(
                    playlists: manager.playlists,
                    onSelect: { name in Task { await manager.playPlaylist(name) } }
                )
                .padding(.top, 4)
            } else {
                StationPickerView(
                    stations: RadioStation.appleMusic,
                    currentStation: manager.currentStation,
                    onSelect: { station in Task { await manager.playStation(station) } }
                )
                .padding(.top, 4)
            }

            // Error display
            if let error = manager.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
                    .padding(.bottom, 4)
                    .lineLimit(2)
            }
        }
        .frame(width: 340, height: 640)
        .onAppear { manager.startPolling() }
        .onDisappear { manager.stopPolling() }
    }
}
