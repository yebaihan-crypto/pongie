import Foundation
import SwiftData

enum SessionType: String, Codable, CaseIterable, Identifiable {
    case practice = "日常练习"
    case casualMatch = "球友约战"
    case tournament = "正式比赛"
    case robotDrill = "发球机/多球"
    
    var id: String { rawValue }
    
    var defaultBallSize: BallSize {
        switch self {
        case .tournament: return .jumbo
        case .casualMatch: return .medium
        case .practice: return .medium
        case .robotDrill: return .small
        }
    }
}

enum MoodType: String, Codable, CaseIterable, Identifiable {
    case onFire = "状态爆棚"
    case joyful = "快乐拉满"
    case solid = "球感稳定"
    case exhausted = "大汗淋漓"
    case frustrated = "吃发球吃到饱"
    case cheeky = "吐舌顽抗"
    case dizzy = "眩晕出界"
    
    var id: String { rawValue }
    
    var emoji: String {
        switch self {
        case .onFire: return "🔥"
        case .joyful: return "😄"
        case .solid: return "⭐"
        case .exhausted: return "💦"
        case .frustrated: return "💢"
        case .cheeky: return "😝"
        case .dizzy: return "🌀"
        }
    }
}

enum BallSize: String, Codable, CaseIterable {
    case small = "小号"
    case medium = "中号"
    case jumbo = "大号"
    
    var radius: CGFloat {
        switch self {
        case .small: return 24.0
        case .medium: return 36.0
        case .jumbo: return 52.0
        }
    }
}

@Model
final class PingPongSession {
    @Attribute(.unique) var id: UUID
    var date: Date
    var durationMinutes: Int
    var sessionTypeRaw: String
    var moodRaw: String
    var ballSizeRaw: String
    var note: String?
    var scorePlayer: Int?
    var scoreOpponent: Int?
    var opponentName: String?
    
    var bladeName: String?
    var forehandRubber: String?
    var backhandRubber: String?
    
    var sessionType: SessionType {
        get { SessionType(rawValue: sessionTypeRaw) ?? .practice }
        set { sessionTypeRaw = newValue.rawValue }
    }
    
    var mood: MoodType {
        get { MoodType(rawValue: moodRaw) ?? .joyful }
        set { moodRaw = newValue.rawValue }
    }
    
    var ballSize: BallSize {
        get { BallSize(rawValue: ballSizeRaw) ?? .medium }
        set { ballSizeRaw = newValue.rawValue }
    }
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        durationMinutes: Int = 60,
        sessionType: SessionType = .practice,
        mood: MoodType = .joyful,
        ballSize: BallSize? = nil,
        note: String? = nil,
        scorePlayer: Int? = nil,
        scoreOpponent: Int? = nil,
        opponentName: String? = nil,
        bladeName: String? = nil,
        forehandRubber: String? = nil,
        backhandRubber: String? = nil
    ) {
        self.id = id
        self.date = date
        self.durationMinutes = durationMinutes
        self.sessionTypeRaw = sessionType.rawValue
        self.moodRaw = mood.rawValue
        self.ballSizeRaw = (ballSize ?? sessionType.defaultBallSize).rawValue
        self.note = note
        self.scorePlayer = scorePlayer
        self.scoreOpponent = scoreOpponent
        self.opponentName = opponentName
        self.bladeName = bladeName
        self.forehandRubber = forehandRubber
        self.backhandRubber = backhandRubber
    }
}
