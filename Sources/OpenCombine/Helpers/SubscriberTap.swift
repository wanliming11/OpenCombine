//
//  SubscriberTap.swift
//  
//
//  Created by Sergej Jaskiewicz on 02.02.2020.
//

internal protocol SubscriberTapMarker {
    var inner: Any { get }
}

internal struct SubscriberTap<Subscriber: OpenCombine.Subscriber>
    : OpenCombine.Subscriber,
      CustomStringConvertible,
      SubscriberTapMarker
{
    internal typealias Input = Subscriber.Input

    internal typealias Failure = Subscriber.Failure

    private let subscriber: Subscriber

    private let _inner: Any?

    internal var inner: Any {
        if let inner = _inner {
            return inner
        } else {
            return AnySubscriber(subscriber)
        }
    }

    internal init(subscriber: Subscriber, inner: Any?) {
        self.subscriber = subscriber
        self._inner = inner
    }

    internal var combineIdentifier: CombineIdentifier {
        return subscriber.combineIdentifier
    }

    internal func receive(subscription: Subscription) {
        if let hook = DebugHook.getGlobalHook() {
            if let subscriptionTap = subscription as? SubscriptionTap {
                hook.willReceive(subscriber: self,
                                 subscription: subscriptionTap.subscription)
                subscriber.receive(subscription: subscription)
                hook.didReceive(subscriber: self,
                                subscription: subscriptionTap.subscription)
            } else {
                hook.willReceive(subscriber: self, subscription: subscription)
                subscriber.receive(subscription: subscription)
                hook.didReceive(subscriber: self, subscription: subscription)
            }
        } else {
            subscriber.receive(subscription: subscription)
        }
    }

    internal func receive(_ input: Input) -> Subscribers.Demand {
        if let hook = DebugHook.getGlobalHook() {
            hook.willReceive(subscriber: self, input: input)
            let newDemand = subscriber.receive(input)
            hook.didReceive(subscriber: self, input: input, resultingDemand: newDemand)
            return newDemand
        } else {
            return subscriber.receive(input)
        }
    }

    internal func receive(completion: Subscribers.Completion<Subscriber.Failure>) {
        if let hook = DebugHook.getGlobalHook() {
            hook.willReceive(subscriber: self, completion: completion)
            subscriber.receive(completion: completion)
            hook.didReceive(subscriber: self, completion: completion)
        } else {
            subscriber.receive(completion: completion)
        }
    }

    internal var description: String {
        return "\(subscriber)"
    }
}
