import SwiftUI

// Enum to define different plant types for humidity needs
enum PlantType: String, CaseIterable, Identifiable {
    case succulent = "Succulents & Cacti"
    case standard = "Standard Houseplants"
    case tropical = "Tropical Plants"
    
    var id: String { self.rawValue }
}

struct HumidityInfo {
    let range: String
    let description: String
    let tips: [String]
}

struct HumidityCalculatorView: View {
    @State private var selectedPlantType: PlantType = .standard
    
    private var humidityData: [PlantType: HumidityInfo] = [
        .succulent: HumidityInfo(
            range: "10-30%",
            description: "These desert plants prefer very dry air. High humidity can cause rot.",
            tips: [
                "Ensure good air circulation.",
                "Avoid placing them in bathrooms or kitchens.",
                "Group them with other succulents."
            ]
        ),
        .standard: HumidityInfo(
            range: "40-60%",
            description: "This is the ideal range for most common houseplants and is similar to average indoor humidity.",
            tips: [
                "Group plants together to create a microclimate.",
                "Use a pebble tray with water under the pot.",
                "Avoid placing near drafts or heating vents."
            ]
        ),
        .tropical: HumidityInfo(
            range: "60-80%+",
            description: "Originating from rainforests, these plants thrive in high humidity.",
            tips: [
                "Use a humidifier nearby.",
                "Mist the leaves regularly with a spray bottle.",
                "Keep them in a well-lit bathroom."
            ]
        )
    ]
    
    var body: some View {
        Form {
            Section(header: Text("Select Plant Type")) {
                Picker("Plant Type", selection: $selectedPlantType) {
                    ForEach(PlantType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Section(header: Text("Optimal Humidity")) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(humidityData[selectedPlantType]?.range ?? "")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primaryGreen)
                    
                    Text(humidityData[selectedPlantType]?.description ?? "")
                        .foregroundColor(.textSecondary)
                }
                .padding(.vertical)
            }
            
            Section(header: Text("Tips to Achieve")) {
                ForEach(humidityData[selectedPlantType]?.tips ?? [], id: \.self) { tip in
                    Label(tip, systemImage: "leaf.fill")
                }
            }
        }
        .navigationTitle("Humidity Guide")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        HumidityCalculatorView()
    }
}
