//
//  FeedViewController+TesHelpers.swift
//  EssentialFeed
//
//  Created by Kouv on 02/01/2025.
//
import Foundation
import EssentialFeediOS
import UIKit


private class FakeRefreshControl:UIRefreshControl {
    private var _isRefreshing:Bool = false
    
    override var isRefreshing: Bool{
        _isRefreshing
    }
    override func beginRefreshing() {
        _isRefreshing = true
    }
    override func endRefreshing() {
        _isRefreshing = false
    }
}

extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator:Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func replaceRefreshControlWithFakeForiOS17support() {
        let fake = FakeRefreshControl()
        refreshControl?.allTargets.forEach({ target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({ action in
                fake.addTarget(target, action: Selector(action), for: .valueChanged)
            })
        })
        refreshControl = fake
        
    }
    
    func renderedFeedImageData(at index: Int) -> Data? {
        return simulateFeedImageViewVisible(at: index)?.renderedImage
    }
    
    func numberOfRenderedImageviews() -> Int {
        return tableView.numberOfRows(inSection: feedImagesSection)
    }
    
    private var feedImagesSection:Int {
        return 0
    }
    
    func feedImageView(at index:Int) -> UITableViewCell?  {
        guard numberOfRenderedImageviews() > index else {return nil}
        let ds = tableView.dataSource
        let indexPath = IndexPath(row: index, section: feedImagesSection)
        return ds?.tableView(tableView, cellForRowAt: indexPath)
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at index:Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    @discardableResult
    func simulateFeedImageViewNotVisible(at index:Int) -> FeedImageCell? {
        let view = simulateFeedImageViewVisible(at: index)
        
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: index, section: feedImagesSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: indexPath )
        return view
    }
    
    func simulateFeedImageNearVisible(at row:Int) {
        let preDS = tableView.prefetchDataSource
        let indexPath = IndexPath(row: row, section: feedImagesSection)
        preDS?.tableView(tableView, prefetchRowsAt: [indexPath])
    }
    
    func simulateImageViewNotNearVisible(at row:Int) {
        simulateFeedImageNearVisible(at:row)
        let preDS = tableView.prefetchDataSource

        let indexPath = IndexPath(row: row, section: feedImagesSection)

        preDS?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }
    
    func simulateViewAppearing() {
        loadViewIfNeeded()
        replaceRefreshControlWithFakeForiOS17support()
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    var errorMessage: String? {
        return errorView?.message
    }
    

}
