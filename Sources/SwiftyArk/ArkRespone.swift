//
//  ArkResponse.swift
//  SwiftyArk
//
//  Created by ByteDance on 12/16/24.
//

import Foundation


// MARK: - Usage
/// Token 使用情况。
public struct Usage: Codable, CustomStringConvertible {
    /// 输入的 prompt token 数量。
    public let promptTokens: Int

    /// 模型生成的 token 数量。
    public let completionTokens: Int

    /// 本次请求消耗的总 token 数量（输入 + 输出）。
    public let totalTokens: Int

    /// 命中上下文缓存的 tokens 细节。
    ///
    /// - Note: 本接口暂不支持该字段。此处应为 0。
    public let promptTokensDetails: PromptTokensDetails?

    /// 输出思维链内容花费的 token 细节。
    ///
    /// - Note: 支持输出思维链的模型才能返回该字段。
    public let completionTokensDetails: CompletionTokensDetails?
    
    
    /// Prompt 输入 token 细节。
    ///
    /// - Note: 本接口暂不支持该字段，通常为 0。
    public struct PromptTokensDetails: Codable {
        /// 命中上下文缓存的 token 数量。
        public let cachedTokens: Int?
        
        private enum CodingKeys: String, CodingKey {
            case cachedTokens = "cached_tokens"
        }
    }

    /// Completion 输出 token 细节。
    ///
    /// - Note: 支持输出思维链的模型才能返回该字段。
    public struct CompletionTokensDetails: Codable {
        /// 输出思维链内容消耗的 token 数量。
        public let reasoningTokens: Int?
        
        private enum CodingKeys: String, CodingKey {
            case reasoningTokens = "reasoning_tokens"
        }
    }
    
    
    private enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
        case promptTokensDetails = "prompt_tokens_details"
        case completionTokensDetails = "completion_tokens_details"
    }

    /// 便于直接打印更完整的 token 消耗信息。
    public var description: String {
        var parts = [
            "prompt: \(promptTokens)",
            "completion: \(completionTokens)",
            "total: \(totalTokens)"
        ]
        if let cached = promptTokensDetails?.cachedTokens {
            parts.append("prompt_cached: \(cached)")
        }
        if let reasoning = completionTokensDetails?.reasoningTokens {
            parts.append("completion_reasoning: \(reasoning)")
        }
        return parts.joined(separator: ", ")
    }
}

// MARK: - ArkResponse

/// 表示所有 Ark 请求响应的通用协议。
///
/// 此协议定义了所有响应类型需要实现的通用属性和行为。
/// 不同的请求（如对话请求和工具调用请求）可实现各自独有的响应类型。
public protocol ArkResponse: Codable {
    /// 请求的唯一标识符。
    ///
    /// 每次请求都会生成唯一的 ID，用于标识和跟踪该请求。
    var id: String { get }

    /// 响应生成的时间戳（以 Unix 时间戳为单位）。
    ///
    /// 此时间戳表示服务器返回响应的时间，用于记录和调试。
    var created: Int { get }
    
    
    /// Token 消耗统计信息。
    ///
    /// 本次请求的 token 用量。
    var usage: Usage { get }

    /// 本次请求使用的模型名称。
    ///
    /// 包含具体模型的标识符，用于确定生成结果所使用的模型版本。
    var model: String { get }

    /// 提供响应对象的描述信息。
    ///
    /// - Returns: 一个 `String`，描述当前响应对象的内容或状态。
    func description() -> String
}

// MARK: - ArkChatResponseProtocol

/// 表示对话请求的响应协议。
///
/// 定义了对话请求的通用响应结构，包括对话生成的选项和消息。
public protocol ArkChatResponseProtocol: ArkResponse {
    /// 包含对话选项的数组。
    var choices: [ArkChatResponse.Choice] { get }
}

// MARK: - ArkChatResponse

/// 表示对话请求的响应。
///
/// 此实现适用于标准对话请求，包含对话生成的选项和消息。
public struct ArkChatResponse: ArkChatResponseProtocol {
    /// 请求的唯一标识符。
    public let id: String

    /// 响应生成的时间戳（以 Unix 时间戳为单位）。
    public let created: Int

    /// 本次请求使用的模型名称。
    public let model: String

    /// 包含对话选项的数组。
    public let choices: [Choice]

    /// Token 消耗统计信息。
    public let usage: Usage

    /// 聊天响应的选项。
    public struct Choice: Codable {
        /// 消息的详细内容。
        public let message: Message
    }

    /// 聊天消息。
    public struct Message: Codable {
        /// 消息的角色。
        ///
        /// 可能的值包括：
        /// - `system`：系统消息。
        /// - `user`：用户消息。
        /// - `assistant`：助手生成的消息。
        public let role: String

        /// 消息的具体内容。
        public let content: String
    }

    /// 提供响应对象的描述信息。
    ///
    /// - Returns: 一个 `String`，描述当前响应对象的内容。
    public func description() -> String {
        let tokenInfo = "\(usage.totalTokens) tokens"
        return "ArkChatResponse(id: \(id), tokens: \(tokenInfo), choices: \(choices.map { $0.message.content }))"
    }
}

// MARK: - ArkToolResponseProtocol

/// 表示工具调用请求的响应协议。
///
/// 定义了工具调用的通用响应结构，包括工具的状态和结果。
public protocol ArkToolResponseProtocol: ArkResponse {
    /// 工具的名称。
    var tool: String { get }

    /// 工具调用的执行状态。
    var status: String { get }

    /// 工具调用的结果。
    var result: String? { get }
}

// MARK: - ArkToolResponse

/// 表示工具调用请求的响应。
///
/// 此实现适用于标准工具调用请求，包含工具的名称、状态和返回结果。
public struct ArkToolResponse: ArkToolResponseProtocol {
    /// 请求的唯一标识符。
    public let id: String

    /// 响应生成的时间戳（以 Unix 时间戳为单位）。
    public let created: Int

    /// 本次请求使用的模型名称。
    public let model: String

    /// 工具的名称。
    public let tool: String

    /// 工具调用的执行状态。
    public let status: String

    /// 工具调用的结果。
    public let result: String?
    
    /// Token 消耗统计信息。
    public let usage: Usage

    /// 提供响应对象的描述信息。
    ///
    /// - Returns: 一个 `String`，描述当前工具调用响应的内容，包括 tokens 消耗信息。
    public func description() -> String {
        let tokenInfo = "\(usage.totalTokens) tokens"
        return "ArkToolResponse(id: \(id), tool: \(tool), status: \(status), tokens: \(tokenInfo), result: \(result ?? "nil"))"
    }
}



// MARK: - ArkStreamResponseProtocol

/// 表示流式请求的响应协议。
///
/// 此协议继承 `ArkResponse`，并增加 `AsyncStream` 类型字段，用于保存流式响应的数据。
public protocol ArkStreamResponseProtocol: ArkResponse {
    /// 实际的流式数据内容。
    var streamContent: [String] { get }
}


// MARK: - ArkStreamRequestProtocol


// MARK: - StreamChatResponse

/// 表示流式聊天响应。
///
/// 同时继承 `ArkChatResponseProtocol` 和 `ArkStreamResponseProtocol`，用于处理流式聊天请求。
public struct StreamChatResponse: ArkChatResponseProtocol, ArkStreamResponseProtocol {

    
    // ArkResponse 的基本属性
    public let id: String
    public let created: Int
    public let model: String

    // ArkChatResponseProtocol 的属性
    public let choices: [ArkChatResponse.Choice]
    // ArkStreamResponseProtocol 的属性
    public var streamContent: [String]

    /// Token 消耗统计信息。
    public let usage: Usage
    
    /// 提供响应对象的描述信息。
    ///
    /// - Returns: 一个 `String`，描述当前流式聊天响应对象的内容，包括 tokens 消耗信息。
    public func description() -> String {
        let tokenInfo = "\(usage.totalTokens) tokens"
        return "StreamChatResponse(id: \(id), model: \(model), tokens: \(tokenInfo), choices: \(choices.count), isStreaming: true)"
    }
}
