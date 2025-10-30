import SwiftUI

struct AddPlantView: View {
    
    @StateObject private var viewModel = AddPlantViewModel()
    @Environment(\.dismiss) private var dismiss
    
    // Это единственный источник правды для изображения в этом View
    @State private var pickedImageData: Data?
    
    var body: some View {
        NavigationView {
            VStack {
                switch viewModel.phase {
                case .initial:
                    initialView
                case .loading:
                    loadingView
                case .success(let result):
                    successView(result: result)
                case .manualEntry:
                    manualEntryView() // Больше не передаем данные
                case .error(let message):
                    errorView(message: message)
                }
            }
            .navigationTitle("Add New Plant")
            .navigationBarItems(leading: Button("Cancel") {
                viewModel.reset()
                dismiss()
            })
            .sheet(isPresented: $viewModel.isShowingImagePicker) {
                ImagePicker(imageData: $pickedImageData, sourceType: .camera)
            }
            .onChange(of: pickedImageData) { newData in
                viewModel.processPickedImage(data: newData)
            }
        }
    }
    
    private var initialView: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Let's identify your new plant!")
                .font(.title2).bold()
                .foregroundColor(.textPrimary)
            
            Button(action: { viewModel.startFlow(for: .scan) }) {
                Label("Scan Plant with Camera", systemImage: "camera.fill")
                    .font(.headline).foregroundColor(.white).padding().frame(maxWidth: .infinity)
                    .background(Color.primaryGreen).cornerRadius(12)
            }.padding(.horizontal)
            
            Button(action: { viewModel.startFlow(for: .manual) }) {
                Text("Or enter details manually").font(.subheadline).foregroundColor(.primaryGreen)
            }
            Spacer()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView().scaleEffect(1.5)
            Text("Identifying your plant...").font(.headline).foregroundColor(.textSecondary)
        }
    }

    private func successView(result: PlantIdentificationResult) -> some View {
        Form {
            Section(header: Text("Identified Plant")) {
                // THE FIX IS HERE: Используем `pickedImageData`
                if let data = pickedImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage).resizable().aspectRatio(contentMode: .fit).frame(height: 200).cornerRadius(12).frame(maxWidth: .infinity, alignment: .center)
                }
                Text(result.speciesName).bold()
            }
            Section(header: Text("Give it a name")) {
                TextField("e.g., Freddy the Ficus", text: $viewModel.customName)
            }
            Button(action: { viewModel.savePlant(); dismiss() }) {
                Text("Add to My Garden").font(.headline).frame(maxWidth: .infinity, alignment: .center)
            }.tint(.primaryGreen)
        }
    }
    
    // THE FIX IS HERE: View больше не принимает `imageData`, а берет его из `@State`
    private func manualEntryView() -> some View {
        Form {
            Section(header: Text("Plant Photo")) {
                if let data = pickedImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage).resizable().aspectRatio(contentMode: .fit).frame(height: 200).cornerRadius(12).frame(maxWidth: .infinity, alignment: .center)
                }
            }
            Section(header: Text("Plant Details")) {
                TextField("Custom Name (e.g., Freddy)", text: $viewModel.customName)
                TextField("Species (e.g., Ficus Lyrata)", text: $viewModel.speciesName)
            }
            Section(header: Text("Basic Care (Optional)")) {
                TextField("Watering needs", text: $viewModel.wateringNeeds)
                TextField("Light needs", text: $viewModel.lightNeeds)
            }
            Button(action: { viewModel.savePlant(); dismiss() }) {
                Text("Save Plant").font(.headline).frame(maxWidth: .infinity, alignment: .center)
            }.tint(.primaryGreen).disabled(viewModel.customName.isEmpty || viewModel.speciesName.isEmpty)
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Spacer()
            // THE FIX IS HERE: Теперь экран ошибки тоже может показать фото
            if let data = pickedImageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable().aspectRatio(contentMode: .fit).frame(height: 150)
                    .cornerRadius(12).padding(.bottom)
            }
            Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 40)).foregroundColor(.accentYellow)
            Text("Oh no!").font(.title.bold())
            Text(message).foregroundColor(.textSecondary).multilineTextAlignment(.center).padding(.horizontal)
            Button("Try Again") {
                viewModel.reset()
                // Очищаем `pickedImageData`, чтобы заново запустить флоу
                pickedImageData = nil
                viewModel.startFlow(for: .scan)
            }.buttonStyle(.borderedProminent).tint(.primaryGreen)
            Button("Enter Manually Instead") {
                viewModel.switchToManualEntry()
            }
            Spacer()
        }.padding()
    }
}
