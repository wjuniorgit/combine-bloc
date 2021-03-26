//
//  Transition.swift
//  
//
//  Created by Wellington Soares on 23/03/21.
//

public struct Transition<Event: Equatable, State: Equatable>: Equatable {
    let currentState: State
    let event: Event?
    let nextState: State
}
