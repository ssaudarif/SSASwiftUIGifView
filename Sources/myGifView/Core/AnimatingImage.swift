//
//  AnimatingImage.swift
//  
//
//  Created by Syed Saud Arif on 18/01/22.
//

import SwiftUI
import ImageIO
import SwiftDisplayLink


//We are done with the SwiftDisplayLink work now it's time to integrate the swiftdiaplylinklibraray to the gif library.


/// The `AnimatingImage` is a ObservableObject that has only one
/// published property `image` of `UIImage` type.
@MainActor
class AnimatingImage: ObservableObject {
    
    /// Change this if you want to update the image.
    @Published var image:GIfImage = GIfImage()
    
    /// Needs to read image.
    var imageReader:GifReader? = nil
    var displaylink:SwiftDisplayLink? = nil
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

        images.cleanUp()
        queue.cleanUp()
        image = GIfImage()
    }
    
    deinit {
    }
    
    func getFirstFrame() -> GIfImage {
        if let i = imageReader?.getFirstFrame() {
            return GIfImage(cgImage: i)
        }
        else { return GIfImage() }
    }
}


extension AnimatingImage : GifReaderDelegate {
    func imageConstructed(_ cgImg: CGImage?, for frame: Int) {
        images.addImageOnIndex(cgImg, frame)
    }
    
    func isReadingCompleted() {
        //should start the GifAnimator
        guard let reader = imageReader else { return }
        displaylink = SwiftDisplayLink(frameCount: reader.getNumberOfFrames(), repeatFrames: true, { [weak self] frame in
            let isImageConstructed = self?.isImageConstructed(frame) ?? false
            return SwiftDisplayLinkFrameData(duration: reader.getFrameDuration(frame), isFrameConstructed: isImageConstructed)
        })
        displaylink?.play({ [weak self] event, frame in
            switch (event) {
            case .constructFrame:
                self?.imageReader?.constructImageFor(frame)
            case .performAction(let currTime, let duration):
                self?.eventOccured(frame: frame, timestamp: currTime, targetTimestamp: currTime, duration: duration)
            }
        })
//        animator = GifAnimator(delegate: self)
//        animator?.play()
    }
}


extension AnimatingImage {//: GifAnimatorDelegate {
    func queueForDisplayImage(_ frame: Int) {
        queue.addFrameToQueue(frame)
    }
    
    func displayImage(_ frame: Int) {
        imageReader?.queue.sync {
            if let i = images.getImageFor(frame) {
                Task {
                    await MainActor.run {
                        image = GIfImage(cgImage: i)
                    }
                }
                imageReader?.queue.async(flags: .barrier) { [weak self] in
                    self?.images.removeFromCache(frame)
                }
            }
        }
    }
    
    func eventOccured(frame:Int, timestamp:CFTimeInterval, targetTimestamp:CFTimeInterval, duration:CFTimeInterval) {
//        let index = queue.getFirst()
//        print("\(index),  -- \(queue)")
        if images.isFrameCached(frame) {
//            queue.removeFirst()
            displayImage(frame)
        }
    }
    
//    func getFrameDuration(_ index:Int) -> CFTimeInterval {
//        return imageReader?.getFrameDuration(index) ?? 0.0
//    }
    
//    func getNumberOfFrames() -> Int {
//        return imageReader?.getNumberOfFrames() ?? 0
//    }
    
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

extension Image {
    init(gifImage: GIfImage) {
        #if os(iOS)
        let uiImage = gifImage.image
        self.init(uiImage: uiImage)
        #else
        let nsImage = gifImage.image
        self.init(nsImage: nsImage)
        #endif
    }
}
