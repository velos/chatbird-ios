//
//  Utils.swift
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

extension Date {
    static let dateFormatter = DateFormatter()
    var lastActivityFormattedString: String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.current
        let current = Date()

        if calendar.isDateInToday(self) {
            Date.dateFormatter.doesRelativeDateFormatting = false
            Date.dateFormatter.setLocalizedDateFormatFromTemplate("jj:mm")
        }
        else if calendar.isDateInYesterday(self) {
            Date.dateFormatter.timeStyle = .none
            Date.dateFormatter.dateStyle = .medium
            Date.dateFormatter.doesRelativeDateFormatting = true
        }
        else if calendar.dateComponents([.day], from: self, to: current).day ?? 0 < 7 {
            Date.dateFormatter.doesRelativeDateFormatting = false
            Date.dateFormatter.setLocalizedDateFormatFromTemplate("E")
        }
        else if calendar.dateComponents([.year], from: self, to: current).year ?? 0 < 1 {
            Date.dateFormatter.doesRelativeDateFormatting = false
            Date.dateFormatter.setLocalizedDateFormatFromTemplate("MMMd")
        }
        else {
            Date.dateFormatter.doesRelativeDateFormatting = false
            Date.dateFormatter.timeStyle = .none
            Date.dateFormatter.dateStyle = .short
        }
        return Date.dateFormatter.string(from: self)
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
    
    /// Returns text to display for last message sent
    public var lastMessageString: String {
        var lastMessage: String = ""
        
        if let adminMessage = self.lastMessage as? SBDAdminMessage {
            lastMessage = adminMessage.message ?? ""
        }
        else if let userMessage = self.lastMessage as? SBDUserMessage {
            lastMessage = userMessage.message ?? ""
        }
        else if let fileMessage = self.lastMessage as? SBDFileMessage {
            if fileMessage.type.hasPrefix("image") {
                lastMessage = "📷 Photo"
            }
            else if fileMessage.type.hasPrefix("video") {
                lastMessage = "🎥 Video"
            }
            else if fileMessage.type.hasPrefix("audio") {
                lastMessage = "🔈 Audio"
            }
            else {
                lastMessage = "📄 File"
            }
        }

        return lastMessage
    }
    
    public var lastDateString: String {
        if let lastMessage = self.lastMessage {
            return Date(timeIntervalSince1970: Double(lastMessage.createdAt) / 1000.0).lastActivityFormattedString
        }
        else {
            return Date(timeIntervalSince1970: Double(self.createdAt) / 1000.0).lastActivityFormattedString
        }
    }
}

extension SBDUser {
    /// Returns user's nickname (or userId, if missing) for display
    public var displayName: String? {
        return (self.nickname?.isEmpty ?? true) ? self.userId : self.nickname
    }
}

public class UserQueryViewModel {
    var query: SBDApplicationUserListQuery?
    public var users: [SBDUser] = []
    
    public init() { }
    
    public func queryUserList(searchText: String = "", refresh: Bool = true, _ completion: @escaping () -> Void) {
        if refresh {
            query = nil
        }
        
        if query == nil {
            query = SBDMain.createApplicationUserListQuery()
            query?.userIdsFilter = [searchText]
            query?.limit = 20
        }
        
        guard query?.hasNext == true else {
            completion()
            return
        }
        
        query?.loadNextPage(completionHandler: { [weak self] (userArray, error) in
            guard error == nil else {
                print("Error loading user list: \(error?.localizedDescription ?? "")")
                completion()
                return
            }
            
            if refresh {
                self?.users.removeAll()
            }
            for user in userArray ?? [] {
                if user.userId == SBDMain.getCurrentUser()!.userId {
                    continue
                }
                self?.users.append(user)
            }
            completion()
        })
    }
}
