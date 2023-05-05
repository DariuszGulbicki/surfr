enum WebpageException {
    
    case notFound(String?)
    case notAllowed(String?)
    case methodNotAllowed(String?)
    case ok(String?)
    case badRequest(String?)
    case internalServerError(String?)
    case unauthorized(String?)
    case forbidden(String?)

}