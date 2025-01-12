//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialApp
//
//  Created by Kouv on 09/01/2025.
//
import XCTest
import EssentialFeed
import EssentialApp

final class FeedLoaderCacheDecoratorTests:XCTestCase, FeedLoaderTestCase {
    
    func test_load_deliversSuccessOnRemoteSuccess() {
        let feed = uniqueFeed()
        let (sut,_) = makeSUT(remoteLoaderResult: .success(feed))
        expect(sut, toCompeleteWith: .success(feed))
    }
    
    func test_load_deliversFailureOnRemoteFailure() {
        let (sut,_) = makeSUT(remoteLoaderResult: .failure(anyNSError()))
        expect(sut, toCompeleteWith: .failure(anyNSError()))
    }
    
    func test_load_cachesFeedOnLoaderSuccess() {
        let cache = CacheSpy()
        let feed = uniqueFeed()
        let (sut,_) = makeSUT(remoteLoaderResult: .success(feed),cache:cache)
        
        sut.load{_ in }
        XCTAssertEqual(cache.messages, [.save(feed)],"Expected cache to have received save cache on successful load")

    }
    
    func test_load_doesNotCacheFeedOnLoaderFailure() {
        let cache = CacheSpy()
        let (sut,_) = makeSUT(remoteLoaderResult: .failure(anyNSError()),cache:cache)
        
        sut.load{_ in }
        
        XCTAssertTrue(cache.messages.isEmpty,"Expected no cache message  on load failure")

    }
    
    //MARK: - Helpers
    private func makeSUT(remoteLoaderResult:FeedLoader.Result,cache:CacheSpy = .init(), file: StaticString = #filePath,
                         line: UInt = #line) -> (sut:FeedLoaderCacheDecorator,remoteLoader:FeedLoader) {
        
        let remoteLoader  = FeedLoaderStub(result: remoteLoaderResult)
        let sut = FeedLoaderCacheDecorator(decoratee: remoteLoader,cache:cache)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(remoteLoader, file: file, line: line)
        return (sut,remoteLoader)
    }
    
    private class CacheSpy:FeedCache {
        private(set) var messages = [Message]()
        
        enum Message:Equatable {
            case save([FeedImage])
        }
        
        func save(_ feed: [FeedImage], completion: @escaping (FeedCache.Result) -> Void) {
            messages.append(.save(feed))
            completion(.success(()))
        }
    }
    
}
