import SwiftUI
import UIKit

enum PetSpritePosition: Int, CaseIterable, Sendable {
    case koala = 0
    case lion = 1
    case frog = 2
    case pig = 3
    case cat = 4
    case rabbit = 5
    case panda = 6
    case penguin = 7
    case bear = 8

    var row: Int { rawValue / 3 }
    var col: Int { rawValue % 3 }
}

struct PetSpriteView: View {
    let position: PetSpritePosition
    let size: CGFloat

    private func cropRect(for image: UIImage) -> CGRect {
        let imgW = image.size.width
        let imgH = image.size.height
        let cellW = imgW / 3.0
        let cellH = imgH / 3.0
        var cropX = CGFloat(position.col) * cellW
        let cropY = CGFloat(position.row) * cellH
        var cropW = cellW

        if position == .koala {
            let extraLeft = cellW * 0.08
            cropX = max(0, cropX - extraLeft)
            cropW = cellW + extraLeft
        }

        if position == .lion {
            let trimLeft = cellW * 0.06
            cropX += trimLeft
            cropW -= trimLeft
        }

        return CGRect(x: cropX, y: cropY, width: min(cropW, imgW - cropX), height: min(cellH, imgH - cropY))
    }

    var body: some View {
        if let fullImage = UIImage(named: "PetStickers") {
            let rect = cropRect(for: fullImage)
            if let cgCropped = fullImage.cgImage?.cropping(to: rect) {
                let cropped = UIImage(cgImage: cgCropped)
                Image(uiImage: cropped)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
            }
        }
    }
}
