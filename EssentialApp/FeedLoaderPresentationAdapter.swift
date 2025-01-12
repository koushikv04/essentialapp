//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeed
//
//  Created by Kouv on 02/01/2025.
//

import EssentialFeed
import EssentialFeediOS

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    var presenter:FeedPresenter?
    private let feedLoader:FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        feedLoader.load {[weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter?.didFinishLoadingFeed(with: feed)
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(With: error)
            }
        }
    }
    
}


