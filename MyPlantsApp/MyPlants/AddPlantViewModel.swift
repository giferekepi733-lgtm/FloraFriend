import Foundation
import SwiftUI

@MainActor
class AddPlantViewModel: ObservableObject {
    
    enum AddMode {
        case scan, manual
    }
    
    // THE FIX IS HERE: Упрощаем enum. Данные об изображении будут храниться отдельно.
    enum AddPlantPhase {
        case initial
        case loading
        case success(PlantIdentificationResult)
        case manualEntry
        case error(String)
    }
    
    @Published var phase: AddPlantPhase = .initial
    @Published var isShowingImagePicker = false
    
    @Published var customName: String = ""
    @Published var speciesName: String = ""
    @Published var wateringNeeds: String = ""
    @Published var lightNeeds: String = ""
    
    // Это единственный источник правды об изображении внутри ViewModel
    private var plantImageData: Data?
    private var userIntent: AddMode = .scan
    
    func startFlow(for mode: AddMode) {
        self.userIntent = mode
        self.isShowingImagePicker = true
    }
    
    func processPickedImage(data: Data?) {
        guard let imageData = data else {
            isShowingImagePicker = false
            return
        }
        
        self.plantImageData = imageData
        isShowingImagePicker = false
        
        switch userIntent {
        case .scan:
            Task { await identifyPlant() }
        case .manual:
            // Сразу переходим в ручной режим
            phase = .manualEntry
        }
    }
    
    private func identifyPlant() async {
        guard let imageData = plantImageData else { return }
        phase = .loading
        
        do {
            let result = try await GeminiService.shared.identifyPlant(from: imageData)
            if result.speciesName.isEmpty {
                phase = .error("We couldn't identify this plant. Please try again or enter the details manually.")
            } else {
                self.customName = result.commonName
                self.speciesName = result.speciesName
                phase = .success(result)
            }
        } catch {
            phase = .error("There was an issue with automatic identification. Please try again or enter the details manually.")
        }
    }
    
    func switchToManualEntry() {
        guard self.plantImageData != nil else {
            reset()
            return
        }
        phase = .manualEntry
    }
    
    // Логика сохранения остается без изменений, но теперь она будет брать `plantImageData` из свойства класса.
    func savePlant() {
        switch phase {
        case .success(let result):
            save(
                customName: customName.isEmpty ? result.commonName : customName,
                speciesName: result.speciesName,
                watering: result.careGuide.watering,
                light: result.careGuide.light,
                temperature: result.careGuide.temperature
            )
        case .manualEntry:
            save(
                customName: customName,
                speciesName: speciesName,
                watering: wateringNeeds,
                light: lightNeeds,
                temperature: "18-24°C" // Default value
            )
        default:
            return
        }
    }
    
    private func save(customName: String, speciesName: String, watering: String, light: String, temperature: String) {
        guard let imageData = self.plantImageData, !customName.isEmpty, !speciesName.isEmpty else {
            return
        }
        
        let newPlant = Plant()
        newPlant.customName = customName
        newPlant.speciesName = speciesName
        newPlant.imageData = imageData
        
        let newCareGuide = CareGuide()
        newCareGuide.watering = watering
        newCareGuide.light = light
        newCareGuide.temperature = temperature
        newPlant.careGuide = newCareGuide
        
        newPlant.acquisitionDate = Date()
        newPlant.wateringFrequency = 7
        
        RealmManager.shared.save(newPlant)
        
        let nextWateringDate = CareCalculator.calculateNextWateringDate(lastWatered: newPlant.lastWateredDate, frequencyInDays: newPlant.wateringFrequency)
        NotificationManager.shared.scheduleNotification(plantID: newPlant.id, plantName: newPlant.customName, on: nextWateringDate)
    }
    
    func reset() {
        phase = .initial
        plantImageData = nil
        isShowingImagePicker = false
        customName = ""
        speciesName = ""
        wateringNeeds = ""
        lightNeeds = ""
        userIntent = .scan
    }
}
