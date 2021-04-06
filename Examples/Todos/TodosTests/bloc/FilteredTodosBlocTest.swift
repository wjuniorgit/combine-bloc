//
//  TodosTests.swift
//  TodosTests
//
//  Created by Wellington Soares on 31/03/21.
//

import Combine
import CombineBloc
@testable import Todos
import XCTest

class FilteredTodosBlocTests: XCTestCase {
    let savedTodos = [
        Todo(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001"
        )!, name: "First", isDone: true),
        Todo(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002"
        )!, name: "Second", isDone: false),
        Todo(id: UUID(uuidString: "00000000-0000-0000-0000-000000000003"
        )!, name: "Third", isDone: true),
        Todo(id: UUID(uuidString: "00000000-0000-0000-0000-000000000004"
        )!, name: "Fourth", isDone: true),
    ]

    func testInitialFilterRule() {
        let sortedTodosBloc = SortedTodosBloc(todosBloc: TodosBloc(repository: MockTodosRepository(savedTodos: Set(savedTodos), delay: 0)))
        let filteredTodosBloc = FilteredTodosBloc(sortedTodosBloc: sortedTodosBloc)
        XCTAssertEqual(filteredTodosBloc.value, .init(todosState: .Loading, filterRule: .none))
    }

    func testFilterByNone() {
        let todosIdNotFiltered = [
            Todo(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001"
            )!, name: "First", isDone: true),
            Todo(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002"
            )!, name: "Second", isDone: false),
            Todo(id: UUID(uuidString: "00000000-0000-0000-0000-000000000003"
            )!, name: "Third", isDone: true),
            Todo(id: UUID(uuidString: "00000000-0000-0000-0000-000000000004"
            )!, name: "Fourth", isDone: true),
        ]

        let sortedTodosBloc = SortedTodosBloc(todosBloc: TodosBloc(repository: MockTodosRepository(savedTodos: Set(savedTodos), delay: 0)))
        let filteredTodosBloc = FilteredTodosBloc(sortedTodosBloc: sortedTodosBloc)

        XCTAssertEqual(filteredTodosBloc.value, .init(todosState: .Loading, filterRule: .none))
        let predicate = NSPredicate { _, _ in
            filteredTodosBloc.value == .init(todosState: .Loaded(todosIdNotFiltered), filterRule: .none)
        }
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: sortedTodosBloc)
        let result = XCTWaiter().wait(for: [expectation], timeout: 0.1)
        switch result {
        default: XCTAssertEqual(filteredTodosBloc.value, .init(todosState: .Loaded(todosIdNotFiltered), filterRule: .none))
        }
    }

    func testFilterByDone() {
        let doneTodosIdFiltered = [
            Todo(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001"
            )!, name: "First", isDone: true),
            Todo(id: UUID(uuidString: "00000000-0000-0000-0000-000000000003"
            )!, name: "Third", isDone: true),
            Todo(id: UUID(uuidString: "00000000-0000-0000-0000-000000000004"
            )!, name: "Fourth", isDone: true),
        ]

        let sortedTodosBloc = SortedTodosBloc(todosBloc: TodosBloc(repository: MockTodosRepository(savedTodos: Set(savedTodos), delay: 0)))
        let filteredTodosBloc = FilteredTodosBloc(sortedTodosBloc: sortedTodosBloc)

        XCTAssertEqual(filteredTodosBloc.value, .init(todosState: .Loading, filterRule: .none))
        let predicate = NSPredicate { _, _ in
            filteredTodosBloc.value == .init(todosState: .Loaded(doneTodosIdFiltered), filterRule: .done)
        }
        Just(.UpdateFilterRule(.done)).subscribe(filteredTodosBloc.subscriber)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: sortedTodosBloc)
        let result = XCTWaiter().wait(for: [expectation], timeout: 0.1)
        switch result {
        default: XCTAssertEqual(filteredTodosBloc.value, .init(todosState: .Loaded(doneTodosIdFiltered), filterRule: .done))
        }
    }

    func testFilterByNotDone() {
        let notDoneTodosIdFiltered = [
            Todo(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002"
            )!, name: "Second", isDone: false),
        ]

        let sortedTodosBloc = SortedTodosBloc(todosBloc: TodosBloc(repository: MockTodosRepository(savedTodos: Set(savedTodos), delay: 0)))
        let filteredTodosBloc = FilteredTodosBloc(sortedTodosBloc: sortedTodosBloc)

        XCTAssertEqual(filteredTodosBloc.value, .init(todosState: .Loading, filterRule: .none))
        let predicate = NSPredicate { _, _ in
            filteredTodosBloc.value == .init(todosState: .Loaded(notDoneTodosIdFiltered), filterRule: .notDone)
        }
        Just(.UpdateFilterRule(.notDone)).subscribe(filteredTodosBloc.subscriber)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: sortedTodosBloc)
        let result = XCTWaiter().wait(for: [expectation], timeout: 0.1)
        switch result {
        default: XCTAssertEqual(filteredTodosBloc.value, .init(todosState: .Loaded(notDoneTodosIdFiltered), filterRule: .notDone))
        }
    }
}
