import CoreText
import SwiftUI
import UIKit

public enum Atelier {
    static let fontsRegistered: Void = {
        let urls = [
            "CormorantGaramond-Medium",
            "CormorantGaramond-SemiBold",
            "CormorantGaramond-MediumItalic"
        ].compactMap {
            Bundle.module.url(forResource: $0, withExtension: "ttf")
        }

        CTFontManagerRegisterFontURLs(urls as CFArray, .process, true, nil)
    }()
}

public extension Color {
    static let atelierGround = Color(light: 0xF7F4EF, dark: 0x171513)
    static let atelierInk = Color(light: 0x1D1B18, dark: 0xEFE9DF)
    static let atelierMuted = Color(light: 0x6B655C, dark: 0xA69E91)
    static let atelierLine = Color(light: 0xD8D0C4, dark: 0x3A352F)
    static let atelierTrack = Color(light: 0xE2DBCF, dark: 0x2E2A25)
    static let atelierTile = Color(light: 0xEDE7DD, dark: 0xE6DFD3)
    static let atelierOnTile = Color(light: 0x4A453E, dark: 0x4A453E)
    static let atelierSkeleton = Color(light: 0xE9E3D9, dark: 0x26221E)
    static let atelierMark = Color(light: 0xE6D9BF, dark: 0x5A4B30)
    static let atelierError = Color(light: 0x9A3B2E, dark: 0xE08A73)
}

public extension Font {
    static func atelierSerif(
        _ size: CGFloat,
        relativeTo style: TextStyle = .body,
        semibold: Bool = false,
        italic: Bool = false
    ) -> Font {
        _ = Atelier.fontsRegistered

        let name = switch (semibold, italic) {
        case (_, true): "CormorantGaramond-MediumItalic"
        case (true, false): "CormorantGaramond-SemiBold"
        case (false, false): "CormorantGaramond-Medium"
        }

        return .custom(name, size: size, relativeTo: style)
    }

    static func atelierMincho(
        _ size: CGFloat,
        relativeTo style: TextStyle = .body,
        bold: Bool = false
    ) -> Font {
        .custom(bold ? "HiraMinProN-W6" : "HiraMinProN-W3", size: size, relativeTo: style)
    }
}

private extension Color {
    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { traits in
            UIColor(rgb: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

private extension UIColor {
    convenience init(rgb: UInt32) {
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8) & 0xFF) / 255,
            blue: CGFloat(rgb & 0xFF) / 255,
            alpha: 1
        )
    }
}
