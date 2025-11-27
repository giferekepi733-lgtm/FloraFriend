import SwiftUI
import RealmSwift

struct MyPlantsView: View {
    
    @StateObject private var viewModel = MyPlantsViewModel()
    @State private var isShowingAddPlantSheet = false
    
    private let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
    
    var body: some View {
        NavigationView {
            ScrollView {
                if viewModel.plants.isEmpty {
                    emptyStateView
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.plants) { plant in
                            // Передаем в детальный View замыкание onDelete
                            if #available(iOS 17.0, *) {
                                NavigationLink(destination:
                                                PlantDetailView(plant: plant, onDelete: {
                                    // Этот код выполнится, когда пользователь подтвердит удаление
                                    viewModel.deletePlant(withId: plant.id)
                                    
                                })
                                ) {
                                    PlantCardView(plant: plant)
                                }
                            } else {
                                // Fallback on earlier versions
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("My Plants")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isShowingAddPlantSheet = true }) {
                        Image(systemName: "plus")
                            .font(.headline)
                    }
                }
            }
            .sheet(isPresented: $isShowingAddPlantSheet) {
                AddPlantView()
            }
        }
    }

    // View для случая, когда растений нет
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "leaf.arrow.circlepath")
                .font(.system(size: 80))
                .foregroundColor(.primaryGreen)
            Text("Your garden is empty")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            Text("Tap the '+' button to add your first plant and start caring for it.")
                .font(.body)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
        .padding()
    }
}

// Preview для SwiftUI Canvas
#Preview {
    MyPlantsView()
}
