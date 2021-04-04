//
//  SortedTodosBloc.swift
//  Todos
//
//  Created by Wellington Soares on 31/03/21.
//

import Foundation
import Combine
import CombineBloc

enum TodosSortRule {
    case id
    case name
    case done
}

enum SortedTodosEvent: Equatable {
    case UpdateSortRule(TodosSortRule)
    case TodosStateUpdated(TodosState)
}


struct SortedTodosState: Equatable {
    let todosState: TodosState
    let sortRule: TodosSortRule
}


final class SortedTodosBloc: Bloc<SortedTodosEvent, SortedTodosState> {

    private var cancellable: AnyCancellable?
    private let todosBloc: Bloc<TodosEvent, TodosState>



    static private func sort(_ todos: [Todo], _ rule: TodosSortRule) -> [Todo]
    {
        switch rule {
        case .id:
            return todos.sorted { $0.id.uuidString < $1.id.uuidString }
        case .name:
            return todos.sorted { $0.name < $1.name }
        case .done:
            return todos.sorted { $0.isDone != $1.isDone }
        }
    }


    init(todosBloc: Bloc<TodosEvent, TodosState>) {
        self.todosBloc = todosBloc

        super.init(initialValue: SortedTodosState(todosState: .Loading, sortRule: .id))
        { event, state, emit in

            var currentSortRule = state.sortRule

            switch event {
            case .UpdateSortRule(let sortRule):
                switch sortRule {
                case .id:
                    currentSortRule = TodosSortRule.id
                case .name:
                    currentSortRule = TodosSortRule.name
                case .done:
                    currentSortRule = TodosSortRule.done
                }
            case .TodosStateUpdated(let todoState):
                switch todoState {
                case .Error:
                    emit(SortedTodosState(todosState: .Error, sortRule: state.sortRule))
                case .Loading:
                    emit(SortedTodosState(todosState: .Loading, sortRule: state.sortRule))
                case .Loaded(let todos):
                    emit(SortedTodosState(todosState: .Loaded(SortedTodosBloc.sort(todos, currentSortRule)), sortRule: state.sortRule))
                }
            }
            if currentSortRule != state.sortRule {
                if case let TodosState.Loaded(todos) = state.todosState {
                    emit(SortedTodosState(todosState: .Loaded(SortedTodosBloc.sort(todos, currentSortRule)), sortRule: currentSortRule))
                } else {
                    emit(SortedTodosState(todosState: state.todosState, sortRule: currentSortRule))
                }
            }

        }

        self.cancellable = todosBloc.publisher.sink { todosState in
            Just(.TodosStateUpdated(todosState)).subscribe(self.subscriber)
        }
    }

    override func cancel() {
        cancellable?.cancel()
        super.cancel()
    }

}