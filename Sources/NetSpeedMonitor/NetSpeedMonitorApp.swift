import SwiftUI

@main
struct NetSpeedMonitorApp: App {
    @StateObject private var menuBarState = MenuBarState()
    @StateObject private var orderManager = OrderManager()
    
    var body: some Scene {
        MenuBarExtra {
            DetailedStatusView()
                .environmentObject(menuBarState)
                .environmentObject(orderManager)
        } label: {
            Image(nsImage: menuBarState.currentIcon)
        }
        .menuBarExtraStyle(.window)
        
        WindowGroup("Settings", id: "settings") {
            SettingsView()
                .frame(width: 450, height: 600) // Default size, but resizable by user/system
                .environmentObject(menuBarState)
                .environmentObject(orderManager)
        }
        .windowResizability(.contentSize)
    }
}
