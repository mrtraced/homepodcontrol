import SwiftUI

struct NowPlayingView: View {
    let nowPlaying: NowPlayingInfo
    let artwork: NSImage?
    let onPlayPause: () -> Void
    let onNext: () -> Void
    let onPrevious: () -> Void
    let onLove: () -> Void
    let onDislike: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Artwork
            artworkView
                .frame(width: 200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.3), radius: 8, y: 4)

            // Track Info
            VStack(spacing: 4) {
                Text(nowPlaying.trackName)
                    .font(.headline)
                    .lineLimit(1)
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
            .frame(maxWidth: .infinity)

            // Progress bar (read-only for now)
            if nowPlaying.duration > 0 {
                ProgressView(value: nowPlaying.position, total: nowPlaying.duration)
                    .tint(.accentColor)
                    .padding(.horizontal)
            }

            // Playback Controls
            HStack(spacing: 24) {
                // Dislike
                Button(action: onDislike) {
                    Image(systemName: "hand.thumbsdown")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help("Dislike & Skip")

                // Previous
                Button(action: onPrevious) {
                    Image(systemName: "backward.fill")
                        .font(.title2)
                }
                .buttonStyle(.plain)

                // Play/Pause
                Button(action: onPlayPause) {
                    Image(systemName: nowPlaying.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                        .symbolRenderingMode(.hierarchical)
                }
                .buttonStyle(.plain)

                // Next
                Button(action: onNext) {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                }
                .buttonStyle(.plain)

                // Love
                Button(action: onLove) {
                    Image(systemName: nowPlaying.isLoved ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundStyle(nowPlaying.isLoved ? .red : .secondary)
                }
                .buttonStyle(.plain)
                .help(nowPlaying.isLoved ? "Remove from Loved" : "Love this track")
            }
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
                RoundedRectangle(cornerRadius: 12)
                    .fill(.quaternary)
                Image(systemName: "music.note")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
            }
        }
    }
}
