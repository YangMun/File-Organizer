import SwiftUI

struct FileTypeItem: Identifiable {
    let id = UUID()
    let imageName: String
    let titleKo: String
    let titleEn: String
    
    var title: String {
        @AppStorage("isEnglish") var isEnglish = false
        return isEnglish ? titleEn : titleKo
    }
}

struct FileView: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("isEnglish") private var isEnglish = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    let fileTypes = [
        FileTypeItem(
            imageName: "PDF", 
            titleKo: "PDF 파일",
            titleEn: "PDF Files"
        ),
        FileTypeItem(
            imageName: "Word", 
            titleKo: "워드 문서",
            titleEn: "Word Documents"
        ),
        FileTypeItem(
            imageName: "HWP", 
            titleKo: "한글 문서",
            titleEn: "Hangul Documents"
        ),
        FileTypeItem(
            imageName: "Excel", 
            titleKo: "엑셀 파일",
            titleEn: "Excel Files"
        ),
        FileTypeItem(
            imageName: "PPT", 
            titleKo: "PPT 파일",
            titleEn: "PPT Files"
        )
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(fileTypes) { item in
                        NavigationLink(destination: ShowFileFolder(fileType: item.title)) {
                            VStack {
                                Image(item.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .padding(.bottom, 8)
                                
                                Text(item.title)
                                    .font(.system(size: 14))
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 120)
                            .background(colorScheme == .dark ? Color(UIColor.systemGray5) : .white)
                            .cornerRadius(12)
                            .shadow(
                                color: colorScheme == .dark ? .black.opacity(0.3) : .black.opacity(0.1),
                                radius: 5,
                                x: 0,
                                y: 2
                            )
                        }
                    }
                }
                .padding()
            }
            .background(colorScheme == .dark ? Color(UIColor.systemGray6).opacity(0.8) : Color(UIColor.systemGray6))
            .navigationTitle(isEnglish ? "Files" : "파일")
        }
    }
}

#Preview {
    FileView()
}

