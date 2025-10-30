import Foundation
import RealmSwift

@MainActor
class ProfileViewModel: ObservableObject {
    
    @Published var achievements: [Achievement] = []
    @Published var plantCount: Int = 0
    @Published var totalWaterings: Int = 0
    
    private var allPlants: Results<Plant>
    
    init() {
        self.allPlants = RealmManager.shared.fetch(Plant.self)
        updateProfile()
    }
    
    func updateProfile() {
        // Call the manager to check for new unlocks based on current data
        AchievementsManager.shared.checkAchievements(plants: allPlants)
        
        // Then, get the updated list to display
        self.achievements = AchievementsManager.shared.getAchievements()
        
        // Update stats
        self.plantCount = allPlants.count
        self.totalWaterings = allPlants.reduce(0) { $0 + $1.journalEntries.filter({ $0.eventType == .watered }).count }
    }
}
