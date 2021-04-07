//
//  Bloc.swift
//
//  Created by Wellington Soares on 08/03/21.
//
import Combine

/// A `Bloc` must be extended to implement the desired use case.
/// A `Bloc` is a composition of a `Subscriber` of `Event` and a `Publisher` of `State`.
/// It receives `Event` as input and maps it to a current `State`.
open class Bloc<Event: Equatable, State: Equatable> {
    /// Initializes a `Bloc` from an initial `State` value, and a mapEventToState closure.
    ///
    /// - Parameters:
    ///   - initialValue: The initial Bloc `State`.
    ///   - mapEventToState: A closure that receives an `Event`, the current `State` and an `emit` closure through which current `State` is updated.
    public init(initialValue: State, mapEventToState: @escaping (Event, State, @escaping (State) -> Void) -> Void) {
        value = initialValue
        self.mapEventToState = mapEventToState

        eventSubject
            .sink {
                event in
                self.mapEventToState(event, self.value) { newState in
                    if newState != self.value {
                        self.transitionSubject.send(Transition(currentState: self.value, event: event, nextState: newState))
                        self.value = newState
                        self.stateSubject.send(self.value)
                    }
                }
            }.store(in: &bag)
        onInit?()
    }

    /// A `Subscriber` instance that receives a stream of `Event` from a `Publisher`.
    public var subscriber: BlocSubscriber<Event> {
        if _subscriber == nil {
            _subscriber = BlocSubscriber<Event>(
                onReceiveInput: { input in self.eventSubject.send(input) },
                onReceiveInputSubscription: { subscription in self.eventSubject.send(subscription: subscription) }
            )
        }
        return _subscriber!
    }

    /// Sends a value to the subscriber.
    ///
    /// - Parameter value: The `Event` value to send.
    public final func send(_ input: Event) {
        eventSubject.send(input)
    }

    /// The current `Bloc` `State`
    public private(set) var value: State

    /// A `Publisher` instance that sends a stream of `State`.
    public var publisher: AnyPublisher<State, Never> { stateSubject.eraseToAnyPublisher() }

    /// Cancel the activity.
    open func cancel() {
        bag.forEach { sub in
            sub.cancel()
        }
        bag.removeAll()
        _subscriber = nil
    }

    private let mapEventToState: (Event, State, @escaping (State) -> Void) -> Void
    private var _subscriber: BlocSubscriber<Event>?
    private let eventSubject = PassthroughSubject<Event, Never>()
    private let stateSubject = PassthroughSubject<State, Never>()
    internal let transitionSubject = PassthroughSubject<Transition<Event, State>, Never>()
    private var bag = Set<AnyCancellable>()
    private var onInit: (() -> Void)?
    private var onDeinit: (() -> Void)?

    deinit {
        onDeinit?()
    }
}

/// A `Transition` is created every time an `Event` triggers a new `State`.
public struct Transition<Event: Equatable, State: Equatable>: Equatable {
    public let currentState: State
    public let event: Event?
    public let nextState: State
}

/// A `BlocSubscriber`is a subscriber that does not cancel on reveicing a `Subscribers.Completion`.
public final class BlocSubscriber<Input>: Subscriber {
    fileprivate init(onReceiveInput: @escaping (Input) -> Void, onReceiveInputSubscription: @escaping (Subscription) -> Void) {
        self.onReceiveInput = onReceiveInput
        self.onReceiveInputSubscription = onReceiveInputSubscription
    }

    public typealias Failure = Never

    /// Tells the subscriber that the publisher has completed publishing, either normally or with an error.
    /// It does not cancel when a publisher has completed publishing.
    ///
    /// - Parameter completion: A ``Subscribers/Completion`` case indicating whether publishing completed normally or with an error.
    public final func receive(completion _: Subscribers.Completion<Never>) {}

    /// Tells the subscriber that the publisher has produced an element.
    ///
    /// - Parameter input: The published element.
    /// - Returns: Always returns `Subscribers.Demand.unlimited`
    public final func receive(_ input: Input) -> Subscribers.Demand {
        onReceiveInput(input)

        return .unlimited
    }

    /// Tells the subscriber that it has successfully subscribed to the publisher and may request items.
    ///
    /// Use the received `Subscription` to request items from the publisher.
    /// - Parameter subscription: A subscription that represents the connection between publisher and subscriber.
    public final func receive(subscription: Subscription) {
        onReceiveInputSubscription(subscription)
    }

    fileprivate let onReceiveInput: (Input) -> Void
    fileprivate let onReceiveInputSubscription: (Subscription) -> Void
}

public extension Bloc {
    /// Used for debugging purposes.
    /// It injects a closure that my print or debug on every `Bloc` lifecycle event.
    ///
    /// - Parameters:
    ///   - onEvent: A closure with the last `Event` received as a parameter.
    ///   - onState: A closure with the last `State` emmited as a parameter.
    ///   - onTransition: A closure with the last `Transition` created as a parameter.
    ///   - onInit: A closure that runs when `Bloc` is initialized.
    ///   - onDeinit: A closure that runs when `Bloc` is deinitialized.
    ///
    /// - Returns: A `Bloc`with injected debug closures.
    func debug(onEvent: ((Event) -> Void)? = nil, onState: ((State) -> Void)? = nil, onTransition: ((Transition<Event, State>) -> Void)? = nil, onInit: (() -> Void)? = nil, onDeinit: (() -> Void)? = nil) -> Bloc<Event, State> {
        eventSubject.sink { event in
            onEvent?(event)
        }.store(in: &bag)

        stateSubject.sink { state in
            onState?(state)
        }.store(in: &bag)

        transitionSubject.sink { transition in
            onTransition?(transition)
        }.store(in: &bag)

        if onInit != nil {
            self.onInit = onInit
        }
        if onDeinit != nil {
            self.onDeinit = onDeinit
        }
        return self
    }
}
