//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Kouv on 07/01/2025.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import CoreData
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    let localStoreURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("feed-store.sqlite")
    
    private lazy var httpClient: HTTPClient = {
            URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        }()

    private lazy var store: FeedStore & FeedImageDataStore = {
            try! CoreDataFeedStore(storeURL: localStoreURL)
        }()
    
    private lazy var localFeedLoader:LocalFeedLoader = {
        LocalFeedLoader(feedStore: store, currentDate: Date.init)
    }()
    
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
            self.init()
            self.httpClient = httpClient
            self.store = store
        }
   

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
            guard let _ = (scene as? UIWindowScene) else { return }
            
            configureWindow()
        }
        
    func configureWindow() {
            let remoteURL = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json")!
            
        let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: httpClient)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
            
        let localFeedLoader = LocalFeedLoader(feedStore: store, currentDate: Date.init)
        let localImageLoader = LocalFeedImageDataLoader(store: store)
            
        window?.rootViewController = UINavigationController(
                rootViewController: FeedUIComposer.feedComposedWith(
                    feedLoader: FeedLoaderWithFallbackComposite(
                        primary: FeedLoaderCacheDecorator(
                            decoratee: remoteFeedLoader,
                            cache: localFeedLoader),
                        fallback: localFeedLoader),
                    imageLoader: FeedImageDataWithFallbackComposite(
                        primaryLoader: localImageLoader,
                        fallbackLoader: FeedImageDataLoaderDecorator(
                            decoratee: remoteImageLoader,
                            cache: localImageLoader))))
        }

    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in 
            
        }
    }

}

