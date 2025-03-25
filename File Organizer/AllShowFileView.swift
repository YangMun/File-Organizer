import SwiftUI

struct AllShowFileView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var fileUploader: FileUpLoadFunction
    
    // 중복 파일 제거하고 최신 파일만 보여주는 계산 속성 수정
    private var uniqueFiles: [UploadedFile] {
        // 먼저 uploadedFiles를 날짜순으로 정렬
        let sortedFiles = fileUploader.uploadedFiles.sorted { $0.date > $1.date }
        
        var uniqueDict = [String: UploadedFile]()
        var seenOrder = [String]()
        
        // 정렬된 파일들을 처리 (최신 파일부터)
        for file in sortedFiles {
            let key = file.name
            if uniqueDict[key] == nil {
                // 새 파일은 항상 맨 앞에 추가
                seenOrder.append(key)
            }
            // 항상 최신 버전으로 업데이트
            uniqueDict[key] = file
        }
        
        return seenOrder.compactMap { uniqueDict[$0] }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0) {
                    // uploadedFiles 대신 uniqueFiles 사용
                    ForEach(uniqueFiles) { file in
                        FileRowView(file: file)
                            .padding(.vertical, 12)
                        
                        // 마지막 항목 체크도 uniqueFiles 사용
                        if file.id != uniqueFiles.last?.id {
                            Divider()
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("모든 파일")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
        }
        .background(Color(.systemBackground))
    }
}

// 파일 행을 표시하는 하위 뷰
struct FileRowView: View {
    let file: UploadedFile
    
    var body: some View {
        HStack(spacing: 16) {
            // 파일 아이콘
            Image(getFileImage(for: file.fileExtension))
                .resizable()
                .frame(width: 40, height: 40)
            
            // 파일 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(file.name)
                    .font(.system(size: 17))
                    .lineLimit(1)
                
                Text(formatFileSize(file.size))
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
    
    // 파일 확장자에 따른 이미지 이름 반환
    private func getFileImage(for extension: String) -> String {
        switch `extension`.lowercased() {
        case "xlsx", "xls":
            return "Excel"
        case "hwp", "hwpx":
            return "HWP"
        case "pdf":
            return "PDF"
        case "docx", "doc":
            return "Word"
        case "pptx", "ppt":
            return "PPT"
        default:
            return "PDF"
        }
    }
    
    // 파일 크기 포맷
    private func formatFileSize(_ size: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
}
