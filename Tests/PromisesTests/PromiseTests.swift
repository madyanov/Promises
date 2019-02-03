//
//  PromiseTest.swift
//  Promises
//
//  Created by Roman Madyanov on 03/02/2019.
//

import XCTest
@testable import Promises

final class PromiseTests: XCTestCase {
    func testTransform() {
        let expect = expectation(description: "Waiting")
        var result: String?

        Promise<String> { completion in completion(.success("Hello")) }
            .then { return "\($0) World" }
            .then { result = $0 }
            .then { _ in expect.fulfill() }

        waitForExpectations(timeout: 1)
        XCTAssert(result == "Hello World")
    }

    static var allTests = [
        ("testTransform", testTransform),
    ]
}
