//
//  EventModel.swift
//  CalendarApp
//
//  Created by Angelina Zhang on 7/18/22.
//

import Foundation
import CalendarKit

@objcMembers
public class Event : NSObject {
    public var parseObjectId: String?
    public var objectUUID = UUID()
    public var updatedAt: Date?
    public var createdAt: Date?
    
    public var eventTitle = ""
    public var authorUsername: String?
    public var eventDescription = ""
    public var location = ""
    
    public var startDate = Date()
    public var endDate = Date()
    
    private var eventEdit : EventDescriptor?
    
}

extension Event : EventDescriptor {
    public var dateInterval: DateInterval {
        get {
            return DateInterval(start: startDate, end: endDate)
        }
        set(newValue) {
            startDate = newValue.start
            endDate = newValue.end
        }
    }
    
    public var editedEvent: EventDescriptor? {
        get {
            return eventEdit
        }
        set(newValue) {
            eventEdit = newValue
        }
    }
    
    public var isAllDay: Bool {
        return false;
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
    
    public var color: UIColor {
        return SystemColors.systemBlue
    }
    
    public var textColor: UIColor {
        return SystemColors.label
    }
    
    public var backgroundColor: UIColor {
        return SystemColors.systemBlue.withAlphaComponent(0.3)
    }
    
    public func makeEditable() -> Self {
        let cloned = Event()
        cloned.dateInterval = dateInterval
        cloned.isAllDay = isAllDay
        cloned.text = text
        cloned.attributedText = attributedText
        cloned.lineBreakMode = lineBreakMode
        cloned.color = color
        cloned.backgroundColor = backgroundColor
        cloned.textColor = textColor
        cloned.userInfo = userInfo
        cloned.editedEvent = self
        return cloned
    }
    
    public func commitEditing() {
        guard let edited = editedEvent else {return}
        edited.dateInterval = dateInterval
    }
    
    private func updateColors() {
      (editedEvent != nil) ? applyEditingColors() : applyStandardColors()
    }
    
    /// Colors used when event is not in editing mode
    private func applyStandardColors() {
      backgroundColor = dynamicStandardBackgroundColor()
      textColor = dynamicStandardTextColor()
    }
    
    /// Colors used in editing mode
    private func applyEditingColors() {
      backgroundColor = color.withAlphaComponent(0.95)
      textColor = .white
    }
    
    /// Dynamic color that changes depending on the user interface style (dark / light)
    private func dynamicStandardBackgroundColor() -> UIColor {
      let light = backgroundColorForLightTheme(baseColor: color)
      let dark = backgroundColorForDarkTheme(baseColor: color)
      return dynamicColor(light: light, dark: dark)
    }
    
    /// Dynamic color that changes depending on the user interface style (dark / light)
    private func dynamicStandardTextColor() -> UIColor {
      let light = textColorForLightTheme(baseColor: color)
      return dynamicColor(light: light, dark: color)
    }
    
    private func textColorForLightTheme(baseColor: UIColor) -> UIColor {
      var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
      baseColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
      return UIColor(hue: h, saturation: s, brightness: b * 0.4, alpha: a)
    }
    
    private func backgroundColorForLightTheme(baseColor: UIColor) -> UIColor {
      baseColor.withAlphaComponent(0.3)
    }
    
    private func backgroundColorForDarkTheme(baseColor: UIColor) -> UIColor {
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
