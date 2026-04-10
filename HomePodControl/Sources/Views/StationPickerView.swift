import SwiftUI

struct StationPickerView: View {
    let stations: [RadioStation]
    let currentStation: RadioStation?
    let onSelect: (RadioStation) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Radio Stations")
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(stations) { station in
                        StationCard(
                            station: station,
                            isSelected: station.id == currentStation?.id,
                            onSelect: { onSelect(station) }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct StationCard: View {
    let station: RadioStation
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.secondary.opacity(0.1))
                        .frame(width: 64, height: 64)

                    Image(systemName: station.artworkSystemImage)
                        .font(.title2)
                        .foregroundStyle(isSelected ? Color.accentColor : .secondary)
                }

                Text(station.name)
                    .font(.caption2)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: 70)
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
        }
        .buttonStyle(.plain)
        .help(station.description)
    }
}
