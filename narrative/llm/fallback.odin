// 手寫台詞 pool、關鍵 run 查表 — GDD §9.6
// Three-tier fallback: critical-run exact line → death-cause pool → pool[run%len].
// get_handwritten_line is always present regardless of LLM config.
// TODO(Phase 1): CRITICAL_LINES table + DEATH_CAUSE_POOLS from GDD §9.6.
package llm
