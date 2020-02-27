//
//  SBDFileMessageViewModel.swift
//
//  Created by Zac White on 11/8/18.
//

import Foundation
import UIKit
import AVFoundation
import SendBirdSDK
import Chatto
import ChattoAdditions
import Nuke

var imageKey = "imageKey"
extension SBDFileMessage: PhotoMessageModelProtocol {
    fileprivate var _image: UIImage? {
        get { return objc_getAssociatedObject(self, &imageKey) as? UIImage }
        set { objc_setAssociatedObject(self, &imageKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    public var image: UIImage {
        get { return _image ?? UIImage() }
        set { _image = newValue }
    }

    public var imageSize: CGSize {
        return self.thumbnails?.first?.realSize ?? .zero
    }

    public var messageModel: MessageModelProtocol {
        return self
    }

    public func hasSameContent(as anotherItem: ChatItemProtocol) -> Bool {
        guard let other = anotherItem as? SBDFileMessage else { return false }
        return url == other.url
    }

}

public class SBDFileMessageViewModel: PhotoMessageViewModel<SBDFileMessage> {

    public override init(photoMessage: SBDFileMessage, messageViewModel: MessageViewModelProtocol) {
        super.init(photoMessage: photoMessage, messageViewModel: messageViewModel)
        self.image.value = photoMessage.image
    }

    var fileMessage: SBDFileMessage {
        return self.photoMessage as! SBDFileMessage
    }

    override public func willBeShown() {
        guard let downloadUrl = URL(string: self.fileMessage.url), fileMessage._image == nil else { return }
        
        if self.fileMessage.type.hasPrefix("image") {
            transferStatus.value = .transfering
            
            ImagePipeline.shared.loadImage(
                with: downloadUrl,
                progress: { _, completed, total in
                    self.transferProgress.value = Double(completed) / Double(total)
                },
                completion: { result in
                    switch result {
                    case .success(let response):
                        self.fileMessage._image = response.image
                        self.image.value = response.image
                        self.transferStatus.value = .success
                    case .failure(let error):
                        print(error)
                        self.transferStatus.value = .failed
                    }
                }
            )
        }
        else if fileMessage.type.hasPrefix("video") {
            let videoPlaceHolderImage = UIImage(named: "play.circle.fill", in: .chatBird, compatibleWith: nil)
            guard let url = URL(string: fileMessage.url) else {
                fileMessage._image = videoPlaceHolderImage
                image.value = videoPlaceHolderImage
                return
            }
            
            let request = ImageRequest(url: url, options: ImageRequestOptions(filteredURL: fileMessage.url))
            if let cachedimage = ImageCache.shared[request] {
                fileMessage._image = cachedimage
                image.value = cachedimage
            }
            else {
                transferStatus.value = .transfering
                let generator = AVAssetImageGenerator(asset: AVAsset(url: url))
                generator.appliesPreferredTrackTransform = true
                generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: CMTime(seconds: 1, preferredTimescale: 1))]) { [weak self] (_, image, _, _, error) in
                    DispatchQueue.main.async {
                        self?.transferStatus.value = .success
                        guard let cgImage = image, error == nil else {
                            self?.fileMessage._image = videoPlaceHolderImage
                            self?.image.value = videoPlaceHolderImage
                            return
                        }
                        
                        let videoImage = UIImage(cgImage: cgImage).mergeWith(topImage: (videoPlaceHolderImage?.tint(with: .white)))
                        
                        ImageCache.shared[request] = videoImage
                        self?.fileMessage._image = videoImage
                        self?.image.value = videoImage
                    }
                }
            }
        }
        else if fileMessage.type.hasPrefix("audio") {
            let audioPlaceHolderImage = UIImage(named: "speaker.3.fill", in: .chatBird, compatibleWith: nil)
            fileMessage._image = audioPlaceHolderImage
            image.value = audioPlaceHolderImage
        }
        else {
            let filePlaceHolderImage = UIImage(named: "doc.richtext", in: .chatBird, compatibleWith: nil)
            fileMessage._image = filePlaceHolderImage
            image.value = filePlaceHolderImage
        }
    }

    override public func wasHidden() { }
}

public class SBDFileMessageViewModelBuilder: ViewModelBuilderProtocol {
    public init() {}

    let messageViewModelBuilder = MessageViewModelDefaultBuilder()

    private var viewModelCache: NSMapTable<SBDFileMessage, SBDFileMessageViewModel> = NSMapTable(keyOptions: [.weakMemory], valueOptions: [.strongMemory])

    public func createViewModel(_ fileMessage: SBDFileMessage) -> SBDFileMessageViewModel {

        if let viewModel = viewModelCache.object(forKey: fileMessage){
            return viewModel
        }

        let messageViewModel = self.messageViewModelBuilder.createMessageViewModel(fileMessage)

        let newViewModel = SBDFileMessageViewModel(photoMessage: fileMessage, messageViewModel: messageViewModel)
        viewModelCache.setObject(newViewModel, forKey: fileMessage)

        updateImage(
            for: fileMessage.sender?.nickname,
            url: fileMessage.sender?.profileUrl,
            observable: messageViewModel.avatarImage
        )

        return newViewModel
    }

    public func canCreateViewModel(fromModel model: Any) -> Bool {
        return model is SBDFileMessage
    }
}
