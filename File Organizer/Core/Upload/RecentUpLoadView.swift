import SwiftUI

struct RecentUpLoadView: View {
    @ObservedObject var fileUploader: FileUpLoadFunction
    @State private var showAllFiles = false
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("isEnglish") private var isEnglish = false
    
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
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(isEnglish ? "Recent Uploads" : "최근 업로드")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Spacer()
                
                Button(action: {
                    showAllFiles = true
                }) {
                    Text(isEnglish ? "View All" : "모두 보기")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            // 스크롤 영역
            ScrollView {
                LazyVStack(spacing: 0) {
                    // uploadedFiles 대신 uniqueFiles 사용
                    ForEach(uniqueFiles) { file in
                        HStack {
                            // 파일 타입에 따른 이미지 설정
                            Image(getFileImage(for: file.fileExtension))
                                .resizable()
                                .frame(width: 30, height: 30)
                            
                            VStack(alignment: .leading) {
                                Text(file.name)
                                    .font(.system(size: 16))
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                Text(formatFileSize(file.size))
                                    .font(.system(size: 12))
                                    .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                            }
                            
                            Spacer()
                            
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        
                        // 마지막 항목 체크도 uniqueFiles 사용
                        if file.id != uniqueFiles.last?.id {
                            Divider()
                                .padding(.horizontal)
                                .background(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.2))
                        }
                    }
                }
            }
            .frame(height: 300) // 고정된 높이 설정
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(colorScheme == .dark ? Color(UIColor.systemGray5) : .white)
        .cornerRadius(12)
        .shadow(color: colorScheme == .dark ? .black.opacity(0.3) : .black.opacity(0.1), radius: 5)
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
    
    // 날짜 포맷 함수 수정
    private func formatDate(_ date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute, .hour, .day], from: date, to: now)
        
        if let minutes = components.minute {
            if minutes < 1 {
                return isEnglish ? "Just now" : "방금 전"
            }
            if minutes < 60 {
                return isEnglish ? "\(minutes) mins ago" : "\(minutes)분 전"
            }
        }
        
        if let hours = components.hour, hours < 24 {
            return isEnglish ? "\(hours) hours ago" : "\(hours)시간 전"
        }
        
        // 24시간 이상 지난 경우 날짜와 시간 표시
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: isEnglish ? "en_US" : "ko_KR")
        formatter.dateFormat = isEnglish ? "MMM d, HH:mm" : "M월 d일 HH:mm"
        return formatter.string(from: date)
    }
}

