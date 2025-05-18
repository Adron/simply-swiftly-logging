//
//  ContentView.swift
//  simply-swifty-logging
//
//  Created by Adron Hall on 5/9/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isRunning = false
    @State private var messages: [String] = []
    @State private var heartbeatTimer: Timer?
    @State private var eventTimer: Timer?
    
    private let eventMessages = [
        "Working.",
        "Operational deviation.",
        "Shifted.",
        "Work Completed - %@"
    ]
    
    private func generateEvent() {
        let uuid = UUID().uuidString
        let timestamp = Date().formatted(date: .omitted, time: .standard)
        let randomMessage = eventMessages.randomElement() ?? "Working."
        let formattedMessage = randomMessage.contains("%@") ? 
            String(format: randomMessage, timestamp) : 
            randomMessage
        let message = "Event: [\(uuid)] - \(formattedMessage)"
        messages.append(message)
        DatadogLoggingService.shared.logMessage(message, level: .info)
    }
    
    private func startTimers() {
        // Heartbeat timer - every 5 seconds
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            let timestamp = Date().formatted(date: .omitted, time: .standard)
            let message = "Tick - [\(timestamp)]"
            messages.append(message)
            DatadogLoggingService.shared.logMessage(message, level: .debug)
        }
        
        // Event timer - random interval between 1-8 seconds
        func scheduleNextEvent() {
            eventTimer?.invalidate()
            eventTimer = Timer.scheduledTimer(withTimeInterval: Double.random(in: 1...8), repeats: false) { _ in
                generateEvent()
                scheduleNextEvent()
            }
        }
        
        scheduleNextEvent()
    }
    
    private func stopTimers() {
        heartbeatTimer?.invalidate()
        eventTimer?.invalidate()
        heartbeatTimer = nil
        eventTimer = nil
    }
    
    var body: some View {
        VStack {
            GroupBox("Log Output") {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(Array(messages.enumerated()), id: \.element) { index, message in
                                Text(message)
                                    .id(index)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .onChange(of: messages.count) { _ in
                        withAnimation {
                            proxy.scrollTo(messages.count - 1, anchor: .bottom)
                        }
                    }
                }
                .frame(maxHeight: .infinity)
            }
            .frame(maxHeight: .infinity)

            HStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Button(isRunning ? "Stop" : "Start") {
                    isRunning.toggle()
                    if isRunning {
                        let message = "Starting."
                        messages.append(message)
                        DatadogLoggingService.shared.logMessage(message, level: .info)
                        startTimers()
                    } else {
                        stopTimers()
                        let message = "Stopped."
                        messages.append(message)
                        DatadogLoggingService.shared.logMessage(message, level: .info)
                    }
                }
            }
        }
        .padding()
        .onAppear {
            DatadogLoggingService.shared.startViewTracking(viewName: "ContentView")
        }
        .onDisappear {
            DatadogLoggingService.shared.stopViewTracking()
        }
    }
}

#Preview {
    ContentView()
}
