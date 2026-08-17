import SwiftUI
import SwiftData
import WidgetKit

struct AddLogSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var onSave: ((PingPongSession) -> Void)? = nil
    
    @State private var sessionType: SessionType = .casualMatch
    @State private var mood: MoodType = .onFire
    @State private var ballSize: BallSize = .medium
    @State private var durationMinutes: Int = 60
    @State private var scorePlayer: String = "11"
    @State private var scoreOpponent: String = "8"
    @State private var opponentName: String = ""
    @State private var note: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("训练/比赛类型") {
                    Picker("模式", selection: $sessionType) {
                        ForEach(SessionType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: sessionType) { _, newValue in
                        ballSize = newValue.defaultBallSize
                    }
                }
                
                Section("掉落乒乓球尺寸 (不同尺寸对应首页不同物理大小)") {
                    Picker("尺寸", selection: $ballSize) {
                        ForEach(BallSize.allCases, id: \.self) { size in
                            Text("\(size.rawValue) 🏓").tag(size)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    HStack(spacing: 20) {
                        Spacer()
                        VStack(spacing: 6) {
                            DoodleBallView(mood: mood, size: ballSize)
                            Text("当前所选物理尺寸")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                Section("打球心情与状态") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(MoodType.allCases) { item in
                                VStack(spacing: 6) {
                                    DoodleBallView(mood: item, size: .medium)
                                        .scaleEffect(mood == item ? 1.1 : 1.0)
                                        .animation(.spring(response: 0.3), value: mood)
                                    Text(item.rawValue)
                                        .font(.caption)
                                        .fontWeight(mood == item ? .bold : .regular)
                                        .foregroundColor(mood == item ? .pongOrange : .sketchLine)
                                }
                                .padding(10)
                                .background(mood == item ? Color.pongOrangeLight.opacity(0.25) : Color.clear)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(mood == item ? Color.pongOrange : Color.clear, lineWidth: 2)
                                )
                                .onTapGesture {
                                    mood = item
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Section("比分与对手 (可选)") {
                    HStack {
                        TextField("我方得分", text: $scorePlayer)
                            .keyboardType(.numberPad)
                        Text(":")
                            .fontWeight(.bold)
                        TextField("对手得分", text: $scoreOpponent)
                            .keyboardType(.numberPad)
                    }
                    
                    TextField("对手昵称 (如: 小张/李教练)", text: $opponentName)
                }
                
                Section("心得手记与发球体会") {
                    TextField("如：正手拉球顺畅，反手撕斜线吃发球较多...", text: $note, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("记一笔打卡 🏓")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存并降落球") {
                        saveSession()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
    
    private func saveSession() {
        let pScore = Int(scorePlayer)
        let oScore = Int(scoreOpponent)
        
        let newSession = PingPongSession(
            date: Date(),
            durationMinutes: durationMinutes,
            sessionType: sessionType,
            mood: mood,
            ballSize: ballSize,
            note: note.isEmpty ? nil : note,
            scorePlayer: pScore,
            scoreOpponent: oScore,
            opponentName: opponentName.isEmpty ? nil : opponentName
        )
        
        modelContext.insert(newSession)
        WidgetCenter.shared.reloadAllTimelines()
        onSave?(newSession)
        dismiss()
    }
}
