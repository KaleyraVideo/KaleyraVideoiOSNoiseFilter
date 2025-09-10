// Copyright © 2018-2025 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import DeepFilterNet

@objc
public class DeepFilter: NSObject {

    private class ConfigureError: NSError {

        override var description: String {
            "Cannot configure DeepFilter because it is already configured"
        }
    }

    private class MismatchingArgumentTypeError: NSError {

        override var description: String {
            "The provided argument has a mismatching type"
        }
    }

    // MARK: - Properties

    private let filter: DeepFilterNetProtocol
    private var state: OpaquePointer? = nil

    @objc
    public private(set) var supportedFrameLength: Int = 0

    @objc
    public var isConfigured: Bool {
        state != nil
    }

    // MARK: - Init

    public override convenience init() {
        self.init(filter: DeepFilterNetWrapper(), modelURL: .modelURL)
    }

    init(filter: DeepFilterNetProtocol, modelURL: URL?) {
        self.filter = filter
        super.init()

        guard let modelURL else { return }
        guard let modelData = try? Data(contentsOf: modelURL) else { return }

        setup(withModelData: modelData)

        guard let state else { return }

        self.supportedFrameLength = filter.getFrameLength(state: state).intVal
    }

    deinit {
        guard let state else { return }
        filter.freeState(state: state)
    }

    // MARK: - Configuration

    @objc(configureWithModelData:error:)
    func configure(withModelData modelData: Any, error: NSErrorPointer) {
        guard !isConfigured else {
            error?.pointee = ConfigureError()
            return
        }

        guard let data = modelData as? Data else {
            error?.pointee = MismatchingArgumentTypeError()
            return
        }

        setup(withModelData: data)
    }

    private func setup(withModelData data: Data) {
        state = data.withUnsafeBytes { bufferPointer -> OpaquePointer? in
            guard let baseAddress = bufferPointer.baseAddress else {
                return nil
            }

            return filter.createState(modelBytes: baseAddress.assumingMemoryBound(to: UInt8.self),
                                      modelSize: data.count.int32Val,
                                      channels: 1,
                                      attenLim: 33.0)
        }
    }

    // MARK: - Remove Noise

    @objc(removeNoiseFromBuffer:bufferSize:)
    public func removeNoise(from buffer: Any, bufferSize: Any) -> NSNumber {
        guard let bufferPointer = buffer as? UnsafeMutablePointer<Int16>, let intBufferSize = bufferSize as? Int, let state else {
            return -1
        }

        return filter.processFrame(state: state, input: bufferPointer, frameSize: intBufferSize.int32Val) as NSNumber
    }
}

private extension Int {

    var int32Val: Int32 {
        Int32(self)
    }
}

private extension Int32 {

    var intVal: Int {
        Int(self)
    }
}

private extension URL {

    static var modelURL: URL? {
        Bundle.module.url(forResource: "DeepFilterNet32", withExtension: "gz")
    }
}
