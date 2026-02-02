import SwiftUI
import Charts

struct DetailedStatusView: View {
    @StateObject private var statsService = NetworkStatsService()
    @EnvironmentObject var menuBarState: MenuBarState
    @Environment(\.openWindow) var openWindow
    
    @State private var uptimeString: String = "00:00:00"
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @AppStorage("showTraffic") private var showTraffic = true
    @AppStorage("showConnection") private var showConnection = true
    @AppStorage("showRouter") private var showRouter = true
    @AppStorage("showDNS") private var showDNS = true
    @AppStorage("showInternet") private var showInternet = true
    @AppStorage("showTips") private var showTips = true
    @AppStorage("showTrafficHeader") private var showTrafficHeader = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text("Net Bar")
                        .font(.headline)
                    Text("Network Diagnostics")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "gearshape")
                    .foregroundStyle(.secondary)
                    .onTapGesture {
                        NSApp.activate(ignoringOtherApps: true)
                        openWindow(id: "settings")
                    }
            }
            Divider()
            
            // Usage Header (SSID)
            HStack {
                 Circle()
                     .fill(Color.green)
                     .frame(width: 8, height: 8)
                 Text(statsService.stats.ssid.isEmpty ? "Wi-Fi" : statsService.stats.ssid)
                     .font(.headline)
                 
                 if !statsService.stats.band.isEmpty {
                     Text(statsService.stats.band)
                         .font(.caption)
                         .padding(.horizontal, 6)
                         .padding(.vertical, 2)
                         .background(Color.gray.opacity(0.3))
                         .cornerRadius(4)
                 }
            } 
            
            // Traffic Section
            if showTraffic {
                VStack(alignment: .leading) {
                    if showTrafficHeader {
                        Text("Traffic")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                    }
                    
                    Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 12) {
                        GridRow(alignment: .center) {
                            Text("Download")
                                .foregroundStyle(.secondary)
                            Text(menuBarState.formatBytes(menuBarState.totalDownload).0 + " " + menuBarState.formatBytes(menuBarState.totalDownload).1)
                                .foregroundStyle(.green)
                                .monospacedDigit()
                            StatGraphView(
                                data: menuBarState.downloadHistory,
                                color: .green,
                                minRange: 0, maxRange: 1024 * 1024,
                                height: 16
                            )
                        }
                        GridRow(alignment: .center) {
                            Text("Upload")
                                .foregroundStyle(.secondary)
                            Text(menuBarState.formatBytes(menuBarState.totalUpload).0 + " " + menuBarState.formatBytes(menuBarState.totalUpload).1)
                                .foregroundStyle(.blue)
                                .monospacedDigit()
                            StatGraphView(
                                data: menuBarState.uploadHistory,
                                color: .blue,
                                minRange: 0, maxRange: 1024 * 1024,
                                height: 16
                            )
                        }
                        GridRow(alignment: .center) {
                             Text("Total")
                                .foregroundStyle(.secondary)
                             Text(menuBarState.formatBytes(menuBarState.totalDownload + menuBarState.totalUpload).0 + " " + menuBarState.formatBytes(menuBarState.totalDownload + menuBarState.totalUpload).1)
                                 .foregroundStyle(.purple)
                                 .monospacedDigit()
                             StatGraphView(
                                 data: menuBarState.totalTrafficHistory,
                                 color: .purple,
                                 minRange: 0, maxRange: 1024 * 1024 * 2,
                                 height: 16
                             )
                         }
                    }
                }
            }

            if showConnection {
                // Divider only if previous sections (like Traffic) might be visible, or just always show divider if section is visible (simplest)
                if showTraffic { Divider() }
                
                // Connection Section
                VStack(alignment: .leading) {
                    Text("Connection")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                        
                    Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 12) {
                        GridRow(alignment: .center) {
                            Text("Link Rate")
                                .foregroundStyle(.secondary)
                            Text("\(Int(statsService.stats.txRate)) Mbps")
                                .foregroundStyle(.green)
                                .monospacedDigit()
                            StatGraphView(
                                data: Array(repeating: statsService.stats.txRate, count: 20),
                                color: .green,
                                minRange: 0, maxRange: 1000,
                                height: 16
                            )
                        }
                        
                        GridRow(alignment: .center) {
                            Text("Signal")
                                .foregroundStyle(.secondary)
                            Text("\(statsService.stats.rssi) dBm")
                                .foregroundStyle(.orange)
                                .monospacedDigit()
                            StatGraphView(
                                data: statsService.signalHistory.map { Double($0) },
                                color: .orange,
                                minRange: -100, maxRange: -30,
                                height: 16
                            )
                        }
                        
                        GridRow(alignment: .center) {
                            Text("Noise")
                                .foregroundStyle(.secondary)
                            Text("\(statsService.stats.noise) dBm")
                                .foregroundStyle(.green)
                                .monospacedDigit()
                            StatGraphView(
                                data: statsService.noiseHistory.map { Double($0) },
                                color: .green,
                                minRange: -110, maxRange: -80,
                                height: 16
                            )
                        }
                    }
                }
            }
            
            if showRouter {
                if showTraffic || showConnection { Divider() }
                
                // Router Section
                VStack(alignment: .leading) {
                    Text("Router")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                    
                    Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 12) {
                        GridRow(alignment: .center) {
                            Text("Ping")
                                .foregroundStyle(.secondary)
                            Text(String(format: "%.0f ms", statsService.stats.routerPing))
                                .foregroundStyle(.green)
                                .monospacedDigit()
                            StatGraphView(
                                data: statsService.routerPingHistory,
                                color: .green,
                                minRange: 0, maxRange: 100,
                                height: 16
                            )
                        }
                        
                        GridRow(alignment: .center) {
                            Text("Jitter")
                                .foregroundStyle(.secondary)
                            Text(String(format: "%.1f ms", statsService.stats.routerJitter))
                                .foregroundStyle(.yellow)
                                .monospacedDigit()
                             StatGraphView(
                                data: statsService.routerPingHistory.map { abs($0 - statsService.stats.routerPing) },
                                color: .yellow,
                                minRange: 0, maxRange: 50,
                                height: 16
                            )
                        }
                        
                        GridRow(alignment: .center) {
                            Text("Loss")
                                .foregroundStyle(.secondary)
                            Text(String(format: "%.0f%%", statsService.stats.routerLoss))
                                .foregroundStyle(.yellow)
                                .monospacedDigit()
                            Rectangle().fill(Color.orange).frame(height: 2)
                        }
                    }
                }
            }

            if showDNS {
                if showTraffic || showConnection || showRouter { Divider() }
                
                // DNS Section
                VStack(alignment: .leading) {
                    Text("DNS Router Assigned")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                    
                    Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 12) {
                         GridRow(alignment: .center) {
                             Text(statsService.stats.dns.isEmpty ? "Unknown" : statsService.stats.dns)
                                 .foregroundStyle(.secondary)
                             Text(String(format: "%.0f ms", statsService.stats.dnsPing))
                                 .foregroundStyle(.cyan)
                                 .monospacedDigit()
                             StatGraphView(
                                 data: statsService.dnsPingHistory,
                                 color: .cyan,
                                 minRange: 0, maxRange: 100,
                                 height: 16
                             )
                         }
                    }
                }
            }
            
            if showInternet {
                if showTraffic || showConnection || showRouter || showDNS { Divider() }
                
                // Internet Section
                VStack(alignment: .leading) {
                    Text("Internet - 1.1.1.1")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                        
                     Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 12) {
                        GridRow(alignment: .center) {
                            Text("Ping")
                                .foregroundStyle(.secondary)
                            Text(String(format: "%.0f ms", statsService.stats.ping))
                                .foregroundStyle(.yellow)
                                .monospacedDigit()
                            StatGraphView(
                                data: statsService.pingHistory,
                                color: .yellow,
                                minRange: 0, maxRange: 200,
                                height: 16
                            )
                        }
                        
                        GridRow(alignment: .center) {
                            Text("Jitter")
                                .foregroundStyle(.secondary)
                            Text(String(format: "%.1f ms", statsService.stats.jitter))
                                 .foregroundStyle(.red)
                                .monospacedDigit()
                             StatGraphView(
                                data: statsService.pingHistory.map { abs($0 - statsService.stats.ping) },
                                color: .red,
                                minRange: 0, maxRange: 50,
                                height: 16
                            )
                        }
                    }
                }
            }
            
            Divider()
            
            // Tips Section
            if showTips && !tips.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Tips", systemImage: "lightbulb.fill")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.yellow)
                    
                    ForEach(tips, id: \.self) { tip in
                        Text("• " + tip)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Divider()
            }
            
            // Quit Button
            Button(action: {
                NSApp.terminate(nil)
            }) {
                HStack {
                    Image(systemName: "power")
                    Text("Quit App")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.red.opacity(0.1))
                .foregroundStyle(.red)
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .frame(width: 350)
        .background(Color(NSColor.windowBackgroundColor))
        .onReceive(timer) { input in
            let diff = input.timeIntervalSince(menuBarState.appLaunchDate)
            let hours = Int(diff) / 3600
            let minutes = (Int(diff) % 3600) / 60
            let seconds = Int(diff) % 60
            uptimeString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }
    
    // Smart Tips Logic
    var tips: [String] {
        var list: [String] = []
        let s = statsService.stats
        
        if s.rssi < -75 && s.rssi != 0 {
            list.append("Weak Wi-Fi signal. Move closer to your router.")
        }
        if s.txRate < 50 && s.txRate > 0 {
            list.append("Low link rate. Wi-Fi might be slow.")
        }
        if s.noise > -85 && s.noise != 0 {
            list.append("High interference (Noise). Try changing Wi-Fi channel.")
        }
        if s.routerLoss > 1.0 {
            list.append("Packet loss detected to router. Connection unstable.")
        }
        if s.routerJitter > 50 {
            list.append("High jitter detected. Calls may be choppy.")
        }
        
        return list
    }
}
