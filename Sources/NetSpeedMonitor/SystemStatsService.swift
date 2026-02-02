import Foundation
import Combine
import IOKit.ps
import MachO

struct SystemStats {
    var cpuUsage: Double = 0.0
    var memoryUsage: Double = 0.0 // Percentage
    var memoryUsed: Double = 0.0 // GB
    var memoryTotal: Double = 0.0 // GB
    var diskUsage: Double = 0.0 // Percentage
    var diskFree: Double = 0.0 // GB
    var batteryLevel: Double = 0.0
    var isCharging: Bool = false
    var timeRemaining: Int = -1 // Minutes, -1 if unknown
    var thermalPressure: String = "Normal"
    var physicalCores: Int = ProcessInfo.processInfo.processorCount
    var activeCores: Int = ProcessInfo.processInfo.activeProcessorCount
}

class SystemStatsService: ObservableObject {
    @Published var stats = SystemStats()
    
    static let shared = SystemStatsService()
    
    // CPU
    private var lastTotalTicks: UInt64 = 0
    private var lastUserTicks: UInt64 = 0
    private var lastSystemTicks: UInt64 = 0
    private var lastNiceTicks: UInt64 = 0
    
    // History (for graphs if needed later, keeping it simple for now)
    @Published var cpuHistory: [Double] = []
    @Published var memoryHistory: [Double] = []
    @Published var diskHistory: [Double] = []
    @Published var batteryHistory: [Double] = []
    @Published var thermalHistory: [Double] = []
    
    private var timer: Timer?
    private let historyLimit = 60
    
    private init() {
        // Pre-fill history to avoid graph resizing
        cpuHistory = Array(repeating: 0.0, count: historyLimit)
        memoryHistory = Array(repeating: 0.0, count: historyLimit)
        diskHistory = Array(repeating: 0.0, count: historyLimit)
        batteryHistory = Array(repeating: 0.0, count: historyLimit)
        thermalHistory = Array(repeating: 0.0, count: historyLimit)
        
        startMonitoring()
    }
    
    func startMonitoring() {
        // Stop existing if any
        stopMonitoring()
        
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateStats()
        }
        RunLoop.current.add(timer, forMode: .common)
        self.timer = timer
        
        // Initial update immediately
        updateStats()
    }
    
    func stopMonitoring() {
        timer?.invalidate()
    }
    
    private func updateStats() {
        updateCPU()
        updateMemory()
        updateDisk()
        updateBattery()
        updateThermal()
    }
    
    // MARK: - CPU
    private func updateCPU() {
        var hostInfo = host_cpu_load_info()
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info>.size / MemoryLayout<integer_t>.size)
        
        let result = withUnsafeMutablePointer(to: &hostInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
            }
        }
        
        if result == KERN_SUCCESS {
            let totalTicks = UInt64(hostInfo.cpu_ticks.0 + hostInfo.cpu_ticks.1 + hostInfo.cpu_ticks.2 + hostInfo.cpu_ticks.3)
            let userTicks = UInt64(hostInfo.cpu_ticks.0)
            let systemTicks = UInt64(hostInfo.cpu_ticks.1)
            let niceTicks = UInt64(hostInfo.cpu_ticks.3)
            
            let totalDiff = totalTicks - lastTotalTicks
            let userDiff = userTicks - lastUserTicks
            let systemDiff = systemTicks - lastSystemTicks
            let niceDiff = niceTicks - lastNiceTicks
            
            if totalDiff > 0 {
                let busyTicks = userDiff + systemDiff + niceDiff
                let cpu = Double(busyTicks) / Double(totalDiff) * 100.0
                
                DispatchQueue.main.async {
                    self.stats.cpuUsage = cpu
                    self.updateHistory(&self.cpuHistory, newValue: cpu)
                }
            }
            
            lastTotalTicks = totalTicks
            lastUserTicks = userTicks
            lastSystemTicks = systemTicks
            lastNiceTicks = niceTicks
        }
    }
    
    // MARK: - Memory
    private func updateMemory() {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
        
        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        
        if result == KERN_SUCCESS {
            let pageSize = UInt64(getpagesize())
            let active = UInt64(stats.active_count) * pageSize
            let wired = UInt64(stats.wire_count) * pageSize
            let compressed = UInt64(stats.compressor_page_count) * pageSize
            let total = ProcessInfo.processInfo.physicalMemory
            
            let used = Double(active + wired + compressed)
            let totalBytes = Double(total)
            
            DispatchQueue.main.async {
                self.stats.memoryUsed = used / 1_073_741_824.0 // GB
                self.stats.memoryTotal = totalBytes / 1_073_741_824.0 // GB
                let usage = (used / totalBytes) * 100.0
                self.stats.memoryUsage = usage
                self.updateHistory(&self.memoryHistory, newValue: usage)
            }
        }
    }
    
    // MARK: - Disk
    private func updateDisk() {
        let fileURL = URL(fileURLWithPath: "/")
        do {
            let values = try fileURL.resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityKey])
            if let capacity = values.volumeTotalCapacity, let available = values.volumeAvailableCapacity {
                let total = Double(capacity)
                let free = Double(available)
                let used = total - free
                
                DispatchQueue.main.async {
                    let usage = (used / total) * 100.0
                    self.stats.diskUsage = usage
                    self.stats.diskFree = free / 1_073_741_824.0 // GB
                    self.updateHistory(&self.diskHistory, newValue: usage)
                }
            }
        } catch {}
    }
    
    // MARK: - Battery (Energy)
    private func updateBattery() {
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array
        
        for source in sources {
            if let description = IOPSGetPowerSourceDescription(snapshot, source).takeUnretainedValue() as? [String: Any] {
                if let type = description[kIOPSTypeKey] as? String, type == kIOPSInternalBatteryType {
                    if let current = description[kIOPSCurrentCapacityKey] as? Int,
                       let max = description[kIOPSMaxCapacityKey] as? Int {
                        DispatchQueue.main.async {
                            let level = Double(current) / Double(max) * 100.0
                            self.stats.batteryLevel = level
                            self.updateHistory(&self.batteryHistory, newValue: level)
                        }
                    }
                    if let charging = description[kIOPSIsChargingKey] as? Bool {
                         DispatchQueue.main.async {
                             self.stats.isCharging = charging
                         }
                    }
                    if let time = description[kIOPSTimeToEmptyKey] as? Int {
                        DispatchQueue.main.async { self.stats.timeRemaining = time }
                    } else {
                        DispatchQueue.main.async { self.stats.timeRemaining = -1 }
                    }
                }
            }
        }
    }
    
    // MARK: - Thermal
    private func updateThermal() {
         let state = ProcessInfo.processInfo.thermalState
         var stateString = "Normal"
         var stateValue = 0.0
         
         switch state {
         case .nominal:
             stateString = "Normal"
             stateValue = 0.0
         case .fair:
             stateString = "Fair"
             stateValue = 33.0
         case .serious:
             stateString = "Serious"
             stateValue = 66.0
         case .critical:
             stateString = "Critical"
             stateValue = 100.0
         @unknown default:
             stateString = "Unknown"
             stateValue = 0.0
         }
        
         DispatchQueue.main.async {
             self.stats.thermalPressure = stateString
             self.updateHistory(&self.thermalHistory, newValue: stateValue)
         }
    }
    
    private func updateHistory<T>(_ history: inout [T], newValue: T) {
        history.append(newValue)
        if history.count > historyLimit {
            history.removeFirst()
        }
    }
}
