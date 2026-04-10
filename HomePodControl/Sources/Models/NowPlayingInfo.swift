import Foundation
import SwiftUI

struct NowPlayingInfo: Equatable {
    var trackName: String
    var artistName: String
    var albumName: String
    var isPlaying: Bool
    var volume: Double
    var isLoved: Bool
    var artworkData: Data?
    var duration: Double
    var position: Double

    static let empty = NowPlayingInfo(
        trackName: "Not Playing",
        artistName: "",
        albumName: "",
        isPlaying: false,
        volume: 0.5,
        isLoved: false,
        artworkData: nil,
        duration: 0,
        position: 0
    )
}
