
# 通用（common）核心类功能简介

> ⚠️ 重要提醒：
> 
> - 本脚本完全基于 AutoHotkey v2.0 语法和函数实现，仅在像素获取部分做了底层优化。
> - 仅适用于 Windows 系统，且需提前安装 AHK v2.0。
> - 由于 AHK 不支持多文件类的跨文件调用，建议所有代码均写在一个 .ahk 文件中，统一编译和运行。

本节介绍所有主流代码版本（工程版/教学版/调试版）均包含的基础类功能，属于本框架的“公共能力”。

---


## WindowArranger
自动查找、激活并排列所有目标应用窗口，支持多窗口批量处理。


**典型调用：**

```autohotkey
arranger := WindowArranger(targetAppName, minWindowWidth, minWindowHeight)
windowArray := arranger.ArrangeWindows()
; windowArray 为 [[windowId, x1, y1, x2, y2], ...]
```
**参数说明：**
- `targetAppName`：目标应用窗口的识别标识，支持窗口标题、`ahk_class`、`ahk_exe`、窗口ID等多种方式（如 "ahk_exe notepad.exe"、"ahk_class Notepad"、窗口标题字符串、窗口十进制ID）。
	> 建议提前用 WinSpy、AutoIt Window Info 等工具获取窗口的唯一标识。
- `minWindowWidth` / `minWindowHeight`：只排列大于此尺寸的窗口，过滤弹窗/隐藏窗。


## RectangleInfo
负责将指定区域按 X/Y 方向分割为网格，生成所有子区域坐标。


**典型调用：**

```autohotkey
rect := RectangleInfo([x1, y1, x2, y2], xModNum, yModNum)
subRects := rect.GetAllSubRects()
; subRects 为所有子区域坐标数组
```
**参数说明：**
- `[x1, y1, x2, y2]`：待分割的矩形区域左上和右下坐标。
- `xModNum` / `yModNum`：X/Y 方向的分割份数（通常为网格列数/行数）。


## CoordinateMapping
实现点到网格单元的映射，支持“给定坐标，判断属于哪个格子”。


**典型调用：**

```autohotkey
mapper := CoordinateMapping([x1, y1, x2, y2], xModNum, yModNum)
cellIndex := mapper.GetCellIndex(x, y)
; cellIndex 返回 [row, col] 或单元格编号
```
**参数说明：**
- `[x1, y1, x2, y2]`：网格区域的左上和右下坐标。
- `xModNum` / `yModNum`：X/Y 方向的分割份数。
- `x, y`：待判断的实际像素坐标。


## WindowColorRegion
用于调试时在屏幕上高亮显示指定区域，支持半透明彩色矩形。


**典型调用：**

```autohotkey
region := WindowColorRegion(windowId, [x1, y1, x2, y2], 0xFF0000, 1000)
region.ShowRegion()
```
**参数说明：**
- `windowId`：目标窗口的句柄。
- `[x1, y1, x2, y2]`：高亮显示的区域坐标（客户区）。
- `0xFF0000`：高亮颜色（RGB 16进制）。
- `1000`：高亮持续时间（毫秒）。
