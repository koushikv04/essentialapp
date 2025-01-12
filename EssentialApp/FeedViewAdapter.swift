//
//  FeedViewAdapter.swift
//  EssentialFeed
//
//  Created by Kouv on 02/01/2025.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapter:FeedView {
    
    private weak var controller:FeedViewController?
    private var imageLoader:FeedImageLoader
    
    init(controller: FeedViewController, imageLoader: FeedImageLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display( viewModel.feed.map{ model in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>,UIImage>(model: model, imageLoader: imageLoader)
            let view = FeedImageCellController(delegate: adapter)
            adapter.presenter = FeedImagePresenter(view: WeakRefVirtualProxy(view), imageTransformer: UIImage.init)
            return view
        })
    }

}



