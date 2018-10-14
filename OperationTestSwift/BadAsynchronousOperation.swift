//
//  BadAsynchronousOperation.swift
//  OperationTestSwift
//
//  Created by Robert Ryan on 9/22/14.
//  Copyright (c) 2014-2018 Robert Ryan. All rights reserved.
//

import UIKit

/// Incorrect implementation of Operation subclass that does not post the
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

class BadAsynchronousOperation: Operation {
   
    var message: String
    var completion: () -> ()
    var duration: Double

    private let stateLock = NSLock()

    init(message: String, duration: Double, completion: @escaping () -> ()) {
        self.message = message
        self.duration = duration
        self.completion = completion
        super.init()
    }

    override var isAsynchronous: Bool {
        return true
    }

    private var _executing = false
    override var isExecuting: Bool {
        get {
            return stateLock.withCriticalScope { _executing }
        }
        set {
            willChangeValue(forKey: "invalidExecuting")
            
            stateLock.withCriticalScope {
                if _executing != newValue {
                    _executing = newValue
                }
            }
            
            didChangeValue(forKey: "invalidExecuting")
        }
    }

    private var _finished = false
    override var isFinished: Bool {
        get {
            return stateLock.withCriticalScope { _finished }
        }
        set {
            willChangeValue(forKey: "invalidFinished")
            
            stateLock.withCriticalScope {
                if _finished != newValue {
                    _finished = newValue
                }
            }
            
            didChangeValue(forKey: "invalidFinished")
        }
    }

    func finish () {
        isExecuting = false
        isFinished = true
    }

    override func start() {
        if isCancelled {
            isFinished = true
            return
        }

        isExecuting = true

        main()
    }

    override func main() {
        // start operation
        execute()
        // but return immediately
    }
    
    func execute() {
        DispatchQueue.global().asyncAfter(deadline: .now() + duration) {
            print("finishing \(self.message)") // report we're done
            
            self.completion() // call completion closure
            self.finish() // finish this operation
        }
    }
    
}


