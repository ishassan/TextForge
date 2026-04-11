import SwiftUI

enum AppTheme {
    static let accent = Color(red: 0.10, green: 0.42, blue: 0.76)
    static let surface = Color(red: 0.96, green: 0.97, blue: 0.99)
    static let panel = Color(red: 0.90, green: 0.94, blue: 0.98)
    static let warm = Color(red: 0.93, green: 0.56, blue: 0.22)
}

struct TextForgeCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppTheme.surface)
            )
    }
}

extension View {
    func textForgeCard() -> some View {
        modifier(TextForgeCardModifier())
    }
}
