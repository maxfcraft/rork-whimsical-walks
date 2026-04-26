import SwiftUI
import UIKit

struct WallpaperManager {
    static let fileName = "polaroids_wallpaper.jpg"
    static let storageKey = "polaroids_custom_wallpaper_set"

    static var directory: URL {
        URL.documentsDirectory.appending(path: "wallpapers")
    }

    static var wallpaperURL: URL {
        directory.appending(path: fileName)
    }

    static func ensureDirectory() {
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    @discardableResult
    static func save(_ image: UIImage) -> Bool {
        ensureDirectory()
        guard let data = image.jpegData(compressionQuality: 0.85) else { return false }
        do {
            try data.write(to: wallpaperURL)
            UserDefaults.standard.set(true, forKey: storageKey)
            return true
        } catch {
            return false
        }
    }

    static func load() -> UIImage? {
        guard UserDefaults.standard.bool(forKey: storageKey) else { return nil }
        guard let data = try? Data(contentsOf: wallpaperURL) else { return nil }
        return UIImage(data: data)
    }

    static func clear() {
        try? FileManager.default.removeItem(at: wallpaperURL)
        UserDefaults.standard.set(false, forKey: storageKey)
    }
}
