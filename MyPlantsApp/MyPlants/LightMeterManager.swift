import Foundation
import AVFoundation
import CoreImage
import SwiftUI // For Color

// We create a struct to hold more detailed info about the light level
struct LightReading {
    var level: LightLevel
    var value: Double // The raw brightness value from the camera
    var description: String
    var recommendedFor: String // Example plants
    var color: Color
    
    // Default state
    static let undetermined = LightReading(
        level: .undetermined,
        value: 0.0,
        description: "Point your camera towards a light source or plant location.",
        recommendedFor: "Unknown",
        color: .gray
    )
}

// Enum for discrete light levels
enum LightLevel: String {
    case undetermined = "Undetermined"
    case low = "Low Light"
    case medium = "Medium Light"
    case brightIndirect = "Bright, Indirect Light"
    case directSun = "Direct Sunlight"
}

class LightMeterManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @Published var reading: LightReading = .undetermined
    
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    
    override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        sessionQueue.async { [weak self] in
            guard let self = self,
                  let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device) else { return }
            
            if self.captureSession.canAddInput(input) {
                self.captureSession.addInput(input)
            }
            
            self.videoOutput.setSampleBufferDelegate(self, queue: self.sessionQueue)
            if self.captureSession.canAddOutput(self.videoOutput) {
                self.captureSession.addOutput(self.videoOutput)
            }
        }
    }
    
    func start() {
        sessionQueue.async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stop() {
        sessionQueue.async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let metadata = CMCopyDictionaryOfAttachments(allocator: nil, target: sampleBuffer, attachmentMode: kCMAttachmentMode_ShouldPropagate) as? [String: Any],
              let exifMetadata = metadata[kCGImagePropertyExifDictionary as String] as? [String: Any],
              let brightnessValue = exifMetadata[kCGImagePropertyExifBrightnessValue as String] as? Double else {
            return
        }
        
        var newReading: LightReading
        
        // Remapped values for better sensitivity
        if brightnessValue < -3.0 {
            newReading = LightReading(level: .low, value: brightnessValue, description: "Suitable for shade-loving plants.", recommendedFor: "ZZ Plant, Snake Plant", color: .blue)
        } else if brightnessValue < 0.0 {
            newReading = LightReading(level: .medium, value: brightnessValue, description: "Good for most common houseplants.", recommendedFor: "Pothos, Philodendron", color: .green)
        } else if brightnessValue < 3.0 {
            newReading = LightReading(level: .brightIndirect, value: brightnessValue, description: "Ideal for plants needing lots of light but not direct sun.", recommendedFor: "Fiddle Leaf Fig, Monstera", color: .orange)
        } else {
            newReading = LightReading(level: .directSun, value: brightnessValue, description: "Best for sun-loving plants like succulents.", recommendedFor: "Cacti, Aloe Vera", color: .red)
        }
        
        DispatchQueue.main.async {
            self.reading = newReading
        }
    }
}
