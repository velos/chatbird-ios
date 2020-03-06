//
//  SBDUserMessageViewModel.swift
//
//  Created by David Rajan on 1/2/20.
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
