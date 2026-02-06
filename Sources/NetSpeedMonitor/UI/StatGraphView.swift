import SwiftUI
import Charts

struct StatGraphView: View {
    let data: [Double]
    let color: Color
    let minRange: Double
    let maxRange: Double
    let height: CGFloat
    
    init(data: [Double], color: Color, minRange: Double, maxRange: Double, height: CGFloat = 20) {
        self.data = data
        self.color = color
        self.minRange = minRange
        self.maxRange = maxRange
        self.height = height
    }
    
    // Computed property to create points for the chart
    var chartPoints: [(index: Int, value: Double)] {
        data.enumerated().map { ($0, $1) }
    }
    
    var body: some View {
        Chart {
            ForEach(chartPoints, id: \.index) { point in
                AreaMark(
                    x: .value("Time", point.index),
                    y: .value("Value", point.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [color.opacity(0.5), color.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.monotone)
                
                LineMark(
                    x: .value("Time", point.index),
                    y: .value("Value", point.value)
                )
                .foregroundStyle(color)
                .interpolationMethod(.monotone)
                .lineStyle(StrokeStyle(lineWidth: 2.0))
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartYScale(domain: minRange...max(maxRange, data.max() ?? maxRange))
        .frame(height: height)
        .clipped()
    }
}
