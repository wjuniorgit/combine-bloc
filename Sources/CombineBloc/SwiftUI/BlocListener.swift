//
//  BlocListener.swift
//  
//
//  Created by Wellington Soares on 23/03/21.
//

import SwiftUI

public struct BlocListener<Event:Equatable, BlocState:Equatable, Content: View>: View {

    var bloc: Bloc<Event, BlocState>
    private let action: (Transition<Event, BlocState>) -> ()
    private let builder: () -> Content

    public var body: some View {
        return builder().onReceive(bloc.transition, perform: {
            transition in
            action(transition) })
    }

    public init(
        bloc: Bloc<Event, BlocState>,
        action: @escaping (_ transition: Transition<Event, BlocState>) -> (),
        @ViewBuilder builder: @escaping () -> Content

    ) {
        self.bloc = bloc
        self.builder = builder
        self.action = action
    }

}
