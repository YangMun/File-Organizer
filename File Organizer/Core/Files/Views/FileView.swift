import SwiftUI

struct FileTypeItem: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
}

struct FileView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    let fileTypes = [
        FileTypeItem(imageName: "PDF", title: "PDF 파일"),
        FileTypeItem(imageName: "Word", title: "워드 문서"),
        FileTypeItem(imageName: "HWP", title: "한글 문서"),
        FileTypeItem(imageName: "Excel", title: "엑셀 파일"),
        FileTypeItem(imageName: "PPT", title: "PPT 파일")
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
        }
    }
}

#Preview {
    FileView()
}

