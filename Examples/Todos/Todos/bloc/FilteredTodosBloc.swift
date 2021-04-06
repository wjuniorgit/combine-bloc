//
//  FilteredTodosBloc.swift
//  Todos
//
//  Created by Wellington Soares on 01/04/21.
//

import Combine
import CombineBloc
import Foundation

enum TodosFilterRule {
    case none
    case done
    case notDone
}

enum FilteredTodosEvent: Equatable {
    case UpdateFilterRule(TodosFilterRule)
    case TodosStateUpdated(TodosState)
}

struct FilteredTodosState: Equatable {
    let todosState: TodosState
    let filterRule: TodosFilterRule
}

final class FilteredTodosBloc: Bloc<FilteredTodosEvent, FilteredTodosState> {
    private var cancellable: AnyCancellable?
    private let sortedTodosBloc: Bloc<SortedTodosEvent, SortedTodosState>

    private static func filter(_ todos: [Todo], _ rule: TodosFilterRule) -> [Todo] {
        switch rule {
        case .none:
            return todos
        case .done:
            return Array(todos).filter { $0.isDone }
        case .notDone:
            return Array(todos).filter { !$0.isDone }
        }
    }

    init(sortedTodosBloc: Bloc<SortedTodosEvent, SortedTodosState>) {
        self.sortedTodosBloc = sortedTodosBloc

        super.init(initialValue: FilteredTodosState(todosState: .Loading, filterRule: .none))
            { event, state, emit in

                var currentFilterRule = state.filterRule

                switch event {
                case let .UpdateFilterRule(filterRule):
                    currentFilterRule = filterRule

                case let .TodosStateUpdated(todoState):
                    switch todoState {
                    case .Error, .Loading:
                        emit(FilteredTodosState(todosState: todoState, filterRule: state.filterRule))
                    case let .Loaded(todos):
                        emit(FilteredTodosState(todosState: .Loaded(FilteredTodosBloc.filter(todos, currentFilterRule)), filterRule: state.filterRule))
                    }
                }

                if currentFilterRule != state.filterRule {
                    if case let TodosState.Loaded(todos) = sortedTodosBloc.value.todosState {
                        emit(FilteredTodosState(todosState: .Loaded(FilteredTodosBloc.filter(todos, currentFilterRule)), filterRule: currentFilterRule))
                    } else {
                        emit(FilteredTodosState(todosState: state.todosState, filterRule: currentFilterRule))
                    }
                }
            }

        cancellable = sortedTodosBloc.publisher.sink { sortedTodosState in
            Just(.TodosStateUpdated(sortedTodosState.todosState)).subscribe(self.subscriber)
        }
    }

    override func cancel() {
        cancellable?.cancel()
        super.cancel()
    }
}
