//
//  FeedUIComposer.swift
//  EssentialFeed
//
//  Created by Kouv on 20/12/2024.
//
import UIKit
import EssentialFeed
import EssentialFeediOS

public final class FeedUIComposer {
    
    private init() {}
    public static func feedComposedWith(feedLoader: FeedLoader,imageLoader:FeedImageLoader) -> FeedViewController {
        let presenterAdapter = FeedLoaderPresentationAdapter(feedLoader: DispatchQueueMainDecorator(decoratee: feedLoader))
        let feedController = makeFeedController(delegate: presenterAdapter, title: "My Feed")
        let presenter = FeedPresenter(feedView: FeedViewAdapter(controller: feedController, imageLoader: DispatchQueueMainDecorator(decoratee: imageLoader)), loadingView: WeakRefVirtualProxy(feedController), errorView: WeakRefVirtualProxy(feedController))
        presenterAdapter.presenter = presenter
        return feedController
    }

    private static func makeFeedController(delegate:FeedViewControllerDelegate,title:String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = FeedPresenter.title
        return feedController
    }
}




