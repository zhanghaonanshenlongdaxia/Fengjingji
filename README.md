# 风景集 · Scenery Collection

LÖVE 2D 程序化风景画廊 —— 20 个全程序绘制的氛围场景(无外部资源)。

## 场景列表
| No. | 主题 | 文件 |
|-----|------|------|
| 01  | 秋日林间 Autumn Forest       | `scenes/autumn_forest.lua` |
| 02  | 薰衣草之夜 Lavender Night    | `scenes/lavender_night.lua` |
| 03  | 沙漠黄昏 Desert Dusk         | `scenes/desert_dusk.lua` |
| 04  | 珊瑚礁珊瑚海 Coral Reef      | `scenes/coral_reef.lua` |
| 05  | 竹林晨雾 Bamboo Mist         | `scenes/bamboo_mist.lua` |
| 06  | 极光雪原 Aurora Snow         | `scenes/aurora_snow.lua` |
| 07  | 雪山旅馆 Snow Hotel          | `scenes/snow_hotel.lua` |
| 08  | 江南水乡 Water Town          | `scenes/water_town.lua` |
| 09  | 樱花神社 Sakura Shrine       | `scenes/sakura_shrine.lua` |
| 10  | 霓虹雨夜 Rain Neon           | `scenes/rain_neon.lua` |
| 11  | 草原拂晓 Grassland Dawn      | `scenes/grassland_dawn.lua` |
| 12  | 火山熔岩 Volcano Lava        | `scenes/volcano_lava.lua` |
| 13  | 沉船深海 Shipwreck Deep      | `scenes/shipwreck_deep.lua` |
| 14  | 雪顶高峰 Snow Summit         | `scenes/snow_summit.lua` |
| 15  | 绿洲之夜 Oasis Night         | `scenes/oasis_night.lua` |
| 16  | 樱花隧道 Sakura Tunnel       | `scenes/sakura_tunnel.lua` |
| 17  | 雾凇松林 Rime Pine Forest    | `scenes/rime_pine_forest.lua` |
| 18  | 冰洞冰晶 Ice Cave            | `scenes/ice_cave.lua` |
| 19  | 屋顶黄昏 Rooftop Dusk        | `scenes/rooftop_dusk.lua` |
| 20  | 萤火虫林 Firefly Wood        | `scenes/firefly_wood.lua` |

## 文件结构
- `main.lua` 入口,加载 20 个场景并支持 `←/→` 切换
- `conf.lua` 窗口/版本配置(窗口标题:风景集 · 场景集)
- `scenes/manager.lua` 场景注册表
- `scenes/*.lua` 20 个独立场景模块
- `fonts/Deng.ttf` 中文字体(Windows 等线,完整 Unicode cmap)
- `tools/snapshot.lua` + `tools/snap_love.py` 截图工具
- `verify_all_20.py` / `verify_all_10.py` 批量截图脚本
- `.gitignore`

## 运行
将项目目录拖到 `love.exe`,或:

```bat
"D:\godotProject\tools\love\love-11.5-win64\love.exe" "D:\godotProject\风景集"
```

启动脚本:`_verify_love_start.bat` / `_verify_love_start.ps1`

## 操作
- `←` / `→` 切换场景
- `Esc` 退出

## 字体说明
默认 LÖVE 字体不含中文字形,常见 simhei / msyh 在 LÖVE 11.5 下部分汉字显示为方框(tofu)。  
改用 Windows 8+ 自带的「等线」Deng.ttf(含完整 Unicode cmap)解决。

## 截图工具
```bash
# 截取当前窗口
python tools/snap_love.py

# 批量截取 20 张
python verify_all_20.py
```
