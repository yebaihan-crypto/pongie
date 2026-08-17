import SwiftUI
import SwiftData
import WidgetKit

struct DashboardView: View {
    @EnvironmentObject var quickActionManager: QuickActionManager
    @Query(sort: \PingPongSession.date, order: .reverse) private var sessions: [PingPongSession]
    @AppStorage("has_dismissed_welcome_ball") private var hasDismissedWelcomeBall: Bool = false
    @State private var showingAddSheet = false
    @State private var selectedSession: PingPongSession? = nil
    @State private var showDropToast = false
    @State private var toastMoodEmoji = "🔥"
    
    @State private var lastAddedSession: PingPongSession? = nil
    
    var thisMonthSessionsCount: Int {
        let calendar = Calendar.current
        return sessions.filter { calendar.isDate($0.date, equalTo: Date(), toGranularity: .month) }.count
    }
    
    var displayCount: Int {
        thisMonthSessionsCount
    }
    
    var body: some View {
        ZStack {
            // Hand-drawn Paper Background
            Color.pongBgPastel
                .ignoresSafeArea()
            
            // Court Lines Pattern
            CourtLinesOverlay()
            
            VStack(spacing: 14) {
                // Top App Branding Bar with Inverted Solid Ball Icon
                HStack(spacing: 10) {
                    InvertedSolidBallIconView(size: 44, showAppIconFrame: false)
                        .rotationEffect(.degrees(-6))
                    Text("Pongie 乒啪记")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(.sketchLine)
                    Spacer()
                    DoodleStickerView(title: "球感稳定 ⭐", color: .stickerYellow, rotationAngle: 4)
                }
                .padding(.horizontal, 20)
                .padding(.top, 6)
                
                // Header Counter Section
                VStack(spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(displayCount)")
                            .font(.system(size: 50, weight: .black, design: .rounded))
                            .foregroundColor(.sketchLine)
                            .contentTransition(.numericText())
                        Text("场球")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.sketchLine)
                    }
                    .animation(.spring(), value: displayCount)
                    
                    if displayCount == 0 {
                        Text("本月还没有打卡，点击下方按钮记录第一场吧！")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.sketchLine.opacity(0.8))
                    } else {
                        Text("真棒！本月已记录 \(displayCount) 次打球心情与状态")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.sketchLine.opacity(0.8))
                    }
                    
                    DoodleStickerView(title: "~ 每次打卡，掉落一枚心情球 ~", color: .stickerPink, rotationAngle: -3)
                        .padding(.top, 2)
                }
                .padding(.top, 8)
                
                Spacer(minLength: 4)
                
                // Central Hand-Drawn Add Button
                Button {
                    showingAddSheet = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                        Text("记录打球")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(Color.pongOrange)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color.sketchLine, lineWidth: 3)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 4, x: 2, y: 3)
                }
                
                Spacer(minLength: 4)
                
                // Interactive Physics Ball Pool (Tumbled varied ball sizes)
                ZStack(alignment: .topTrailing) {
                    BallPhysicsPoolView(sessions: sessions, isWelcomeDismissed: hasDismissedWelcomeBall, onSelectSession: { clickedSession in
                        selectedSession = clickedSession
                    }, pendingDropSession: lastAddedSession)
                    .frame(height: 380)
                    .padding(.horizontal, 16)
                    
                    // Floating Doodle Stickers
                    VStack(alignment: .trailing, spacing: 10) {
                        if sessions.isEmpty && !hasDismissedWelcomeBall {
                            Button {
                                selectedSession = welcomeSession
                            } label: {
                                DoodleStickerView(title: "👋 欢迎引导球 🏓", color: .stickerYellow, rotationAngle: 6)
                            }
                            .buttonStyle(.plain)
                            
                            Button {
                                selectedSession = welcomeSession
                            } label: {
                                DoodleStickerView(title: "点击查看玩法 💡", color: .stickerBlue, rotationAngle: -4)
                            }
                            .buttonStyle(.plain)
                        } else {
                            DoodleStickerView(title: "心情球池 🏓", color: .stickerYellow, rotationAngle: 6)
                            DoodleStickerView(title: "点击浮弹卡片 ✨", color: .stickerBlue, rotationAngle: -4)
                        }
                    }
                    .padding(.trailing, 28)
                    .offset(y: -18)
                }
                .padding(.bottom, 10)
            }
            
            // Drop Toast Banner
            if showDropToast {
                VStack {
                    HStack(spacing: 8) {
                        Text(toastMoodEmoji)
                            .font(.title2)
                        Text("新的打球心情球已进入球池！")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.sketchLine)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.stickerYellow)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.sketchLine, lineWidth: 2.5))
                    .shadow(radius: 4)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 16)
                    
                    Spacer()
                }
            }
        }
        .onChange(of: quickActionManager.showAddSessionSheet) { _, newValue in
            if newValue {
                showingAddSheet = true
                quickActionManager.showAddSessionSheet = false
            }
        }
        .sheet(isPresented: $showingAddSheet, onDismiss: {
            if lastAddedSession != nil {
                withAnimation(.spring()) {
                    showDropToast = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                    withAnimation {
                        showDropToast = false
                    }
                }
            }
        }) {
            AddLogSheet { addedSession in
                toastMoodEmoji = addedSession.mood.emoji
                lastAddedSession = addedSession
            }
        }
        .sheet(item: $selectedSession) { session in
            if session.id == MoodPhysicsScene.welcomeSessionID {
                WelcomeGuideSheet(onDismissWelcome: {
                    hasDismissedWelcomeBall = true
                }, onRecordFirst: {
                    hasDismissedWelcomeBall = true
                    showingAddSheet = true
                })
            } else {
                SessionDetailSheet(session: session)
            }
        }
    }
    
    private var welcomeSession: PingPongSession {
        let session = PingPongSession(
            sessionType: .practice,
            mood: .joyful,
            ballSize: .jumbo,
            note: "👋 欢迎来到 Pongie！记录打卡后，球池将实时掉落你的专属心情球 🏓"
        )
        session.id = MoodPhysicsScene.welcomeSessionID
        return session
    }
}

struct WelcomeGuideSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onDismissWelcome: (() -> Void)? = nil
    var onRecordFirst: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header with Doodle Ball Icon
                VStack(spacing: 12) {
                    DoodleBallView(mood: .joyful, size: .jumbo)
                        .scaleEffect(1.2)
                        .padding(.top, 12)
                    
                    Text("👋 欢迎来到 Pongie 乒啪记")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.sketchLine)
                    
                    Text("你的乒乓打卡与心情球小角落")
                        .font(.subheadline)
                        .foregroundColor(.sketchLine.opacity(0.7))
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.stickerYellow.opacity(0.35))
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.sketchLine, lineWidth: 2))
                
                // Instructions / Guide
                VStack(alignment: .leading, spacing: 16) {
                    GuideFeatureRow(icon: "🏓", title: "掉落专属心情球", description: "每次打卡记录比赛或练习后，球池会随机掉落带有你当时状态与心情的乒乓球。")
                    GuideFeatureRow(icon: "⚡", title: "物理碰撞与乱斗", description: "球池具备真实碰撞效果，拖拽或点击“乱斗”可使球群弹跃游玩，点击单球可回放细节。")
                    GuideFeatureRow(icon: "📊", title: "球技成长与球具", description: "全方位统计胜率与打法特征，同时贴心追踪你的底板与套胶耗损使用时间。")
                }
                .padding(.horizontal, 4)
                
                Spacer()
                
                // Action Button
                Button {
                    onDismissWelcome?()
                    dismiss()
                    onRecordFirst()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        Text("立即记录第一场打球")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.pongOrange)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.sketchLine, lineWidth: 2.5))
                    .shadow(color: .black.opacity(0.12), radius: 3, x: 1, y: 2)
                }
            }
            .padding(20)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("我知道了") {
                        onDismissWelcome?()
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

struct GuideFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text(icon)
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(Color.white)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.sketchLine, lineWidth: 1.5))
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.sketchLine)
                Text(description)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.sketchLine.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct SessionDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let session: PingPongSession
    
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    DoodleBallView(mood: session.mood, size: session.ballSize)
                        .scaleEffect(1.2)
                        .padding(.top, 12)
                    
                    Text(session.mood.rawValue)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.sketchLine)
                    
                    Text("尺寸规格：\(session.ballSize.rawValue) 乒乓球")
                        .font(.subheadline)
                        .foregroundColor(.sketchLine.opacity(0.7))
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.pongOrangeLight.opacity(0.2))
                .cornerRadius(20)
                
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Label("模式：\(session.sessionType.rawValue)", systemImage: "figure.table.tennis")
                        Spacer()
                        Text(session.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .font(.headline)
                    
                    if let player = session.scorePlayer, let opponent = session.scoreOpponent {
                        HStack {
                            Text("比赛比分：")
                                .fontWeight(.medium)
                            Text("\(player) : \(opponent)")
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundColor(.pongOrange)
                            if let name = session.opponentName, !name.isEmpty {
                                Text("(VS \(name))")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    if let note = session.note, !note.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("心得手记：")
                                .font(.subheadline)
                                .fontWeight(.bold)
                            Text(note)
                                .font(.body)
                                .foregroundColor(.sketchLine)
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.sketchLine.opacity(0.3)))
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Delete Record Button
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "trash.fill")
                        Text("删除此条打卡记录")
                    }
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.3), lineWidth: 1.5))
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .padding()
            .navigationTitle("打卡心情微卡")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("关闭") { dismiss() }
                }
            }
            .alert("确认删除此记录？", isPresented: $showingDeleteAlert) {
                Button("删除", role: .destructive) {
                    modelContext.delete(session)
                    WidgetCenter.shared.reloadAllTimelines()
                    dismiss()
                }
                Button("取消", role: .cancel) { }
            } message: {
                Text("删除该打卡记录后，数据分析与球池中的对应心情球都将被自动移除。")
            }
        }
        .presentationDetents([.medium, .large])
    }
}

struct CourtLinesOverlay: View {
    var body: some View {
        Canvas { context, size in
            var path = Path()
            // Outer court rect
            path.addRoundedRect(in: CGRect(x: 20, y: 40, width: size.width - 40, height: size.height - 80), cornerSize: CGSize(width: 16, height: 16))
            // Center net line
            path.move(to: CGPoint(x: 20, y: size.height / 2))
            path.addLine(to: CGPoint(x: size.width - 20, y: size.height / 2))
            
            context.stroke(path, with: .color(Color.white.opacity(0.4)), style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
        }
        .ignoresSafeArea()
    }
}

