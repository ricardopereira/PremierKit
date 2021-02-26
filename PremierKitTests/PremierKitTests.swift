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
        delay(1) {
            let end = Date()
            XCTAssertLessThan(end.timeIntervalSince(start), 1.1)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testCombineMutableDictionaries() {
        var data = ["John": 0]
        data += ["Maria": 0]
        data += ["Maria": 1]
        data += nil
        XCTAssertTrue(data == ["John": 0, "Maria": 1])
    }

    func testCombineImmutableDictionaries() {
        let d1 = ["John": 0]
        let d2 = d1 + ["Maria": 0] + ["Maria": 1]
        let d3 = d2 + nil
        XCTAssertTrue(d2 == ["John": 0, "Maria": 1])
        XCTAssertTrue(d2 == d3)
    }

    func testCollectionAt() {
        let a = [0]
        let d = ["John": 0]

        XCTAssertNotNil(a.at(0))
        XCTAssertNil(a.at(1))

        XCTAssertNotNil(d.at("John")?.value)
        XCTAssertNil(d.at("Maria")?.value)
        XCTAssertNil(d["Maria"])
        XCTAssertEqual(d["John"], d.at("John")?.value)
    }

    func testObfuscator() {
        let o = Obfuscator(with: "sçdiouf98asufio2niuaysdf9ahsdfl")
        let expectedResult = "john@apple.com"
        let bytes = o.bytesByObfuscatingString(string: expectedResult)
        XCTAssertEqual(o.reveal(key: bytes), expectedResult)
    }

    func testTrimmedText() {
        let str = "Fancy  text          "
        XCTAssertEqual(str.trimmed, "Fancy  text")
    }

    func testTruncatedText() {
        let str = "Fancy  text          "
        XCTAssertEqual(str.truncated(at: 40), "Fancy  text")
        XCTAssertEqual(str.truncated(at: 5), "Fancy")
        XCTAssertEqual(str.truncated(at: 0), "")
        XCTAssertEqual(str.truncated(at: -1), "")
    }

    func testTruncatedTextWithEllipsis() {
        let str = "Fancy text for this beautiful test"
        XCTAssertEqual(str.truncated(at: 40, suffix: "…"), str)
        XCTAssertEqual(str.truncated(at: 34, suffix: "…"), str)
        XCTAssertEqual(str.truncated(at: str.lengthOfBytes(using: .utf8), suffix: "…"), str)
        XCTAssertEqual(str.truncated(at: 5, suffix: "…"), "Fancy…")
    }

    func testIdentifiableHashable() {
        if #available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *) {
            struct Foo: IdentifiableHashable {
                var id: String
            }

            let foo1 = Foo(id: "A")
            let foo2 = Foo(id: "a")
            let foo3 = Foo(id: "A")
            let foo4 = Foo(id: "C")

            XCTAssertEqual(foo1, foo3)
            XCTAssertFalse(foo1 == foo4)
            XCTAssertFalse(foo1 == foo2)

            let set1 = Set<Foo>([foo1, foo2, foo3, foo4])
            XCTAssertEqual(set1.count, 3)
        }
    }

}
