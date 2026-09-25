import AppKit
import SwiftUI

enum PreferencesPane: String, CaseIterable, Identifiable {
    case sounds
    case usage

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .sounds:
            return "声音"
        case .usage:
            return "用量"
        }
    }

    var iconName: String {
        switch self {
        case .sounds:
            return "speaker.wave.2"
        case .usage:
            return "gauge.with.dots.needle.50percent"
        }
    }
}

struct PreferencesSidebar: View {
    @Binding var selectedPane: PreferencesPane

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 10) {
                CodexUsageMeter(statusIntensity: 0.7, usage: nil)
                    .frame(width: 28, height: 28)
                    .padding(7)
                    .background(InterfaceDesign.elevatedPanel.opacity(0.56), in: RoundedRectangle(cornerRadius: InterfaceDesign.panelRadius, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: InterfaceDesign.panelRadius, style: .continuous)
                            .strokeBorder(InterfaceDesign.border, lineWidth: 1)
                    }

                Text("Codex Monitor")
                    .font(.headline.weight(.semibold))
                    .lineLimit(1)
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)

            VStack(spacing: 4) {
                ForEach(PreferencesPane.allCases) { pane in
                    SidebarRow(
                        pane: pane,
                        isSelected: pane == selectedPane
                    ) {
                        selectedPane = pane
                    }
                }
            }
            .padding(.horizontal, 10)

            Spacer()
        }
        .frame(width: 188)
        .background(InterfaceDesign.basePanel.opacity(0.38))
    }
}

private struct SidebarRow: View {
    let pane: PreferencesPane
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: pane.iconName)
                    .font(.system(size: 13, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(isSelected ? InterfaceDesign.accent : Color.secondary)
                    .frame(width: 25, height: 25)
                    .background(isSelected ? InterfaceDesign.accent.opacity(0.08) : Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 6, style: .continuous))

                Text(pane.title)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.primary)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
            .frame(height: 36)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background {
            if isSelected {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: InterfaceDesign.controlRadius, style: .continuous)
                        .fill(InterfaceDesign.accent.opacity(0.055))
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(InterfaceDesign.accent)
                        .frame(width: 3, height: 24)
                        .padding(.leading, 2)
                }
            }
        }
    }
}

struct PreferencesHeader: View {
    let pane: PreferencesPane

    var body: some View {
        Text(pane.title)
            .font(.system(size: 26, weight: .semibold))
            .lineLimit(1)
            .padding(.bottom, 4)
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.leading, 3)

            VStack(spacing: 0) {
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(InterfaceDesign.elevatedPanel.opacity(0.54), in: RoundedRectangle(cornerRadius: InterfaceDesign.panelRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: InterfaceDesign.panelRadius, style: .continuous)
                    .strokeBorder(InterfaceDesign.border, lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(0.025), radius: 8, x: 0, y: 2)
        }
    }
}

struct SettingsControlRow<Control: View>: View {
    let title: String
    @ViewBuilder var control: Control

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Text(title)
                .font(.callout.weight(.medium))
                .foregroundStyle(.primary)
                .lineLimit(1)

            Spacer(minLength: 24)

            control
        }
        .settingsRow()
    }
}

struct SettingsPickerRow<Control: View>: View {
    let title: String
    let value: String
    @ViewBuilder var control: Control

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.callout.weight(.medium))

                Spacer(minLength: 16)

                Text(value)
                    .font(.callout.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            control
        }
        .settingsRow()
    }
}

struct SettingsValueRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 16) {
            Text(title)
                .font(.callout.weight(.medium))
            Spacer(minLength: 24)
            Text(value)
                .font(.callout.monospacedDigit())
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .settingsRow()
    }
}

struct SettingsToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Text(title)
                .font(.callout.weight(.medium))
                .foregroundStyle(.primary)
                .lineLimit(1)

            Spacer(minLength: 24)

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(.switch)
                .tint(InterfaceDesign.accent)
        }
        .settingsRow()
    }
}

struct SoundSettingsRow: View {
    let title: String
    @Binding var isEnabled: Bool
    let path: String
    let testAction: () -> Void
    let chooseAction: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .center, spacing: 16) {
                Text(title)
                    .font(.callout.weight(.medium))
                    .lineLimit(1)

                Spacer(minLength: 24)

                Toggle("", isOn: $isEnabled)
                    .labelsHidden()
                    .toggleStyle(.switch)
                    .tint(InterfaceDesign.accent)
            }

            HStack(spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "waveform")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.secondary)

                    Text(URL(fileURLWithPath: path).lastPathComponent)
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .padding(.horizontal, 9)
                .frame(height: 26)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(InterfaceDesign.basePanel.opacity(0.52), in: RoundedRectangle(cornerRadius: InterfaceDesign.controlRadius, style: .continuous))

                Button(action: testAction) {
                    Image(systemName: "play.fill")
                        .frame(width: 26, height: 26)
                }
                .buttonStyle(SettingsIconButtonStyle())
                .disabled(!isEnabled)
                .help("试听")

                Button(action: chooseAction) {
                    Image(systemName: "folder")
                        .frame(width: 26, height: 26)
                }
                .buttonStyle(SettingsIconButtonStyle())
                .help("选择声音")
            }
        }
        .settingsRow()
    }
}

private extension View {
    func settingsRow(verticalPadding: CGFloat = 12) -> some View {
        self
            .padding(.horizontal, 14)
            .padding(.vertical, verticalPadding)
            .frame(minHeight: 50)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(InterfaceDesign.separator)
                    .frame(height: 1)
                    .padding(.leading, 14)
            }
    }
}

private struct SettingsIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.secondary)
            .background(InterfaceDesign.basePanel.opacity(configuration.isPressed ? 0.92 : 0.58), in: RoundedRectangle(cornerRadius: InterfaceDesign.controlRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: InterfaceDesign.controlRadius, style: .continuous)
                    .strokeBorder(InterfaceDesign.border, lineWidth: 1)
            }
    }
}
