import SwiftUI
import UniformTypeIdentifiers
import MobileCoreServices

// 파일 상단에 UploadedFile 구조체 추가
struct UploadedFile: Identifiable {
    let id = UUID()
    let bookmarkData: Data
    let name: String
    let size: Int64
    let date: Date
    let fileExtension: String
    
    var url: URL? {
        var isStale = false
        return try? URL(resolvingBookmarkData: bookmarkData,
                       options: [],
                       relativeTo: nil,
                       bookmarkDataIsStale: &isStale)
    }
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
    private let fileCoordinator = NSFileCoordinator()
    
    // 지원하는 파일 형식 정의
    private let supportedFileTypes: [UTType] = [
        .pdf,                    // PDF 파일
        UTType("com.microsoft.word.doc")!,    // Word 문서
        UTType("org.openxmlformats.wordprocessingml.document")!,  // Word 문서 (docx)
        UTType("com.microsoft.powerpoint.ppt")!,  // PowerPoint 프레젠테이션
        UTType("org.openxmlformats.presentationml.presentation")!,  // PowerPoint 프레젠테이션 (pptx)
        UTType("com.microsoft.excel.xls")!,  // Excel 스프레드시트
        UTType("org.openxmlformats.spreadsheetml.sheet")!,  // Excel 스프레드시트 (xlsx)
        UTType("org.hancom.hwp")!,  // 한글 문서 (hwp)
        UTType("org.hancom.hwpx")!  // 한글 문서 (hwpx)

    ]
    
    // MARK: - Public Methods
    func openFilePicker(
        fileTypes: [UTType]? = nil,
        allowsMultipleSelection: Bool = true
    ) {
        DispatchQueue.main.async {
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: fileTypes ?? self.supportedFileTypes)
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
        controller.dismiss(animated: true) { [weak self] in
            self?.processFiles(urls)
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
    
    // MARK: - Private Methods
    private func processFiles(_ urls: [URL]) {
        processingTask?.cancel()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.totalFiles = urls.count
            self.processedFilesCount = 0
            self.isLoading = true
            self.uploadProgress = 0.0
        }
        
        processingTask = Task { [weak self] in
            guard let self = self else { return }
            
            for (index, url) in urls.enumerated() {
                if Task.isCancelled { break }
                
                // 보안 스코프 리소스 접근 시작
                guard url.startAccessingSecurityScopedResource() else {
                    print("Failed to access security scoped resource: \(url.lastPathComponent)")
                    continue
                }
                
                defer {
                    url.stopAccessingSecurityScopedResource()
                }
                
                // File Coordinator를 사용하여 파일 접근
                var error: NSError?
                fileCoordinator.coordinate(readingItemAt: url, options: .immediatelyAvailableMetadataOnly, error: &error) { [weak self] url in
                    guard let self = self else { return }
                    
                    do {
                        // 파일 정보 가져오기
                        let fileSize = url.fileSize ?? 0
                        
                        // 북마크 데이터 생성
                        let bookmarkData = try url.bookmarkData(
                            options: [],
                            includingResourceValuesForKeys: [.fileSizeKey],
                            relativeTo: nil
                        )
                        
                        Task { @MainActor in
                            self.currentProcessingFileName = url.lastPathComponent
                            
                            // 새 파일 항목 생성 및 추가
                            let newFile = UploadedFile(
                                bookmarkData: bookmarkData,
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
                    } catch {
                        print("Error creating bookmark: \(error.localizedDescription)")
                    }
                }
                
                if let error = error {
                    print("File coordination error: \(error.localizedDescription)")
                }
                
                try? await Task.sleep(nanoseconds: 50_000_000) // 0.05초
            }
            
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
