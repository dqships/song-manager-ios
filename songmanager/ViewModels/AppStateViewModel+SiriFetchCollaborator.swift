import CoreData
import Foundation

extension AppStateViewModel {
    func fetchCollaboratorForSiri(by id: UUID) throws -> CollaboratorEntity {
        let request: NSFetchRequest<CollaboratorEntity> = CollaboratorEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        guard let collaborator = try context.fetch(request).first else { throw SiriDataError.collaboratorNotFound }
        return collaborator
    }
}
