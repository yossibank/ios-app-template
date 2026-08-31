import FeatureHome
import SwiftUI

/// アプリの起点。画面の組み立てはここで行い、App 本体は起動と表示だけを持つ。
public struct AppRootView: View {
    public init() {}

    public var body: some View {
        HomeView()
    }
}
