
import Foundation
import FirebaseMessaging
import UIKit

final class TokenStore: NSObject, MessagingDelegate {
    static let shared = TokenStore()
    private override init() { super.init() }

    private var waiters: [(String?) -> Void] = []
    private(set) var fcmToken: String? {
        didSet {
            guard fcmToken != nil else { return }
            waiters.forEach { $0(fcmToken) }
            waiters.removeAll()
        }
    }

    func start() {
        Messaging.messaging().delegate = self

        Messaging.messaging().token { [weak self] token, error in
            if let token { print("✅ FCM token (pull): \(token)"); self?.fcmToken = token }
            else { print("⚠️ FCM token pull error: \(error?.localizedDescription ?? "nil")") }
        }

        
    }

    func waitForFCMToken(timeoutSec: TimeInterval, _ cb: @escaping (String?) -> Void) {
        if let t = fcmToken { cb(t); return }
        waiters.append(cb)
        DispatchQueue.main.asyncAfter(deadline: .now() + timeoutSec) { [weak self] in
            guard let self else { return }
            print("⏱️ FCM wait timeout — returning \(self.fcmToken ?? "nil")")
            cb(self.fcmToken)
            self.waiters.removeAll()
        }
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("✅ FCM token (delegate): \(fcmToken ?? "nil")")
        self.fcmToken = fcmToken
    }
}
