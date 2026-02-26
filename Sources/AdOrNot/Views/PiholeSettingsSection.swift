import SwiftUI

struct PiholeSettingsSection: View {
    @Bindable var viewModel: TestViewModel
    @State private var piholePassword: String = KeychainHelper.load(key: "piholePassword") ?? ""
    @State private var connectionStatus: ConnectionStatus = .idle

    private enum ConnectionStatus {
        case idle, testing, success, failure
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacingMD) {
            SectionHeader(title: "Pi-hole", icon: "shield.checkered")

            VStack(spacing: 0) {
                hostAddressField
                StyledDivider()
                passwordField
                StyledDivider()
                testConnectionRow
            }
            .glassCard(padding: 0)
        }
    }

    // MARK: - Host Address

    private var hostAddressField: some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            Text("Host Address")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white)

            TextField("192.168.1.x", text: Binding(
                get: { viewModel.pihole.piholeHost },
                set: { viewModel.pihole.savePiholeHost($0) }
            ))
            .textFieldStyle(.roundedBorder)

            Text("Just the IP address (e.g. 192.168.1.100) or with port (e.g. 192.168.1.100:8080)")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.35))
        }
        .padding(Theme.spacingMD)
    }

    // MARK: - Password

    private var passwordField: some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            Text("Password")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white)

            SecureField("Pi-hole password", text: $piholePassword)
                .textFieldStyle(.roundedBorder)
                .onChange(of: piholePassword) { _, newValue in
                    if newValue.isEmpty {
                        KeychainHelper.delete(key: "piholePassword")
                    } else {
                        _ = KeychainHelper.save(key: "piholePassword", value: newValue)
                    }
                }

            Text("Stored securely in Keychain")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.35))
        }
        .padding(Theme.spacingMD)
    }

    // MARK: - Test Connection

    private var testConnectionRow: some View {
        HStack {
            Button {
                connectionStatus = .testing
                Task {
                    let success = await viewModel.pihole.testPiholeConnection()
                    connectionStatus = success ? .success : .failure
                }
            } label: {
                HStack(spacing: Theme.spacingSM) {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                    Text("Test Connection")
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Theme.brandBlueLight)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.pihole.piholeHost.isEmpty || piholePassword.isEmpty)

            Spacer()

            connectionStatusView
        }
        .padding(Theme.spacingMD)
    }

    @ViewBuilder
    private var connectionStatusView: some View {
        switch connectionStatus {
        case .idle:
            EmptyView()
        case .testing:
            ProgressView()
                .controlSize(.small)
        case .success:
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                Text("Connected")
            }
            .font(.caption.weight(.medium))
            .foregroundStyle(Theme.scoreGood)
        case .failure:
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "xmark.circle.fill")
                    Text("Failed")
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(Theme.scoreWeak)

                if let error = viewModel.pihole.piholeError {
                    Text(error)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.5))
                        .lineLimit(2)
                }
            }
        }
    }
}
