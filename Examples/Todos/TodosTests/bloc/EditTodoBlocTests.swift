//
//  EditTodoBlocTests.swift
//  TodosTests
//
//  Created by Wellington Soares on 31/03/21.
//

import Combine
import CombineBloc
@testable import Todos
import XCTest

class EditTodoBlocTests: XCTestCase {
    func testEditInitialState() {
        let todo = Todo(id: UUID(), name: "Todo", isDone: false)
        let todosBloc = TodosBloc(repository: MockTodosRepository(savedTodos: [todo], delay: 0))
        XCTAssertEqual(todosBloc.value, .Loading)
        let editTodoBloc = EditTodoBloc(todo: todo, todosState: todosBloc.publisher, add: { todosBloc.send(.Add($0)) }, update: { todosBloc.send(.Update($0)) }, remove: { todosBloc.send(.Remove($0)) })

        let initialValue = EditTodoState.ValidTodo(ValidTodoState(name: todo.name,
                                                                  isDone: todo.isDone,
                                                                  id: todo.id, isSaved: true, canSave: false, isNameValid: true))

        XCTAssertEqual(editTodoBloc.value, initialValue)
    }

    func testAddInitialState() {
        var id: UUID?
        let todosBloc = TodosBloc(repository: MockTodosRepository(savedTodos: [], delay: 0))
        XCTAssertEqual(todosBloc.value, .Loading)
        let editTodoBloc = EditTodoBloc(todosState: todosBloc.publisher, add: { todosBloc.send(.Add($0)) }, update: { todosBloc.send(.Update($0)) }, remove: { todosBloc.send(.Remove($0)) })

        if case let .ValidTodo(state) = editTodoBloc.value {
            id = state.id
        }

        let initialValue = EditTodoState.ValidTodo(ValidTodoState(name: "",
                                                                  isDone: false,
                                                                  id: id ?? UUID(), isSaved: false, canSave: false, isNameValid: true))

        XCTAssertEqual(editTodoBloc.value, initialValue)
    }

    func testNameChanged() {
        let todo = Todo(id: UUID(), name: "Todo", isDone: false)
        let todosBloc = TodosBloc(repository: MockTodosRepository(savedTodos: [todo], delay: 0))
        XCTAssertEqual(todosBloc.value, .Loading)
        let editTodoBloc = EditTodoBloc(todo: todo, todosState: todosBloc.publisher, add: { todosBloc.send(.Add($0)) }, update: { todosBloc.send(.Update($0)) }, remove: { todosBloc.send(.Remove($0)) })

        [.NameChanged("Tod"), .NameChanged("To"), .NameChanged("T"), .NameChanged("")].publisher.subscribe(editTodoBloc.subscriber)

        let invalidNameState = EditTodoState.ValidTodo(ValidTodoState(name: "",
                                                                      isDone: todo.isDone,
                                                                      id: todo.id, isSaved: true, canSave: false, isNameValid: false))
        XCTAssertEqual(editTodoBloc.value, invalidNameState)

        Just(.NameChanged("T")).subscribe(editTodoBloc.subscriber)
        let validNameState = EditTodoState.ValidTodo(ValidTodoState(name: "T",
                                                                    isDone: todo.isDone,
                                                                    id: todo.id, isSaved: true, canSave: true, isNameValid: true))
        XCTAssertEqual(editTodoBloc.value, validNameState)
    }

    func testDoneChanged() {
        let todo = Todo(id: UUID(), name: "Todo", isDone: false)
        let todosBloc = TodosBloc(repository: MockTodosRepository(savedTodos: [todo], delay: 0))
        XCTAssertEqual(todosBloc.value, .Loading)
        let editTodoBloc = EditTodoBloc(todo: todo, todosState: todosBloc.publisher, add: { todosBloc.send(.Add($0)) }, update: { todosBloc.send(.Update($0)) }, remove: { todosBloc.send(.Remove($0)) })

        let toggleDoneState = EditTodoState.ValidTodo(ValidTodoState(name: "Todo",
                                                                     isDone: true,
                                                                     id: todo.id, isSaved: true, canSave: true, isNameValid: true))

        Just(.DoneChanged(true)).subscribe(editTodoBloc.subscriber)

        XCTAssertEqual(editTodoBloc.value, toggleDoneState)
    }
}
