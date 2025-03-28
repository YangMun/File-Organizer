import SwiftUI
import Lottie

struct LoadingView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isLoading = true
    @State private var showAdOrMainView = false
    
    // InterstitialAdManager 인스턴스
    @StateObject private var adManager = InterstitialAdManager.shared
    
    var body: some View {
        ZStack {
            // 배경색을 항상 회색으로 설정
            Color(UIColor.systemGray5)
                .edgesIgnoringSafeArea(.all)
            
            if showAdOrMainView {
                // 로딩 후 화면 - 메인 뷰로 이동 (광고는 overlay로 표시됨)
                MainView()
                    .transition(.opacity)
            } else {
                // 로딩 애니메이션 표시
                VStack(spacing: 20) {
                    LottieView(name: "LoadingAni")
                        .frame(width: 200, height: 200)
                }
                .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            // print("로딩 화면이 나타났습니다")
            
            // 로딩 애니메이션을 3초 동안 표시
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                // print("로딩 애니메이션이 끝났습니다, 광고 표시 준비")
                
                withAnimation {
                    isLoading = false
                    showAdOrMainView = true
                }
                
                // 로딩 화면이 끝난 후 광고 표시 시도
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if adManager.isAdLoaded {
                        // print("광고가 로드되어 있습니다. 광고를 표시합니다.")
                        showAd()
                    } else {
                        // print("광고가 로드되지 않았습니다. 메인 화면으로 진행합니다.")
                    }
                }
            }
        }
    }
    
    // 광고 표시 함수
    private func showAd() {
        guard let rootViewController = getRootViewController() else {
            // print("루트 뷰 컨트롤러를 가져오는데 실패했습니다")
            return
        }
        
        adManager.showInterstitialAd(from: rootViewController) {
            // print("광고 표시가 완료되었습니다.")
        }
    }
    
    // UIViewController를 가져오는 헬퍼 메서드
    private func getRootViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        return windowScene?.windows.first?.rootViewController
    }
}

struct LottieView: UIViewRepresentable {
    var name: String
    
    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        let animationView = LottieAnimationView()
        let animation = LottieAnimation.named(name)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {
        // 업데이트 코드가 필요할 경우
    }
}

#Preview {
    LoadingView()
}
