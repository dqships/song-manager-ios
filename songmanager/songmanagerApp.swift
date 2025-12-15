//
//  songmanagerApp.swift
//  songmanager
//
//  Created by DaQuan Louden on 11/27/25.
//

import SwiftUI
import RevenueCat
import CoreData

@main
@MainActor
struct songmanagerApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var subscriptionService = SubscriptionService()
    @StateObject private var playbackController = MusicPlaybackController()

    init() {
        SiriShortcutRegistration.refresh()
        guard let apiKey = Self.revenueCatAPIKey() else { return }
        Purchases.configure(withAPIKey: apiKey)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: .live(), subscriptionService: subscriptionService)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(playbackController)
                .tint(.paletteBrick)
        }
    }

    private static func revenueCatAPIKey() -> String? {
        guard let rawValue = Bundle.main.object(forInfoDictionaryKey: "RevenueCatAPIKey") as? String else {
            reportRevenueCatKeyError("RevenueCat API key missing from Info.plist.")
            return nil
        }

        let apiKey = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !apiKey.isEmpty, apiKey.contains("$(") == false else {
            reportRevenueCatKeyError("RevenueCat API key is empty or not substituted; check build settings.")
            return nil
        }

        return apiKey
    }

    private static func reportRevenueCatKeyError(_ message: String) {
        #if DEBUG
        assertionFailure(message)
        #else
        NSLog("%@", message)
        #endif
    }
}
