import SwiftUI
import SwiftData
import WidgetKit

struct AnalyticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PingPongSession.date, order: .reverse) private var sessions: [PingPongSession]
    
    @State private var sessionToDelete: PingPongSession? = nil
    @State private var showingDeleteAlert = false
    @State private var selectedSessionDetail: PingPongSession? = nil
    @State private var selectedFilter: RecordFilter = .all
    
    enum RecordFilter: String, CaseIterable, Identifiable {
        case all = "全部"
        case match = "比赛"
        case practice = "练习/多球"
        
        var id: String { rawValue }
    }
    
    var filteredSessions: [PingPongSession] {
        switch selectedFilter {
        case .all:
            return sessions
        case .match:
            return sessions.filter { $0.sessionType == .casualMatch || $0.sessionType == .tournament }
        case .practice:
            return sessions.filter { $0.sessionType == .practice || $0.sessionType == .robotDrill }
        }
    }
    
    var winCount: Int {
        sessions.filter {
            guard let p = $0.scorePlayer, let o = $0.scoreOpponent else { return false }
            return p > o
        }.count
    }
    
    var totalMatches: Int {
        sessions.filter { $0.scorePlayer != nil }.count
    }
    
    var winRate: Double {
        guard totalMatches > 0 else { return 0 }
        return Double(winCount) / Double(totalMatches) * 100
    }
    
    private func hasSessionOnDay(_ day: Int) -> Bool {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let currentMonth = calendar.component(.month, from: Date())
        
        return sessions.contains { session in
            let comp = calendar.dateComponents([.year, .month, .day], from: session.date)
            return comp.year == currentYear && comp.month == currentMonth && comp.day == day
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.pongBgPastel.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Stat Cards
                        HStack(spacing: 16) {
                            StatCard(title: "胜率", value: String(format: "%.0f%%", winRate), icon: "trophy.fill", color: .pongOrange)
                            StatCard(title: "打球总场次", value: "\(sessions.count)", icon: "figure.table.tennis", color: .pongBlue)
                        }
                        
                        // Monthly Heat Grid (Dot Heatmap)
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("\(Date().formatted(.dateTime.month(.wide)))打卡热力图")
                                    .font(.headline)
                                    .foregroundColor(.sketchLine)
                                Spacer()
                                DoodleStickerView(title: "#\(Date().formatted(.dateTime.month()))", color: .stickerYellow, rotationAngle: 3)
                            }
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                                ForEach(1...31, id: \.self) { day in
                                    let active = hasSessionOnDay(day)
                                    Circle()
                                        .fill(active ? Color.pongOrange : Color.white.opacity(0.8))
                                        .frame(height: 32)
                                        .overlay(
                                            Text("\(day)")
                                                .font(.caption2)
                                                .foregroundColor(active ? .white : .sketchLine)
                                                .fontWeight(active ? .bold : .regular)
                                        )
                                        .overlay(
                                            Circle().stroke(Color.sketchLine, lineWidth: active ? 2 : 1)
                                        )
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.sketchLine, lineWidth: 2))
                        
                        // Stroke Tags
                        VStack(alignment: .leading, spacing: 10) {
                            Text("近期打法特征分析")
                                .font(.headline)
                                .foregroundColor(.sketchLine)
                            
                            HStack {
                                TagBadge(text: "正手弧圈球 +40%", color: .stickerPink)
                                TagBadge(text: "反手拧拉 +25%", color: .stickerBlue)
                            }
                            HStack {
                                TagBadge(text: "吃侧上旋发球 ⚠️", color: .stickerYellow)
                                TagBadge(text: "发球直接得分 +18%", color: .stickerPink)
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.sketchLine, lineWidth: 2))
                        
                        // Record Management & History List Section
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(alignment: .center) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("打卡记录管理 📝")
                                        .font(.headline)
                                        .foregroundColor(.sketchLine)
                                    Text("支持查看与删减记录，对应球池小球自动同步")
                                        .font(.caption)
                                        .foregroundColor(.sketchLine.opacity(0.7))
                                }
                                Spacer()
                                DoodleStickerView(title: "\(sessions.count) 条", color: .stickerBlue, rotationAngle: -2)
                            }
                            
                            // Filter Chips
                            HStack(spacing: 8) {
                                ForEach(RecordFilter.allCases) { filter in
                                    Button {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedFilter = filter
                                        }
                                    } label: {
                                        Text(filter.rawValue)
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(selectedFilter == filter ? Color.pongOrange : Color.white)
                                            .foregroundColor(selectedFilter == filter ? .white : .sketchLine)
                                            .clipShape(Capsule())
                                            .overlay(Capsule().stroke(Color.sketchLine, lineWidth: 1.5))
                                    }
                                }
                            }
                            
                            if filteredSessions.isEmpty {
                                VStack(spacing: 8) {
                                    Image(systemName: "tray")
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                    Text("暂无相应打卡记录")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 24)
                                .background(Color.white.opacity(0.5))
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.sketchLine.opacity(0.3), lineWidth: 1))
                            } else {
                                LazyVStack(spacing: 10) {
                                    ForEach(filteredSessions) { session in
                                        SessionRowCard(session: session, onTap: {
                                            selectedSessionDetail = session
                                        }, onDelete: {
                                            sessionToDelete = session
                                            showingDeleteAlert = true
                                        })
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.sketchLine, lineWidth: 2))
                    }
                    .padding(16)
                }
            }
            .navigationTitle("球技成长 📊")
            .sheet(item: $selectedSessionDetail) { session in
                SessionDetailSheet(session: session)
            }
            .alert("确认删除此打卡记录？", isPresented: $showingDeleteAlert, presenting: sessionToDelete) { session in
                Button("删除记录", role: .destructive) {
                    withAnimation {
                        modelContext.delete(session)
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }
                Button("取消", role: .cancel) { }
            } message: { session in
                Text("删除此条记录后，数据分析与球池中的对应心情球都将被自动移除。")
            }
        }
    }
}

struct SessionRowCard: View {
    let session: PingPongSession
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Mood Thumbnail
            DoodleBallView(mood: session.mood, size: .small)
                .frame(width: 44, height: 44)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(session.sessionType.rawValue)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.sketchLine)
                    
                    Text("•")
                        .foregroundColor(.gray)
                    
                    Text(session.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                if let player = session.scorePlayer, let opponent = session.scoreOpponent {
                    HStack(spacing: 4) {
                        Text("比分：\(player) : \(opponent)")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(player > opponent ? .pongOrange : .sketchLine)
                        
                        if let name = session.opponentName, !name.isEmpty {
                            Text("(VS \(name))")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                } else if let note = session.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.sketchLine.opacity(0.8))
                        .lineLimit(1)
                } else {
                    Text("状态：\(session.mood.rawValue)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Delete Action Button
            Button {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.red.opacity(0.85))
                    .padding(8)
                    .background(Color.red.opacity(0.08))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.sketchLine.opacity(0.3), lineWidth: 1.5))
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.sketchLine)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.sketchLine, lineWidth: 2))
    }
}

struct TagBadge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.bold)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.sketchLine, lineWidth: 1.5))
    }
}
