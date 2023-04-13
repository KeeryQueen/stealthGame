//
//  SceneDelegate.swift
//  Stock
//
//  Created by 張永霖 on 2021/5/6.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = UINavigationController(rootViewController: StockListVC())
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScen