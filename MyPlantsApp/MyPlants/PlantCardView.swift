import SwiftUI

struct PlantCardView: View {
    let plant: Plant

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Plant Image
            if let imageData = plant.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.secondaryGreen.opacity(0.3))
                    .frame(height: 120)
                    .overlay(
                        Image(systemName: "photo.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    )
            }

            // Plant Info
            VStack(alignment: .leading, spacing: 4) {
                Text(plant.customName)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                
                Text(plant.speciesName)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .overlay(alignment: .topTrailing) {
            // THE FIX IS HERE.
            // We now use the CareCalculator to get the date.
            let nextWatering = CareCalculator.calculateNextWateringDate(
                lastWatered: plant.lastWateredDate,
                frequencyInDays: plant.wateringFrequency
            )
            
            // The logic to show the indicator if the date is today or in the past.
            if nextWatering <= Date() {
                Image(systemName: "drop.fill")
                    .foregroundColor(.accentYellow)
                    .font(.title3)
                    .padding(8)
                    .background(Circle().fill(Color.white.opacity(0.8)))
                    .padding(8)
            }
        }
    }
}

