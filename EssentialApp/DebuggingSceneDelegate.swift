//
//  DebuggingSceneDelegate.swift
//  EssentialApp
//
//  Created by Kouv on 10/01/2025.
//

import Foundation
import UIKit
import EssentialFeed

class DebuggingSceneDelegate:SceneDelegate {
    
    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let _ = (scene as? UIWindowScene) else { return }
        
        if CommandLine.arguments.contains("-reset") {
           try? FileManager.default.removeItem(at: localStoreURL)
        }
        
        super.scene(scene, willConnectTo: session, options: connectionOptions)
        
    }
    
    override func makeRemoteClient() -> HTTPClient {
        
        if UserDefaults.standard.string(forKey: "connectivity") == "offline" {
            return AlwaysFailingHTTPClient()
        }
        return super.makeRemoteClient()
    }
        
    
    private class AlwaysFailingHTTPClient:HTTPClient {
        
        private struct Task:HTTPClientTask {
            func cancel() {
                
            }
        }
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> any EssentialFeed.HTTPClientTask {
            completion(.failure(NSError(domain: "any error", code: 0)))
            return Task()
        }
        
        
    }
    
}
    

