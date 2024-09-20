
# 调用本接口，向大模型发起一次对话请求。
# 请求消息样式

```HTTP
POST /api/v3/chat/completions HTTP/1.1
Host: ark.cn-beijing.volces.com
Content-Type: application/json
Authorization: <authorization string>

body
```

# 地域和访问域名

本接口支持的地域及 API 访问域名参见[地域和访问域名](https://www.volcengine.com/docs/82379/1302013)。

# 鉴权方式

本接口支持 API Key 鉴权方式，详见[鉴权认证方式](https://www.volcengine.com/docs/82379/1298459)。

# 请求参数

## 请求体

| 参数名称         | 类型                                | 是否必填 | 默认值 | 描述                                                                 | 示例值                                       |
| :--              | :--                                 | :--      | :--    | :--                                                                  | :--                                          |
| model            | String                              | 是       | \-     | 您创建的[推理接入点](https://www.volcengine.com/docs/82379/1099522) ID | ep-202406040\*\*\*\*\*-\*\*\*\*\*            |
| messages         | Array of [MessageParam](#messageparam) | 是       | \-     | 由目前为止的对话组成的消息列表                                          | \-                                           |
| stream           | Boolean                             | 否       | false  | 响应内容是否流式返回                                                     | false                                        |
| stream_options   | [StreamOptionsParam](#streamoptionsparam) | 否       | \-     | 流式响应的选项。仅当 `stream: true` 时可以设置 `stream_options` 参数。    | \-                                           |
| max_tokens       | Integer                             | 否       | 4096   | 模型可以生成的最大 token 数量。取值范围为 \[0, 4096\]。                    | 4096                                         |
| stop             | String or Array                     | 否       | \-     | 模型遇到 `stop` 字段所指定的字符串时将停止继续生成，这个词语本身不会输出。最多支持 4 个字符串。 | \[\"你好\", \"天气\"\]                       |
| frequency_penalty| Float                               | 否       | 0      | 频率惩罚系数。如果值为正，会根据新 token 在文本中的出现频率对其进行惩罚，从而降低模型逐字重复的可能性。取值范围为 \[-2.0, 2.0\]。 | 1                                             |
| presence_penalty | Float                               | 否       | 0      | 存在惩罚系数。如果值为正，会根据新 token 到目前为止是否出现在文本中对其进行惩罚，从而增加模型谈论新主题的可能性。取值范围为 \[-2.0, 2.0\]。 | 1                                             |
| temperature      | Float                               | 否       | 1      | 采样温度。控制了生成文本时对每个候选词的概率分布进行平滑的程度。取值范围为 \[0, 1\]。当取值为 0 时模型仅考虑对数概率最大的一个 token。 | 0.8                                           |
| top_p            | Float                               | 否       | 0.7    | 核采样概率阈值。模型会考虑概率质量在 `top_p` 内的 token 结果。取值范围为 \[0, 1\]。当取值为 0 时模型仅考虑对数概率最大的一个 token。 | 0.8                                           |
| logprobs         | Boolean                             | 否       | false  | 是否返回输出 tokens 的对数概率。                                           | false                                        |
| top_logprobs     | Integer                             | 否       | 0      | 指定每个输出 token 位置最有可能返回的 token 数量，每个 token 都有关联的对数概率。仅当 `logprobs: true` 时可以设置 `top_logprobs` 参数，取值范围为 \[0, 20\]。 | 2                                             |
| logit_bias       | Map<Integer, Float>                 | 否       | \-     | 调整指定 token 在模型输出内容中出现的概率，使模型生成的内容更加符合特定的偏好。`logit_bias` 字段接受一个 map 值，其中每个键为词表中的 token ID（使用 tokenization 接口获取），每个值为该 token 的偏差值，取值范围为 \[-100, 100\]。 | ```json <br> \-1 会减少选择的可能性，1 会增加选择的可能性；-100 会完全禁止选择该 token，100 会导致仅可选择该 token。该参数的实际效果可能因模型而异。 | { <br> "1234": -100 <br> } <br> ``` |
| tools            | Array of [ToolParam](#toolparam)    | 否       | \-     | 模型可以调用的工具列表。目前，仅函数作为工具被支持。用这个来提供模型可能为其生成 JSON 输入的函数列表。 | \-                                           |

## 数据结构

### MessageParam

| 参数名称         | 类型                                | 是否必填 | 默认值 | 描述                                                                 | 示例值                                       |
| :--              | :--                                 | :--      | :--    | :--                                                                  | :--                                          |
| role             | String                              | 是       | \-     | 发出该消息的对话参与者角色，可选值包括：                                  | user                                         |
| content          | String                              | 否       | \-     | 消息内容                                                              | 世界第一高山是什么？                         |
| tool_calls       | Array of [MessageToolCallParam](#messagetoolcallparam) | 否       | \-     | 模型生成的工具调用。当 `role` 为 `assistant` 时，`content` 与 `tool_calls` 参数二者至少填其一 | \-                                           |
| tool_call_id     | String                              | 否       | \-     | 此消息所回应的工具调用 ID，当 `role` 为 `tool` 时必填                      | call_5y\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*   |

### MessageToolCallParam

| 参数名称         | 类型                                | 是否必填 | 默认值 | 描述                                                                 | 示例值                                       |
| :--              | :--                                 | :--      | :--    | :--                                                                  | :--                                          |
| id               | String                              | 是       | \-     | 当前工具调用 ID                                                         | call_5y\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*   |
| type             | String                              | 是       | \-     | 工具类型，当前仅支持`function`                                          | function                                     |
| function         | [FunctionParam](#functionparam)     | 是       | \-     | 模型需要调用的函数                                                     | \-                                           |

### FunctionParam

| 参数名称         | 类型                                | 是否必填 | 默认值 | 描述                                                                 | 示例值                                       |
| :--              | :--                                 | :--      | :--    | :--                                                                  | :--                                          |
| name             | String                              | 是       | \-     | 模型需要调用的函数名称                                                 | get_current_weather                          |
| arguments        | String                              | 是       | \-     | 模型生成的用于调用函数的参数，JSON 格式。请注意，模型并不总是生成有效的 JSON，并且可能会虚构出一些您的函数参数规范中未定义的参数。在调用函数之前，请在您的代码中验证这些参数是否有效。 | {\"location\": \"Boston, MA\"}                |

### ToolParam

| 参数名称         | 类型                                | 是否必填 | 默认值 | 描述                                                                 | 示例值                                       |
| :--              | :--                                 | :--      | :--    | :--                                                                  | :--                                          |
| type             | String                              | 是       | \-     | 工具类型，当前仅支持 `function`                                        | function                                     |
| function         | [FunctionDefinition](#functiondefinition) | 是   | \-     | 模型可以调用的工具列表。                                               | \-                                           |

### FunctionDefinition

| 参数名称         | 类型                                | 是否必填 | 默认值 | 描述                                                                 | 示例值                                       |
| :--              | :--                                 | :--      | :--    | :--                                                                  | :--                                          |
| name             | String                              | 是       | \-     | 函数的名称                                                             | get_current_weather                          |
| description      | String                              | 否       | \-     | 对函数用途的描述，供模型判断何时以及如何调用该工具函数                      | 获取指定城市的天气信息                         |
| parameters       | Object                              | 否       |        | 函数请求参数，以 JSON Schema 格式描述。具体格式请参考 [JSON Schema](https://json-schema.org/understanding-json-schema) 文档 | ```json <br> { <br> "type": "object", <br> "properties": { <br> "location": { <
