//
//  Bloc.swift
//
//  Created by Wellington Soares on 08/03/21.
//
import Combine

open class Bloc<Event:Equatable, State:Equatable> {


    public init(initialValue: State, mapEventToState: @escaping (Event, State, @escaping (State) -> ()) -> ()) {
        self.value = initialValue
        self.mapEventToState = mapEventToState

        eventSubject
            .sink {
            event in
            self.mapEventToState(event, self.value) { newState in
                if(newState != self.value) {
                    self.transitionSubject.send(Transition(currentState: self.value, event: event, nextState: newState))
                    self.value = newState
                    self.stateSubject.send(self.value)
                }
            }
        }.store(in: &bag)
        onInit?()
    }

    public var subscriber: BlocSubscriber<Event> {
        if(self._subscriber == nil) {
            self._subscriber = BlocSubscriber<Event>(
                onReceiveInput: { input in self.eventSubject.send(input) },
                onReceiveInputSubscription: { subscription in self.eventSubject.send(subscription: subscription) })
        }
        return self._subscriber!
    }


    final public func send(_ input: Event) {
        eventSubject.send(input)
    }

    private var _subscriber: BlocSubscriber<Event>?
    private(set) public var value: State
    public var publisher: AnyPublisher<State, Never> { stateSubject.eraseToAnyPublisher() }
    internal let transitionSubject = PassthroughSubject<Transition<Event, State>, Never>()
    private let eventSubject = PassthroughSubject<Event, Never>()
    private let stateSubject = PassthroughSubject<State, Never>()

    private var bag = Set<AnyCancellable>()
    private let mapEventToState: ((Event, State, @escaping (State) -> ()) -> ())

    private var onInit: (() -> ())?
    private var onDeinit: (() -> ())?


    deinit {
        onDeinit?()
    }

    open func cancel() {
        bag.forEach { sub in
            sub.cancel()
        }
        bag.removeAll()
        self._subscriber = nil
    }
}

public class BlocSubscriber<Input>: Subscriber
{

    fileprivate init(onReceiveInput: @escaping(Input) -> (), onReceiveInputSubscription: @escaping(Subscription) -> ()) {
        self.onReceiveInput = onReceiveInput
        self.onReceiveInputSubscription = onReceiveInputSubscription
    }

    fileprivate let onReceiveInput: (Input) -> ()
    fileprivate let onReceiveInputSubscription: (Subscription) -> ()

    public typealias Failure = Never

    final public func receive(completion: Subscribers.Completion<Never>) { }

    final public func receive(_ input: Input) -> Subscribers.Demand {
        self.onReceiveInput(input)
        return .unlimited
    }

    final public func receive(subscription: Subscription) {
        self.onReceiveInputSubscription(subscription)
    }
}


public extension Bloc {
    func debug(onEvent: ((Event) -> ())? = nil, onState: ((State) -> ())? = nil, onTransition: ((Transition<Event, State>) -> ())? = nil, onInit: (() -> ())? = nil, onDeinit: (() -> ())? = nil) -> Bloc<Event, State> {
        self.eventSubject.sink { event in
            onEvent?(event)
        }.store(in: &bag)

        self.stateSubject.sink { state in
            onState?(state)
        }.store(in: &bag)

        self.transitionSubject.sink { transition in
            onTransition?(transition)
        }.store(in: &bag)

        if(onInit != nil) {
            self.onInit = onInit
        }
        if(onDeinit != nil) {
            self.onDeinit = onDeinit
        }

        return self
    }
}
