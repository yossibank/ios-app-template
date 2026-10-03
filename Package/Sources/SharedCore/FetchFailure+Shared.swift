import ScreenCore
import Shared

extension FetchFailure {
    init(_ failure: any ApiFailure) {
        self = switch onEnum(of: failure) {
        case .offline:
            .offline

        case .timeout:
            .timeout

        case let .server(server):
            .server(statusCode: Int(server.statusCode), canRetry: server.canRetry)

        case .unreadable:
            .unreadable

        case .unauthorized:
            .unauthorized
        }
    }
}
