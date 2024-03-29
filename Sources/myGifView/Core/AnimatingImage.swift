//
//  AnimatingImage.swift
//  
//
//  Created by Syed Saud Arif on 18/01/22.
//

import SwiftUI
import ImageIO

/// The `AnimatingImage` is a ObservableObject that has only one
/// published property `image` of `UIImage` type.
class AnimatingImage: ObservableObject {
    
    /// Change this if you want to update the image.
    @Published var image:UIImage = UIImage()
    
    /// 
    var imageReader:GifReader? = nil
    var animator:GifAnimator? = nil
    var images:ImagesCache = ImagesCache()
    var queue:FrameQueue = FrameQueue()
    var config:GifConfig = GifConfig.defaultConfig
    
    func setNewConfig(_ c:GifConfig) {
        self.config = c
        self.imageReader?.config = c
    }
    
    func startReadingGif(_ source:GifWrapper) {
        imageReader = GifReader(source, delegate: self, config: config)
    }
    
    var isImageReadingStarted :Bool {
        return imageReader != nil
    }
    
    func play(){
        imageReader?.start() //will start the reading.
    }
    
    func pause(){
        imageReader?.stop()
        animator?.pause()
        images.cleanUp()
        queue.cleanUp()
        image = UIImage()
    }
    
    deinit {
    }
    
    func getFirstFrame() -> UIImage {
        if let i = imageReader?.getFirstFrame() {
            return UIImage(cgImage: i)
        }
        else { return UIImage() }
    }
}


extension AnimatingImage : GifReaderDelegate {
    func imageConstructed(_ cgImg: CGImage?, for frame: Int) {
        images.addImageOnIndex(cgImg, frame)
    }
    
    func isReadingCompleted() {
        //should start the GifAnimator
        animator = GifAnimator(delegate: self)
        animator?.play() 
    }
}


extension AnimatingImage : GifAnimatorDelegate {
    func queueForDisplayImage(_ frame: Int) {
        queue.addFrameToQueue(frame)
    }
    
    func displayImage(_ frame: Int) {
        imageReader?.queue.sync {
            if let i = images.getImageFor(frame) {
                image = UIImage(cgImage: i)
                imageReader?.queue.async(flags: .barrier) { [weak self] in
                    self?.images.removeFromCache(frame)
                }
            }
        }
    }
    
    func eventOccured(frame:Int, timestamp:CFTimeInterval, targetTimestamp:CFTimeInterval, duration:CFTimeInterval) {
        let index = queue.getFirst()
        //print("\(index),  -- \(queue)")
        if index > -1 && images.isFrameCached(index) {
            queue.removeFirst()
            displayImage(index)
        }
    }
    
    func getFrameDuration(_ index:Int) -> CFTimeInterval {
        return imageReader?.getFrameDuration(index) ?? 0.0
    }
    
    func getNumberOfFrames() -> Int {
        return imageReader?.getNumberOfFrames() ?? 0
    }
    
    func constructImage(_ frame:Int) {
        imageReader?.constructImageFor(frame)
    }
    
    func isImageConstructed(_ frame:Int) -> Bool {
        return images.isFrameCached(frame)
    }
}

//MARK: Remder a frame
extension AnimatingImage {
    
}
