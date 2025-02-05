import XCTest
import AnyCodable
@testable import SwiftyArk

final class ArkRequestTests: XCTestCase {
    
    // 配置数据
    let auth = ArkAuth(
        domain: "ark.cn-beijing.volces.com",
        endpoint: "/api/v3/chat/completions",
        apiKey: "ecd36f8a-d9ec-4b9a-89a9-f7f31d6925cc"
    )
    
    let modelConfig = ArkModelConfig(
        model: "ep-20240903165341-s5b5n",
        maxTokens: 4096,
        temperature: 1.0,
        topP: 0.7,
        frequencyPenalty: 0.0,
        presencePenalty: 0.0,
        stream: false,
        stop: nil
    )
    
    func testExecuteChatRequest() async throws {
        // 创建 ArkRequest 实例
        var request = ArkRequest(auth: auth, modelConfig: modelConfig)
        
        // 准备测试的消息参数
        let messages = [
            ["role": "user", "content": "Hello!"],
            ["role": "assistant", "content": "Hi, how can I help you?"]
        ]
        
        do {
            // 调用 execute 方法
            let response = try await request.execute(messages: messages)
            // 打印响应的详细内容
            print("Response ID: \(response.id)")
            print("Created at: \(response.created)")
            print("Model: \(response.model)")
            print("Choices: \(response.choices.map { $0.message.content })")
            
            // 验证响应结构
            XCTAssertNotNil(response.id, "Response ID should not be nil")
            XCTAssertNotNil(response.created, "Response created timestamp should not be nil")
            XCTAssertNotNil(response.model, "Response model should not be nil")
            XCTAssertGreaterThan(response.choices.count, 0, "Choices should not be empty")
            XCTAssertNotNil(response.choices.first?.message.content, "First choice message content should not be nil")
        } catch {
            // 捕获错误并打印
            XCTFail("Request failed with error: \(error)")
            print("Error occurred during request: \(error)")
        }
    }
    
    func testExecuteToolRequest() async throws {
        let request = ArkRequest(auth: auth, modelConfig: modelConfig)
        let tool = MockTool(name: "test-tool", parameters: ["key": "value"])
        
        // 模拟工具调用请求
        let response = try await request.executeTool(tool: tool)
        
        // 验证工具响应格式
        XCTAssertNotNil(response.id)
        XCTAssertNotNil(response.created)
        XCTAssertNotNil(response.model)
        XCTAssertNotNil(response.tool)
        XCTAssertNotNil(response.status)
        XCTAssertNotNil(response.result)
    }
    
}

// MARK: - MockTool 定义

/// 用于测试的工具类
struct MockTool: ArkTool {
    static let type: String = "function"
    let name: String
    var description: String? = nil
    let parameters: [String: AnyCodable]?

    // 编码和解码
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case parameters
    }

    init(name: String, description: String? = nil, parameters: [String: AnyCodable]? = nil) {
        self.name = name
        self.description = description
        self.parameters = parameters
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.parameters = try container.decodeIfPresent([String: AnyCodable].self, forKey: .parameters)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(parameters, forKey: .parameters)
    }
}
