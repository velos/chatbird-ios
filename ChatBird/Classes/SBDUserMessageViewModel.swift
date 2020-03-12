//
//  SBDUserMessageViewModel.swift
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
import SendBirdSDK
import Chatto
import ChattoAdditions
import Nuke

extension SBDUserMessage: TextMessageModelProtocol {

    public var text: String {
        return self.message ?? ""
    }

    public var messageModel: MessageModelProtocol {
        return self
    }

    public func hasSameContent(as anotherItem: ChatItemProtocol) -> Bool {
        guard let other = anotherItem as? SBDUserMessage else { return false }
        return message == other.message
    }
}

extension ViewModelBuilderProtocol {
    func updateImage(for name: String?, url: String?, observable: ChattoAdditions.Observable<UIImage?>) {
        let placeholderImage = UIImage(named: "person.crop.circle.fill", in: .chatBird, compatibleWith: nil)
        guard let profileUrl = URL(string: url ?? "") else {
            observable.value = placeholderImage
            return
        }
        
        ImagePipeline.shared.loadImage(with: ImageRequest(url: profileUrl, processors: [ImageProcessor.Circle()])) { result in
            switch result {
            case .success(let response):
                observable.value = response.image
            case .failure(let error):
                observable.value = placeholderImage
                print(error)
            }
        }
    }
}

public class SBDUserMessageViewModel: TextMessageViewModel<SBDUserMessage> { }

public class SBDUserMessageViewModelBuilder: ViewModelBuilderProtocol {
    public init() {}

    let messageViewModelBuilder = MessageViewModelDefaultBuilder()

    public func createViewModel(_ userMessage: SBDUserMessage) -> SBDUserMessageViewModel {
        let messageViewModel = self.messageViewModelBuilder.createMessageViewModel(userMessage)
        let userMessageViewModel = SBDUserMessageViewModel(textMessage: userMessage, messageViewModel: messageViewModel)

        updateImage(
            for: userMessage.sender?.nickname,
            url: userMessage.sender?.profileUrl,
            observable: userMessageViewModel.avatarImage
        )

        return userMessageViewModel
    }

    public func canCreateViewModel(fromModel model: Any) -> Bool {
        return model is SBDUserMessage
    }
}
