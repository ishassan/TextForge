import SwiftUI

struct OnboardingView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(alignment: .leading, spacing: 16) {
                Text("TextForge")
                    .font(.system(size: 42, weight: .bold, design: .rounded))

                Text("Local-first text tooling for snippets, notes, and repeatable transformations.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 14) {
                featureCard(
                    title: "Snippets",
                    body: "Capture clipboard content privately, organize tags, and pin the things you use every day.",
                    systemImage: "paperclip"
                )
                featureCard(
                    title: "Editor",
                    body: "Write in markdown, preview live, and keep internal notes on-device with external files treated as peers.",
                    systemImage: "square.and.pencil"
                )
                featureCard(
                    title: "Actions",
                    body: "Run reusable text workflows across selections, documents, snippets, or pasted text.",
                    systemImage: "bolt.horizontal"
                )
            }

            Spacer()

            Button("Start Writing", action: onContinue)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [AppTheme.panel, .white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }

    private func featureCard(title: String, body: String, systemImage: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(AppTheme.accent)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(body)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .textForgeCard()
    }
}
