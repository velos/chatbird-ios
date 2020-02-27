import SendBirdSDK

public class ChatBirdManager {
    public static let shared = ChatBirdManager()

    public func initializeSendbird(with appId: String) {
        print("** SendBird Initialize AppID: \(appId)")
        SBDMain.initWithApplicationId(appId)
        SBDMain.setLogLevel(SBDLogLevel.info)
    }

    public func update(token: Data?) {
        if let data = token {
            print("** SendBird Registering Push Token")
            SBDMain.registerDevicePushToken(data, unique: true, completionHandler: nil)
        } else {
            print("** SendBird Unregistering Push Token")
            SBDMain.unregisterAllPushToken(completionHandler: nil)
        }
    }

    public func connectSendBird(uuid: String, token: String? = nil, _ completion: @escaping (_ user: SBDUser?, _ error: SBDError?) -> Void) {

        print("** SendBird token: \(token ?? "")")
        SBDMain.connect(withUserId: uuid, accessToken: token) { (user, error) in

            if user != nil, let pendingToken = SBDMain.getPendingPushToken() {
                print("** SendBird registering pending token: \(pendingToken)")
                SBDMain.registerDevicePushToken(pendingToken, unique: true, completionHandler: nil)
            } else {
                print("** SendBird no registration needed")
            }

            completion(user, error)
        }
    }

    public func disconnectSendBird(_ completion: @escaping () -> Void) {
        SBDMain.disconnect {
            self.update(token: nil)
            UserDefaults.standard.removeObject(forKey: "sendbird_user_id")
            completion()
        }
    }
    
    public func updateUnreadMessageCount() {
        SBDMain.getTotalUnreadMessageCount { (unreadCount, error) in
            if error != nil {
                print("** SendBird error getting unread count: \(error?.localizedDescription ?? "")")
                return
            }

            UIApplication.shared.applicationIconBadgeNumber = Int(unreadCount)
            print("** SendBird got \(unreadCount) unread messages")
        }
    }
}
