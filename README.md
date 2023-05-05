# Surfr

Powerful and intuitive web server for Swift

## Features

- **Easy to use**: Surfr is designed to be easy to use. You can create a web server with just a few lines of code.
- **Powerful**: Surfr is powerful. It supports routing, middleware, and more.
- **Intuitive**: Surfr is intuitive. It is designed to be easy to understand and use.

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/DariuszGulbicki/surfr.git", from: "1.0.0")
]
```

## Usage

Surfr is easy to use. You can create a web server with just a few lines of code.

### Load pages from directory

You can load pages from directory. This is useful when you want to create a simple website.

```swift
import Surfr

// Create a new Surfr server
let server = Surfr()

// Register directory containing pages
// Relative directory contains pages and special relative directory contains error pages in format <status code>.<extensions>
// For example 404.html is a page for 404 error
// Relative directory is relative to the directory containing the executable
// Special relative directory is relative to the directory containing the executable
server.registerDirectory(relativeDirectory: "pages", specialRelativeDirectory: "pages/errors")

// Start the server
server.start()
```

### Hot reload

Hot reload is useful when you are developing a website. It reloads pages when they are changed.

```swift
import Surfr

// Create a new Surfr server
let server = Surfr()

// You can use hot reload to reload pages when they are changed
// This is useful when you are developing a website
// Relative directory contains pages and special relative directory contains error pages in format <status code>.<extensions>
// For example 404.html is a page for 404 error
server.enableHotReload(relativeDirectory: "pages", specialRelativeDirectory: "pages/errors")

// Start the server
server.start()
```

### Custom pages

You can create custom pages. This is useful when you want to create a website with custom pages.

```swift
import Surfr

// Create a new Surfr server
let server = Surfr()

// Register custom page
// You can use this feature to render backend generated pages or inject data into pages
server.webpage(path: "/wptest", handler: { req in 
    if (req.queryParams.count == 1) {
        name = req.queryParams[0].1
        if (name == "world") {
            throw WebpageResponse.ok(response: "Hello fellow software developer!")
        } else {
            throw WebpageResponse.ok(response: "Hello, \(String(describing: name!))!")
        }
    } else {
        throw WebpageResponse.ok(response: "Hello, world!")
    }
})

// Start the server
// You can provide a port as an argument
server.start(8080)
```

## Contributing

Contributions are welcome! Feel free to create a pull request.

## License

Surfr is available under the MIT license. See the LICENSE file for more info.