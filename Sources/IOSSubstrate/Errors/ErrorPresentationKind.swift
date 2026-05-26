public import Foundation

/// Product-neutral error classification for user-facing copy gates.
///
/// Substrate owns only the stable technical categories. Product apps own the
/// localized words, support-code policy, and domain-specific error mapping.
public enum ErrorPresentationKind: Equatable, Sendable {
    case badRequest
    case cancelled
    case conflict
    case forbidden
    case invalidRequest
    case invalidResponse
    case networkOffline
    case networkSecureConnectionFailed
    case networkTimedOut
    case networkUnreachable
    case notFound
    case rateLimited
    case serverUnavailable
    case unauthenticated
    case unknown

    public static func classify(httpStatus status: Int) -> Self {
        if let kind = httpStatusKinds[status] {
            return kind
        }

        if (500...599).contains(status) {
            return .serverUnavailable
        }

        return .unknown
    }

    public static func classify(urlError: URLError) -> Self {
        urlErrorKinds[urlError.code] ?? .networkUnreachable
    }

    public static func classify(nsError: NSError) -> Self? {
        guard nsError.domain == NSURLErrorDomain else {
            return nil
        }

        return classify(urlError: URLError(URLError.Code(rawValue: nsError.code)))
    }

    private static let httpStatusKinds: [Int: Self] = [
        400: .badRequest,
        401: .unauthenticated,
        403: .forbidden,
        404: .notFound,
        408: .networkTimedOut,
        409: .conflict,
        422: .badRequest,
        429: .rateLimited,
    ]

    private static let urlErrorKinds: [URLError.Code: Self] = [
        .badURL: .invalidRequest,
        .cancelled: .cancelled,
        .cannotConnectToHost: .networkUnreachable,
        .cannotFindHost: .networkUnreachable,
        .dnsLookupFailed: .networkUnreachable,
        .networkConnectionLost: .networkOffline,
        .notConnectedToInternet: .networkOffline,
        .secureConnectionFailed: .networkSecureConnectionFailed,
        .serverCertificateHasBadDate: .networkSecureConnectionFailed,
        .serverCertificateHasUnknownRoot: .networkSecureConnectionFailed,
        .serverCertificateNotYetValid: .networkSecureConnectionFailed,
        .serverCertificateUntrusted: .networkSecureConnectionFailed,
        .timedOut: .networkTimedOut,
        .unsupportedURL: .invalidRequest,
    ]
}
