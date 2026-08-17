import SwiftUI
import SwiftData
import WidgetKit

struct GearManagerView: View {
    @Query private var gearItems: [GearItem]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddGear = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.paperTextureBg.ignoresSafeArea()
                
                if gearItems.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "circle.grid.cross")
                            .font(.system(size: 48))
                            .foregroundColor(.pongOrange)
                        Text("还没有记录球拍装备")
                            .font(.headline)
                        Text("记录你的底板、正手胶皮与反手胶皮，追踪打球累计磨损时长")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        Button("添加新装备") {
                            showingAddGear = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.pongOrange)
                    }
                } else {
                    List {
                        ForEach(gearItems) { gear in
                            GearRowView(gear: gear)
                        }
                        .onDelete(perform: deleteGear)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("球具日志 🏓")
            .toolbar {
                Button {
                    showingAddGear = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddGear) {
                AddGearSheetView()
            }
        }
    }
    
    private func deleteGear(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(gearItems[index])
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
}

struct GearRowView: View {
    let gear: GearItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(gear.category.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.pongBlue.opacity(0.1))
                    .foregroundColor(.pongBlue)
                    .clipShape(Capsule())
                
                Text(gear.brand)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(gear.totalHoursUsed) 小时")
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
            
            HStack {
                Text(gear.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.sketchLine)
                
                Spacer()
                
                HStack(spacing: 6) {
                    Button("+1h") {
                        gear.totalHoursUsed += 1
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.pongOrange.opacity(0.15))
                    .foregroundColor(.pongOrange)
                    .clipShape(Capsule())
                    .buttonStyle(.plain)
                    
                    Button("+2h") {
                        gear.totalHoursUsed += 2
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.pongOrange.opacity(0.15))
                    .foregroundColor(.pongOrange)
                    .clipShape(Capsule())
                    .buttonStyle(.plain)
                }
            }
            
            // Progress Bar
            Gauge(value: gear.usagePercentage) {
                Text("胶皮/底板磨损估计")
            } currentValueLabel: {
                Text("\(Int(gear.usagePercentage * 100))%")
            }
            .gaugeStyle(.linearCapacity)
            .tint(gear.usagePercentage > 0.85 ? Color.red : Color.pongOrange)
        }
        .padding(.vertical, 6)
    }
}

