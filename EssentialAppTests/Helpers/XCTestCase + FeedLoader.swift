//
//  XCTestCase + FeedLoader.swift
//  EssentialApp
//
//  Created by Kouv on 09/01/2025.
//

import XCTest
import EssentialFeed

protocol FeedLoaderTestCase:XCTestCase {}

extension FeedLoaderTestCase {
    func expect(_ sut:FeedLoader,toCompeleteWith expectedResult:FeedLoader.Result,file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "wait for load")
        sut.load{receivedResult in
            switch (receivedResult,expectedResult) {
            case let (.success(receivedFeed),.success(expectedFeed)):
                XCTAssertEqual(receivedFeed,expectedFeed,file: file,line: line)
            case (.failure,.failure):
                break
            default:
                XCTFail("should have got \(expectedResult) but got response \(receivedResult) instead")
            }
        exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}
