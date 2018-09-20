//
//  PremierKitTests.swift
//  PremierKitTests
//
//  Created by Ricardo Pereira on 20/09/2018.
//  Copyright © 2018 Ricardo Pereira. All rights reserved.
//

import XCTest
@testable import PremierKit

class PremierKitTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDelay() {
        let expectation = self.expectation(description: "Delay")
        let start = Date()
        delay(3) {
            let end = Date()
            XCTAssertLessThan(end.timeIntervalSince(start), 3.1)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }

}
