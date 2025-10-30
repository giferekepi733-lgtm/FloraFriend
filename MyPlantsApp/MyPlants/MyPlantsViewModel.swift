import Foundation
import RealmSwift
import Combine

@MainActor
class MyPlantsViewModel: ObservableObject {
    
    @Published var plants: [Plant] = []
    
    private var plantResults: Results<Plant>
    private var notificationToken: NotificationToken?

    init() {
        plantResults = RealmManager.shared.fetch(Plant.self)
        
        // Этот наблюдатель теперь будет нашим единственным источником правды
        notificationToken = plantResults.observe { [weak self] _ in
            self?.plants = Array(self!.plantResults)
        }
        
        self.plants = Array(plantResults)
    }

    // THE FIX IS HERE: Реализация вашего плана.
    func deletePlant(withId id: ObjectId) {
        plants = []
        // Шаг 1: Удаляем уведомление (быстрая операция).
        NotificationManager.shared.removeNotification(forPlantID: id)
        
        // Шаг 2 (ВАШЕ ПРЕДЛОЖЕНИЕ): Вручную убираем растение из массива,
        // который видит UI. Это заставляет SwiftUI немедленно убрать карточку с экрана.
        if let index = plants.firstIndex(where: { $0.id == id }) {
            plants.remove(at: index)
        }
        
        // Шаг 3: Только теперь, когда UI БЕЗОПАСЕН, мы удаляем объект из базы данных.
        RealmManager.shared.delete(id: id)
        
        
        plantResults = RealmManager.shared.fetch(Plant.self)
        
        // Этот наблюдатель теперь будет нашим единственным источником правды
        notificationToken = plantResults.observe { [weak self] _ in
            self?.plants = Array(self!.plantResults)
        }
        
        self.plants = Array(plantResults)
        // Шаг 4: Наблюдатель Realm (notificationToken) заметит удаление и
        // асинхронно пришлет финальное, чистое состояние массива, но к этому моменту
        // крэш уже будет невозможен, так как мы убрали объект из массива вручную.
    }

    deinit {
        notificationToken?.invalidate()
    }
}
