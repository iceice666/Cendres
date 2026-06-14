// HTTP client、非同步請求、超時處理 — GDD §9.6
// Hits localhost (Ollama/llama.cpp OpenAI-compatible endpoint) or cloud API.
// On timeout: silent fallback to handwritten lines (player never sees the error).
// TODO(Phase 2): request_beacon_line, http_post, parse_llm_response procs.
package llm
