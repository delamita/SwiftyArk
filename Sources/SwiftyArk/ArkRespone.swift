//
//  ArkResponse.swift
//  SwiftyArk
//
//  Created by ByteDance on 12/16/24.
//

import Foundation

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
        return "ArkChatResponse(id: \(id), choices: \(choices.map { $0.message.content }))"
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

    /// 提供响应对象的描述信息。
    ///
    /// - Returns: 一个 `String`，描述当前工具调用响应的内容。
    public func description() -> String {
        return "ArkToolResponse(id: \(id), tool: \(tool), status: \(status), result: \(result ?? "nil"))"
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

    // 提供描述信息
    public func description() -> String {
        return "StreamChatResponse(id: \(id), model: \(model), choices: \(choices.count), isStreaming: true)"
    }
}
