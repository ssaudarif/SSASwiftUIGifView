//
//  GifReader.swift
//  
//
//  Created by Syed Saud Arif on 08/01/22.
//

import Foundation
import ImageIO
//import UIKit
import SwiftUI

/// This protocol will act as a delegate instance to transfer callbacks when GirReader wants too.
protocol GifReaderDelegate: AnyObject {
    
    func isReadingCompleted()
    func imageConstructed(_ cgImg:CGImage?, for frame:Int)
}

/// The `GifReader` struct will help you read the Gif file.
struct GifReader {
    /// The error will keep all the errors stored.
    /// TODO: Need to check how the error is getting reported.
    public var error:String? = nil
    private var imgSource:CGImageSource = CGImageSourceCreateIncremental(nil)
    private let gifFileWrapper:GifWrapper
    var config:GifConfig
    weak var readerDelgate:GifReaderDelegate?
    let queue = DispatchQueue(label: "GifReaderQueue", attributes: .concurrent)
    
    /// Constructor for `GifReader`.
    ///
    /// Note : This will not automatically starts the reading. We need to call the `start()` function.
    ///
    /// - parameter source: The `GifWrapper` object to get the gif file source.
    /// - parameter delegate: The `GifReaderDelegate` object that will get notified during the data reading process.
    /// - parameter config: The `GifConfig` is the config object that can have some flag to alter the reading process.
    init(_ source:GifWrapper, delegate:GifReaderDelegate, config c: GifConfig) {
        readerDelgate = delegate
        gifFileWrapper = source
        config = c
        
        //print("init reader")
    }

    
    /// start will  construct the imageSource again
    /// and starts the animation.
    /// - parameter shouldStartAnimation: pass false in `shouldStartAnimation`.
    ///         if you do not want the delegate object to start the animation.
    ///
    mutating func start(_ shouldStartAnimation: Bool = true) {
        // will create the imagsource.
        read(self.gifFileWrapper)
        
        if shouldStartAnimation {
            guard let delegate = readerDelgate else { return }
            DispatchQueue.main.async {
                delegate.isReadingCompleted()
            }
        }
    }
    
    /// Pause will completely remove all the data.
    /// and stops the animation.
    mutating func stop() {
        distroySource()
    }
    
    /// This is a different function. Call this function when you do not want to start the animation but just get a first image.
    /// Helps in showing the thumbnail etc.
    mutating func getFirstFrame() -> CGImage? {
        start(false)
        defer {
            stop()
        }
        
        return imgSource.getImage(at: 0, config)
    }
    
    mutating func changeConfig(_ new:GifConfig) {
        self.config = new
    }
}

extension GifReader {
    func getFrameDuration(_ index:Int) -> CFTimeInterval {
        return (imgSource.frameDuration(at: index, config) ?? 0.0) as CFTimeInterval
    }
    
    func getNumberOfFrames() -> Int {
        return imgSource.frameCount
    }
    
    func constructImageFor(_ frame:Int) {
        self.queue.async {
            self.readerDelgate?.imageConstructed(self.imgSource.getImage(at: frame, config), for: frame)
        }
    }
}

extension GifReader {
    /// Main function to call to start the reading.
    /// Here the source is GifWrapper that means that is not exactly gif File
    private mutating func read(_ source:GifWrapper) {
        /// Calling getImageData() on GifWrapper will provide a data or error.
        switch (source.getImageData()) {
        case .success(let data):
            startReading(data)
        case .failure(let err):
            self.error = err.localizedDescription
        }
    }
    
    /// This will be called from read function.
    /// This is the first time image source is getting created.
    mutating func startReading(_ data:Data) {
        let cfDic = [:] as CFDictionary
        //CGAnimateImageDataWithBlock(data as CFData, cfDic, self.blockToAnimatePictures)
        guard let s = CGImageSourceCreateWithData(data as CFData, cfDic) else { //TODO: config to pass
            error = "Not a valid image file."
            return
        }
        self.imgSource = s
    }
    
    ///This function will destroy image source reference.
    mutating private func distroySource() {
        self.imgSource = CGImageSourceCreateIncremental(nil)
        error = nil
    }
}

extension GifReader {
    
    static func getDataFrom(_ file:URL) -> Result<Data, Error> {
        do {
            let data = try Data(contentsOf: file)
            return .success(data)
        } catch {
            return .failure(error)
        }
    }
    
}
