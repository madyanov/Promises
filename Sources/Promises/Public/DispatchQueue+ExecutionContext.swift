//
//  DispatchQueue+ExecutionContext.swift
//  Promises
//
//  Created by Roman Madyanov on 01.05.2020.
//

import Dispatch

extension DispatchQueue: ExecutionContext
{
    public func execute(_ work: @escaping () -> Void) {
        async(execute: work)
    }
}
