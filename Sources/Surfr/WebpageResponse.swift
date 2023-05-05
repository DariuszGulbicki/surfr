public enum WebpageResponse: Error {

    // HTTP response codes

    // 1xx Informational
    case httpContinue
    case switchingProtocols(protocol: String, response: String = "")
    case processing

    // 2xx Success
    case ok(response: String = "OK")
    case created(response: String = "Created")
    case accepted(response: String = "Accepted")
    case nonAuthoritativeInformation(response: String = "Non-Authoritative Information")
    case noContent
    case resetContent
    case partialContent(range: String, response: String = "")

    // 3xx Redirection
    case multipleChoices(possibilities: [String])
    case movedPermanently(location: String)
    case found(location: String)
    case seeOther(location: String)
    case notModified(rsponse: String = "")
    case useProxy(location: String)
    case temporaryRedirect(location: String)
    case permanentRedirect(location: String)

    // 4xx Client Error

    case badRequest(cause: String = "Unknown")
    case unauthorized
    case paymentRequired
    case forbidden
    case notFound
    case methodNotAllowed
    case notAcceptable
    case proxyAuthenticationRequired
    case requestTimeout
    case conflict
    case gone
    case lengthRequired
    case preconditionFailed
    case payloadTooLarge
    case uriTooLong
    case unsupportedMediaType
    case rangeNotSatisfiable
    case expectationFailed
    case imATeapot
    case misdirectedRequest
    case unprocessableEntity
    case locked
    case failedDependency
    case upgradeRequired
    case preconditionRequired
    case tooManyRequests
    case requestHeaderFieldsTooLarge
    case unavailableForLegalReasons

    // 5xx Server Error
    case internalServerError
    case notImplemented
    case badGateway
    case serviceUnavailable
    case gatewayTimeout
    case httpVersionNotSupported
    case variantAlsoNegotiates
    case insufficientStorage
    case loopDetected
    case notExtended
    case networkAuthenticationRequired
    
    // Custom
    case custom(_ code: Int, response: String = "", customData: [String: String]? = nil)
    
    public static func toData(_ response: WebpageResponse) -> (Int16, String, [String:String]) {
        switch response {
        case .httpContinue:
            return (100, "Continue", [:])
        case .switchingProtocols(let proto, let response):
            return (101, "Switching Protocols", ["Upgrade": proto, "response": response])
        case .processing:
            return (102, "Processing", [:])
        case .ok(let response):
            return (200, "OK", ["response": response])
        case .created(let response):
            return (201, "Created", ["response": response])
        case .accepted(let response):
            return (202, "Accepted", ["response": response])
        case .nonAuthoritativeInformation(let response):
            return (203, "Non-Authoritative Information", ["response": response])
        case .noContent:
            return (204, "No Content", [:])
        case .resetContent:
            return (205, "Reset Content", [:])
        case .partialContent(let range, let response):
            return (206, "Partial Content", ["range": range, "response": response])
        case .multipleChoices(let possibilities):
            return (300, "Multiple Choices", ["possibilities": possibilities.joined(separator: ", ")])
        case .movedPermanently(let location):
            return (301, "Moved Permanently", ["location": location])
        case .found(let location):
            return (302, "Found", ["location": location])
        case .seeOther(let location):
            return (303, "See Other", ["location": location])
        case .notModified(let response):
            return (304, "Not Modified", ["response": response])
        case .useProxy(let location):
            return (305, "Use Proxy", ["location": location])
        case .temporaryRedirect(let location):
            return (307, "Temporary Redirect", ["location": location])
        case .permanentRedirect(let location):
            return (308, "Permanent Redirect", ["location": location])
        case .badRequest(let cause):
            return (400, "Bad Request", ["cause": cause])
        case .unauthorized:
            return (401, "Unauthorized", [:])
        case .paymentRequired:
            return (402, "Payment Required", [:])
        case .forbidden:
            return (403, "Forbidden", [:])
        case .notFound:
            return (404, "Not Found", [:])
        case .methodNotAllowed:
            return (405, "Method Not Allowed", [:])
        case .notAcceptable:
            return (406, "Not Acceptable", [:])
        case .proxyAuthenticationRequired:
            return (407, "Proxy Authentication Required", [:])
        case .requestTimeout:
            return (408, "Request Timeout", [:])
        case .conflict:
            return (409, "Conflict", [:])
        case .gone:
            return (410, "Gone", [:])
        case .lengthRequired:
            return (411, "Length Required", [:])
        case .preconditionFailed:
            return (412, "Precondition Failed", [:])
        case .payloadTooLarge:
            return (413, "Payload Too Large", [:])
        case .uriTooLong:
            return (414, "URI Too Long", [:])
        case .unsupportedMediaType:
            return (415, "Unsupported Media Type", [:])
        case .rangeNotSatisfiable:
            return (416, "Range Not Satisfiable", [:])
        case .expectationFailed:
            return (417, "Expectation Failed", [:])
        case .imATeapot:
            return (418, "I'm a teapot", ["Secret":"I'm a teapot"])
        case .misdirectedRequest:
            return (421, "Misdirected Request", [:])
        case .unprocessableEntity:
            return (422, "Unprocessable Entity", [:])
        case .locked:
            return (423, "Locked", [:])
        case .failedDependency:
            return (424, "Failed Dependency", [:])
        case .upgradeRequired:
            return (426, "Upgrade Required", [:])
        case .preconditionRequired:
            return (428, "Precondition Required", [:])
        case .tooManyRequests:
            return (429, "Too Many Requests", [:])
        case .requestHeaderFieldsTooLarge:
            return (431, "Request Header Fields Too Large", [:])
        case .unavailableForLegalReasons:
            return (451, "Unavailable For Legal Reasons", [:])
        case .internalServerError:
            return (500, "Internal Server Error", [:])
        case .notImplemented:
            return (501, "Not Implemented", [:])
        case .badGateway:
            return (502, "Bad Gateway", [:])
        case .serviceUnavailable:
            return (503, "Service Unavailable", [:])
        case .gatewayTimeout:
            return (504, "Gateway Timeout", [:])
        case .httpVersionNotSupported:
            return (505, "HTTP Version Not Supported", [:])
        case .variantAlsoNegotiates:
            return (506, "Variant Also Negotiates", [:])
        case .insufficientStorage:
            return (507, "Insufficient Storage", [:])
        case .loopDetected:
            return (508, "Loop Detected", [:])
        case .notExtended:
            return (510, "Not Extended", [:])
        case .networkAuthenticationRequired:
            return (511, "Network Authentication Required", [:])
        case .custom(let code, let response, let customData):
            return (Int16(code), response, customData ?? [:])
        }
    }

}