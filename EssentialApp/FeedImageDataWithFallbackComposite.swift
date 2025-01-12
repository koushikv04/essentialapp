//
//  FeedImageDataWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Kouv on 08/01/2025.
//
import EssentialFeed

public final class FeedImageDataWithFallbackComposite:FeedImageLoader {
    private let primaryLoader:FeedImageLoader
    private let fallbackLoader:FeedImageLoader
    
    public init(primaryLoader:FeedImageLoader,fallbackLoader:FeedImageLoader) {
        self.primaryLoader = primaryLoader
        self.fallbackLoader = fallbackLoader
    }
    
    private class Task:FeedImageDataLoaderTask {
        var wrapped:FeedImageDataLoaderTask?
        func cancel() {
            wrapped?.cancel()
        }
    }
    
    public func loadImageData(url: URL, completion: @escaping (FeedImageLoader.Result) -> Void) -> any FeedImageDataLoaderTask {
        let task = Task()
        task.wrapped =  primaryLoader.loadImageData(url: url) {[weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                task.wrapped = self?.fallbackLoader.loadImageData(url: url, completion: completion)
            }
        }
        return task
    }
}
