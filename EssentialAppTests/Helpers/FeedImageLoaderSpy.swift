//
//  FeedImageLoaderSpy.swift
//  EssentialApp
//
//  Created by Kouv on 09/01/2025.
//
import EssentialFeed

class FeedImageLoaderSpy:FeedImageLoader {
    var completions = [(url:URL,completion:((FeedImageLoader.Result) -> Void))]()
    var cancelledURLs = [URL]()
    var requestedURLs:[URL] {
        return completions.map{$0.url}
    }
    
    private struct Task:FeedImageDataLoaderTask {
        let callback:()->Void
        func cancel() {
            callback()
        }
    }
    
    func loadImageData(url: URL, completion: @escaping (FeedImageLoader.Result) -> Void) -> any FeedImageDataLoaderTask {
        completions.append((url:url,completion:completion))
        return Task {[weak self] in
            self?.cancelledURLs.append(url)
        }
    }
    
    func completeWith(_ error:Error, at index:Int = 0) {
        completions[index].completion(.failure(error))
    }
    
    func completeWith(data:Data, at index:Int = 0) {
        completions[index].completion(.success(data))
    }
}
