//
//  ExecutionContext.swift
//  Promises
//
//  Created by Roman Madyanov on 01.05.2020.
//

public protocol ExecutionContext
{
    func execute(_ work: @escaping () -> Void)
}
