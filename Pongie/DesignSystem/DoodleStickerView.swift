import SwiftUI

struct DoodleStickerView: View {
    let title: String
    var color: Color = .stickerYellow
    var rotationAngle: Double = -5
    
    var body: some View {
        Text(title)
            .font(.system(.subheadline, design: .rounded))
            .fontWeight(.bold)
            .foregroundColor(.sketchLine)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.sketchLine, lineWidth: 2)
            )
            .overlay(
                // Tape effect
                Rectangle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 24, height: 10)
                    .rotationEffect(.degrees(15))
                    .offset(y: -14),
                alignment: .topLeading
            )
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 1, y: 2)
            .rotationEffect(.degrees(rotationAngle))
    }
}
