//
//  Event.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 7/18/22.
//

import Foundation
import CalendarKit

@objcMembers
public class Event : NSObject {
    public static var supportsSecureCoding = true
    public var ekEventID: String?
    public var objectUUID = UUID()
    public var updatedAt: Date?
    public var createdAt: Date?
    
    public var eventTitle = "[No title]"
    public var authorUsername: String?
    public var eventDescription = ""
    public var location = ""
    
    public var startDate = Date()
    public var endDate = Date()
    public var isAllDay = false
    
    public var color = SystemColors.systemBlue
    private weak var edited: EventDescriptor?
    
    public required override init() {
        super.init()
    }
    
    public required init(originalEvent: Event) {
        ekEventID = originalEvent.ekEventID;
        objectUUID = originalEvent.objectUUID;
        updatedAt = originalEvent.updatedAt;
        createdAt = originalEvent.createdAt;
        
        eventTitle = originalEvent.eventTitle;
        authorUsername = originalEvent.authorUsername;
        eventDescription = originalEvent.eventDescription;
        location = originalEvent.location;
        
        startDate = originalEvent.startDate;
        endDate = originalEvent.endDate;
        isAllDay = originalEvent.isAllDay;
        color = originalEvent.color;
    }
}

extension Event : EventDescriptor {
    public var editedEvent: EventDescriptor? {
        get {
            return edited
        }
        set(newValue) {
            edited = newValue
        }
    }
    
    public var dateInterval: DateInterval {
        get {
            return DateInterval(start: startDate, end: endDate)
        }
        set(newValue) {
            startDate = newValue.start
            endDate = newValue.end
        }
    }
    
    public var text: String {
        let dateIntervalFormatter = DateIntervalFormatter()
        var info = [eventTitle, location]
        info.append(dateIntervalFormatter.string(from: startDate, to: endDate))
        return info.reduce("", {$0 + $1 + "\n"})
    }
    
    public var attributedText: NSAttributedString? {
        return nil
    }
    
    public var lineBreakMode: NSLineBreakMode? {
        return nil
    }
    
    public var font: UIFont {
        return UIFont.boldSystemFont(ofSize: 12)
    }
    
    public var textColor: UIColor {
        if (editedEvent != nil) {
            return .white
        }
        return dynamicStandardTextColor
    }
    
    public var backgroundColor: UIColor {
        if (editedEvent != nil) {
            return color.withAlphaComponent(0.95)
        }
        return dynamicStandardBackgroundColor
    }
    
    public func makeEditable() -> Self {
        let cloned = Event()
        cloned.objectUUID = objectUUID
        cloned.updatedAt = updatedAt
        cloned.createdAt = createdAt
        
        cloned.eventTitle = eventTitle
        cloned.authorUsername = authorUsername
        cloned.eventDescription = eventDescription
        cloned.location = location
        
        cloned.startDate = startDate
        cloned.endDate = endDate
        cloned.isAllDay = isAllDay
        cloned.editedEvent = self
        return cloned as! Self
    }
    
    public func commitEditing() {
        guard let edited = editedEvent else {return}
        edited.dateInterval = dateInterval
    }
    
    /// Dynamic color that changes depending on the user interface style (dark / light)
    private var dynamicStandardBackgroundColor: UIColor {
      let light = backgroundColorForLightTheme
      let dark = backgroundColorForDarkTheme
      return dynamicColor(light: light, dark: dark)
    }
    
    /// Dynamic color that changes depending on the user interface style (dark / light)
    private var dynamicStandardTextColor: UIColor {
      let light = textColorForLightTheme
      return dynamicColor(light: light, dark: color)
    }
    
    private var textColorForLightTheme: UIColor {
      var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
      color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
      return UIColor(hue: h, saturation: s, brightness: b * 0.4, alpha: a)
    }
    
    private var backgroundColorForLightTheme: UIColor {
      return color.withAlphaComponent(0.3)
    }
    
    private var backgroundColorForDarkTheme: UIColor {
      var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
      color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
      return UIColor(hue: h, saturation: s, brightness: b * 0.4, alpha: a * 0.8)
    }
    
    private func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
      if #available(iOS 13.0, *) {
        return UIColor { traitCollection in
          let interfaceStyle = traitCollection.userInterfaceStyle
          switch interfaceStyle {
          case .dark:
            return dark
          default:
            return light
          }
        }
      } else {
        return light
      }
    }
}
