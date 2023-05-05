import LoggingCamp
import Swifter
import Foundation

public class Surfr {
    
    public typealias WebpageHandler = (HttpRequest) throws -> WebpageResponse

    private var logger: Logger?
    private var requestLogger: Logger?

    private var userDefinedWebpages: [String] = []

    private var specialHandlers: [Int16: (HttpRequest, String, [String:String]) -> HttpResponse] = [
        404: { request, _, _ in
            return HttpResponse.notFound
        },
        500: { request, _, _ in
            return HttpResponse.internalServerError
        },
        0: { request, _, _ in
            return HttpResponse.internalServerError
        },
    ]

    private var extensionHandlers: [String: any ExtensionHandler] = [
        "html": BasicExtensionHandler(serverHeader: "Surfr"),
        "css": BasicExtensionHandler(serverHeader: "Surfr"),
        "js": BasicExtensionHandler(serverHeader: "Surfr"),
        "json": BasicExtensionHandler(serverHeader: "Surfr"),
        "png": BasicExtensionHandler(serverHeader: "Surfr"),
        "jpg": BasicExtensionHandler(serverHeader: "Surfr"),
        "jpeg": BasicExtensionHandler(serverHeader: "Surfr"),
        "gif": BasicExtensionHandler(serverHeader: "Surfr"),
        "svg": BasicExtensionHandler(serverHeader: "Surfr"),
        "ico": BasicExtensionHandler(serverHeader: "Surfr"),
        "txt": BasicExtensionHandler(serverHeader: "Surfr"),
        "md": MarkdownExtensionHandler(css: .link("markdown.css")),
        "*": BasicExtensionHandler(serverHeader: "Surfr"),
    ]

    let server: HttpServer

    public init(logging: Bool = true, logger: Logger? = Logger("Surfr WebServer"), requestLogger: Logger? = Logger("Surfr Request")) {
        self.logger = logger
        self.requestLogger = requestLogger
        server = HttpServer()
        server.notFoundHandler = { request in
            return self.specialHandlers[404]!(request, "", [:])
        }
        if (logging) {
            server.middleware.append { request in
                // (SERVER PORT): (METHOD) (PATH) -> (CLIENT IP) ((USER AGENT)) 
                self.requestLogger?.info("\(request.headers["host"] ?? "unknown") [\(request.method) \(request.path)] -> \(request.address ?? "unknown") (\(request.headers["user-agent"] ?? "unknown"))")
                return nil
            }
        }
    }

    private func serveHotReload(file: String, request: HttpRequest, handlerFor: String? = nil) -> HttpResponse? {
        do {
            if (try file.exists()) {
                do {
                    requestLogger?.info("Serving file: \(file)")
                    requestLogger?.debug("Reading file")
                    let data = try String(contentsOfFile: file)
                    let ext = file.split(separator: ".").last!
                    requestLogger?.debug("Determined file extension as: \(ext)")
                    let handler: ExtensionHandler
                    if (handlerFor != nil) {
                        handler = self.extensionHandlers[handlerFor!] ?? self.extensionHandlers["*"]!
                    } else {
                        handler = self.extensionHandlers[String(ext)] ?? self.extensionHandlers["*"]!
                    }
                    requestLogger?.debug("Serving response: \(handler)")
                    do {
                        return try handler.handle(data: data, request: request)
                    } catch let res where res is WebpageResponse {
                        return processWebpageResponse(res as! WebpageResponse)
                    }
                }
            }
        } catch {
            requestLogger?.error("File not found: \(file)")
            return self.specialHandlers[404]!(request, "Not Found", [:])
        }
        return nil
    }

    private func hotCheckForSpecialHandler(_ relativeDirectory: String, _ reponseCode: Int16) -> HttpResponse {
        let directory = FileManager.default.currentDirectoryPath + "/" + relativeDirectory
        do {
            let reponseCodeString = String(describing: reponseCode)
            let files = try FileManager.default.contentsOfDirectory(atPath: directory)
            for file in files {
                if (file == reponseCodeString + ".html") {
                    logger?.info("Found special handler for \(reponseCode): \(directory + "/" + file)")
                    self.registerSpecialHandler(code: Int16(reponseCodeString)!, handler: { request, _, _ in
                        do {
                            let data = try String(contentsOfFile: directory + "/" + file)
                            return try self.extensionHandlers["html"]!.handle(data: data, request: request)
                        } catch {
                            self.logger?.error("Error while serving special handler: \(error)")
                            return self.specialHandlers[500]!(request, "Error", ["error": "\(error)"])
                        }
                    })
                } else if (file == reponseCodeString + ".json") {
                    logger?.info("Found special handler for \(reponseCode): \(directory + "/" + file)")
                    self.registerSpecialHandler(code: Int16(reponseCodeString)!, handler: { request, _, _ in
                        do {
                            let data = try String(contentsOfFile: directory + "/" + file)
                            return try self.extensionHandlers["json"]!.handle(data: data, request: request)
                        } catch {
                            self.logger?.error("Error while serving special handler: \(error)")
                            return self.specialHandlers[500]!(request, "Error", ["error": "\(error)"])
                        }
                    })
                } else if (file == reponseCodeString + ".txt") {
                    logger?.info("Found special handler for \(reponseCode): \(directory + "/" + file)")
                    self.registerSpecialHandler(code: Int16(reponseCodeString)!, handler: { request, _, _ in
                        do {
                            let data = try String(contentsOfFile: directory + "/" + file)
                            return try self.extensionHandlers["txt"]!.handle(data: data, request: request)
                        } catch {
                            self.logger?.error("Error while serving special handler: \(error)")
                            return self.specialHandlers[500]!(request, "Error", [:])
                        }
                    })
                } else if (file == reponseCodeString + ".md") {
                    logger?.info("Found special handler for \(reponseCode): \(directory + "/" + file)")
                    self.registerSpecialHandler(code: Int16(reponseCodeString)!, handler: { request, _, _ in
                        do {
                            let data = try String(contentsOfFile: directory + "/" + file)
                            return try self.extensionHandlers["md"]!.handle(data: data, request: request)
                        } catch {
                            self.logger?.error("Error while serving special handler: \(error)")
                            return self.specialHandlers[500]!(request, "Error", ["error":"\(error)"])
                        }
                    })
                }
            }
        } catch {
            logger?.error("Error while checking for special handlers: \(error)")
        }
        return self.specialHandlers[reponseCode]?(HttpRequest(), "Error", [:]) ?? .internalServerError
    }

    private func processWebpageResponse(_ res: WebpageResponse) -> HttpResponse {
        let resData = WebpageResponse.toData(res)
        return specialHandlers[resData.0]?(HttpRequest(), resData.1, resData.2) ?? HttpResponse.raw(Int(resData.0), resData.1, resData.2, { writer in
            if (resData.2["response"] != nil) {
                try writer.write(Array(resData.2["response"]!.utf8))
            } else {
                try writer.write(Array(resData.1.utf8))
            }
        })
    }

    public func addRoute(path: String, handler: @escaping (HttpRequest) -> HttpResponse) {
        server[path] = handler
    }

    public func webpage(path: String, handler: @escaping WebpageHandler) {
        userDefinedWebpages.append(path)
        server[path] = { request in
            do {
                let data = try handler(request)
                let resData = WebpageResponse.toData(data)
                return HttpResponse.raw(Int(resData.0), resData.1, resData.2, { writer in
                    if (resData.2["response"] != nil) {
                        try writer.write(Array(resData.2["response"]!.utf8))
                    } else {
                        try writer.write(Array(resData.1.utf8))
                    }
                })
            } catch let res where res is WebpageResponse {
                self.requestLogger?.debug("Webpage handler returned WebpageResponse: \(res) \(WebpageResponse.toData(res as! WebpageResponse))")
                return self.processWebpageResponse(res as! WebpageResponse)
            } catch {
                self.requestLogger?.error("Error while serving webpage: \(error)")
                return self.specialHandlers[500]!(request, "Error", [:])
            }
        } as (HttpRequest) -> HttpResponse
    }

    public func registerSpecialHandler(code: Int16, handler: @escaping (HttpRequest, String, [String:String]?) -> HttpResponse) {
        specialHandlers[code] = handler
    }

    public func registerExtensionHandler(extensionHandler: ExtensionHandler, forExtension ext: String) {
        self.extensionHandlers[ext] = extensionHandler
    }

    public func registerFileHandlers(directory: String, registerCleanPath: Bool = true) {
        logger?.debug("Registering file handlers for directory: \(directory)")
        directoryLookup(directory: directory, actualPath: "")
    }

    private func directoryLookup(directory: String, actualPath: String, registerCleanPath: Bool = true) {
        logger?.debug("(handler registration) Directory lookup: \(directory)")
        var files: [String] = []
        do {
            files = try FileManager.default.contentsOfDirectory(atPath: directory)
        } catch {
            logger?.error("(handler registration) Directory not found: \(directory)")
        }
        for file in files {
            if (file.isEmpty || file.starts(with: ".")) {
                continue
            }
            do {
                if (try file.directory()) {
                    logger?.debug("(handler registration) Found directory: \(file)")
                    directoryLookup(directory: directory + "/" + file, actualPath: actualPath + "/" + file, registerCleanPath: registerCleanPath)
                    continue
                } else {
                    logger?.debug("(handler registration) Found file: \(file)")
                    if (!userDefinedWebpages.contains(actualPath + "/" + file)) {
                        registerHandler(directory + "/" + file, actualPath + "/" + file, registerCleanPath)
                    } else {
                        logger?.warn("(handler registration) User defined webpage already exists for path: \(actualPath + "/" + file)")
                    }
                }
            } catch let error as NSError {
                logger?.error("(handler registration) Error while checking if file is directory: \(error)")
            } catch {
                logger?.error("(handler registration) Cannot perform handler registration for: \(actualPath)")
            }
        }
    }

    private func registerHandler(_ path: String, _ actualPath: String, _ registerCleanPath: Bool = true) {
        logger?.debug("(handler registration) Registering file handler for path: \(actualPath)")
        let ext = path.components(separatedBy: ".").last!
        let handler: ExtensionHandler = extensionHandlers[ext] ?? extensionHandlers["*"]!
        if (server[actualPath] != nil) {
            logger?.warn("(handler registration) Handler already exists for path: \(actualPath)")
            return
        }
        do {
            let data = try String(contentsOfFile: path)
            server[actualPath] = { request -> Swifter.HttpResponse in
                do {
                    return try handler.handle(data: data, request: request)
                } catch let res where res is WebpageResponse {
                    let res = res as? WebpageResponse ?? .internalServerError
                    return self.processWebpageResponse(res)
                } catch {
                    self.logger?.error("(handler registration) Error while serving file: \(error)")
                    return self.specialHandlers[500]!(request, "Error", ["error": "\(error)"])
                }
            } as ((HttpRequest) -> HttpResponse)
        } catch let error as NSError {
            if (error.code == 256) {
                logger?.debug("(handler registration) [WARNING] Directory found instead of file: \(path) (ignoring)")
                return
            }
            logger?.error("(handler registration) Error while reading file: \(error)")
        } catch {
            logger?.error("(handler registration) Cannot register handler for: \(actualPath)")
        }
        if (registerCleanPath) {
            let cleanPath = actualPath.components(separatedBy: ".").dropLast().joined(separator: ".")
            registerHandler(path, cleanPath, false)
        }
    }

    public func registerFileHandlers(relativeDirectory: String, registerCleanPath: Bool = true) {
        let directory = FileManager.default.currentDirectoryPath + "/" + relativeDirectory
        registerFileHandlers(directory: directory)
    }

    public func registerFileHandlers(registerCleanPath: Bool = true) {
        registerFileHandlers(relativeDirectory: "pages", registerCleanPath: registerCleanPath)
    }

    public func registerSpecialHandlerFromFile(responseType: Int16, file: String) {
        do {
            logger?.debug("(Special handler file registration) Registering special handler for code: \(responseType)")
            let content = try String(contentsOfFile: file)
            logger?.debug("(Special handler file registration) Found \(content.count) bytes of content")
            logger?.debug("(Special handler file registration) Assigning handler for code: \(responseType)")
            specialHandlers[responseType] = { request, title, data -> HttpResponse in
                return .raw(Int(responseType), title, data, { writer in
                    try writer.write(Array((content.utf8)))
                })
            }
        } catch {
            logger?.error("File not found: \(file)")
        }
    }

    public func registerSpecialHandlers(directory: String) {
        logger?.debug("Registering special handlers from directory: \(directory)")
        do {
            if (try directory.exists()) {
                var assigned: [String] = []
                let files = try FileManager.default.contentsOfDirectory(atPath: directory)
                for file in files {
                    if (try! file.directory()) {
                        logger?.debug("(Special handler registration) Skipping directory: \(file)")
                        continue
                    }
                    let path = directory + "/" + file
                    let ext = file.components(separatedBy: ".").last!
                    let name = file.components(separatedBy: ".").first!
                    if (ext == "html" || ext == "htm" || ext == "txt" || ext == "json" || ext == "md") {
                        if (assigned.contains(name)) {
                            logger?.warn("(Special handler registration) Special handler already assigned: \(name)")
                            continue
                        }
                        assigned.append(name)
                        logger?.debug("(Special handler registration) Assigning special handler: \(name) -> \(path)")
                        registerSpecialHandlerFromFile(responseType: Int16(name)!, file: path)
                    } else {
                        logger?.warn("(Special handler registration) Cannot assign file of type \(ext) as a special handler. Skipping...")
                    }
                }
            } else {
                logger?.error("(Special handler registration) Directory not found: \(directory)")
            }
        } catch {
            logger?.error("Error while performing operations", error)
        }
    }

    private func registerNotFoundPage(handler: @escaping (HttpRequest) -> HttpResponse) {
        server.notFoundHandler = handler
    }

    public func registerSpecialHandlers(relativeDirectory: String) {
        let directory = FileManager.default.currentDirectoryPath + "/" + relativeDirectory
        registerSpecialHandlers(directory: directory)
    }

    public func registerSpecialHandlers() {
        registerSpecialHandlers(relativeDirectory: "pages/errors")
    }

    public func registerIndexFromDirectory(directory: String, indexFileName: String = "index") {
        logger?.debug("Registering index from directory: \(directory)")
        let files = try! FileManager.default.contentsOfDirectory(atPath: directory)
        for file in files {
            if (try! file.directory()) {
                logger?.debug("[Index handler registration] Skipping directory: \(file)")
                continue
            }
            let path = directory + "/" + file
            let ext = file.components(separatedBy: ".").last!
            let name = file.components(separatedBy: ".").first!
            if (ext == "html" || ext == "htm" || ext == "txt" || ext == "md") {
                if (name == indexFileName) {
                    registerHandler(path, "/")
                    logger?.debug("Registered \(file) as an index handler")
                }
            } else {
                logger?.debug("Cannot assign file of type \(ext) as an index handler. Skipping...")
            }
        }
    }

    public func registerIndexFromDirectory(relativeDirectory: String) {
        let relativeDirectory = FileManager.default.currentDirectoryPath + "/" + relativeDirectory
        registerIndexFromDirectory(directory: relativeDirectory)
    }

    public func registerDirectory(relativeDirectory: String, specialRelativeDirectory: String) {
        registerIndexFromDirectory(relativeDirectory: relativeDirectory)
        registerFileHandlers(relativeDirectory: relativeDirectory)
        registerSpecialHandlers(relativeDirectory: specialRelativeDirectory)
    }

    public func start(port: UInt16 = 80, forceIPv4: Bool = false, priority: DispatchQoS.QoSClass = .default) {
        logger?.info("Starting Surfr Webserver on port \(port)")
        do {
            try server.start(port, forceIPv4: forceIPv4, priority: priority)
            logger?.info("Server started on port \(port)")
        } catch {
            logger?.fatal("Failed to start server at port \(port): \(error)")
        }
    }

    public func enableHotReload(relativeDirectory: String, specialRelativeDirectory: String) {
        logger?.info("Enabling hot reload for directory: \(relativeDirectory)")
        let hotReloadDir = FileManager.default.currentDirectoryPath + "/" + relativeDirectory
        self.server.middleware.append {request -> HttpResponse? in 
        if (self.userDefinedWebpages.contains(request.path)) {
            self.logger?.debug("User defined webpage detected. Skipping hot reload.")
            return nil
        }
        self.requestLogger?.debug("Hot reload triggered for path: \(request.path)")
        let file = hotReloadDir + request.path
        // index (/) handling
        if (request.path == "/") {
            self.requestLogger?.debug("Index (/) detected. Triggering directory search.")
            for possibleExtension in self.extensionHandlers.keys {
                if (possibleExtension == "*") {
                    continue
                }
                let out = self.serveHotReload(file: file + "index." + possibleExtension, request: request, handlerFor: possibleExtension)
                if (out != nil) {
                    return out!
                }
            }
        }
        let pathext = request.path.split(separator: ".")
        if (pathext.count == 1) {
            self.requestLogger?.debug("No extension detected. Triggering directory search.")
            for possibleExtension in self.extensionHandlers.keys {
                if (possibleExtension == "*") {
                    continue
                }
                let out = self.serveHotReload(file: file + "." + possibleExtension, request: request, handlerFor: possibleExtension)
                if (out != nil) {
                    return out!
                }
            }
        } else {
            return self.serveHotReload(file: file, request: request) ?? self.hotCheckForSpecialHandler(specialRelativeDirectory, 404)
        }
        return self.hotCheckForSpecialHandler(specialRelativeDirectory, 404)
        }
    }

    public func stop() {
        logger?.warn("Stopping Surfr Webserver.")
        logger?.warn("Stopping the server is recomended only in specific cases. Make sure that you know what you are doing!")
        server.stop()
    }

}
