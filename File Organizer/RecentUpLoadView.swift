import SwiftUI

struct RecentUpLoadView: View {
    @ObservedObject var fileUploader: FileUpLoadFunction
    @State private var showAllFiles = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("최근 업로드")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    showAllFiles = true
                }) {
                    Text("모두 보기")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            // 스크롤 영역
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(fileUploader.uploadedFiles) { file in
                        HStack {
                            // 파일 타입에 따른 이미지 설정
                            Image(getFileImage(for: file.fileExtension))
                                .resizable()
                                .frame(width: 30, height: 30)
                            
                            VStack(alignment: .leading) {
                                Text(file.name)
                                    .font(.system(size: 16))
                                Text("\(formatFileSize(file.size)) • \(formatDate(file.date))")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        
                        // 마지막 항목이 아닌 경우에만 구분선 추가
                        if file.id != fileUploader.uploadedFiles.last?.id {
                            Divider()
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .frame(height: 300) // 고정된 높이 설정
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
        .sheet(isPresented: $showAllFiles) {
            AllShowFileView(fileUploader: fileUploader)
                .presentationBackground(.ultraThinMaterial)
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
            return "PDF" // 기본 이미지
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

