# Simply Swiftly Logging

> NOTE: I've written a blog entry to more thoroughly detail this example in "[Implementing Datadog in iOS: A SwiftUI vs UIKit Perspective](https://compositecode.blog/2025/05/31/implementing-datadog-in-ios-a-swiftui-vs-uikit-perspective/)"

A Swift-based iOS application demonstrating best practices for implementing Datadog logging and monitoring in iOS applications.

## Overview

Simply Swiftly Logging is a sample iOS application that showcases the integration of Datadog's logging and monitoring capabilities. The application serves as a reference implementation for developers looking to add robust logging and monitoring to their iOS applications.

## Features

- Datadog SDK integration for comprehensive logging
- Real User Monitoring (RUM) implementation
- Crash reporting capabilities
- Environment-based configuration
- Secure environment variable management

## Technical Stack

- Swift 5.0
- iOS 18.0+
- Datadog SDK 2.27.0+
- SwiftUI for UI implementation

## Project Structure

```
simply-swifty-logging/
├── simply-swifty-logging/          # Main application code
├── simply-swifty-loggingTests/     # Unit tests
├── simply-swifty-loggingUITests/   # UI tests
├── docs/                          # Documentation
└── .env.example                   # Environment variables template
```

## Setup Instructions

1. Clone the repository
2. Install dependencies using Swift Package Manager
3. Configure environment variables (see below)
4. Build and run the application

### Environment Configuration

The application requires several environment variables to be set up in Xcode:

1. Open your Xcode project
2. Select your target
3. Go to the "Run" tab
4. Click "Edit Scheme"
5. Select "Run" on the left
6. Click the "Arguments" tab
7. Add the following environment variables:

Required variables:
- `DATADOG_CLIENT_TOKEN`
- `DATADOG_APPLICATION_ID`
- `DATADOG_ENVIRONMENT`
- `DATADOG_SERVICE`
- `APPLE_DEVELOPMENT_TEAM`

## Documentation

Detailed implementation guides and documentation can be found in the `docs/` directory, including:
- Datadog implementation guide
- Environment configuration guide
- Testing procedures

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## Original Content

Adding the environment variables 

![xcode-env-1](https://github.com/user-attachments/assets/1c888b4b-fcbf-4315-a71a-fd7d0353587b)

![xcode-env-2](https://github.com/user-attachments/assets/8ace4ab9-1752-4214-b922-748d763515ee)

Also had to add them via an .env file, just take the existing .env.example and swap out the values for your values.
