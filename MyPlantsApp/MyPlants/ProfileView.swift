import SwiftUI

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    headerView
                    
                    // Stats Section
                    statsView
                    
                    // Achievements Section
                    achievementsGrid
                }
                .padding()
            }
            .background(Color.backgroundLight)
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) { // Will create this view next
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .onAppear {
                viewModel.updateProfile() // Refresh data every time the view appears
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.primaryGreen)
            Text("Gardener") // Placeholder name
                .font(.title.bold())
        }
    }
    
    private var statsView: some View {
        HStack(spacing: 16) {
            StatCard(value: "\(viewModel.plantCount)", label: "Plants", icon: "leaf.fill")
            StatCard(value: "\(viewModel.totalWaterings)", label: "Waterings", icon: "drop.fill")
        }
    }
    
    private var achievementsGrid: some View {
        VStack(alignment: .leading) {
            Text("Achievements")
                .font(.title2.bold())
                .padding(.bottom, 8)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.achievements) { achievement in
                    AchievementIcon(achievement: achievement)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

// Subview for a single stat
struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.primaryGreen)
            Text(value)
                .font(.title.bold())
            Text(label)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

// Subview for a single achievement icon
struct AchievementIcon: View {
    let achievement: Achievement
    @State private var isShowingDetail = false
    
    var body: some View {
        VStack {
            Image(systemName: achievement.iconName)
                .font(.largeTitle)
                .padding()
                .background(achievement.isUnlocked ? Color.accentYellow.opacity(0.3) : Color.backgroundLight)
                .clipShape(Circle())
                .foregroundColor(achievement.isUnlocked ? .accentYellow : .gray.opacity(0.5))
            
            Text(achievement.name)
                .font(.caption)
                .lineLimit(1)
                .foregroundColor(achievement.isUnlocked ? .textPrimary : .textSecondary)
        }
        .onTapGesture {
            isShowingDetail = true
        }
        .alert(achievement.name, isPresented: $isShowingDetail) {
            // This is a simple way to show details. A custom sheet would be nicer.
        } message: {
            Text(achievement.description + (achievement.isUnlocked ? "\n\n(Unlocked!)" : "\n\n(Locked)"))
        }
    }
}
