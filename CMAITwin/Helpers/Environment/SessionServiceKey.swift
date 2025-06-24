//
//  SessionServiceKey.swift
//  CMAITwin
//
//  Created by Anderen on 23.06.2025.
//

import SwiftUI

private struct SessionServiceKey: EnvironmentKey {
    static let defaultValue: SessionService = SessionService(client: APIClient.shared)
}

extension EnvironmentValues {
    var sessionService: SessionService {
        get { self[SessionServiceKey.self] }
        set { self[SessionServiceKey.self] = newValue }
    }
}
