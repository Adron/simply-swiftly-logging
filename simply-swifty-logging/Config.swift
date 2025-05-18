import Foundation

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
    
    enum App {
        static let developmentTeam: String = {
            guard let team = ProcessInfo.processInfo.environment["APPLE_DEVELOPMENT_TEAM"] else {
                fatalError("APPLE_DEVELOPMENT_TEAM environment variable is not set")
            }
            return team
        }()
    }
} 