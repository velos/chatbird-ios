//
//  Utils.swift
//  ChatBird
//
//  Created by David Rajan on 2/21/20.
//

import Foundation
import SendBirdSDK

extension UIImage {
    func round() -> UIImage {

        let imageGenerator: () -> UIImage = {
            let imageView: UIImageView = UIImageView(image: self)
            let layer = imageView.layer
            layer.masksToBounds = true
            layer.cornerRadius = imageView.bounds.size.width / 2.0
            UIGraphicsBeginImageContext(imageView.bounds.size)
            layer.render(in: UIGraphicsGetCurrentContext()!)
            let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return roundedImage!
        }

        if Thread.isMainThread {
            return imageGenerator()
        } else {

            var image: UIImage!
            DispatchQueue.main.sync {
                image = imageGenerator()
            }

            return image
        }
    }

    func tint(with fillColor: UIColor) -> UIImage {
        let image = withRenderingMode(.alwaysTemplate)
        let imageSize = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        return renderer.image { context in
            fillColor.set()
            image.draw(in: CGRect(origin: .zero, size: imageSize))
        }
    }
    
    func mergeWith(topImage: UIImage?) -> UIImage {
        guard let topImage = topImage else { return self }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let topImageOrigin = CGPoint(x: (size.width - topImage.size.width) / 2, y: (size.height - topImage.size.height) / 2)
            
            draw(at: .zero, blendMode: .copy, alpha: 1.0)
            topImage.draw(at: topImageOrigin, blendMode: .normal, alpha: 0.8)
        }
    }
    
    func resizeForSending() -> Data {
        let ratio = self.size.height / self.size.width
        let newSize = CGSize(width: 600, height: ratio * 600)

        return UIGraphicsImageRenderer(size: newSize)
            .jpegData(withCompressionQuality: 0.8) { context in
                self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

extension Bundle {
    private class BundleFinder { }
    public static let chatBird = Bundle(for: BundleFinder.self)
}

extension String {
    static func initialsFor(name: String) -> String {
        var nameComponents = name.uppercased().components(separatedBy: CharacterSet.letters.inverted)
        nameComponents.removeAll(where: { $0.isEmpty} )

        let firstInitial = nameComponents.first?.first
        let lastInitial  = nameComponents.count > 1 ? nameComponents.last?.first : nil
        return (firstInitial != nil ? "\(firstInitial!)" : "") + (lastInitial != nil ? "\(lastInitial!)" : "")
    }
}

extension SBDGroupChannel {
    /// Returns sorted list of members to display - edit this to change sorting
    public var membersString: String {
        let members = otherMembersArray

        switch members.count {
        case 0:
            // no other members in chat except self
            return "Waiting for Participants..."
        case 1:
            // one other member so return full name of other participant
            return members.compactMap { $0.nickname }.joined(separator: ", ")
        default:
            // return first name of members sorted by last name
            return members.compactMap { $0.nickname?.components(separatedBy: " ") }
                .sorted(by: { $0.last ?? "" < $1.last ?? "" })
                .compactMap { $0.first }
                .joined(separator: ", ")
        }
    }

    /// Returns array of all channel members
    public var allMembersArray: [SBDMember] {
        var allMembers = otherMembersArray
        if let currentMember = self.getMember(SBDMain.getCurrentUser()?.userId ?? "") {
            allMembers.insert(currentMember, at: 0)
        }
        return allMembers
    }

    /// Returns array of all channel members minus the current user
    public var otherMembersArray: [SBDMember] {
        let members: [SBDMember] = (self.members ?? []).compactMap { $0 as? SBDMember }
        return members.compactMap { $0.userId == SBDMain.getCurrentUser()?.userId ? nil : $0 }
    }
}

extension SBDUser {
    /// Returns user's nickname (or userId, if missing) for display
    public var displayName: String? {
        return (self.nickname?.isEmpty ?? true) ? self.userId : self.nickname
    }
}
