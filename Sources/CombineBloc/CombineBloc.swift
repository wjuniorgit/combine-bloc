//
//  CombineBLoC.swift
//
//  Created by Wellington Soares on 08/03/21.
//
import Combine

struct Transition<Event: Equatable, State: Equatable>: Equatable {
    let currentState: State
    let event: Event?
    let nextState: State
}

extension Bloc {
    func debug() -> Bloc<Event, State> {
        self.stateSubject.sink { state in
            print("State: \(state)")
        }.store(in: &bag)

        self.transitionSubject.sink { transition in
            print("Transition: \(transition)")
        }.store(in: &bag)

        self.eventSubject.sink { event in
            print("Event: \(event)")
        }.store(in: &bag)
        return self
    }
}

class Bloc<Event:Equatable, State:Equatable>: ObservableObject {

    @Published public internal(set) var state: State
    @Published public internal(set) var event: Event?
    @Published public internal(set) var transition: Transition<Event, State>?

    private let stateSubject = PassthroughSubject<State, Never>()
    private let transitionSubject = PassthroughSubject<Transition<Event, State>, Never>()
    private let eventSubject = PassthroughSubject<Event, Never>()

    private var bag = Set<AnyCancellable>()

    private let mapEventToState: ((Event, State, @escaping (State) -> ()) -> ())

    final func send(_ value: Event) {
        eventSubject.send(value)
    }

    init(initialValue: State, mapEventToState: @escaping (Event, State, @escaping (State) -> ()) -> ()) {
        self.state = initialValue
        self.mapEventToState = mapEventToState

        self.stateSubject.assign(to: \.state, on: self).store(in: &bag)

        eventSubject.sink {
            event in
            self.event = event
            self.mapEventToState(event, self.state) { newState in
                if(newState != self.state) {
                    self.transitionSubject.send(Transition(currentState: self.state, event: event, nextState: newState))
                    self.stateSubject.send(newState)
                }
            }
        }.store(in: &bag)

        transitionSubject.sink {
            transition in
            self.transition = transition
        }.store(in: &bag)
    }

    func cancel() {
        bag.forEach { sub in
            sub.cancel()
        }
        bag.removeAll()
    }
}
