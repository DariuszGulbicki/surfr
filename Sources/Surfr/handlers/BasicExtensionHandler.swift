import Swifter

public class BasicExtensionHandler: ExtensionHandler {

    private var defaultHeaders: [String:String]

    public init(serverHeader: String? = "Surfr", defaultHeaders: [String: String] = [:]) {
        self.defaultHeaders = defaultHeaders
        if let serverHeader = serverHeader {
            self.defaultHeaders["Server"] = serverHeader
        }
    }

    public func handle(data: String, request: Swifter.HttpRequest) -> HttpResponse {
        return HttpResponse.raw(200, "OK", defaultHeaders, { writer in
            try writer.write(data.data(using: .utf8)!)
        })
    }

}