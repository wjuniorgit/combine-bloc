//
//  CounterBloc.swift
//  Counter
//
//  Created by Wellington Soares on 23/03/21.
//

import CombineBloc
import Foundation

enum CounterEvent: Equatable {
    case increment
    case decrement
}

struct CounterState: Equatable {
    let count: Int
}

final class CounterBloc: Bloc<CounterEvent, CounterState> {
    init() {
        super.init(initialValue: CounterState(count: 0)) {
            event, state, emit in
            switch event {
            case .increment:
                emit(CounterState(count: state.count + 1))
            case .decrement:
                emit(CounterState(count: state.count - 1))
            }
        }
    }
}
