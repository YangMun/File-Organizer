import SwiftUI
import QuickLook

struct FileDetailView: View {
    let document: FileEntity
    @State private var isPreviewPresented = false
    @State private var documentURL: URL?
    @State private var showError = false
    @State private var errorMessage = ""
    
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
                documentURL = url
            } else {
                errorMessage = "파일에 접근할 수 없습니다."
                showError = true
            }
        } catch {
            errorMessage = "파일을 불러올 수 없습니다: \(error.localizedDescription)"
            showError = true
        }
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
            
            // 파일 열기 버튼
            Button(action: {
                loadDocument()
                isPreviewPresented = true
            }) {
                HStack {
                    Image(systemName: "eye.fill")
                    Text("파일 보기")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
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

#Preview {
    NavigationView {
        FileDetailView(document: FileEntity())
    }
}
