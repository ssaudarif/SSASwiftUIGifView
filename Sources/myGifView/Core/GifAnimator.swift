//
//  ImagesProvider.swift
//  
//
//  Created by Syed Saud Arif on 08/01/22.
//

import Foundation
//import UIKit
import SwiftUI

protocol GifAnimatorDelegate: AnyObject {
    func eventOccured(frame:Int, timestamp:CFTimeInterval, targetTimestamp:CFTimeInterval, duration:CFTimeInterval)
    func getFrameDuration(_ index:Int) -> CFTimeInterval
    func getNumberOfFrames() -> Int
    func constructImage(_ frame:Int)
    func isImageConstructed(_ frame:Int) -> Bool
    func queueForDisplayImage(_ frame:Int)
    func displayImage(_ frame:Int)
}

class GifAnimator {
    
    let displayLinkWrapper = GifAnimatorDisplayLink()
    let displaylink:CADisplayLink
    weak var animationDelegate:GifAnimatorDelegate?
    private var frame:Int = -1
    var nextDuration: CFTimeInterval = minDuration
//    static let maxFrameRate:Int = 60
    static let minDuration:CFTimeInterval = 0.016666667
//    static let halfOfMinDuration:CFTimeInterval = 0.008333335
//    static let twiceMinDuration:CFTimeInterval = 0.033333333
//    static let exactTimeCalculations = true
    
//    private var _maxFrameRate: CFTimeInterval = 0
//    private var maxFrameRate: CFTimeInterval {
//        if _maxFrameRate == 0 {
//            #if os
//            _maxFrameRate = CFTimeInterval( displaylink.maximumFramesPerSecond.maximum )
//        }
//        return _maxFrameRate
//    }
    
    private var _numberOfFrames: Int = 0
    private var getNumberOfFrames: Int {
        if _numberOfFrames == 0 {
            _numberOfFrames = animationDelegate?.getNumberOfFrames() ?? 0
        }
        return _numberOfFrames
    }

    
    init(delegate : GifAnimatorDelegate) {
        animationDelegate = delegate
        displaylink = CADisplayLink(
            target: displayLinkWrapper,
            selector: #selector(GifAnimatorDisplayLink.renderFrame(displaylink:))
        )
        displayLinkWrapper.eventBlock = getAnimatingBlock()
    }

    ///Play will  construct the imageSource again.
    ///and starts the animation.
    func play() {
        setUpFrameStart()
        startAnimation()
    }
    
    private func startAnimation() {
        displaylink.add(to: .main, forMode: .default)
    }
    
    private func setUpFrameStart() {
        displaylink.preferredFramesPerSecond = 0
        frame = 0
    }
    
    private func setupForNextFrameFire() {
        guard let d = animationDelegate else { return }
        frame = frame + 1
        let n = getNumberOfFrames
        if frame >= n {
            frame = 0
        }
        self.nextDuration += d.getFrameDuration(frame)
//        if !GifAnimator.exactTimeCalculations {
//            let duration = self.nextDuration
//            if duration > 0.0 {
//                var fps = Int(1/duration)
//                if fps > 20 { fps = 20 }
//                else if fps < 2 { fps = 2 }
//                displaylink.preferredFramesPerSecond = fps
//            }
//        }
    }
    
    ///Pause will completely remove all the data.
    ///and stops the animation.
    func pause() {
        stopAnimation()
    }
    
    private func stopAnimation() {
        displaylink.isPaused = true
        displaylink.invalidate()
    }
    
    
    func getAnimatingBlock() -> ((CFTimeInterval, CFTimeInterval, CFTimeInterval) -> Void) {
        return { [weak self] (timestamp, targetTimestamp, duration) in
            if let kSelf = self {
                kSelf.nextDuration = kSelf.nextDuration - targetTimestamp + timestamp
                
                if kSelf.nextDuration > 0 {
                    return
                }
//                else if !GifAnimator.exactTimeCalculations && kSelf.nextDuration + GifAnimator.twiceMinDuration > 0 {
//                    return
//                }
//                print("Will Trigger SetupFor new frame")

                if (kSelf.animationDelegate?.isImageConstructed(kSelf.frame) ?? false) == false {
                    kSelf.animationDelegate?.constructImage(kSelf.frame)
                    
                }
//                else {
//                    kSelf.animationDelegate?.displayImage(kSelf.frame)
//                }
                kSelf.animationDelegate?.queueForDisplayImage(kSelf.frame)
                kSelf.animationDelegate?.eventOccured(frame:kSelf.frame, timestamp:timestamp, targetTimestamp:targetTimestamp, duration:duration)
                kSelf.setupForNextFrameFire()
            }
        }
    }
}


class GifAnimatorDisplayLink {
    
    var eventBlock:((CFTimeInterval, CFTimeInterval, CFTimeInterval) -> Void)?
    
    
    @objc func renderFrame(displaylink: CADisplayLink) {
        eventBlock?(displaylink.timestamp, displaylink.targetTimestamp, displaylink.duration)
    }
    
}
