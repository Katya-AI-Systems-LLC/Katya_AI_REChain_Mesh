# AI / Agents Plan

- Interfaces: `AIService`, `AgentOrchestrator`, `ToolRegistry`
- Providers: OpenAI/GPT, local models (gguf), MCP clients
- CODE+VIBE bridge: serialize intent+context+artifacts for Mesh transport

MVP Tasks:
- Define agent protocol in Dart (requests, tools, results)
- Add local inference toggle and caching
- Security: sandbox tools, rate limits, redaction
