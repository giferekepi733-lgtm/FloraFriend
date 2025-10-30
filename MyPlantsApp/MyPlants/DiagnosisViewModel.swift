import SwiftUI

// MARK: - ViewModel
@MainActor
class DiagnosisViewModel: ObservableObject {
    enum DiagnosisPhase {
        case initial
        case loading
        case success(PlantDiagnosisResult)
        case error(String)
    }
    
    @Published var phase: DiagnosisPhase = .initial
    @Published var plantImageData: Data?
    
    func diagnosePlant() async {
        guard let imageData = plantImageData else { return }
        phase = .loading
        do {
            let result = try await GeminiService.shared.diagnoseDisease(from: imageData)
            phase = .success(result)
            AchievementsManager.shared.didPerformDiagnosis()
        } catch {
            phase = .error("Failed to get diagnosis. Please try again. Error: \(error.localizedDescription)")
        }
    }
    
    func reset() {
        phase = .initial
        plantImageData = nil
    }
}

// MARK: - View
struct DiagnosisView: View {
    @StateObject private var viewModel = DiagnosisViewModel()
    @State private var isShowingImagePicker = false
    
    var body: some View {
        VStack {
            switch viewModel.phase {
            case .initial:
                initialStateView
            case .loading:
                ProgressView("Diagnosing...")
            case .success(let result):
                resultsView(for: result)
            case .error(let message):
                errorStateView(message: message)
            }
        }
        .navigationTitle("Plant Doctor")
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(imageData: $viewModel.plantImageData, sourceType: .camera)
        }
        .onChange(of: viewModel.plantImageData) {
            if viewModel.plantImageData != nil {
                Task { await viewModel.diagnosePlant() }
            }
        }
    }
    
    private var initialStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "cross.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.primaryGreen)
            Text("Is your plant feeling unwell?")
                .font(.title2.bold())
            Text("Take a clear photo of the affected area (e.g., a leaf) and we'll try to diagnose the issue.")
                .multilineTextAlignment(.center)
                .foregroundColor(.textSecondary)
                .padding(.horizontal)
            Button("Scan for Diseases") {
                isShowingImagePicker = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.primaryGreen)
            .controlSize(.large)
            Spacer()
        }
        .padding()
    }
    
    private func resultsView(for result: PlantDiagnosisResult) -> some View {
        List {
            Section(header: Text("Diagnosis Result")) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(result.condition)
                        .font(.title.bold())
                    Text(result.description)
                        .foregroundColor(.textSecondary)
                }
                .padding(.vertical)
            }
            
            Section(header: Text("Potential Causes")) {
                ForEach(result.potentialCauses, id: \.self) { cause in
                    Text("• \(cause)")
                }
            }
            
            Section(header: Text("Recommended Treatment")) {
                ForEach(result.treatmentSteps, id: \.self) { step in
                    HStack(alignment: .top) {
                        Text("\(step.step).")
                            .bold()
                        Text(step.instruction)
                    }
                    .padding(.vertical, 4)
                }
            }
            
            Button("Scan Another Plant") {
                viewModel.reset()
            }
        }
    }
    
    private func errorStateView(message: String) -> some View {
        VStack(spacing: 20) {
            Text("😔")
                .font(.largeTitle)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.textSecondary)
            Button("Try Again") {
                viewModel.reset()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}
