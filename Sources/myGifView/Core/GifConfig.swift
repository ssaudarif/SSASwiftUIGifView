//
//  GifConfig.swift
//  
//
//  Created by Syed Saud Arif on 16/01/22.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

import ImageIO

public enum GifScale{
    ///Will not casue any blurring.
    case screen
    ///Will have no scale.
    case none
    ///Custom scale. Will accept values as 2.0, 3.0, 0.5 etc.
    case custom(value: CGFloat)
}

public struct GifConfig {
    /// Whether the image should be cached in a decoded form.
    /// If enabled, it will increase memory usage and performance.
    /// In another words, when this flag is set to false,
    ///  we let the core graphic framework know that we only need to create a reference to the image source
    ///  and do not want to decode the image immediately when the CGImageSource object is being created.
    let shouldCache:Bool //= false
    
    /// Should we allow framerate less than 10ms ?
    /// webKit does not allow it to be less than 10ms.
    /// If disabled, it will allow framerates less than 10ms.
    let shoulClipFrameRate:Bool //= true
    
    /// Should we downsample the image ?
    /// Use this property if you want to show a big sized image into a smaller area.
    /// If size is not zero, it will downsample the image to the provided size.
    let downsample:Bool //= false
    
    /// The downsampling scale factor.
    let downsamplingScale:GifScale
    
    //Not able to cnfigure.
    //View based configs for intenal use.
    
    /// If size is not zero, it will downsample the image to the provided size.
    internal var frameSize:CGSize = CGSize.zero
    
    /// The downsampling scale factor.
    /// Usually, this will be the scale factor associated with the screen (we usually refer to it as @2x or @3x).
    /// That’s why you can see that its default value has been set to UIScreen.main.scale.
    /// This will not be used if downsample = false.
    internal var scale: CGFloat {
        switch downsamplingScale {
        case .screen:
#if os(iOS)
            return UIScreen.main.scale
#elseif os(macOS)
            return NSScreen.main?.backingScaleFactor ?? 2.0
#endif
        case .none:
            return CGFloat(1.0)
        case .custom(let value):
            return value
        }
    }
    
    /// Default config should be good for majority of use cases.
    public static var defaultConfig:GifConfig {
        return GifConfig(shouldCache:false,
                         shoulClipFrameRate:true,
                         downsample: false,
                         downsamplingScale: GifScale.screen)
    }
    
    public static var downsampleConfig:GifConfig {
        return GifConfig(shouldCache:false,
                         shoulClipFrameRate:true,
                         downsample: true,
                         downsamplingScale: GifScale.screen)
    }
    
    public static var downsampleNoScaleConfig:GifConfig {
        return GifConfig(shouldCache:false,
                         shoulClipFrameRate:true,
                         downsample: true,
                         downsamplingScale: GifScale.none)
    }
    
    public init(shouldCache sc:Bool,
                shoulClipFrameRate scfr:Bool,
                downsample ds: Bool,
                downsamplingScale s:GifScale) {
        shouldCache = sc
        shoulClipFrameRate = scfr
        downsample = ds
        downsamplingScale = s
        
        print("init Config")
    }
    
    func imageSourceOptions() -> CFDictionary {
        return [kCGImageSourceShouldCache: self.shouldCache] as CFDictionary
    }
}
