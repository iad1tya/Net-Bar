import SwiftUI
import Combine
import LaunchAtLogin
import SystemConfiguration
import NetTrafficStat

class MenuBarState: ObservableObject {
    // LaunchAtLogin handles the storage and state automatically
    // We can expose a binding or just use LaunchAtLogin.isEnabled directly in the view
    // But keeping a published property to sync might be useful if we want to observe changes,
    // though LaunchAtLogin.observable seems better. For now let's just leave it out of here
    // and use LaunchAtLogin directly in the view, OR wrapper it.
    // Let's wrapping it for simplicity in the View code we have.
    
    var autoLaunchEnabled: Bool {
        get { LaunchAtLogin.isEnabled }
        set { LaunchAtLogin.isEnabled = newValue }
    }
    
    @AppStorage("displayMode") var displayMode: DisplayMode = .both
    @AppStorage("showArrows") var showArrows: Bool = true
    @AppStorage("unitType") var unitType: UnitType = .bytes
    @AppStorage("fixedUnit") var fixedUnit: FixedUnit = .auto
    @AppStorage("fontSize") var fontSize: Double = 9.0
    @AppStorage("textSpacing") var textSpacing: Double = 0.0
    @AppStorage("characterSpacing") var characterSpacing: Double = 0.0
    @AppStorage("unstackNetworkUsage") var unstackNetworkUsage: Bool = false
    
    @AppStorage("showCPUMenu") var showCPUMenu: Bool = false
    @AppStorage("showMemoryMenu") var showMemoryMenu: Bool = false
    @AppStorage("showDiskMenu") var showDiskMenu: Bool = false
    
    @Published var menuText = ""
    
    var currentIcon: NSImage {
        return MenuBarIconGenerator.generateIcon(
            text: menuText,
            font: .monospacedSystemFont(ofSize: fontSize, weight: .semibold),
            spacing: textSpacing,
            kern: characterSpacing
        )
    }
    
    // Expose raw values for UI
    var currentUploadSpeed: Double { uploadSpeed }
    var currentDownloadSpeed: Double { downloadSpeed }
    
    private var timer: Timer?
    private var primaryInterface: String?
    private var netTrafficStat = NetTrafficStatReceiver()
    private var systemStatsService = SystemStatsService.shared
    
    // Session tracking
    @Published var totalUpload: Double = 0.0
    @Published var totalDownload: Double = 0.0
    @Published var appLaunchDate = Date()
    
    // Speed History for Graphs
    @Published var downloadHistory: [Double] = []
    @Published var uploadHistory: [Double] = []
    @Published var totalTrafficHistory: [Double] = []
    private let historyLimit = 60
    
    // Current Speed
    private var uploadSpeed: Double = 0.0
    private var downloadSpeed: Double = 0.0
    
    private let byteMetrics: [String] = [" B", "KB", "MB", "GB", "TB"]
    private let bitMetrics: [String] = [" b", "Kb", "Mb", "Gb", "Tb"]
    
    private func findPrimaryInterface() -> String? {
        let storeRef = SCDynamicStoreCreate(nil, "FindCurrentInterfaceIpMac" as CFString, nil, nil)
        let global = SCDynamicStoreCopyValue(storeRef, "State:/Network/Global/IPv4" as CFString)
        let primaryInterface = global?.value(forKey: "PrimaryInterface") as? String
        return primaryInterface
    }
    
    func formatSpeed(_ speed: Double) -> (String, String) {
        // Convert to bits if needed
        let value = unitType == .bits ? speed * 8 : speed
        
        let metrics = unitType == .bits ? bitMetrics : byteMetrics
        var scaledValue = value
        var metricIndex = 0
        
        if fixedUnit == .kb {
            scaledValue = value / 1024.0
            metricIndex = 1
        } else if fixedUnit == .mb {
            scaledValue = value / (1024.0 * 1024.0)
            metricIndex = 2
        } else {
            // Auto
            while scaledValue > 1024.0 && metricIndex < metrics.count - 1 {
                scaledValue /= 1024.0
                metricIndex += 1
            }
        }
        
        return (String(format: "%6.2lf", scaledValue), metrics[metricIndex] + (unitType == .bits ? "ps" : "/s"))
    }
    
    func formatBytes(_ bytes: Double) -> (String, String) {
         let metrics = byteMetrics // Always bytes for total
         var scaledValue = bytes
         var metricIndex = 0
         
         while scaledValue > 1024.0 && metricIndex < metrics.count - 1 {
             scaledValue /= 1024.0
             metricIndex += 1
         }
         
         return (String(format: "%.2f", scaledValue), metrics[metricIndex])
    }
    
    private func updateHistory<T>(_ history: inout [T], newValue: T) {
        history.append(newValue)
        if history.count > historyLimit {
            history.removeFirst()
        }
    }
    
    private func startTimer() {
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.primaryInterface = self.findPrimaryInterface()
                if (self.primaryInterface == nil) { return }
                
                if let netTrafficStatMap = self.netTrafficStat.getNetTrafficStatMap() {
                    if let netTrafficStat = netTrafficStatMap.object(forKey: self.primaryInterface!) as? NetTrafficStatOC  {
                        self.downloadSpeed = netTrafficStat.ibytes_per_sec as! Double
                        self.uploadSpeed = netTrafficStat.obytes_per_sec as! Double
                        
                        // Accumulate totals (speed is bytes per second, timer is 1s)
                        self.totalDownload += self.downloadSpeed
                        self.totalUpload += self.uploadSpeed
                        
                        // Update History
                        self.updateHistory(&self.downloadHistory, newValue: self.downloadSpeed)
                        self.updateHistory(&self.uploadHistory, newValue: self.uploadSpeed)
                        self.updateHistory(&self.totalTrafficHistory, newValue: self.downloadSpeed + self.uploadSpeed)
                        
                        let (downVal, downUnit) = self.formatSpeed(self.downloadSpeed)
                        let (upVal, upUnit) = self.formatSpeed(self.uploadSpeed)
                        
                        var networkSegments: [String] = []
                        
                        if self.displayMode == .both || self.displayMode == .uploadOnly {
                            networkSegments.append("\(self.showArrows ? "↑ " : "")\(upVal) \(upUnit)")
                        }
                        
                        if self.displayMode == .both || self.displayMode == .downloadOnly {
                            networkSegments.append("\(self.showArrows ? "↓ " : "")\(downVal) \(downUnit)")
                        }
                        
                        var text = networkSegments.joined(separator: self.unstackNetworkUsage ? " | " : "\n")
                        
                        // System Stats
                        var statsList: [String] = []
                        if self.showCPUMenu {
                            statsList.append("CPU: \(Int(self.systemStatsService.stats.cpuUsage))%")
                        }
                        if self.showMemoryMenu {
                            statsList.append("RAM: \(Int(self.systemStatsService.stats.memoryUsage))%")
                        }
                        if self.showDiskMenu {
                            statsList.append("HDD: \(Int(self.systemStatsService.stats.diskUsage))%")
                        }
                        
                        let systemStatsText = statsList.joined(separator: " | ")
                        
                        if !systemStatsText.isEmpty {
                            text = text.trimmingCharacters(in: .whitespacesAndNewlines) + " | " + systemStatsText
                        } else {
                            text = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                        
                        self.menuText = text
                    }
                }
            }
        RunLoop.current.add(timer, forMode: .common)
        self.timer = timer
    }
    
    private func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    init() {
        DispatchQueue.main.async {
            // Ensure valid display mode default
            if self.menuText.isEmpty { self.menuText = "..." }
            self.startTimer()
        }
    }
    
    deinit {
        DispatchQueue.main.async {
            self.stopTimer()
        }
    }
}

