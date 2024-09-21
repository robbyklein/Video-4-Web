import Foundation

class AsyncOperation: Operation, @unchecked Sendable {
    private let stateQueue = DispatchQueue(label: "com.example.asyncoperation", attributes: .concurrent)
    private var _isExecuting: Bool = false
    private var _isFinished: Bool = false

    override private(set) var isExecuting: Bool {
        get {
            return stateQueue.sync { _isExecuting }
        }
        set {
            willChangeValue(forKey: "isExecuting")
            stateQueue.sync(flags: .barrier) {
                _isExecuting = newValue
            }
            didChangeValue(forKey: "isExecuting")
        }
    }

    override private(set) var isFinished: Bool {
        get {
            return stateQueue.sync { _isFinished }
        }
        set {
            willChangeValue(forKey: "isFinished")
            stateQueue.sync(flags: .barrier) {
                _isFinished = newValue
            }
            didChangeValue(forKey: "isFinished")
        }
    }

    override var isAsynchronous: Bool {
        return true
    }

    override func start() {
        if isCancelled {
            finish()
            return
        }

        isExecuting = true
        main()
    }

    override func main() {
        fatalError("Subclasses must implement `main` without calling super.")
    }

    func finish() {
        isExecuting = false
        isFinished = true
    }
}
