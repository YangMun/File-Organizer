import SwiftUI
import UniformTypeIdentifiers
import MobileCoreServices

/// iCloud Drive에서 파일을 선택하는 기능을 제공하는 클래스
class FileUpLoadFunction: NSObject, ObservableObject {
    
    /// 선택된 파일 URL
    @Published var selectedFileURL: URL?
    
    /// 선택된 파일 이름
    @Published var selectedFileName: String = ""
    
    /// 선택된 파일 목록
    @Published var selectedFiles: [URL] = []
    
    /// 로딩 상태
    @Published var isLoading: Bool = false
    
    /// 파일 선택 완료 시 실행될 콜백
    var onFileSelected: ((URL) -> Void)?
    
    /// 파일 선택 취소 시 실행될 콜백
    var onCancel: (() -> Void)?
    
    /// 현재 활성화된 Document Picker Controller
    private var documentPickerController: UIDocumentPickerViewController?
    
    /// 업로드 진행 상태
    @Published var uploadProgress: Double = 0.0
    
    /// iCloud Drive를 열어 파일을 선택하는 함수
    /// - Parameters:
    ///   - fileTypes: 선택 가능한 파일 타입 배열 (기본값: 모든 타입)
    ///   - allowsMultipleSelection: 다중 선택 허용 여부 (기본값: true)
    ///   - onFileSelected: 파일 선택 완료 시 실행될 콜백
    ///   - onCancel: 파일 선택 취소 시 실행될 콜백
    func openFilePicker(
        fileTypes: [UTType] = [.item],
        allowsMultipleSelection: Bool = true,
        onFileSelected: ((URL) -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) {
        DispatchQueue.main.async {
            self.onFileSelected = onFileSelected
            self.onCancel = onCancel
            
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: fileTypes)
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = allowsMultipleSelection
            
            self.documentPickerController = documentPicker
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(documentPicker, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - UIDocumentPickerDelegate
extension FileUpLoadFunction: UIDocumentPickerDelegate {
    
    /// 사용자가 파일을 선택했을 때 호출되는 메서드
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // UI 업데이트는 메인 스레드에서 수행
        DispatchQueue.main.async {
            self.isLoading = true
            self.uploadProgress = 0.0
            self.selectedFiles.removeAll()
        }
        
        // 백그라운드 큐에서 파일 처리
        DispatchQueue.global(qos: .userInitiated).async {
            let totalFiles = Double(urls.count)
            var processedFiles: Double = 0
            
            for url in urls {
                guard url.startAccessingSecurityScopedResource() else {
                    print("파일 접근 권한을 얻을 수 없습니다: \(url.lastPathComponent)")
                    continue
                }
                
                // 파일 처리 시뮬레이션 (실제 구현시 실제 파일 처리 로직으로 대체)
                Thread.sleep(forTimeInterval: 1.0) // 각 파일당 1초 지연
                
                DispatchQueue.main.async {
                    self.selectedFiles.append(url)
                    processedFiles += 1
                    self.uploadProgress = processedFiles / totalFiles
                    print("파일 처리 중: \(url.lastPathComponent), 진행률: \(Int(self.uploadProgress * 100))%")
                }
                
                url.stopAccessingSecurityScopedResource()
            }
            
            // 모든 파일 처리 완료 후
            DispatchQueue.main.async {
                self.isLoading = false
                print("모든 파일 처리 완료")
                
                // 선택된 파일에 대한 콜백 실행
                if let firstURL = urls.first {
                    self.onFileSelected?(firstURL)
                }
            }
        }
    }
    
    /// 사용자가 파일 선택을 취소했을 때 호출되는 메서드
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        // 콜백 실행
        onCancel?()
    }
}

// MARK: - SwiftUI View Extension
extension View {
    /// FileUpLoadFunction을 사용하여 iCloud Drive 파일 선택기를 여는 함수
    /// - Parameters:
    ///   - fileTypes: 선택 가능한 파일 타입 배열 (기본값: 모든 타입)
    ///   - allowsMultipleSelection: 다중 선택 허용 여부 (기본값: true)
    ///   - onFileSelected: 파일 선택 완료 시 실행될 콜백
    ///   - onCancel: 파일 선택 취소 시 실행될 콜백
    func openFileUploader(
        fileTypes: [UTType] = [.item],
        allowsMultipleSelection: Bool = true,
        onFileSelected: @escaping (URL) -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        let fileUploader = FileUpLoadFunction()
        fileUploader.openFilePicker(
            fileTypes: fileTypes,
            allowsMultipleSelection: allowsMultipleSelection,
            onFileSelected: onFileSelected,
            onCancel: onCancel
        )
    }
}
