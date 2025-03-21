import SwiftUI

struct FileUpLoadView: View {
    @StateObject private var fileUploader = FileUpLoadFunction()
    
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
                fileUploader.selectedFiles.removeAll()
                fileUploader.openFilePicker(
                    fileTypes: [.item],
                    allowsMultipleSelection: true,
                    onFileSelected: { url in
                        // 개별 파일 선택 시 처리는 FileUpLoadFunction에서 함
                    },
                    onCancel: {
                        print("파일 선택이 취소되었습니다.")
                    }
                )
            }) {
                Text("파일 선택하기")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            
            if fileUploader.isLoading {
                VStack(spacing: 8) {
                    Text("파일 업로드 중...")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    // 선형 프로그레스 바
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // 배경 게이지 바
                            Rectangle()
                                .foregroundColor(Color.gray.opacity(0.2))
                                .frame(width: geometry.size.width, height: 8)
                                .cornerRadius(4)
                            
                            // 진행 게이지 바
                            Rectangle()
                                .foregroundColor(.blue)
                                .frame(width: geometry.size.width * CGFloat(fileUploader.uploadProgress), height: 8)
                                .cornerRadius(4)
                                .animation(.linear, value: fileUploader.uploadProgress)
                        }
                    }
                    .frame(height: 8)
                    .frame(width: 200)
                    
                    Text("\(Int(fileUploader.uploadProgress * 100))%")
                        .font(.caption)
                        .foregroundColor(.blue)
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

