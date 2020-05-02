//
//  Result.swift
//  Promises
//
//  Created by Roman Madyanov on 01.05.2020.
//

public enum Result<Value>
{
    case success(Value)
    case failure(Swift.Error)
}

extension Result where Value == Void
{
    public static var success: Result {
        return .success(())
    }
}
