//
//  CMAITwinApp.swift
//  CMAITwin
//
//  Created by Anderen on 22.06.2025.
//

import SwiftUI

@main
struct CMAITwinApp: App {

    @StateObject private var sessionService = SessionService(client: APIClient.shared)

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.sessionService, sessionService)
        }
    }

}
