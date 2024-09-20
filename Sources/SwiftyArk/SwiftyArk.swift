import Foundation
import Alamofire
import Combine



public class ArkRequest: ObservableObject {

    public enum Role: String, Codable {
        case system
        case user
        case assistant
        case tool
    }
    
    public struct Message: Codable, Identifiable {
        public var id = UUID() // 添加唯一标识符，用于 ForEach
        public let role: Role
        public let content: String

        enum CodingKeys: String, CodingKey {
            case role
            case content
        }

        public init(role: Role, content: String) {
            self.role = role
            self.content = content
        }
    }

    public struct Choice: Codable {
        public let finishReason: String?
        public let index: Int
        public let logprobs: String?
        public let message: Message

        enum CodingKeys: String, CodingKey {
            case finishReason = "finish_reason"
            case index
            case logprobs
            case message
        }

        public init(finishReason: String?, index: Int, logprobs: String?, message: Message) {
            self.finishReason = finishReason
            self.index = index
            self.logprobs = logprobs
            self.message = message
        }
    }

    public struct Usage: Codable {
        public let completionTokens: Int
        public let promptTokens: Int
        public let totalTokens: Int

        enum CodingKeys: String, CodingKey {
            case completionTokens = "completion_tokens"
            case promptTokens = "prompt_tokens"
            case totalTokens = "total_tokens"
        }

        public init(completionTokens: Int, promptTokens: Int, totalTokens: Int) {
            self.completionTokens = completionTokens
            self.promptTokens = promptTokens
            self.totalTokens = totalTokens
        }
    }

    public struct Response: Codable {
        public let choices: [Choice]
        public let created: Int
        public let id: String
        public let model: String
        public let object: String
        public let usage: Usage?

        enum CodingKeys: String, CodingKey {
            case choices
            case created
            case id
            case model
            case object
            case usage
        }

        public init(choices: [Choice], created: Int, id: String, model: String, object: String, usage: Usage?) {
            self.choices = choices
            self.created = created
            self.id = id
            self.model = model
            self.object = object
            self.usage = usage
        }
    }
    
    let apiKey: String
    let modelKey: String
    
    let host: String = "ark.cn-beijing.volces.com"
    let path: String = "/api/v3/chat/completions"

    @Published public var sendMessages: [Message] = [Message]()
    @Published public var receivedMessages: [Message] = [Message]()
    @Published public var exposeMessages: [Message] = [Message]()
    
    @Published public var systemRole = "You are a helpful assistant."
    
    public init(apiKey:String, modelKey:String) {
        self.apiKey = apiKey
        self.modelKey = modelKey
        let initMessage = Message(role: .system, content: systemRole)
        self.sendMessages.append(initMessage)
        self.exposeMessages.append(initMessage)
    }

    @discardableResult
    public func send(_ content: String, role: Role = .user) async throws -> Response {
        // 创建一个用户消息，并添加到 sendMessages 和 exposeMessages 中
        let userMessage = Message(role: role, content: content)
        DispatchQueue.main.async {
            self.sendMessages.append(userMessage)
            self.exposeMessages.append(userMessage)
        }
        
        // 将 exposeMessages 转换为 [String: Any] 的字典数组
        let messagesToSend: [[String: Any]] = self.exposeMessages.map { message in
            return ["role": message.role.rawValue, "content": message.content]
        }
        
        // 构造请求体
        let requestBody: [String: Any] = [
            "model": modelKey,
            "messages": messagesToSend
        ]
        print("will send: \(requestBody)")

        // 构造请求 URL
        let requestURL = "https://\(host)\(path)"
        
        // 使用 await 来等待 Alamofire 的响应
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(requestURL,
                       method: .post,
                       parameters: requestBody,
                       encoding: JSONEncoding.default,
                       headers: [
                        .contentType("application/json"),
                        .authorization(bearerToken: apiKey)
                       ]
            ).responseDecodable(of: Response.self) { response in
                switch response.result {
                case .success(let decodedResponse):
                    DispatchQueue.main.async {
                        // 添加接收到的 assistant 消息到 receivedMessages 和 exposeMessages 中
                        if let msg = decodedResponse.choices.map { $0.message }.first {
                            self.receivedMessages.append(msg)
                            self.exposeMessages.append(msg)
                        }
                    }
                    continuation.resume(returning: decodedResponse)
                    
                case .failure(let error):
                    print("请求失败：\(error.localizedDescription)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
}
