//
//  PromiseTest.swift
//  Promises
//
//  Created by Roman Madyanov on 03/02/2019.
//

import XCTest
@testable import Promises

final class PromiseTests: XCTestCase
{
    func testTransform() {
        let expect = expectation(description: "Waiting")

        var result: String?
        var catchCalled = false
        var finallyCalled = false

        Promise<String> { completion in completion(.success("Hello")) }
            .then { "\($0) World" }
            .then { result = $0 }
            .catch { _ in catchCalled = true }
            .finally {
                finallyCalled = true
                expect.fulfill()
            }

        waitForExpectations(timeout: 1)

        XCTAssertEqual(result, "Hello World")
        XCTAssertFalse(catchCalled)
        XCTAssertTrue(finallyCalled)
    }

    func testFinally() {
        let expect = expectation(description: "Waiting")

        var finallyCalled = false

        Single { _ in throw Error.error }
            .finally {
                finallyCalled = true
                expect.fulfill()
            }

        waitForExpectations(timeout: 1)

        XCTAssertTrue(finallyCalled)
    }

    func testFinallyWithCatch() {
        let expect = expectation(description: "Waiting")

        var catchCalled = false
        var finallyCalled = false

        Single { _ in throw Error.error }
            .catch { _ in catchCalled = true }
            .finally {
                finallyCalled = true
                expect.fulfill()
            }

        waitForExpectations(timeout: 1)

        XCTAssertTrue(catchCalled)
        XCTAssertTrue(finallyCalled)
    }
}

private enum Error: Swift.Error
{
    case error
}
