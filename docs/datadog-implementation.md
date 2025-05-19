# Datadog Implementation Guide

## Overview
This document provides a comprehensive guide to implementing Datadog logging and RUM tracking in the simply-swifty-logging application.

## Implementation Steps

### 1. Project Setup

#### 1.1 Add Dependencies
Add Datadog SDK dependencies using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/DataDog/dd-sdk-ios", from: "2.27.0")
]
```

Required packages:
- DatadogCore
- DatadogLogs
- DatadogRUM
- DatadogCrashReporting

#### 1.2 Environment Configuration
Create a configuration file to manage environment variables:

```swift
enum Config {
    enum Datadog {
        static let clientToken: String = {
            guard let token = ProcessInfo.processInfo.environment["DATADOG_CLIENT_TOKEN"] else {
                fatalError("DATADOG_CLIENT_TOKEN environment variable is not set")
            }
            return token
        }()
        
        static let applicationId: String = {
            guard let id = ProcessInfo.processInfo.environment["DATADOG_APPLICATION_ID"] else {
                fatalError("DATADOG_APPLICATION_ID environment variable is not set")
            }
            return id
        }()
        
        static let environment: String = {
            ProcessInfo.processInfo.environment["DATADOG_ENVIRONMENT"] ?? "development"
        }()
        
        static let service: String = {
            ProcessInfo.processInfo.environment["DATADOG_SERVICE"] ?? "simply-swifty-logging"
        }()
    }
}
```

### 2. Logging Service Implementation

#### 2.1 Create Logging Service
```swift
class DatadogLoggingService: ObservableObject {
    static let shared = DatadogLoggingService()
    private let logger: any DatadogLogs.LoggerProtocol
    var onLogSent: ((String) -> Void)?
    
    private init() {
        // Initialize Datadog
        Datadog.initialize(
            with: Datadog.Configuration(
                clientToken: Config.Datadog.clientToken,
                env: Config.Datadog.environment,
                site: .us5,
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
        
        // Create logger instance
        logger = DatadogLogs.Logger.create(
            with: DatadogLogs.Logger.Configuration(
                name: "simply-swifty-logging",
                networkInfoEnabled: true,
                consoleLogFormat: .short
            )
        )
    }
}
```

#### 2.2 Implement Logging Methods
```swift
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
    rum.addAction(
        type: .custom,
        name: "message_displayed",
        attributes: [
            "message": message,
            "level": level.rawValue
        ] as [String: any Encodable]
    )
}
```

### 3. RUM Implementation

#### 3.1 Create View Modifier
```swift
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
```

#### 3.2 Add View Extension
```swift
extension View {
    func trackRUMView(name: String) -> some View {
        modifier(RUMViewModifier(name: name))
    }
}
```

### 4. UI Implementation

#### 4.1 Create Content View
```swift
struct ContentView: View {
    @State private var isRunning = false
    @State private var messages: [String] = []
    @State private var heartbeatTimer: Timer?
    @State private var eventTimer: Timer?
    @StateObject private var loggingService = DatadogLoggingService.shared
    
    var body: some View {
        VStack {
            // UI implementation
        }
        .trackRUMView(name: "ContentView")
    }
}
```

#### 4.2 Implement Event Generation
```swift
private func startTimers() {
    // Heartbeat timer
    heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
        let timestamp = Date().formatted(date: .omitted, time: .standard)
        let message = "Tick - [\(timestamp)]"
        messages.append(message)
        loggingService.logMessage(message, level: .debug)
    }
    
    // Event timer
    func scheduleNextEvent() {
        eventTimer?.invalidate()
        eventTimer = Timer.scheduledTimer(withTimeInterval: Double.random(in: 1...8), repeats: false) { _ in
            generateEvent()
            scheduleNextEvent()
        }
    }
    
    scheduleNextEvent()
}
```

### 5. Error Handling

#### 5.1 Implement Error Logging
```swift
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
```

### 6. Testing

#### 6.1 Unit Tests
```swift
func testLoggingService() {
    let service = DatadogLoggingService.shared
    let expectation = XCTestExpectation(description: "Log message")
    
    service.onLogSent = { message in
        XCTAssertNotNil(message)
        expectation.fulfill()
    }
    
    service.logMessage("Test message")
    wait(for: [expectation], timeout: 5.0)
}
```

#### 6.2 UI Tests
```swift
func testContentView() {
    let app = XCUIApplication()
    app.launch()
    
    let startButton = app.buttons["Start"]
    startButton.tap()
    
    // Verify logging
    let logMessage = app.staticTexts["Tick"]
    XCTAssertTrue(logMessage.exists)
}
```

## Best Practices

### 1. Configuration
- Use environment variables for sensitive data
- Implement proper error handling
- Use appropriate log levels
- Include relevant context

### 2. Performance
- Minimize logging overhead
- Use appropriate sampling rates
- Batch logs when possible
- Monitor memory usage

### 3. Security
- Never log sensitive data
- Use appropriate log levels
- Implement proper error handling
- Follow data retention policies

### 4. Maintenance
- Regular SDK updates
- Monitor log volume
- Review log levels
- Update retention policies

## Troubleshooting

### 1. Common Issues
- Missing logs
- Performance issues
- Memory leaks
- Configuration errors

### 2. Solutions
- Verify configuration
- Check network connectivity
- Monitor memory usage
- Review log levels

## Conclusion
This implementation provides a foundation for logging and monitoring in iOS applications using Datadog. By following these steps and best practices, you can ensure effective monitoring and debugging capabilities in your application.

## References
- [Datadog iOS SDK Documentation](https://docs.datadoghq.com/real_user_monitoring/ios/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [iOS Best Practices](https://docs.datadoghq.com/real_user_monitoring/ios/best_practices/) 