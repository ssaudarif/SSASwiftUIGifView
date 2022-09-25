import XCTest
@testable import SSASwiftUIGifView

final class GifAnimatorTests: XCTestCase {
    
    var frames: Int = 0
    var durations: [CFTimeInterval] = [CFTimeInterval]()
    var isImageConstructed: [Bool] = [Bool]()
    var constructImageCalllback: (Int) -> Void = {(_) in }
    var queueForDisplayImageCalllback: (Int) -> Void = {(_) in }
    var eventOccuredCallback: (Int, CFTimeInterval, CFTimeInterval, CFTimeInterval) -> Void = {(_,_,_,_) in }
    
    override func tearDownWithError() throws {
        frames = 0
        durations = [CFTimeInterval]()
        isImageConstructed = [Bool]()
        constructImageCalllback = {(_) in }
        queueForDisplayImageCalllback = {(_) in }
        eventOccuredCallback = {(_,_,_,_) in }
    }
    
    func testTimerWithImageConstructed() throws {
        let expectation = expectation(description: "Loading stories")
        frames = 1
        durations = [1.0]
        isImageConstructed = [true]
        var isQueueForDisplayImageCalled = false
        constructImageCalllback = {(index) in
            XCTAssert(!(self.isImageConstructed[index]),
                      "The constructImage function should not be called if the image is already constructed.")
        }
        queueForDisplayImageCalllback = {(index) in
            isQueueForDisplayImageCalled = true
        }
        eventOccuredCallback = {(frame, timestamp, targetTimestamp, duration) in
            expectation.fulfill()
        }
        let animator = GifAnimator(delegate: self)
        animator.play()
        waitForExpectations(timeout: 3.0)
        XCTAssert(isQueueForDisplayImageCalled, "The queueForDisplayImage function should be called")
        animator.pause()
    }
    
    func testTimerWithImageNotConstructed() throws {
        let expectation = expectation(description: "Loading stories")
        frames = 1
        durations = [1.0]
        isImageConstructed = [false] //image is not constructed.
        //constructImageCalllback should get called.
        var isQueueForDisplayImageCalled = false
        constructImageCalllback = {(index) in
            XCTAssert(!(self.isImageConstructed[index]),
                      "The constructImage function should not be called if the image is already constructed.")
        }
        queueForDisplayImageCalllback = {(index) in
            isQueueForDisplayImageCalled = true
        }
        eventOccuredCallback = {(frame, timestamp, targetTimestamp, duration) in
            expectation.fulfill()
        }
        let animator = GifAnimator(delegate: self)
        animator.play()
        waitForExpectations(timeout: 3.0)
        XCTAssert(isQueueForDisplayImageCalled, "The queueForDisplayImage function should be called")
        animator.pause()
    }
    
    func testTimerOnDurations() throws {
        let expectation = expectation(description: "Loading stories")
        frames = 6
        durations = [CFTimeInterval](repeating: 0.5, count: frames)
        isImageConstructed = [Bool](repeating: false, count: frames) //image is not constructed.
        let start = DispatchTime.now() // <<<<<<<<<< Start time
        eventOccuredCallback = {(frame, timestamp, targetTimestamp, duration) in
            if frame == 5 {
                expectation.fulfill()
            }
        }
        let animator = GifAnimator(delegate: self)
        animator.play()
        waitForExpectations(timeout: 3.0)
        let end = DispatchTime.now()   // <<<<<<<<<<   end time
        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
        let timeInterval = Double(nanoTime) / 1_000_000_000 // Technically could overflow for long running tests
        
        /// The timeInterval should be ` 2.5 seconds + time taken for the 0th frame call`.
        /// Basically the logic is ..
        /// Once you call `animator.play()` the 0th frame gets called
        /// After that 0-1 , 1-2 , 2-3 , 3-4 , 4-5 will take 0.5 seconds each.
        /// So all of this will cause the time to be elapsed as `2.5 seconds + time taken for the 0th frame call`.
        
        let isValid = timeInterval > 2.5 && timeInterval < 2.6

        XCTAssert(isValid, "The Duration should have been between 2.5 and 2.6 but it is \(timeInterval)")
        animator.pause()
    }
    
//    func testTimerOnDurations() throws {
//        let expectation = expectation(description: "Loading stories")
//        frames = 6
//        durations = [CFTimeInterval](repeating: 0.5, count: frames)
//        isImageConstructed = [Bool](repeating: false, count: frames) //image is not constructed.
//        let start = DispatchTime.now() // <<<<<<<<<< Start time
//        eventOccuredCallback = {(frame, timestamp, targetTimestamp, duration) in
//            if frame == 5 {
//                expectation.fulfill()
//            }
//        }
//        let animator = GifAnimator(delegate: self)
//        animator.play()
//        waitForExpectations(timeout: 3.0)
//        let end = DispatchTime.now()   // <<<<<<<<<<   end time
//        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
//        let timeInterval = Double(nanoTime) / 1_000_000_000 // Technically could overflow for long running tests
//        
//        /// The timeInterval should be ` 2.5 seconds + time taken for the 0th frame call`.
//        /// Basically the logic is ..
//        /// Once you call `animator.play()` the 0th frame gets called
//        /// After that 0-1 , 1-2 , 2-3 , 3-4 , 4-5 will take 0.5 seconds each.
//        /// So all of this will cause the time to be elapsed as `2.5 seconds + time taken for the 0th frame call`.
//        
//        let isValid = timeInterval > 2.5 && timeInterval < 2.6
//
//        XCTAssert(isValid, "The Duration should have been between 2.5 and 2.6 but it is \(timeInterval)")
//        animator.pause()
//    }
    
    
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
    
    
}
