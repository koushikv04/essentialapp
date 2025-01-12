//
//  FeedLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Kouv on 09/01/2025.
//
import EssentialFeed

public final class FeedLoaderCacheDecorator:FeedLoader {
    private let decoratee:FeedLoader
    private let cache:FeedCache
    
    public init(decoratee:FeedLoader,cache:FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            completion(result.map { feed in
                self?.cache.saveIgnoringResult(feed)
                return feed
            })
        }
    }
}

extension FeedCache {
    func saveIgnoringResult(_ feed:[FeedImage]) {
        self.save(feed) { _ in
            
        }
    }
}
