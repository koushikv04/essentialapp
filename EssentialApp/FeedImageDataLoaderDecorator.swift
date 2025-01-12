//
//  FeedImageDataLoaderDecorator.swift
//  EssentialApp
//
//  Created by Kouv on 09/01/2025.
//
import EssentialFeed

public final class FeedImageDataLoaderDecorator:FeedImageLoader {
    private let decoratee:FeedImageLoader
    private let cache:FeedImageCache
    
    public init(decoratee: FeedImageLoader,cache:FeedImageCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    private class Task:FeedImageDataLoaderTask {
        func cancel() {
            
        }
    }
    
    public func loadImageData(url: URL, completion: @escaping (FeedImageLoader.Result) -> Void) -> any FeedImageDataLoaderTask {
        return decoratee.loadImageData(url: url) {[weak self] result in
            completion(result.map{imageData in
                self?.cache.saveImageDataIgnoringResult(imageData, for: url)
                return imageData
            })
        }
    }
    
}

extension FeedImageCache {
    func saveImageDataIgnoringResult(_ data:Data,for url:URL) {
        self.saveImageData(data, for: url) { _ in }
    }
}
