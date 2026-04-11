import Cocoa
import MediaPlayer

/// Intercepts media keys (F7/F8/F9) and routes them to our HomePod controls
/// instead of the default Music.app behavior.
@MainActor
final class MediaKeyHandler {
    private var manager: HomePodManager?

    func attach(to manager: HomePodManager) {
        self.manager = manager
        setupNowPlayingCommands()
    }

    /// Uses MPRemoteCommandCenter to intercept media key events.
    /// This makes our app the "now playing" app, so F7/F8/F9 route to us.
    private func setupNowPlayingCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()

        // Play/Pause (F8)
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            Task { @MainActor in
                await self.manager?.playPause()
            }
            return .success
        }

        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            Task { @MainActor in
                await self.manager?.playPause()
            }
            return .success
        }

        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            Task { @MainActor in
                await self.manager?.playPause()
            }
            return .success
        }

        // Next Track (F9)
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            Task { @MainActor in
                await self.manager?.nextTrack()
            }
            return .success
        }

        // Previous Track (F7)
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            Task { @MainActor in
                await self.manager?.previousTrack()
            }
            return .success
        }

        // Update the Now Playing info center so macOS knows we're the active player
        updateNowPlayingInfo()
    }

    /// Updates the system Now Playing info so media keys route to our app
    func updateNowPlayingInfo() {
        guard let manager else { return }
        let nowPlayingInfo = manager.nowPlaying

        var info = [String: Any]()
        info[MPMediaItemPropertyTitle] = nowPlayingInfo.trackName
        info[MPMediaItemPropertyArtist] = nowPlayingInfo.artistName
        info[MPMediaItemPropertyAlbumTitle] = nowPlayingInfo.albumName
        info[MPMediaItemPropertyPlaybackDuration] = nowPlayingInfo.duration
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = nowPlayingInfo.position
        info[MPNowPlayingInfoPropertyPlaybackRate] = nowPlayingInfo.isPlaying ? 1.0 : 0.0

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        MPNowPlayingInfoCenter.default().playbackState = nowPlayingInfo.isPlaying ? .playing : .paused
    }
}
