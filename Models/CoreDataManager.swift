import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    private let viewContext: NSManagedObjectContext
    
    init() {
        self.viewContext = PersistenceController.shared.container.viewContext
    }
    
    // MARK: - Create or Update
    func saveFile(_ uploadedFile: UploadedFile) {
        // 기존 파일 검색 (경로로 검색)
        let request: NSFetchRequest<FileEntity> = FileEntity.fetchRequest()
        if let path = uploadedFile.url?.path {
            request.predicate = NSPredicate(format: "path == %@", path)
        }
        
        do {
            let results = try viewContext.fetch(request)
            let fileEntity: FileEntity
            
            if let existingFile = results.first {
                // 기존 파일 업데이트
                fileEntity = existingFile
                print("기존 파일 업데이트: \(uploadedFile.name)")
            } else {
                // 새 파일 생성
                fileEntity = FileEntity(context: viewContext)
                fileEntity.id = uploadedFile.id
                print("새 파일 생성: \(uploadedFile.name)")
            }
            
            // 파일 정보 업데이트
            fileEntity.name = uploadedFile.name
            fileEntity.size = uploadedFile.size
            fileEntity.dateUploaded = uploadedFile.date
            fileEntity.fileExtension = uploadedFile.fileExtension
            fileEntity.bookmarkData = uploadedFile.bookmarkData
            if let url = uploadedFile.url {
                fileEntity.path = url.path
            }
            
            try viewContext.save()
            print("파일 저장 성공: \(uploadedFile.name)")
            // 저장 후 전체 파일 목록 출력 (확인용)
            printAllFiles()
            
        } catch {
            print("파일 저장 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Read
    func fetchAllFiles() -> [FileEntity] {
        let request: NSFetchRequest<FileEntity> = FileEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FileEntity.dateUploaded, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("파일 조회 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchRecentFiles(limit: Int = 10) -> [FileEntity] {
        let request: NSFetchRequest<FileEntity> = FileEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FileEntity.dateUploaded, ascending: false)]
        request.fetchLimit = limit
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("최근 파일 조회 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Delete
    func deleteFile(_ file: FileEntity) {
        viewContext.delete(file)
        
        do {
            try viewContext.save()
        } catch {
            print("파일 삭제 실패: \(error.localizedDescription)")
        }
    }
    
    func deleteFiles(_ files: [FileEntity]) {
        files.forEach { viewContext.delete($0) }
        
        do {
            try viewContext.save()
        } catch {
            print("파일들 삭제 실패: \(error.localizedDescription)")
        }
    }
    
    // 디버그용 함수 추가
    func printAllFiles() {
        let files = fetchAllFiles()
        print("\n=== 저장된 파일 목록 ===")
        files.forEach { file in
            print("""
                
                파일명: \(file.name ?? "Unknown")
                ID: \(file.id?.uuidString ?? "No ID")
                크기: \(ByteCountFormatter.string(fromByteCount: Int64(file.size), countStyle: .file))
                확장자: \(file.fileExtension ?? "Unknown")
                업로드 날짜: \(file.dateUploaded ?? Date())
                경로: \(file.path ?? "No path")
                ----------------------
                """)
        }
        print("총 \(files.count)개의 파일이 저장됨\n")
    }
}
