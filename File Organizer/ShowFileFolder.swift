import SwiftUI

struct ShowFileFolder: View {
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
            case "PDF 파일":
                return document.fileExtension?.lowercased() == "pdf"
            case "워드 문서":
                return ["doc", "docx"].contains(document.fileExtension?.lowercased() ?? "")
            case "한글 문서":
                return document.fileExtension?.lowercased() == "hwp"
            case "엑셀 파일":
                return ["xls", "xlsx"].contains(document.fileExtension?.lowercased() ?? "")
            case "PPT 파일":
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
            SearchBar(text: $searchText, isSearching: $isSearching)
                .padding(.horizontal)
                .padding(.top)
            
            if filteredDocuments.isEmpty {
                EmptyStateView()
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
                                selectedItems: $selectedItems
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
                            // 전체 선택
                            selectedItems = Set(filteredDocuments.compactMap { $0.id })
                        } else {
                            // 선택 해제
                            selectedItems.removeAll()
                        }
                    }) {
                        Text(selectedItems.isEmpty ? "전체 선택" : "선택 해제")
                    }
                    .padding()
                    
                    Spacer()
                    
                    Button(action: {
                        deleteSelectedFiles()
                    }) {
                        Text("선택 삭제")
                            .foregroundColor(.red)
                    }
                    .padding()
                    .disabled(selectedItems.isEmpty)
                }
                .background(Color(.systemBackground))
            }
        }
        .navigationTitle(categoryType)
        .navigationBarItems(trailing: editButton)
        .onAppear {
            loadDocuments()
        }
        .refreshable {
            loadDocuments()
        }
        .alert("삭제 완료", isPresented: $showDeleteAlert) {
            Button("확인", role: .cancel) {
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
            Text(isEditMode ? "완료" : "편집")
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
        deletedFileName = "\(fileNames) 파일이 삭제되었습니다."
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
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("파일 검색", text: $text)
                    .foregroundColor(.primary)
                
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
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}

// 문서 카드 컴포넌트
struct DocumentCard: View {
    let document: FileEntity
    @Binding var showDeleteAlert: Bool
    @Binding var deletedFileName: String
    @Binding var selectedDocuments: [FileEntity]
    @Binding var isEditMode: Bool
    @Binding var selectedItems: Set<UUID>
    
    var body: some View {
        HStack {
            if isEditMode {
                // 체크박스
                Image(systemName: selectedItems.contains(document.id!) ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(selectedItems.contains(document.id!) ? .blue : .gray)
                    .imageScale(.large)
                    .padding(.leading)
            }
            
            NavigationLink(destination: FileDetailView(document: document)) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        // 파일 타입 아이콘
                        Image(systemName: "doc.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(document.name ?? "Unknown")
                                .font(.headline)
                                .lineLimit(1)
                            
                            Text(document.fileExtension?.uppercased() ?? "")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        // 파일 크기
                        Text(ByteCountFormatter.string(fromByteCount: Int64(document.size), countStyle: .file))
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        // 화살표 추가
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .padding(.leading, 8)
                    }
                    
                    Divider()
                    
                    // 업로드 날짜
                    Text("업로드: \((document.dateUploaded ?? Date()).formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
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
                deletedFileName = "\(document.name ?? "Unknown") 파일이 삭제되었습니다."
                CoreDataManager.shared.deleteFile(document)
                if let index = selectedDocuments.firstIndex(where: { $0.id == document.id }) {
                    selectedDocuments.remove(at: index)
                }
                showDeleteAlert = true
            }) {
                Label("삭제", systemImage: "trash")
            }
        }
    }
}

// 빈 상태 뷰
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("파일이 없습니다")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("이 카테고리에 해당하는 파일이 아직 없습니다")
                .font(.subheadline)
                .foregroundColor(.gray)
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
