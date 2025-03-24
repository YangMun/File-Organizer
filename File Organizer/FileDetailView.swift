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
    
    private func loadDocument() {
        guard let bookmarkData = document.bookmarkData else {
            errorMessage = "북마크 데이터를 찾을 수 없습니다."
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
                errorMessage = "파일에 접근할 수 없습니다."
                showError = true
            }
        } catch {
            errorMessage = "파일을 불러올 수 없습니다: \(error.localizedDescription)"
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
    
    var body: some View {
        VStack(spacing: 20) {
            // 파일 정보 표시
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "doc.fill")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading) {
                        Text(document.name ?? "Unknown")
                            .font(.headline)
                        Text(document.fileExtension?.uppercased() ?? "")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    DetailRow(title: "파일 크기", value: ByteCountFormatter.string(fromByteCount: Int64(document.size), countStyle: .file))
                    DetailRow(title: "업로드 날짜", value: (document.dateUploaded ?? Date()).formatted())
                }
                .padding(.top)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5)
            
            VStack(spacing: 12) {  // spacing 추가
                // 파일 열기 버튼
                Button(action: {
                    loadDocument()
                }) {
                    HStack {
                        Text("파일 보기")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                // 한글 파일일 경우에만 안내 메시지 표시
                if document.fileExtension?.lowercased() == "hwp" {
                    Text("한컴오피스 Viewer 프로그램이 필요합니다.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom, 4)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .alert("오류", isPresented: $showError) {
            Button("확인", role: .cancel) {}
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
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
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
