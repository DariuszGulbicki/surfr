import Swifter

public protocol ExtensionHandler {

    func handle(data: String, request: HttpRequest) throws -> HttpResponse

}