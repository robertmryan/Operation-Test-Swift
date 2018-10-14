//
//  GoodAsynchronousOperation.swift
//  OperationTestSwift
//
//  Created by Robert Ryan on 9/22/14.
//  Copyright (c) 2014-2018 Robert Ryan. All rights reserved.
//

import UIKit

/// Correct implementation of "Operation" subclass that does post the
/// appropriate "isFinished" and "isExecuting" notification
///
/// Because this posts "isFinished" and "isExecuting", this will succeed in
/// recognizing that the operation finished. Thus, if you use dependencies or
/// if you are relying up "maxConcurrentOperationCount", this will
/// work properly.
///
/// Please compare this to BadAsynchronousOperation

class GoodAsynchronousOperation: Operation {

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
            willChangeValue(forKey: "isExecuting")
            
            stateLock.withCriticalScope {
                if _executing != newValue {
                    _executing = newValue
                }
            }

            didChangeValue(forKey: "isExecuting")
        }
    }

    private var _finished = false
    override var isFinished: Bool {
        get {
            return stateLock.withCriticalScope { _finished }
        }
        set {
            willChangeValue(forKey: "isFinished")
            
            stateLock.withCriticalScope {
                if _finished != newValue {
                    _finished = newValue
                }
            }
            
            didChangeValue(forKey: "isFinished")
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
