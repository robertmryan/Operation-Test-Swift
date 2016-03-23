//
//  GoodAsynchronousOperation.swift
//  OperationTestSwift
//
//  Created by Robert Ryan on 9/22/14.
//  Copyright (c) 2014 Robert Ryan. All rights reserved.
//

import UIKit

/// Correct implementation of "NSOperation" subclass that does post the
/// appropriate "isFinished" and "isExecuting" notification
///
/// Because this posts "isFinished" and "isExecuting", this will succeed in
/// recognizing that the operation finished. Thus, if you use dependencies or
/// if you are relying up "maxConcurrentOperationCount", this will
/// work properly.
///
/// Please compare this to BadAsynchronousOperation

class GoodAsynchronousOperation: NSOperation {

    var message: String
    var completion: () -> ()
    var duration: Double

    private let stateLock = NSLock()

    init(message: String, duration: Double, completion: () -> ()) {
        self.message    = message
        self.duration   = duration
        self.completion = completion
        super.init()
    }

    override var asynchronous: Bool {
        return true
    }

    private var _executing: Bool = false
    override private(set) var executing: Bool {
        get {
            return stateLock.withCriticalScope { _executing }
        }
        set {
            willChangeValueForKey("isExecuting")
            
            stateLock.withCriticalScope {
                if _executing != newValue {
                    _executing = newValue
                }
            }

            didChangeValueForKey("isExecuting")
        }
    }

    private var _finished: Bool = false;
    override private(set) var finished: Bool {
        get {
            return stateLock.withCriticalScope { _finished }
        }
        set {
            willChangeValueForKey("isFinished")
            
            stateLock.withCriticalScope {
                if _finished != newValue {
                    _finished = newValue
                }
            }
            
            didChangeValueForKey("isFinished")
        }
    }

    func completeOperation () {
        executing = false
        finished = true
    }

    override func start() {
        if cancelled {
            finished = true
            return
        }

        executing = true

        main()
    }
    
    override func main() {
        // start operation

        print("starting \(message)")

        // stop operation in two seconds

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(duration * Double(NSEC_PER_SEC))), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {

            print("finishing \(self.message)")  // report we're done

            self.completion()                     // call completion closure

            self.completeOperation()              // finish this operation
        }
        
        // but return immediately
    }
    
}
