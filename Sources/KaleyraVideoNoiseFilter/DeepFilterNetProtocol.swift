// Copyright © 2018-2025 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

protocol DeepFilterNetProtocol {

    func createState(modelBytes: UnsafePointer<UInt8>, modelSize: Int32, channels: Int32, attenLim: Float) -> OpaquePointer?
    func processFrame(state: OpaquePointer, input: UnsafePointer<Int16>, frameSize: Int32) -> Float
    func getFrameLength(state: OpaquePointer) -> Int32
    func setAttenLim(state: OpaquePointer, limDb: Float)
    func setPostFilterBeta(state: OpaquePointer, beta: Float)
    func freeState(state: OpaquePointer)
}
