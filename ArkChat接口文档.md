* 文档首页
/火山方舟大模型服务平台/API 参考/调用模型/ChatCompletions-文字对话
ChatCompletions-文字对话最近更新时间：2024.11.11 10:17:51首次发布时间：2024.07.10 15:15:56[我的收藏](/docs/favorite)文档反馈
```
POST https://ark.cn-beijing.volces.com/api/v3/chat/completions
HTTP
```
本文介绍Doubao语言大模型API的输入输出参数，帮助您使用接口向大模型发起文字对话请求。服务会将输入的文字信息输入给模型，并返回模型生成的内容。  


鉴权方式本接口支持 API Key 鉴权方式，详见[鉴权认证方式](/docs/82379/1298459)。


> 如果您需要使用Access Key来调用，可以使用接口来获取临时API Key，详细接口说明请参见[GetApiKey - 获取临时API](https://www.volcengine.com/docs/82379/1262825) 
> 
> 

请求参数## 请求体



| 参数名称 | 类型 | 是否必填 | 默认值 | 描述 | 示例值 |
| --- | --- | --- | --- | --- | --- |
| model | String | 是 | - | 您创建的[推理接入点](/docs/82379/1099522) ID | ep-202406040*****-***** |
| messages | Array of [MessageParam](/docs/82379/1298454#messageparam) | 是 | - | 由目前为止的对话组成的消息列表
当指定了 `tools` 参数以使用模型的 function call 能力时，请确保 `messages` 列表内的消息满足如下要求：* 如果 message 列表中前文出现了带有 n 个 `tool_calls` 的 Assistant Message，则后文必须有连续 n 个分别和每个 `tool_call_id` 相对应的 Tool Message，来回应 `tool_calls` 的信息要求
 | - |
| stream | Boolean | 否 | false | 响应内容是否流式返回* `false`：模型生成完所有内容后一次性返回结果
* `true`：按 SSE 协议逐块返回模型生成内容，并以一条 `data: [DONE]` 消息结束
 | false |
| stream\_options | Array of[StreamOptionsParam](/docs/82379/1298454#streamoptionsparam) | 否 | - | 流式响应的选项。仅当 `stream: true` 时可以设置 `stream_options` 参数。 | - |
| max\_tokens | Integer | 否 | 4096 | 注意* **模型回复最大长度（单位 token），取值范围为 [0, 4096]。**
* **输入 token 和输出 token 的总长度还受模型的上下文长度限制。**
 | 4096 |
| stop | String or Array | 否 | - | 模型遇到 `stop` 字段所指定的字符串时将停止继续生成，这个词语本身不会输出。最多支持 4 个字符串。 | ["你好", "天气"] |
| frequency\_penalty | Float | 否 | 0 | 频率惩罚系数。如果值为正，会根据新 token 在文本中的出现频率对其进行惩罚，从而降低模型逐字重复的可能性。取值范围为 [-2.0, 2.0]。 | 1 |
| presence\_penalty | Float | 否 | 0 | 存在惩罚系数。如果值为正，会根据新 token 到目前为止是否出现在文本中对其进行惩罚，从而增加模型谈论新主题的可能性。取值范围为 [-2.0, 2.0]。 | 1 |
| temperature | Float | 否 | 1 | 采样温度。控制了生成文本时对每个候选词的概率分布进行平滑的程度。取值范围为 [0, 1]。当取值为 0 时模型仅考虑对数概率最大的一个 token。
较高的值（如 0.8）会使输出更加随机，而较低的值（如 0.2）会使输出更加集中确定。通常建议仅调整 `temperature` 或 `top_p` 其中之一，不建议两者都修改。 | 0.8 |
| top\_p | Float | 否 | 0.7 | 核采样概率阈值。模型会考虑概率质量在 `top_p` 内的 token 结果。取值范围为 [0, 1]。当取值为 0 时模型仅考虑对数概率最大的一个 token。
如 0.1 意味着只考虑概率质量最高的前 10% 的 token，取值越大生成的随机性越高，取值越低生成的确定性越高。通常建议仅调整 `temperature` 或 `top_p` 其中之一，不建议两者都修改。 | 0.8 |
| logprobs | Boolean | 否 | false | 是否返回输出 tokens 的对数概率。* `false`：不返回对数概率信息
* `true`：返回消息内容中每个输出 token 的对数概率
 | false |
| top\_logprobs | Integer | 否 | 0 | 指定每个输出 token 位置最有可能返回的 token 数量，每个 token 都有关联的对数概率。仅当 `logprobs: true` 时可以设置 `top_logprobs` 参数，取值范围为 [0, 20]。 | 2 |
| logit\_bias | Map<String, Integer> | 否 | - | 调整指定 token 在模型输出内容中出现的概率，使模型生成的内容更加符合特定的偏好。`logit_bias` 字段接受一个 map 值，其中每个键为词表中的 token ID（使用 tokenization 接口获取），每个值为该 token 的偏差值，取值范围为 [-100, 100]。
-1 会减少选择的可能性，1 会增加选择的可能性；-100 会完全禁止选择该 token，100 会导致仅可选择该 token。该参数的实际效果可能因模型而异。 | 
```
{
    "1234": -100
}
json
```
 |
| tools | Array of [ToolParam](/docs/82379/1298454#toolparam) | 否 | - | 模型可以调用的工具列表。目前，仅函数作为工具被支持。用这个来提供模型可能为其生成 JSON 输入的函数列表。 | - |

## 数据结构

### MessageParam



| 参数名称 | 类型 | 是否必填 | 默认值 | 描述 | 示例值 |
| --- | --- | --- | --- | --- | --- |
| role | String | 是 | - | 发出该消息的对话参与者角色，可选值包括：* `system`：System Message 系统消息
* `user`：User Message 用户消息
* `assistant`：Assistant Message 对话助手消息
* `tool`：Tool Message 工具调用消息
 | user |
| content | String | 否 | - | 消息内容* 当 `role` 为 `system`、`user`、`tool`时，参数必填
* 当 `role` 为 `assistant` 时，`content` 与 `tool_calls` 参数二者至少填写其一
 | 世界第一高山是什么？ |
| tool\_calls | Array of [MessageToolCallParam](/docs/82379/1298454#messagetoolcallparam) | 否 | - | 模型生成的工具调用。当 `role` 为 `assistant` 时，`content` 与 `tool_calls` 参数二者至少填其一 | - |
| tool\_call\_id | String | 否 | - | 此消息所回应的工具调用 ID，当 `role` 为 `tool` 时必填 | call\_5y********************** |

### MessageToolCallParam



| 参数名称 | 类型 | 是否必填 | 默认值 | 描述 | 示例值 |
| --- | --- | --- | --- | --- | --- |
| id | String | 是 | - | 当前工具调用 ID | call\_5y********************** |
| type | String | 是 | - | 工具类型，当前仅支持`function` | function |
| function | [FunctionParam](/docs/82379/1298454#functionparam) | 是 | - | 模型需要调用的函数 | - |

### FunctionParam



| 参数名称 | 类型 | 是否必填 | 默认值 | 描述 | 示例值 |
| --- | --- | --- | --- | --- | --- |
| name | String | 是 | - | 模型需要调用的函数名称 | get\_current\_weather |
| arguments | String | 是 | - | 模型生成的用于调用函数的参数，JSON 格式。请注意，模型并不总是生成有效的 JSON，并且可能会虚构出一些您的函数参数规范中未定义的参数。在调用函数之前，请在您的代码中验证这些参数是否有效。 | {"location": "Boston, MA"} |

### ToolParam



| 参数名称 | 类型 | 是否必填 | 默认值 | 描述 | 示例值 |
| --- | --- | --- | --- | --- | --- |
| type | String | 是 | - | 工具类型，当前仅支持 `function` | function |
| function | [FunctionDefinition](/docs/82379/1298454#functiondefinition) | 是 | - | 模型可以调用的工具列表。 | - |

### FunctionDefinition



| 参数名称 | 类型 | 是否必填 | 默认值 | 描述 | 示例值 |
| --- | --- | --- | --- | --- | --- |
| name | String | 是 | - | 函数的名称 | get\_current\_weather |
| description | String | 否 | - | 对函数用途的描述，供模型判断何时以及如何调用该工具函数 | 获取指定城市的天气信息 |
| parameters | Object | 否 |  | 函数请求参数，以 JSON Schema 格式描述。具体格式请参考 [JSON Schema](https://json-schema.org/understanding-json-schema) 文档 | 
```
{
    "type": "object",
    "properties": {
        "location": {
            "type": "string",
            "description": "城市，如：北京",
        },
    },
    "required": ["location"],
}
json
```
 |

### StreamOptionsParam



| 参数名称 | 类型 | 是否必填 | 默认值 | 描述 | 示例值 |
| --- | --- | --- | --- | --- | --- |
| include\_usage | Boolean | 否 | false | 是否包含本次请求的 token 用量统计信息* `false`：不返回 token 用量信息
* `true`：在 `data: [DONE]` 消息之前返回一个额外的块，此块上的 `usage` 字段代表整个请求的 token 用量，`choices` 字段为空数组。所有其他块也将包含 `usage` 字段，但值为 `null`。
 | false |

响应参数## 非流式调用



| 参数名称 | 类型 | 描述 | 示例值 |
| --- | --- | --- | --- |
| id | String | 本次请求的唯一标识 | 021718049470528d92fcbe0865fdffdde******************** |
| model | String | 本次请求实际使用的模型名称和版本 | doubao-pro-4k-240515 |
| created | Integer | 本次请求创建时间的 Unix 时间戳（秒） | 1718049470 |
| object | String | 固定为 `chat.completion` | chat.completion |
| choices | Array of [Choice](/docs/82379/1298454#choice) | 本次请求的模型输出内容 | - |
| usage | [Usage](/docs/82379/1298454#usage) | 本次请求的 tokens 用量 | - |

## 流式调用



| 参数名称 | 类型 | 描述 | 示例值 |
| --- | --- | --- | --- |
| id | String | 本次请求的唯一标识 | 021718049470528d92fcbe0865fdffdde******************** |
| model | String | 本次请求实际使用的模型名称和版本 | doubao-pro-4k-240515 |
| created | Integer | 本次请求创建时间的 Unix 时间戳（秒） | 1718049470 |
| object | String | 固定为 `chat.completion.chunk` | chat.completion.chunk |
| choices | Array of [StreamChoice](/docs/82379/1298454#streamchoice) | 本次请求的模型输出内容 | - |
| usage | [Usage](/docs/82379/1298454#usage) | 本次请求的 tokens 用量 | - |

## 数据结构

### Choice



| 参数名称 | 类型 | 描述 | 示例值 |
| --- | --- | --- | --- |
| index | Integer | 当前元素在 `choices` 列表的索引 | 0 |
| finish\_reason | String | 模型停止生成 token 的原因。可能的值包括：* `stop`：模型输出自然结束，或因命中请求参数 `stop` 中指定的字段而被截断
* `length`：模型输出因达到请求参数 `max_token` 指定的最大 token 数量而被截断
* `content_filter`：模型输出被内容审核拦截
* `tool_calls`：模型调用了工具
 | stop |
| message | [Message](/docs/82379/1298454#message) | 模型输出的内容 |  |
| logprobs | [ChoiceLogprobs](/docs/82379/1298454#choicelogprobs) | 当前内容的对数概率信息 |  |

### Message



| 参数名称 | 类型 | 描述 | 示例值 |
| --- | --- | --- | --- |
| role | String | 固定为 `assistant` | assistant |
| content | String | 模型生成的消息内容，`content` 与 `tool_calls` 字段二者至少有一个为非空 | "你好" |
| tool\_calls | Array of [MessageToolCall](/docs/82379/1298454#messagetoolcall) | 模型生成的工具调用，`content` 与 `tool_calls` 字段二者至少有一个为非空 |  |

### MessageToolCall



| 参数名称 | 类型 | 描述 | 示例值 |
| --- | --- | --- | --- |
| id | String | 当前工具调用 ID | call\_5y********************** |
| type | String | 工具类型，当前仅支持`function` | function |
| function | [Function](/docs/82379/1298454#function) | 模型需要调用的函数 |  |

### Function



| 参数名称 | 类型 | 描述 | 示例值 |
| --- | --- | --- | --- |
| name | String | 模型需要调用的函数名称 | get\_current\_weather |
| arguments | String | 模型生成的用于调用函数的参数，JSON 格式。请注意，模型并不总是生成有效的 JSON，并且可能会虚构出一些您的函数参数规范中未定义的参数。在调用函数之前，请在您的代码中验证这些参数是否有效。 | {"location": "Boston, MA"} |

### ChoiceLogprobs



| 参数名称 | 类型 | 描述 | 示例值 |
| --- | --- | --- | --- |
| content | Array of [TokenLogprob](/docs/82379/1298454#tokenlogprob) | `message`列表中每个 `content` 元素中的 token 对数概率信息 | - |

### TokenLogprob



| 参数名称 | 类型 | 描述 | 示例值 |
| --- | --- | --- | --- |
| token | String | 当前 token | The |
| bytes | Array of Integer | 当前 token 的 UTF-8 值，格式为整数列表。当一个字符由多个 token 组成（表情符号或特殊字符等）时可以用于字符的编码和解码。如果 token 没有 UTF-8 值则为空。 | [84, 104, 101] |
| logprob | Float | 当前 token 的对数概率 | -0.0155029296875 |
| top\_logprobs | Array of [TopLogprob](/docs/82379/1298454#toplogprob) | 在当前 token 位置最有可能的标记及其对数概率的列表。在一些情况下，返回的数量可能比请求参数 `top_logprobs` 指定的数量要少。 | - |

### TopLogprob



| 参数名称 | 类型 | 描述 | 示例值 |
| --- | --- | --- | --- |
| token | String | 当前 token | The |
| bytes | Array of Integer | 当前 token 的 UTF-8 值，格式为整数列表。当一个字符由多个 token 组成（表情符号或特殊字符等）时可以用于字符的编码和解码。如果 token 没有 UTF-8 值则为空。 | [84, 104, 101] |
| logprob | Float | 当前 token 的对数概率 | -0.0155029296875 |

### Usage



| 参数名称 | 类型 | 描述 | 示例值 |
| --- | --- | --- | --- |
| prompt\_tokens | Integer | 输入的 prompt token 数量 | 130 |
| completion\_tokens | Integer | 模型生成的 token 数量 | 100 |
| total\_tokens | Integer | 本次请求消耗的总 token 数量（输入 + 输出） | 240 |

### StreamChoice



| 参数名称 | 类型 | 描述 | 示例值 |
| --- | --- | --- | --- |
| index | Integer | 当前元素在 `choices` 列表的索引 | 0 |
| finish\_reason | String | 模型停止生成 token 的原因。可能的值包括：* `stop`：模型输出自然结束，或因命中请求参数 `stop` 中指定的字段而被截断
* `length`：模型输出因达到请求参数 `max_token` 指定的最大 token 数量而被截断
* `content_filter`：模型输出被内容审核拦截
* `tool_calls`：模型调用了工具
 | stop |
| delta | [ChoiceDelta](/docs/82379/1298454#choicedelta) | 模型输出的内容 | - |
| logprobs | [ChoiceLogprobs](/docs/82379/1298454#choicelogprobs) | 当前内容的对数概率信息 | - |

### ChoiceDelta



| 参数名称 | 类型 | 描述 | 示例值 |
| --- | --- | --- | --- |
| role | String | 固定为 `assistant` | assistant |
| content | String | 模型生成的消息内容，`content` 与 `tool_calls` 字段二者必有一个为非空 | "你好" |
| tool\_calls | Array of [ChoiceDeltaToolCall](/docs/82379/1298454#choicedeltatoolcall) | 模型生成的工具调用列表，`content` 与 `tool_calls` 字段二者必有一个为非空 | - |

### ChoiceDeltaToolCall



| 参数名称 | 类型 | 描述 | 示例值 |
| --- | --- | --- | --- |
| index | Interger | 当前元素在 `tool_calls` 列表的索引 | 0 |
| id | String | 当前工具调用 ID | call\_5y********************** |
| type | String | 工具类型，当前仅支持`function` | function |
| function | [Function](/docs/82379/1298454#function) | 模型需要调用的函数 | - |

请求示例
```
curl https://ark.cn-beijing.volces.com/api/v3/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ea764f0f-3b60-45b3-****-************" \
  -d '{
 "model": "ep-20240704******-*****",
 "messages": [
 {
 "role": "system",
 "content": "You are a helpful assistant."
 },
 {
 "role": "user",
 "content": "Hello!"
 }
 ]
 }'
bash
```
响应示例
```
{
    "id": "021718067849899d92fcbe0865fdffdde********************",
    "object": "chat.completion",
    "created": 1720582714,
    "model": "doubao-pro-32k-240615",
    "choices": [{
        "index": 0,
        "message": {
            "role": "assistant",
            "content": "Hello, can i help you with something?"
        },
        "logprobs": null,
        "finish\_reason": "stop"
    }],
    "usage": {
        "prompt\_tokens": 22,
        "completion\_tokens": 9,
        "total\_tokens": 31
    }
}
json
```
错误处理## 错误响应

本接口调用失败的返回结构和参数释义请参见[返回结构](/docs/82379/1298460)文档。  


## 错误码

本接口与业务逻辑相关的错误码如下表所示。公共错误码请参见公共错误码文档。



| HTTP 状态码 | 错误类型 type | 错误代码 code | 错误信息 message | 含义 |
| --- | --- | --- | --- | --- |
| 400 | BadRequest | SensitiveContentDetected | The request failed because the input text may contain sensitive information. | 输入文本可能包含敏感信息，请您使用其他 prompt。 |

[上一篇模型能力概览](/docs/82379/1302004)[下一篇ChatCompletions-视觉理解](/docs/82379/1362913)