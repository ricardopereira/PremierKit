//
//  EventTests.swift
//  PremierKitTests
//
//  Created by Ricardo Pereira on 09/09/2019.
//  Copyright © 2019 Ricardo Pereira. All rights reserved.
//

import XCTest
@testable import PremierKit

enum FooEvent: String, Event {
    case foo1
    case foo2
}

class EventTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testEventEmitWithoutObject() {
        let fooEventObserverExpectation = XCTestExpectation(description: "addObserver")
        fooEventObserverExpectation.assertForOverFulfill = true
        fooEventObserverExpectation.expectedFulfillmentCount = 2
        let token1 = FooEvent.foo1.observe { (result: Bool?) in
            XCTAssertNil(result)
            fooEventObserverExpectation.fulfill()
        }
        XCTAssertNotNil(token1)
        let token2 = FooEvent.foo1.observe {
            fooEventObserverExpectation.fulfill()
        }
        XCTAssertNotNil(token2)
        let fooEventExpectation = XCTNSNotificationExpectation(name: Notification.Name(rawValue: FooEvent.foo1.rawValue), object: nil)
        FooEvent.foo1.emit()
        self.wait(for: [fooEventExpectation, fooEventObserverExpectation], timeout: 10)
    }

    func testEventEmitWithObject() {
        let expectedResult = "wow"
        let fooEventObserverExpectation = XCTestExpectation(description: "addObserver")
        fooEventObserverExpectation.assertForOverFulfill = true
        fooEventObserverExpectation.expectedFulfillmentCount = 2
        let token1 = FooEvent.foo1.observe { (result: String?) in
            XCTAssertEqual(result, expectedResult)
            fooEventObserverExpectation.fulfill()
        }
        XCTAssertNotNil(token1)
        let token2 = FooEvent.foo1.observe {
            fooEventObserverExpectation.fulfill()
        }
        XCTAssertNotNil(token2)
        let token3 = FooEvent.foo2.observe {
            XCTFail("Should not reach")
        }
        XCTAssertNotNil(token3)
        let fooEventExpectation = XCTNSNotificationExpectation(name: Notification.Name(rawValue: FooEvent.foo1.rawValue), object: expectedResult)
        FooEvent.foo1.emit(with: expectedResult)
        self.wait(for: [fooEventExpectation, fooEventObserverExpectation], timeout: 10)
    }

    func testEventTokenShouldRemoveObserver() {
        let fooEventObserverExpectation = XCTestExpectation(description: "addObserver")
        fooEventObserverExpectation.assertForOverFulfill = true
        fooEventObserverExpectation.expectedFulfillmentCount = 1
        var token1: EventToken? = FooEvent.foo1.observe {
            XCTFail("Should not reach")
        }
        XCTAssertNotNil(token1)
        let token2 = FooEvent.foo1.observe {
            fooEventObserverExpectation.fulfill()
        }
        XCTAssertNotNil(token2)
        token1 = nil
        FooEvent.foo1.emit()
        self.wait(for: [fooEventObserverExpectation], timeout: 10)
    }

}
