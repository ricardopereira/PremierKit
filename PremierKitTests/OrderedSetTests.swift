//
//  OrderedSetTests.swift
//  PremierKitTests
//
//  Created by Ricardo Pereira on 07/05/2020.
//  Copyright © 2020 Ricardo Pereira. All rights reserved.
//

import XCTest
@testable import PremierKit

class OrderedSetTests: XCTestCase {

    func testBasics() {
        // Create an empty set.
        var set = OrderedSet<String>()
        XCTAssertTrue(set.isEmpty)
        XCTAssertEqual(set.contents, [])

        // Create a new set with some strings.
        set = OrderedSet(["one", "two", "three"])
        XCTAssertFalse(set.isEmpty)
        XCTAssertEqual(set.count, 3)
        XCTAssertEqual(set[0], "one")
        XCTAssertEqual(set[1], "two")
        XCTAssertEqual(set[2], "three")
        XCTAssertEqual(set.contents, ["one", "two", "three"])

        // Try adding the same item again - the set should be unchanged.
        XCTAssertEqual(set.append("two"), false)
        XCTAssertEqual(set.count, 3)
        XCTAssertEqual(set[0], "one")
        XCTAssertEqual(set[1], "two")
        XCTAssertEqual(set[2], "three")

        // Remove the last element.
        let three = set.removeLast()
        XCTAssertEqual(set.count, 2)
        XCTAssertEqual(set[0], "one")
        XCTAssertEqual(set[1], "two")
        XCTAssertEqual(three, "three")

        // Remove all the objects.
        set.removeAll(keepingCapacity: true)
        XCTAssertEqual(set.count, 0)
        XCTAssertTrue(set.isEmpty)
        XCTAssertEqual(set.contents, [])

        set.append("Hello")
        XCTAssertEqual(set.remove("Hello"), "Hello")
        XCTAssertEqual(set.remove("Hello"), nil)
        XCTAssertEqual(set.remove("cool"), nil)
    }

    func testEqualToSet() {
        let items: [String] = ["Cooler", "hello"]
        let orderedSet1 = OrderedSet<String>(items)
        let set1 = Set<String>(items)
        let set2 = Set<String>(items.map({$0.lowercased()}))
        let set3 = Set<String>(["1", "2", "3"])
        XCTAssertTrue(orderedSet1 == set1)
        XCTAssertTrue(set1 == orderedSet1)
        XCTAssertFalse(orderedSet1 == set2)
        XCTAssertFalse(set2 == orderedSet1)
        XCTAssertFalse(orderedSet1 == set3)
        XCTAssertFalse(set3 == orderedSet1)

        let emptyOrderedSet = OrderedSet<String>()
        let emptySet = Set<String>()
        XCTAssertTrue(emptyOrderedSet == emptySet)
        XCTAssertTrue(emptySet == emptyOrderedSet)

        XCTAssertFalse(emptyOrderedSet == set1)
        XCTAssertFalse(set1 == emptyOrderedSet)
    }

}
