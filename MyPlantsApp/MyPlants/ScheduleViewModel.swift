import Foundation
import RealmSwift
import Combine

struct CareTask: Identifiable {
    let id: ObjectId
    let plantName: String
    let eventType: CareEventType
    let dueDate: Date
    let plantID: ObjectId
}

@MainActor
class ScheduleViewModel: ObservableObject {
    
    @Published var upcomingTasks: [CareTask] = []
    @Published var completedTodayTasks: [JournalEntry] = []
    
    private var allPlants: Results<Plant>
    private var notificationToken: NotificationToken?
    private let realm: Realm // ViewModel будет держать свою ссылку на Realm

    init() {
        // Инициализируем Realm здесь, в главном потоке
        self.realm = try! Realm()
        self.allPlants = RealmManager.shared.fetch(Plant.self)
        
        setupObservers()
        updateData()
    }
    
    private func setupObservers() {
        notificationToken = allPlants.observe { [weak self] _ in
            self?.updateData()
        }
    }
    
    private func updateData() {
        var tasks: [CareTask] = []
        for plant in allPlants {
            let nextWateringDate = CareCalculator.calculateNextWateringDate(
                lastWatered: plant.lastWateredDate,
                frequencyInDays: plant.wateringFrequency
            )
            
            let wateringTask = CareTask(
                id: plant.id,
                plantName: plant.customName,
                eventType: .watered,
                dueDate: nextWateringDate,
                plantID: plant.id
            )
            tasks.append(wateringTask)
        }
        self.upcomingTasks = tasks.sorted { $0.dueDate < $1.dueDate }
        
        let todayStart = Calendar.current.startOfDay(for: Date())
        let completedEntries = allPlants.flatMap { $0.journalEntries }.filter { $0.date >= todayStart }
        self.completedTodayTasks = completedEntries.sorted { $0.date > $1.date }
    }
    
    // THE FIX IS HERE: The logic now lives inside the ViewModel.
    func completeTask(task: CareTask) {
        // 1. Find the live, managed object in this thread's Realm instance.
        guard let plantToUpdate = realm.object(ofType: Plant.self, forPrimaryKey: task.plantID) else {
            return
        }
        
        // 2. Create the new journal entry.
        let journalEntry = JournalEntry()
        journalEntry.date = Date()
        journalEntry.eventType = .watered
        
        // 3. Perform a write transaction to update the plant.
        do {
            try realm.write {
                plantToUpdate.journalEntries.append(journalEntry)
                plantToUpdate.lastWateredDate = Date()
            }
        } catch {
            print("Failed to complete task: \(error)")
            return // Stop if the write fails
        }
        
        // 4. After the successful write, reschedule the notification.
        // The `plantToUpdate` object is now updated, so we can calculate the new date.
        let newNextWateringDate = CareCalculator.calculateNextWateringDate(
            lastWatered: plantToUpdate.lastWateredDate,
            frequencyInDays: plantToUpdate.wateringFrequency
        )
        
        NotificationManager.shared.scheduleNotification(
            plantID: plantToUpdate.id,
            plantName: plantToUpdate.customName,
            on: newNextWateringDate
        )
    }
    
    deinit {
        notificationToken?.invalidate()
    }
}
