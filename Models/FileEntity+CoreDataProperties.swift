import Foundation
import CoreData


extension FileEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FileEntity> {
        return NSFetchRequest<FileEntity>(entityName: "FileEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var size: Int64
    @NSManaged public var dateUploaded: Date?
    @NSManaged public var fileExtension: String?
    @NSManaged public var bookmarkData: Data?
    @NSManaged public var path: String?
    @NSManaged public var name: String?

}

extension FileEntity : Identifiable {

}
