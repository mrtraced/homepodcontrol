import SwiftUI

struct NowPlayingView: View {
    let nowPlaying: NowPlayingInfo
    let artwork: NSImage?
    let onPlayPause: () -> Void
    let onNext: () -> Void
    let onPrevious: () -> Void
    let onLove: () -> Void
    let onDislike: () -> Void
    let onAddToLibrary: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            // Artwork + track info side by side for compact layout
            HStack(spacing: 14) {
                // Artwork
                artworkView
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: .black.opacity(0.2), radius: 4, y: 2)

                // Track Info
                VStack(alignment: .leading, spacing: 3) {
                    Text(nowPlaying.trackName)
                        .font(.system(.headline, design: .rounded))
                        .lineLimit(2)
                        .foregroundStyle(.primary)

                    Text(nowPlaying.artistName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    if !nowPlaying.albumName.isEmpty {
                        Text(nowPlaying.albumName)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Add to Library
                if nowPlaying.trackName != "Not Playing" {
                    Button(action: onAddToLibrary) {
                        Image(systemName: "plus.circle")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Add to Library")
                }
            }
            .padding(.horizontal)

            // Progress bar
            if nowPlaying.duration > 0 {
                VStack(spacing: 2) {
                    ProgressView(value: nowPlaying.position, total: nowPlaying.duration)
                        .tint(.accentColor)
                    HStack {
                        Text(formatTime(nowPlaying.position))
                        Spacer()
                        Text("-\(formatTime(nowPlaying.duration - nowPlaying.position))")
                    }
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.tertiary)
                }
                .padding(.horizontal)
            }

            // Playback Controls
            HStack(spacing: 20) {
                // Dislike
                Button(action: onDislike) {
                    Image(systemName: "hand.thumbsdown")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
                .help("Dislike & Skip")

                Spacer()

                // Previous
                Button(action: onPrevious) {
                    Image(systemName: "backward.fill")
                        .font(.title3)
                }
                .buttonStyle(.plain)

                // Play/Pause
                Button(action: onPlayPause) {
                    Image(systemName: nowPlaying.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 40))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.space, modifiers: [])

                // Next
                Button(action: onNext) {
                    Image(systemName: "forward.fill")
                        .font(.title3)
                }
                .buttonStyle(.plain)

                Spacer()

                // Favorite (star)
                Button(action: onLove) {
                    Image(systemName: nowPlaying.isLoved ? "star.fill" : "star")
                        .font(.body)
                        .foregroundStyle(nowPlaying.isLoved ? .yellow : .secondary)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
                .help(nowPlaying.isLoved ? "Remove from Favorites" : "Add to Favorites")
            }
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private var artworkView: some View {
        if let artwork {
            Image(nsImage: artwork)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [.purple.opacity(0.3), .blue.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: "music.note")
                    .font(.system(size: 28))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
