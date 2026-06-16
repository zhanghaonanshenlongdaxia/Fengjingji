"""
风景集 / 验证 20 个场景文件 — 不依赖 LÖVE 安装
- 直接静态检查 20 个 scene 文件 + main.lua
- 看 require 是否都注册
- 统计色彩/形状调用
"""
import re
from pathlib import Path

ROOT = Path(r"D:\godotProject\风景集")
SCENES = ROOT / "scenes"
MAIN  = ROOT / "main.lua"
MGR   = SCENES / "manager.lua"

ALL_SCENES = [
    # No.1 ~ No.10
    "snow_hotel", "water_town", "autumn_forest", "lavender_night",
    "desert_dusk", "coral_reef", "bamboo_mist", "sakura_shrine",
    "aurora_snow", "rain_neon",
    # No.11 ~ No.20
    "grassland_dawn", "volcano_lava", "shipwreck_deep", "snow_summit",
    "oasis_night", "sakura_tunnel", "rime_pine_forest", "rooftop_dusk",
    "firefly_wood", "ice_cave",
]

print("=" * 60)
print(f"  风景集 / {len(ALL_SCENES)} 场景自检")
print("=" * 60)

# 1) 必备文件
print("\n[1] 必备文件")
files = {
    "main.lua": MAIN,
    "manager.lua": MGR,
}
for s in ALL_SCENES:
    files[s] = SCENES / f"{s}.lua"
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
for s in ALL_SCENES:
    pattern = f"scenes.{s}"
    if pattern in content:
        print(f"  ✓ {s:18s} 已注册")
    else:
        print(f"  ✗ {s:18s} ❌ 未注册")
        all_ok = False

# 3) 每个 scene 文件结构
print("\n[3] scene 文件结构 (M.draw / return M / name)")
for s in ALL_SCENES:
    p = SCENES / f"{s}.lua"
    if not p.exists():
        continue
    c = p.read_text(encoding="utf-8")
    has_module = "local M" in c
    has_draw   = "function M.draw" in c
    has_return = "return M" in c
    has_name   = 'name = "' in c or "name = '" in c
    ok = has_module and has_draw and has_return and has_name
    mark = "✓" if ok else "✗"
    print(f"  {mark} {s:18s}  M.draw={'✓' if has_draw else '✗'} return M={'✓' if has_return else '✗'} name={'✓' if has_name else '✗'}")
    if not ok:
        all_ok = False

# 4) 画的内容统计
print("\n[4] 各场景内容统计 (color / shape / KB)")
for s in ALL_SCENES:
    p = SCENES / f"{s}.lua"
    if not p.exists():
        continue
    c = p.read_text(encoding="utf-8")
    n_color = len(re.findall(r"love\.graphics\.setColor", c))
    n_rect  = len(re.findall(r"love\.graphics\.rectangle", c))
    n_circ  = len(re.findall(r"love\.graphics\.circle",   c))
    n_line  = len(re.findall(r"love\.graphics\.line",     c))
    n_poly  = len(re.findall(r"love\.graphics\.polygon",  c))
    n_print = len(re.findall(r"love\.graphics\.print",    c))
    n_ellip = len(re.findall(r"love\.graphics\.ellipse",  c))
    kb = p.stat().st_size / 1024
    print(f"  {s:18s}  {kb:4.1f}KB  color={n_color:3d} rect={n_rect:3d} circ={n_circ:2d} line={n_line:3d} poly={n_poly:2d} ellip={n_ellip:2d} print={n_print:2d}")

# 5) 主题色
print("\n[5] 主题色检查 (提取 C.* 表前 6 个 key)")
for s in ALL_SCENES:
    p = SCENES / f"{s}.lua"
    if not p.exists():
        continue
    c = p.read_text(encoding="utf-8")
    m = re.search(r"local C = \{(.*?)\n\}", c, re.S)
    if m:
        keys = re.findall(r"(\w+)\s*=", m.group(1))
        print(f"  {s:18s}  keys: {', '.join(keys[:6])}")

# 6) No. 顺序对照
print("\n[6] 场景 No. 与 main.lua 注册顺序对照")
order_in_main = [n for n in re.findall(r"scenes\.(\w+)", content) if n != "manager"]
expected = ALL_SCENES
if order_in_main == expected:
    print(f"  ✓ main.lua 注册顺序与 ALL_SCENES 一致 ({len(order_in_main)} 张)")
else:
    print(f"  ✗ 顺序不一致!")
    print(f"    main.lua: {order_in_main}")
    print(f"    expected: {expected}")
    all_ok = False

print()
print("=" * 60)
if all_ok:
    print(f"  ✅ 全部 {len(ALL_SCENES)} 个场景: 文件 / 注册 / 结构 全部通过")
else:
    print("  ❌ 有问题, 看上面 ✗ 行")
print("=" * 60)
