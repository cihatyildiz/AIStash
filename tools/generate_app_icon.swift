import AppKit

let outputDirectory = URL(fileURLWithPath: "/Users/cihatyildiz/Projects/AIStash/AIStash/Resources/Assets.xcassets/AppIcon.appiconset", isDirectory: true)
let fileManager = FileManager.default

let sizes: [(filename: String, dimension: Int)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024),
]

try fileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

func makePNGData(dimension: Int) -> Data {
    let rect = NSRect(x: 0, y: 0, width: dimension, height: dimension)
    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: dimension,
        pixelsHigh: dimension,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        fatalError("Failed to allocate bitmap")
    }

    bitmap.size = NSSize(width: dimension, height: dimension)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)

    NSColor.clear.setFill()
    rect.fill()

    let inset = CGFloat(dimension) * 0.08
    let baseRect = rect.insetBy(dx: inset, dy: inset)
    let cornerRadius = CGFloat(dimension) * 0.22
    let basePath = NSBezierPath(roundedRect: baseRect, xRadius: cornerRadius, yRadius: cornerRadius)

    let gradient = NSGradient(colors: [
        NSColor(calibratedRed: 0.17, green: 0.50, blue: 0.93, alpha: 1.0),
        NSColor(calibratedRed: 0.05, green: 0.33, blue: 0.82, alpha: 1.0),
    ])!
    gradient.draw(in: basePath, angle: 90)

    NSGraphicsContext.current?.saveGraphicsState()
    basePath.addClip()

    let glowRect = NSRect(
        x: baseRect.minX - CGFloat(dimension) * 0.10,
        y: baseRect.midY + CGFloat(dimension) * 0.02,
        width: baseRect.width * 1.28,
        height: baseRect.height * 0.78
    )
    let glowPath = NSBezierPath(ovalIn: glowRect)
    NSColor(calibratedRed: 0.79, green: 0.93, blue: 1.0, alpha: 0.22).setFill()
    glowPath.fill()

    let accentWidth = CGFloat(dimension) * 0.16
    let accentRect = NSRect(
        x: baseRect.maxX - accentWidth * 1.22,
        y: baseRect.minY + CGFloat(dimension) * 0.14,
        width: accentWidth,
        height: baseRect.height * 0.72
    )
    let accentPath = NSBezierPath(roundedRect: accentRect, xRadius: accentWidth * 0.45, yRadius: accentWidth * 0.45)
    NSColor(calibratedRed: 0.48, green: 0.87, blue: 0.95, alpha: 0.98).setFill()
    accentPath.fill()

    let shelfRect = NSRect(
        x: baseRect.minX + CGFloat(dimension) * 0.14,
        y: baseRect.minY + CGFloat(dimension) * 0.18,
        width: baseRect.width * 0.62,
        height: CGFloat(dimension) * 0.08
    )
    let shelfPath = NSBezierPath(roundedRect: shelfRect, xRadius: shelfRect.height / 2, yRadius: shelfRect.height / 2)
    NSColor.white.withAlphaComponent(0.12).setFill()
    shelfPath.fill()

    NSGraphicsContext.current?.restoreGraphicsState()

    let lineWidth = max(2, CGFloat(dimension) * 0.048)
    let lineColor = NSColor.white
    let topY = baseRect.maxY - CGFloat(dimension) * 0.26
    let bottomY = baseRect.minY + CGFloat(dimension) * 0.28
    let midY = baseRect.midY + CGFloat(dimension) * 0.01

    let aLeftX = baseRect.minX + CGFloat(dimension) * 0.22
    let aWidth = CGFloat(dimension) * 0.24
    let aApexX = aLeftX + aWidth * 0.5

    let aPath = NSBezierPath()
    aPath.lineWidth = lineWidth
    aPath.lineCapStyle = .round
    aPath.lineJoinStyle = .round
    aPath.move(to: NSPoint(x: aLeftX, y: bottomY))
    aPath.line(to: NSPoint(x: aApexX, y: topY))
    aPath.line(to: NSPoint(x: aLeftX + aWidth, y: bottomY))
    aPath.move(to: NSPoint(x: aLeftX + aWidth * 0.23, y: midY))
    aPath.line(to: NSPoint(x: aLeftX + aWidth * 0.77, y: midY))
    lineColor.setStroke()
    aPath.stroke()

    let sRect = NSRect(
        x: baseRect.minX + CGFloat(dimension) * 0.45,
        y: baseRect.minY + CGFloat(dimension) * 0.28,
        width: CGFloat(dimension) * 0.21,
        height: CGFloat(dimension) * 0.40
    )
    let sPath = NSBezierPath()
    sPath.lineWidth = lineWidth
    sPath.lineCapStyle = .round
    sPath.lineJoinStyle = .round
    sPath.move(to: NSPoint(x: sRect.maxX, y: sRect.maxY - sRect.height * 0.06))
    sPath.curve(
        to: NSPoint(x: sRect.minX + sRect.width * 0.18, y: sRect.midY + sRect.height * 0.10),
        controlPoint1: NSPoint(x: sRect.minX + sRect.width * 0.64, y: sRect.maxY),
        controlPoint2: NSPoint(x: sRect.minX - sRect.width * 0.02, y: sRect.maxY * 0.98)
    )
    sPath.curve(
        to: NSPoint(x: sRect.maxX - sRect.width * 0.08, y: sRect.midY - sRect.height * 0.04),
        controlPoint1: NSPoint(x: sRect.minX + sRect.width * 0.05, y: sRect.midY - sRect.height * 0.04),
        controlPoint2: NSPoint(x: sRect.maxX - sRect.width * 0.12, y: sRect.midY + sRect.height * 0.06)
    )
    sPath.curve(
        to: NSPoint(x: sRect.minX, y: sRect.minY + sRect.height * 0.02),
        controlPoint1: NSPoint(x: sRect.maxX, y: sRect.minY + sRect.height * 0.02),
        controlPoint2: NSPoint(x: sRect.minX + sRect.width * 0.44, y: sRect.minY - sRect.height * 0.06)
    )
    lineColor.setStroke()
    sPath.stroke()

    let outline = NSBezierPath(roundedRect: baseRect, xRadius: cornerRadius, yRadius: cornerRadius)
    outline.lineWidth = max(1, CGFloat(dimension) * 0.012)
    NSColor.white.withAlphaComponent(0.18).setStroke()
    outline.stroke()

    NSGraphicsContext.restoreGraphicsState()
    guard let pngData = bitmap.representation(using: .png, properties: [:]) else {
        fatalError("Failed to encode PNG")
    }
    return pngData
}

for entry in sizes {
    let pngData = makePNGData(dimension: entry.dimension)
    try pngData.write(to: outputDirectory.appendingPathComponent(entry.filename))
}
