//
//  FeedImageDataLoaderPresentationAdapter.swift
//  EssentialFeed
//
//  Created by Kouv on 02/01/2025.
//

import EssentialFeed
import EssentialFeediOS

final class FeedImageDataLoaderPresentationAdapter<View:FeedImageView, Image>:FeedImageCellControllerDelegate where View.Image == Image {
    var presenter:FeedImagePresenter<View,Image>?
    private let imageLoader:FeedImageLoader
    private let model:FeedImage
    private var task:FeedImageDataLoaderTask?
    
    init(model:FeedImage,imageLoader: FeedImageLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func didRequestImageData() {
        presenter?.didStartLoadingImageData(for: model)
        let model = self.model
        task = imageLoader.loadImageData(url: model.url) {[weak self] result in
            switch result {
            case let .success(imageData):
                self?.presenter?.didFinishLoadingImageData(with: imageData, for: model)
            case let .failure(error):
                self?.presenter?.didFinishLoadingImageData(with: error, for: model)
                
            }
        }
    }
    
    func didCancelImageRequest() {
        task?.cancel()
    }
    
}
