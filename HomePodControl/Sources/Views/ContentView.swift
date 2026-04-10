import SwiftUI

struct ContentView: View {
    @State private var manager = HomePodManager()

    var body: some View {
        VStack(spacing: 16) {
            // Device selector
            DevicePickerView(
                devices: manager.availableDevices,
                selectedDevice: manager.selectedDevice,
                isConnected: manager.isConnected,
                onSelect: { device in Task { await manager.selectDevice(device) } },
                onRefresh: { Task { await manager.refreshDevices() } }
            )

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

            // Volume
            VolumeControlView(
                volume: $manager.nowPlaying.volume,
                onVolumeChange: { vol in Task { await manager.setVolume(vol) } }
            )

            Divider().padding(.horizontal)

            // Quick play button
            Button {
                Task { await manager.playFavorites() }
            } label: {
                Label("Play Favorite Songs", systemImage: "heart.fill")
                    .frame(maxWidth: .infinity)
            }
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)

            // Error display
            if let error = manager.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(.vertical)
        .frame(width: 340, height: 520)
        .onAppear { manager.startPolling() }
        .onDisappear { manager.stopPolling() }
    }
}
