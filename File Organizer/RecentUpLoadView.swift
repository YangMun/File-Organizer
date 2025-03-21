import SwiftUI

struct RecentUpLoadView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("최근 업로드")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    // 모두 보기 액션
                }) {
                    Text("모두 보기")
                        .foregroundColor(.blue)
                }
            }
            
            ForEach(["회의록.pdf", "제안서.docx", "발표자료.pptx"], id: \.self) { file in
                HStack {
                    Image(systemName: file.contains("pdf") ? "doc.fill" :
                            file.contains("docx") ? "doc.text.fill" : "doc.on.doc.fill")
                        .foregroundColor(file.contains("pdf") ? .red :
                                        file.contains("docx") ? .blue : .orange)
                    
                    VStack(alignment: .leading) {
                        Text(file)
                            .font(.system(size: 16))
                        Text("2.4 MB • 오늘")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

