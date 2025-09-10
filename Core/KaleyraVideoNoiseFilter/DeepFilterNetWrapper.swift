// Copyright © 2018-2025 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import DeepFilterNet

class DeepFilterNetWrapper: DeepFilterNetProtocol {

    func createState(modelBytes: UnsafePointer<UInt8>, modelSize: Int32, channels: Int32, attenLim: Float) -> OpaquePointer? {
        df_create(modelBytes, modelSize, channels, attenLim)
    }

    func processFrame(state: OpaquePointer, input: UnsafePointer<Int16>, frameSize: Int32) -> Float {
        df_process_frame(state, input, frameSize)
    }

    func getFrameLength(state: OpaquePointer) -> Int32 {
        df_get_frame_length(state)
    }

    func setAttenLim(state: OpaquePointer, limDb: Float) {
        df_set_atten_lim(state, limDb)
    }

    func setPostFilterBeta(state: OpaquePointer, beta: Float) {
        df_set_post_filter_beta(state, beta)
    }

    func freeState(state: OpaquePointer) {
        df_free(state)
    }
}
