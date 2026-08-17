import SwiftUI
import SwiftData
import WidgetKit

struct AddGearSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name: String = ""
    @State private var brand: String = ""
    @State private var category: GearCategory = .forehandRubber
    @State private var installDate: Date = Date()
    @State private var totalHoursUsed: Int = 0
    @State private var recommendedMaxHours: Int = 60
    
    private let quickTemplates: [(name: String, brand: String, category: GearCategory, maxHours: Int)] = [
        ("狂飚3 国套 40度", "DHS 红双喜", .forehandRubber, 60),
        ("Tenergy 05 (T05)", "Butterfly 蝴蝶", .backhandRubber, 80),
        ("Dignics 09C", "Butterfly 蝴蝶", .forehandRubber, 90),
        ("蝴蝶王 VISCARIA", "Butterfly 蝴蝶", .blade, 300),
        ("CL CR 纯木底板", "STIGA 斯帝卡", .blade, 300)
    ]
    
    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && !brand.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.paperTextureBg.ignoresSafeArea()
                
                Form {
                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(quickTemplates, id: \.name) { item in
                                    Button {
                                        applyTemplate(item)
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: "wand.and.stars")
                                                .font(.caption2)
                                            Text(item.name)
                                                .font(.caption)
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.pongOrange.opacity(0.12))
                                        .foregroundColor(.pongOrange)
                                        .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    } header: {
                        Text("快捷模版填入")
                    }
                    
                    Section {
                        TextField("装备名称（如：狂飚3 / VISCARIA）", text: $name)
                        TextField("品牌（如：红双喜 DHS / 蝴蝶）", text: $brand)
                        
                        Picker("装备类型", selection: $category) {
                            ForEach(GearCategory.allCases, id: \.self) { cat in
                                Text(cat.rawValue).tag(cat)
                            }
                        }
                        .onChange(of: category) { oldCat, newCat in
                            switch newCat {
                            case .blade:
                                recommendedMaxHours = 300
                            case .forehandRubber:
                                recommendedMaxHours = 60
                            case .backhandRubber:
                                recommendedMaxHours = 80
                            }
                        }
                    } header: {
                        Text("基本信息")
                    }
                    
                    Section {
                        DatePicker("启用/贴皮日期", selection: $installDate, displayedComponents: .date)
                        
                        Stepper("已使用时长: \(totalHoursUsed) 小时", value: $totalHoursUsed, in: 0...999)
                        
                        Stepper("建议最大寿命: \(recommendedMaxHours) 小时", value: $recommendedMaxHours, in: 10...1000, step: 10)
                    } header: {
                        Text("使用寿命与打卡统计")
                    } footer: {
                        Text("通常底板使用寿命约 300 小时，正反手胶皮寿命约 60~90 小时（视打法强度与保养情况而定）。")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("添加球拍装备 🏓")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveGear()
                    }
                    .fontWeight(.bold)
                    .tint(.pongOrange)
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    private func applyTemplate(_ item: (name: String, brand: String, category: GearCategory, maxHours: Int)) {
        self.name = item.name
        self.brand = item.brand
        self.category = item.category
        self.recommendedMaxHours = item.maxHours
    }
    
    private func saveGear() {
        let newItem = GearItem(
            name: name.trimmingCharacters(in: .whitespaces),
            brand: brand.trimmingCharacters(in: .whitespaces),
            category: category,
            installDate: installDate,
            totalHoursUsed: totalHoursUsed,
            recommendedMaxHours: recommendedMaxHours
        )
        modelContext.insert(newItem)
        WidgetCenter.shared.reloadAllTimelines()
        dismiss()
    }
}
