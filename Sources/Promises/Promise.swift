//
//  Promise.swift
//  Promises
//
//  Created by Roman Madyanov on 03/02/2019.
//

import Dispatch

public final class Promise<Value> {
    public enum Result {
        case success(Value)
        case failure(Swift.Error)
    }

    public var state: State {
        return queue.sync {
            return State(from: result)
        }
    }

    public var isPending: Bool {
        return state.isPending
    }

    public var isFulfilled: Bool {
        return state.isFulfilled
    }

    public var isRejected: Bool {
        return state.isRejected
    }

    public var value: Value? {
        return state.value
    }

    public var error: Swift.Error? {
        return state.error
    }

    private var result: Result?
    private var observers: [Observer] = []

    private lazy var queue = DispatchQueue(label: "PromisesQueue", attributes: .concurrent)

    public init(value: Value) {
        result = .success(value)
    }

    public init(error: Swift.Error) {
        result = .failure(error)
    }

    public init(_ work: @escaping (@escaping (Result) -> Void) throws -> Void) {
        do {
            try work(report)
        } catch {
            result = .failure(error)
        }
    }

    @discardableResult
    public func observe(on context: ExecutionContext = DispatchQueue.main,
                        with handler: @escaping (Result) -> Void) -> Self
    {
        let observer = Observer(handler: handler, context: context)

        queue.sync(flags: .barrier) {
            observers.append(observer)
            result.map(observer.report)
        }

        return self
    }

    @discardableResult
    public func then<NewValue>(context: ExecutionContext = DispatchQueue.main,
                               _ work: @escaping (Value) throws -> Promise<NewValue>) -> Promise<NewValue>
    {
        return Promise<NewValue> { completion in
            self.observe(on: context) { result in
                switch result {
                case .success(let value):
                    do {
                        try work(value).observe(on: context, with: completion)
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    @discardableResult
    public func then<NewValue>(context: ExecutionContext = DispatchQueue.main,
                               _ work: @escaping (Value) throws -> NewValue) -> Promise<NewValue>
    {
        return then(context: context) { value in
            do {
                return Promise<NewValue>(value: try work(value))
            } catch {
                return Promise<NewValue>(error: error)
            }
        }
    }

    @discardableResult
    public func `catch`(context: ExecutionContext = DispatchQueue.main,
                        _ handler: @escaping (Swift.Error) -> Void) -> Self
    {
        return observe(on: context) { result in
            switch result {
            case .success: break
            case .failure(let error): handler(error)
            }
        }
    }

    @discardableResult
    public func recover(context: ExecutionContext = DispatchQueue.main,
                        _ handler: @escaping (Swift.Error) throws -> Promise) -> Promise
    {
        return Promise { completion in
            self.observe(on: context, with: completion)
                .catch(context: context) { error in
                    do {
                        try handler(error).observe(on: context, with: completion)
                    } catch {
                        completion(.failure(error))
                    }
                }
        }
    }

    @discardableResult
    public func finally(context: ExecutionContext = DispatchQueue.main,
                        _ handler: @escaping  () -> Void) -> Self
    {
        return observe(on: context) { _ in
            handler()
        }
    }
}

extension Promise.Result where Value == Void {
    public static var success: Promise.Result {
        return .success(())
    }
}

// MARK: - Private
extension Promise {
    private struct Observer {
        private let handler: (Result) -> Void
        private let context: ExecutionContext

        init(handler: @escaping (Result) -> Void, context: ExecutionContext) {
            self.handler = handler
            self.context = context
        }

        func report(result: Result) {
            context.execute { self.handler(result) }
        }
    }

    private func report(result: Result) {
        queue.sync(flags: .barrier) {
            guard self.result == nil else {
                return
            }

            self.result = result
            observers.forEach { $0.report(result: result) }
        }
    }
}
