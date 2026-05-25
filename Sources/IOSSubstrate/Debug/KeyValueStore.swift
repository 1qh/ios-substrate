public import Foundation

public protocol KeyValueStore: Sendable {
    func string(forKey key: String) -> String?
    func setString(_ value: String, forKey key: String)
    func removeObject(forKey key: String)
}

extension UserDefaults: KeyValueStore {
    public func setString(_ value: String, forKey key: String) {
        set(value, forKey: key)
    }
}
