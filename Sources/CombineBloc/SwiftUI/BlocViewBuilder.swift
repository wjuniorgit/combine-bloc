//
//  BlocViewBuilder.swift
//  
//
//  Created by Wellington Soares on 23/03/21.
//

import SwiftUI

public struct BlocViewBuilder<Event:Equatable, BlocState:Equatable, Content: View>: View {

    var bloc: Bloc<Event, BlocState>
    @State var state: BlocState
    private let builder: (BlocState) -> Content

    public var body: some View {
        return builder(self.state).onReceive(bloc.$state, perform: {
            state in
            self.state = state })
    }
    public init(
        bloc: Bloc<Event, BlocState>,
        @ViewBuilder builder: @escaping (BlocState) -> Content
    ) {
        self.bloc = bloc
        self.builder = builder
        _state = State(initialValue: bloc.state)
    }

}
