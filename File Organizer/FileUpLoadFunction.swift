import SwiftUI
import UniformTypeIdentifiers
import MobileCoreServices

// 파일 상단에 UploadedFile 구조체 추가
struct UploadedFile: Identifiable {
    let id = UUID()
    let url: URL
    let name: String
    let size: Int64
    let date: Date
    let fileExtension: String
}

/// iCloud Drive에서 파일을 선택하는 기능을 제공하는 클래스
class FileUpLoadFunction: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var isLoading: Bool = false
    @Published var uploadProgress: Double = 0.0
    @Published var uploadedFiles: [UploadedFile] = []
    @Published var currentProcessingFileName: String = ""
    @Published var totalFiles: Int = 0
    @Published var processedFilesCount: Int = 0
    
    // MARK: - Private Properties
    private var documentPickerController: UIDocumentPickerViewController?
    private var processingTask: Task<Void, Never>?
    
    // MARK: - Public Methods
    func openFilePicker(
        fileTypes: [UTType] = [.item],
        allowsMultipleSelection: Bool = true
    ) {
        DispatchQueue.main.async {
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: fileTypes)
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = allowsMultipleSelection
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(documentPicker, animated: true)
            }
        }
    }
}

// MARK: - UIDocumentPickerDelegate
extension FileUpLoadFunction: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // 즉시 picker를 닫고 처리 시작
        controller.dismiss(animated: true) { [weak self] in
            self?.processFiles(urls)
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
    
    // MARK: - Private Methods
    private func processFiles(_ urls: [URL]) {
        // 이전 작업이 있다면 취소
        processingTask?.cancel()
        
        // 초기 상태 설정
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.totalFiles = urls.count
            self.processedFilesCount = 0
            self.isLoading = true
            self.uploadProgress = 0.0
        }
        
        // 새로운 처리 작업 시작
        processingTask = Task { [weak self] in
            guard let self = self else { return }
            
            for (index, url) in urls.enumerated() {
                if Task.isCancelled { break }
                
                // 파일 정보 가져오기
                let fileSize = url.fileSize ?? 0
                
                await MainActor.run {
                    self.currentProcessingFileName = url.lastPathComponent
                    
                    // 새 파일 항목 생성 및 추가
                    let newFile = UploadedFile(
                        url: url,
                        name: url.lastPathComponent,
                        size: fileSize,
                        date: Date(),
                        fileExtension: url.pathExtension.lowercased()
                    )
                    
                    // UI 업데이트
                    self.uploadedFiles.insert(newFile, at: 0)
                    self.processedFilesCount = index + 1
                    self.uploadProgress = Double(self.processedFilesCount) / Double(self.totalFiles)
                }
                
                // 각 파일 처리 사이에 짧은 지연을 주어 UI가 부드럽게 업데이트되도록 함
                try? await Task.sleep(nanoseconds: 50_000_000) // 0.05초
            }
            
            // 모든 처리 완료
            await MainActor.run {
                self.isLoading = false
                self.currentProcessingFileName = ""
                self.uploadProgress = 1.0
            }
        }
    }
}

// MARK: - URL Extension
extension URL {
    var fileSize: Int64? {
        guard let values = try? resourceValues(forKeys: [.fileSizeKey, .totalFileSizeKey]),
              let size = values.fileSize ?? values.totalFileSize else { return nil }
        return Int64(size)
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
            allowsMultipleSelection: allowsMultipleSelection
        )
    }
}
