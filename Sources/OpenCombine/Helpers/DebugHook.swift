//
//  DebugHook.swift
//  
//
//  Created by Sergej Jaskiewicz on 02.02.2020.
//

internal protocol DebugHandler: AnyObject {

    func willReceive<Upstream: Publisher, Downstream: Subscriber>(
        publisher: Upstream,
        subscriber: Downstream
    ) where Upstream.Failure == Downstream.Failure, Upstream.Output == Downstream.Input

    func didReceive<Upstream: Publisher, Downstream: Subscriber>(
        publisher: Upstream,
        subscriber: Downstream
    ) where Upstream.Failure == Downstream.Failure, Upstream.Output == Downstream.Input

    func willReceive<Downstream: Subscriber>(subscriber: Downstream,
                                             subscription: Subscription)

    func didReceive<Downstream: Subscriber>(subscriber: Downstream,
                                            subscription: Subscription)

    func willReceive<Downstream: Subscriber>(subscriber: Downstream,
                                             input: Downstream.Input)

    func didReceive<Downstream: Subscriber>(subscriber: Downstream,
                                            input: Downstream.Input,
                                            resultingDemand: Subscribers.Demand)

    func willReceive<Downstream: Subscriber>(
        subscriber: Downstream,
        completion: Subscribers.Completion<Downstream.Failure>
    )

    func didReceive<Downstream: Subscriber>(
        subscriber: Downstream,
        completion: Subscribers.Completion<Downstream.Failure>
    )

    func willRequest(subscription: Subscription, demand: Subscribers.Demand)

    func didRequest(subscription: Subscription, demand: Subscribers.Demand)

    func willCancel(subscription: Subscription)

    func didCancel(subscription: Subscription)
}

internal final class DebugHook {

    private struct Handler: Hashable {
        let handler: DebugHandler

        static func == (lhs: Handler, rhs: Handler) -> Bool {
            return lhs.handler === rhs.handler
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(ObjectIdentifier(handler))
        }
    }

    internal static func getGlobalHook() -> DebugHook? {
        globalLock.lock()
        defer { globalLock.unlock() }
        return globalHook
    }

    internal static func installDebugHandler(_ handler: DebugHandler) {
        let hook: DebugHook
        DebugHook.globalLock.lock()
        if let _hook = DebugHook.globalHook {
            hook = _hook
        } else {
            hook = DebugHook()
            DebugHook.globalHook = hook
        }
        DebugHook.globalLock.unlock()
        hook.handlers.insert(Handler(handler: handler))
    }

    private static var globalHook: DebugHook?

    private static let globalLock = UnfairLock.allocate()

    private let lock = UnfairLock.allocate()

    private var handlers = Set<Handler>()

    private init() {}

    deinit {
        lock.deallocate()
    }

    internal var debugHandlers: [DebugHandler] {
        lock.lock()
        defer { lock.unlock() }
        return handlers.map { $0.handler }
    }

    internal func willReceive<Upstream: Publisher, Downstream: Subscriber>(
        publisher: Upstream,
        subscriber: Downstream
    ) where Upstream.Failure == Downstream.Failure, Upstream.Output == Downstream.Input {
        for debugHandler in debugHandlers {
            debugHandler.willReceive(publisher: publisher, subscriber: subscriber)
        }
    }

    internal func didReceive<Upstream: Publisher, Downstream: Subscriber>(
        publisher: Upstream,
        subscriber: Downstream
    ) where Upstream.Failure == Downstream.Failure, Upstream.Output == Downstream.Input {
        for debugHandler in debugHandlers {
            debugHandler.didReceive(publisher: publisher, subscriber: subscriber)
        }
    }

    internal func willReceive<Downstream: Subscriber>(subscriber: Downstream,
                                                      subscription: Subscription) {
        for debugHandler in debugHandlers {
            debugHandler.willReceive(subscriber: subscriber, subscription: subscription)
        }
    }

    internal func didReceive<Downstream: Subscriber>(subscriber: Downstream,
                                                     subscription: Subscription) {
        for debugHandler in debugHandlers {
            debugHandler.didReceive(subscriber: subscriber, subscription: subscription)
        }
    }

    internal func willReceive<Downstream: Subscriber>(subscriber: Downstream,
                                                      input: Downstream.Input) {
        for debugHandler in debugHandlers {
            debugHandler.willReceive(subscriber: subscriber, input: input)
        }
    }

    internal func didReceive<Downstream: Subscriber>(
        subscriber: Downstream,
        input: Downstream.Input,
        resultingDemand: Subscribers.Demand
    ) {
        for debugHandler in debugHandlers {
            debugHandler.didReceive(subscriber: subscriber,
                                    input: input,
                                    resultingDemand: resultingDemand)
        }
    }

    internal func willReceive<Downstream: Subscriber>(
        subscriber: Downstream,
        completion: Subscribers.Completion<Downstream.Failure>
    ) {
        for debugHandler in debugHandlers {
            debugHandler.willReceive(subscriber: subscriber, completion: completion)
        }
    }

    internal func didReceive<Downstream: Subscriber>(
        subscriber: Downstream,
        completion: Subscribers.Completion<Downstream.Failure>
    ) {
        for debugHandler in debugHandlers {
            debugHandler.didReceive(subscriber: subscriber, completion: completion)
        }
    }

    internal func willRequest(subscription: Subscription, demand: Subscribers.Demand) {
        for debugHandler in debugHandlers {
            debugHandler.willRequest(subscription: subscription, demand: demand)
        }
    }

    internal func didRequest(subscription: Subscription, demand: Subscribers.Demand) {
        for debugHandler in debugHandlers {
            debugHandler.didRequest(subscription: subscription, demand: demand)
        }
    }

    internal func willCancel(subscription: Subscription) {
        for debugHandler in debugHandlers {
            debugHandler.willCancel(subscription: subscription)
        }
    }

    internal func didCancel(subscription: Subscription) {
        for debugHandler in debugHandlers {
            debugHandler.didCancel(subscription: subscription)
        }
    }
}
