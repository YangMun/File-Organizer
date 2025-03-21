import SwiftUI

struct MainView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 홈 탭
            VStack {
                ScrollView {
                    VStack(spacing: 20) {
                        FileUpLoadView()
                        RecentUpLoadView()
                    }
                    .padding()
                }
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
        .background(Color(UIColor.systemGray6))
    }
}

#Preview {
    MainView()
}
