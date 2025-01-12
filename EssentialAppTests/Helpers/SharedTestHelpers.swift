//
//  SharedTestHelpers.swift
//  EssentialApp
//
//  Created by Kouv on 08/01/2025.
//
import Foundation
import EssentialFeed

 func anyNSError() -> NSError {
    return NSError(domain: "app test", code: 0)
}


 func anyImageData() -> Data {
    return Data("image-data".utf8)
}

 func anyURL() -> URL {
    return URL(string:"https://any-url")!
}

func uniqueFeed() -> [FeedImage] {
    return [FeedImage(id: UUID(),description:"any", location: "any", url: URL(string: "https://any-url.com")!)]
}
