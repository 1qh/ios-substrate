import CoreGraphics
import Foundation
@testable import IOSSubstrate
import SwiftUI
import Testing

@Test
internal func `flow layout exposes deterministic product neutral defaults`() {
    let layout = FlowLayout()

    #expect(layout.spacing == 8)
    #expect(layout.maxWidth == nil)
}

@Test
internal func `flow layout keeps explicit spacing and width`() {
    let layout = FlowLayout(spacing: 6, maxWidth: 320)

    #expect(layout.spacing == 6)
    #expect(layout.maxWidth == 320)
}

@Test
internal func `haptic feedback helpers are safe to call in tests`() {
    HapticFeedback.light()
    HapticFeedback.medium()
    HapticFeedback.heavy()
    HapticFeedback.success()
    HapticFeedback.warning()
    HapticFeedback.error()
    HapticFeedback.selection()
}

@Test
internal func `display string separates localized resources from user content`() {
    let localized = DisplayString.localized("Ready")
    let userContent = DisplayString.userContent("Merchant typed value")

    #expect(localized == .localized("Ready"))
    #expect(userContent == .userContent("Merchant typed value"))
}

@Test
internal func `load state exposes loaded value only for loaded phase`() {
    let loaded = LoadState<String, String>.loaded("ready")
    let loading = LoadState<String, String>.loading

    #expect(loaded.value == "ready")
    #expect(loading.value == nil)
}

@Test
@MainActor
internal func `load state content accepts every product owned renderer`() {
    let loaded = LoadState<String, String>.loaded("ready")
    let view = LoadStateContent(state: loaded) {
        Text("Loading")
    } content: { value in
        Text(value)
    } empty: {
        Text("Empty")
    } failed: { failure in
        Text(failure)
    }

    _ = view.body
    #expect(String(describing: type(of: view)).contains("LoadStateContent"))
}

@Test
internal func `submit error keeps stable identity and product-owned copy`() {
    let id = UUID()
    let error = SubmitError(title: "Retry", message: "Network unavailable", id: id)

    #expect(error.id == id)
    #expect(error.message == "Network unavailable")
    #expect(error == SubmitError(title: "Ignored by equality", message: "Network unavailable", id: id))
    #expect(error != SubmitError(title: "Retry", message: "Network unavailable"))
}

@Test
internal func `error presentation kind classifies http url and ns errors`() {
    #expect(ErrorPresentationKind.classify(httpStatus: 400) == .badRequest)
    #expect(ErrorPresentationKind.classify(httpStatus: 401) == .unauthenticated)
    #expect(ErrorPresentationKind.classify(httpStatus: 403) == .forbidden)
    #expect(ErrorPresentationKind.classify(httpStatus: 404) == .notFound)
    #expect(ErrorPresentationKind.classify(httpStatus: 408) == .networkTimedOut)
    #expect(ErrorPresentationKind.classify(httpStatus: 409) == .conflict)
    #expect(ErrorPresentationKind.classify(httpStatus: 429) == .rateLimited)
    #expect(ErrorPresentationKind.classify(httpStatus: 503) == .serverUnavailable)
    #expect(ErrorPresentationKind.classify(httpStatus: 418) == .unknown)

    #expect(ErrorPresentationKind.classify(urlError: URLError(.notConnectedToInternet)) == .networkOffline)
    #expect(ErrorPresentationKind.classify(urlError: URLError(.timedOut)) == .networkTimedOut)
    #expect(ErrorPresentationKind.classify(urlError: URLError(.cannotFindHost)) == .networkUnreachable)
    #expect(ErrorPresentationKind.classify(urlError: URLError(.serverCertificateUntrusted)) == .networkSecureConnectionFailed)
    #expect(ErrorPresentationKind.classify(urlError: URLError(.badURL)) == .invalidRequest)
    #expect(ErrorPresentationKind.classify(urlError: URLError(.cancelled)) == .cancelled)

    let nsError = NSError(domain: NSURLErrorDomain, code: URLError.notConnectedToInternet.rawValue)
    #expect(ErrorPresentationKind.classify(nsError: nsError) == .networkOffline)
    #expect(ErrorPresentationKind.classify(nsError: NSError(domain: "other", code: 1)) == nil)
}
