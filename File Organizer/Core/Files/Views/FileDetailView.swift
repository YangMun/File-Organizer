import SwiftUI
import QuickLook
import UIKit

struct FileDetailView: View {
    let document: FileEntity
    @State private var isPreviewPresented = false
    @State private var documentURL: URL?
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var interactionController: UIDocumentInteractionController?
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("isEnglish") private var isEnglish = false
    
    private func loadDocument() {
        guard let bookmarkData = document.bookmarkData else {
            errorMessage = isEnglish ? 
                "Bookmark data not found." : 
                "북마크 데이터를 찾을 수 없습니다."
            showError = true
            return
        }
        
        do {
            var isStale = false
            let url = try URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale)
            
            if url.startAccessingSecurityScopedResource() {
                // 한글 파일인 경우
                if document.fileExtension?.lowercased() == "hwp" {
                    presentOpenInMenu(url: url)
                } else {
                    // 다른 파일은 QuickLook 사용
                    documentURL = url
                    isPreviewPresented = true
                }
            } else {
                errorMessage = isEnglish ? 
                    "Cannot access the file." : 
                    "파일에 접근할 수 없습니다."
                showError = true
            }
        } catch {
            errorMessage = isEnglish ? 
                "Cannot load file: \(error.localizedDescription)" : 
                "파일을 불러올 수 없습니다: \(error.localizedDescription)"
            showError = true
        }
    }
    
    private func presentOpenInMenu(url: URL) {
        let controller = UIDocumentInteractionController(url: url)
        
        // 현재 뷰 컨트롤러 찾기
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let viewController = window.rootViewController {
            
            // 바로 "열기" 메뉴 표시
            let rect = CGRect(x: 0, y: 0, width: 300, height: 300) // 메뉴가 표시될 위치
            controller.presentOptionsMenu(from: rect, in: viewController.view, animated: true)
        }
        
        // 컨트롤러 참조 유지
        interactionController = controller
    }
    
    // 파일 타입에 따른 이미지 이름 반환
    private func getFileImage(fileExtension: String?) -> String {
        guard let ext = fileExtension?.lowercased() else { return "PDF" }
        
        switch ext {
        case "pdf":
            return "PDF"
        case "doc", "docx":
            return "Word"
        case "hwp":
            return "HWP"
        case "xls", "xlsx":
            return "Excel"
        case "ppt", "pptx":
            return "PPT"
        default:
            return "PDF"
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // 파일 정보 표시
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    // systemName 이미지를 Assets의 실제 파일 타입 이미지로 변경
                    Image(getFileImage(fileExtension: document.fileExtension))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                    
                    VStack(alignment: .leading) {
                        Text(document.name ?? "Unknown")
                            .font(.headline)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        Text(document.fileExtension?.uppercased() ?? "")
                            .font(.subheadline)
                            .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    DetailRow(
                        title: isEnglish ? "File Size" : "파일 크기",
                        value: ByteCountFormatter.string(fromByteCount: Int64(document.size), countStyle: .file),
                        colorScheme: colorScheme
                    )
                    DetailRow(
                        title: isEnglish ? "Upload Date" : "업로드 날짜",
                        value: (document.dateUploaded ?? Date()).formatted(),
                        colorScheme: colorScheme
                    )
                }
                .padding(.top)
            }
            .padding()
            .background(colorScheme == .dark ? Color(UIColor.systemGray5) : Color(.systemBackground))
            .cornerRadius(12)
            .shadow(
                color: colorScheme == .dark ? .black.opacity(0.3) : .black.opacity(0.1),
                radius: 5
            )
            
            VStack(spacing: 12) {
                // 파일 열기 버튼
                Button(action: {
                    loadDocument()
                }) {
                    HStack {
                        Text(isEnglish ? "View File" : "파일 보기")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                // 한글 파일일 경우에만 안내 메시지 표시
                if document.fileExtension?.lowercased() == "hwp" {
                    Text(isEnglish ? 
                         "Hancom Office Viewer program is required." : 
                         "한컴오피스 Viewer 프로그램이 필요합니다.")
                        .font(.caption)
                        .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                        .padding(.bottom, 4)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .background(colorScheme == .dark ? Color(UIColor.black) : Color(.systemGroupedBackground))
        .alert(isEnglish ? "Error" : "오류", isPresented: $showError) {
            Button(isEnglish ? "OK" : "확인", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .quickLookPreview($documentURL)
        .onDisappear {
            documentURL?.stopAccessingSecurityScopedResource()
            interactionController = nil
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    let colorScheme: ColorScheme
    @AppStorage("isEnglish") private var isEnglish = false
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(colorScheme == .dark ? .gray : .secondary)
            Spacer()
            Text(value)
                .foregroundColor(colorScheme == .dark ? .white : .black)
        }
    }
}

// UIDocumentInteractionController 델리게이트
class InteractionDelegate: NSObject, UIDocumentInteractionControllerDelegate {
    static let shared = InteractionDelegate()
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            fatalError("No root view controller found")
        }
        return rootViewController
    }
}

#Preview {
    NavigationView {
        FileDetailView(document: FileEntity())
    }
}
