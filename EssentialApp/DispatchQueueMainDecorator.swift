//
//  DispatchQueueMainDecorator.swift
//  EssentialFeed
//
//  Created by Kouv on 02/01/2025.
//

import Foundation
import EssentialFeed

final class DispatchQueueMainDecorator<T> {
    private let decoratee:T
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion:@escaping()->Void) {
        if Thread.isMainThread {
            completion()
        } else {
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}
extension DispatchQueueMainDecorator:FeedLoader where T == FeedLoader {
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch {completion(result)}
        }
    }
}

extension DispatchQueueMainDecorator:FeedImageLoader where T == FeedImageLoader {
    func loadImageData(url: URL, completion: @escaping (FeedImageLoader.Result) -> Void) -> any FeedImageDataLoaderTask {
        decoratee.loadImageData(url: url) {[weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
    
    
}
