import SwiftUI
import UIKit

struct PhotoManager {
    static var documentsDirectory: URL {
        URL.documentsDirectory.appending(path: "polaroids")
    }

    static func ensureDirectory() {
        try? FileManager.default.createDirectory(at: documentsDirectory, withIntermediateDirectories: true)
    }

    static func savePhoto(_ image: UIImage) -> String? {
        ensureDirectory()
        let filtered = WhimsicalFilter.applyFantasyFilter(to: image) ?? image
        let fileName = UUID().uuidString + ".jpg"
        let url = documentsDirectory.appending(path: fileName)
        guard let data = filtered.jpegData(compressionQuality: 0.8) else { return nil }
        do {
            try data.write(to: url)
            return fileName
        } catch {
            return nil
        }
    }

    static func loadPhoto(named fileName: String) -> UIImage? {
        let url = documentsDirectory.appending(path: fileName)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    static func photoURL(named fileName: String) -> URL {
        documentsDirectory.appending(path: fileName)
    }
}
