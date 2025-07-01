// Copyright © 2018-2025 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import DeepFilterNet

@objc
public class DeepFilter: NSObject {

    // MARK: - Properties

    private let filter: DeepFilterNetProtocol
    private var state: OpaquePointer? = nil

    @objc
    public private(set) var supportedFrameLength: Int = 0

    // MARK: - Init

    public override convenience init() {
        self.init(filter: DeepFilterNetWrapper())
    }

    init(filter: DeepFilterNetProtocol) {
        self.filter = filter
        super.init()

        guard let modelURL = Bundle.module.url(forResource: "DeepFilterNet32", withExtension: "gz") else { return }
        guard let modelData = try? Data(contentsOf: modelURL) else { return }

        self.state = modelData.withUnsafeBytes { bufferPointer -> OpaquePointer? in
            guard let baseAddress = bufferPointer.baseAddress else {
                return nil
            }

            return filter.createState(modelBytes: baseAddress.assumingMemoryBound(to: UInt8.self),
                                      modelSize: modelData.count.int32Val,
                                      channels: 1,
                                      attenLim: 33.0)
        }

        guard let state else { return }

        self.supportedFrameLength = filter.getFrameLength(state: state).intVal
    }

    deinit {
        guard let state else { return }
        filter.freeState(state: state)
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
