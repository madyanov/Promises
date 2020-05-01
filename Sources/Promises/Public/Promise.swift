//
//  Promise.swift
//  Promises
//
//  Created by Roman Madyanov on 03/02/2019.
//

import Dispatch

public typealias Single = Promise<Void>

public final class Promise<Value>
{
    public var isPending: Bool { state.isPending }
    public var isFulfilled: Bool { state.isFulfilled }
    public var isRejected: Bool { state.isRejected }

    public var value: Value? { state.value }
    public var error: Swift.Error? { state.error }

    public var state: State<Value> {
        queue.sync { State(from: result) }
    }

    public static var void: Promise<Void> { Promise<Void>(value: ()) }

    private var result: Result<Value>?
    private var observers: [Observer<Value>] = []

    private lazy var queue = DispatchQueue(label: "PromisesQueue", attributes: .concurrent)

    public init(value: Value) {
        result = .success(value)
    }

    public init(error: Swift.Error) {
        result = .failure(error)
    }

    public init(_ work: @escaping (@escaping (Result<Value>) -> Void) throws -> Void) {
        do {
            try work(report)
        } catch {
            result = .failure(error)
        }
    }

    @discardableResult
    public func observe(on context: ExecutionContext = DispatchQueue.main,
                        with handler: @escaping (Result<Value>) -> Void) -> Self
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
                        _ handler: @escaping () -> Void) -> Self
    {
        return observe(on: context) { _ in
            handler()
        }
    }
}

extension Promise
{
    private func report(result: Result<Value>) {
        queue.sync(flags: .barrier) {
            guard self.result == nil else { return }

            self.result = result
            observers.forEach { $0.report(result: result) }
        }
    }
}
