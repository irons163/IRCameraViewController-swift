//
//  IRAssetsLibrary.swift
//  IRCameraViewController-swift
//
//  Created by Phil Chang on 2024/5/1.
//  Copyright © 2024  All rights reserved.
//        

import Foundation
import UIKit
import Photos

typealias IRAssetsResultCompletion = (URL) -> Void
typealias IRAssetsFailureCompletion = (Error?) -> Void
typealias IRAssetsLoadImagesCompletion = ([IRAssetImageFile]?, Error?) -> Void

class IRAssetsLibrary: PHPhotoLibrary {

    // Singleton pattern for centralized management of the asset library
    static let defaultAssetsLibrary: IRAssetsLibrary = {
        let instance = IRAssetsLibrary()
        return instance
    }()

    private override init() {
        super.init()
    }

    // MARK: - Public Methods
    func deleteFile(_ file: IRAssetImageFile) {
        let fileManager = FileManager.default

        if fileManager.isDeletableFile(atPath: file.path) {
            try? fileManager.removeItem(atPath: file.path)
        }
    }

    func loadImagesFromDocumentDirectory() -> [IRAssetImageFile]? {
        guard let directory = directory() else {
            return nil
        }

        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: directory)
            var items = [IRAssetImageFile]()
            for name in contents {
                let path = (directory as NSString).appendingPathComponent(name)
                if let data = NSData(contentsOfFile: path) as Data? {
                    if let image = UIImage(data: data) {
                        let file = IRAssetImageFile(path: path, image: image)
                        items.append(file)
                    }
                }
            }
            return items
        } catch {
            return nil
        }
    }

    func loadImagesFromAlbum(_ albumName: String, withCallback callback: @escaping IRAssetsLoadImagesCompletion) {
        var items = [IRAssetImageFile]()

        // Assuming usage of Photos framework
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

        collections.enumerateObjects { (collection, index, stop) in
            let assets = PHAsset.fetchAssets(in: collection, options: nil)
            assets.enumerateObjects { (asset, index, stop) in
                let imageManager = PHImageManager.default()
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                imageManager.requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFill, options: options) { (image, info) in
                    if let image = image {
                        let file = IRAssetImageFile(path: asset.localIdentifier, image: image)
                        items.append(file)
                    }
                }
            }
            callback(items, nil)
        }
    }

    func saveImage(_ image: UIImage, completion: @escaping IRAssetsResultCompletion, failureBlock: @escaping IRAssetsFailureCompletion) {
        guard let data = image.jpegData(compressionQuality: 1.0),
              let directory = directory() else {
            failureBlock(nil)
            return
        }

        let fileName = UUID().uuidString.appending(".jpg")
        let fullPath = (directory as NSString).appendingPathComponent(fileName)

        do {
            try data.write(to: URL(fileURLWithPath: fullPath))
            completion(URL(fileURLWithPath: fullPath))
        } catch {
            failureBlock(error)
        }
    }

    // MARK: - Private Methods
    private func directory() -> String? {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0].appending("/Images/")

        if !FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                return nil
            }
        }

        return path
    }
}
