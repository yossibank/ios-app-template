import Foundation

extension Int {
    var ungrouped: String {
        formatted(.number.grouping(.never))
    }
}
