import SwiftUI
import GoogleMobileAds

class InterstitialAdManager: NSObject, ObservableObject {
    // 싱글톤 패턴으로 구현
    static let shared = InterstitialAdManager()
    
    // 전면 광고 객체
    private var interstitialAd: InterstitialAd?
    
    // 광고가 로드 완료되었는지 여부
    @Published var isAdLoaded = false
    
    // 광고가 이미 표시되었는지 여부 (앱 세션당 한번만 표시)
    @Published var hasAdBeenShown = false
    
    private override init() {
        super.init()
        loadInterstitialAd()
    }
    
    // 광고 로드
    func loadInterstitialAd() {
        // Info.plist에서 광고 ID 가져오기
        guard let adUnitID = Bundle.main.object(forInfoDictionaryKey: "GADInterstitialAdUnitID") as? String else {
            // print("오류: Info.plist에서 GADInterstitialAdUnitID를 찾을 수 없습니다")
            return
        }
        
        // 광고 요청 객체 생성
        let request = Request()
        
        // 광고 로드
        InterstitialAd.load(with: adUnitID, request: request) { [weak self] ad, error in
            guard let self = self else { return }
            
            if let error = error {
                // print("전면 광고 로드 실패: \(error.localizedDescription)")
                return
            }
            
            self.interstitialAd = ad
            self.interstitialAd?.fullScreenContentDelegate = self
            self.isAdLoaded = true
            // print("전면 광고 로드 성공")
        }
    }
    
    // 광고 표시
    func showInterstitialAd(from rootViewController: UIViewController, completion: @escaping () -> Void) {
        // 이미 광고가 표시된 경우 표시하지 않음
        if hasAdBeenShown {
            // print("이미 광고가 표시되었으므로 건너뜁니다")
            completion()
            return
        }
        
        // 광고가 로드되지 않은 경우
        guard isAdLoaded, let interstitialAd = interstitialAd else {
            // print("전면 광고가 아직 로드되지 않았으므로 건너뜁니다")
            completion()
            return
        }
        
        // 광고 표시
        interstitialAd.present(from: rootViewController)
        self.hasAdBeenShown = true
        
        // 최초 한 번만 표시하므로 다시 로드하지 않음
        // loadInterstitialAd() 호출 제거
        
        // completion 핸들러는 광고 종료 이벤트에서 호출됨
    }
    
    // UIViewController를 가져오는 헬퍼 메서드
    func getRootViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        return windowScene?.windows.first?.rootViewController
    }
    
    // SwiftUI View에서 사용하기 위한 래퍼 메서드
    func showAdIfNeeded(completion: @escaping () -> Void) {
        guard let rootViewController = getRootViewController() else {
            // print("루트 뷰 컨트롤러를 가져오는데 실패했습니다")
            completion()
            return
        }
        
        showInterstitialAd(from: rootViewController, completion: completion)
    }
    
    // 앱이 백그라운드로 갔다가 다시 포그라운드로 돌아올 때 호출할 메서드
    func resetForNewSession() {
        // 최초 한 번만 표시하므로 이 메서드는 사용하지 않음
        // hasAdBeenShown = false 제거
        
        // 광고가 로드되지 않은 경우에만 다시 로드
        if !isAdLoaded && !hasAdBeenShown {
            loadInterstitialAd()
        }
    }
}

// MARK: - GADFullScreenContentDelegate
extension InterstitialAdManager: FullScreenContentDelegate {
    // 광고가 표시되기 시작할 때
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        // print("전면 광고가 표시됩니다")
        isAdLoaded = false
    }
    
    // 광고 표시가 실패했을 때
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        // print("전면 광고 표시 실패: \(error.localizedDescription)")
        isAdLoaded = false
        hasAdBeenShown = true  // 실패해도 보여진 것으로 처리하여 중복 시도 방지
        // 최초 한 번만 표시하므로 다시 로드하지 않음
        // loadInterstitialAd() 호출 제거
    }
    
    // 광고가 닫혔을 때
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        // print("전면 광고가 닫혔습니다")
        // 최초 한 번만 표시하므로 다시 로드하지 않음
        // loadInterstitialAd() 호출 제거
    }
}
