//
//  ImagesCache.swift
//  
//
//  Created by Syed Saud Arif on 22/01/22.
//

import Foundation
import UIKit

typealias ImagesCache = Dictionary<Int,CGImage>
private let _queueKey = malloc(4)

extension ImagesCache {
    
    mutating func addImageOnIndex(_ img:CGImage?, _ index:Int) {
        if let i = img {
            self[index] = i
        }
    }
    
    func isFrameCached(_ index:Int) -> Bool {
        return ( self[index] != nil )
    }
    
    func getImageFor(_ index:Int) -> CGImage? {
        return self[index]
    }
    
    mutating func removeFromCache(_ index:Int) {
        self.removeValue(forKey: index)        
    }
    
    mutating func cleanUp() {
        self.removeAll()
    }
    
}

typealias FrameQueue = Array<Int>

extension FrameQueue {
    mutating func addFrameToQueue(_ frame:Int) {
        self.append(frame)
    }
    
    mutating func deQueue() -> Int {
        if let k = self.first {
            self = FrameQueue(self.dropFirst())
            return k
        } else {
            return -1
        }
    }
    
    mutating func getFirst() -> Int {
        if let k = self.first {
            return k
        } else {
            return -1
        }
    }
    
    mutating func cleanUp() {
        self.removeAll()
    }
}
