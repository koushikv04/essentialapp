//
//  FeedViewControllerTests.swift
//  EssentialFeed
//
//  Created by Kouv on 17/12/2024.
//

import XCTest
import UIKit
import EssentialApp
import EssentialFeed
import EssentialFeediOS

final class FeeUIIntegrationTests:XCTestCase {
    
    func test_feedView_hasTitle() {
        let (sut,_) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        let bundle = Bundle(for: FeedViewController.self)
        let localisedKey = "FEED_TITLE"
        let localisedTitle = bundle.localizedString(forKey: localisedKey, value: nil, table: "Feed")
        XCTAssertNotEqual(localisedKey, localisedTitle,"missing localised value for the key")
        XCTAssertEqual(sut.title, localised("FEED_TITLE"))

    }
    
    
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut,loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0,"Expected no loading requets before view is loaded")

        sut.loadViewIfNeeded()
        
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        
        XCTAssertEqual(loader.loadCallCount,1, "expected one loading request once view is loaded")
        
        sut.simulateUserInitiatedFeedReload()
        
        XCTAssertEqual(loader.loadCallCount,2, "expected another loading request once user initiates reload")
        
        sut.simulateUserInitiatedFeedReload()
        
        XCTAssertEqual(loader.loadCallCount,3,"expected another loading request once user initiates reload")

    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut,loader) = makeSUT()

        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFakeForiOS17support()
        
        XCTAssertEqual(sut.isShowingLoadingIndicator,false,"Expected no loading indicator before view is loaded")

        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        
        XCTAssertEqual(sut.isShowingLoadingIndicator,true, "Expected loading indicator once view is loaded")
        
        loader.completeFeedLoading(at : 0)
        
        XCTAssertEqual(sut.isShowingLoadingIndicator,false,"Expected no loading indicator when feed loaded successfully")
        
        sut.simulateUserInitiatedFeedReload()
                
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator on user initiated refresh")

        loader.completeFeedLoadingWithError(at: 1)
        
        XCTAssertEqual(sut.isShowingLoadingIndicator, false,"Expected no loading indicator once user initated refresh completes with error")
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description:"a description",location:"a location")
        let image1 = makeImage(description:nil,location:"a location")
        let image2 = makeImage(description:"a description",location:nil)
        let image3 = makeImage(description:nil,location:nil)

        let (sut,loader) = makeSUT()
        sut.simulateViewAppearing()
        
        assertThat(sut, isRendering: [])
        
        loader.completeFeedLoading(with: [image0],at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        
        loader.completeFeedLoading(with: [image0,image1,image2,image3], at: 1)
        assertThat(sut, isRendering: [image0,image1,image2,image3])

    }
    
    func test_loadFeedCompletion_shouldNotAlterExisitingFeedOnError() {
        let (sut,loader) = makeSUT()
        let image0 = makeImage(description:"a description",location:"a location")
        sut.simulateViewAppearing()

        loader.completeFeedLoading(with: [image0],at: 0)
        assertThat(sut, isRendering: [image0])
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError( at: 1)
        assertThat(sut, isRendering: [image0])
    }

    func test_feedImage_loadsImageURLWhenVisible() {
        let image0 = makeImage(url: URL(string: "any-url")!)
        let image1 = makeImage(url: URL(string: "any-url")!)
        let (sut,loader) = makeSUT()
        sut.simulateViewAppearing()

        
        loader.completeFeedLoading(with: [image0,image1], at: 0)
        
        XCTAssertEqual(loader.loadedImageURLs, [],"Expected no loading of image until view is visible")
        
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url],"Expected first image url once view is visible")
        
        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url,image1.url],"Expected two images url once view is visible")


    }
    
    func test_feedImage_cancelImageURLWhenNotVisible() {
        let image0 = makeImage(url: URL(string: "any-url")!)
        let image1 = makeImage(url: URL(string: "any-url")!)
        let (sut,loader) = makeSUT()
        sut.simulateViewAppearing()
        
        loader.completeFeedLoading(with: [image0,image1], at: 0)
        
        XCTAssertEqual(loader.cancelledImageURLs, [],"Expected no cancellations of image url until image is not visible")
        
        sut.simulateFeedImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url],"Expected cancelled first image when view is not visible")
        
        sut.simulateFeedImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url,image1.url],"Expected cancelled two images url once view is not visible")


    }
    
    func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let (sut,loader) = makeSUT()
        sut.simulateViewAppearing()

        let image0 = makeImage(url: URL(string: "any-url")!)
        let image1 = makeImage(url: URL(string: "any-url")!)
        loader.completeFeedLoading(with: [image0,image1], at: 0)
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true,"Expected to show loading indicator on loading first image")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true,"Expected to show loading indicator on loading second image")
        
        loader.completeImageLoadingWith(at:0)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false,"Expected to hide loading indicator once first image is loaded")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true,"Expected to show loading indicator on loading second image")

        loader.completeImageLoadingWith(at:1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false,"Expected to hide loading indicator once first image is loaded")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false,"Expected to hide loading indicator once second image is loaded")

        
    }
    
    func test_feedImageView_rendersImageLoadedFromURL() {
        let (sut,loader) = makeSUT()
        sut.simulateViewAppearing()

        let image0 = makeImage(url: URL(string: "any-url")!)
        let image1 = makeImage(url: URL(string: "any-url")!)
        loader.completeFeedLoading(with: [image0,image1], at: 0)
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.renderedImage, .none,"Expected first image not to be loaded yet")
        XCTAssertEqual(view1?.renderedImage, .none,"Expected second image not to be loaded yet")
        
        let image0Data = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoadingWith(image0Data,at:0)
        XCTAssertEqual(view0?.renderedImage, image0Data,"Expected to load first image")
        XCTAssertEqual(view1?.renderedImage, .none,"Expected second image not to be loaded yet")

        let image1Data = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoadingWith(image1Data,at:1)
        XCTAssertEqual(view0?.renderedImage, image0Data,"Expected first image to be loaded")
        XCTAssertEqual(view1?.renderedImage, image1Data,"Expected second image to be loaded")

    }
    
    func test_loadFeedImageRetryButton_isVisibleOnImageURLError() {
        let (sut,loader) = makeSUT()
        sut.simulateViewAppearing()

        let image0 = makeImage(url: URL(string: "any-url")!)
        let image1 = makeImage(url: URL(string: "any-url")!)
        loader.completeFeedLoading(with: [image0,image1], at: 0)
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false,"Expected no retry button for first image since image is not loaded yet")
        XCTAssertEqual(view1?.isShowingRetryAction, false,"Expected no retry button for second image since image is not loaded yet")
        
        let image0Data = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoadingWith(image0Data,at:0)
        XCTAssertEqual(view0?.isShowingRetryAction, false,"Expected no retry button for first image since image was loaded successfully")
        XCTAssertEqual(view1?.isShowingRetryAction, false,"Expected no retry button for second image since image is not loaded yet")

        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false,"Expected no retry button for first image since image was loaded successfully")
        XCTAssertEqual(view1?.isShowingRetryAction, true,"Expected to show retry button since it failed to load image ")
    }
    
    func test_feedImageRetryButton_isVisibleOnInvalidImageData() {
        let (sut,loader) = makeSUT()
        sut.simulateViewAppearing()

        let image0 = makeImage(url: URL(string: "any-url")!)
        loader.completeFeedLoading(with: [image0], at: 0)
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false,"Expected no retry button for first image since image is not loaded yet")
        
        let image0Data = Data("invalid data".utf8)
        loader.completeImageLoadingWith(image0Data,at:0)
        XCTAssertEqual(view0?.isShowingRetryAction, true,"Expected retry button for first image since image was not loaded due to invalid data")

    }
    
    func test_feedImageRetryButton_retryImageload() {
        let (sut,loader) = makeSUT()
        sut.simulateViewAppearing()

        let image0 = makeImage(url: URL(string: "any-url")!)
        let image1 = makeImage(url: URL(string: "any-url")!)

        loader.completeFeedLoading(with: [image0,image1], at: 0)
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url,image1.url],"Expected only two image urls before retry action")
        
        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url,image1.url],"Expected only two image urls before retry action")

        view0?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url,image1.url,image0.url],"Expected third image url after retry action")
        
        view1?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url,image1.url,image0.url,image1.url],"Expected fourth image url after retry action")

    }
    
    func test_feedImageView_preLoadsImageURLNearVisible() {
        let (sut,loader) = makeSUT()
        sut.simulateViewAppearing()

        let image0 = makeImage(url: URL(string: "any-url")!)
        let image1 = makeImage(url: URL(string: "any-url")!)

        loader.completeFeedLoading(with: [image0,image1], at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [],"Expected the image urls to be empty before images are loaded")

        
        sut.simulateFeedImageNearVisible(at:0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url],"Expected only one image url to preload")
        
        sut.simulateFeedImageNearVisible(at:1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url,image1.url],"Expected only two image urls to preload")
    }
    func test_feedImageView_cancelImageURLPreloadWhenViewIsNotVisibleAnymore() {
        let (sut,loader) = makeSUT()
        sut.simulateViewAppearing()

        let image0 = makeImage(url: URL(string: "any-url")!)
        let image1 = makeImage(url: URL(string: "any-url")!)

        loader.completeFeedLoading(with: [image0,image1], at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [],"Expected cancelled urls to be empty")

        
        sut.simulateImageViewNotNearVisible(at:0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url],"Expected only one image url to cancel preload")
        
        sut.simulateImageViewNotNearVisible(at:1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url,image1.url],"Expected only two image urls to cancel")
    }
    
    func test_feedImageView_doesNotLoadImageWhenViewIsNotVisibleAnymore() {
        let (sut,loader) = makeSUT()
        sut.simulateViewAppearing()
        loader.completeFeedLoading(with: [makeImage()], at: 0)

        let view = sut.simulateFeedImageViewNotVisible(at: 0)
        loader.completeImageLoadingWith(anyImageData(), at: 0)
        XCTAssertNil(view?.renderedImage, "Expected no rendered image since cell is not visible any more")
        

    }
    
    func test_loadfeedcompletion_dispatchesFromBackgroundToMainThread() {
        let (sut,loader) = makeSUT()
        sut.simulateViewAppearing()
        let exp = expectation(description: "complete loading on main thread")
        DispatchQueue.global().async {
            loader.completeFeedLoading(at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadImageDataCompletion_dispatchesImagesFromBackgroundToMainthread() {
        let (sut,loader) = makeSUT()
        sut.simulateViewAppearing()
        
        loader.completeFeedLoading(with: [makeImage()], at: 0)
        sut.simulateFeedImageNearVisible(at: 0)
        let exp = expectation(description: "complete loading on main thread")
        DispatchQueue.global().async {
            loader.completeImageLoadingWith(self.anyImageData(), at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadFeedCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()

        sut.simulateViewAppearing()


        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeFeedLoadingWithError(at: 0)
        
        XCTAssertEqual(sut.errorMessage, localised("FEED_VIEW_CONNECTION_ERROR"))
        
        sut.simulateUserInitiatedFeedReload()
        
        XCTAssertEqual(sut.errorMessage, nil)

    }
    
    
    
    //MARK: - HELPERS
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut:FeedViewController,loader:LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedUIComposer.feedComposedWith(feedLoader: loader, imageLoader: loader)
        trackForMemoryLeaks(sut, file:file, line: line)
        trackForMemoryLeaks(loader,file: file,line: line)
        return (sut,loader)
    }
    
    private func anyImageData() -> Data {
        return UIImage.make(withColor: .red).pngData()!
    }
    
    private func makeImage(description:String? = nil,location:String? = nil, url:URL = URL(string:"any-url")!) -> FeedImage {
        return FeedImage(id: UUID(),description: description,location: location, url: url)
    }
    
    private func assertThat(_ sut:FeedViewController, isRendering feed:[FeedImage],file: StaticString = #filePath,
                            line: UInt = #line) {
        guard sut.numberOfRenderedImageviews() == feed.count else {
            return XCTFail("Exptected \(feed.count) images but got \(sut.numberOfRenderedImageviews()) instead",file: file, line: line)
        }
        feed.enumerated().forEach { index,image in
            assertThat(sut, hasViewConfiguredFor: image, at: index,file: file,line: line)
        }
    }
    private func assertThat(_ sut:FeedViewController,hasViewConfiguredFor img:FeedImage, at index:Int,file: StaticString = #filePath,
                            line: UInt = #line) {
        let view = sut.feedImageView(at:index) as? FeedImageCell
        guard let cell = view else {
            return XCTFail("Expected \(FeedImageCell.self) instance but got \(String(describing:view))instead ",file: file,line: line)
        }
        let shouldLocationBeVisible = img.location != nil
        XCTAssertEqual(cell.isShowingLocation,shouldLocationBeVisible,"Expected 'isshowinglocation' to be \(shouldLocationBeVisible) for image view at \(index)",file: file, line: line)
        XCTAssertEqual(cell.locationLabel.text,img.location,"Expected 'location' to be \(String(describing: img.location)) for image view at \(index)",file: file, line: line)
        XCTAssertEqual(cell.descriptionLabel.text,img.description,"Expected 'description' to be \(String(describing: img.description)) for image view at \(index)",file: file, line: line)
    }
    class LoaderSpy:FeedLoader,FeedImageLoader {
        
        
        var loadCallCount:Int {
            return completions.count
        }
        var completions = [(FeedLoader.Result) -> Void]()
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeFeedLoading(with feed:[FeedImage] = [],at index:Int) {
            completions[index](.success(feed))
        }
        
        func completeFeedLoadingWithError( at index: Int) {
            let error = NSError(domain: "any domain", code: 500, userInfo: nil)
            completions[index](.failure(error))
        }
        
        //MARK: - Feed image loader
        var loadedImageURLs:[URL] {
            return imageRequests.map {$0.url}
        }
        
        var cancelledImageURLs = [URL]()
        
        struct TaskSpy:FeedImageDataLoaderTask {
            let cancelCallback : () -> Void
            func cancel() {
                cancelCallback()
            }
        }
        
        private var imageRequests = [(url:URL,completion: (FeedImageLoader.Result) -> Void)]()
        func loadImageData(url:URL, completion:@escaping (FeedImageLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            imageRequests.append((url,completion))
           return TaskSpy {[weak self] in
               self?.cancelledImageURLs.append(url)
            }
        }
        
        func cancelImageLoad(from url: URL) {
            cancelledImageURLs.append(url)
        }
        
        func completeImageLoadingWith(_ imageData:Data = Data(),at index:Int) {
            imageRequests[index].completion(.success(imageData))
        }
        
        func completeImageLoadingWithError(at index:Int = 0) {
            let error = NSError(domain: "any domain", code: 500, userInfo: nil)
            imageRequests[index].completion(.failure(error))
        }
    }
    
    
}
extension FeedImageCell {
    var isShowingLocation:Bool {
        return !locationContainer.isHidden
    }
    
    var isShowingImageLoadingIndicator:Bool {
        return feedImageContainer.isShimmering
    }
    
    var isShowingRetryAction:Bool {
        return !feedImageRetryButton.isHidden
    }
    
    var locationText:String? {
        return locationLabel.text
    }
    
    var descriptionText:String? {
        return descriptionLabel.text
    }
    
    var renderedImage:Data? {
        return feedImageView.image?.pngData()
    }
    
    func simulateRetryAction() {
        feedImageRetryButton.simulateTap()
    }
    
}




extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({ (target as NSObject).perform(Selector($0))
            })
        }
    }
}

extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach({ (target as NSObject).perform(Selector($0))
            })
        }
    }
}

public extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: rect.size,format:format).image { context in
            color.setFill()
            context.fill(rect)
        }
    }
}
