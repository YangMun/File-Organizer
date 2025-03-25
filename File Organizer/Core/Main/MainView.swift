import SwiftUI

struct MainView: View {
    @State private var selectedTab = 0
    @StateObject private var fileUploader = FileUpLoadFunction()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 홈 탭
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
                Text("홈")
            }
            .tag(0)
            
            // 파일 탭
            FileView()
                .tabItem {
                    Image(systemName: "doc.fill")
                    Text("파일")
                }
                .tag(1)
            
            // 설정 탭
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("설정")
                }
                .tag(2)
        }
        .tint(.blue)
        .onAppear {
            // TabBar 스타일 설정
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            
            // 선택되지 않은 아이템 색상 설정
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
