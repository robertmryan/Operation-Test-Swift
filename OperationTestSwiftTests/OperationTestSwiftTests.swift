//
//  OperationTestSwiftTests.swift
//  OperationTestSwiftTests
//
//  Created by Robert Ryan on 9/22/14.
//  Copyright (c) 2014-2018 Robert Ryan. All rights reserved.
//

import UIKit
import XCTest

class OperationTestSwiftTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGoodOperation() {
        let expectation1 = expectation(description: "first expectation")
        let expectation2 = expectation(description: "second expectation")

        let queue = OperationQueue()

        let op1 = GoodAsynchronousOperation(message: "testGoodOperation first", duration: 2.0) {
            expectation1.fulfill()
        }

        let op2 = GoodAsynchronousOperation(message: "testGoodOperation second", duration: 2.0) {
            expectation2.fulfill()
        }

        op2.addDependency(op1)

        queue.addOperation(op1)
        queue.addOperation(op2)

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testBadOperation() {
        let expectation1 = expectation(description: "first expectation")
        let expectation2 = expectation(description: "second expectation")

        let queue = OperationQueue()

        let op1 = BadAsynchronousOperation(message: "testBadOperation first", duration: 2.0) {
            expectation1.fulfill()
        }

        // note, because `BadAsynchronousOperation` doesn't do the appropriate KVO,
        // this second operation will never fire, thus the second expectation will
        // never be fulfilled, and the `waitForExpectations` below will fail.

        let op2 = BadAsynchronousOperation(message: "testBadOperation second", duration: 2.0) {
            expectation2.fulfill()
        }

        op2.addDependency(op1)

        queue.addOperation(op1)
        queue.addOperation(op2)

        // let's wait five seconds for those two operations to complete and fulfill the two expectations
        
        waitForExpectations(timeout: 5.0, handler: nil)

        // Given this second operation would not have fired, we probably should cancel it when we clean up

        queue.cancelAllOperations()
    }
}
