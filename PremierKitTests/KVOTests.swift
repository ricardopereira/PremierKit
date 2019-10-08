//
//  KVOTests.swift
//  PremierKitTests
//
//  Created by Ricardo Pereira on 08/10/2019.
//  Copyright © 2019 Ricardo Pereira. All rights reserved.
//

import XCTest
@testable import PremierKit

class KVOTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testNewKey() {
        let op1 = Operation()
        var cancelled = false
        let kvoToken = op1.addObserver(for: \.isCancelled, options:[.new]) { object, change in
            cancelled = change.newValue ?? false
            XCTAssertEqual(change.kind, .setting)
            XCTAssertEqual(change.newValue, true)
            XCTAssertNil(change.oldValue)
            XCTAssertNil(change.indexes)
            XCTAssertEqual(change.isPrior, false)
        }
        op1.cancel()
        kvoToken.invalidate()
        XCTAssertTrue(cancelled)
    }

    func testNewAndOldKey() {
        let op1 = Operation()
        var cancelled = false
        let kvoToken = op1.addObserver(for: \.isCancelled, options:[.new, .old]) { object, change in
            cancelled = true
            XCTAssertEqual(change.kind, .setting)
            XCTAssertEqual(change.newValue, true)
            XCTAssertEqual(change.oldValue, false)
            XCTAssertNil(change.indexes)
            XCTAssertEqual(change.isPrior, false)
        }
        op1.cancel()
        kvoToken.invalidate()
        XCTAssertTrue(cancelled)
    }

    func testInvalidate() {
        let op1 = Operation()
        var cancelled = false
        let kvoToken = op1.addObserver(for: \.isCancelled, options:[.new]) { object, change in
            cancelled = true
        }
        kvoToken.invalidate()
        op1.cancel()
        XCTAssertFalse(cancelled)
    }

}
