//
//  SubscriptionTap.swift
//  
//
//  Created by Sergej Jaskiewicz on 02.02.2020.
//

internal struct SubscriptionTap: Subscription, CustomStringConvertible {

    internal let subscription: Subscription

    internal var combineIdentifier: CombineIdentifier {
        return subscription.combineIdentifier
    }

    internal func request(_ demand: Subscribers.Demand) {
        if let hook = DebugHook.getGlobalHook() {
            hook.willRequest(subscription: self, demand: demand)
            subscription.request(demand)
            hook.didRequest(subscription: self, demand: demand)
        } else {
            subscription.request(demand)
        }
    }

    internal func cancel() {
        if let hook = DebugHook.getGlobalHook() {
            hook.willCancel(subscription: subscription)
            subscription.cancel()
            hook.didCancel(subscription: subscription)
        } else {
            subscription.cancel()
        }
    }

    internal var description: String {
        return "\(subscription)"
    }
}
