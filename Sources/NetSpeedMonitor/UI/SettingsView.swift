import SwiftUI

struct SettingsView: View {
    @AppStorage("displayMode") private var displayMode: DisplayMode = .both
    @AppStorage("showArrows") private var showArrows: Bool = true
    @AppStorage("unitType") private var unitType: UnitType = .bytes
    @AppStorage("fixedUnit") private var fixedUnit: FixedUnit = .auto
    @AppStorage("fontSize") private var fontSize: Double = 9.0
    @AppStorage("textSpacing") private var textSpacing: Double = 0.0
    @AppStorage("characterSpacing") private var characterSpacing: Double = 0.0


    
    @EnvironmentObject var menuBarState: MenuBarState
    
    @State private var updateAvailable: Bool = false
    @State private var latestVersionURL: URL?
    @State private var isChecking: Bool = false

    var body: some View {
        Form {
            // App Header Section
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Net Bar")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("Version 1.3")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    if updateAvailable, let url = latestVersionURL {
                        Link("Update Available", destination: url)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.red)
                            .cornerRadius(6)
                    } else if isChecking {
                        ProgressView()
                            .controlSize(.small)
                            .padding(.horizontal, 8)
                    } else {
                        Button("Check for Updates") {
                            checkForUpdates()
                        }
                        .controlSize(.small)
                        // Using a plain/bordered style to make it look like a button
                        .buttonStyle(.bordered) 
                    }
                }
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Section("Behavior") {
                Toggle("Launch at Login", isOn: $menuBarState.autoLaunchEnabled)
                

            }
            
            Section("Appearance") {
                Picker("Display Mode", selection: $displayMode) {
                    Text("Both").tag(DisplayMode.both)
                    Text("Download").tag(DisplayMode.downloadOnly)
                    Text("Upload").tag(DisplayMode.uploadOnly)
                }
                .pickerStyle(.segmented)
                
                Toggle("Show Direction Arrows", isOn: $showArrows)
            }
                        Section("Display Sections") {
                    Toggle("Traffic", isOn: Binding(
                        get: { UserDefaults.standard.object(forKey: "showTraffic") as? Bool ?? true },
                        set: { UserDefaults.standard.set($0, forKey: "showTraffic") }
                    ))
                    Toggle("Connection", isOn: Binding(
                        get: { UserDefaults.standard.object(forKey: "showConnection") as? Bool ?? true },
                        set: { UserDefaults.standard.set($0, forKey: "showConnection") }
                    ))
                    Toggle("Router", isOn: Binding(
                        get: { UserDefaults.standard.object(forKey: "showRouter") as? Bool ?? true },
                        set: { UserDefaults.standard.set($0, forKey: "showRouter") }
                    ))
                    Toggle("DNS", isOn: Binding(
                        get: { UserDefaults.standard.object(forKey: "showDNS") as? Bool ?? true },
                        set: { UserDefaults.standard.set($0, forKey: "showDNS") }
                    ))
                    Toggle("Internet", isOn: Binding(
                        get: { UserDefaults.standard.object(forKey: "showInternet") as? Bool ?? true },
                        set: { UserDefaults.standard.set($0, forKey: "showInternet") }
                    ))
                    Toggle("Smart Tips", isOn: Binding(
                        get: { UserDefaults.standard.object(forKey: "showTips") as? Bool ?? true },
                        set: { UserDefaults.standard.set($0, forKey: "showTips") }
                    ))
                    Toggle("Traffic Header Text", isOn: Binding(
                        get: { UserDefaults.standard.object(forKey: "showTrafficHeader") as? Bool ?? false },
                        set: { UserDefaults.standard.set($0, forKey: "showTrafficHeader") }
                    ))
                }
                
                Section("Misc (System Stats)") {
                    VStack(alignment: .leading) {
                        Toggle("CPU Usage", isOn: Binding(
                            get: { UserDefaults.standard.object(forKey: "showCPU") as? Bool ?? false },
                            set: { UserDefaults.standard.set($0, forKey: "showCPU") }
                        ))
                        Toggle("Show in Menu Bar", isOn: $menuBarState.showCPUMenu)
                            .font(.caption)
                            .padding(.leading, 20)
                            .disabled(!(UserDefaults.standard.object(forKey: "showCPU") as? Bool ?? false))
                    }
                    
                    VStack(alignment: .leading) {
                        Toggle("Memory Usage", isOn: Binding(
                            get: { UserDefaults.standard.object(forKey: "showMemory") as? Bool ?? false },
                            set: { UserDefaults.standard.set($0, forKey: "showMemory") }
                        ))
                        Toggle("Show in Menu Bar", isOn: $menuBarState.showMemoryMenu)
                            .font(.caption)
                            .padding(.leading, 20)
                             .disabled(!(UserDefaults.standard.object(forKey: "showMemory") as? Bool ?? false))
                    }
                    
                    VStack(alignment: .leading) {
                        Toggle("Disk Usage", isOn: Binding(
                            get: { UserDefaults.standard.object(forKey: "showDisk") as? Bool ?? false },
                            set: { UserDefaults.standard.set($0, forKey: "showDisk") }
                        ))
                        Toggle("Show in Menu Bar", isOn: $menuBarState.showDiskMenu)
                            .font(.caption)
                            .padding(.leading, 20)
                             .disabled(!(UserDefaults.standard.object(forKey: "showDisk") as? Bool ?? false))
                    }
                    
                    Toggle("Energy / Battery", isOn: Binding(
                        get: { UserDefaults.standard.object(forKey: "showEnergy") as? Bool ?? false },
                        set: { UserDefaults.standard.set($0, forKey: "showEnergy") }
                    ))
                    
                    Toggle("Temperature", isOn: Binding(
                         get: { UserDefaults.standard.object(forKey: "showTemp") as? Bool ?? false },
                         set: { UserDefaults.standard.set($0, forKey: "showTemp") }
                     ))
                }
                
                Section("General") {
                Picker("Unit Type", selection: $unitType) {
                    Text("Bytes (MB/s)").tag(UnitType.bytes)
                    Text("Bits (Mbps)").tag(UnitType.bits)
                }
                .pickerStyle(.segmented)
                
                Picker("Fixed Scale", selection: $fixedUnit) {
                    Text("Automatic").tag(FixedUnit.auto)
                    Text("KB/s").tag(FixedUnit.kb)
                    Text("MB/s").tag(FixedUnit.mb)
                }
            }
            
            Section("Typography") {
                Grid(alignment: .leading, verticalSpacing: 10) {
                    GridRow {
                        Text("Font Size")
                            .gridColumnAlignment(.leading)
                        Slider(value: Binding(
                            get: { menuBarState.fontSize },
                            set: { menuBarState.fontSize = round($0) }
                        ), in: 9...16)
                            .frame(maxWidth: 200)
                        Text("\(Int(menuBarState.fontSize)) pt")
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                            .gridColumnAlignment(.leading)
                            .frame(width: 40, alignment: .trailing)
                    }
                    
                    GridRow {
                        Text("Line Spacing")
                        Slider(value: Binding(
                            get: { menuBarState.textSpacing },
                            set: { menuBarState.textSpacing = round($0) }
                        ), in: -5...10)
                            .frame(maxWidth: 200)
                        Text("\(Int(menuBarState.textSpacing)) pt")
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                            .frame(width: 40, alignment: .trailing)
                    }
                    
                    GridRow {
                        Text("Kerning")
                        Slider(value: Binding(
                            get: { menuBarState.characterSpacing },
                            set: { menuBarState.characterSpacing = (round($0 * 2) / 2) }
                        ), in: -2...5)
                            .frame(maxWidth: 200)
                        Text(String(format: "%.1f pt", menuBarState.characterSpacing))
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                            .frame(width: 40, alignment: .trailing)
                    }
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            
            Section("Support") {
                Link("Support the Developer", destination: URL(string: "https://support.iad1tya.cyou")!)
                    .foregroundStyle(.blue)
            }
            }

        .formStyle(.grouped)
        .padding() // Standard padding for the form
        .onAppear {
            checkForUpdates()
        }
    }
    
    func checkForUpdates() {
        isChecking = true
        guard let url = URL(string: "https://api.github.com/repos/iad1tya/Net-Bar/releases/latest") else {
            isChecking = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            defer {
                DispatchQueue.main.async {
                    self.isChecking = false
                }
            }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let tagName = json["tag_name"] as? String,
                  let htmlUrlString = json["html_url"] as? String,
                  let htmlUrl = URL(string: htmlUrlString) else {
                return
            }
            
            DispatchQueue.main.async {
                let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
                
                // Strip 'v' prefix if present
                let remoteVersion = tagName.replacingOccurrences(of: "v", with: "")
                let localVersion = currentVersion.replacingOccurrences(of: "v", with: "")
                
                if remoteVersion != localVersion {
                    self.updateAvailable = true
                    self.latestVersionURL = htmlUrl
                }
            }
        }.resume()
    }
    

}


enum DisplayMode: String, CaseIterable, Identifiable {
    case both, downloadOnly, uploadOnly
    var id: Self { self }
}

enum UnitType: String, CaseIterable, Identifiable {
    case bytes, bits
    var id: Self { self }
}

enum FixedUnit: String, CaseIterable, Identifiable {
    case auto, kb, mb
    var id: Self { self }
}
