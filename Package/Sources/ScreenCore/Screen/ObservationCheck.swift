#if DEBUG

    import Foundation

    @MainActor
    enum ObservationCheck {
        private static var verified: Set<ObjectIdentifier> = []

        static func assertObservable(_ object: AnyObject) {
            let concrete = type(of: object)
            let key = ObjectIdentifier(concrete)

            guard !verified.contains(key) else {
                return
            }

            verified.insert(key)

            let instrumented = Mirror(reflecting: object).children.contains {
                ($0.label ?? "").contains("observationRegistrar")
            }

            assert(
                instrumented,
                "\(concrete) に @Observable が付いていません。View が更新されません"
            )
        }
    }

#endif
