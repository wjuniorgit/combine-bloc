//
//  CombineBLoC.swift
//
//  Created by Wellington Soares on 08/03/21.
//
import Combine

open class CombineBloc<Event, State> where Event: Equatable, State: Equatable {
    public let bloc: Bloc<Event, State>
    public init(state: State, mapEventToState: @escaping ((Event) -> (State)))
    { bloc = Bloc(state: state, mapEventToState: mapEventToState) }
}

final public class Bloc<Event, State>: ObservableObject where Event: Equatable, State: Equatable {
    final public func send(_ event: Event) {
        let newState = self._mapEventToState(event)
        if(self.state != newState) {
            self.state = newState }
    }
    public internal(set) var state: State {
        willSet {
            objectWillChange.send()
        }
    }
    internal init(state: State, mapEventToState: @escaping ((Event) -> (State))
    ) {
        self._mapEventToState = mapEventToState
        self.state = state
    }
    private let _mapEventToState: (Event) -> (State)
}
