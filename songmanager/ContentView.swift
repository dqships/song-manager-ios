//
//  ContentView.swift
//  songmanager
//
//  Created by DaQuan Louden on 11/27/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: AppStateViewModel
    @ObservedObject private var subscriptionService: SubscriptionService
    @EnvironmentObject private var playbackController: MusicPlaybackController

    init(viewModel: AppStateViewModel, subscriptionService: SubscriptionService) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.subscriptionService = subscriptionService
    }

    var body: some View {
        Group {
            if viewModel.profile.hasCompletedOnboarding {
                AppShellView(viewModel: viewModel)
            } else {
                OnboardingFlowView(viewModel: viewModel)
            }
        }
        .environmentObject(subscriptionService)
        .environmentObject(playbackController)
    }
}
