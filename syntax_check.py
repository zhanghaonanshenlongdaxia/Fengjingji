"""
风景集 / 深度静态检查 (clean)
- main.lua 里所有 require 目标都存在 (走 scenes/ 子目录)
- scenes/*.lua 里所有 require 目标都存在
- function / end 配对
- 必备接口
"""
import re
from pathlib import Path

ROOT  = Path(r"D:\godotProject\风景集")
SCN   = ROOT / "scenes"

print("=" * 60)
print("  风景集 / 深度静态检查 (clean)")
print("=" * 60)
all_ok = True

# 把 require 路径 ("scenes.xxx") 转成磁盘路径 ("scenes/xxx.lua")
def to_path(name: str) -> Path:
    return SCN / f"{name.split('.', 1)[1]}.lua"

# 1) main.lua require
print("\n[1] main.lua require 解析")
main = (ROOT / "main.lua").read_text(encoding="utf-8")
requires = re.findall(r'require(?:\s*\(\s*)?["\']([\w\./]+)["\']', main)
print(f"  共 {len(requires)} 个 require:")
for r in requires:
    p = to_path(r)
    if p.exists():
        print(f"    ✓ {r}  →  {p.relative_to(ROOT)}")
    else:
        print(f"    ✗ {r}  ❌ MISSING  →  {p}")
        all_ok = False

# 2) scenes/*.lua 内部 require
print("\n[2] scenes/*.lua 内部 require")
broken = []
for sf in sorted(SCN.glob("*.lua")):
    c = sf.read_text(encoding="utf-8")
    rs = re.findall(r'require(?:\s*\(\s*)?["\']([\w\./]+)["\']', c)
    for r in rs:
        p = to_path(r)
        if not p.exists():
            print(f"  ✗ {sf.name} → require {r} ❌ MISSING")
            broken.append((sf.name, r))
            all_ok = False
if not broken:
    print(f"  ✓ 所有 scene 的 require 全部满足")

# 3) function / end 配对 (Lua 里有 for/if/while/do 也要 end, 所以 end >= function)
print("\n[3] function / end 配对 (end 应 >= function)")
for sf in sorted(SCN.glob("*.lua")):
    c = sf.read_text(encoding="utf-8")
    n_func = len(re.findall(r"\bfunction\b", c))
    n_end  = len(re.findall(r"\bend\b", c))
    if n_end >= n_func:
        print(f"  ✓ {sf.name:22s}  function={n_func:3d}  end={n_end:3d}  (end-function={n_end-n_func})")
    else:
        print(f"  ✗ {sf.name:22s}  function={n_func}  end={n_end}  ❌ end 少于 function!")
        all_ok = False

# 4) scene 必备接口 (只有 M.draw 必备, 其余可选)
print("\n[4] 必备接口 (M.draw 必备; M.update/keypressed/mousepressed/mousemoved 可选)")
need_required = ["M.draw"]
need_optional = ["M.update", "M.keypressed", "M.mousepressed", "M.mousemoved"]
ok_req = 0
ok_opt = 0
for sf in sorted(SCN.glob("*.lua")):
    if sf.name == "manager.lua":
        continue
    c = sf.read_text(encoding="utf-8")
    miss_req = [n for n in need_required if f"function {n}" not in c]
    miss_opt = [n for n in need_optional if f"function {n}" not in c]
    if miss_req:
        print(f"  ✗ {sf.name:22s}  缺必备: {', '.join(miss_req)}")
        all_ok = False
    else:
        ok_req += 1
    if not miss_opt:
        ok_opt += 1
print(f"  ✓ {ok_req} 张场景 M.draw 齐全, {ok_opt} 张 5 个接口全齐全")

# 5) 总结
print()
print("=" * 60)
if all_ok:
    print("  ✅ 深度检查: 全部通过")
else:
    print("  ❌ 有问题, 看上面 ✗ 行")
print("=" * 60)
