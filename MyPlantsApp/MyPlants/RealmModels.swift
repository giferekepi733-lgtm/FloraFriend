import Foundation
import RealmSwift

class Plant: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var customName: String
    @Persisted var speciesName: String
    @Persisted var imageData: Data?
    
    @Persisted var careGuide: CareGuide?
    
    @Persisted var acquisitionDate: Date
    @Persisted var lastWateredDate: Date?
    @Persisted var wateringFrequency: Int
    
    @Persisted var journalEntries: List<JournalEntry>
    
    // REMOVED: isMarkedForDeletion flag
}

class CareGuide: EmbeddedObject {
    @Persisted var watering: String = ""
    @Persisted var light: String = ""
    @Persisted var temperature: String = ""
}

class JournalEntry: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var date: Date
    @Persisted var note: String?
    @Persisted var imageData: Data?
    
    // We use the rawValue of the enum to store it as a String in Realm
    @Persisted private var eventTypeRaw: String
    
    var eventType: CareEventType {
        get { CareEventType(rawValue: eventTypeRaw) ?? .noteAdded }
        set { eventTypeRaw = newValue.rawValue }
    }
    
    // Linking back to the parent Plant object
    @Persisted(originProperty: "journalEntries") var plant: LinkingObjects<Plant>
}

enum CareEventType: String, Codable {
    case watered = "Watered"
    case fertilized = "Fertilized"
    case repotted = "Repotted"
    case photoAdded = "New Photo"
    case noteAdded = "Note"
    case diagnosis = "Health Check"
}
