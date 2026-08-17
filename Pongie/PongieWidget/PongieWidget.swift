import WidgetKit
import SwiftUI
import AppIntents
import SwiftData

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Pongie Widget 配置"
    static var description = IntentDescription("自定义 Pongie 桌面小组件")
}

struct Provider: AppIntentTimelineProvider {
    @MainActor
    private func fetchCurrentEntry() -> SimpleEntry {
        let container = SharedModelContainer.create()
        let context = container.mainContext

        // Sessions
        let sessionDescriptor = FetchDescriptor<PingPongSession>(sortBy: [SortDescriptor<PingPongSession>(\.date, order: .reverse)])
        let sessions = (try? context.fetch(sessionDescriptor)) ?? []

        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let currentMonth = calendar.component(.month, from: Date())

        let thisMonthSessions = sessions.filter { s in
            let comp = calendar.dateComponents([.year, .month], from: s.date)
            return comp.year == currentYear && comp.month == currentMonth
        }
        let matchCount = thisMonthSessions.count

        // Win Rate Calculation (same as AnalyticsView)
        var winCount = 0
        var totalScoredMatches = 0
        for s in sessions {
            if let p = s.scorePlayer, let o = s.scoreOpponent {
                totalScoredMatches += 1
                if p > o {
                    winCount += 1
                }
            }
        }
        let winRate = totalScoredMatches > 0 ? Int((Double(winCount) / Double(totalScoredMatches) * 100).rounded()) : 0

        // Recent Moods
        var recentMoods: [String] = []
        for s in sessions.prefix(5) {
            recentMoods.append(s.mood.emoji)
        }

        // Gear Wear Calculation
        let gearDescriptor = FetchDescriptor<GearItem>()
        let gears = (try? context.fetch(gearDescriptor)) ?? []
        var gearWear = 0
        if !gears.isEmpty {
            var sumPercentage: Double = 0
            for gear in gears {
                sumPercentage += gear.usagePercentage
            }
            gearWear = Int((sumPercentage / Double(gears.count)) * 100)
        }

        // Active Days in Current Month
        var activeDaysThisMonth: Set<Int> = []
        for s in thisMonthSessions {
            let day = calendar.component(.day, from: s.date)
            activeDaysThisMonth.insert(day)
        }

        return SimpleEntry(
            date: Date(),
            matchCount: matchCount,
            winRate: winRate,
            recentMoods: recentMoods.isEmpty ? ["🔥", "🏆", "💦", "⚡️", "💪"] : recentMoods,
            gearWear: gearWear,
            activeDaysThisMonth: activeDaysThisMonth
        )
    }

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            matchCount: 3,
            winRate: 67,
            recentMoods: ["🔥", "🏆", "💦"],
            gearWear: 30,
            activeDaysThisMonth: [7, 8]
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        await MainActor.run {
            fetchCurrentEntry()
        }
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let entry = await MainActor.run {
            fetchCurrentEntry()
        }
        return Timeline(entries: [entry], policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let matchCount: Int
    let winRate: Int
    let recentMoods: [String]
    let gearWear: Int
    let activeDaysThisMonth: Set<Int>
}

struct PongieWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        case .accessoryCircular:
            CircularAccessoryView(entry: entry)
        case .accessoryRectangular:
            RectangularAccessoryView(entry: entry)
        case .accessoryInline:
            InlineAccessoryView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget (小正方形)
struct SmallWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        ZStack {
            Color.pongBgPastel
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("#\(entry.matchCount)")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundColor(.sketchLine)
                    Spacer()
                    DoodleStickerView(title: "Ahhh! 🏓", color: .stickerYellow, rotationAngle: 5)
                }
                
                // Mini Heatmap Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 4) {
                    ForEach(0..<18, id: \.self) { i in
                        Circle()
                            .fill(i < entry.matchCount ? Color.pongOrange : Color.white.opacity(0.8))
                            .frame(height: 10)
                    }
                }
                
                Spacer(minLength: 0)
                
                HStack {
                    Text("胜率 \(entry.winRate)%")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.pongOrange)
                    Spacer()
                    Text("打卡卡片")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
            .padding(12)
        }
    }
}

// MARK: - Medium Widget (中中矩形)
struct MediumWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        ZStack {
            Color.pongBgPastel
            
            HStack(spacing: 16) {
                // Left Column: Count & Win Rate
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Text("\(entry.matchCount)")
                            .font(.system(size: 38, weight: .black, design: .rounded))
                            .foregroundColor(.sketchLine)
                        Text("场球")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.sketchLine)
                    }
                    
                    DoodleStickerView(title: "胜率 \(entry.winRate)% ⚡️", color: .stickerYellow, rotationAngle: -3)
                    
                    Spacer()
                    
                    Text("Pongie 乒啪记")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.sketchLine.opacity(0.6))
                }
                
                Divider()
                    .background(Color.sketchLine.opacity(0.2))
                
                // Right Column: Recent Ball Mood Pool Preview
                VStack(alignment: .leading, spacing: 8) {
                    Text("近期状态浮弹")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.sketchLine)
                    
                    HStack(spacing: 6) {
                        ForEach(entry.recentMoods, id: \.self) { emoji in
                            Text(emoji)
                                .font(.system(size: 18))
                                .padding(6)
                                .background(Color.white)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.sketchLine.opacity(0.3), lineWidth: 1.5))
                        }
                    }
                    
                    // Heatmap Dots
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
                        ForEach(0..<14, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(i < entry.matchCount ? Color.pongOrange : Color.white.opacity(0.7))
                                .frame(height: 10)
                        }
                    }
                }
            }
            .padding(14)
        }
    }
}

// MARK: - Large Widget (大号全景看板)
struct LargeWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        ZStack {
            Color.pongBgPastel
            
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Pongie 乒啪记")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundColor(.sketchLine)
                        Text("月度运动看板")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    DoodleStickerView(title: "胜率 \(entry.winRate)% 🏆", color: .stickerYellow, rotationAngle: 4)
                }
                
                // Stat Cards
                HStack(spacing: 12) {
                    VStack(alignment: .leading) {
                        Text("本月打卡")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(entry.matchCount) 场")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.sketchLine)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    VStack(alignment: .leading) {
                        Text("装备磨损")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(entry.gearWear)%")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.pongOrange)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(12)
                }
                
                // Calendar Heat Grid
                Text("打卡热力方阵")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.sketchLine)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 6) {
                    ForEach(1...31, id: \.self) { day in
                        let active = entry.activeDaysThisMonth.contains(day)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(active ? Color.pongOrange : Color.white.opacity(0.6))
                            .frame(height: 16)
                            .overlay(
                                Text("\(day)")
                                    .font(.system(size: 8, weight: .bold, design: .rounded))
                                    .foregroundColor(active ? .white : .sketchLine.opacity(0.4))
                            )
                    }
                }
                
                Spacer()
                
                // Footer
                HStack {
                    Text("最近心情: " + entry.recentMoods.joined(separator: " "))
                        .font(.caption)
                        .foregroundColor(.sketchLine)
                    Spacer()
                    Text("保持球感 ✨")
                        .font(.caption2)
                        .foregroundColor(.pongOrange)
                }
            }
            .padding(16)
        }
    }
}

// MARK: - Circular Accessory (锁屏/桌面圆形小组件)
struct CircularAccessoryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 1) {
                Image(systemName: "figure.table.tennis")
                    .font(.system(size: 14, weight: .bold))
                Text("#\(entry.matchCount)")
                    .font(.system(size: 16, weight: .black, design: .rounded))
            }
        }
    }
}

// MARK: - Rectangular Accessory (锁屏/桌面矩形小组件)
struct RectangularAccessoryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "figure.table.tennis")
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Pongie 打球卡")
                    .font(.headline)
                    .widgetAccentable()
                Text("本月 \(entry.matchCount) 场 · 胜率 \(entry.winRate)%")
                    .font(.caption)
            }
        }
    }
}

// MARK: - Inline Accessory (锁屏单行小组件)
struct InlineAccessoryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        Label("🏓 本月打球 \(entry.matchCount) 场 (胜率 \(entry.winRate)%)", systemImage: "figure.table.tennis")
    }
}

@main
struct PongieWidgetBundle: WidgetBundle {
    var body: some Widget {
        PongieWidget()
    }
}

struct PongieWidget: Widget {
    let kind: String = "PongieWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            PongieWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Pongie 打卡小组件")
        .description("支持桌面与锁屏多种形状规格：展示打卡场次、胜率看板与心情球池。")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}


