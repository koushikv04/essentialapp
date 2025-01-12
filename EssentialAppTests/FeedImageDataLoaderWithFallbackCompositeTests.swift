//
//  FeedImageDataLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Kouv on 08/01/2025.
//
import XCTest
import EssentialFeed
import EssentialApp


final class FeedImageDataLoaderWithFallbackCompositeTests:XCTestCase, FeedImageDataLoaderTestCase {
    
    func test_init_doesNotLoadImage() {
        let (_,primaryLoader,fallbackLoader) = makeSUT()
        
        XCTAssertTrue(primaryLoader.requestedURLs.isEmpty, "Expected no message on init")
        XCTAssertTrue(fallbackLoader.requestedURLs.isEmpty, "Expected no message on init")
    }
    
    func test_load_loadsFromPrimaryLoaderFirst() {
        let (sut,primaryLoader,fallbackLoader) = makeSUT()
        let url = anyURL()

        _ = sut.loadImageData(url: url) { _ in }
        
        XCTAssertEqual(primaryLoader.requestedURLs,[url], "Expected primary to have received load call")
        XCTAssertTrue(fallbackLoader.requestedURLs.isEmpty, "Expected no message on fallback loader")
    }
    
    func test_load_loadsFromFallbackLoaderOnPrimaryLoaderFailure() {
        let (sut,primaryLoader,fallbackLoader) = makeSUT()
        let url = anyURL()

        _ = sut.loadImageData(url: url) { _ in }
        
        primaryLoader.completeWith(anyNSError())

        XCTAssertEqual(primaryLoader.requestedURLs,[url], "Expected primary to have received load call")
        XCTAssertEqual(fallbackLoader.requestedURLs,[url], "Expected fallback to have received load call")
    }
    
    func test_cancelLoadImageData_cancelPrimaryLoaderTask() {
        let (sut,primaryLoader,fallbackLoader) = makeSUT()
        let url = anyURL()

        let task = sut.loadImageData(url: url) { _ in }
        
        task.cancel()
        
        XCTAssertEqual(primaryLoader.cancelledURLs, [url],"Expected primary loader to have received cancel call for task")
        XCTAssertTrue(fallbackLoader.cancelledURLs.isEmpty,"Expected no cancelled urls for fallback loader")
        
    }
    
    func test_cancelLoadImageData_cancelFallbackLoaderAfterPrimaryLoaderTask() {
        let (sut,primaryLoader,fallbackLoader) = makeSUT()
        let url = anyURL()

        let task = sut.loadImageData(url: url) { _ in }
        primaryLoader.completeWith(anyNSError())
        task.cancel()
        
        XCTAssertTrue(primaryLoader.cancelledURLs.isEmpty,"Expected no cancel task on primary loader")
        XCTAssertEqual(fallbackLoader.cancelledURLs,[url],"Expected o cancelled urls for fallback loader")
        
    }
    
    func test_load_deliversImageOnPrimarySuccess() {
        let (sut,primaryLoader,_) = makeSUT()
        let primaryImageData = anyImageData()
        
        expect(sut, toCompleteWith: .success(primaryImageData)) {
            primaryLoader.completeWith(data: primaryImageData)
        }
    }
    
    func test_load_deliversFallbackImageOnPrimaryFailure() {
        let (sut,primaryLoader,fallbackLoader) = makeSUT()
        let fallbackImageData = anyImageData()
        
        expect(sut, toCompleteWith: .success(fallbackImageData)) {
            primaryLoader.completeWith(anyNSError())
            fallbackLoader.completeWith(data:fallbackImageData)
        }
    }
    
    func test_loadImageData_deliversFailureOnPrimaryAndFallbackLoaderFailure() {
        let (sut,primaryLoader,fallbackLoader) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(anyNSError())) {
            primaryLoader.completeWith(anyNSError())
            fallbackLoader.completeWith(anyNSError())
        }
    }
    
    //MARK: - Helpers
   
    
    
    
    private func makeSUT( file: StaticString = #filePath,
                          line: UInt = #line) -> (sut:FeedImageDataWithFallbackComposite,primaryLoader:FeedImageLoaderSpy,fallbackLoader:FeedImageLoaderSpy)  {

        let primaryLoader = FeedImageLoaderSpy()
        let fallbackLoader = FeedImageLoaderSpy()
        let sut = FeedImageDataWithFallbackComposite(primaryLoader: primaryLoader, fallbackLoader: fallbackLoader)
        trackForMemoryLeaks(sut,file: file,line: line)
        trackForMemoryLeaks(primaryLoader,file: file,line: line)
        trackForMemoryLeaks(fallbackLoader,file: file,line: line)
        return (sut,primaryLoader,fallbackLoader)
    }
    
    
}
