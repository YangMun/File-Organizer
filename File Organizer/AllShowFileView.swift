import SwiftUI

struct AllShowFileView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var fileUploader: FileUpLoadFunction
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(fileUploader.uploadedFiles) { file in
                        FileRowView(file: file)
                            .padding(.vertical, 12)
                        
                        if file.id != fileUploader.uploadedFiles.last?.id {
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
                
                Text("\(formatFileSize(file.size)) • \(formatDate(file.date))")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
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
    
    // 날짜 포맷
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
