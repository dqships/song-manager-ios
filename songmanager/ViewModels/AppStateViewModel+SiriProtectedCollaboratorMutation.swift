import CoreData
import Foundation

extension AppStateViewModel {
    func deleteCollaboratorForSiri(id: UUID) throws {
        let collaborator = try fetchCollaboratorForSiri(by: id)
        try performSiriMutation { context.delete(collaborator) }
    }
}
