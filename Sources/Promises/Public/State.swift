//
//  State.swift
//  Promises
//
//  Created by Roman Madyanov on 03/02/2019.
//

public enum State<Value>
{
    case pending
    case fulfilled(value: Value)
    case rejected(error: Swift.Error)

    public var isPending: Bool {
        if case .pending = self {
            return true
        }

        return false
    }

    public var isFulfilled: Bool {
        if case .fulfilled = self {
            return true
        }

        return false
    }

    public var isRejected: Bool {
        if case .rejected = self {
            return true
        }

        return false
    }

    public var value: Value? {
        guard case .fulfilled(let value) = self else {
            return nil
        }

        return value
    }

    public var error: Swift.Error? {
        guard case .rejected(let error) = self else {
            return nil
        }

        return error
    }

    init(from result: Result<Value>?) {
        switch result {
        case .none: self = .pending
        case .success(let value)?: self = .fulfilled(value: value)
        case .failure(let error)?: self = .rejected(error: error)
        }
    }
}
