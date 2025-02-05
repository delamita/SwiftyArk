//
//  ArkRequest.swift
//  SwiftyArk
//
//  Created by ByteDance on 12/13/24.
//

import Foundation
import Alamofire


// MARK: - 普通请求协议定义

/// `ArkRequestProtocol` 协议：定义普通请求的接口。
///
/// 继承 `ArkBaseRequestProtocol`，专注于普通请求的行为。
public protocol ArkRequestProtocol: ArkRequestBaseProtocol where ResponseType == ArkChatResponse {
    /// 执行聊天请求。
    ///
    /// - Returns: 返回一个 `ArkChatResponse` 类型。
    mutating func execute(messages: [[String: String]]) async throws -> ArkChatResponse

    /// 执行工具调用请求。
    ///
    /// - Parameter tool: 工具调用的具体实例。
    /// - Returns: 返回一个 `ArkToolResponse` 类型。
    mutating func executeTool(tool: ArkTool) async throws -> ArkToolResponse
}


// MARK: - ArkRequestProtocol 默认实现

extension ArkRequestProtocol {
    /// 默认实现：执行聊天请求。
    ///
    /// 此方法通过构造的请求体和 `ArkAuth` 配置，发送聊天请求并返回解析后的响应。
    ///
    /// - Returns: 一个 `ArkChatResponse` 类型的解析响应。
    public mutating func execute(messages: [[String: String]]) async throws -> ArkChatResponse {
        // 构造 URL、Headers 和 Body
        let url = "https://\(auth.domain)\(auth.endpoint)"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(auth.apiKey)"]
        var body = buildRequestBody()
        body["messages"] = messages // 添加 messages 参数
        // 发送请求
        let request = AF.request(url,
                                 method: .post,
                                 parameters: body,
                                 encoding: JSONEncoding.default,
                                 headers: headers)
        
        let respone = try await request.serializingData().value
        // 解码为 ArkChatResponse
        do {
            let decodedResponse = try JSONDecoder().decode(ArkChatResponse.self, from: respone)
            self.response = decodedResponse
            return decodedResponse
        } catch {
            throw error
        }
    }

    /// 默认实现：执行工具调用请求。
    ///
    /// 此方法通过构造的请求体和 `ArkAuth` 配置，发送工具调用请求并返回解析后的响应。
    ///
    /// - Parameter tool: 工具调用的具体实例。
    /// - Returns: 一个 `ArkToolResponse` 类型的解析响应。
    public func executeTool(tool: ArkTool) async throws -> ArkToolResponse {
        let url = "https://\(auth.domain)\(auth.endpoint)"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(auth.apiKey)"]
        let body = buildRequestBody(tool: tool)

        let request = AF.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers)
        let response = try await request.serializingDecodable(ArkToolResponse.self).value
        return response
    }
}


// MARK: - 默认实现结构

/// `ArkRequest`：普通请求的默认实现。
///
/// 实现了 `ArkRequestProtocol`，可以直接实例化。
public struct ArkRequest: ArkRequestProtocol {
    
    
    public let auth: ArkAuth
    public let modelConfig: ArkModelConfigurable
    public var response: ArkChatResponse?

    public init(auth: ArkAuth, modelConfig: ArkModelConfigurable) {
        self.auth = auth
        self.modelConfig = modelConfig
    }
}

