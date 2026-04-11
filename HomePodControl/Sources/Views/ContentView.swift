import SwiftUI

enum SourceTab: String, CaseIterable {
    case playlists = "Playlists"
    case radio = "Radio"
}

struct ContentView: View {
    @State private var manager = HomePodManager()
    @State private var selectedTab: SourceTab = .playlists
    private let mediaKeyHandler = MediaKeyHandler()

    var body: some View {
        VStack(spacing: 0) {
            // Header with device selector
            DevicePickerView(
                devices: manager.availableDevices,
                selectedDevice: manager.selectedDevice,
                isConnected: manager.isConnected,
                onSelect: { device in Task { await manager.selectDevice(device) } },
                onRefresh: { Task { await manager.refreshDevices() } }
            )
            .padding(.top, 10)
            .padding(.bottom, 6)

            Divider().padding(.horizontal)

            // Now Playing
            NowPlayingView(
                nowPlaying: manager.nowPlaying,
                artwork: manager.artworkImage,
                onPlayPause: { Task { await manager.playPause() } },
                onNext: { Task { await manager.nextTrack() } },
                onPrevious: { Task { await manager.previousTrack() } },
                onLove: { Task { await manager.toggleLove() } },
                onDislike: { Task { await manager.dislike() } }
            )
            .padding(.vertical, 10)

            // Volume
            VolumeControlView(
                volume: $manager.nowPlaying.volume,
                onVolumeChange: { vol in Task { await manager.setVolume(vol) } }
            )

            Divider().padding(.horizontal).padding(.top, 6)

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

            // Footer
            HStack {
                // Error display
                if let error = manager.errorMessage {
                    Text(error)
                        .font(.caption2)
                        .foregroundStyle(.red)
                        .lineLimit(1)
                }
                Spacer()
                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    Image(systemName: "power")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help("Quit HomePod Control")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .frame(width: 340, height: 580)
        .onAppear {
            manager.startPolling()
            mediaKeyHandler.attach(to: manager)
        }
        .onDisappear { manager.stopPolling() }
        .onChange(of: manager.nowPlaying) {
            mediaKeyHandler.updateNowPlayingInfo()
        }
    }
}
