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

class DatadogLoggingService {
    static let shared = DatadogLoggingService()
    private let logger: any DatadogLogs.LoggerProtocol
    
    private init() {
        // Create a logger instance
        logger = DatadogLogs.Logger.create(
            with: DatadogLogs.Logger.Configuration(
                name: "simply-swifty-logging",
                networkInfoEnabled: true,
                consoleLogFormat: .short
            )
        )
        setupDatadog()
    }
    
    private func setupDatadog() {
        // Initialize Datadog
        Datadog.initialize(
            with: Datadog.Configuration(
                clientToken: "pub28d62b08073738b84c86ac2bb7dfc0c8",
                env: "development",
                service: "simply-swifty-logging"
            ),
            trackingConsent: .granted
        )
        
        // Initialize Logs
        DatadogLogs.Logs.enable(
            with: DatadogLogs.Logs.Configuration(
                eventMapper: nil
            )
        )
        
        // Initialize RUM
        DatadogRUM.RUM.enable(
            with: DatadogRUM.RUM.Configuration(
                applicationID: "ad4f70c6-4947-4aba-83db-1eda66d5b599",
                uiKitViewsPredicate: DefaultUIKitRUMViewsPredicate(),
                uiKitActionsPredicate: DefaultUIKitRUMActionsPredicate(),
                longTaskThreshold: 0.1,
                viewEventMapper: nil
            )
        )
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
        
        // Track as RUM event
        let rum = DatadogRUM.RUMMonitor.shared()
        rum.addUserAction(
            type: .custom,
            name: "message_displayed",
            attributes: [
                "message": message,
                "level": level.rawValue
            ]
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
            ]
        )
    }
    
    func startViewTracking(viewName: String) {
        let rum = DatadogRUM.RUMMonitor.shared()
        rum.startView(
            key: viewName,
            name: viewName,
            attributes: [:]
        )
    }
    
    func stopViewTracking() {
        let rum = DatadogRUM.RUMMonitor.shared()
        rum.stopView()
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

