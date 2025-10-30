import SwiftUI
import AVFoundation

struct LightMeterView: View {
    @StateObject private var manager = LightMeterManager()
    
    var body: some View {
        ZStack {
            // Camera feed as the background
//            CameraPreview()
//                .ignoresSafeArea()
//                .blur(radius: 5) // Subtle blur to focus on the UI
//                .opacity(0.8)

            Color.black.opacity(0.4).ignoresSafeArea() // Dark overlay for better text readability

            // Main UI
            VStack {
                Spacer()
                
                // "Viewfinder" circle in the middle
                viewfinder
                
                Spacer()
                
                // Results card at the bottom
                resultsCard
            }
        }
        .onAppear { manager.start() }
        .onDisappear { manager.stop() }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Light Meter")
        .preferredColorScheme(.dark) // Force dark mode for this screen for better aesthetics
    }
    
    private var viewfinder: some View {
        ZStack {
            Circle()
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [10]))
                .foregroundColor(manager.reading.color.opacity(0.8))
                .frame(width: 200, height: 200)

            // A simple animated "scanning" effect
            Circle()
                .trim(from: 0, to: 0.25)
                .stroke(manager.reading.color, lineWidth: 4)
                .frame(width: 190, height: 190)
                .rotationEffect(.degrees(Date().timeIntervalSince1970 * 100)) // Animation
                .animation(.linear(duration: 1), value: Date().timeIntervalSince1970)

            VStack {
                Text(manager.reading.level.rawValue)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(String(format: "%.2f", manager.reading.value))
                    .font(.system(size: 18, weight: .regular, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
    
    private var resultsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Progress bar showing light intensity
            VStack(alignment: .leading) {
                Text("Intensity")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                // Map the brightness value (-5 to 5 range) to a 0-1 progress
                let progress = (manager.reading.value + 5.0) / 10.0
                
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: manager.reading.color))
            }

            // Textual description
            Text(manager.reading.description)
                .font(.body)
                .foregroundColor(.white)
            
            // Recommended plants
            VStack(alignment: .leading, spacing: 4) {
                Text("Good for plants like:")
                    .font(.caption.bold())
                    .foregroundColor(.white.opacity(0.9))
                Text(manager.reading.recommendedFor)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(20)
        .background(.black.opacity(0.5))
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .padding()
    }
}


struct CameraPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)

        // Setup capture session
        let captureSession = AVCaptureSession()
        
        // Find camera
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return view }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return view }
        captureSession.addInput(input)
        
        // Start session on a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }

        // Setup preview layer
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}


#Preview {
    NavigationView {
        LightMeterView()
    }
}
