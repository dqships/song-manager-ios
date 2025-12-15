import Foundation

enum SiriRoleSet {
    static func applying(_ roles: Set<Contribution>, to current: Set<Contribution>, change: SiriRoleChange) -> Set<Contribution> {
        switch change {
        case .add: current.union(roles)
        case .remove: current.subtracting(roles)
        case .replace: roles
        }
    }
}
