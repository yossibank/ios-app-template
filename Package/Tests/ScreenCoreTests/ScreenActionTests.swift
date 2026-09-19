import Foundation
@testable import ScreenCore
import Testing

@MainActor
struct ScreenActionTests {
    @Test("同じ画面の同じ種類なら等しい")
    func sameScreenSameKind() {
        let id = UUID()
        let a = ScreenAction(.reload, screenID: id) {}
        let b = ScreenAction(.reload, screenID: id) {}
        #expect(a == b)
    }

    @Test("画面が変わると等しくない")
    func differentScreen() {
        let a = ScreenAction(.reload, screenID: UUID()) {}
        let b = ScreenAction(.reload, screenID: UUID()) {}
        #expect(a != b)
    }

    @Test("種類が変わると等しくない")
    func differentKind() {
        let id = UUID()
        let a = ScreenAction(.reload, screenID: id) {}
        let b = ScreenAction(.loadMore, screenID: id) {}
        #expect(a != b)
    }

    @Test("既定値は画面の動作と等しくない")
    func defaultIsDistinct() {
        #expect(ScreenAction(.reload) != ScreenAction(.reload, screenID: UUID()) {})
    }

    @Test("既定値は何もしないが呼べる")
    func defaultIsCallable() {
        ScreenAction(.reload)()
    }

    @Test("呼ぶと渡した処理が走る")
    func callsThrough() {
        final class Box { var hit = 0 }
        let box = Box()
        let action = ScreenAction(.reload, screenID: UUID()) { box.hit += 1 }
        action()
        action()
        #expect(box.hit == 2)
    }
}
