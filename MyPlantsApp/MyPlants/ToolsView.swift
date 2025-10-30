import SwiftUI

struct ToolsView: View {
    @State private var isShowingAddPlantSheet = false
    
    var body: some View {
        NavigationView {
            List {
                // Section for Identification & Diagnosis
                Section(header: Text("Identification & Health")) {
                    NavigationLink(destination: DiagnosisView()) {
                        Label("Diagnose Disease", systemImage: "cross.case.fill")
                    }
                    
                    Button(action: { isShowingAddPlantSheet = true }) {
                        Label("Identify a Plant", systemImage: "camera.viewfinder")
                    }
                    .foregroundColor(.primary)
                }
                
                // Section for Environment
                Section(header: Text("Environment")) {
                    NavigationLink(destination: LightMeterView()) {
                        Label("Light Meter", systemImage: "sun.max.fill")
                    }
                    
                    // NEW TOOL ADDED HERE
                    NavigationLink(destination: HumidityCalculatorView()) {
                        Label("Humidity Guide", systemImage: "humidity.fill")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Tools")
            .sheet(isPresented: $isShowingAddPlantSheet) {
                AddPlantView()
            }
        }
    }
}

#Preview {
    ToolsView()
}
