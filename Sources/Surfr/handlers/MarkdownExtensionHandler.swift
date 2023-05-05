import Swifter
import Ink

public class MarkdownExtensionHandler: ExtensionHandler {

    public enum CssType {
        case link(String)
        case inline(String)
    }

    let returnString: String
    let defaultHeaders: [String:String]

    public init(template: String = "<html><head><title>Webpage</title>{{css}}</head><body>{{md}}</body></html>", css: CssType? = nil, defaultHeaders: [String: String] = ["Server":"Surfr (Markdown renderer)"]) {
        let template = template
        self.defaultHeaders = defaultHeaders
        let rcss: String
        if (css != nil) {
            switch css {
            case .link(let link):
                rcss = "<link rel=\"stylesheet\" href=\"\(link)\">"
            case .inline(let css):
                rcss = "<style>\(css)</style>"
            default:
                rcss = ""
            }
        } else {
            rcss = ""
        }
        returnString = template
            .replacingOccurrences(of: "{{css}}", with: rcss)
    }

    public func handle(data: String, request: HttpRequest) -> HttpResponse {
        let parser = MarkdownParser()
        let md = parser.html(from: data)
        let html = returnString
            .replacingOccurrences(of: "{{md}}", with: md)
        return .raw(200, "OK", defaultHeaders, { writer in
            try writer.write(html.data(using: .utf8)!)
        })
    }

}