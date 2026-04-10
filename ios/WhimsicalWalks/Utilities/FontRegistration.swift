import SwiftUI
import CoreText

enum FontRegistration {
    static func registerFonts() {
        registerFont(named: "Keshia", extension: "ttf")
    }

    private static func registerFont(named name: String, extension ext: String) {
        guard let fontURL = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "Fonts")
                ?? Bundle.main.url(forResource: name, withExtension: ext) else {
            return
        }
        CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
    }

    static let keshia: String = {
        registerFonts()
        return "Keshia"
    }()
}
