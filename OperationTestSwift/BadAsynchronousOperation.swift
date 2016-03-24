//
//  BadAsynchronousOperation.swift
//  OperationTestSwift
//
//  Created by Robert Ryan on 9/22/14.
//  Copyright (c) 2014 Robert Ryan. All rights reserved.
//

import UIKit

/// Incorrect implementation of NSOperation subclass that does not post the
/// appropriate "isFinished" and "isExecuting" notifications.
///
/// It doesn't matter if this posts "executing" and/or "finished", or posts nothing:
/// Because it fails to post "isFinished" and "isExecuting", this will fail to
/// recognize that the operation finished. Thus, if you use dependencies or
/// if you are relying up "maxConcurrentOperationCount", this will not 
/// work properly.
///
/// Note, this failure only manifests itself if (a) this is an asynchronous
/// operation; and (b) that it actually only completes asynchronously.
///
/// Please compare this to GoodAsynchronousOperation

class BadAsynchronousOperation: NSOperation {
   
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
            willChangeValueForKey("executing")
            
            stateLock.withCriticalScope {
                if _executing != newValue {
                    _executing = newValue
                }
            }
            
            didChangeValueForKey("executing")
        }
    }

    private var _finished: Bool = false
    override private(set) var finished: Bool {
        get {
            return stateLock.withCriticalScope { _finished }
        }
        set {
            willChangeValueForKey("finished")
            
            stateLock.withCriticalScope {
                if _finished != newValue {
                    _finished = newValue
                }
            }
            
            didChangeValueForKey("finished")
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
