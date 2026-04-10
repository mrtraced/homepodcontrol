import SwiftUI

struct PlaylistPickerView: View {
    let playlists: [String]
    let onSelect: (String) -> Void
    @State private var searchText = ""

    private var filtered: [String] {
        if searchText.isEmpty { return playlists }
        return playlists.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(spacing: 8) {
            // Search bar
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .font(.caption)
                TextField("Search playlists…", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.subheadline)
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(6)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
            .padding(.horizontal)

            // Playlist list
            ScrollView {
                LazyVStack(spacing: 2) {
                    ForEach(filtered, id: \.self) { playlist in
                        Button {
                            onSelect(playlist)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "music.note.list")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                                    .frame(width: 16)
                                Text(playlist)
                                    .font(.subheadline)
                                    .lineLimit(1)
                                Spacer()
                                Image(systemName: "play.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.clear)
                        )
                        .onHover { hovering in
                            // SwiftUI handles hover highlight via buttonStyle
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }
}
