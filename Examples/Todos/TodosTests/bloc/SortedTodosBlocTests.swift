//
//  SortedTodosBlocTests.swift
//  TodosTests
//
//  Created by Wellington Soares on 31/03/21.
//

import Combine
import CombineBloc
@testable import Todos
import XCTest

class SortedTodosBlocTests: XCTestCase {
  let savedTodos = [
    Todo(id: UUID(
      uuidString: "00000000-0000-0000-0000-000000000001"
    )!, name: "First", isDone: true, description: ""),
    Todo(id: UUID(
      uuidString: "00000000-0000-0000-0000-000000000002"
    )!, name: "Second", isDone: false, description: ""),
    Todo(id: UUID(
      uuidString: "00000000-0000-0000-0000-000000000004"
    )!, name: "Fourth", isDone: true, description: ""),
    Todo(id: UUID(
      uuidString: "00000000-0000-0000-0000-000000000003"
    )!, name: "Third", isDone: true, description: "")
  ]

  func testInitialSortRule() {
    let sortedTodosBloc =
      SortedTodosBloc(
        todosBloc: TodosBloc(repository: MockTodosRepository(
          savedTodos: Array(savedTodos),
          delay: 0
        ))
      )
    XCTAssertEqual(
      sortedTodosBloc.value,
      .init(todosState: .Loading, sortRule: .done)
    )
  }

  func testSortById() {
    let savedTodosIdSorted = [
      Todo(id: UUID(
        uuidString: "00000000-0000-0000-0000-000000000001"
      )!, name: "First", isDone: true, description: ""),
      Todo(id: UUID(
        uuidString: "00000000-0000-0000-0000-000000000002"
      )!, name: "Second", isDone: false, description: ""),
      Todo(id: UUID(
        uuidString: "00000000-0000-0000-0000-000000000003"
      )!, name: "Third", isDone: true, description: ""),
      Todo(id: UUID(
        uuidString: "00000000-0000-0000-0000-000000000004"
      )!, name: "Fourth", isDone: true, description: "")
    ]

    let sortedTodosBloc =
      SortedTodosBloc(
        todosBloc: TodosBloc(repository: MockTodosRepository(
          savedTodos: Array(savedTodos),
          delay: 0
        ))
      )
    XCTAssertEqual(
      sortedTodosBloc.value,
      .init(todosState: .Loading, sortRule: .done)
    )
    let predicate = NSPredicate { _, _ in
      sortedTodosBloc.value == .init(
        todosState: .Loaded(savedTodosIdSorted),
        sortRule: .id
      )
    }
    Just(.UpdateSortRule(.id)).subscribe(sortedTodosBloc.subscriber)
    let expectation = XCTNSPredicateExpectation(
      predicate: predicate,
      object: sortedTodosBloc
    )
    let result = XCTWaiter().wait(for: [expectation], timeout: 0.1)
    switch result {
    default: XCTAssertEqual(
        sortedTodosBloc.value,
        .init(todosState: .Loaded(savedTodosIdSorted), sortRule: .id)
      )
    }
  }

  func testSortByName() {
    let savedTodosNameSorted = [
      Todo(id: UUID(
        uuidString: "00000000-0000-0000-0000-000000000001"
      )!, name: "First", isDone: true, description: ""),
      Todo(id: UUID(
        uuidString: "00000000-0000-0000-0000-000000000004"
      )!, name: "Fourth", isDone: true, description: ""),
      Todo(id: UUID(
        uuidString: "00000000-0000-0000-0000-000000000002"
      )!, name: "Second", isDone: false, description: ""),
      Todo(id: UUID(
        uuidString: "00000000-0000-0000-0000-000000000003"
      )!, name: "Third", isDone: true, description: "")
    ]

    let sortedTodosBloc =
      SortedTodosBloc(
        todosBloc: TodosBloc(repository: MockTodosRepository(
          savedTodos: Array(savedTodos),
          delay: 0
        ))
      )
    XCTAssertEqual(
      sortedTodosBloc.value,
      .init(todosState: .Loading, sortRule: .done)
    )
    let predicate = NSPredicate { _, _ in
      sortedTodosBloc.value == .init(
        todosState: .Loaded(savedTodosNameSorted),
        sortRule: .name
      )
    }
    Just(.UpdateSortRule(.name)).subscribe(sortedTodosBloc.subscriber)
    let expectation = XCTNSPredicateExpectation(
      predicate: predicate,
      object: sortedTodosBloc
    )
    let result = XCTWaiter().wait(for: [expectation], timeout: 0.1)
    switch result {
    default: XCTAssertEqual(
        sortedTodosBloc.value,
        .init(todosState: .Loaded(savedTodosNameSorted), sortRule: .name)
      )
    }
  }

  func testSortByIsDone() {
    let savedTodosDoneSorted = [
      Todo(id: UUID(
        uuidString: "00000000-0000-0000-0000-000000000002"
      )!, name: "Second", isDone: false, description: ""),
      Todo(id: UUID(
        uuidString: "00000000-0000-0000-0000-000000000001"
      )!, name: "First", isDone: true, description: ""),
      Todo(id: UUID(
        uuidString: "00000000-0000-0000-0000-000000000004"
      )!, name: "Fourth", isDone: true, description: ""),
      Todo(id: UUID(
        uuidString: "00000000-0000-0000-0000-000000000003"
      )!, name: "Third", isDone: true, description: "")
    ]

    let sortedTodosBloc =
      SortedTodosBloc(
        todosBloc: TodosBloc(repository: MockTodosRepository(
          savedTodos: Array(savedTodos),
          delay: 0
        ))
      )
    XCTAssertEqual(
      sortedTodosBloc.value,
      .init(todosState: .Loading, sortRule: .done)
    )
    let predicate = NSPredicate { _, _ in
      sortedTodosBloc.value == .init(
        todosState: .Loaded(savedTodosDoneSorted),
        sortRule: .done
      )
    }
    Just(.UpdateSortRule(.done)).subscribe(sortedTodosBloc.subscriber)
    let expectation = XCTNSPredicateExpectation(
      predicate: predicate,
      object: sortedTodosBloc
    )
    let result = XCTWaiter().wait(for: [expectation], timeout: 0.1)
    switch result {
    default: XCTAssertEqual(
        sortedTodosBloc.value,
        .init(todosState: .Loaded(savedTodosDoneSorted), sortRule: .done)
      )
    }
  }
}
