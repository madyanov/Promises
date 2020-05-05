//
//  Promise+Reject.swift
//  Promises
//
//  Created by Roman Madyanov on 04.05.2020.
//

extension Promise
{
    public func reject() {
        report(result: .failure(Error.rejected))
    }
}
