//
//  FilteredTodosBloc.swift
//  Todos
//
//  Created by Wellington Soares on 01/04/21.
//


import Foundation
import Combine
import CombineBloc

enum TodosFilterRule {
    case none
    case done
    case undone
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



    static private func filter(_ todos: [Todo], _ rule: TodosFilterRule) -> [Todo]
    {
        switch rule {
        case .none:
            return todos
        case .done:
            return Array(todos).filter { $0.isDone }
        case .undone:
            return Array(todos).filter { !$0.isDone }
        }
    }


    init(sortedTodosBloc: Bloc<SortedTodosEvent, SortedTodosState>) {
        self.sortedTodosBloc = sortedTodosBloc

        super.init(initialValue: FilteredTodosState(todosState: .Loading, filterRule: .none))
        { event, state, emit in

            var currentFilterRule = state.filterRule

            switch event {
            case .UpdateFilterRule(let filterRule):
                switch filterRule {
                case .none:
                    currentFilterRule = .none
                case .done:
                    currentFilterRule = .done
                case .undone:
                    currentFilterRule = .undone
                }

            case .TodosStateUpdated(let todoState):
                switch todoState {
                case .Error:
                    emit(FilteredTodosState(todosState: .Error, filterRule: state.filterRule))
                case .Loading:
                    emit(FilteredTodosState(todosState: .Loading, filterRule: state.filterRule))
                case .Loaded(let todos):
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

        self.cancellable = sortedTodosBloc.publisher.sink { sortedTodosState in
            Just(.TodosStateUpdated(sortedTodosState.todosState)).subscribe(self.subscriber)
        }
    }

    override func cancel() {
        cancellable?.cancel()
        super.cancel()
    }

}
