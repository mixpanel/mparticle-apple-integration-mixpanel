import Foundation

/// Configurable user identification type for Mixpanel identity mapping
public enum UserIdentificationType: String {
    case customerId = "CustomerId"
    case mpid = "MPID"
    case other = "Other"
    case other2 = "Other2"
    case other3 = "Other3"
    case other4 = "Other4"
}
