# 視覺與音效

## 視覺語言

**主色調：**
- `#F5C842` — Amber（暖 Lumen 光、生命、記憶）
- `#2A2A2A` — Void Black（純粹的、吞噬一切的黑）
- `#C8B89A` — Ash Grey（中間地帶、灰塵、消逝之物）
- `#1A0F00` — Deep Ember（光緣的餘燼、危險）

**視覺原則：**
- 黑暗是**純黑**，不是深灰。光的缺席，是絕對的缺席。
- 光源邊緣有硬 bloom——光在空氣中產生的可見體積。
- 美術方向走油畫筆觸：牆面 texture 手繪感，sprite 邊緣不規則。
- Void 生物在光中露出暗沉的暖色底調；在黑暗中只剩下輪廓和發光的眼睛。

**3D + GLSL shader 的視覺特性：**
- Raylib 3D 場景：tile map → cube 牆壁 + 平面地板／天花板
- 光暗效果由 fragment shader 計算：每個像素依距最近光源的 XZ 距離決定亮度
- 地板和天花板逐像素漸層：#F5C842 Amber（光源附近）→ #2A2A2A Void Black（光源外）
- 多光源加法疊加（亮度 clamp 1.0），玩家 Lantern + 結構光源同時作用
- Void sprite 仍是 billboard（DrawBillboard，永遠面向玩家）
- 牆面 texture 手繪油畫風；shader 的 vertex color tint 讓每面牆可有色相偏移

---

## 音效方向

- Ambient：Lumen 燃料燃燒的低頻嗡嗡聲、遠處的風
- Void 生物先有聲音，才有視覺——聲音是第一個警告
- 音樂：稀疏鋼琴，每個 Void 物種一個樂器 motif，安靜階段無打擊樂
- 死亡畫面：靜默，然後一聲 **餘燼**的單音
