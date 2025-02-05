//
//  ArkConfig.swift
//  SwiftyArk
//
//  Created by ByteDance on 12/13/24.
//

import Foundation

/// `ArkModelConfigurable` 协议，用于定义模型请求的配置行为。
///
/// 此协议抽象了通用的模型请求参数，为不同的请求类型提供扩展和具体实现。
/// 实现此协议的类型可以通过指定 `model` 和其他生成参数，灵活控制请求行为。
public protocol ArkModelConfigurable: Codable {
    // MARK: - 请求头配置

    /// 请求的 HTTP Headers。
    ///
    /// 此属性定义请求所需的 HTTP 头部信息。
    /// 默认值为 `["Content-Type": "application/json"]`。
    var headers: [String: String] { get }

    // MARK: - 请求体参数配置

    /// 模型 ID。
    ///
    /// 用于指定调用的语言模型，必须明确填写。
    var model: String { get }

    /// 最大生成的 Token 数量。
    ///
    /// 限制模型生成文本的最大长度。
    /// 默认值为 `4096`。
    var maxTokens: Int { get }

    /// 采样温度。
    ///
    /// 控制生成文本时的随机性。
    /// - 范围: [0, 1]。
    /// - 默认值: `1.0`。
    /// - 值越高，生成的结果越随机；值越低，生成的结果越确定。
    var temperature: Float { get }

    /// 核采样概率阈值。
    ///
    /// 模型会优先考虑概率累积质量不超过 `topP` 的 Token。
    /// - 范围: [0, 1]。
    /// - 默认值: `0.7`。
    /// - 值越高，生成的结果越多样化；值越低，生成的结果越确定。
    var topP: Float { get }

    /// 频率惩罚系数。
    ///
    /// 用于减少生成文本中重复单词或短语的可能性。
    /// - 范围: [-2.0, 2.0]。
    /// - 默认值: `0.0`。
    /// - 值越大，惩罚越强。
    var frequencyPenalty: Float { get }

    /// 存在惩罚系数。
    ///
    /// 用于增加生成新主题或未出现内容的可能性。
    /// - 范围: [-2.0, 2.0]。
    /// - 默认值: `0.0`。
    var presencePenalty: Float { get }

    /// 是否流式返回。
    ///
    /// 如果设置为 `true`，响应会按流式分块返回。
    /// - 默认值: `false`。
    var stream: Bool { get }

    /// 停止生成的标志。
    ///
    /// 指定模型生成到这些标志时停止。
    /// - 默认值: `nil`（表示没有特定停止标志）。
    var stop: [String]? { get }

    // MARK: - 流式响应选项
    /// 流式响应的附加选项。
    ///
    /// 此属性定义流式返回的额外行为。
    /// 默认值为 `ArkConfigStreamOptions()`。
    var streamOptions: StreamOptions { get }

    // MARK: - 超时配置

    /// 请求超时时间。
    ///
    /// 定义请求的超时时长，以秒为单位。
    /// - 默认值: `10.0` 秒。
    var timeout: TimeInterval { get }
}



// MARK: - 流式请求配置

/// 流式响应选项结构体：用于定义流式返回的附加行为。
///
/// 此结构体主要描述流式请求的额外行为选项。
public struct ArkModelConfigStreamOptions: Codable {
    /// 是否包含 Token 使用统计信息。
    ///
    /// - 默认值: `false`。
    public var includeUsage: Bool

    /// 初始化方法。
    /// - Parameter includeUsage: 指定是否包含 Token 使用统计信息。
    public init(includeUsage: Bool = false) {
        self.includeUsage = includeUsage
    }
}

public typealias StreamOptions = ArkModelConfigStreamOptions

// MARK: - 默认实现

public extension ArkModelConfigurable {
    var headers: [String: String] {
        ["Content-Type": "application/json"]
    }

    var maxTokens: Int { 4096 }
    var temperature: Float { 1.0 }
    var topP: Float { 0.7 }
    var frequencyPenalty: Float { 0.0 }
    var presencePenalty: Float { 0.0 }
    var stream: Bool { false }
    var stop: [String]? { nil }
    var streamOptions: StreamOptions { StreamOptions() }
    var timeout: TimeInterval { 10.0 }
}



/// `ArkChatConfig` 实现了 `ArkConfig` 协议，提供对话请求的具体配置。
///
/// 此类型可用于配置对话模型的参数，控制生成结果的行为。
public struct ArkModelConfig: ArkModelConfigurable {
    public var model: String
    public var maxTokens: Int
    public var temperature: Float
    public var topP: Float
    public var frequencyPenalty: Float
    public var presencePenalty: Float
    public var stream: Bool
    public var stop: [String]?
    public var streamOptions: StreamOptions
    public var timeout: TimeInterval

    /// 初始化方法。
    ///
    /// - Parameters:
    ///   - model: 模型 ID，必须明确填写。
    ///   - maxTokens: 最大生成的 Token 数量，默认值为 `4096`。
    ///   - temperature: 采样温度，默认值为 `1.0`。
    ///   - topP: 核采样概率阈值，默认值为 `0.7`。
    ///   - frequencyPenalty: 频率惩罚系数，默认值为 `0.0`。
    ///   - presencePenalty: 存在惩罚系数，默认值为 `0.0`。
    ///   - stream: 是否流式返回，默认值为 `false`。
    ///   - stop: 停止生成的标志，默认值为 `nil`。
    ///   - streamOptions: 流式响应的附加选项，默认值为 `ArkConfigStreamOptions()`。
    ///   - timeout: 请求超时时间，默认值为 `10.0` 秒。
    public init(
        model: String,
        maxTokens: Int = 4096,
        temperature: Float = 1.0,
        topP: Float = 0.7,
        frequencyPenalty: Float = 0.0,
        presencePenalty: Float = 0.0,
        stream: Bool = false,
        stop: [String]? = nil,
        streamOptions: StreamOptions = StreamOptions(),
        timeout: TimeInterval = 10.0
    ) {
        self.model = model
        self.maxTokens = maxTokens
        self.temperature = temperature
        self.topP = topP
        self.frequencyPenalty = frequencyPenalty
        self.presencePenalty = presencePenalty
        self.stream = stream
        self.stop = stop
        self.streamOptions = streamOptions
        self.timeout = timeout
    }
}



