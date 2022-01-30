//
//  GifReader.swift
//  
//
//  Created by Syed Saud Arif on 08/01/22.
//

import Foundation
import ImageIO
import UIKit
import SwiftUI


protocol GifReaderDelegate: AnyObject {
    func isReadingCompleted()
    func imageConstructed(_ cgImg:CGImage?, for frame:Int)
}


struct GifReader {
    
    public var error:String? = nil
    private var imgSource:CGImageSource = CGImageSourceCreateIncremental(nil)
    private let fileURL:URL
    var config:GifConfig
    weak var readerDelgate:GifReaderDelegate?
    let queue = DispatchQueue(label: "GifReaderQueue", attributes: .concurrent)
    
    init(_ file:URL, delegate:GifReaderDelegate, config c: GifConfig) {
        readerDelgate = delegate
        fileURL = file
        config = c
        
        print("init reader")
    }

    
    ///Play will  construct the imageSource again.
    ///and starts the animation.
    mutating func start() {
        read(self.fileURL)
        readerDelgate?.isReadingCompleted()
    }
    
    ///Pause will completely remove all the data.
    ///and stops the animation.
    mutating func stop() {
        distroySource()
    }
    
    mutating func getFirstFrame() -> CGImage? {
        read(self.fileURL)
        defer {
            distroySource()
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
    ///Main function to call to start the reading.
    private mutating func read(_ fileURL:URL) {
        switch (GifReader.getDataFrom(fileURL)) {
        case .success(let data):
            startReading(data)
        case .failure(let err):
            self.error = err.localizedDescription
        }
    }
    
    ///This will be called from read function.
    mutating func startReading(_ data:Data) {
        let cfDic = [:] as CFDictionary
        //CGAnimateImageDataWithBlock(data as CFData, cfDic, self.blockToAnimatePictures)
        guard let s = CGImageSourceCreateWithData(data as CFData, cfDic) else { //TODO : config to pass
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
