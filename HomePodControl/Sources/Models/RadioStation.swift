import Foundation

struct RadioStation: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let artworkSystemImage: String

    static let appleMusic: [RadioStation] = [
        RadioStation(
            id: "apple-music-1",
            name: "Apple Music 1",
            description: "The new music that matters",
            artworkSystemImage: "radio"
        ),
        RadioStation(
            id: "apple-music-hits",
            name: "Apple Music Hits",
            description: "Songs you know and love",
            artworkSystemImage: "star.circle"
        ),
        RadioStation(
            id: "apple-music-country",
            name: "Apple Music Country",
            description: "Where it sounds like home",
            artworkSystemImage: "guitars"
        ),
        RadioStation(
            id: "apple-music-chill",
            name: "Chill",
            description: "Music to unwind to",
            artworkSystemImage: "leaf"
        ),
        RadioStation(
            id: "apple-music-classical",
            name: "Classical",
            description: "From icons to icons in the making",
            artworkSystemImage: "music.note"
        ),
        RadioStation(
            id: "apple-music-jazz",
            name: "Jazz",
            description: "Jazz for every mood",
            artworkSystemImage: "music.quarternote.3"
        ),
        RadioStation(
            id: "apple-music-electronic",
            name: "Electronic",
            description: "Electronic music from every angle",
            artworkSystemImage: "waveform"
        ),
        RadioStation(
            id: "apple-music-hip-hop",
            name: "Hip-Hop",
            description: "Where hip-hop lives",
            artworkSystemImage: "mic"
        ),
        RadioStation(
            id: "apple-music-rock",
            name: "Rock",
            description: "Rock in all its forms",
            artworkSystemImage: "bolt"
        ),
        RadioStation(
            id: "apple-music-pop",
            name: "Pop",
            description: "Today's biggest pop hits",
            artworkSystemImage: "sparkles"
        ),
    ]
}
