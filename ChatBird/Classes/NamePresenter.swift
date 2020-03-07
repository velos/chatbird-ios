//
//  NamePresenter.swift
//  ChatBird
//
//  Adapted from Chatto sample app
//  https://github.com/badoo/Chatto
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015-present Badoo Trading Limited.
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

import UIKit
import Chatto
import ChattoAdditions

public class NameModel: ChatItemProtocol {
    public let uid: String
    public static var chatItemType: ChatItemType {
        return "decoration-name"
    }

    public var type: String { return NameModel.chatItemType }
    let name: String

    public init(uid: String, name: String) {
        self.uid = uid
        self.name = name
    }
}

public class NamePresenterBuilder: ChatItemPresenterBuilderProtocol {

    public init() { }
    
    public func canHandleChatItem(_ chatItem: ChatItemProtocol) -> Bool {
        return chatItem is NameModel ? true : false
    }

    public func createPresenterWithChatItem(_ chatItem: ChatItemProtocol) -> ChatItemPresenterProtocol {
        assert(self.canHandleChatItem(chatItem))
        return NamePresenter(
            nameModel: chatItem as! NameModel
        )
    }

    public var presenterType: ChatItemPresenterProtocol.Type {
        return NamePresenter.self
    }
}

public class NamePresenter: ChatItemPresenterProtocol {

    let nameModel: NameModel
    init (nameModel: NameModel) {
        self.nameModel = nameModel
    }

    public static func registerCells(_ collectionView: UICollectionView) {
        collectionView.register(NameCollectionViewCell.self, forCellWithReuseIdentifier: "NameCollectionViewCell")
    }

    public let isItemUpdateSupported = false

    public func update(with chatItem: ChatItemProtocol) {}

    public func dequeueCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NameCollectionViewCell", for: indexPath)
        return cell
    }

    public func configureCell(_ cell: UICollectionViewCell, decorationAttributes: ChatItemDecorationAttributesProtocol?) {
        guard let nameCell = cell as? NameCollectionViewCell else {
            assert(false, "expecting name cell")
            return
        }

        nameCell.label.text = nameModel.name
    }

    public var canCalculateHeightInBackground: Bool {
        return true
    }

    public func heightForCell(maximumWidth width: CGFloat, decorationAttributes: ChatItemDecorationAttributesProtocol?) -> CGFloat {
        return 19
    }
}
