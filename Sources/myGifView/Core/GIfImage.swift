//
//  GIfImage.swift
//  
//
//  Created by Syed Saud Arif on 18/09/22.
//

import Foundation
import SwiftUI
import ImageIO

class GIfImage {
    #if os(iOS)
    let image: UIImage
    #else
    let image: NSImage
    #endif
    
    
    init(cgImage: CGImage) {
        #if os(iOS)
        image = UIImage(cgImage: cgImage)
        #else
        image = NSImage(cgImage: cgImage, size: .zero)
        #endif
    }
    
    init() {
        #if os(iOS)
        image = UIImage()
        #else
        image = NSImage()
        #endif
    }
    
#if os(iOS)
    var size: CGSize {
        return image.size
    }
#else
    var size: NSSize {
        return image.size
    }
#endif
}
