// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

public class MainTabCoordinator: TabCoordinator<AppTab> {
    public init() {
        super.init(initialTab: .home)
        setupTabs()
    }
    
    private func setupTabs() {
        // Home tab
        let homeCoordinator = AuthCoordinator()
        addChild(homeCoordinator, for: .home)
        
        // Profile tab
        let profileCoordinator = SwiftUICoordinator()
        addChild(profileCoordinator, for: .profile)
        
        // Settings tab
        let settingsCoordinator = SwiftUICoordinator()
        addChild(settingsCoordinator, for: .settings)
    }
} 