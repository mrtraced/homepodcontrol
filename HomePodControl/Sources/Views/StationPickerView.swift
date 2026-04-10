import SwiftUI

struct StationPickerView: View {
    let stations: [RadioStation]
    let currentStation: RadioStation?
    let onSelect: (RadioStation) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 2) {
                ForEach(stations) { station in
                    Button {
                        onSelect(station)
                    } label: {
                        HStack(spacing: 10) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(station.id == currentStation?.id
                                          ? Color.accentColor.opacity(0.2)
                                          : Color.secondary.opacity(0.1))
                                    .frame(width: 32, height: 32)
                                Image(systemName: station.artworkSystemImage)
                                    .font(.caption)
                                    .foregroundStyle(station.id == currentStation?.id
                                                     ? Color.accentColor
                                                     : .secondary)
                            }

                            VStack(alignment: .leading, spacing: 1) {
                                Text(station.name)
                                    .font(.subheadline)
                                    .fontWeight(station.id == currentStation?.id ? .semibold : .regular)
                                Text(station.description)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }

                            Spacer()

                            if station.id == currentStation?.id {
                                Image(systemName: "waveform")
                                    .font(.caption)
                                    .foregroundStyle(Color.accentColor)
                            } else {
                                Image(systemName: "play.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
        }
    }
}
