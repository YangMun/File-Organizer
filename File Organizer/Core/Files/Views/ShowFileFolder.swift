import SwiftUI

struct ShowFileFolder: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("isEnglish") private var isEnglish = false
    @State private var selectedDocuments: [FileEntity] = []
    @State private var isSearching: Bool = false
    @State private var searchText: String = ""
    @State private var showDeleteAlert = false
    @State private var deletedFileName = ""
    @State private var isEditMode = false  // 편집 모드 상태
    @State private var selectedItems = Set<UUID>()  // 선택된 파일들의 ID
    let categoryType: String
    
    init(fileType: String) {
        self.categoryType = fileType
    }
    
    private func loadDocuments() {
        let allDocuments = CoreDataManager.shared.fetchAllFiles()
        
        // 파일 타입에 따른 필터링
        selectedDocuments = allDocuments.filter { document in
            switch categoryType {
            case isEnglish ? "PDF Files" : "PDF 파일":
                return document.fileExtension?.lowercased() == "pdf"
            case isEnglish ? "Word Documents" : "워드 문서":
                return ["doc", "docx"].contains(document.fileExtension?.lowercased() ?? "")
            case isEnglish ? "Hangul Documents" : "한글 문서":
                return document.fileExtension?.lowercased() == "hwp"
            case isEnglish ? "Excel Files" : "엑셀 파일":
                return ["xls", "xlsx"].contains(document.fileExtension?.lowercased() ?? "")
            case isEnglish ? "PPT Files" : "PPT 파일":
                return ["ppt", "pptx"].contains(document.fileExtension?.lowercased() ?? "")
            default:
                return false
            }
        }
    }
    
    var filteredDocuments: [FileEntity] {
        if searchText.isEmpty {
            return selectedDocuments
        }
        return selectedDocuments.filter { $0.name?.localizedCaseInsensitiveContains(searchText) ?? false }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 검색 바
            SearchBar(text: $searchText, isSearching: $isSearching, colorScheme: colorScheme)
                .padding(.horizontal)
                .padding(.top)
            
            if filteredDocuments.isEmpty {
                EmptyStateView(colorScheme: colorScheme)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredDocuments, id: \.id) { document in
                            DocumentCard(
                                document: document,
                                showDeleteAlert: $showDeleteAlert,
                                deletedFileName: $deletedFileName,
                                selectedDocuments: $selectedDocuments,
                                isEditMode: $isEditMode,
                                selectedItems: $selectedItems,
                                colorScheme: colorScheme
                            )
                        }
                    }
                    .padding()
                }
            }
            
            // 편집 모드일 때 보여줄 하단 버튼
            if isEditMode {
                HStack {
                    Button(action: {
                        if selectedItems.isEmpty {
                            selectedItems = Set(filteredDocuments.compactMap { $0.id })
                        } else {
                            selectedItems.removeAll()
                        }
                    }) {
                        Text(selectedItems.isEmpty ? 
                             (isEnglish ? "Select All" : "전체 선택") : 
                             (isEnglish ? "Deselect All" : "선택 해제"))
                            .foregroundColor(.blue)
                    }
                    .padding()
                    
                    Spacer()
                    
                    Button(action: {
                        deleteSelectedFiles()
                    }) {
                        Text(isEnglish ? "Delete Selected" : "선택 삭제")
                            .foregroundColor(.red)
                    }
                    .padding()
                    .disabled(selectedItems.isEmpty)
                }
                .background(colorScheme == .dark ? Color(UIColor.systemGray5) : Color(.systemBackground))
            }
        }
        .background(colorScheme == .dark ? Color.black : Color(.systemGroupedBackground))
        .navigationTitle(categoryType)
        .navigationBarItems(trailing: editButton)
        .onAppear {
            loadDocuments()
        }
        .refreshable {
            loadDocuments()
        }
        .alert(isEnglish ? "Delete Complete" : "삭제 완료", isPresented: $showDeleteAlert) {
            Button(isEnglish ? "OK" : "확인", role: .cancel) {
                selectedItems.removeAll()
            }
        } message: {
            Text(deletedFileName)
        }
    }
    
    // 편집 버튼
    private var editButton: some View {
        Button(action: {
            isEditMode.toggle()
            if !isEditMode {
                selectedItems.removeAll()
            }
        }) {
            Text(isEditMode ? 
                 (isEnglish ? "Done" : "완료") : 
                 (isEnglish ? "Edit" : "편집"))
        }
    }
    
    // 선택된 파일들 삭제
    private func deleteSelectedFiles() {
        let filesToDelete = selectedDocuments.filter { selectedItems.contains($0.id!) }
        let fileNames = filesToDelete.compactMap { $0.name }.joined(separator: ", ")
        
        for file in filesToDelete {
            CoreDataManager.shared.deleteFile(file)
        }
        
        selectedDocuments.removeAll { selectedItems.contains($0.id!) }
        deletedFileName = isEnglish ? 
            "\(fileNames) files have been deleted." : 
            "\(fileNames) 파일이 삭제되었습니다."
        showDeleteAlert = true
        
        if selectedDocuments.isEmpty {
            isEditMode = false
        }
    }
}

// 검색바 컴포넌트
struct SearchBar: View {
    @Binding var text: String
    @Binding var isSearching: Bool
    @AppStorage("isEnglish") private var isEnglish = false
    let colorScheme: ColorScheme
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField(isEnglish ? "Search files" : "파일 검색", text: $text)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(8)
            .background(colorScheme == .dark ? Color(UIColor.systemGray6) : Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}

// 문서 카드 컴포넌트
struct DocumentCard: View {
    @AppStorage("isEnglish") private var isEnglish = false
    let document: FileEntity
    @Binding var showDeleteAlert: Bool
    @Binding var deletedFileName: String
    @Binding var selectedDocuments: [FileEntity]
    @Binding var isEditMode: Bool
    @Binding var selectedItems: Set<UUID>
    let colorScheme: ColorScheme
    
    // 파일 타입에 따른 이미지 이름 반환
    private func getFileImage(fileExtension: String?) -> String {
        guard let ext = fileExtension?.lowercased() else { return "PDF" }
        
        switch ext {
        case "pdf":
            return "PDF"
        case "doc", "docx":
            return "Word"
        case "hwp":
            return "HWP"
        case "xls", "xlsx":
            return "Excel"
        case "ppt", "pptx":
            return "PPT"
        default:
            return "PDF"
        }
    }
    
    var body: some View {
        HStack {
            if isEditMode {
                Image(systemName: selectedItems.contains(document.id!) ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(selectedItems.contains(document.id!) ? .blue : .gray)
                    .imageScale(.large)
                    .padding(.leading)
            }
            
            NavigationLink(destination: FileDetailView(document: document)) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        // 파일 타입 아이콘을 Assets의 이미지로 변경
                        Image(getFileImage(fileExtension: document.fileExtension))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(document.name ?? "Unknown")
                                .font(.headline)
                                .lineLimit(1)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            
                            Text(document.fileExtension?.uppercased() ?? "")
                                .font(.caption)
                                .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                        }
                        
                        Spacer()
                        
                        Text(ByteCountFormatter.string(fromByteCount: Int64(document.size), countStyle: .file))
                            .font(.caption)
                            .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                            .padding(.leading, 8)
                    }
                    
                    Divider()
                        .background(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.2))
                    
                    Text("업로드: \((document.dateUploaded ?? Date()).formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                }
                .padding()
                .background(colorScheme == .dark ? Color(UIColor.systemGray5) : Color(.systemBackground))
                .cornerRadius(12)
                .shadow(
                    color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.1),
                    radius: 5,
                    x: 0,
                    y: 2
                )
            }
            .disabled(isEditMode)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if isEditMode {
                if selectedItems.contains(document.id!) {
                    selectedItems.remove(document.id!)
                } else {
                    selectedItems.insert(document.id!)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button(action: {
                deletedFileName = isEnglish ?
                    "\(document.name ?? "Unknown") file has been deleted." :
                    "\(document.name ?? "Unknown") 파일이 삭제되었습니다."
                CoreDataManager.shared.deleteFile(document)
                if let index = selectedDocuments.firstIndex(where: { $0.id == document.id }) {
                    selectedDocuments.remove(at: index)
                }
                showDeleteAlert = true
            }) {
                Label(isEnglish ? "Delete" : "삭제", systemImage: "trash")
            }
        }
    }
}

// 빈 상태 뷰
struct EmptyStateView: View {
    @AppStorage("isEnglish") private var isEnglish = false
    let colorScheme: ColorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(colorScheme == .dark ? .gray : .secondary)
            
            Text(isEnglish ? "No Files" : "파일이 없습니다")
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            
            Text(isEnglish ? 
                 "There are no files in this category yet" : 
                 "이 카테고리에 해당하는 파일이 아직 없습니다")
                .font(.subheadline)
                .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NavigationView {
        ShowFileFolder(fileType: "PDF 파일")
    }
}
