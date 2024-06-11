//
//  helperExtnetions.swift
//  CometChatSwift
//
//  Created by admin on 15/08/23.
//  Copyright © 2023 MacMini-03. All rights reserved.
//

import Foundation
import UIKit


//gif edit
extension UIImageView {
    
    func loadGif(from url: URL) {
        
        //let workItem = DispatchWorkItem {
        
        self.image = UIImage(named: "default-image.png", in: UIKitSettings.bundle, compatibleWith: nil)
        self.animationImages = nil
        
        ImageCache.getImages(urlString: url.absoluteString) { imageArry in
            guard let imageArry = imageArry else {
                print("Not fpound")
                return
            }
            self.loadGif(fromImage: imageArry)
        }
    }
}

extension UIImage {
    static func cometChatGIF(data: Data) -> UIImage? {
        
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        
        var images: [UIImage] = []
        var duration = 0.0
        
        for index in 0..<CGImageSourceGetCount(source) {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil),
               let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [String: Any],
               let gifInfo = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any] {
                if let frameDuration = gifInfo[kCGImagePropertyGIFDelayTime as String] as? Double {
                    duration += frameDuration
                }
                images.append(UIImage(cgImage: cgImage))
            }
        }
        
        return UIImage.animatedImage(with: images, duration: duration)
    }
}



extension UIImage {
    func imageURL(formate: String) -> String? {
        guard let imageData = self.jpegData(compressionQuality: 1.0) else {
               return nil
           }
        
        if formate == "" && formate == "Unknown" {
            return ""
        }
           
           do {
               // Get the documents directory URL
               let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
               
               // Create a unique filename
               let filename = UUID().uuidString + formate
               
               // Construct the file URL
               let fileURL = documentsURL.appendingPathComponent(filename)
               
               // Write the image data to the file
               try imageData.write(to: fileURL)
               
               // Return the file URL as a string
               
               let finalPath = "file://" + fileURL.path
               return finalPath
           } catch {
               print("Error saving image: \(error)")
               return nil
           }
    }
}


extension UIImageView {
    func loadGif(fromImage images: [UIImage]) {
        DispatchQueue.global(qos: .userInitiated).async {
            
            let images: [UIImage] = images
            
            DispatchQueue.main.async {
                self.animationImages = images
                self.image = images[0]
                self.animationDuration = TimeInterval(images.count) * 0.1
                self.startAnimating()
            }
        }
    }
    
    func loadGif(fromData: Data) {
        
        self.image = UIImage(named: "default-image.png", in: UIKitSettings.bundle, compatibleWith: nil)
        self.animationImages = nil
        
        guard let source = CGImageSourceCreateWithData(fromData as CFData, nil) else {
            return
        }
        
        var images: [UIImage] = []
        
        for index in 0..<CGImageSourceGetCount(source) {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil) {
                images.append(UIImage(cgImage: cgImage))
            }
        }
        
        self.animationImages = images
        self.animationDuration = TimeInterval(images.count) * 0.1 // Adjust animation speed as needed
        self.startAnimating()
    }

}



extension Data {
    // Save data to a local file and return its URL
    func saveToLocalFile(named fileName: String) -> String? {
            do {
                let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let fileURL = documentsURL.appendingPathComponent(fileName)
                try self.write(to: fileURL)
                
                let finalPath = "file://" + fileURL.path
                print("file:// " + finalPath)
                
                return finalPath
            } catch {
                print("Error saving data to local file: \(error)")
                return nil
            }
    }
}


extension UIViewController {
    static func loadFromNib() -> Self {
        func instantiateFromNib<T: UIViewController>() -> T {
            return T.init(nibName: String(describing: T.self), bundle: nil)
        }

        return instantiateFromNib()
    }
}


import UIKit

import UIKit

class ImageCache {
    private static let cache = NSCache<NSString, CachedImages>()
    private static let cacheQueue = DispatchQueue.global()

    static func cacheImages(fromURL url: URL, complition: @escaping ([UIImage]?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let gifData = data {
                guard let source = CGImageSourceCreateWithData(gifData as CFData, nil) else {
                    return
                }
                
                var images: [UIImage] = []
                
                for index in 0..<CGImageSourceGetCount(source) {
                    if let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil) {
                        images.append(UIImage(cgImage: cgImage))
                    }
                }

                cacheQueue.async(flags: .barrier) {
                    cache.setObject(CachedImages(images: images), forKey: NSString(string: url.absoluteString))
                    complition(images)
                }
            }
        }.resume()
    }

    static func getImages(urlString: String, completion: @escaping ([UIImage]?) -> Void) {
        cacheQueue.async {
            if let cachedImages = cache.object(forKey: NSString(string: urlString))?.images {
                completion(cachedImages)
            } else {
                cacheImages(fromURL: URL(string: urlString)!, complition: completion)
            }
        }
    }

}

class CachedImages {
    let images: [UIImage]

    init(images: [UIImage]) {
        self.images = images
    }
}



import UIKit

extension UIImage {
    func imageType() -> String? {
        guard let imageData = self.jpegData(compressionQuality: 1.0) ?? self.pngData() else {
            return nil
        }
        
        var imageType: String?
        
        // JPEG signature bytes: [0xFF, 0xD8, 0xFF]
        let jpegSignature: [UInt8] = [0xFF, 0xD8, 0xFF]
        // PNG signature bytes: [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
        let pngSignature: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
        
        let dataBytes = [UInt8](imageData)
        
        if dataBytes.starts(with: jpegSignature) {
            imageType = "JPEG"
        } else if dataBytes.starts(with: pngSignature) {
            imageType = "PNG"
        } else {
            imageType = "JPEG"
        }
        
        return imageType
    }
}


