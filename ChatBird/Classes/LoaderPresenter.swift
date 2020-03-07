//
//  LoaderPresenter.swift
//  ChatBird
//
//  The MIT License (MIT)
//
//  Copyright (c) 2020 Velos Mobile LLC.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import Foundation
import UIKit
import Chatto

public class LoaderPresenterBuilder: ChatItemPresenterBuilderProtocol {

    public init() { }
    
    public func createPresenterWithChatItem(_ chatItem: ChatItemProtocol) -> ChatItemPresenterProtocol {
        guard let item = chatItem as? LoaderItem else {
            fatalError("chatItem is not the expected type: ChatLoadingDomainModel")
        }

        assert(self.canHandleChatItem(chatItem))
        return LoaderPresenter(loadingModel: item)
    }

    public var presenterType: ChatItemPresenterProtocol.Type {
        return LoaderPresenter.self
    }

    public func canHandleChatItem(_ chatItem: ChatItemProtocol) -> Bool {
        return chatItem is LoaderItem
    }
}

class LoaderPresenter: ChatItemPresenterProtocol {

    let loadingModel: LoaderItem
    init (loadingModel: LoaderItem) {
        self.loadingModel = loadingModel
    }

    private static let cellReuseIdentifier = LoaderCollectionViewCell.self.description()

    let isItemUpdateSupported = false

    func update(with chatItem: ChatItemProtocol) {}

    static func registerCells(_ collectionView: UICollectionView) {
        collectionView.register(LoaderCollectionViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
    }

    func dequeueCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: LoaderPresenter.cellReuseIdentifier, for: indexPath)
    }

    func configureCell(_ cell: UICollectionViewCell, decorationAttributes: ChatItemDecorationAttributesProtocol?) { }

    func cellWillBeShown(_ cell: UICollectionViewCell) {
        guard let loadingCell = cell as? LoaderCollectionViewCell else { return }
        loadingCell.activityIndicator.startAnimating()
    }

    func cellWasHidden(_ cell: UICollectionViewCell) {
        guard let loadingCell = cell as? LoaderCollectionViewCell else { return }
        loadingCell.activityIndicator.stopAnimating()
    }

    var canCalculateHeightInBackground: Bool {
        return true
    }

    func heightForCell(maximumWidth width: CGFloat, decorationAttributes: ChatItemDecorationAttributesProtocol?) -> CGFloat {
        return 24
    }
}
