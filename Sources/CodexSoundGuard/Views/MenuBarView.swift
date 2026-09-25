import AppKit
import CodexSoundGuardCore
import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var monitor: SessionMonitor

    @AppStorage(AppDefaults.Key.monitoringEnabled) private var alertsEnabled = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            usagePanel
            footer
        }
        .padding(14)
        .frame(width: 408)
        .background(InterfaceDesign.window.opacity(0.96))
        .controlSize(.small)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 10) {
            Text("Codex Monitor")
                .font(.system(size: 18, weight: .semibold))
                .lineLimit(1)

            Spacer(minLength: 8)

            StatusBadge(title: monitor.isRunning ? "用量中" : "启动中", isActive: monitor.isRunning)

            Toggle("", isOn: $alertsEnabled)
                .labelsHidden()
                .toggleStyle(HeaderToggleStyle())
        }
    }

    private var usagePanel: some View {
        Surface(prominence: .overview) {
            VStack(alignment: .leading, spacing: 12) {
                PrimaryUsageSummary(usage: monitor.latestUsage)

                if let usage = monitor.latestUsage {
                    UsageSummaryPills(usage: usage)
                    RemainingLimitStack(usage: usage)
                } else {
                    EmptyStateLine(iconName: "hourglass", text: "等待用量数据")
                }
            }
        }
    }

    private var footer: some View {
        HStack(spacing: 6) {
            FooterAction(title: "设置", iconName: "gearshape") {
                PreferencesWindowController.shared.show(monitor: monitor)
            }

            Spacer()

            Button {
                NSApp.terminate(nil)
            } label: {
                Image(systemName: "power")
                    .font(.system(size: 12, weight: .semibold))
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(QuietIconButtonStyle(role: .destructive))
            .help("退出")
        }
        .padding(.top, 2)
    }
}
