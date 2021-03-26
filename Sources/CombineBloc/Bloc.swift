//
//  Bloc.swift
//
//  Created by Wellington Soares on 08/03/21.
//
import Combine

private final class BlocStateSubscription<State, S: Subscriber>: Subscription where S.Input == State {

    init(statePublisher: AnyPublisher<State, Never>, subscriber: S) {

        self.cancellable = statePublisher.sink { state in
            _ = subscriber.receive(state)
        }
    }

    func request(_ demand: Subscribers.Demand) { }

    func cancel() {
        cancellable?.cancel()
        cancellable = nil
    }

    var cancellable: AnyCancellable?

}


open class Bloc<Event:Equatable, State:Equatable>: Publisher, Subscriber{

    public typealias Input = Event
    public typealias Output = State
    public typealias Failure = Never

    public init(initialValue: State, mapEventToState: @escaping (Event, State, @escaping (State) -> ()) -> ()) {
        self.value = initialValue
        self.mapEventToState = mapEventToState

        eventSubject.sink {
            event in
            self.mapEventToState(event, self.value) { newState in
                if(newState != self.value) {
                    self.transitionSubject.send(Transition(currentState: self.value, event: event, nextState: newState))
                    self.value = newState
                    self.stateSubject.send(self.value)
                }
            }
        }.store(in: &bag)
    }
//
//    final public func send(_ input: Event) { eventSubject.send(input) }
//
//    final public func send(subscription: Subscription) {
//        eventSubject.send(subscription: subscription)
//    }
//
//    final public func send(completion: Subscribers.Completion<Failure>) {
//    }

    final public func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, State == S.Input {
        subscriber.receive(subscription: BlocStateSubscription(statePublisher: statePublisher, subscriber: subscriber))
    }

    final public func receive(completion: Subscribers.Completion<Never>) {}

    final public func receive(_ input: Event) -> Subscribers.Demand {
        eventSubject.send(input)
        return .unlimited
    }

    final public func receive(subscription: Subscription) {
        subscription.request(.unlimited)
    }

    private(set) public var value: State
    public var transitions: AnyPublisher<Transition<Event, State>, Never> { transitionSubject.eraseToAnyPublisher() }

    private var statePublisher: AnyPublisher<State, Never> { stateSubject.eraseToAnyPublisher() }
    private let transitionSubject = PassthroughSubject<Transition<Event, State>, Never>()
    private let eventSubject = PassthroughSubject<Event, Never>()
    private let stateSubject = PassthroughSubject<State, Never>()
    

    private var bag = Set<AnyCancellable>()
    private let mapEventToState: ((Event, State, @escaping (State) -> ()) -> ())

    open func cancel() {
        bag.forEach { sub in
            sub.cancel()
        }
        bag.removeAll()
    }
}

public extension Bloc {
    func debug(onEvent: ((Event) -> ())? = nil, onState: ((State) -> ())? = nil, onTransition: ((Transition<Event, State>) -> ())? = nil) -> Bloc<Event, State> {
        self.eventSubject.sink { event in
            onEvent?(event)
        }.store(in: &bag)

        self.sink { state in
            onState?(state)
        }.store(in: &bag)

        self.transitions.sink { transition in
            onTransition?(transition)
        }.store(in: &bag)
        return self
    }
}
