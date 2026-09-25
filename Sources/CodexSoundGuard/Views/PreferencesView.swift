import AppKit
import CodexSoundGuardCore
import SwiftUI
import UniformTypeIdentifiers

struct PreferencesView: View {
    @EnvironmentObject private var monitor: SessionMonitor

    @AppStorage(AppDefaults.Key.monitoringEnabled) private var alertsEnabled = true
    @AppStorage(AppDefaults.Key.completionSoundEnabled) private var completionSoundEnabled = true
    @AppStorage(AppDefaults.Key.failureSoundEnabled) private var failureSoundEnabled = true
    @AppStorage(AppDefaults.Key.approvalSoundEnabled) private var approvalSoundEnabled = true
    @AppStorage(AppDefaults.Key.failureDetectionMode) private var failureDetectionMode = TurnFailureDetectionMode.strict.rawValue
    @AppStorage(AppDefaults.Key.completionSoundPath) private var completionSoundPath = AppDefaults.defaultCompletionSoundPath
    @AppStorage(AppDefaults.Key.failureSoundPath) private var failureSoundPath = AppDefaults.defaultFailureSoundPath
    @AppStorage(AppDefaults.Key.approvalSoundPath) private var approvalSoundPath = AppDefaults.defaultApprovalSoundPath
    @AppStorage(AppDefaults.Key.volume) private var volume = 0.8
    @AppStorage(AppDefaults.Key.menuBarDisplayMode) private var menuBarDisplayMode = MenuBarDisplayMode.graphic.rawValue

    @State private var selectedPane = PreferencesPane.sounds

    init(initialPane: PreferencesPane = .sounds) {
        _selectedPane = State(initialValue: initialPane)
    }

    var body: some View {
        HStack(spacing: 0) {
            PreferencesSidebar(selectedPane: $selectedPane)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    PreferencesHeader(pane: selectedPane)
                    paneContent
                }
                .frame(maxWidth: 480, alignment: .leading)
                .padding(.horizontal, 32)
                .padding(.vertical, 28)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(InterfaceDesign.window)
        }
        .frame(width: 700, height: 560)
        .tint(InterfaceDesign.accent)
    }

    @ViewBuilder
    private var paneContent: some View {
        switch selectedPane {
        case .sounds:
            soundsPane
        case .usage:
            usagePane
        }
    }

    private var soundsPane: some View {
        VStack(alignment: .leading, spacing: 18) {
            SettingsSection(title: "提醒") {
                SettingsToggleRow(title: "声音提醒", isOn: $alertsEnabled)

                SettingsControlRow(title: "音量") {
                    HStack(spacing: 10) {
                        Slider(value: $volume, in: 0...1)
                            .frame(width: 180)
                        Text("\(Int(volume * 100))%")
                            .font(.callout.monospacedDigit())
                            .foregroundStyle(.secondary)
                            .frame(width: 44, alignment: .trailing)
                    }
                }

                SettingsPickerRow(title: "失败判定", value: selectedFailureDetectionMode.title) {
                    Picker("失败判定", selection: $failureDetectionMode) {
                        ForEach(TurnFailureDetectionMode.allCases) { mode in
                            Text(mode.title).tag(mode.rawValue)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                }
            }

            SettingsSection(title: "声音") {
                SoundSettingsRow(
                    title: "完成",
                    isEnabled: $completionSoundEnabled,
                    path: completionSoundPath,
                    testAction: { monitor.testCompletionSound() },
                    chooseAction: { chooseSound(defaultKey: AppDefaults.Key.completionSoundPath) }
                )

                SoundSettingsRow(
                    title: "失败",
                    isEnabled: $failureSoundEnabled,
                    path: failureSoundPath,
                    testAction: { monitor.testFailureSound() },
                    chooseAction: { chooseSound(defaultKey: AppDefaults.Key.failureSoundPath) }
                )

                SoundSettingsRow(
                    title: "批准",
                    isEnabled: $approvalSoundEnabled,
                    path: approvalSoundPath,
                    testAction: { monitor.testApprovalSound() },
                    chooseAction: { chooseSound(defaultKey: AppDefaults.Key.approvalSoundPath) }
                )
            }
        }
    }

    private var usagePane: some View {
        VStack(alignment: .leading, spacing: 18) {
            SettingsSection(title: "菜单栏") {
                SettingsPickerRow(title: "显示", value: selectedDisplayMode.title) {
                    Picker("显示", selection: $menuBarDisplayMode) {
                        ForEach(MenuBarDisplayMode.allCases) { mode in
                            Text(mode.title).tag(mode.rawValue)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                }
            }

            SettingsSection(title: "用量") {
                if let usage = monitor.latestUsage {
                    SettingsValueRow(title: "最近", value: UsageFormatter.tokenCount(usage.last.totalTokens))
                    SettingsValueRow(title: "累计", value: UsageFormatter.tokenCount(usage.total.totalTokens))
                    SettingsValueRow(title: "上下文", value: UsageFormatter.contextWindow(usage.modelContextWindow))
                    SettingsValueRow(title: "5 小时", value: remainingText(usage.primaryRateLimit))
                    SettingsValueRow(title: "7 天", value: remainingText(usage.secondaryRateLimit))
                } else {
                    SettingsValueRow(title: "用量", value: "等待数据")
                }
            }
        }
    }

    private var selectedDisplayMode: MenuBarDisplayMode {
        MenuBarDisplayMode(rawValue: menuBarDisplayMode) ?? .graphic
    }

    private var selectedFailureDetectionMode: TurnFailureDetectionMode {
        TurnFailureDetectionMode(rawValue: failureDetectionMode) ?? .strict
    }

    private func remainingText(_ limit: UsageRateLimit?) -> String {
        guard let limit else {
            return "--"
        }
        return UsageFormatter.remainingPercent(limit)
    }

    private func chooseSound(defaultKey: String) {
        let panel = NSOpenPanel()
        panel.title = "选择声音"
        panel.prompt = "选择"
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.audio]

        if panel.runModal() == .OK, let url = panel.url {
            UserDefaults.standard.set(url.path, forKey: defaultKey)
        }
    }
}

private extension TurnFailureDetectionMode {
    var title: String {
        switch self {
        case .strict:
            return "严格"
        case .smart:
            return "智能"
        case .developer:
            return "开发者"
        }
    }
}
