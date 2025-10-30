import SwiftUI

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @State private var isShowingShareSheet = false
    @State private var isShowingDeleteAlert = false
    
    var body: some View {
        Form {
            // Section for System Permissions
            Section(header: Text("Permissions")) {
                Button(action: {
                    viewModel.openAppSettings()
                }) {
                    Label("Notifications & Camera", systemImage: "gearshape")
                }
                .foregroundColor(.primary)
            }
            
            // Section for App Feedback & Sharing
            Section(header: Text("Support & Feedback")) {
                Button(action: {
                    viewModel.requestReview()
                }) {
                    Label("Rate Flora Friend", systemImage: "star.fill")
                }
                .foregroundColor(.primary)
                
                Button(action: {
                    isShowingShareSheet = true
                }) {
                    Label("Share with Friends", systemImage: "square.and.arrow.up.fill")
                }
                .foregroundColor(.primary)
            }
            
            // Section for Data Management (Danger Zone)
            Section(header: Text("Data Management")) {
                Button(role: .destructive) {
                    isShowingDeleteAlert = true
                } label: {
                    Label("Delete All Data", systemImage: "trash.fill")
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingShareSheet) {
            // Configure the share sheet content here
            let shareText = "Check out Flora Friend, an amazing app to help you with your plants!"
            // If you have a link to your app on the App Store, add it here
            // let appStoreLink = URL(string: "https://apps.apple.com/...")!
            ShareSheet(activityItems: [shareText])
        }
        .alert("Are you absolutely sure?", isPresented: $isShowingDeleteAlert) {
            Button("Delete All My Data", role: .destructive) {
                viewModel.deleteAllData()
                // Optionally, you can add a small haptic feedback here
            }
        } message: {
            Text("This action is irreversible and will delete all your plants, journals, and achievements. Your app will be reset to its initial state.")
        }
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
}
