import SwiftUI
import WidgetKit

struct PlaceholderEntry: TimelineEntry {
    let date: Date
    let title: String
    let subtitle: String
}

struct PlaceholderProvider: TimelineProvider {
    func placeholder(in context: Context) -> PlaceholderEntry {
        PlaceholderEntry(date: .now, title: "Pinned Snippet", subtitle: "Widget data stays stubbed in v1.")
    }

    func getSnapshot(in context: Context, completion: @escaping (PlaceholderEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PlaceholderEntry>) -> Void) {
        let entry = placeholder(in: context)
        completion(Timeline(entries: [entry], policy: .never))
    }
}

struct TextForgeWidgetView: View {
    var entry: PlaceholderEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.title)
                .font(.headline)
            Text(entry.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text("TextForge")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(AppTheme.accent)
        }
        .padding()
        .containerBackground(.background.tertiary, for: .widget)
    }
}

struct TextForgeWidget: Widget {
    let kind = "TextForgeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PlaceholderProvider()) { entry in
            TextForgeWidgetView(entry: entry)
        }
        .configurationDisplayName("TextForge")
        .description("Placeholder widget target for future snippet surfacing.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct TextForgeWidgetsBundle: WidgetBundle {
    var body: some Widget {
        TextForgeWidget()
    }
}
