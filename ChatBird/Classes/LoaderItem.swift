//
//  ChatLoadingDomainModel.swift
//
//  Created by Zac White on 11/11/18.
//

import Foundation
import Chatto

public class LoaderItem: ChatItemProtocol {
    public let uid: String = LoaderItem.uid
    public let type: String = LoaderItem.chatItemType

    public static var chatItemType: ChatItemType = "LoaderItem"
    static var uid: String = "loading"
}
