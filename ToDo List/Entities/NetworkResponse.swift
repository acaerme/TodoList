//
//  NetworkResponse.swift
//  ToDo List
//
//  Created by Islam Elikhanov on 25/03/2025.
//

import Foundation

struct NetworkResponse: Codable {
    let todos: [ToDoNetworkObject]
    let total: Int
    let skip: Int
    let limit: Int
}

struct ToDoNetworkObject: Codable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}
