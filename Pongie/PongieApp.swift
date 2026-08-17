import SwiftUI
import SwiftData
import UIKit

enum QuickActionType: String {
    case quickLog = "pongie.quick-log"
    case gear = "pongie.gear"
    case analytics = "pongie.analytics"
    
    var urlScheme: String {
        switch self {
        case .quickLog: return "pongie://quick-log"
        case .gear: return "pongie://gear"
        case .analytics: return "pongie://analytics"
        }
    }
}

class QuickActionManager: ObservableObject {
    static let shared = QuickActionManager()
    
    @Published var selectedTab: Int = 0
    @Published var showAddSessionSheet: Bool = false
    
    /// Register dynamic shortcut items for long-pressing app icon
    func registerShortcutItems() {
        // Info.plist already configures static shortcut item "pongie.quick-log"
        // Clearing dynamic shortcutItems prevents duplicate menu items
        UIApplication.shared.shortcutItems = []
    }
    
    /// Handle shortcut item selection from long press menu
    func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        if shortcutItem.type == QuickActionType.quickLog.rawValue || shortcutItem.type.contains("quick-log") {
            navigateToQuickLog()
            return true
        }
        return false
    }
    
    /// Handle deep link URL (e.g. pongie://quick-log)
    func handleURL(_ url: URL) {
        guard url.scheme == "pongie" else { return }
        
        switch url.host {
        case "quick-log", "log":
            navigateToQuickLog()
        case "gear":
            navigateToTab(1)
        case "analytics":
            navigateToTab(2)
        default:
            break
        }
    }
    
    private func navigateToQuickLog() {
        DispatchQueue.main.async {
            self.selectedTab = 0
            self.showAddSessionSheet = true
        }
    }
    
    private func navigateToTab(_ tabIndex: Int) {
        DispatchQueue.main.async {
            self.selectedTab = tabIndex
        }
    }
}

// MARK: - AppDelegate for Shortcut Handling
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        QuickActionManager.shared.registerShortcutItems()
        
        if let shortcutItem = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
            _ = QuickActionManager.shared.handleShortcutItem(shortcutItem)
        }
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        let handled = QuickActionManager.shared.handleShortcutItem(shortcutItem)
        completionHandler(handled)
    }
}

@main
struct PongieApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var quickActionManager = QuickActionManager.shared

    var sharedModelContainer: ModelContainer = SharedModelContainer.create()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(quickActionManager)
        }
        .modelContainer(sharedModelContainer)
    }
}


