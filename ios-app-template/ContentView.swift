//
//  ContentView.swift
//  ios-app-template
//
//  Created by Kamiyama Yoshihito on 2026/08/30.
//

import SwiftUI
import Shared

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            // 文言は共通コア（kmp-app-template）から取得する。
            Text(Greeting().greet())
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
