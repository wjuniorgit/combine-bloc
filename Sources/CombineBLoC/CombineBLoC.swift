//
//  CombineBLoC.swift
//
//  Created by Wellington Soares on 08/03/21.
//
import Combine

final internal class BlocSubject<Event, State, Failure: Error>: Publisher {
    typealias Output = State

    init(initialValue: State, mapEventToState: @escaping (Event, State) -> State) {
        self.subject = .init(initialValue)
        self.mapEventToState = mapEventToState
    }

    func send(_ value: Event) {
        subject.send(mapEventToState(value, subject.value))
    }

    func send(completion: Subscribers.Completion<Failure>) {
        subject.send(completion: completion)
    }

    func send(subscription: Subscription) {
        subject.send(subscription: subscription)
    }

    func receive<Downstream: Subscriber>(subscriber: Downstream) where Failure == Downstream.Failure, State == Downstream.Input {
        subject.subscribe(subscriber)
    }

    private let subject: CurrentValueSubject<State, Failure>
    private let mapEventToState: ((Event, State) -> State)
}

class Bloc<Event, State>: ObservableObject {

    @Published public internal(set) var state: State
    private let subject: BlocSubject<Event, State, Never>
    private var cancellable: AnyCancellable?

    final func send(_ value: Event) {
        subject.send(value)
    }

    init(initialValue: State, mapEventToState: @escaping (Event, State) -> State) {
        self.state = initialValue
        self.subject = BlocSubject<Event, State, Never> (initialValue: initialValue, mapEventToState: mapEventToState)
        self.cancellable = self.subject.assign(to: \.state, on: self)
    }

}
