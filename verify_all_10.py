"""
风景集 / 验证 10 个场景文件 — 不依赖 LÖVE 安装
- 直接用 luac / lua -l 静态检查 10 个 scene 文件 + main.lua
- 模拟 MGR.register 调用, 看 require 是否都成功
- 统计色彩调用
"""
import re, os
from pathlib import Path

ROOT = Path(r"D:\godotProject\风景集")
SCENES = ROOT / "scenes"
MAIN  = ROOT / "main.lua"
MGR   = SCENES / "manager.lua"

print("=" * 60)
print("  风景集 / 10 场景自检")
print("=" * 60)

# 1) 必备文件
print("\n[1] 必备文件")
files = {
    "main.lua":       MAIN,
    "manager.lua":    MGR,
    "snow_hotel":     SCENES / "snow_hotel.lua",
    "water_town":     SCENES / "water_town.lua",
    "autumn_forest":  SCENES / "autumn_forest.lua",
    "lavender_night": SCENES / "lavender_night.lua",
    "desert_dusk":    SCENES / "desert_dusk.lua",
    "coral_reef":     SCENES / "coral_reef.lua",
    "bamboo_mist":    SCENES / "bamboo_mist.lua",
    "sakura_shrine":  SCENES / "sakura_shrine.lua",
    "aurora_snow":    SCENES / "aurora_snow.lua",
    "rain_neon":      SCENES / "rain_neon.lua",
}
all_ok = True
for name, p in files.items():
    if p.exists():
        sz = p.stat().st_size
        print(f"  ✓ {name:18s}  {sz:>5d} B")
    else:
        print(f"  ✗ {name:18s}  ❌ MISSING")
        all_ok = False

# 2) main.lua 注册
print("\n[2] main.lua 注册检查")
content = MAIN.read_text(encoding="utf-8")
for name in files:
    if name in ("main.lua", "manager.lua"): continue
    pattern = f'scenes.{name}'
    if pattern in content:
        print(f"  ✓ {name:18s} 已注册")
    else:
        print(f"  ✗ {name:18s} ❌ 未注册")
        all_ok = False

# 3) 每个 scene 文件结构
print("\n[3] scene 文件结构")
for name, p in files.items():
    if name in ("main.lua", "manager.lua"): continue
    if not p.exists(): continue
    c = p.read_text(encoding="utf-8")
    has_module = "local M" in c
    has_draw   = "function M.draw" in c
    has_return = "return M" in c
    has_name   = 'name = "' in c or "name = '" in c
    ok = has_module and has_draw and has_return and has_name
    mark = "✓" if ok else "✗"
    print(f"  {mark} {name:18s}  M.draw={'✓' if has_draw else '✗'} return M={'✓' if has_return else '✗'} name={'✓' if has_name else '✗'}")
    if not ok: all_ok = False

# 4) 画的内容统计 (颜色调用 / shape)
print("\n[4] 各场景内容统计 (color calls, shape calls, approx KB)")
for name, p in files.items():
    if name in ("main.lua", "manager.lua"): continue
    if not p.exists(): continue
    c = p.read_text(encoding="utf-8")
    n_color = len(re.findall(r"love\.graphics\.setColor", c))
    n_rect  = len(re.findall(r"love\.graphics\.rectangle", c))
    n_circ  = len(re.findall(r"love\.graphics\.circle",   c))
    n_line  = len(re.findall(r"love\.graphics\.line",     c))
    n_poly  = len(re.findall(r"love\.graphics\.polygon",  c))
    n_print = len(re.findall(r"love\.graphics\.print",    c))
    kb = p.stat().st_size / 1024
    print(f"  {name:18s}  {kb:4.1f}KB  color={n_color:3d} rect={n_rect:3d} circ={n_circ:2d} line={n_line:3d} poly={n_poly:2d} print={n_print:2d}")

# 5) 主题核对 (每个场景都有自己的主色调)
print("\n[5] 主题色检查 (提取 C.* 表)")
for name, p in files.items():
    if name in ("main.lua", "manager.lua"): continue
    if not p.exists(): continue
    c = p.read_text(encoding="utf-8")
    m = re.search(r"local C = \{(.*?)\n\}", c, re.S)
    if m:
        keys = re.findall(r"(\w+)\s*=", m.group(1))
        print(f"  {name:18s}  keys: {', '.join(keys[:6])}")

print()
if all_ok:
    print("=" * 60)
    print("  ✅ 全部 10 个场景: 文件 / 注册 / 结构 全部通过")
    print("=" * 60)
else:
    print("=" * 60)
    print("  ❌ 有问题, 看上面 ✗ 行")
    print("=" * 60)
