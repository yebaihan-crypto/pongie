import SwiftUI

/// 倒方向的“球感稳定”乒乓球图标组件
struct InvertedSolidBallIconView: View {
    var size: CGFloat = 80
    var showAppIconFrame: Bool = false
    
    var body: some View {
        let content = ZStack {
            // 球体主体
            Circle()
                .fill(Color.pongOrange)
                .overlay(
                    Circle()
                        .stroke(Color.sketchLine, lineWidth: max(2, size * 0.04))
                )
                .shadow(color: Color.black.opacity(0.12), radius: size * 0.04, x: 2, y: 3)
            
            // 左侧缝合线（倒置后的弧线）
            Path { path in
                let r = size / 2.0
                path.addArc(
                    center: CGPoint(x: r * 0.35, y: r),
                    radius: r * 0.65,
                    startAngle: .degrees(110),
                    endAngle: .degrees(250),
                    clockwise: false
                )
            }
            .stroke(
                Color.white.opacity(0.6),
                style: StrokeStyle(
                    lineWidth: max(1.5, size * 0.035),
                    lineCap: .round,
                    dash: [max(3, size * 0.05), max(2, size * 0.03)]
                )
            )
            
            // 倒方向“球感稳定”表情：顶部倒弧眉 + 右上金星 + 左下圆点眼
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w / 2.0
                let cy = h / 2.0
                let r = min(w, h) / 2.0
                
                ZStack {
                    // 1. 顶部拱形表情弧线 ⌒
                    Path { p in
                        p.addArc(
                            center: CGPoint(x: cx - r * 0.05, y: cy - r * 0.1),
                            radius: r * 0.22,
                            startAngle: .degrees(190),
                            endAngle: .degrees(350),
                            clockwise: false
                        )
                    }
                    .stroke(
                        Color.sketchLine,
                        style: StrokeStyle(lineWidth: max(2, r * 0.1), lineCap: .round)
                    )
                    
                    // 2. 右上角发光金星 ⭐
                    Text("⭐")
                        .font(.system(size: r * 0.38))
                        .shadow(color: Color.yellow.opacity(0.6), radius: 3)
                        .position(x: cx + r * 0.32, y: cy - r * 0.08)
                    
                    // 3. 左下角实心眼睛点 •
                    Circle()
                        .fill(Color.sketchLine)
                        .frame(width: max(4, r * 0.22), height: max(4, r * 0.22))
                        .position(x: cx - r * 0.12, y: cy + r * 0.28)
                }
            }
        }
        .frame(width: size, height: size)
        
        if showAppIconFrame {
            // 极简单层 AppIcon 风格（满版温暖橙色，去除多层白框嵌套）
            ZStack {
                Color.pongOrange
                
                content
                    .scaleEffect(0.85)
            }
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
        } else {
            content
        }
    }
}

#if canImport(UIKit)
import UIKit

extension InvertedSolidBallIconView {
    @MainActor
    static func asUIImage(size: CGFloat = 30) -> UIImage? {
        let renderer = ImageRenderer(content: InvertedSolidBallIconView(size: size))
        return renderer.uiImage
    }
}
#endif

#Preview {
    VStack(spacing: 20) {
        InvertedSolidBallIconView(size: 100, showAppIconFrame: false)
        InvertedSolidBallIconView(size: 120, showAppIconFrame: true)
    }
    .padding()
    .background(Color.pongBgPastel)
}
