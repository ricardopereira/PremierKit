//
//  OperationTests.swift
//  PremierKitTests
//
//  Created by Ricardo Pereira on 08/10/2019.
//  Copyright © 2019 Ricardo Pereira. All rights reserved.
//

import XCTest
@testable import PremierKit

class OperationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testAsyncOperation() {
        var started = false

        let op1 = AsyncBlockOperation(id: "foo") { operation in
            started = true
        }

        XCTAssertFalse(started)

        op1.start()

        XCTAssertTrue(started)
        XCTAssertFalse(op1.isFinished)
    }

    func testSetAsyncOperations() {
        var operations = Set<AsyncBlockOperation>()

        let op1 = AsyncBlockOperation(id: "foo") { operation in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                operation.finish()
            }
        }
        operations.insert(op1)

        let op2 = AsyncBlockOperation(id: "foo") { operation in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                operation.finish()
            }
        }
        operations.insert(op2)

        let op3 = AsyncBlockOperation(id: "abc") { operation in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                operation.finish()
            }
        }
        operations.remove(op3)

        XCTAssertTrue(operations.contains(where: { $0.id == "foo" }))
        XCTAssertTrue(operations.count == 2)
        XCTAssertTrue(op1 == op2)
    }

    func testAsyncOperationsCancellationEvent() {
        var cancelled = false

        let expectation = self.expectation(description: "Operation1")
        let op1 = AsyncBlockOperation(id: "foo") { operation in
            operation.onCancel = {
                cancelled = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                XCTAssertTrue(operation.isCancelled)
                operation.finish()
                expectation.fulfill()
            }
        }
        XCTAssertFalse(op1.isFinished)
        XCTAssertFalse(op1.isExecuting)
        op1.start()
        XCTAssertFalse(op1.isFinished)
        XCTAssertTrue(op1.isExecuting)
        op1.cancel()
        wait(for: [expectation], timeout: 10.0)

        XCTAssertNil(op1.onCancel)
        XCTAssertTrue(op1.isCancelled)
        XCTAssertTrue(cancelled)
        XCTAssertTrue(op1.isFinished)
        XCTAssertFalse(op1.isExecuting)
    }

}
