//
//  LoaderPresenter.swift
//
//  Created by Zac White on 11/11/18.
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
