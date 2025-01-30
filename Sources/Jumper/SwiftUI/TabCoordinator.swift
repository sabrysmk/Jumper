// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

/// Protocol for tab items that can be used in TabCoordinator
public protocol TabItem: Identifiable, Hashable, Codable {
    /// The title of the tab
    var title: String { get }
    /// The system image name for the tab
    var systemImage: String { get }
    /// The tag value used to identify the tab
    var tag: Int { get }
}

/// A coordinator that manages navigation between tabs and maintains independent navigation stacks
///
/// `TabCoordinator` allows you to organize your app into tabs, where each tab can have its own
/// navigation stack and coordinator. It manages tab selection and state restoration for all tabs.
///
/// Example of basic usage:
/// ```swift
/// // Define your tab items
/// enum AppTab: Int, TabItem {
///     case home
///     case profile
///     case settings
///     
///     var title: String {
///         switch self {
///         case .home: return "Home"
///         case .profile: return "Profile"
///         case .settings: return "Settings"
///         }
///     }
///     
///     var systemImage: String {
///         switch self {
///         case .home: return "house"
///         case .profile: return "person"
///         case .settings: return "gear"
///         }
///     }
///     
///     var tag: Int { rawValue }
/// }
///
/// // Create your tab coordinator
/// class AppTabCoordinator: TabCoordinator<AppTab> {
///     init() {
///         super.init(selectedTab: .home)
///         
///         // Add child coordinators for each tab
///         add(HomeCoordinator(), for: .home)
///         add(ProfileCoordinator(), for: .profile)
///         add(SettingsCoordinator(), for: .settings)
///     }
/// }
/// ```
///
/// Example with deep linking:
/// ```swift
/// extension AppTabCoordinator {
///     func handle(_ deepLink: JumperDeepLink) -> Bool {
///         switch deepLink.components.first {
///         case "profile":
///             // Switch to profile tab and handle deep link
///             selectedTab = .profile
///             return childCoordinators[.profile]?.handle(deepLink) ?? false
///         case "settings":
///             selectedTab = .settings
///             return childCoordinators[.settings]?.handle(deepLink) ?? false
///         default:
///             return childCoordinators[selectedTab]?.handle(deepLink) ?? false
///         }
///     }
/// }
/// ```
///
/// Example with state restoration:
/// ```swift
/// extension AppTabCoordinator {
///     override func saveState() -> Data? {
///         // Save selected tab and child states
///         let state = TabState(
///             selectedTab: selectedTab,
///             childStates: childCoordinators.compactMapValues { $0.saveState() }
///         )
///         return try? JSONEncoder().encode(state)
///     }
/// }
/// ```
open class TabCoordinator<Tab: TabItem>: SwiftUICoordinator {
    /// The currently selected tab
    @Published public var selectedTab: Tab
    
    /// The child coordinators for each tab
    public private(set) var childCoordinators: [Tab: SwiftUICoordinator]
    
    /// Creates a new tab coordinator
    /// - Parameters:
    ///   - initialTab: The initially selected tab
    ///   - parent: The parent coordinator if any
    public init(initialTab: Tab, parent: (any SwiftUICoordinable)? = nil) {
        self.selectedTab = initialTab
        self.childCoordinators = [:]
        super.init(parent: parent)
    }
    
    /// Adds a child coordinator for a specific tab
    /// - Parameters:
    ///   - coordinator: The coordinator to add
    ///   - tab: The tab to associate with the coordinator
    public func addChild(_ coordinator: SwiftUICoordinator, for tab: Tab) {
        coordinator.parent = self
        childCoordinators[tab] = coordinator
    }
    
    /// Removes a child coordinator for a specific tab
    /// - Parameter tab: The tab whose coordinator should be removed
    public func removeChild(for tab: Tab) {
        childCoordinators[tab]?.parent = nil
        childCoordinators.removeValue(forKey: tab)
    }
    
    /// Creates and returns the root view for this coordinator
    public override func makeRootView() -> AnyView {
        AnyView(
            TabCoordinatorView(coordinator: self)
        )
    }
    
    /// Switches to a specific tab
    /// - Parameter tab: The tab to switch to
    public func switchTo(tab: Tab) {
        selectedTab = tab
    }
    
    /// Gets the coordinator for a specific tab
    /// - Parameter tab: The tab to get the coordinator for
    /// - Returns: The coordinator for the tab if it exists
    public func coordinator(for tab: Tab) -> SwiftUICoordinator? {
        childCoordinators[tab]
    }
}

/// Internal view for TabCoordinator to handle the actual TabView
private struct TabCoordinatorView<Tab: TabItem>: View {
    @ObservedObject var coordinator: TabCoordinator<Tab>
    
    var body: some View {
        TabView(selection: Binding(
            get: { coordinator.selectedTab },
            set: { coordinator.selectedTab = $0 }
        )) {
            ForEach(Array(coordinator.childCoordinators.keys)) { tab in
                if let coordinator = coordinator.childCoordinators[tab] {
                    coordinator.makeRootView()
                        .withCoordinator(coordinator)
                        .tabItem {
                            Label(tab.title, systemImage: tab.systemImage)
                        }
                        .tag(tab)
                }
            }
        }
    }
}

// MARK: - State Restoration

extension TabCoordinator {
    /// Additional state for tab coordinator
    private struct TabState: Codable {
        var selectedTab: Tab
        var childStates: [String: Data]
        
        private enum CodingKeys: String, CodingKey {
            case selectedTab
            case childStates 
        }
        
        init(selectedTab: Tab, childStates: [String: Data]) {
            self.selectedTab = selectedTab
            self.childStates = childStates
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            selectedTab = try container.decode(Tab.self, forKey: .selectedTab)
            childStates = try container.decode([String: Data].self, forKey: .childStates)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(selectedTab, forKey: .selectedTab)
            try container.encode(childStates, forKey: .childStates)
        }
    }
    
    func saveTabState() -> JumperState {
        var state = JumperState(pathRepresentation: path.codable)
        
        // Save child coordinators state
        var childStates: [String: Data] = [:]
        for (tab, coordinator) in childCoordinators {
            if let data = try? JSONEncoder().encode(coordinator.saveState()) {
                childStates[String(tab.tag)] = data
            }
        }
        
        // Save tab state
        let tabState = TabState(selectedTab: selectedTab, childStates: childStates)
        if let data = try? JSONEncoder().encode(tabState) {
            state.sheetScreen = ("tabState", data)
        }
        
        return state
    }
    
    func restoreTabState(from state: JumperState) {
        // Restore base state
        restore(from: state)
        
        // Restore tab state
        if let (_, data) = state.sheetScreen,
           let tabState = try? JSONDecoder().decode(TabState.self, from: data) {
            selectedTab = tabState.selectedTab
            
            // Restore child states
            for (tag, stateData) in tabState.childStates {
                if let tab = childCoordinators.keys.first(where: { String($0.tag) == tag }),
                   let coordinator = childCoordinators[tab],
                   let childState = try? JSONDecoder().decode(JumperState.self, from: stateData) {
                    coordinator.restore(from: childState)
                }
            }
        }
    }
} 
