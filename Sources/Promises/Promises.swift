//
//  Promises.swift
//  Promises
//
//  Created by Roman Madyanov on 03/02/2019.
//

import Foundation

// MARK: - Delaying & Retrying

public enum Promises {
    public static func delay(_ delay: TimeInterval, on queue: DispatchQueue = .main) -> Promise<Void> {
        return Promise<Void> { completion in
            queue.asyncAfter(deadline: .now() + delay) {
                completion(.success)
            }
        }
    }

    public static func timeout<Value>(_ timeout: TimeInterval, on queue: DispatchQueue = .main) -> Promise<Value> {
        return Promise<Value> { completion in
            delay(timeout, on: queue).then { _ in
                completion(.failure(Promise<Value>.Error.timeout))
            }
        }
    }

    public static func retry<Value>(attempts: Int,
                                    delay: TimeInterval,
                                    on queue: DispatchQueue = .main,
                                    generate: @escaping () -> Promise<Value>) -> Promise<Value>
    {
        guard attempts > 0 else {
            return generate()
        }

        return Promise<Value> { completion in
            generate()
                .recover { _ in
                    return self.delay(delay, on: queue).then {
                        return retry(attempts: attempts - 1, delay: delay, on: queue, generate: generate)
                    }
                }
                .observe(on: queue, with: completion)
        }
    }
}

// MARK: - Zipping

extension Promises {
    public static func zip<V1, V2>(_ p1: Promise<V1>, _ p2: Promise<V2>) -> Promise<(V1, V2)> {
        return Promise<(V1, V2)> { completion in
            let zip: (Any) -> Void = { _ in
                if let v1 = p1.value, let v2 = p2.value {
                    completion(.success((v1, v2)))
                }
            }

            p1.then(zip).catch(completion)
            p2.then(zip).catch(completion)
        }
    }

    public static func zip<V1, V2, V3>(_ p1: Promise<V1>,
                                       _ p2: Promise<V2>,
                                       _ lp: Promise<V3>) -> Promise<(V1, V2, V3)>
    {
        return Promise<(V1, V2, V3)> { completion in
            let zp = self.zip(p1, p2)

            let zip: (Any) -> Void = { _ in
                if let zv = zp.value, let lv = lp.value {
                    completion(.success((zv.0, zv.1, lv)))
                }
            }

            zp.then(zip).catch(completion)
            lp.then(zip).catch(completion)
        }
    }

    public static func zip<V1, V2, V3, V4>(_ p1: Promise<V1>,
                                           _ p2: Promise<V2>,
                                           _ p3: Promise<V3>,
                                           _ lp: Promise<V4>) -> Promise<(V1, V2, V3, V4)>
    {
        return Promise<(V1, V2, V3, V4)> { completion in
            let zp = self.zip(p1, p2, p3)

            let zip: (Any) -> Void = { _ in
                if let zv = zp.value, let lv = lp.value {
                    completion(.success((zv.0, zv.1, zv.2, lv)))
                }
            }

            zp.then(zip).catch(completion)
            lp.then(zip).catch(completion)
        }
    }
}
