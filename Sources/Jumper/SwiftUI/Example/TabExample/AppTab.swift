// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

public enum AppTab: Int, TabItem {
    case home
    case profile
    case settings
    
    public var id: Int { rawValue }
    
    public var title: String {
        switch self {
        case .home:
            return "Home"
        case .profile:
            return "Profile"
        case .settings:
            return "Settings"
        }
    }
    
    public var systemImage: String {
        switch self {
        case .home:
            return "house"
        case .profile:
            return "person"
        case .settings:
            return "gear"
        }
    }
    
    public var tag: Int { rawValue }
} 