import Foundation
import SwiftData

public struct SharedModelContainer {
    public static let appGroupID = "group.com.antigravity.pongie"
    
    @MainActor
    public static func create() -> ModelContainer {
        let schema = Schema([
            PingPongSession.self,
            GearItem.self
        ])
        
        let containerURL: URL? = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
        let modelConfiguration: ModelConfiguration
        
        if let appGroupURL = containerURL {
            let storeURL = appGroupURL.appendingPathComponent("default.store")
            migrateExistingDatabaseToAppGroupIfNeeded(targetStoreURL: storeURL)
            modelConfiguration = ModelConfiguration(schema: schema, url: storeURL)
        } else {
            modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        }
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("Failed to create shared ModelContainer with App Group URL: \(error). Falling back to default container.")
            do {
                let defaultConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
                return try ModelContainer(for: schema, configurations: [defaultConfig])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }
    
    private static func migrateExistingDatabaseToAppGroupIfNeeded(targetStoreURL: URL) {
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: targetStoreURL.path) {
            return
        }
        
        guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return
        }
        
        let oldStoreURL = appSupportURL.appendingPathComponent("default.store")
        
        if fileManager.fileExists(atPath: oldStoreURL.path) {
            let targetDir = targetStoreURL.deletingLastPathComponent()
            try? fileManager.createDirectory(at: targetDir, withIntermediateDirectories: true)
            
            let filesToCopy = [
                "default.store",
                "default.store-shm",
                "default.store-wal"
            ]
            
            for fileName in filesToCopy {
                let src = appSupportURL.appendingPathComponent(fileName)
                let dst = targetDir.appendingPathComponent(fileName)
                if fileManager.fileExists(atPath: src.path) && !fileManager.fileExists(atPath: dst.path) {
                    try? fileManager.copyItem(at: src, to: dst)
                }
            }
        }
    }
}
