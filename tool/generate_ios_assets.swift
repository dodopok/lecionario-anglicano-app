import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

enum AssetGenerationError: Error, CustomStringConvertible {
  case invalidArguments
  case contextCreation
  case imageDestination
  case imageFinalize

  var description: String {
    switch self {
    case .invalidArguments:
      return "Uso: generate_ios_assets.swift /caminho/para/o/repo"
    case .contextCreation:
      return "Não foi possível criar o contexto gráfico."
    case .imageDestination:
      return "Não foi possível criar o destino PNG."
    case .imageFinalize:
      return "Não foi possível finalizar o PNG."
    }
  }
}

let pineDeep = CGColor(red: 0x12 / 255.0, green: 0x32 / 255.0, blue: 0x29 / 255.0, alpha: 1)
let paper = CGColor(red: 0xF4 / 255.0, green: 0xF0 / 255.0, blue: 0xE7 / 255.0, alpha: 1)
let copper = CGColor(red: 0xB9 / 255.0, green: 0x79 / 255.0, blue: 0x4D / 255.0, alpha: 1)

func makeContext(width: Int, height: Int) throws -> CGContext {
  guard let context = CGContext(
    data: nil,
    width: width,
    height: height,
    bitsPerComponent: 8,
    bytesPerRow: width * 4,
    // sRGB, not DeviceRGB: the PNG is written as sRGB, and a device space
    // is converted on the way out — which shifted the launch image's paper
    // away from the launch screen's, leaving a visible square behind the mark.
    space: CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB(),
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
  ) else {
    throw AssetGenerationError.contextCreation
  }
  return context
}

func drawSacredMark(in context: CGContext, center: CGPoint, scale: CGFloat) {
  let medallionRadius = scale * 0.34
  context.setFillColor(paper)
  context.fillEllipse(
    in: CGRect(
      x: center.x - medallionRadius,
      y: center.y - medallionRadius,
      width: medallionRadius * 2,
      height: medallionRadius * 2
    )
  )

  context.setStrokeColor(copper)
  context.setLineWidth(max(1, scale * 0.025))
  context.strokeEllipse(
    in: CGRect(
      x: center.x - medallionRadius,
      y: center.y - medallionRadius,
      width: medallionRadius * 2,
      height: medallionRadius * 2
    )
  )

  let markRadius = scale * 0.21
  context.setLineCap(.round)
  context.setLineWidth(max(1, scale * 0.035))
  context.strokeEllipse(
    in: CGRect(
      x: center.x - markRadius,
      y: center.y - markRadius,
      width: markRadius * 2,
      height: markRadius * 2
    )
  )

  context.move(to: CGPoint(x: center.x, y: center.y - markRadius * 0.68))
  context.addLine(to: CGPoint(x: center.x, y: center.y + markRadius * 0.68))
  context.move(to: CGPoint(x: center.x - markRadius * 0.47, y: center.y))
  context.addLine(to: CGPoint(x: center.x + markRadius * 0.47, y: center.y))
  context.strokePath()

  let dotRadius = max(1, scale * 0.017)
  context.setFillColor(copper)
  context.fillEllipse(
    in: CGRect(
      x: center.x - dotRadius,
      y: center.y - dotRadius,
      width: dotRadius * 2,
      height: dotRadius * 2
    )
  )
}

func makeIcon(size: Int) throws -> CGImage {
  let context = try makeContext(width: size, height: size)
  context.setFillColor(pineDeep)
  context.fill(CGRect(x: 0, y: 0, width: size, height: size))
  drawSacredMark(
    in: context,
    center: CGPoint(x: CGFloat(size) / 2, y: CGFloat(size) / 2),
    scale: CGFloat(size)
  )
  guard let image = context.makeImage() else {
    throw AssetGenerationError.contextCreation
  }
  return image
}

func makeLaunchImage(width: Int, height: Int) throws -> CGImage {
  let context = try makeContext(width: width, height: height)
  context.setFillColor(paper)
  context.fill(CGRect(x: 0, y: 0, width: width, height: height))
  drawSacredMark(
    in: context,
    center: CGPoint(x: CGFloat(width) / 2, y: CGFloat(height) / 2),
    scale: CGFloat(min(width, height)) * 0.86
  )
  guard let image = context.makeImage() else {
    throw AssetGenerationError.contextCreation
  }
  return image
}

func writePNG(_ image: CGImage, to url: URL) throws {
  guard let destination = CGImageDestinationCreateWithURL(
    url as CFURL,
    UTType.png.identifier as CFString,
    1,
    nil
  ) else {
    throw AssetGenerationError.imageDestination
  }
  CGImageDestinationAddImage(destination, image, nil)
  guard CGImageDestinationFinalize(destination) else {
    throw AssetGenerationError.imageFinalize
  }
}

guard CommandLine.arguments.count == 2 else {
  throw AssetGenerationError.invalidArguments
}

let repositoryRoot = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
let fileManager = FileManager.default
let iconDirectory = repositoryRoot.appendingPathComponent(
  "ios/Runner/Assets.xcassets/AppIcon.appiconset",
  isDirectory: true
)
let launchDirectory = repositoryRoot.appendingPathComponent(
  "ios/Runner/Assets.xcassets/LaunchImage.imageset",
  isDirectory: true
)

try fileManager.createDirectory(at: iconDirectory, withIntermediateDirectories: true)
try fileManager.createDirectory(at: launchDirectory, withIntermediateDirectories: true)

let iconSizes: [(String, Int)] = [
  ("Icon-App-20x20@1x.png", 20),
  ("Icon-App-20x20@2x.png", 40),
  ("Icon-App-20x20@3x.png", 60),
  ("Icon-App-29x29@1x.png", 29),
  ("Icon-App-29x29@2x.png", 58),
  ("Icon-App-29x29@3x.png", 87),
  ("Icon-App-40x40@1x.png", 40),
  ("Icon-App-40x40@2x.png", 80),
  ("Icon-App-40x40@3x.png", 120),
  ("Icon-App-60x60@2x.png", 120),
  ("Icon-App-60x60@3x.png", 180),
  ("Icon-App-76x76@1x.png", 76),
  ("Icon-App-76x76@2x.png", 152),
  ("Icon-App-83.5x83.5@2x.png", 167),
  ("Icon-App-1024x1024@1x.png", 1024),
]

for (filename, size) in iconSizes {
  try writePNG(makeIcon(size: size), to: iconDirectory.appendingPathComponent(filename))
}

let launchSizes: [(String, Int, Int)] = [
  ("LaunchImage.png", 168, 185),
  ("LaunchImage@2x.png", 336, 370),
  ("LaunchImage@3x.png", 504, 555),
]

for (filename, width, height) in launchSizes {
  try writePNG(
    makeLaunchImage(width: width, height: height),
    to: launchDirectory.appendingPathComponent(filename)
  )
}

print("iOS app icon and launch assets generated.")
