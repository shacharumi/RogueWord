import SwiftUI
import WidgetKit

// 定義資料結構
struct WidgetData: Identifiable {
    let id = UUID()
    let english: String
    let chinese: String
}

// 定義 TimelineEntry
struct SimpleEntry: TimelineEntry {
    let date: Date
    let data: WidgetData
}

// 定義 Provider，負責提供 Widget 的更新內容
struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), data: WidgetData(english: "Placeholder English", chinese: "Placeholder Chinese"))
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), data: WidgetData(english: "Snapshot English", chinese: "Snapshot Chinese"))
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = SimpleEntry(date: Date(), data: WidgetData(english: "Timeline English", chinese: "Timeline Chinese"))
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

// Widget 的視圖顯示
struct WidgetView: View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            // 卡片背景
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white) // 卡片背景顏色
                .shadow(radius: 5) // 陰影效果

            VStack {
                // 英文文字
                Text(entry.data.english)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.black)

                // 中文文字
                Text(entry.data.chinese)
                    .font(.title)
                    .foregroundColor(.gray)
            }
            .padding() // 內邊距，讓文字不貼著邊框
        }
        .padding() // 外邊距，避免卡片緊貼 Widget 邊界
    }
}

// Widget 配置
@main
struct MyCardWidget: Widget {
    let kind: String = "MyCardWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetView(entry: entry)
        }
        .configurationDisplayName("小卡片 Widget")
        .description("展示一張帶有圓角和陰影的小卡片，內含英中文對照文字。")
        .supportedFamilies([.systemSmall]) // 只支持小尺寸
    }
}

// 預覽
struct MyCardWidget_Previews: PreviewProvider {
    static var previews: some View {
        WidgetView(entry: SimpleEntry(date: Date(), data: WidgetData(english: "Hello", chinese: "你好")))
            .previewContext(WidgetPreviewContext(family: .systemSmall)) // 僅顯示小尺寸預覽
    }
}
