# 開發階段與待解問題

## 12. 開發階段

### Phase 0 — Prototype

- [ ] Odin + Raylib 基礎專案設定
- [ ] 基礎 raycasting renderer（固定牆高）
- [ ] 玩家移動 + 視角旋轉
- [ ] 單一光源影響 ray 射程（Illuminate 概念驗證）
- [ ] 一個 Void 物種（Drifter）+ 基礎 A* pathfinding
- [ ] Lantern：Illuminate + Flare 僅此兩種
- [ ] 單一 Amber 結構的放置 + tick
- [ ] 基礎 Lumen 消耗循環

### Phase 1 — Vertical Slice

- [ ] 地板 / 天花板明暗渲染（光源感知）
- [ ] 多光源疊加（玩家 + 結構）
- [ ] 3 個 Void 物種，各自行為不同
- [ ] 3 種結構類型
- [ ] Lumen 經濟端到端運作
- [ ] 完整 Lantern 能力組
- [ ] 捕捉 + Void Garden（無培育）
- [ ] 10 波 run 循環 + 死亡狀態
- [ ] **餘燼**：Run 1–5 對話
- [ ] 2 個 lore imprint 放置

### Phase 2 — Alpha

- [ ] 完整物種名冊（6 種 + Behemoth）
- [ ] Void Garden 培育系統：主動餵食、10 隻上限、每種最多 3 隻、視覺狀態（無數字）
- [ ] Garden cap 滿時的陰影殘影（次次 Reflection 出現後消散）
- [ ] Garden 餵食視覺線索：Run 15+ 認出行為、Run 20+ 互相轉向
- [ ] 命名機制：Fragment 片段列表 UI、Codex 深層條目解鎖
- [ ] Garden 無上限解鎖條件：每種物種各命名一隻
- [ ] **餘念**樹（數值升級）
- [ ] Fragment 系統：聆聽模式、見證動作、Fragment 解鎖樹（機制升級）
- [ ] Void Codex 雙層解鎖（捕捉層 + 聆聽 / 命名深層）
- [ ] Salvage Phase + Dimming Boundary
- [ ] Named Void 系統
- [ ] Behemoth 跨 run 見證累積系統（5 次見證 → 自己走進 Garden）
- [ ] Behemoth Codex 深層條目（含第一個**拾薪者**名字，Ending C 所需）
- [ ] **餘燼**對話：Run 1–22（含 Run 11–22 選擇性追問觸發）
- [ ] Lore 碎片完整組（Boundary imprint）
- [ ] Wave grammar 系統（Pressure_Type）
- [ ] 油畫風格 texture 第一版
- [ ] 早期無聲線索音效：燒 Lumen 的人聲雜訊（Run 1–3）
- [ ] LLM 系統：Ollama backend 整合、context 組裝、fallback 驗證
- [ ] LLM system prompt red-team：確認 truth_layer 約束不會洩漏敘事

### Phase 3 — Beta / 內容完成

- [ ] Run 23–29 **餘燼**對話
- [ ] 三個結局實作
- [ ] 結局 C（Garden）—— 需要 Behemoth 弧線
- [ ] 音效方向：物種 motif、**餘燼**音調組
- [ ] **餘映**房間視覺演化（run 數狀態）
- [ ] 全面平衡：Lumen 經濟、波次升級

---

## 13. 待解問題

| 問題 | 負責方向 | 阻塞？ |
|---|---|---|
| Raycasting 在 Odin 的效能：要不要用多線程 column 渲染？ | Tech | Phase 0 確認 |
| 捕捉引導（3 秒按住）在即時波次中的 feel——緊張還是挫折？ | Playtest | 是 |
| Dim 能力是否創造有趣的湧現玩法，還是太情境化？ | Playtest | 否 |
| Named Void 如果沒有被捕捉，下一個 run 是否重新出現？ | 敘事 | 否 |
| Void Garden 餵食：主動放入 Lumen（Slime Rancher 式），還是自動消耗？ | Design | 否 |
| Fragment 和 Lumen 的效率差距多大？記憶路線難度上限在哪？ | Design + Balance | Phase 2 前 |
| 聆聽模式（Tether 不拉取）的 5–8 秒引導，在波次中是否過長？ | Playtest | 是 |
| Behemoth 見證的 20 秒門檻在波次壓力下是否可行？需要實測 | Playtest | 是 |
| Garden 兩種路線（燃燒 vs. 記憶）在同一隻生物上互斥——UI 是否需要提示切換的代價？ | Design | 否 |
| 早期無聲線索的音量 / 頻率校準：要讓玩家「幾乎不注意到」，不能太明顯 | Design + Audio | Phase 2 前 |
| LLM system prompt 的 truth_layer 約束夠不夠穩健？需要 red-team 測試 | Tech + 敘事 | Phase 2 前 |
