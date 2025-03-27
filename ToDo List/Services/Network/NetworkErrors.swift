import Foundation

enum NetworkErrors: Error {
    case invalidUrl
    case requestFailed
    case badResponse
    case failedToDecode
    case unknownError
}
