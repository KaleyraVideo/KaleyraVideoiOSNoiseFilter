// Copyright © 2018-2025 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import SwiftHamcrest
import KaleyraTestKit
import KaleyraTestHelpers
import KaleyraTestMatchers
import DeepFilterNet
@testable import KaleyraVideoNoiseFilter

final class DeepFilterTests: UnitTestCase {

    // MARK: - Test Setup

    private var sut: DeepFilter!
    private var deepFilterNetSpy: DeepFilterNetSpy!
    private var buffer: UnsafeMutablePointer<Int16>!

    override func setUp() {
        super.setUp()

        deepFilterNetSpy = makeDeepFilterNetSpy()
        buffer = UnsafeMutablePointer<Int16>.allocate(capacity: 1)
        sut = makeSUT(filter: deepFilterNetSpy)
    }

    override func tearDown() {
        sut = nil
        buffer.deallocate()
        buffer = nil
        deepFilterNetSpy = nil

        super.tearDown()
    }

    // MARK: - Tests

    func testInitWithModelShouldCallCreateStateOnDeepFilterNet() {
        assertThat(deepFilterNetSpy.createStateInvocations, hasCount(1))
        assertThat(deepFilterNetSpy.createStateInvocations.first?.channels, presentAnd(equalTo(1)))
        assertThat(deepFilterNetSpy.createStateInvocations.first?.attenLim, presentAnd(equalTo(33.0)))
    }

    func testInitWithModelShouldSetIsConfiguredToTrue() {
        assertThat(sut.isConfigured, isTrue())
    }

    func testInitWithoutModelShouldSetIsConfiguredToTrue() {
        let sut = makeNotConfiguredSUT()

        assertThat(sut.isConfigured, isFalse())
    }

    func testShouldSetSupportedFrameLengthUsingDeepFilterNet() {
        assertThat(deepFilterNetSpy.getFrameLengthInvocations, equalTo([deepFilterNetSpy.mockedState]))
        assertThat(sut.supportedFrameLength, equalTo(512))
    }

    func testRemoveNoiseFromBufferShouldCallProcessFrame() {
        let result = sut.removeNoise(from: buffer!, bufferSize: 512)

        assertThat(deepFilterNetSpy.processFrameInvocations, hasCount(1))
        assertThat(deepFilterNetSpy.processFrameInvocations.first?.state, presentAnd(equalTo(deepFilterNetSpy.mockedState)))
        assertThat(deepFilterNetSpy.processFrameInvocations.first?.input, presentAnd(equalTo(buffer)))
        assertThat(deepFilterNetSpy.processFrameInvocations.first?.frameSize, presentAnd(equalTo(512)))
        assertThat(result, equalTo(0.75))
    }

    func testRemoveNoiseFromBufferProvidingAMismatchingBufferTypeShouldReturnNegativeOne() {
        let result = sut.removeNoise(from: NSObject(), bufferSize: 512)

        assertThat(result, equalTo(-1))
    }

    func testRemoveNoiseFromBufferProvidingAMismatchingBufferSizeShouldReturnNegativeOne() {
        let result = sut.removeNoise(from: buffer!, bufferSize: NSObject())

        assertThat(result, equalTo(-1))
    }

    func testConfigureWhenAlreadyConfiguredShouldReportAnError() {
        var error: NSError?
        sut.configure(withModelData: Data.testModelData, error: &error)

        assertThat(error, present())
    }

    func testConfigureWithMismatchingArgumentTypeShouldReportAnError() {
        let sut = makeNotConfiguredSUT()

        var error: NSError?
        sut.configure(withModelData: String.foo, error: &error)

        assertThat(error, present())
    }

    func testConfigureShouldCallCreateStateOnDeepFilterNet() {
        let deepFilterNetSpy = makeDeepFilterNetSpy()
        let sut = makeNotConfiguredSUT(filter: deepFilterNetSpy)

        sut.configure(withModelData: Data.testModelData, error: nil)

        assertThat(deepFilterNetSpy.createStateInvocations, hasCount(1))
        assertThat(deepFilterNetSpy.createStateInvocations.first?.channels, presentAnd(equalTo(1)))
        assertThat(deepFilterNetSpy.createStateInvocations.first?.attenLim, presentAnd(equalTo(33.0)))
        assertThat(sut.isConfigured, isTrue())
    }

    func testConfigureShouldSetSupportedFrameLengthUsingDeepFilterNet() {
        let deepFilterNetSpy = makeDeepFilterNetSpy()
        let sut = makeNotConfiguredSUT(filter: deepFilterNetSpy)

        sut.configure(withModelData: Data.testModelData, error: nil)

        assertThat(deepFilterNetSpy.getFrameLengthInvocations, equalTo([deepFilterNetSpy.mockedState]))
        assertThat(sut.supportedFrameLength, equalTo(512))
    }

    func testDeinitShouldFreeState() {
        sut = nil

        assertThat(deepFilterNetSpy.freeStateInvocations, hasCount(1))
    }

    // MARK: - Helpers

    private func makeSUT(filter: DeepFilterNetProtocol, modelURL: URL? = .testModelURL) -> DeepFilter {
        .init(filter: filter, modelURL: modelURL)
    }

    private func makeNotConfiguredSUT(filter: DeepFilterNetProtocol? = nil) -> DeepFilter {
        makeSUT(filter: filter ?? deepFilterNetSpy, modelURL: nil)
    }

    private func makeDeepFilterNetSpy() -> DeepFilterNetSpy {
        .init()
    }

    // MARK: - Doubles

    private class DeepFilterNetSpy: DeepFilterNetProtocol {

        let mockedState: OpaquePointer = OpaquePointer(bitPattern: 0x1000)!

        private(set) var createStateInvocations = [(modelBytes: UnsafePointer<UInt8>, modelSize: Int32, channels: Int32, attenLim: Float)]()
        private(set) var processFrameInvocations = [(state: OpaquePointer, input: UnsafePointer<Int16>, frameSize: Int32)]()
        private(set) var getFrameLengthInvocations = [OpaquePointer]()
        private(set) var setAttenLimInvocations = [(state: OpaquePointer, limDb: Float)]()
        private(set) var setPostFilterBetaInvocations = [(state: OpaquePointer, beta: Float)]()
        private(set) var freeStateInvocations = [OpaquePointer]()

        func createState(modelBytes: UnsafePointer<UInt8>, modelSize: Int32, channels: Int32, attenLim: Float) -> OpaquePointer? {
            createStateInvocations.append((modelBytes: modelBytes, modelSize: modelSize, channels: channels, attenLim: attenLim))
            return mockedState
        }

        func processFrame(state: OpaquePointer, input: UnsafePointer<Int16>, frameSize: Int32) -> Float {
            processFrameInvocations.append((state: state, input: input, frameSize: frameSize))
            return 0.75
        }

        func getFrameLength(state: OpaquePointer) -> Int32 {
            getFrameLengthInvocations.append(state)
            return 512
        }

        func setAttenLim(state: OpaquePointer, limDb: Float) {
            setAttenLimInvocations.append((state: state, limDb: limDb))
        }

        func setPostFilterBeta(state: OpaquePointer, beta: Float) {
            setPostFilterBetaInvocations.append((state: state, beta: beta))
        }

        func freeState(state: OpaquePointer) {
            freeStateInvocations.append(state)
        }
    }
}

private extension URL {

    static var testModelURL: URL {
        Bundle.module.url(forResource: "TestModel", withExtension: "tar.gz")!
    }
}

private extension Data {

    static var testModelData: Data {
        try! Data(contentsOf: .testModelURL)
    }
}
