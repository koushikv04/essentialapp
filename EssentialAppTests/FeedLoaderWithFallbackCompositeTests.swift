//
//  RemoteWithLocalFallbackFeedLoaderTests.swift
//  EssentialApp
//
//  Created by Kouv on 08/01/2025.
//

import XCTest
import EssentialFeed
import EssentialApp


final class FeedLoaderWithFallbackCompositeTests:XCTestCase,FeedLoaderTestCase {
    
    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        let(primaryLoader,fallbackLoader) = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))
        let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        expect(sut, toCompeleteWith: .success(primaryFeed))

    }
    
    func test_load_deliversFallbackFeedOnPrimaryFailure() {
        let fallbackFeed = uniqueFeed()
        let(primaryLoader,fallbackLoader) = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(fallbackFeed))
        let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        expect(sut, toCompeleteWith: .success(fallbackFeed))
    }
    
    func test_load_deliversErrorOnPrimaryAndFeedbackLoaderFailure() {
        let(primaryLoader,fallbackLoader) = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .failure(anyNSError()))
        let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        expect(sut, toCompeleteWith: .failure(anyNSError()))
    }
    
    
    private class FeedLoaderStub:FeedLoader {
        private let result: FeedLoader.Result
        init(result:FeedLoader.Result) {
            self.result = result
        }
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
    }
    
    //MARK: - Helpers
    
    private func makeSUT(primaryResult:FeedLoader.Result,fallbackResult:FeedLoader.Result, file: StaticString = #filePath,
                         line: UInt = #line) -> (primary:FeedLoader,fallback:FeedLoader) {
        
        let primaryLoader  = FeedLoaderStub(result: primaryResult)
        let fallbackLoader = FeedLoaderStub(result: fallbackResult)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        return (primaryLoader,fallbackLoader)
    }
    
    
    
}
