//
//  UIImage+CameraFilters.swift
//  IRCameraViewController-swift
//
//  Created by Phil Chang on 2024/5/1.

import UIKit
import CoreImage

extension UIImage {

    func curveFilter() -> UIImage? {
        guard let inputImage = CIImage(image: self) else { return nil }

        let filter = CIFilter(name: "CIToneCurve")!
        filter.setDefaults()
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(CIVector(x: 0, y: 0), forKey: "inputPoint0")
        filter.setValue(CIVector(x: 0.25, y: 0.15), forKey: "inputPoint1")
        filter.setValue(CIVector(x: 0.5, y: 0.5), forKey: "inputPoint2")
        filter.setValue(CIVector(x: 0.75, y: 0.85), forKey: "inputPoint3")
        filter.setValue(CIVector(x: 1, y: 1), forKey: "inputPoint4")

        return imageFromContext(withFilter: filter)
    }

    func saturateImage(_ saturation: CGFloat, withContrast contrast: CGFloat) -> UIImage? {
        guard let inputImage = CIImage(image: self) else { return nil }

        let filter = CIFilter(name: "CIColorControls")!
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(saturation, forKey: "inputSaturation")
        filter.setValue(contrast, forKey: "inputContrast")

        return imageFromContext(withFilter: filter)
    }

    func vignetteWithRadius(_ radius: CGFloat, intensity: CGFloat) -> UIImage? {
        guard let inputImage = CIImage(image: self) else { return nil }

        let filter = CIFilter(name: "CIVignette")!
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(intensity, forKey: "inputIntensity")
        filter.setValue(radius, forKey: "inputRadius")

        return imageFromContext(withFilter: filter)
    }

    private func imageFromContext(withFilter filter: CIFilter) -> UIImage? {
        let context = CIContext(options: nil)
        guard let outputImage = filter.outputImage, let cgimg = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        let image = UIImage(cgImage: cgimg, scale: scale, orientation: imageOrientation)
        return image
    }
}
