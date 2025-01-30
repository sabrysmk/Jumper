// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

/// Main coordinator that manages the application's root navigation structure
/// Responsibilities:
/// - Manages authentication state
/// - Controls tab navigation
/// - Handles deep linking
final class MainCoordinator: SwiftUICoordinator {
    
    // MARK: - State
    
    /// Represents the main navigation tabs in the application
    enum Tab: Int, TabItem {
        case home
        case search
        case profile
        
        var title: String {
            switch self {
            case .home: return "Home"
            case .search: return "Search"
            case .profile: return "Profile"
            }
        }
        
        var systemImage: String {
            switch self {
            case .home: return "house.fill"
            case .search: return "magnifyingglass"
            case .profile: return "person.fill"
            }
        }
        
        var tag: Int { rawValue }
        var id: String { title }
    }
    
    /// Tracks whether the user is authenticated
    @Published private(set) var isAuthenticated: Bool = false
    
    // MARK: - Child Coordinators
    
    private lazy var tabCoordinator: TabCoordinator<Tab> = {
        let coordinator = TabCoordinator<Tab>(initialTab: .home)
        
        // Add Home coordinator
        coordinator.addChild(HomeCoordinator(), for: .home)
        
        // Add Search coordinator
        coordinator.addChild(SearchCoordinator(), for: .search)
        
        // Add Profile coordinator with logout handling
        let profileCoordinator = ProfileCoordinator()
        profileCoordinator.onLogout = { [weak self] in
            self?.isAuthenticated = false
        }
        coordinator.addChild(profileCoordinator, for: .profile)
        
        return coordinator
    }()
    
    private lazy var authCoordinator: AuthCoordinator = {
        let coordinator = AuthCoordinator()
        coordinator.onAuthenticated = { [weak self] in
            self?.isAuthenticated = true
        }
        return coordinator
    }()
    
    // MARK: - Root View
    
    override func makeRootView() -> AnyView {
        AnyView(
            Group {
                if isAuthenticated {
                    tabCoordinator.makeRootView()
                        .withCoordinator(tabCoordinator)
                } else {
                    authCoordinator.makeRootView()
                        .withCoordinator(authCoordinator)
                }
            }
        )
    }
} 