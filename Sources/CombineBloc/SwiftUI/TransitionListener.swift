//
//  TransitionListener.swift
//
//
//  Created by Wellington Soares on 23/03/21.
//

import SwiftUI

/// A `TransitionListener` is a helper `View` that is able to run a closure every time a `Bloc` creates a new `Transition`.
public struct TransitionListener<Event: Equatable, BlocState: Equatable, Content: View>: View {
    var bloc: Bloc<Event, BlocState>
    private let action: (Transition<Event, BlocState>) -> Void
    private let builder: () -> Content

    public var body: some View {
        builder().onReceive(bloc.transitionSubject, perform: {
            transition in
            action(transition)
        })
    }

    /// Initializes a `TransitionListener` from a selected `Bloc` and action closure to be run on every new `Transition`.
    ///
    /// - Parameters:
    ///   - bloc: The `Bloc` to listen for every new `Transition`.
    ///   - action: A closure that is called every time a new `Transition`is created by the `Bloc`.
    public init(
        bloc: Bloc<Event, BlocState>,
        action: @escaping (_ transition: Transition<Event, BlocState>) -> Void,
        @ViewBuilder builder: @escaping () -> Content

    ) {
        self.bloc = bloc
        self.builder = builder
        self.action = action
    }
}
