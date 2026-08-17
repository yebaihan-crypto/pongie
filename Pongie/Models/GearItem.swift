import Foundation
import SwiftData

enum GearCategory: String, Codable, CaseIterable {
    case blade = "底板"
    case forehandRubber = "正手胶皮"
    case backhandRubber = "反手胶皮"
}

@Model
final class GearItem {
    @Attribute(.unique) var id: UUID
    var name: String
    var brand: String
    var categoryRaw: String
    var installDate: Date
    var totalHoursUsed: Int
    var recommendedMaxHours: Int
    var isCurrentActive: Bool
    
    var category: GearCategory {
        get { GearCategory(rawValue: categoryRaw) ?? .blade }
        set { categoryRaw = newValue.rawValue }
    }
    
    var usagePercentage: Double {
        guard recommendedMaxHours > 0 else { return 0 }
        return min(1.0, Double(totalHoursUsed) / Double(recommendedMaxHours))
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        brand: String,
        category: GearCategory,
        installDate: Date = Date(),
        totalHoursUsed: Int = 0,
        recommendedMaxHours: Int = 100,
        isCurrentActive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.categoryRaw = category.rawValue
        self.installDate = installDate
        self.totalHoursUsed = totalHoursUsed
        self.recommendedMaxHours = recommendedMaxHours
        self.isCurrentActive = isCurrentActive
    }
}
