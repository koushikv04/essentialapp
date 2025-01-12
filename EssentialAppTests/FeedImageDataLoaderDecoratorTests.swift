//
//  FeedImageDataLoaderDecoratorTests.swift
//  EssentialApp
//
//  Created by Kouv on 09/01/2025.
//
import XCTest
import EssentialFeed
import EssentialApp


final class FeedImageDataLoaderDecoratorTests:XCTestCase,FeedImageDataLoaderTestCase {
    
    func test_init_doesNotLoadImageData() {
        let (_,imageLoader) = makeSUT()

        XCTAssertTrue(imageLoader.requestedURLs.isEmpty, "Expected requestedurls to be empty")
    }
    
    func test_loadImageData_loadsFromLoader() {
        let (sut,imageLoader) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(url: url){_ in }
        
        XCTAssertEqual(imageLoader.requestedURLs, [url],"Expected loader to have received call from decorator")

    }
    
    
    func test_cancelLoadImageData_cancelLoaderTask() {
        let (sut,imageLoader) = makeSUT()
        let url = anyURL()

        let task = sut.loadImageData(url:url){ _ in }
        
        task.cancel()
        
        XCTAssertEqual(imageLoader.cancelledURLs, [url],"Expected one url in cancelledurls when task is cancelled")
    }
    
    func test_loadImageData_deliversDataOnLoaderSuccess() {
        let (sut,imageLoader) = makeSUT()
        let imageData = anyImageData()
        expect(sut, toCompleteWith: .success(imageData)) {
            imageLoader.completeWith(data: imageData)
        }
    }
    
    func test_loadImageData_deliversErrorOnLoaderFailure() {
        let (sut,imageLoader) = makeSUT()
        let error = anyNSError()
        expect(sut, toCompleteWith: .failure(error)) {
            imageLoader.completeWith(error)
        }
    }
    
    func test_loadImageData_cachesImageOnLoaderSuccess() {
        let cache = CacheSpy()
        let (sut,imageLoader) = makeSUT(cache: cache)
        let imageData = anyImageData()
        _ = sut.loadImageData(url: anyURL()) { _ in }
        imageLoader.completeWith(data: imageData )
        XCTAssertEqual(cache.messages, [.save(imageData)], "Expected decorator to call cache on loader success")
    }
    
    func test_loadImageData_failsTocachesImageOnLoaderFailure() {
        let cache = CacheSpy()
        let (sut,imageLoader) = makeSUT(cache: cache)
        _ = sut.loadImageData(url: anyURL()) { _ in }
        imageLoader.completeWith(anyNSError())
        XCTAssertTrue(cache.messages.isEmpty, "Expected decorator to not call cache on loader failure")
    }
    
    
    
    //MARK: - Helpers
    
    private func makeSUT(cache:CacheSpy = .init(), file: StaticString = #filePath,
                         line: UInt = #line) -> (sut:FeedImageDataLoaderDecorator,imageLoader:FeedImageLoaderSpy) {
        let imageLoader = FeedImageLoaderSpy()
        let sut = FeedImageDataLoaderDecorator(decoratee:imageLoader,cache:cache)
        trackForMemoryLeaks(sut,file: file,line: line)
        trackForMemoryLeaks(imageLoader,file: file,line: line)
        return (sut,imageLoader)
    }
    
    private class CacheSpy:FeedImageCache {
        var messages = [Message]()
        
        enum Message:Equatable {
            case save(Data)
        }
        
        func saveImageData(_ data: Data, for url: URL, completion: @escaping (FeedImageCache.Result) -> Void) {
            messages.append(.save(data))
        }
    }
    
    
    
    
   
    
    
}
