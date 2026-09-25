import CodexSoundGuardCore
import SwiftUI

enum SurfaceProminence {
    case regular
    case overview
    case quiet
}

struct Surface<Content: View>: View {
    var prominence: SurfaceProminence = .regular
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(prominence == .overview ? 14 : 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(backgroundFill, in: RoundedRectangle(cornerRadius: InterfaceDesign.panelRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: InterfaceDesign.panelRadius, style: .continuous)
                    .strokeBorder(InterfaceDesign.border, lineWidth: 1)
            }
    }

    private var backgroundFill: Color {
        switch prominence {
        case .regular:
            return InterfaceDesign.elevatedPanel.opacity(0.54)
        case .overview:
            return InterfaceDesign.elevatedPanel.opacity(0.58)
        case .quiet:
            return InterfaceDesign.basePanel.opacity(0.54)
        }
    }
}

struct StatusBadge: View {
    let title: String
    let isActive: Bool

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isActive ? InterfaceDesign.accent : Color.primary.opacity(0.32))
                .frame(width: 6, height: 6)

            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(isActive ? .primary : .secondary)
                .lineLimit(1)
        }
        .padding(.horizontal, 9)
        .frame(height: 24)
        .background(InterfaceDesign.basePanel.opacity(0.60), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .strokeBorder(InterfaceDesign.border, lineWidth: 1)
        }
    }
}

struct PrimaryUsageSummary: View {
    let usage: TokenUsageSnapshot?

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text("当前用量")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                Text(primaryValue)
                    .font(.system(size: 27, weight: .semibold, design: .rounded).monospacedDigit())
                    .lineLimit(1)
                    .minimumScaleFactor(0.80)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("累计")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
                Text(totalValue)
                    .font(.callout.monospacedDigit().weight(.semibold))
                    .lineLimit(1)
            }
        }
    }

    private var primaryValue: String {
        usage.map { UsageFormatter.tokenCount($0.last.totalTokens) } ?? "--"
    }

    private var totalValue: String {
        usage.map { UsageFormatter.tokenCount($0.total.totalTokens) } ?? "--"
    }
}

struct MetricPill: View {
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 5) {
            Text(title)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption2.monospacedDigit().weight(.semibold))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 8)
        .frame(height: 23)
        .background(InterfaceDesign.basePanel.opacity(0.54), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
    }
}

struct UsageSummaryPills: View {
    let usage: TokenUsageSnapshot

    var body: some View {
        HStack(spacing: 6) {
            MetricPill(title: "5 小时", value: remainingValue(usage.primaryRateLimit))
            MetricPill(title: "7 天", value: remainingValue(usage.secondaryRateLimit))
            MetricPill(title: "上下文", value: UsageFormatter.contextWindow(usage.modelContextWindow))
        }
    }

    private func remainingValue(_ limit: UsageRateLimit?) -> String {
        guard let limit else {
            return "--"
        }
        return UsageFormatter.percent(100 - max(0, min(limit.usedPercent, 100)))
    }
}

struct HeaderToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(spacing: 7) {
                Image(systemName: configuration.isOn ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .font(.system(size: 11, weight: .bold))
                    .frame(width: 16)
                Text(configuration.isOn ? "提醒开" : "已静音")
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(configuration.isOn ? Color.white : Color.primary.opacity(0.72))
            .padding(.horizontal, 11)
            .frame(height: 30)
            .background(configuration.isOn ? InterfaceDesign.accent : InterfaceDesign.basePanel.opacity(0.66), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(configuration.isOn ? Color.white.opacity(0.26) : InterfaceDesign.border, lineWidth: 1)
            }
            .shadow(color: configuration.isOn ? InterfaceDesign.accent.opacity(0.18) : Color.clear, radius: 7, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

struct EmptyStateLine: View {
    let iconName: String
    let text: String
    var detail: String?

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: iconName)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(InterfaceDesign.accent.opacity(0.72))
                .frame(width: 18)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 2) {
                Text(text)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                if let detail {
                    Text(detail)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

struct RemainingLimitStack: View {
    let usage: TokenUsageSnapshot

    var body: some View {
        VStack(spacing: 8) {
            RemainingLimitRow(title: "5 小时", limit: usage.primaryRateLimit)
            RemainingLimitRow(title: "7 天", limit: usage.secondaryRateLimit)
        }
    }
}

private struct RemainingLimitRow: View {
    let title: String
    let limit: UsageRateLimit?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Spacer()

                Text(remainingText)
                    .font(.caption.monospacedDigit().weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }

            Text(resetDetailText)
                .font(.caption2.monospacedDigit())
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.86)

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.primary.opacity(0.10))

                    Capsule()
                        .fill(InterfaceDesign.accent.opacity(0.82))
                        .frame(width: proxy.size.width * remainingProgress)
                }
            }
            .frame(height: 5)
            .help(resetHelpText)
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 9)
        .background(InterfaceDesign.basePanel.opacity(0.56), in: RoundedRectangle(cornerRadius: InterfaceDesign.controlRadius, style: .continuous))
    }

    private var remainingProgress: Double {
        guard let limit else {
            return 0
        }
        return 1 - (max(0, min(limit.usedPercent, 100)) / 100)
    }

    private var remainingText: String {
        guard let limit else {
            return "--"
        }
        return "\(UsageFormatter.percent(remainingPercent(limit))) 剩余"
    }

    private var resetDetailText: String {
        guard let resetDate = limit?.resetsAt else {
            return "重置 --"
        }
        return "重置 \(Self.resetText(for: resetDate)) · \(Self.relativeResetText(until: resetDate))"
    }

    private var resetHelpText: String {
        guard let resetDate = limit?.resetsAt else {
            return "重置 --"
        }
        return "重置 \(Self.resetText(for: resetDate)) · \(Self.relativeResetText(until: resetDate))"
    }

    private func remainingPercent(_ limit: UsageRateLimit) -> Double {
        100 - max(0, min(limit.usedPercent, 100))
    }

    private static func resetText(for date: Date, now: Date = Date()) -> String {
        if Calendar.current.isDate(date, inSameDayAs: now) {
            return sameDayResetFormatter.string(from: date)
        }

        if Calendar.current.component(.year, from: date) == Calendar.current.component(.year, from: now) {
            return futureResetFormatter.string(from: date)
        }

        return distantResetFormatter.string(from: date)
    }

    private static func relativeResetText(until date: Date, now: Date = Date()) -> String {
        let seconds = Int(date.timeIntervalSince(now).rounded(.up))
        guard seconds > 0 else {
            return "即将重置"
        }

        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour

        if seconds < minute {
            return "不足 1 分钟"
        }

        if seconds < hour {
            return "还有 \((seconds + minute - 1) / minute) 分钟"
        }

        if seconds < day {
            var hours = seconds / hour
            var minutes = (seconds % hour + minute - 1) / minute
            if minutes == 60 {
                hours += 1
                minutes = 0
            }

            if minutes == 0 {
                return "还有 \(hours) 小时"
            }
            return "还有 \(hours) 小时 \(minutes) 分钟"
        }

        var days = seconds / day
        var hours = (seconds % day + hour - 1) / hour
        if hours == 24 {
            days += 1
            hours = 0
        }

        if hours == 0 {
            return "还有 \(days) 天"
        }
        return "还有 \(days) 天 \(hours) 小时"
    }

    private static let sameDayResetFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private static let futureResetFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d HH:mm"
        return formatter
    }()

    private static let distantResetFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/M/d HH:mm"
        return formatter
    }()
}

struct FooterAction: View {
    let title: String
    let iconName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: iconName)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .padding(.horizontal, 10)
                .frame(height: 27)
        }
        .buttonStyle(QuietCapsuleButtonStyle())
    }
}

struct QuietIconButtonStyle: ButtonStyle {
    enum Role {
        case normal
        case destructive
    }

    var role: Role = .normal

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(foreground)
            .background(background(isPressed: configuration.isPressed), in: RoundedRectangle(cornerRadius: InterfaceDesign.controlRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: InterfaceDesign.controlRadius, style: .continuous)
                    .strokeBorder(border, lineWidth: 1)
            }
    }

    private var foreground: Color {
        switch role {
        case .normal:
            return .secondary
        case .destructive:
            return .red
        }
    }

    private func background(isPressed: Bool) -> Color {
        switch role {
        case .normal:
            return InterfaceDesign.basePanel.opacity(isPressed ? 0.86 : 0.58)
        case .destructive:
            return Color.red.opacity(isPressed ? 0.16 : 0.08)
        }
    }

    private var border: Color {
        switch role {
        case .normal:
            return InterfaceDesign.border
        case .destructive:
            return Color.red.opacity(0.12)
        }
    }
}

private struct QuietCapsuleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.secondary)
            .background(InterfaceDesign.basePanel.opacity(configuration.isPressed ? 0.86 : 0.58), in: RoundedRectangle(cornerRadius: InterfaceDesign.controlRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: InterfaceDesign.controlRadius, style: .continuous)
                    .strokeBorder(InterfaceDesign.border, lineWidth: 1)
            }
    }
}
