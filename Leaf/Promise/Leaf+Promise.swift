
import Foundation
import Oath

public extension Leaf {
    @discardableResult
    public func request(_ method: LeafRequest.LeafMethod,
                        timeout: TimeInterval = 120,
                        progress: LeafTask.ProgressClosure? = nil) -> Promise<LeafResponse> {
        return Promise<LeafResponse>.init(callback: { (resolve, reject) in
            do {
                try self.async(method, timeout: timeout, progress: progress, success: resolve, failure: { (error) in
                    reject(error)
                })
            } catch {
                reject(error)
            }
        })
    }
}

public extension LeafTask {
    @discardableResult
    public func asynchronously() -> Promise<LeafResponse> {
        return Promise<LeafResponse>.init(callback: { (resolve, reject) in
            do {
                try self.async(success: resolve, failure: { (error) in
                    reject(error)
                })
            } catch {
                reject(error)
            }
        })
    }
}
