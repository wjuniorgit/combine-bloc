//
//  TodosBlocTests.swift
//  TodosTests
//
//  Created by Wellington Soares on 31/03/21.
//

import Combine
import CombineBloc
@testable import Todos
import XCTest

class TodosBlocTests: XCTestCase {
  func testLoadedAfterDelay() {
    let todosBloc =
      TodosBloc(repository: MockTodosRepository(savedTodos: [], delay: 1))
    XCTAssertEqual(todosBloc.value, .Loading)

    let predicate = NSPredicate { _, _ in
      todosBloc.value == .Loaded([])
    }
    let expectation = XCTNSPredicateExpectation(
      predicate: predicate,
      object: todosBloc
    )
    let result = XCTWaiter().wait(for: [expectation], timeout: 1.1)
    switch result {
    case .completed: XCTAssertEqual(todosBloc.value, .Loaded([]))
    default: XCTFail()
    }
  }

  func testErrorAfterDelay() {
    let todosBloc =
      TodosBloc(repository: MockTodosRepository(
        savedTodos: [],
        delay: 1,
        mustFail: true
      ))
    XCTAssertEqual(todosBloc.value, .Loading)

    let predicate = NSPredicate { _, _ in
      todosBloc.value == .Error
    }
    let expectation = XCTNSPredicateExpectation(
      predicate: predicate,
      object: todosBloc
    )
    let result = XCTWaiter().wait(for: [expectation], timeout: 1.1)
    switch result {
    case .completed: XCTAssertEqual(todosBloc.value, .Error)
    default: XCTFail()
    }
  }

  func testAddOneTodo() {
    let todosBloc =
      TodosBloc(repository: MockTodosRepository(savedTodos: [], delay: 0))
    XCTAssertEqual(todosBloc.value, .Loading)
    let firstTodo = Todo(
      id: UUID(),
      name: "First",
      isDone: false,
      description: ""
    )

    Just(.Add(firstTodo)).subscribe(todosBloc.subscriber)
    XCTAssertEqual(todosBloc.value, .Loaded([firstTodo]))
  }

  func testRemoveOneTodo() {
    let firstTodo = Todo(
      id: UUID(),
      name: "First",
      isDone: false,
      description: ""
    )
    let todosBloc =
      TodosBloc(repository: MockTodosRepository(
        savedTodos: [firstTodo],
        delay: 0
      ))
    XCTAssertEqual(todosBloc.value, .Loading)

    Just(.Remove(firstTodo.id)).subscribe(todosBloc.subscriber)
    XCTAssertEqual(todosBloc.value, .Loaded([]))
  }

  func testEditTodoName() {
    let todoId = UUID()
    let initialTodo = Todo(
      id: todoId,
      name: "First",
      isDone: false,
      description: ""
    )
    let finalTodo = Todo(
      id: todoId,
      name: "Second",
      isDone: false,
      description: ""
    )
    let todosBloc =
      TodosBloc(repository: MockTodosRepository(
        savedTodos: [initialTodo],
        delay: 0
      ))
    XCTAssertEqual(todosBloc.value, .Loading)

    Just(.Update(initialTodo.copyWith(name: "Second")))
      .subscribe(todosBloc.subscriber)
    XCTAssertEqual(todosBloc.value, .Loaded([finalTodo]))
  }

  func testSequentialEditTodoName() {
    let todoId = UUID()
    let initialTodo = Todo(
      id: todoId,
      name: "F",
      isDone: false,
      description: ""
    )
    let finalTodo = Todo(
      id: todoId,
      name: "First",
      isDone: false,
      description: ""
    )
    let todosBloc =
      TodosBloc(repository: MockTodosRepository(
        savedTodos: [initialTodo],
        delay: 0
      ))
    XCTAssertEqual(todosBloc.value, .Loading)

    [
      .Update(initialTodo.copyWith(name: "Fi")),
      .Update(initialTodo.copyWith(name: "Fir")),
      .Update(initialTodo.copyWith(name: "Firs")),
      .Update(initialTodo.copyWith(name: "First"))
    ].publisher.subscribe(todosBloc.subscriber)

    XCTAssertEqual(todosBloc.value, .Loaded([finalTodo]))

    [
      .Update(initialTodo.copyWith(name: "Firs")),
      .Update(initialTodo.copyWith(name: "Fir")),
      .Update(initialTodo.copyWith(name: "Fi")),
      .Update(initialTodo.copyWith(name: "F"))
    ].publisher.subscribe(todosBloc.subscriber)

    XCTAssertEqual(todosBloc.value, .Loaded([initialTodo]))
  }

  func testEditTodoIdDone() {
    let todoId = UUID()
    let initialTodo = Todo(
      id: todoId,
      name: "First",
      isDone: false,
      description: ""
    )
    let finalTodo = Todo(
      id: todoId,
      name: "First",
      isDone: true,
      description: ""
    )
    let todosBloc =
      TodosBloc(repository: MockTodosRepository(
        savedTodos: [initialTodo],
        delay: 0
      ))
    XCTAssertEqual(todosBloc.value, .Loading)

    Just(.Update(initialTodo.copyWith(isDone: true)))
      .subscribe(todosBloc.subscriber)
    XCTAssertEqual(todosBloc.value, .Loaded([finalTodo]))
  }
}
