import XCTest
@testable import SSASwiftUIGifView

final class GifAnimatorTests: XCTestCase {
    
    var frames: Int = 0
    var durations: [CFTimeInterval] = [CFTimeInterval]()
    var isImageConstructed: [Bool] = [Bool]()
    var constructImageCalllback: (Int) -> Void = {(_) in }
    var queueForDisplayImageCalllback: (Int) -> Void = {(_) in }
    var displayImageCalllback: (Int) -> Void = {(_) in }
    var eventOccuredCallback: (Int, CFTimeInterval, CFTimeInterval, CFTimeInterval) -> Void = {(_,_,_,_) in }
    
    func testExample() throws {
        let expectation = expectation(description: "Loading stories")
        frames = 1
        durations = [1.0]
        isImageConstructed = [true]
        constructImageCalllback = {(index) in
            print("constructImageCalllback for \(index)")
        }
        queueForDisplayImageCalllback = {(index) in
            print("queueForDisplayImageCalllback for \(index)")
        }
        displayImageCalllback = {(index) in
            print("displayImageCalllback for \(index)")
        }
        eventOccuredCallback = {(frame, timestamp, targetTimestamp, duration) in
            print("eventOccuredCallback for \(frame) \(timestamp) \(targetTimestamp) \(duration)")
            expectation.fulfill()
        }
        let animator = GifAnimator(delegate: self)
        animator.play()
        waitForExpectations(timeout: 3.0)
    }
}



extension GifAnimatorTests: GifAnimatorDelegate {
    
    func eventOccured(frame: Int, timestamp: CFTimeInterval, targetTimestamp: CFTimeInterval, duration: CFTimeInterval) {
        eventOccuredCallback(frame, timestamp, targetTimestamp, duration)
    }
    
    func getFrameDuration(_ index: Int) -> CFTimeInterval {
        return durations[index]
    }
    
    func getNumberOfFrames() -> Int {
        return frames
    }
    
    func constructImage(_ frame: Int) {
        constructImageCalllback(frame)
    }
    
    func isImageConstructed(_ frame: Int) -> Bool {
        return isImageConstructed[frame]
    }
    
    func queueForDisplayImage(_ frame: Int) {
        queueForDisplayImageCalllback(frame)
    }
    
    func displayImage(_ frame: Int) {
        displayImageCalllback(frame)
    }
    
    
}
