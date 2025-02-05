//
//  ArkTool.swift
//  SwiftyArk
//
//  Created by ByteDance on 12/16/24.
//

import Foundation
import AnyCodable

/// `ArkTool` 协议：定义工具调用的通用接口。
///
/// 此协议描述了工具调用所需的基本属性，例如工具的类型、名称和参数。
/// 实现此协议的工具可以被模型调用以实现更复杂的逻辑。
public protocol ArkTool: Codable {
    /// 工具的类型。
    ///
    /// - 描述：指定工具的类型，当前支持 "function" 类型。
    static var type: String { get }

    /// 工具的名称。
    ///
    /// - 描述：标识工具的唯一名称，用于模型识别。
    var name: String { get }

    /// 工具的参数。
    ///
    /// - 描述：用于调用工具时提供的动态参数，支持任意可编码类型。
    /// - 默认值：`nil`
    var parameters: [String: AnyCodable]? { get }
}

/// `ArkFunctionTool`：`ArkTool` 协议的默认实现，用于定义函数调用工具。
///
/// 此工具类型用于支持模型生成的函数调用请求，并接受参数以实现动态调用。
public struct ArkFunctionTool: ArkTool {
    /// 工具的类型。
    ///
    /// - 固定值："function"。
    public static let type: String = "function"


    /// 工具的名称。
    ///
    /// - 描述：标识函数调用的唯一名称。
    public let name: String

    /// 工具的参数。
    ///
    /// - 描述：指定函数调用时的动态参数，支持 `AnyCodable` 类型。
    /// - 默认值：`nil`
    public let parameters: [String: AnyCodable]?

    /// 初始化方法。
    ///
    /// - Parameters:
    ///   - name: 函数调用的唯一名称。
    ///   - parameters: 调用时所需的动态参数。
    public init(name: String, parameters: [String: AnyCodable]? = nil) {
        self.name = name
        self.parameters = parameters
    }
    
}
