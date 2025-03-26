//
//  NetworkErrors.swift
//  ToDo List
//
//  Created by Islam Elikhanov on 25/03/2025.
//

import Foundation

enum NetworkErrors: Error {
    case invalidUrl
    case requestFailed
    case badResponse
    case failedToDecode
    case unknownError
}
