//
//  File.swift
//
//
//  Created by Valentin Radu on 07/04/2022.
//

import Foundation

public typealias Send = (any Action) async throws -> Void

private struct SendKey: EnvironmentKey {
    public static var defaultValue: Send = { _ in }
}

public extension EnvironmentValues {
    internal(set) var send: Send {
        get { self[SendKey.self] }
        set { self[SendKey.self] = newValue }
    }
}

public struct Bootstrap<I>
    where I: Service
{
    private let rootHashValue = AnyHashable(UUID())
    private var _items: I
    public init(@ServiceBuilder _ itemsBuilder: () -> I) async throws {
        _items = itemsBuilder()
        var environment = EnvironmentValues()
        environment.send = send
        try await _items
            .inject(environment: environment,
                    from: rootHashValue)
    }

    public func send(action: any Action) async throws {
        try await _items.send(action: action,
                              from: rootHashValue)
    }
}
