//
//  Bloc.swift
//
//  Created by Wellington Soares on 08/03/21.
//
import Combine

open class Bloc<Event:Equatable, State:Equatable> {

    @Published private(set) public var state: State

    public var transition: AnyPublisher<Transition<Event, State>, Never> { transitionSubject.eraseToAnyPublisher() }
    public var event: AnyPublisher<Event, Never> { eventSubject.eraseToAnyPublisher() }

    private let transitionSubject = PassthroughSubject<Transition<Event, State>, Never>()
    private let eventSubject = PassthroughSubject<Event, Never>()

    private var bag = Set<AnyCancellable>()
    private let mapEventToState: ((Event, State, @escaping (State) -> ()) -> ())

    final public func send(_ value: Event) { eventSubject.send(value) }

    public init(initialValue: State, mapEventToState: @escaping (Event, State, @escaping (State) -> ()) -> ()) {
        self.state = initialValue
        self.mapEventToState = mapEventToState

        eventSubject.sink {
            event in
            self.mapEventToState(event, self.state) { newState in
                if(newState != self.state) {
                    self.transitionSubject.send(Transition(currentState: self.state, event: event, nextState: newState))
                    self.state = newState
                }
            }
        }.store(in: &bag)
    }

    func cancel() {
        bag.forEach { sub in
            sub.cancel()
        }
        bag.removeAll()
    }
}

public extension Bloc {
    func debug(onEvent: ((Event) -> ())? = nil, onState: ((State) -> ())? = nil, onTransition: ((Transition<Event, State>) -> ())? = nil) -> Bloc<Event, State> {
        self.event.sink { event in
            onEvent?(event)
        }.store(in: &bag)

        self.$state.sink { state in
            onState?(state)
        }.store(in: &bag)

        self.transition.sink { transition in
            onTransition?(transition)
        }.store(in: &bag)
        return self
    }
}
