import Foundation
import SwiftUI

// A simple structure to hold the decoded response from Gemini
struct PlantIdentificationResult: Decodable {
    let speciesName: String
    let commonName: String
    let careGuide: CareGuideResult
}

struct CareGuideResult: Decodable {
    let watering: String
    let light: String
    let temperature: String
}

struct PlantDiagnosisResult: Decodable {
    let condition: String // e.g., "Spider Mites" or "Healthy"
    let description: String
    let potentialCauses: [String]
    let treatmentSteps: [TreatmentStep]
}

struct TreatmentStep: Decodable, Hashable {
    let step: Int
    let instruction: String
}


class GeminiService {
    
    static let shared = GeminiService()
    private let apiKey = "AIzaSyDeKZRT21892LO6NjoSWdWgq3OfXeiOG1c" // <<<--- ВСТАВЬТЕ СВОЙ КЛЮЧ СЮДА
    private let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent"
    
    private init() {}
    
    func diagnoseDisease(from imageData: Data) async throws -> PlantDiagnosisResult {
        guard let url = URL(string: "\(urlString)?key=\(apiKey)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let base64Image = imageData.base64EncodedString()
        
        // A new, very specific prompt for diagnosis
        let prompt = """
        You are an expert plant pathologist. Analyze the plant in this image for any signs of disease, pests, or nutrient deficiencies.
        Provide the response strictly in the following JSON format, and nothing else.
        If the plant appears healthy, state that in the condition field.

        {
          "condition": "Name of the disease or pest, or 'Healthy'",
          "description": "A brief, one-sentence description of the issue.",
          "potentialCauses": [
            "A list of possible causes, e.g., 'Low humidity', 'Overwatering'."
          ],
          "treatmentSteps": [
            { "step": 1, "instruction": "First treatment step." },
            { "step": 2, "instruction": "Second treatment step." },
            { "step": 3, "instruction": "Third treatment step." }
          ]
        }
        """
        
        let requestBody: [String: Any] = [
            "contents": [ "parts": [ ["text": prompt], ["inline_data": ["mime_type": "image/jpeg", "data": base64Image]] ] ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // The decoding logic is the same as before
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        guard let textPart = geminiResponse.candidates.first?.content.parts.first?.text,
              let jsonData = textPart.data(using: .utf8) else {
            throw URLError(.cannotParseResponse)
        }
        
        let finalResult = try JSONDecoder().decode(PlantDiagnosisResult.self, from: jsonData)
        return finalResult
    }
    
    func listAvailableModels() async {
        // ВАЖНО: URL для списка моделей отличается!
        let listModelsURLString = "https://generativelanguage.googleapis.com/v1beta/models?key=\(apiKey)"
        
        guard let url = URL(string: listModelsURLString) else {
            print("Invalid URL for listing models")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let errorBody = String(data: data, encoding: .utf8) ?? "No response body"
                print("Error listing models. Status code: \((response as? HTTPURLResponse)?.statusCode ?? 0). Body: \(errorBody)")
                return
            }
            
            // Попробуем распечатать "сырой" JSON, чтобы увидеть все детали
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
               let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
               let prettyPrintedString = String(data: prettyData, encoding: .utf8) {
                print("--- Available Models ---")
                print(prettyPrintedString)
                print("----------------------")
            } else {
                print("Could not parse the JSON response for models list.")
            }
            
        } catch {
            print("An error occurred while fetching the models list: \(error)")
        }
    }
    
    func identifyPlant(from imageData: Data) async throws -> PlantIdentificationResult {
        guard let url = URL(string: "\(urlString)?key=\(apiKey)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let base64Image = imageData.base64EncodedString()
        
        // This is the prompt. It's crucial for getting a good, structured response.
        let prompt = """
        You are an expert botanist. Identify the plant in this image.
        Provide the response strictly in the following JSON format, and nothing else.
        If the image is not a plant, provide a JSON with empty strings.

        {
          "speciesName": "Scientific Species Name",
          "commonName": "Common Name",
          "careGuide": {
            "watering": "Brief watering instructions, e.g., 'Water every 7-10 days'",
            "light": "Brief light requirements, e.g., 'Bright \n indirect light'",
            "temperature": "Brief ideal temperature range, e.g., '18-24°C'"
          }
        }
        """

        let requestBody: [String: Any] = [
            "contents": [
                "parts": [
                    ["text": prompt],
                    [
                        "inline_data": [
                            "mime_type": "image/jpeg",
                            "data": base64Image
                        ]
                    ]
                ]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            print("Error: Invalid response or status code")
            // For debugging, print the raw response
            print(String(data: data, encoding: .utf8) ?? "No response body")
            throw URLError(.badServerResponse)
        }
        
        // Gemini nests its JSON response, so we need to decode it in two steps.
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        guard let textPart = geminiResponse.candidates.first?.content.parts.first?.text else {
            throw URLError(.cannotParseResponse)
        }

        // Now, decode the JSON string that Gemini returned into our PlantIdentificationResult struct.
        guard let jsonData = textPart.data(using: .utf8) else {
            throw URLError(.cannotParseResponse)
        }
        
        let finalResult = try JSONDecoder().decode(PlantIdentificationResult.self, from: jsonData)
        
        return finalResult
    }
}

// Codable structs to parse the raw Gemini API response
private struct GeminiResponse: Decodable {
    let candidates: [Candidate]
}

private struct Candidate: Decodable {
    let content: Content
}

private struct Content: Decodable {
    let parts: [Part]
}

private struct Part: Decodable {
    let text: String
}
