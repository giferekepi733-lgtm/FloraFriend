import SwiftUI
import RealmSwift



// Represents a single achievement the user can earn.
struct Achievement: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let iconName: String
    var isUnlocked: Bool = false
}

class AchievementsManager {
    
    static let shared = AchievementsManager()
    private let unlockedAchievementsKey = "unlockedAchievements"
    
    // The master list of all possible achievements in the app
    private let allAchievements: [Achievement] = [
        Achievement(name: "Plant Parent", description: "Add your first plant to the garden.", iconName: "plus.circle.fill"),
        Achievement(name: "Green Thumb", description: "Successfully keep 5 plants alive.", iconName: "hand.thumbsup.fill"),
        Achievement(name: "Watering Wizard", description: "Water your plants 20 times.", iconName: "drop.circle.fill"),
        Achievement(name: "First Diagnosis", description: "Use the plant doctor for the first time.", iconName: "cross.case.fill"),
        Achievement(name: "Librarian", description: "Have a collection of 10 different plants.", iconName: "books.vertical.fill"),
        Achievement(name: "Dedicated Gardener", description: "Log into the app 7 days in a row.", iconName: "calendar.badge.clock"),
        Achievement(name: "Photographer", description: "Add 10 photos to your plant journals.", iconName: "photo.stack.fill")
    ]
    
    private init() {}
    
    // Checks the current game state and unlocks achievements if conditions are met.
    // This function can be called from various places in the app.
    func checkAchievements(plants: Results<Plant>) {
        var unlockedIds = getUnlockedAchievementIds()
        
        // Check "Plant Parent"
        if !plants.isEmpty && !unlockedIds.contains("Plant Parent") {
            unlockAchievement(name: "Plant Parent")
            unlockedIds.insert("Plant Parent")
        }
        
        // Check "Green Thumb"
        if plants.count >= 5 && !unlockedIds.contains("Green Thumb") {
            unlockAchievement(name: "Green Thumb")
            unlockedIds.insert("Green Thumb")
        }
        
        // Check "Librarian"
        if plants.count >= 10 && !unlockedIds.contains("Librarian") {
            unlockAchievement(name: "Librarian")
            unlockedIds.insert("Librarian")
        }

        // Check "Watering Wizard"
        let totalWaterings = plants.reduce(0) { $0 + $1.journalEntries.filter({ $0.eventType == .watered }).count }
        if totalWaterings >= 20 && !unlockedIds.contains("Watering Wizard") {
            unlockAchievement(name: "Watering Wizard")
            unlockedIds.insert("Watering Wizard")
        }
        
        // Check "Photographer"
        let totalPhotos = plants.reduce(0) { $0 + $1.journalEntries.filter({ $0.imageData != nil }).count }
        if totalPhotos >= 10 && !unlockedIds.contains("Photographer") {
            unlockAchievement(name: "Photographer")
            unlockedIds.insert("Photographer")
        }
    }
    
    // A specific function to be called after a diagnosis
    func didPerformDiagnosis() {
        if !getUnlockedAchievementIds().contains("First Diagnosis") {
            unlockAchievement(name: "First Diagnosis")
        }
    }
    
    // Returns the full list of achievements with their current unlocked status
    func getAchievements() -> [Achievement] {
        let unlockedIds = getUnlockedAchievementIds()
        return allAchievements.map { achievement in
            var updatedAchievement = achievement
            if unlockedIds.contains(achievement.name) {
                updatedAchievement.isUnlocked = true
            }
            return updatedAchievement
        }
    }
    
    // Helper function to save an unlocked achievement
    private func unlockAchievement(name: String) {
        var unlockedIds = getUnlockedAchievementIds()
        unlockedIds.insert(name)
        UserDefaults.standard.set(Array(unlockedIds), forKey: unlockedAchievementsKey)
    }
    
    // Helper function to get the set of unlocked achievement IDs
    private func getUnlockedAchievementIds() -> Set<String> {
        let savedArray = UserDefaults.standard.stringArray(forKey: unlockedAchievementsKey) ?? []
        return Set(savedArray)
    }
}
