import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "FileOrganizer")
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data 저장소 로딩 실패: \(error.localizedDescription)")
            }
        }
        
        // 동일한 id의 파일이 있을 경우 업데이트하도록 설정
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
