import SwiftUI
import RealmSwift

@available(iOS 17.0, *)
struct PlantDetailView: View {
    // Получаем живой объект от родительского View
    @ObservedRealmObject var plant: Plant
    
    // Получаем замыкание (колбэк), которое будет вызвано при удалении
    var onDelete: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingDeleteAlert = false
    
    var body: some View {
        // Проверяем, не был ли объект удален
        if !plant.isInvalidated {
            List {
                // Секция с изображением
                Section {
                    if let imageData = plant.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 250)
                            .clipped()
                            .listRowInsets(EdgeInsets())
                    }
                }
                
                // Секция с информацией по уходу
                Section(header: Text("Care Guide")) {
                    InfoRow(label: "Watering", value: plant.careGuide?.watering ?? "N/A", icon: "drop.fill")
                    InfoRow(label: "Light", value: plant.careGuide?.light ?? "N/A", icon: "sun.max.fill")
                    InfoRow(label: "Temperature", value: plant.careGuide?.temperature ?? "N/A", icon: "thermometer")
                }
                
                // Секция с журналом ухода
                Section(header: Text("History & Journal")) {
                    if plant.journalEntries.isEmpty {
                        Text("No history yet.")
                    } else {
                        ForEach(plant.journalEntries.sorted(by: \.date, ascending: false)) { entry in
                            JournalRow(entry: entry)
                        }
                    }
                }

                // Секция с действиями
                Section(header: Text("Actions")) {
                    NavigationLink(destination: DiagnosisView()) {
                        Label("Diagnose Disease", systemImage: "cross.case.fill")
                    }
                    
                
                }
            }
            .navigationTitle(plant.customName)
            .navigationBarTitleDisplayMode(.inline)
                .alert("Are you sure?", isPresented: $isShowingDeleteAlert) {
                    Button("Delete", role: .destructive) {
                        // Вызываем колбэк и закрываем экран
                        onDelete()
                        dismiss()
                    }
                } message: {
                    Text("This will permanently delete \(plant.customName) and all its history.")
                }
        } else {
            // Заглушка, если объект был удален
            ProgressView()
        }
    }

}

// Вспомогательный View для строки информации
struct InfoRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Label(label, systemImage: icon)
            Spacer()
            Text(value)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.trailing)
        }
    }
}

// Вспомогательный View для строки журнала
struct JournalRow: View {
    @ObservedRealmObject var entry: JournalEntry
    
    var body: some View {
        if !entry.isInvalidated {
            HStack {
                VStack(alignment: .leading) {
                    Text(entry.eventType.rawValue)
                        .font(.headline)
                    Text(entry.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                Spacer()
                if entry.imageData != nil {
                    Image(systemName: "photo.fill")
                        .foregroundColor(.textSecondary)
                }
            }
            .padding(.vertical, 4)
        }
    }
}
