//
//  OSSignPostDebugHandler.swift
//  
//
//  Created by Sergej Jaskiewicz on 02.02.2020.
//

#if canImport(os)

// swiftlint:disable:next no_foundation_dependency
import Foundation
import os.signpost

@available(macOS 10.14, iOS 12.0, watchOS 5.0, tvOS 12.0, *)
internal final class OSSignPostDebugHandler: DebugHandler {

    private let log = OSLog(subsystem: "org.opencombine.OpenCombine",
                            category: "Reactive traffic")

    internal func willReceive<Upstream: Publisher, Downstream: Subscriber>(
        publisher: Upstream,
        subscriber: Downstream
    ) where Upstream.Failure == Downstream.Failure, Upstream.Output == Downstream.Input {
        os_signpost(.begin,
                    log: log,
                    name: "Subscribing",
                    signpostID: subscriber.signpostID,
                    "Subscribing '%@' to '%@'",
                    "\(publisher)",
                    "\(subscriber)")
    }

    internal func didReceive<Upstream: Publisher, Downstream: Subscriber>(
        publisher: Upstream,
        subscriber: Downstream
    ) where Upstream.Failure == Downstream.Failure, Upstream.Output == Downstream.Input {
        os_signpost(.end,
                    log: log,
                    name: "Subscribing",
                    signpostID: subscriber.signpostID)
    }

    internal func willReceive<Downstream: Subscriber>(subscriber: Downstream,
                                                      subscription: Subscription) {
        os_signpost(.begin,
                    log: log,
                    name: "Receiving subscription",
                    signpostID: subscriber.signpostID,
                    "'%@' receives subscription '%@'",
                    "\(subscriber)",
                    "\(subscription)")
    }

    internal func didReceive<Downstream: Subscriber>(subscriber: Downstream,
                                                     subscription: Subscription) {
        os_signpost(.end,
                    log: log,
                    name: "Receiving subscription",
                    signpostID: subscriber.signpostID)
    }

    internal func willReceive<Downstream: Subscriber>(subscriber: Downstream,
                                                      input: Downstream.Input) {
        os_signpost(.begin,
                    log: log,
                    name: "Receiving input",
                    signpostID: subscriber.signpostID,
                    "'%@' receives input '%@'",
                    "\(subscriber)",
                    "\(input)")
    }

    internal func didReceive<Downstream: Subscriber>(
        subscriber: Downstream,
        input: Downstream.Input,
        resultingDemand: Subscribers.Demand
    ) {
        os_signpost(.end,
                    log: log,
                    name: "Receiving input",
                    signpostID: subscriber.signpostID,
                    "Resulting demand: %@",
                    "\(resultingDemand)")
    }

    internal func willReceive<Downstream: Subscriber>(
        subscriber: Downstream,
        completion: Subscribers.Completion<Downstream.Failure>
    ) {
        switch completion {
        case .finished:
            os_signpost(.begin,
                        log: log,
                        name: "Receiving completion",
                        signpostID: subscriber.signpostID,
                        "'%@' finishes",
                        "\(subscriber)")
        case .failure(let error):
            os_signpost(.begin,
                        log: log,
                        name: "Receiving completion",
                        signpostID: subscriber.signpostID,
                        "'%@' fails with error '%@'",
                        "\(subscriber)",
                        "\(error)")
        }
    }

    internal func didReceive<Downstream: Subscriber>(
        subscriber: Downstream,
        completion: Subscribers.Completion<Downstream.Failure>
    ) {
        os_signpost(.end,
                    log: log,
                    name: "Receiving completion",
                    signpostID: subscriber.signpostID)
    }

    internal func willRequest(subscription: Subscription, demand: Subscribers.Demand) {
        os_signpost(.begin,
                    log: log,
                    name: "Requesting",
                    signpostID: subscription.signpostID,
                    "'%@' is requested for '%@' elements",
                    "\(subscription)",
                    "\(demand)")
    }

    internal func didRequest(subscription: Subscription, demand: Subscribers.Demand) {
        os_signpost(.end,
                    log: log,
                    name: "Requesting",
                    signpostID: subscription.signpostID)
    }

    internal func willCancel(subscription: Subscription) {
        os_signpost(.begin,
                    log: log,
                    name: "Cancelling",
                    signpostID: subscription.signpostID,
                    "'%@' is being cancelled")
    }

    internal func didCancel(subscription: Subscription) {
        os_signpost(.end,
                    log: log,
                    name: "Cancelling",
                    signpostID: subscription.signpostID)
    }
}

@available(macOS 10.14, iOS 12.0, watchOS 5.0, tvOS 12.0, *)
extension CustomCombineIdentifierConvertible {
    fileprivate var signpostID: OSSignpostID {
        return .init(combineIdentifier.value)
    }
}

#endif
