import XCTest
@testable import Surfr
import Swifter
import LoggingCamp

final class SurfrTests: XCTestCase {
    func testExample() throws {
        LoggingCamp.setGlobalLoggingLevel(.DEBUG)
        let logger = Logger("SurfrTests")
        logger.debug("Starting SurfrTests")
        let server = Surfr()
        server.addRoute(path: "/") { _ in
            return HttpResponse.ok(.text("Hello, world!"))
        }
        server.registerFileHandlers()
        server.start(port: 8080)
        RunLoop.main.run()
    }
}
