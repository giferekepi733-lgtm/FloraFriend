import SwiftUI

struct ContentView: View {
    
    
    init() {
            // Request notification permission on app launch
            NotificationManager.shared.requestAuthorization()
        }
    
    
    var body: some View {
        
        TabView {
            MyPlantsView() // Replace Text("My Plants Screen") with this
                .tabItem {
                    Label("My Plants", systemImage: "leaf.fill")
                }
            
            ScheduleView() // Замените Text("Schedule Screen")
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
                }
                

            ToolsView() // Замените Text("Tools Screen")
                .tabItem {
                    Label("Tools", systemImage: "wrench.and.screwdriver.fill")
                }

            ProfileView() // Замените Text("Profile Screen")
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .tint(.primaryGreen) // Use our custom color for the selected tab icon
    }
}

#Preview {
    ContentView()
}
