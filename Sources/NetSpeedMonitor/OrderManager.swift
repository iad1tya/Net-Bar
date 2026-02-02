import SwiftUI
import Combine

class OrderManager: ObservableObject {
    @Published var sectionOrder: [String] = [] {
        didSet {
            saveOrder()
        }
    }
    
    private let key = "sectionOrder"
    private let defaultOrder = [
        "Traffic",
        "Connection",
        "Router",
        "DNS",
        "Internet",
        "Processor",
        "Memory",
        "Disk",
        "Battery",
        "Thermal State"
    ]
    
    init() {
        loadOrder()
    }
    
    private func loadOrder() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            
            // Ensure any new sections added in updates are included
            var validOrder = decoded // Start with saved order
            
            // Add any missing default items to the end
            for item in defaultOrder {
                if !validOrder.contains(item) {
                    validOrder.append(item)
                }
            }
            // Remove any obsolete items? Maybe better to keep for safety, or filter.
            // For now, filter to only known items to clean up trash
            sectionOrder = validOrder.filter { defaultOrder.contains($0) }
            
        } else {
            sectionOrder = defaultOrder
        }
    }
    
    private func saveOrder() {
        if let encoded = try? JSONEncoder().encode(sectionOrder) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func reset() {
        sectionOrder = defaultOrder
    }
}
