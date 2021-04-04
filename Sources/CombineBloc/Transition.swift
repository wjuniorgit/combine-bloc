//
//  Transition.swift
//  
//
//  Created by Wellington Soares on 23/03/21.
//

public struct Transition<Event: Equatable, State: Equatable>: Equatable {
    public let currentState: State
    public let event: Event?
    public let nextState: State
}
