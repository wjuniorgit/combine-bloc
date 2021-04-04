//
//  BlocViewBuilder.swift
//
//
//  Created by Wellington Soares on 23/03/21.
//

import SwiftUI
import Combine

public struct BlocViewBuilder<Event:Equatable, BlocState:Equatable, Content: View>: View {

    var publisher: AnyPublisher<BlocState, Never>
    @State var state: BlocState
    private let builder: (BlocState) -> Content
    private let animation: Animation?

    public var body: some View {
        return builder(self.state).onReceive(publisher, perform: {
            state in
            withAnimation(self.animation) {
                self.state = state
            }
        })
    }
    public init(
        bloc: Bloc<Event, BlocState>,
        @ViewBuilder builder: @escaping (BlocState) -> Content,
        animation: Animation? = .default
    ) {
        self.init(publisher: bloc.publisher, value: bloc.value, builder: builder, animation: animation)
    }

    public init(publisher: AnyPublisher<BlocState, Never>, value: BlocState, @ViewBuilder builder: @escaping (BlocState) -> Content,
                animation: Animation? = .default
    ) {
        self.publisher = publisher
        self.builder = builder
        _state = State(initialValue: value)
        self.animation = animation
    }
}
