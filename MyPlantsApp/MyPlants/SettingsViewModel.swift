import Foundation
import SwiftUI
import RealmSwift
import StoreKit // Required for in-app review

@MainActor
class SettingsViewModel: ObservableObject {
    
    // Function to open the app's settings in the iOS Settings app
    func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsUrl) else {
            return
        }
        UIApplication.shared.open(settingsUrl)
    }
    
    // Function to request an in-app review from the user
    func requestReview() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    // Function to delete all plant data from Realm
    func deleteAllData() {
        // We perform deletion on a background thread to avoid blocking the UI
        DispatchQueue.global(qos: .background).async {
            do {
                let realm = try Realm()
                try realm.write {
                    // Get all objects of type Plant and JournalEntry
                    let allPlants = realm.objects(Plant.self)
                    let allJournalEntries = realm.objects(JournalEntry.self)
                    
                    // Delete them
                    realm.delete(allPlants)
                    realm.delete(allJournalEntries)
                }
                print("All data has been deleted.")
                
                // Also clear all pending notifications
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                print("All pending notifications removed.")

            } catch {
                print("Error deleting all data: \(error)")
            }
        }
    }
}


struct ShareSheet: UIViewControllerRepresentable {
    
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
