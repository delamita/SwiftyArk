//
//  Untitled.swift
//  SwiftyArk
//
//  Created by ByteDance on 12/19/24.
//

import Foundation
import Alamofire

// MARK: - ArkAuth 定义

/// `ArkAuth` 用于存储请求的认证信息
public struct ArkAuth {
    public var domain: String
    public var endpoint: String
    public var apiKey: String

    public init(domain: String, endpoint: String, apiKey: String) {
        self.domain = domain
        self.endpoint = endpoint
        self.apiKey = apiKey
    }
}



// MARK: - 基础协议定义

/// `ArkBaseRequestProtocol` 协议：定义所有请求的通用接口。
///
/// 此协议提供基础属性和通用方法，供其他协议扩展。
public protocol ArkRequestBaseProtocol {
    /// 鉴权和全局配置。
    var auth: ArkAuth { get }

    /// 模型级参数配置。
    var modelConfig: ArkModelConfigurable { get }

    /// 构造请求体。
    ///
    /// - Parameter tool: 当前请求使用的工具（可选）。
    /// - Returns: 包含请求参数的字典，用于发送 HTTP 请求。
    func buildRequestBody(tool: ArkTool?) -> [String: Any]
    
    ///
    associatedtype ResponseType: ArkResponse
    var response: ResponseType? { get set }
}


// MARK: - ArkRequestBaseProtocol 默认实现

extension ArkRequestBaseProtocol {
    /// 默认实现：构造请求体。
    ///
    /// 此方法根据 `modelConfig` 提供的参数，构造一个标准化的请求体。
    /// 如果具体实现需要扩展参数，可重写该方法。
    ///
    /// - Parameter tool: 当前请求使用的工具（可选）。
    /// - Returns: 包含请求参数的字典。
    public func buildRequestBody(tool: ArkTool? = nil) -> [String: Any] {
        var body: [String: Any] = [
            "model": modelConfig.model,
            "max_tokens": modelConfig.maxTokens,
            "temperature": modelConfig.temperature,
            "top_p": modelConfig.topP,
            "frequency_penalty": modelConfig.frequencyPenalty,
            "presence_penalty": modelConfig.presencePenalty,
            "stream": modelConfig.stream
        ]
        if let stop = modelConfig.stop {
            body["stop"] = stop
        }
        if let tool = tool {
            body["tool"] = [
                "type": type(of: tool).type,
                "name": tool.name,
                "parameters": tool.parameters ?? [:]
            ]
        }
        return body
    }
}
