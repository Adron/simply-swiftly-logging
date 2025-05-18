//
//  simply_swifty_loggingApp.swift
//  simply-swifty-logging
//
//  Created by Adron Hall on 5/9/25.
//

import SwiftUI
import DatadogCore
import DatadogLogs
import DatadogRUM

@main
struct simply_swifty_loggingApp: App {
    init() {
        // Initialize Datadog through our service
        _ = DatadogLoggingService.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Initialize Datadog
    Datadog.initialize(
        with: Datadog.Configuration(
            clientToken: "YOUR_CLIENT_TOKEN",
            env: "production", 
            service: "simply-swiftly-logging"
        ),
        trackingConsent: .granted
    )
    
    // Initialize Logs
    Logs.enable(
        with: Logs.Configuration(
            eventMapper: nil
        )
    )
    
    return true
}
