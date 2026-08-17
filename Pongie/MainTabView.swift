import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var quickActionManager: QuickActionManager
    
    var body: some View {
        TabView(selection: $quickActionManager.selectedTab) {
            DashboardView()
                .tabItem {
                    if let uiImage = InvertedSolidBallIconView.asUIImage(size: 26) {
                        Label {
                            Text("球池打卡")
                        } icon: {
                            Image(uiImage: uiImage)
                        }
                    } else {
                        Label("球池打卡", systemImage: "circle.circle.fill")
                    }
                }
                .tag(0)
            
            GearManagerView()
                .tabItem {
                    Label("球具日志", systemImage: "wrench.and.screwdriver.fill")
                }
                .tag(1)
            
            AnalyticsView()
                .tabItem {
                    Label("数据分析", systemImage: "chart.bar.fill")
                }
                .tag(2)
        }
        .tint(.pongOrange)
        .onOpenURL { url in
            quickActionManager.handleURL(url)
        }
    }
}

