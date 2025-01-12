//
//  SceneDelegateTests.swift
//  EssentialApp
//
//  Created by Kouv on 12/01/2025.
//
import XCTest
import EssentialFeediOS
@testable import EssentialApp

final class SceneDelegateTests:XCTestCase {
    func test_sceneWillConnectToSession_configuresRootViewController() {
        let sut = SceneDelegate()
        sut.window = UIWindow()
        sut.configureWindow()
        
        let root = sut.window?.rootViewController as? UINavigationController
        
        let topController = root?.topViewController
        
        XCTAssertNotNil(root,"Expected the view controller to be encapsulated in navigation controller")
        XCTAssertTrue(topController is FeedViewController, "Expected the main view controller to be feed view controlle but got \(String(describing:topController)) instead")
    }
    
}
