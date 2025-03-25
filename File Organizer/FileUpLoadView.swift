import SwiftUI

struct FileUpLoadView: View {
    @ObservedObject var fileUploader: FileUpLoadFunction
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "arrow.down.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.blue)
            
            Text("파일 업로드")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            
            Text("기기에서 파일을 선택해주세요.")
                .multilineTextAlignment(.center)
                .foregroundColor(colorScheme == .dark ? .gray : .secondary)
            
            Button(action: {
                fileUploader.openFilePicker()
            }) {
                Text("파일 선택하기")
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .disabled(fileUploader.isLoading)
            
            if fileUploader.isLoading {
                VStack(spacing: 8) {
                    Text("파일 처리 중... (\(fileUploader.processedFilesCount)/\(fileUploader.totalFiles))")
                        .font(.caption)
                        .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                    
                    if !fileUploader.currentProcessingFileName.isEmpty {
                        Text(fileUploader.currentProcessingFileName)
                            .font(.caption)
                            .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                            .lineLimit(1)
                    }
                    
                    ProgressView(value: fileUploader.uploadProgress) {
                        Text("\(Int(fileUploader.uploadProgress * 100))%")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .frame(width: 200)
                    .tint(.blue)
                }
                .padding(.top, 10)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(colorScheme == .dark ? Color(UIColor.systemGray5) : .white)
        .cornerRadius(12)
        .shadow(color: colorScheme == .dark ? .black.opacity(0.3) : .black.opacity(0.1), radius: 5)
        .padding(.horizontal)
    }
}

