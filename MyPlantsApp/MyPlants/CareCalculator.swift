import Foundation

struct CareCalculator {
    
    // This function takes the raw data and returns the next watering date.
    // It is completely independent of Realm objects.
    static func calculateNextWateringDate(lastWatered: Date?, frequencyInDays: Int) -> Date {
        guard let lastWateredDate = lastWatered else {
            // If never watered, the next date is today.
            return Date()
        }
        return Calendar.current.date(byAdding: .day, value: frequencyInDays, to: lastWateredDate) ?? Date()
    }
}
