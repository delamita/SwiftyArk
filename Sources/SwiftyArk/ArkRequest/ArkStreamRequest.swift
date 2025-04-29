//
//  ArkStreamRequest.swift
//  SwiftyArk
//
//  Created by ByteDance on 12/19/24.
//
import Foundation
import Alamofire

// MARK: - 流式请求协议定义

/// `ArkStreamRequestProtocol` 协议：定义流式请求的接口。
///
/// 继承 `ArkBaseRequestProtocol`，专注于流式请求的行为。
public protocol ArkStreamRequestProtocol: ArkRequestBaseProtocol {
    /// 执行流式聊天请求。
    ///
    /// - Returns: 返回一个 `AsyncStream<String>` 类型。
    func executeStream() async throws -> AsyncStream<String>

    /// 执行流式工具调用请求。
    ///
    /// - Parameter tool: 工具调用的具体实例。
    /// - Returns: 返回一个 `AsyncStream<String>` 类型。
    func executeToolStream(tool: ArkTool) async throws -> AsyncStream<String>
}


// MARK: - ArkStreamRequestProtocol 默认实现

extension ArkStreamRequestProtocol {
    /// 默认实现：执行流式聊天请求。
    ///
    /// 此方法通过构造的请求体和 `ArkAuth` 配置，发送聊天请求并以流的方式返回响应。
    ///
    /// - Returns: 一个 `AsyncStream<String>` 类型的解析响应。
    public func executeStream() async throws -> AsyncStream<String> {
        let url = "https://\(auth.domain)\(auth.endpoint)"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(auth.apiKey)"]
        let body = buildRequestBody()

        // 将 body 转换为 JSON 数据
        let bodyData = try JSONSerialization.data(withJSONObject: body)

        return AsyncStream { continuation in
            do {
                // 使用 URLRequest 构建流式请求
                var urlRequest = try URLRequest(url: url, method: .post, headers: headers)
                urlRequest.httpBody = bodyData

                let request = AF.streamRequest(urlRequest)
                request.responseStream { stream in
                    switch stream.event {
                    case .stream(let result):
                        switch result {
                        case .success(let data):
                            if let string = String(data: data, encoding: .utf8) {
                                continuation.yield(string) // 发送流式数据
                            }
                        case .failure(let error):
                            print("Stream error: \(error)") // 打印错误日志
                        }
                    case .complete(_):
                        continuation.finish() // 结束流式请求
                    }
                }
            } catch {
                print("Error building URLRequest: \(error)")
                continuation.finish()
            }
        }
    }

    /// 执行流式工具调用请求。
    ///
    /// 此方法通过构造的请求体和 `ArkAuth` 配置，发送工具调用请求并以流的方式返回响应。
    ///
    /// - Parameter tool: 工具调用的具体实例。
    /// - Returns: 一个 `AsyncStream<String>` 类型。
    public func executeToolStream(tool: ArkTool) async throws -> AsyncStream<String> {
        let url = "https://\(auth.domain)\(auth.endpoint)"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(auth.apiKey)"]
        let body = buildRequestBody(tool: tool)

        // 将 body 转换为 JSON 数据
        let bodyData = try JSONSerialization.data(withJSONObject: body)

        return AsyncStream { continuation in
            do {
                // 使用 URLRequest 构建流式请求
                var urlRequest = try URLRequest(url: url, method: .post, headers: headers)
                urlRequest.httpBody = bodyData

                let request = AF.streamRequest(urlRequest)
                request.responseStream { stream in
                    switch stream.event {
                    case .stream(let result):
                        switch result {
                        case .success(let data):
                            if let string = String(data: data, encoding: .utf8) {
                                continuation.yield(string) // 发送流式数据
                            }
                        case .failure(let error):
                            print("Stream error: \(error)") // 打印错误日志
                        }
                    case .complete(_):
                        continuation.finish() // 结束流式请求
                    }
                }
            } catch {
                print("Error building URLRequest: \(error)")
                continuation.finish()
            }
        }
    }
}


/// `ArkStreamRequest`：流式请求的默认实现。
///

/// 实现了 `ArkStreamRequestProtocol`，可以直接实例化。
public struct ArkStreamRequest: ArkStreamRequestProtocol {
    
    
    
    public typealias ResponseType = ArkChatResponse
    public let auth: ArkAuth
    public let modelConfig: ArkModelConfigurable
    public var response: ArkChatResponse?
    public var streamContent: [String]
    

    public init(auth: ArkAuth, modelConfig: ArkModelConfigurable, streamContent: [String]) {
        self.auth = auth
        self.modelConfig = modelConfig
        self.streamContent = streamContent
    }
}
