//
//  FilterViewController.swift
//  demo
//
//  Created by Phil Chang on 2024/5/1.
//  Copyright © 2024  All rights reserved.
//        

import UIKit
import GPUImage

class FilterViewController: UIViewController {
    @IBOutlet weak var filterButton1: UIButton!
    @IBOutlet weak var filterButton2: UIButton!
    @IBOutlet weak var filterButton3: UIButton!
    @IBOutlet weak var filterButton4: UIButton!
    @IBOutlet weak var imageView: UIImageView!

    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = image

        let rect = CGRect(x: 0, y: 0, width: 75, height: 75)
        UIGraphicsBeginImageContext(rect.size)
        image?.draw(in: rect)
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        filterButton1.setBackgroundImage(imageWithSepiaFilter(thumbnail), for: .normal)
        filterButton2.setBackgroundImage(imageWithBrightnessFilter(thumbnail), for: .normal)
        filterButton3.setBackgroundImage(imageWithHazeFilter(thumbnail), for: .normal)
        filterButton4.setBackgroundImage(imageWithSketchFilter(thumbnail), for: .normal)
    }

    func imageWithSepiaFilter(_ originImage: UIImage?) -> UIImage? {
        guard let inputImage = originImage else { return nil }
        
        let pictureInput = PictureInput(image: inputImage)
        let pictureOutput = PictureOutput()

        let sepiaFilter = SepiaToneFilter()

        var outputImage: UIImage?
        pictureOutput.imageAvailableCallback = { filteredImage in
            outputImage = filteredImage
        }

        // 開始處理
        pictureInput.processImage(synchronously: true)

        return outputImage
    }

    func imageWithBrightnessFilter(_ originImage: UIImage?) -> UIImage? {
        guard let inputImage = originImage else { return nil }

        let pictureInput = PictureInput(image: inputImage)
        let pictureOutput = PictureOutput()

        let sepiaFilter = BrightnessAdjustment()

        var outputImage: UIImage?
        pictureOutput.imageAvailableCallback = { filteredImage in
            outputImage = filteredImage
        }

        // 開始處理
        pictureInput.processImage(synchronously: true)

        return outputImage
    }

    func imageWithHazeFilter(_ originImage: UIImage?) -> UIImage? {
        guard let inputImage = originImage else { return nil }

        let pictureInput = PictureInput(image: inputImage)
        let pictureOutput = PictureOutput()

        let sepiaFilter = Haze()

        var outputImage: UIImage?
        pictureOutput.imageAvailableCallback = { filteredImage in
            outputImage = filteredImage
        }

        // 開始處理
        pictureInput.processImage(synchronously: true)

        return outputImage
    }

    func imageWithSketchFilter(_ originImage: UIImage?) -> UIImage? {
        guard let inputImage = originImage else { return nil }

        let pictureInput = PictureInput(image: inputImage)
        let pictureOutput = PictureOutput()

        let sepiaFilter = SketchFilter()

        var outputImage: UIImage?
        pictureOutput.imageAvailableCallback = { filteredImage in
            outputImage = filteredImage
        }

        // 開始處理
        pictureInput.processImage(synchronously: true)

        return outputImage
    }

    @IBAction func filterButton1Click(_ sender: Any) {
        imageView.image = imageWithSepiaFilter(image)
    }

    @IBAction func filterButton2Click(_ sender: Any) {
        imageView.image = imageWithBrightnessFilter(image)
    }

    @IBAction func filterButton3Click(_ sender: Any) {
        imageView.image = imageWithHazeFilter(image)
    }

    @IBAction func filterButton4Click(_ sender: Any) {
        imageView.image = imageWithSketchFilter(image)
    }

    @IBAction func closeButtonClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func saveButtonClick(_ sender: Any) {
        image = imageView.image
        closeButtonClick(sender)
    }
}

