import SwiftUI

struct DevicePickerView: View {
    let devices: [HomePodDevice]
    let selectedDevice: HomePodDevice?
    let isConnected: Bool
    let onSelect: (HomePodDevice) -> Void
    let onRefresh: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isConnected ? "homepod.fill" : "homepod")
                .foregroundStyle(isConnected ? Color.accentColor : .secondary)

            if let device = selectedDevice {
                Text(device.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
            } else {
                Text("No HomePod Selected")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Menu {
                if devices.isEmpty {
                    Text("No devices found")
                } else {
                    ForEach(devices) { device in
                        Button {
                            onSelect(device)
                        } label: {
                            HStack {
                                Image(systemName: device.iconName)
                                Text(device.name)
                                Spacer()
                                if device.name == selectedDevice?.name {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }

                Divider()

                Button("Refresh Devices", action: onRefresh)
            } label: {
                Image(systemName: "chevron.down.circle")
                    .font(.subheadline)
            }
            .menuStyle(.borderlessButton)
            .frame(width: 24)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal)
    }
}
