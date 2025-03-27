import SwiftUI

struct MainView: View {
    @State private var selectedTab = 0
    @StateObject private var fileUploader = FileUpLoadFunction()
    @AppStorage("isEnglish") private var isEnglish = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home tab
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack {
                    FileUpLoadView(fileUploader: fileUploader)
                        .frame(height: 280)
                    
                    RecentUpLoadView(fileUploader: fileUploader)
                        .frame(maxHeight: .infinity)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text(isEnglish ? "Home" : "홈")
            }
            .tag(0)
            
            // Files tab
            FileView()
                .tabItem {
                    Image(systemName: "doc.fill")
                    Text(isEnglish ? "Files" : "파일")
                }
                .tag(1)
            
            // Settings tab
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text(isEnglish ? "Settings" : "설정")
                }
                .tag(2)
        }
        .tint(.blue)
        .onAppear {
            // TabBar style settings
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            
            // Unselected item color settings
            let unselectedColor = UIColor.gray
            appearance.stackedLayoutAppearance.normal.iconColor = unselectedColor
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: unselectedColor]
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview {
    MainView()
}
