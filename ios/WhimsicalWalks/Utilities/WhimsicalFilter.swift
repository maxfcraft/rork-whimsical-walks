import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

struct WhimsicalFilter {
    private static let ciContext = CIContext(options: [.useSoftwareRenderer: false])

    static func applyFantasyFilter(to image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        let extent = ciImage.extent

        var result = ciImage

        let exposure = CIFilter.exposureAdjust()
        exposure.inputImage = result
        exposure.ev = -0.4
        guard let exposureOut = exposure.outputImage else { return nil }
        result = exposureOut

        let highlightShadow = CIFilter.highlightShadowAdjust()
        highlightShadow.inputImage = result
        highlightShadow.highlightAmount = 0.1
        highlightShadow.shadowAmount = -0.05
        guard let hsOut = highlightShadow.outputImage else { return nil }
        result = hsOut

        let colorControls = CIFilter.colorControls()
        colorControls.inputImage = result
        colorControls.brightness = 0.04
        colorControls.contrast = 1.05
        colorControls.saturation = 1.35
        guard let ccOut = colorControls.outputImage else { return nil }
        result = ccOut

        let vibrance = CIFilter.vibrance()
        vibrance.inputImage = result
        vibrance.amount = -0.1
        guard let vibOut = vibrance.outputImage else { return nil }
        result = vibOut

        let tempTint = CIFilter.temperatureAndTint()
        tempTint.inputImage = result
        tempTint.neutral = CIVector(x: 6500, y: 0)
        tempTint.targetNeutral = CIVector(x: 5500, y: 65)
        guard let ttOut = tempTint.outputImage else { return nil }
        result = ttOut

        let sharpen = CIFilter.sharpenLuminance()
        sharpen.inputImage = result
        sharpen.sharpness = 0.3
        sharpen.radius = 1.5
        guard let sharpOut = sharpen.outputImage else { return nil }
        result = sharpOut

        let bloom = CIFilter.bloom()
        bloom.inputImage = result
        bloom.radius = 8
        bloom.intensity = 0.15
        guard let bloomOut = bloom.outputImage else { return nil }
        result = bloomOut

        guard let cgImage = ciContext.createCGImage(result, from: extent) else { return nil }
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
}
