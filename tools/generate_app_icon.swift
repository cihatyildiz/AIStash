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
    let cornerRadius = CGFloat(dimension) * 0.23
    let basePath = NSBezierPath(roundedRect: baseRect, xRadius: cornerRadius, yRadius: cornerRadius)

    let gradient = NSGradient(colors: [
        NSColor(calibratedRed: 0.97, green: 0.83, blue: 0.46, alpha: 1.0),
        NSColor(calibratedRed: 0.90, green: 0.55, blue: 0.19, alpha: 1.0),
    ])!
    gradient.draw(in: basePath, angle: 90)

    NSGraphicsContext.current?.saveGraphicsState()
    basePath.addClip()

    let glowRect = NSRect(
        x: baseRect.minX - CGFloat(dimension) * 0.16,
        y: baseRect.midY + CGFloat(dimension) * 0.16,
        width: baseRect.width * 1.34,
        height: baseRect.height * 0.70
    )
    let glowPath = NSBezierPath(ovalIn: glowRect)
    NSColor(calibratedRed: 1.0, green: 0.96, blue: 0.86, alpha: 0.35).setFill()
    glowPath.fill()

    let groundRect = NSRect(
        x: baseRect.minX + CGFloat(dimension) * 0.12,
        y: baseRect.minY + CGFloat(dimension) * 0.12,
        width: baseRect.width * 0.76,
        height: CGFloat(dimension) * 0.12
    )
    let groundPath = NSBezierPath(roundedRect: groundRect, xRadius: groundRect.height / 2, yRadius: groundRect.height / 2)
    NSColor.black.withAlphaComponent(0.12).setFill()
    groundPath.fill()

    NSGraphicsContext.current?.restoreGraphicsState()

    let bucketWidth = CGFloat(dimension) * 0.50
    let bucketHeight = CGFloat(dimension) * 0.40
    let bucketRect = NSRect(
        x: rect.midX - bucketWidth / 2,
        y: baseRect.minY + CGFloat(dimension) * 0.22,
        width: bucketWidth,
        height: bucketHeight
    )
    let bucketTopWidth = bucketWidth * 0.82
    let bucketLipHeight = CGFloat(dimension) * 0.10
    let bucketTopX = rect.midX - bucketTopWidth / 2
    let bucketTopY = bucketRect.maxY - bucketLipHeight * 0.30

    let bucketBody = NSBezierPath()
    bucketBody.move(to: NSPoint(x: bucketRect.minX + bucketWidth * 0.12, y: bucketRect.minY))
    bucketBody.line(to: NSPoint(x: bucketRect.maxX - bucketWidth * 0.12, y: bucketRect.minY))
    bucketBody.line(to: NSPoint(x: bucketTopX + bucketTopWidth * 0.96, y: bucketTopY))
    bucketBody.line(to: NSPoint(x: bucketTopX + bucketTopWidth * 0.04, y: bucketTopY))
    bucketBody.close()

    let bucketGradient = NSGradient(colors: [
        NSColor(calibratedRed: 0.27, green: 0.46, blue: 0.82, alpha: 1.0),
        NSColor(calibratedRed: 0.11, green: 0.27, blue: 0.61, alpha: 1.0),
    ])!
    bucketGradient.draw(in: bucketBody, angle: -90)

    let bucketTopRect = NSRect(
        x: bucketTopX,
        y: bucketTopY - bucketLipHeight * 0.34,
        width: bucketTopWidth,
        height: bucketLipHeight
    )
    let bucketTopPath = NSBezierPath(ovalIn: bucketTopRect)
    NSColor(calibratedRed: 0.72, green: 0.87, blue: 1.0, alpha: 0.95).setFill()
    bucketTopPath.fill()

    let bucketInnerRect = bucketTopRect.insetBy(dx: bucketTopRect.width * 0.12, dy: bucketTopRect.height * 0.22)
    let bucketInnerPath = NSBezierPath(ovalIn: bucketInnerRect)
    NSColor(calibratedRed: 0.08, green: 0.18, blue: 0.43, alpha: 0.75).setFill()
    bucketInnerPath.fill()

    let handleWidth = bucketTopWidth * 0.88
    let handleRect = NSRect(
        x: rect.midX - handleWidth / 2,
        y: bucketTopY + CGFloat(dimension) * 0.01,
        width: handleWidth,
        height: bucketHeight * 0.70
    )
    let handlePath = NSBezierPath()
    handlePath.lineWidth = max(2, CGFloat(dimension) * 0.035)
    handlePath.lineCapStyle = .round
    handlePath.move(to: NSPoint(x: handleRect.minX, y: handleRect.minY + handleRect.height * 0.40))
    handlePath.curve(
        to: NSPoint(x: handleRect.maxX, y: handleRect.minY + handleRect.height * 0.40),
        controlPoint1: NSPoint(x: handleRect.minX, y: handleRect.maxY),
        controlPoint2: NSPoint(x: handleRect.maxX, y: handleRect.maxY)
    )
    NSColor.white.withAlphaComponent(0.72).setStroke()
    handlePath.stroke()

    let textShadow = NSShadow()
    textShadow.shadowOffset = NSSize(width: 0, height: -CGFloat(dimension) * 0.018)
    textShadow.shadowBlurRadius = CGFloat(dimension) * 0.035
    textShadow.shadowColor = NSColor.black.withAlphaComponent(0.18)

    let textParagraph = NSMutableParagraphStyle()
    textParagraph.alignment = .center

    let fontSize = CGFloat(dimension) * 0.24
    let textAttributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: fontSize, weight: .black),
        .foregroundColor: NSColor.white,
        .paragraphStyle: textParagraph,
        .shadow: textShadow,
    ]

    let textRect = NSRect(
        x: bucketRect.minX - CGFloat(dimension) * 0.01,
        y: bucketRect.midY - CGFloat(dimension) * 0.01,
        width: bucketRect.width,
        height: fontSize * 1.2
    )
    "AI".draw(in: textRect, withAttributes: textAttributes)

    let sparkleColor = NSColor.white.withAlphaComponent(0.84)
    let sparkleLineWidth = max(1.5, CGFloat(dimension) * 0.016)
    for center in [
        NSPoint(x: rect.midX - CGFloat(dimension) * 0.18, y: bucketTopY + CGFloat(dimension) * 0.16),
        NSPoint(x: rect.midX + CGFloat(dimension) * 0.20, y: bucketTopY + CGFloat(dimension) * 0.13),
    ] {
        let sparkle = NSBezierPath()
        sparkle.lineWidth = sparkleLineWidth
        sparkle.lineCapStyle = .round
        let radius = CGFloat(dimension) * 0.026
        sparkle.move(to: NSPoint(x: center.x, y: center.y - radius))
        sparkle.line(to: NSPoint(x: center.x, y: center.y + radius))
        sparkle.move(to: NSPoint(x: center.x - radius, y: center.y))
        sparkle.line(to: NSPoint(x: center.x + radius, y: center.y))
        sparkleColor.setStroke()
        sparkle.stroke()
    }

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
