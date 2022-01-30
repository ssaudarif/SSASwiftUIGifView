//
//  GifImageSource.swift
//  
//
//  Created by Syed Saud Arif on 08/01/22.
//

import Foundation
import ImageIO



extension CGImageSource {

    var frameCount: Int {
        CGImageSourceGetCount(self)
    }

    func frameDuration(at index: Int, _ config:GifConfig) -> TimeInterval? {
        guard let frameProperties = CGImageSourceCopyPropertiesAtIndex(self, index, config.imageSourceOptions()) as? [CFString: Any] else {
            return nil
        }

        var animationProperties = CGImageSource.imageProperties(from: frameProperties)

        if animationProperties == nil {
            if let properties = CGImageSourceCopyProperties(self, config.imageSourceOptions()) as? [CFString: Any] {
                //TODO : Need to check logic for HICS
                animationProperties = CGImageSource.animationHEICSProperties(from: properties, at: index)
            }
        }

        let duration: TimeInterval

        // Use the unclamped frame delay if it exists. Otherwise use the clamped frame delay.
        if let unclampedDelay = animationProperties?["UnclampedDelayTime" as CFString] as? TimeInterval {
            duration = unclampedDelay
        }
        else if let delay = animationProperties?["DelayTime" as CFString] as? TimeInterval {
            duration = delay
        }
        else {
            duration = 0.0
        }

        // WebKit don't allow frame duration faster than 10ms. We are taking it same but it can be mutated as per need
        if config.shoulClipFrameRate {
            return duration < 0.011 ? 0.01 : duration
        } else {
            return duration
        }
        
    }
    
    
    func getImage(at index: Int,_ config:GifConfig) -> CGImage? {
        
        if config.downsample && config.frameSize != CGSize.zero {
            // Calculate the desired dimension
            let maxDimensionInPixels = max(config.frameSize.width, config.frameSize.height) * config.scale
            
            // Perform downsampling
            let downsampleOptions = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceShouldCacheImmediately: true, //This flag indicates that the core graphic framework should decode the image at the exact moment we start the downsampling process.
                kCGImageSourceCreateThumbnailWithTransform: true, //Setting this flag to true is very important as it lets the core graphic framework know that you want the downsampled image to have the same orientation as the original image.
                kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
            ] as CFDictionary
            
            return CGImageSourceCreateThumbnailAtIndex(self, index, downsampleOptions)
        }
        else {
            return CGImageSourceCreateImageAtIndex(self, index, config.imageSourceOptions())
        }
    }
    
}



fileprivate extension CGImageSource {
    static func imageProperties(from properties: [CFString: Any]) -> [CFString: Any]? {
        if let gifProperties = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any] {
            return gifProperties
        }

        if let pngProperties = properties[kCGImagePropertyPNGDictionary] as? [CFString: Any] {
            return pngProperties
        }

        if #available(iOS 13.0, *) {
            if let heicsProperties = properties[kCGImagePropertyHEICSDictionary] as? [CFString: Any] {
                return heicsProperties
            }
        }

        return nil
    }
    
    ///HEIC is the file format name Apple has chosen for the new HEIF (High Efficiency Image Format) Standard.
    ///Using advanced and modern compression methods, it allows photos to be created in smaller file sizes while retaining a higher image quality compared to JPEG/JPG.
    static func animationHEICSProperties(from properties: [CFString: Any], at index: Int) -> [CFString: Any]? {
            if #available(iOS 13.0, *) {
                guard let heicsProperties = properties[kCGImagePropertyHEICSDictionary] as? [CFString: Any] else {
                    return nil
                }

                guard let array = heicsProperties["FrameInfo" as CFString] as? [[CFString: Any]], array.count > index else {
                    return nil
                }

                return array[index]
            }

            return nil
        }
}
