import Foundation

struct RadioStation: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let artworkSystemImage: String
    let musicURL: String

    static let appleMusic: [RadioStation] = [
        // Live radio stations (verified working)
        RadioStation(
            id: "ra.978194965",
            name: "Apple Music 1",
            description: "The new music that matters",
            artworkSystemImage: "radio",
            musicURL: "music://music.apple.com/us/station/apple-music-1/ra.978194965"
        ),
        RadioStation(
            id: "ra.1498155548",
            name: "Apple Music Hits",
            description: "Songs you know and love",
            artworkSystemImage: "star.circle",
            musicURL: "music://music.apple.com/us/station/apple-music-hits/ra.1498155548"
        ),
        RadioStation(
            id: "ra.1498157166",
            name: "Apple Music Country",
            description: "Where it sounds like home",
            artworkSystemImage: "guitars",
            musicURL: "music://music.apple.com/us/station/apple-music-country/ra.1498157166"
        ),
        RadioStation(
            id: "ra.1740614260",
            name: "Apple Music Chill",
            description: "Music to unwind to",
            artworkSystemImage: "leaf",
            musicURL: "music://music.apple.com/us/station/apple-music-chill/ra.1740614260"
        ),
    ]
}
