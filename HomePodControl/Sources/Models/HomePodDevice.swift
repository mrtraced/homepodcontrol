import Foundation

struct HomePodDevice: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let kind: String  // "computer", "HomePod", "Apple TV", "AirPlay device", "TV"

    init(id: String? = nil, name: String, kind: String = "") {
        self.id = id ?? UUID().uuidString
        self.name = name
        self.kind = kind
    }

    var isHomePod: Bool {
        kind.lowercased().contains("homepod")
    }

    var iconName: String {
        switch kind.lowercased() {
        case let k where k.contains("homepod"): return "homepod.fill"
        case "computer": return "desktopcomputer"
        case let k where k.contains("apple tv"): return "appletv.fill"
        case let k where k.contains("tv"): return "tv"
        default: return "airplayaudio"
        }
    }
}
