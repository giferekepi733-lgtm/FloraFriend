import Foundation
import RealmSwift

class RealmManager {
    static let shared = RealmManager()
    private let realm: Realm
    
    private init() {
        do {
            realm = try Realm()
        } catch {
            fatalError("Failed to initialize Realm: \(error)")
        }
    }
    
    func save<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.add(object, update: .modified)
            }
        } catch {
            print("Error saving object: \(error)")
        }
    }
    
    func fetch<T: Object>(_ objectType: T.Type) -> Results<T> {
        return realm.objects(objectType)
    }
    
    // Простой, синхронный метод удаления в главном потоке.
    func delete(id: ObjectId) {
        guard let objectToDelete = realm.object(ofType: Plant.self, forPrimaryKey: id) else {
            return
        }
        
        do {
            try realm.write {
                realm.delete(objectToDelete)
            }
        } catch {
            print("Error deleting object: \(error)")
        }
    }
}
