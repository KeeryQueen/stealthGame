import Foundation

/** This file provides a thin abstraction layer atop of UIKit (iOS, tvOS) and Cocoa (OS X). The two APIs are very much 
 alike, and for the chart library's usage of the APIs it is often sufficient to typealias one to the other. The NSUI*
 types are aliased to either their UI* implementation (on iOS) or their NS* implementation (on OS X). */
#if os(iOS) || os(tvOS)
#if canImport(UIKit)
    import UIKit
#endif

public typealias NSUIFont = UIFont
public typealias NSUIImage = UIImage
public typealias NSUIScrollView = UIScrollView
public typealias NSUIScreen = UIScreen
public typealias NSUIDisplayLink = CADisplayLink

open class NSUIView: UIView
{
    @objc var nsuiLayer: CALayer?
    {
        return self.layer
    }
}

extension UIScrollView
{
    @objc var nsuiIsScrollEnabled: Bool
        {
        get { return isScrollEnabled }
        set { isScrollEnabled = newValue }
    }
}

extension UIScreen
{
    @objc final var nsuiScale: CGFloat
    {
        return self.scale
    }
}

#endif

#if os(OSX)
import Cocoa
import Quartz

public typealias NSUIFont = NSFont
public typealias NSUIImage = NSImage
public typealias NSUIScrollView = NSScrollView
public typealias NSUIScreen = NSScreen

/** On OS X there is no CADisplayLink. Use a 60 fps timer to render the animations. */
public class NSUIDisplayLink
{
    private var timer: Timer?
    private var displayLink: CVDisplayLink?
    private var _timestamp: CFTimeInterval = 0.0

    private weak var _target: AnyObject?
    private var _selector: Selector

    public var timestamp: CFTimeInterval
    