//
//  XCTestCase+FeedImageDataLoader.swift
//  EssentialApp
//
//  Created by Kouv on 09/01/2025.
//
import XCTest
import EssentialFeed

protocol FeedImageDataLoaderTestCase:XCTestCase {}

extension FeedImageDataLoaderTestCase {
    
    func expect(_ sut:FeedImageLoader,toCompleteWith expectedResult:FeedImageLoader.Result,when action:()->Void, file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait to fetch image data")
        _ = sut.loadImageData(url: anyURL()) { receivedResult in
            switch (receivedResult,expectedResult) {
            case let (.success(receivedData),.success(expectedData)):
                XCTAssertEqual(receivedData, expectedData)
            case (.failure,.failure):
                break
            default:
                XCTFail("should have got \(expectedResult) but got response\(receivedResult) instead")
            }
            exp.fulfill()
            
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
}
