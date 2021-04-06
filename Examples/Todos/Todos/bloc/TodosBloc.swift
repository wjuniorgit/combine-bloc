//
//  todosBloc.swift
//  Todos
//
//  Created by Wellington Soares on 31/03/21.
//


import Foundation
import Combine
import CombineBloc


enum TodosEvent: Equatable {
    case Add(Todo)
    case Remove(UUID)
    case Update(Todo)
    case ListUpdated(Result<Set<Todo>, TodosRepositoryError>)

}

enum TodosState: Equatable {
    case Loading
    case Loaded([Todo])
    case Error
}


final class TodosBloc: Bloc<TodosEvent, TodosState> {

    private var cancellable: AnyCancellable?
    private let repository: TodosRepository



    init(repository: TodosRepository) {
        self.repository = repository

        super.init(initialValue: TodosState.Loading, mapEventToState:  { event, _, emit in
            switch event {
            case .ListUpdated(let result):
                switch result {
                case .failure(let error):
                    switch error {
                    case .connectionError:
                        emit(.Error)
                    case .loading:
                        emit(.Loading)
                    }
                case .success(let todos):
                    emit(.Loaded(Array(todos)))
                }
            case .Add(let todo):
                repository.add(todo)
            case .Remove(let id):
                repository.remove(id)
            case .Update(let todo):
                repository.update(todo)
            }

        })

        self.cancellable = repository.todos.sink { todosResult in
            Just(.ListUpdated(todosResult)).subscribe(self.subscriber)
        }
    }

    override func cancel() {
        cancellable?.cancel()
        super.cancel()
    }

}
