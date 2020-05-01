//
//  Observer.swift
//  Promises
//
//  Created by Roman Madyanov on 01.05.2020.
//

struct Observer<Value>
{
    private let handler: (Result<Value>) -> Void
    private let context: ExecutionContext

    init(handler: @escaping (Result<Value>) -> Void, context: ExecutionContext) {
        self.handler = handler
        self.context = context
    }

    func report(result: Result<Value>) {
        context.execute { self.handler(result) }
    }
}
