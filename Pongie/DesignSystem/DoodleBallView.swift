import SwiftUI

struct DoodleBallView: View {
    let mood: MoodType
    let size: BallSize
    var isTilted: Bool = false
    
    var body: some View {
        ZStack {
            // Hand-drawn Crayon Circle Base
            Circle()
                .fill(Color.pongOrange)
                .overlay(
                    Circle()
                        .stroke(Color.sketchLine, lineWidth: 3)
                )
                .shadow(color: Color.black.opacity(0.15), radius: 3, x: 2, y: 3)
            
            // Ping Pong Ball Seam Line
            Path { path in
                let r = size.radius
                path.addArc(
                    center: CGPoint(x: r * 0.8, y: r),
                    radius: r * 0.6,
                    startAngle: .degrees(-70),
                    endAngle: .degrees(70),
                    clockwise: false
                )
            }
            .stroke(Color.white.opacity(0.5), style: StrokeStyle(lineWidth: 2.5, lineCap: .round, dash: [4, 2]))
            
            // Doodle Face Expression
            DoodleFaceView(mood: mood, radius: size.radius)
        }
        .frame(width: size.radius * 2, height: size.radius * 2)
        .rotationEffect(.degrees(isTilted ? -8 : 0))
    }
}

struct DoodleFaceView: View {
    let mood: MoodType
    let radius: CGFloat
    
    private var eyeSize: CGFloat { max(4, radius * 0.22) }
    private var lineWidth: CGFloat { max(2, radius * 0.08) }
    
    var body: some View {
        Group {
            switch mood {
            case .onFire:
                // 状态爆棚：星光双眼 + 哈哈大笑
                VStack(spacing: radius * 0.06) {
                    HStack(spacing: radius * 0.3) {
                        Text("🔥").font(.system(size: radius * 0.35))
                        Text("🔥").font(.system(size: radius * 0.35))
                    }
                    Path { p in
                        p.addArc(center: CGPoint(x: radius * 0.25, y: 0), radius: radius * 0.2, startAngle: .degrees(0), endAngle: .degrees(180), clockwise: false)
                    }
                    .stroke(Color.sketchLine, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .frame(width: radius * 0.5, height: radius * 0.2)
                }
                
            case .joyful:
                // 快乐拉满：弧线笑眼 + 开怀大笑
                VStack(spacing: radius * 0.05) {
                    HStack(spacing: radius * 0.3) {
                        Text("^").font(.system(size: radius * 0.35, weight: .black))
                        Text("^").font(.system(size: radius * 0.35, weight: .black))
                    }
                    .foregroundColor(.sketchLine)
                    .offset(y: radius * 0.05)
                    
                    Path { p in
                        p.addArc(center: CGPoint(x: radius * 0.25, y: 0), radius: radius * 0.22, startAngle: .degrees(10), endAngle: .degrees(170), clockwise: false)
                    }
                    .stroke(Color.sketchLine, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .frame(width: radius * 0.5, height: radius * 0.2)
                }
                
            case .solid:
                // 球感稳定：星星眨眼 + 弧度微笑
                VStack(spacing: radius * 0.05) {
                    HStack(spacing: radius * 0.25) {
                        Text("⭐").font(.system(size: radius * 0.32))
                        Circle().fill(Color.sketchLine).frame(width: eyeSize, height: eyeSize)
                    }
                    Path { p in
                        p.addArc(center: CGPoint(x: radius * 0.25, y: 0), radius: radius * 0.18, startAngle: .degrees(10), endAngle: .degrees(170), clockwise: false)
                    }
                    .stroke(Color.sketchLine, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .frame(width: radius * 0.5, height: radius * 0.18)
                }
                
            case .exhausted:
                // 大汗淋漓：> < 眼睛 + 汗珠
                HStack(spacing: 2) {
                    VStack(spacing: radius * 0.06) {
                        HStack(spacing: radius * 0.25) {
                            Text(">").font(.system(size: radius * 0.3, weight: .black))
                            Text("<").font(.system(size: radius * 0.3, weight: .black))
                        }
                        .foregroundColor(.sketchLine)
                        
                        Capsule()
                            .fill(Color.sketchLine)
                            .frame(width: radius * 0.35, height: lineWidth)
                    }
                    Text("💦").font(.system(size: radius * 0.3))
                        .offset(y: -radius * 0.1)
                }
                
            case .frustrated:
                // 吃发球吃到饱：> < 眼睛 + 直线横嘴
                VStack(spacing: radius * 0.08) {
                    HStack(spacing: radius * 0.25) {
                        Text(">").font(.system(size: radius * 0.32, weight: .black))
                        Text("<").font(.system(size: radius * 0.32, weight: .black))
                    }
                    .foregroundColor(.sketchLine)
                    
                    Capsule()
                        .fill(Color.sketchLine)
                        .frame(width: radius * 0.4, height: max(2.5, lineWidth))
                }
                
            case .dizzy:
                // 眩晕出界：蓝色漩涡眼睛 🌀 🌀
                HStack(spacing: radius * 0.15) {
                    Text("🌀").font(.system(size: radius * 0.38))
                    Text("🌀").font(.system(size: radius * 0.38))
                }
                
            case .cheeky:
                // 吐舌顽抗：^ ^ 眼睛 + 吐舌头
                VStack(spacing: 1) {
                    HStack(spacing: radius * 0.3) {
                        Text("^").font(.system(size: radius * 0.32, weight: .black))
                        Text("^").font(.system(size: radius * 0.32, weight: .black))
                    }
                    .foregroundColor(.sketchLine)
                    
                    Text("👅").font(.system(size: radius * 0.32))
                        .offset(y: -radius * 0.05)
                }
                }
        }
    }
}

