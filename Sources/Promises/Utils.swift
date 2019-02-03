//
//  Utils.swift
//  Promises
//
//  Created by Roman Madyanov on 03/02/2019.
//

import Foundation

public protocol ExecutionContext {
    func execute(_ work: @escaping () -> Void)
}

extension DispatchQueue: ExecutionContext {
    public func execute(_ work: @escaping () -> Void) {
        async(execute: work)
    }
}
