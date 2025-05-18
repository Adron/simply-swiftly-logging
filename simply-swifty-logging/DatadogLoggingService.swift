//
//  DatadogLoggingService.swift
//  simply-swifty-logging
//
//  Created by Adron Hall on 5/17/25.
//

import Foundation
import DatadogCore
import DatadogLogs
import DatadogRUM
import SwiftUI

class DatadogLoggingService: ObservableObject {
    static let shared = DatadogLoggingService()
    private let logger: any DatadogLogs.LoggerProtocol
    var onLogSent: ((String) -> Void)?
    
    private init() {
        // Initialize Datadog first
        Datadog.initialize(
            with: Datadog.Configuration(
                clientToken: Config.Datadog.clientToken,
                env: Config.Datadog.environment,
                site: .us5,  // Explicitly set the Datadog site
                service: Config.Datadog.service
            ),
            trackingConsent: .granted
        )
        
        // Enable debug logging
        Datadog.verbosityLevel = .debug
        
        // Initialize Logs
        DatadogLogs.Logs.enable(
            with: DatadogLogs.Logs.Configuration(
                eventMapper: nil
            )
        )
        
        // Initialize RUM
        DatadogRUM.RUM.enable(
            with: DatadogRUM.RUM.Configuration(
                applicationID: Config.Datadog.applicationId,
                longTaskThreshold: 0.1,
                viewEventMapper: nil
            )
        )
        
        // Create a logger instance after Datadog is initialized
        logger = DatadogLogs.Logger.create(
            with: DatadogLogs.Logger.Configuration(
                name: "simply-swifty-logging",
                networkInfoEnabled: true,
                consoleLogFormat: .short
            )
        )
        
        // Log initial connection
        logger.info("Datadog SDK initialized and connected", attributes: [
            "service": "simply-swifty-logging",
            "environment": "development"
        ] as [String: any Encodable])
    }
    
    func logMessage(_ message: String, level: LogLevel = .info) {
        let attributes: [String: any Encodable] = [
            "source": "ui_scroll_view",
            "timestamp": Date().timeIntervalSince1970
        ]
        
        switch level {
        case .debug:
            logger.debug(message, attributes: attributes)
        case .info:
            logger.info(message, attributes: attributes)
        case .notice:
            logger.notice(message, attributes: attributes)
        case .warning:
            logger.warn(message, attributes: attributes)
        case .error:
            logger.error(message, attributes: attributes)
        case .critical:
            logger.critical(message, attributes: attributes)
        }
        
        // Notify that a log was sent
        let timestamp = Date().formatted(date: .omitted, time: .standard)
        onLogSent?("📤 Datadog Log Sent [\(timestamp)] - Level: \(level.rawValue)")
        
        // Track as RUM event
        let rum = DatadogRUM.RUMMonitor.shared()
        rum.addAction(
            type: .custom,
            name: "message_displayed",
            attributes: [
                "message": message,
                "level": level.rawValue
            ] as [String: any Encodable]
        )
    }
    
    func logError(_ error: Error, context: String) {
        logger.error(
            "Error occurred: \(error.localizedDescription)",
            attributes: [
                "context": context,
                "error_type": String(describing: type(of: error)),
                "timestamp": Date().timeIntervalSince1970
            ] as [String: any Encodable]
        )
        
        // Track error in RUM
        let rum = DatadogRUM.RUMMonitor.shared()
        rum.addError(
            error: error,
            source: .custom,
            attributes: [
                "context": context
            ] as [String: any Encodable]
        )
    }
}

// Log level enum
enum LogLevel: String {
    case debug
    case info
    case notice
    case warning
    case error
    case critical
}

// SwiftUI View Modifier for RUM tracking
struct RUMViewModifier: ViewModifier {
    let name: String
    @StateObject private var loggingService = DatadogLoggingService.shared
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                let rum = DatadogRUM.RUMMonitor.shared()
                rum.startView(
                    key: name,
                    name: name,
                    attributes: [:] as [String: any Encodable]
                )
            }
            .onDisappear {
                let rum = DatadogRUM.RUMMonitor.shared()
                rum.stopView(key: name)
            }
    }
}

// SwiftUI View extension for easy RUM tracking
extension View {
    func trackRUMView(name: String) -> some View {
        modifier(RUMViewModifier(name: name))
    }
}

