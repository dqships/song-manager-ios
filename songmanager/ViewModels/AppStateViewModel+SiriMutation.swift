import CoreData
import Foundation

extension AppStateViewModel {
    func performSiriMutation(_ mutation: () throws -> Void) throws {
        do {
            try mutation()
            try saveAndRefresh()
        } catch {
            context.rollback()
            try? saveAndRefresh()
            throw error
        }
    }
}
