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
        exposure.ev = -0.62
        guard let exposureOut = exposure.outputImage else { return nil }
        result = exposureOut

        let highlightShadow = CIFilter.highlightShadowAdjust()
        highlightShadow.inputImage = result
        highlightShadow.highlightAmount = 0.84
        highlightShadow.shadowAmount = 0.0
        guard let hsOut = highlightShadow.outputImage else { return nil }
        result = hsOut

        let colorControls = CIFilter.colorControls()
        colorControls.inputImage = result
        colorControls.brightness = -0.27
        colorControls.contrast = 0.50
        colorControls.saturation = 1.16
        guard let ccOut = colorControls.outputImage else { return nil }
        result = ccOut

        let tempTint = CIFilter.temperatureAndTint()
        tempTint.inputImage = result
        tempTint.neutral = CIVector(x: 6500, y: 0)
        tempTint.targetNeutral = CIVector(x: 7120, y: 34)
        guard let ttOut = tempTint.outputImage else { return nil }
        result = ttOut

        let vignette = CIFilter.vignette()
        vignette.inputImage = result
        vignette.intensity = -0.39
        vignette.radius = 1.5
        guard let vigOut = vignette.outputImage else { return nil }
        result = vigOut

        guard let cgImage = ciContext.createCGImage(result, from: extent) else { return nil }
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
}
