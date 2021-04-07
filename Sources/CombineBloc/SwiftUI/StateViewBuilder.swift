//
//  StateViewBuilder.swift
//
//
//  Created by Wellington Soares on 23/03/21.
//

import Combine
import SwiftUI

/// A `StateViewBuilder` is a`View` that is reconstruted every time a new `State` is received from a `Bloc`.
public struct StateViewBuilder<Event: Equatable, BlocState: Equatable, Content: View>: View {
    var publisher: AnyPublisher<BlocState, Never>
    @State var state: BlocState
    private let builder: (BlocState) -> Content
    private let animation: Animation?

    public var body: some View {
        builder(self.state).onReceive(publisher, perform: {
            state in
            withAnimation(self.animation) {
                self.state = state
            }
        })
    }

    /// Initializes a `StateViewBuilder` from a selected `Bloc` and a `View` builder closure to be recreated on each new `State`.
    ///
    /// - Parameters:
    ///   - bloc: The `Bloc` to listen for every new `State`.
    ///   - animation: An animation sequence performed when the `State` changes.
    ///   - builder: A closure to be recreated on each new `State`.
    public init(
        bloc: Bloc<Event, BlocState>,
        animation: Animation? = .default,
        @ViewBuilder builder: @escaping (BlocState) -> Content
    ) {
        self.init(publisher: bloc.publisher, value: bloc.value, animation: animation, builder: builder)
    }

    /// Initializes a `StateViewBuilder` from a selected `State` publisher and a `View` builder closure to be recreated on each new `State`.
    ///
    /// - Parameters:
    ///   - publisher: The `State` publisher to listen for every new `State`.
    ///   - animation: An animation sequence performed when the `State` changes.
    ///   - builder: A closure to be recreated on each new `State`.
    public init(publisher: AnyPublisher<BlocState, Never>, value: BlocState, animation: Animation? = .default, @ViewBuilder builder: @escaping (BlocState) -> Content) {
        self.publisher = publisher
        self.builder = builder
        _state = State(initialValue: value)
        self.animation = animation
    }
}
