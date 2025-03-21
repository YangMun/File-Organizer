import SwiftUI

struct FileUpLoadView: View {
    @ObservedObject var fileUploader: FileUpLoadFunction
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "arrow.down.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.blue)
            
            Text("파일 업로드")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("기기에서 파일을 선택해주세요.")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            
            Button(action: {
                fileUploader.openFilePicker()
            }) {
                Text("파일 선택하기")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .disabled(fileUploader.isLoading)
            
            if fileUploader.isLoading {
                VStack(spacing: 8) {
                    Text("파일 처리 중... (\(fileUploader.processedFilesCount)/\(fileUploader.totalFiles))")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if !fileUploader.currentProcessingFileName.isEmpty {
                        Text(fileUploader.currentProcessingFileName)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    
                    ProgressView(value: fileUploader.uploadProgress) {
                        Text("\(Int(fileUploader.uploadProgress * 100))%")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .frame(width: 200)
                }
                .padding(.top, 10)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

