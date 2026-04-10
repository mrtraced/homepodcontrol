import SwiftUI

struct VolumeControlView: View {
    @Binding var volume: Double
    let onVolumeChange: (Double) -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "speaker.fill")
                .font(.caption)
                .foregroundStyle(.secondary)

            Slider(value: $volume, in: 0...1) { editing in
                if !editing {
                    onVolumeChange(volume)
                }
            }
            .controlSize(.small)

            Image(systemName: volumeIcon)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 16)

            Text("\(Int(volume * 100))%")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 32, alignment: .trailing)
                .monospacedDigit()
        }
        .padding(.horizontal)
    }

    private var volumeIcon: String {
        if volume == 0 { return "speaker.slash.fill" }
        if volume < 0.33 { return "speaker.wave.1.fill" }
        if volume < 0.66 { return "speaker.wave.2.fill" }
        return "speaker.wave.3.fill"
    }
}
