// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

/// Protocol for screens that can be encoded and decoded for state restoration
public protocol StatePersistable: Codable {
    /// Unique identifier for the screen type
    static var stateIdentifier: String { get }
    
    /// Creates a JumperScreen from the persisted state
    func createScreen() -> any JumperScreen
}

/// Represents the state of a coordinator
public struct JumperState: Codable {
    /// The navigation path state
    public var pathRepresentation: NavigationPath.CodableRepresentation?
    
    /// The presented sheet screen state
    private var _sheetScreen: SheetState?
    
    /// The presented full screen cover state
    private var _fullScreenCover: FullScreenState?
    
    private struct SheetState: Codable {
        let identifier: String
        let data: Data
    }
    
    private struct FullScreenState: Codable {
        let identifier: String
        let data: Data
    }
    
    public var sheetScreen: (identifier: String, data: Data)? {
        get {
            guard let state = _sheetScreen else { return nil }
            return (state.identifier, state.data)
        }
        set {
            if let newValue = newValue {
                _sheetScreen = SheetState(identifier: newValue.identifier, data: newValue.data)
            } else {
                _sheetScreen = nil
            }
        }
    }
    
    public var fullScreenCover: (identifier: String, data: Data)? {
        get {
            guard let state = _fullScreenCover else { return nil }
            return (state.identifier, state.data)
        }
        set {
            if let newValue = newValue {
                _fullScreenCover = FullScreenState(identifier: newValue.identifier, data: newValue.data)
            } else {
                _fullScreenCover = nil
            }
        }
    }
    
    public init(
        pathRepresentation: NavigationPath.CodableRepresentation? = nil,
        sheetScreen: (identifier: String, data: Data)? = nil,
        fullScreenCover: (identifier: String, data: Data)? = nil
    ) {
        self.pathRepresentation = pathRepresentation
        self.sheetScreen = sheetScreen
        self.fullScreenCover = fullScreenCover
    }
    
    // MARK: - Codable
    
    private enum CodingKeys: String, CodingKey {
        case pathRepresentation
        case sheetScreen
        case fullScreenCover
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        pathRepresentation = try container.decodeIfPresent(NavigationPath.CodableRepresentation.self, forKey: .pathRepresentation)
        _sheetScreen = try container.decodeIfPresent(SheetState.self, forKey: .sheetScreen)
        _fullScreenCover = try container.decodeIfPresent(FullScreenState.self, forKey: .fullScreenCover)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(pathRepresentation, forKey: .pathRepresentation)
        try container.encodeIfPresent(_sheetScreen, forKey: .sheetScreen)
        try container.encodeIfPresent(_fullScreenCover, forKey: .fullScreenCover)
    }
}

/// Protocol for coordinators that support state restoration
public protocol StateRestorable {
    /// Saves the current state
    /// - Returns: The encoded state
    func saveState() -> JumperState
    
    /// Restores from a saved state
    /// - Parameter state: The state to restore from
    func restore(from state: JumperState)
}

extension SwiftUICoordinator {
    /// Saves the current navigation state
    public func saveState() -> JumperState {
        // Save sheet screen
        var savedSheetScreen: (String, Data)? = nil
        if let screen = sheetScreen as? any StatePersistable,
           let data = try? JSONEncoder().encode(screen) {
            savedSheetScreen = (type(of: screen).stateIdentifier, data)
        }
        
        // Save full screen cover
        var savedFullScreenCover: (String, Data)? = nil
        if let screen = fullScreenCover as? any StatePersistable,
           let data = try? JSONEncoder().encode(screen) {
            savedFullScreenCover = (type(of: screen).stateIdentifier, data)
        }
        
        return JumperState(
            pathRepresentation: path.codable,
            sheetScreen: savedSheetScreen,
            fullScreenCover: savedFullScreenCover
        )
    }
    
    /// Restores the coordinator state
    public func restore(from state: JumperState) {
        // Clear current state
        path = state.pathRepresentation.map(NavigationPath.init) ?? NavigationPath()
        sheetScreen = nil
        fullScreenCover = nil
        
        // Restore sheet screen
        if let (identifier, data) = state.sheetScreen,
           let screen = restoreScreen(from: data, identifier: identifier) {
            present(screen)
        }
        
        // Restore full screen cover
        if let (identifier, data) = state.fullScreenCover,
           let screen = restoreScreen(from: data, identifier: identifier) {
            present(screen)
        }
    }
    
    /// Restores a screen from saved data
    /// - Parameters:
    ///   - data: The encoded screen data
    ///   - identifier: The screen type identifier
    /// - Returns: The restored screen if successful
    private func restoreScreen(from data: Data, identifier: String) -> (any JumperScreen)? {
        // This should be implemented by concrete coordinator subclasses
        return nil
    }
} 