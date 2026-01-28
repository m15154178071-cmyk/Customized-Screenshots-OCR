; ===== 教学版 (Teaching Version) =====
; 特点：使用标准 AHK 命令 (PixelGetColor) 实现核心逻辑，代码结构清晰，适合学习算法原理。
; ===================================
; ===== Module: OS Adapter (Experiment Layer & wrappers) =====
/*
 单文件模块化结构（目录）
  1) Module: OS Adapter (Experiment Layer & wrappers)
  2) Module: Global Config & Boot
  3) Module: Window Arranger
  4) Module: Geometry & Region Models (Point/Rect/Mapping/ColorRegion...)
  5) Business Logic, Hotkeys and Utilities

 注意：仅添加了模块注释与小修（修正 OS_Click() 调用缺失括号），未改变原有流程与接口。
*/
; ========================= AHK v2 Experiment Layer =========================
; This is an instrumented build of 改良版3 (DO NOT modify 改良版2).
; Adds: lightweight logging, throttling, and jitter around OS_* wrappers.
; Toggle via g_logEnabled / g_throttleMs / g_jitterMs below.
; 日志功能总开关，true 时记录实验层行为
g_logEnabled := false
; 是否绕过实验封装，true 时直接调用原始 OS_* 函数
g_wrapperBypass := true  ; 先保持绕过，和原来一样快
; 日志文件输出路径
g_logFile := A_ScriptDir . "\ahk_experiment.log"
; 每次 OS_* 调用后的基础延迟
g_throttleMs := 10     ; base sleep after each OS_* call
; 额外抖动延迟的上限，用于模拟随机延迟
g_jitterMs := 10     ; extra random sleep [0..jitter] ms

; 追加式日志写入工具，记录简单字符串
Log(msg) {
    global g_logEnabled, g_logFile
    if !g_logEnabled
        return
    ts := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss.fff")
    try {
        FileAppend(ts "  " msg "`n", g_logFile, "UTF-8")
    } catch {
        ; ignore logging errors
    }
}

; --- Param logging helpers ---
; 将任意参数安全转换为字符串，避免异常
San(v) {
    try {
        s := "" . v
    } catch {
        s := "<val>"
    }
    if (StrLen(s) > 120)
        s := SubStr(s, 1, 120) . "...(" . StrLen(s) . ")"
    return s
}
; 将数组内容连接为字符串，默认使用逗号分隔
StrJoin(arr, sep := ", ") {
    out := ""
    for i, v in arr
        out .= (i = 1 ? "" : sep) v
    return out
}
; 记录函数调用与参数，kv* 以键值对形式传入
LogCall(fn, kv*) {
    global g_logEnabled, g_logFile
    if !g_logEnabled
        return
    ts := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss.fff")
    line := ts "  " fn
    i := 1
    while (i <= kv.Length) {
        k := kv[i], v := (i + 1 <= kv.Length ? kv[i + 1] : "")
        line .= "  " k ": " San(v)
        i += 2
    }
    try {
        FileAppend(line "`n", g_logFile, "UTF-8")
    } catch {
        ; ignore
    }
}
; --- end helpers ---

; 在包装函数中增加可配置节流与随机等待
Throttle() {
    global g_throttleMs, g_jitterMs
    j := (g_jitterMs > 0) ? Random(0, g_jitterMs) : 0
    total := g_throttleMs + j
    if (total > 0)
        Sleep(total)
}
; ==========================================================================
;
; === Experiment Wrappers (auto-generated) ===
;
; 鼠标移动包装，附带节流与参数日志
OS_MouseMove(x, y, speed := 0) {
    global g_wrapperBypass
    if (g_wrapperBypass)
        return OS_MouseMove_orig(x, y, speed)

    Throttle()
    if (g_logEnabled)
        LogCall("OS_MouseMove", "x", x, "y", y, "speed", speed)
    return OS_MouseMove_orig(x, y, speed)
}
; 鼠标点击包装，支持多次点击
OS_Click(btn := "L", times := 1) {
    global g_wrapperBypass
    if (g_wrapperBypass)
        return OS_Click_orig(btn, times)

    Throttle()
    if (g_logEnabled)
        LogCall("OS_Click", "btn", btn, "times", times)
    return OS_Click_orig(btn, times)
}
; 获取指定坐标颜色的包装
OS_PixelGetColor(x, y, mode := "RGB") {
    global g_wrapperBypass
    if (g_wrapperBypass)
        return OS_PixelGetColor_orig(x, y, mode)

    Throttle()
    if (g_logEnabled)
        LogCall("OS_PixelGetColor", "x", x, "y", y, "mode", mode)
    return OS_PixelGetColor_orig(x, y, mode)
}
; 像素搜索包装，保留 ByRef 输出
OS_PixelSearch(&outX, &outY, args*) {
    global g_wrapperBypass
    if (g_wrapperBypass)
        return OS_PixelSearch_orig(&outX, &outY, args*)

    Throttle()
    if (g_logEnabled)
        LogCall("OS_PixelSearch", "outX", outX, "outY", outY, "args", StrJoin(args, ", "))
    return OS_PixelSearch_orig(&outX, &outY, args*)
}
; 激活窗口包装，记录窗口标识
OS_WinActivate(winId) {
    global g_wrapperBypass
    if (g_wrapperBypass)
        return OS_WinActivate_orig(winId)

    Throttle()
    if (g_logEnabled)
        LogCall("OS_WinActivate", "winId", winId)
    return OS_WinActivate_orig(winId)
}
; 移动或调整窗口包装，转发所有参数
OS_WinMove(params*) {
    global g_wrapperBypass
    if (g_wrapperBypass)
        return OS_WinMove_orig(params*)

    Throttle()
    if (g_logEnabled)
        LogCall("OS_WinMove", "params", StrJoin(params, ", "))
    return OS_WinMove_orig(params*)
}
; 窗口位置获取包装，保留 ByRef 输出
OS_WinGetPos(&x, &y, &w, &h, params*) {
    global g_wrapperBypass
    if (g_wrapperBypass)
        return OS_WinGetPos_orig(&x, &y, &w, &h, params*)

    Throttle()
    if (g_logEnabled)
        LogCall("OS_WinGetPos", "x", x, "y", y, "w", w, "h", h, "params", StrJoin(params, ", "))
    return OS_WinGetPos_orig(&x, &y, &w, &h, params*)
}
; 设置坐标模式包装，默认屏幕坐标
OS_CoordMode(type, mode := "Screen") {
    global g_wrapperBypass
    if (g_wrapperBypass)
        return OS_CoordMode_orig(type, mode)

    Throttle()
    if (g_logEnabled)
        LogCall("OS_CoordMode", "type", type, "mode", mode)
    return OS_CoordMode_orig(type, mode)
}
; 控件点击包装，记录参数组合
OS_ControlClick(params*) {
    global g_wrapperBypass
    if (g_wrapperBypass)
        return OS_ControlClick_orig(params*)

    Throttle()
    if (g_logEnabled)
        LogCall("OS_ControlClick", "params", StrJoin(params, ", "))
    return OS_ControlClick_orig(params*)
}
; 图像搜索包装，保留输出坐标
OS_ImageSearch(&outX, &outY, args*) {
    global g_wrapperBypass
    if (g_wrapperBypass)
        return OS_ImageSearch_orig(&outX, &outY, args*)

    Throttle()
    if (g_logEnabled)
        LogCall("OS_ImageSearch", "outX", outX, "outY", outY, "args", StrJoin(args, ", "))
    return OS_ImageSearch_orig(&outX, &outY, args*)
}
; 键盘输入包装，记录按键序列
OS_Send(keys) {
    global g_wrapperBypass
    if (g_wrapperBypass)
        return OS_Send_orig(keys)

    Throttle()
    if (g_logEnabled)
        LogCall("OS_Send", "keys", keys)
    return OS_Send_orig(keys)
}
; 等待按键包装，兼容可选参数
OS_KeyWait(key, opts := "") {
    global g_wrapperBypass
    if (g_wrapperBypass)
        return OS_KeyWait_orig(key, opts)

    Throttle()
    if (g_logEnabled)
        LogCall("OS_KeyWait", "key", key, "opts", opts)
    return OS_KeyWait_orig(key, opts)
}
;
; === End Wrappers ===
;

;=== OS ADAPTER BEGIN ===
; Centralized OS calls. Core should only call these OS_* wrappers.

; === 原始 OS_* 函数，提供系统 API 的统一入口 ===
OS_MouseMove_orig(x, y, speed) {
    MouseMove(x, y, speed)
}
; 兼容多次点击的原始实现
OS_Click_orig(btn, times) {
    Loop times {
        Click(btn)
    }
}
; 直接调用系统 PixelGetColor
OS_PixelGetColor_orig(x, y, mode) {
    return PixelGetColor(x, y, mode)
}
; Forward remaining params variadically while keeping first two ByRef
; 将 ByRef 输出直接传给 PixelSearch
OS_PixelSearch_orig(&outX, &outY, args*) {
    return PixelSearch(&outX, &outY, args*)
}
; 激活目标窗口
OS_WinActivate_orig(winId) {
    return WinActivate(winId)
}
; Forward any combination of params to WinMove
; 保持参数灵活性的 WinMove 包装
OS_WinMove_orig(params*) {
    WinMove(params*)
}
; Keep first four ByRef, forward the rest
; 输出窗口位置与尺寸
OS_WinGetPos_orig(&x, &y, &w, &h, params*) {
    WinGetPos(&x, &y, &w, &h, params*)
}
; 设置鼠标/像素等的坐标模式
OS_CoordMode_orig(type, mode) {
    CoordMode(type, mode)
}
; ControlClick 的透传包装
OS_ControlClick_orig(params*) {
    ControlClick(params*)
}
; 调用 AHK 原生图像搜索
OS_ImageSearch_orig(&outX, &outY, args*) {
    return ImageSearch(&outX, &outY, args*)
}
; 发送按键序列
OS_Send_orig(keys) {
    Send(keys)
}
; 等待指定按键释放或超时
OS_KeyWait_orig(key, opts) {
    if (opts = "")
        KeyWait(key)
    else
        KeyWait(key, opts)
}
; #endregion Module: OS Adapter
; #endregion Module: OS Adapter

#Requires AutoHotkey v2.0
#SingleInstance Force
; ===== Module: Global Config & Boot =====

; 退出快捷键
; Esc 热键：调试模式下提示后退出脚本
Esc:: {
    if (g_debugConfig["debugMode"]) {
        MsgBox("ExitApp", , "T1")
    }
    ExitApp
}

; ========================= 全局配置区域 ==========================
; 用于描述外部程序与自动化流程所需的全局对象
; 程序启动配置，Map 中键为描述，值为 [exe 路径, 参数, 标签]
global g_programConfig := Map(
    "终端程序01", ["C:\\Program Files\\WindowsApps\\Microsoft.WindowsTerminal_1.23.12811.0_x64__8wekyb3d8bbwe\\wt.exe", '-p "Windows PowerShell"' "`t" "Windows PowerShell"],
    "终端程序02", ["C:\\Program Files\\WindowsApps\\Microsoft.WindowsTerminal_1.23.12811.0_x64__8wekyb3d8bbwe\\wt.exe", '-p "命令提示符"' "`t" "命令提示符"],
    "三方截图工具", ["C:\\Program Files\\ShareX\\ShareX.exe", "" "`t" "ShareX"],
    "OCR工具", ["D:\\Umi-OCR_Paddle_v2.1.5\\Umi-OCR.exe", "" "`t" "Umi-OCR"]
)

; [全局配置] 终端程序启动映射
; 终端窗口快捷映射
global g_terminalMap := Map(
    "Windows PowerShell", g_programConfig["终端程序01"],
    "命令提示符", g_programConfig["终端程序02"]
)

; 常用外部程序的快捷变量，便于后续引用
global g_screenshotTool := g_programConfig["三方截图工具"]
global g_ocrTool := g_programConfig["OCR工具"]
global g_Terminal01 := g_terminalMap["Windows PowerShell"]
global g_Terminal02 := g_terminalMap["命令提示符"]
; [全局配置] 外部应用程序启动映射
; ======================================================================================================
; 外部程序启动列表，按照执行顺序存储 exe 和参数
global g_exeMap := [{ exe: g_Terminal01[1], param: g_Terminal01[2] }, { exe: g_screenshotTool[1], param: g_screenshotTool[2] }, { exe: g_ocrTool[1], param: g_ocrTool[2] }, { exe: g_Terminal02[1], param: g_Terminal02[2] }
]


; ========================= 窗口与操作参数 ==========================
; 窗口相关的判定与操作参数
global g_windowConfig := Map(
    "targetAppName", "中国体育彩票",
    "minWindowWidth", 5,
    "minWindowHeight", 5,
    "windowArrangementXMultiplier", 1,
    "windowArrangementYMultiplier", 0,
    "windowSizeAdjustmentX", 5,
    "windowSizeAdjustmentY", 5,
    "maxActivationAttemptsX", 5,
    "maxActivationAttemptsY", 5,
    "minAreaComparisonIndex", 5,
    "mouseLock", false,
    "mouseRandomFiveClicks", 4,
    "defaultSleepTime", 100,
    "defaultDisplayTime", 500
)

; 将常用配置缓存为局部全局变量，便于频繁使用
minWindowWidth := g_windowConfig["minWindowWidth"]
minWindowHeight := g_windowConfig["minWindowHeight"]
windowArrangementXMultiplier := g_windowConfig["windowArrangementXMultiplier"]
windowArrangementYMultiplier := g_windowConfig["windowArrangementYMultiplier"]
mouseRandomFiveClicks := g_windowConfig["mouseRandomFiveClicks"]


; ========================= 鼠标与点击参数 ==========================
; 鼠标事件相关延迟配置
global g_mouseConfig := Map(
    "clickSleepTime", 100,
    "dragSleepTime", 100,
    "wheelSleepTime", 100
)

; ========================= 调试与提示参数 ==========================
; 调试提示与声音反馈配置
global g_debugConfig := Map(
    "debugMode", false,
    "debugMsgTime", "T1",
    "debugSleepTime", 100,
    "debugSleepTimeDivisions", 10,
    "beepFrequency", 523,
    "beepDuration", 2000,
    "soundVolume", 60,
    "timeMsgBox", 3,
    "colorOffset", 16 ** 5 * 8 ; 颜色容差偏移值
)
if (g_debugConfig["debugMode"]) {
    debugSleepTimeDivisions := g_debugConfig["debugSleepTimeDivisions"]
} else {
    debugSleepTimeDivisions := 1
}


; ========================= 结果计算参数 ==========================

; 结果计算相关的限制参数
global g_resultCountConfig := Map(
    "AreaCountLimit01", 5,
    "LoopLimit01", 100,
    "ChangeInfo01", [1],
    "LoopLimit02", 2
)

; ========================= 应用与分割参数 ==========================
; 图像或区域划分相关的配置
global g_splitConfig := Map(
    "xCoarseAndFine", 1, ; 横向粗细分割比例，宽度倍数
    "yCoarseAndFine", 1, ; 纵向粗细分割比例，高度倍数
    "modMin", 8, ; 最小单元长度单位, 也是单元格间隔基准
    "xMinOffset", 15, ; 横向最小偏移
    "yMinOffset", 15, ; 纵向最小偏移
    "xDivisions", 3, ; 横向分割数量，计算得出
    "yDivisions", 20  ; 纵向分割数量，计算得出
)

; ========================= 颜色参数 ==========================
; 定义 UI 中常见颜色及容差
global g_colorConfig := Map(
    "grayBackgroundColor", ["0xF0F0F0", 0],
    "whiteBackgroundColor", ["0xFFFFFF", 0],
    "fontColor", ["0x666666", 3],
    "titleColor", ["0x000000", 0],
    "purchaseDeadlineColor", ["0x4A4A4A", 0],
    "separatorColor", ["0xC7C7C7", 3],
    "dataFrontColor01", ["0x499BF4", 3],
    "dataFrontColor02", ["0x899BF4", 3],
    "dataBackColor01", ["0xFF9100", 3],
    "dataBackColor02", ["0xFFAD00", 3],
    "dashedColor01", ["0xE4E4E4", 3],
    "dashedColor02", ["0xEBEBEB", 3],
    "dashedColor03", ["0xF4F4F4", 3],
    "dashedColor04", ["0xFBFBFB", 3],
    "betMultiplierColor", ["0xE1E1E1", 0],
    "saveButtonColor", ["0xD0021B", 0]
)

; ========================= 颜色映射 ==========================
; 将中文颜色名称映射到配置键
global g_colorMap := Map(
    "背景灰色", "grayBackgroundColor",
    "背景白色", "whiteBackgroundColor",
    "字体颜色", "fontColor",
    "标题颜色", "titleColor",
    "购买截止颜色", "purchaseDeadlineColor",
    "分隔线颜色", "separatorColor",
    "数据前景色01", "dataFrontColor01",
    "数据前景色02", "dataFrontColor02",
    "数据背景色01", "dataBackColor01",
    "数据背景色02", "dataBackColor02",
    "虚线颜色01", "dashedColor01",
    "虚线颜色02", "dashedColor02",
    "虚线颜色03", "dashedColor03",
    "虚线颜色04", "dashedColor04",
    "投注倍数颜色", "betMultiplierColor",
    "保存按钮颜色", "saveButtonColor"
)

; ========================= 颜色配置映射 ==========================
; 提供编号到颜色名称的双重映射，方便批量处理
global colorIndexMap := Map(
    "01", "背景灰色",
    "02", "背景白色",
    "03", "字体颜色",
    "04", "标题颜色",
    "05", "购买截止颜色",
    "06", "分隔线颜色",
    "07", "数据前景色01",
    "08", "数据前景色02",
    "09", "数据背景色01",
    "10", "数据背景色02",
    "11", "虚线颜色01",
    "12", "虚线颜色02",
    "13", "虚线颜色03",
    "14", "虚线颜色04",
    "15", "投注倍数颜色",
    "16", "保存按钮颜色"
)

; 颜色查找模式映射，限定搜索范围类型
global g_colorPixelSearchMap := Map(
    1, "Area",
    2, "Corner"
)


; 颜色映射测试函数
; 遍历颜色配置，生成用于测试的数组
TestColorMap() {
    colorArray := []
    for NumKey, colorValue in colorIndexMap {
        colorName := colorIndexMap[NumKey]
        colorKey := g_colorMap[colorName]
        colorData := g_colorConfig[colorKey]
        color := colorData[1]
        tolerance := colorData[2]
        colorArray.Push([NumKey, colorName, color, tolerance])
    }
    return colorArray
}

; 调试颜色映射测试
; 预计算颜色映射，供后续函数直接使用
colorArray := TestColorMap()

; ========================= 十六进制到十进制映射 ==========================
; 16 进制字符到十进制数值的查找表
global g_hexToDecimalMap := Map(
    "0", 0, "1", 1, "2", 2, "3", 3, "4", 4, "5", 5,
    "6", 6, "7", 7, "8", 8, "9", 9, "A", 10, "B", 11,
    "C", 12, "D", 13, "E", 14, "F", 15
)

; 将十进制颜色数值转换为 0xRRGGBB 格式
ConvertNumToRGB(num) {
    ; 将映射表转为数组，方便按索引取值
    g_hexToDecimalArray := []
    for key, value in g_hexToDecimalMap {
        valueInfo := [key, value]
        g_hexToDecimalArray.Push(valueInfo)
    }
    ; 初始化结果字符串
    hexList := "0x"
    loop 6 {
        if (Mod(6 - A_Index, 2) = 1) {
            ; 奇数位跳过，只处理偶数位拼接
            continue
        } else {
            Divisionpart := Floor((6 - A_Index) / 2)
        }
        ; 每两位计算一次对应的高低位字符
        devisor := 16 ** 2 ** Divisionpart
        numNew := Mod(num, devisor)
        quotient := Floor(num / devisor)
        firstNum := g_hexToDecimalArray[Floor(quotient / 16) + 1][1]
        lastNum := g_hexToDecimalArray[Mod(quotient, 16) + 1][1]
        hexList := hexList "" firstNum "" lastNum
        num := numNew
    }
    return hexList
}

; 将 0xRRGGBB 颜色转换为 [R,G,B] 数组
ConvertHexToRGB(hexColor) {
    ; 去掉前缀后按照两个字符解析 R/G/B
    hexColor := StrReplace(hexColor, "0x", "")
    red := Integer("0x" SubStr(hexColor, 1, 2))
    green := Integer("0x" SubStr(hexColor, 3, 2))
    blue := Integer("0x" SubStr(hexColor, 5, 2))
    return [red, green, blue]
}

; 判断两个颜色是否在容差范围内
IsColorWithinTolerance(color1, color2, tolerance := 10) {
    ; 获取映射表大小（16进制，值为16）
    mapCount := g_hexToDecimalMap.Count
    ; 将十六进制颜色值转换为数字（支持字符串和数字格式）
    numericColor1 := Number(color1)
    numericColor2 := Number(color2)
    ; 计算颜色差值（RGB三个分量）
    ; divisorArray中的三个除数分别用于提取R、G、B分量：16^4=65536, 16^2=256, 16^0=1
    divisorArray := [mapCount ** 4, mapCount ** 2, mapCount ** 0]  ; 对应R、G、B分量的除数
    dividend := Abs(numericColor1 - numericColor2)
    ; 记录每个颜色分量差值
    colorRGBArray := []
    quotientList := ""
    ; 提取RGB三个分量的差值
    loop divisorArray.Length {
        divisor := divisorArray[A_Index]
        quotient := Floor(dividend / divisor)
        remainder := Mod(dividend, divisor)
        dividend := remainder
        ; 保存当前分量差值，便于后续判断
        colorRGBArray.Push(quotient)
        quotientList := quotientList "" quotient "`n"
    }
    ; 检查RGB三个分量的差值是否都在容差范围内
    resultCount := 0
    loop colorRGBArray.Length {
        colorValue := colorRGBArray[A_Index]
        if (tolerance >= colorValue) {
            result := true
        } else {
            result := false
        }
        resultCount += result
    }
    ; 只有RGB三个分量都在容差内，才返回true
    result := (resultCount = colorRGBArray.Length)
    return result
}

ColorConvertNewColor(Color, colorOffset) {
    ; 校验颜色参数类型
    if (IsNumber(Color) = false) {
        MsgBox("Error: ColorConvertNewColor函数的参数Color必须是有效的十六进制数字。", , "T1")
    }
    ; 根据偏移量生成新的颜色值
    newColor := ConvertNumToRGB(Mod((Floor(Number(Color) / 16 ** 4) * 16 ** 4 + colorOffset), 16 ** 6))
    return newColor
}


; ========================= 参数导入区域 ==========================

; 参数导入
; 读取窗口、调试与结果配置中的常用字段，便于后续直接使用
targetAppName := g_windowConfig["targetAppName"]
defaultSleepTime := g_windowConfig["defaultSleepTime"]
windowSizeAdjustmentX := g_windowConfig["windowSizeAdjustmentX"]
windowSizeAdjustmentY := g_windowConfig["windowSizeAdjustmentY"]
minAreaComparisonIndex := g_windowConfig["minAreaComparisonIndex"]
maxActivationAttemptsX := g_windowConfig["maxActivationAttemptsX"]
maxActivationAttemptsY := g_windowConfig["maxActivationAttemptsY"]
defaultDisplayTime := g_windowConfig["defaultDisplayTime"]


soundVolume := g_debugConfig["soundVolume"]
beepFrequency := g_debugConfig["beepFrequency"]
beepDuration := g_debugConfig["beepDuration"]
timeMsgBox := g_debugConfig["timeMsgBox"]
colorOffset := g_debugConfig["colorOffset"]

AreaCountLimit01 := g_resultCountConfig["AreaCountLimit01"]
LoopLimit01 := g_resultCountConfig["LoopLimit01"]
ChangeInfo01 := g_resultCountConfig["ChangeInfo01"]

LoopLimit02 := g_resultCountConfig["LoopLimit02"]
xMinOffset := g_splitConfig["xMinOffset"]
yMinOffset := g_splitConfig["yMinOffset"]

; ========================= 工具函数区域 ==========================

; [工具函数] 任务栏信息获取
; ======================================================================================================
GetTaskbarInfo() {
    loop {
        ; 获取任务栏窗口列表
        windowIds := WinGetList("ahk_class Shell_TrayWnd")

        if (windowIds.Length > 0) {
            ; 成功获取任务栏窗口
            taskbarId := windowIds[1]
            WinGetClientPos(&x, &y, &width, &height, "ahk_id " . taskbarId)
            taskbarInfoArray := [taskbarId, x, y, width, height]
            return taskbarInfoArray
        } else {
            ; 任务栏不可用，尝试重启explorer
            RunWait("taskkill /f /im explorer.exe")
            Sleep(1000)
            Run("explorer.exe")
        }
    }
}

ShowDebugMessage(message, timeout := "", options := "") {
    global g_debugConfig
    ; 未开启调试模式时直接返回
    if (!g_debugConfig["debugMode"]) {
        return
    }
    ; 默认使用配置中的显示时长
    if (timeout = "") {
        timeout := g_debugConfig["debugMsgTime"]
    }
    ; 支持附加 MsgBox 选项
    if (options != "") {
        timeout .= " " options
    }
    MsgBox(message, , timeout)
}

; GenerateGridSubDevision - 将大区域均匀分割成单元格网格
; ======================================================================================================
GenerateGridSubDevision(startX, startY, horizontalDevisions, cellWidth, verticalDevisions, cellHeight) {
    areaListArray := []

    ; 外层循环：遍历每一行
    loop verticalDevisions {
        yHead := startY + (A_Index - 1) * cellHeight
        yEnd := yHead + cellHeight

        ; 内层循环：遍历每一列
        loop horizontalDevisions {
            xHead := startX + (A_Index - 1) * cellWidth
            xEnd := xHead + cellWidth
            areaInfo := [xHead, yHead, xEnd, yEnd]
            areaListArray.Push(areaInfo)
        }
    }
    return areaListArray
}

; [工具函数] 警告和提示消息
; ======================================================================================================
ShowAlertMessage(message, alertCount := 3) {
    ShowAlertMessageInner(message, alertCount)
}

; ShowAlertMessageInner - 内部报警消息处理函数
; ======================================================================================================
ShowAlertMessageInner(message := "", alertCount := 3) {
    SoundSetVolume(soundVolume)
    Loop alertCount {
        if (message = "") {
            note := "时间到此为止，消息弹窗将在" timeMsgBox "秒后自动关闭，请重新启动脚本"
            timeString := "T" timeMsgBox
            MsgBox(note, , timeString)
        } else {
            note := "未检测到" message "开启，消息弹窗将在`t" timeMsgBox "秒后自动关闭，请打开" message "并重新启动脚本"
            timeString := "T" timeMsgBox "`tYesNoCancel"
            MsgBox(note, , timeString)
        }
        SoundBeep(beepFrequency, beepDuration)
        ; 可选：最后一次循环可加特殊处理
    }
}

; AdjustWindowSizeAndPosition - 窗口大小调整和位置识别
; ======================================================================================================
AdjustWindowSizeAndPosition(windowIds, minWidth, minHeight) {
    windowClientLocationArray := []
    ; 获取屏幕工作区域尺寸（不包括任务栏）
    WinGetClientPos(&screenX, &screenY, &screenWidth, &screenHeight, "Program Manager")
    for windowId in windowIds {
        safeActivateArray := SafeActivateWindow(windowId, "Client")
        windowId := safeActivateArray[1] + 0
        x := safeActivateArray[2] + 0
        y := safeActivateArray[3] + 0
        width := safeActivateArray[4] + 0
        height := safeActivateArray[5] + 0
        areaArray := []
        ; 第一步：将窗口移动到屏幕原点，并等待窗口尺寸稳定
        loop {
            OS_WinGetPos(&screenX, &screenY, &screenWidth, &screenHeight, "Program Manager")      ; 获取屏幕尺寸
            OS_WinGetPos(&windowX, &windowY, &windowWidth, &windowHeight, "ahk_id " . windowId)                     ; 获取窗口位置和尺寸
            WinGetClientPos(&x, &y, &width, &height, "ahk_id " . windowId)                           ; 获取窗口客户区尺寸
            ; 移动窗口到屏幕原点，窗口大小设置为客户区尺寸（去除边框）
            OS_WinMove(screenX, screenY, windowWidth - (windowWidth - width), windowHeight - (windowHeight - height), "ahk_id " . windowId)
            WinGetClientPos(&x, &y, &width, &height, "ahk_id " . windowId)                            ; 再次获取客户区尺寸
            areaInfo := [windowId, x, y, width, height]                                           ; 记录窗口区域信息
            areaArray.Push(areaInfo)

            ; 获取当前迭代的窗口尺寸
            currentX := areaArray[areaArray.Length][2] + 0                                   ; 当前X坐标
            currentY := areaArray[areaArray.Length][3] + 0                                   ; 当前Y坐标
            currentWidth := areaArray[areaArray.Length][4] + 0                                   ; 当前宽度
            currentHeight := areaArray[areaArray.Length][5] + 0                                   ; 当前高度

            ; 只有迭代次数足够多时才开始比较尺寸稳定性
            if (A_Index > minAreaComparisonIndex) {
                previousX := areaArray[areaArray.Length - 1][2] + 0                           ; 上次X坐标
                previousY := areaArray[areaArray.Length - 1][3] + 0                           ; 上次Y坐标
                previousWidth := areaArray[areaArray.Length - 1][4] + 0                          ; 上次宽度
                previousHeight := areaArray[areaArray.Length - 1][5] + 0                           ; 上次高度
                result := (currentWidth = previousWidth)                                                    ; 判断宽度是否稳定（连续两次相同则稳定）
            } else {
                result := false
            }
            if (result) {
                break                                                                  ; 尺寸稳定后退出循环
            }
        }

        ; 第二步：调整窗口高度以适应任务栏
        taskbarInfoArray := GetTaskbarInfo()
        taskbarHeight := taskbarInfoArray[5] + 0
        maxHeight := screenHeight - taskbarHeight  ; 计算最大可用高度（屏幕高度减去任务栏高度）
        OS_WinMove(screenX, screenY, width, maxHeight, "ahk_id " . windowId)
        Sleep(defaultSleepTime)

        ; 第三步：逐步调整窗口尺寸直到达到最大可用高度
        safeActivateArray := SafeActivateWindow(windowId, "Client")
        windowId := safeActivateArray[1] + 0
        x := safeActivateArray[2] + 0
        y := safeActivateArray[3] + 0
        width := safeActivateArray[4] + 0
        height := safeActivateArray[5] + 0
        loop {
            ; 每次迭代增加1像素高度，直到客户区高度等于最大可用高度
            OS_WinMove(x, y, width - windowSizeAdjustmentX, maxHeight + A_Index, "ahk_id " . windowId)
            windowId := safeActivateArray[1] + 0
            x := safeActivateArray[2] + 0
            y := safeActivateArray[3] + 0
            width := safeActivateArray[4] + 0
            height := safeActivateArray[5] + 0
            WinGetClientPos(&clientX, &clientY, &clientWidth, &clientHeight, "ahk_id " . windowId)
            if (clientHeight = maxHeight) {
                break  ; 达到目标高度后退出循环
            }

            Sleep(defaultSleepTime)
        }

        ; 第四步：获取窗口的最终屏幕坐标位置信息
        safeActivateArray := SafeActivateWindow(windowId, "Screen")
        windowId := safeActivateArray[1] + 0
        x := safeActivateArray[2] + 0
        y := safeActivateArray[3] + 0
        width := safeActivateArray[4] + 0
        height := safeActivateArray[5] + 0
        areaInfo := [windowId, x, y, width, height]
        windowClientLocationArray.Push(areaInfo)
    }
    return windowClientLocationArray
}

; [类] 窗口排列管理器
; ======================================================================================================
; ===== Module: Window Arranger =====
class WindowArranger {
    __New(appName, minWidth := 5, minHeight := 5) {
        this.appName := appName
        this.minWidth := minWidth
        this.minHeight := minHeight
        this.windowIds := WinGetList(appName)
        if (this.windowIds.Length = 0) {
            ShowAlertMessage(targetAppName, 3)
            ExitApp
        }
        this.windowClientLocationArray := AdjustWindowSizeAndPosition(this.windowIds, minWidth, minHeight)
    }

    ArrangeWindows() {
        locationIndexArray := []
        loop this.windowClientLocationArray.Length {
            windowInfo := this.windowClientLocationArray[A_Index]
            windowId := windowInfo[1] + 0
            windowX := windowInfo[2] + 0
            windowY := windowInfo[3] + 0
            windowWidth := windowInfo[4] + 0
            windowHeight := windowInfo[5] + 0
            screenXStart := windowWidth * (A_Index - 1) * windowArrangementXMultiplier
            screenYStart := windowY * windowArrangementYMultiplier
            screenXEnd := screenXStart + windowWidth
            screenYEnd := screenYStart + windowHeight
            screenWidth := windowWidth
            screenHeight := windowHeight
            OS_WinMove(screenXStart, screenYStart, screenWidth, screenHeight, "ahk_id " . windowId)
            locationIndex := [windowId, screenXStart, screenYStart, screenXEnd, screenYEnd]
            locationIndexArray.Push(locationIndex)
            Sleep(defaultSleepTime)
        }
        return locationIndexArray
    }
}

; [类] 批量应用程序启动与排列器
; ======================================================================================================
class BatchAppLauncherAndArranger {
    __New(exeMap, startX := 0, startY := 0) {
        this.exeMap := exeMap       ; 应用程序配置数组
        this.startX := startX       ; 排列起始X坐标
        this.startY := startY       ; 排列起始Y坐标
        this.idArray := []         ; 窗口ID数组
    }

    ; StartAllApps - 启动所有配置的应用程序
    ; 说明：遍历exeMap配置，启动每个应用程序，识别主窗口并保存窗口ID
    ; 算法：
    ;   1. 解析每个应用的执行路径、参数和窗口标题
    ;   2. 执行启动命令并获取进程PID
    ;   3. 根据PID和窗口标题匹配找到主窗口
    ;   4. 关闭不匹配的窗口，只保留主窗口
    ;   5. 将窗口信息保存到idArray中
    StartAllApps() {
        ahkExeList := ""
        idArray := []
        for item in this.exeMap {
            ; 解析应用程序配置信息
            exePath := item.exe                    ; 可执行文件路径
            param := StrSplit(item.param, "`t")[1] ; 启动参数（制表符分隔的第一部分）
            winTitle := StrSplit(item.param, "`t")[2] ; 窗口标题关键词（制表符分隔的第二部分）

            ; 构建启动命令
            cmd := '"' exePath '"'
            if (param != "") {
                cmd .= " " param
            }

            ; 构造完成后立即启动并记录 PID
            ; 启动应用程序并获取进程ID
            Run(cmd, "", "", &pid)
            sleep(500)  ; 等待应用程序启动

            ; 根据进程ID获取该进程的所有窗口
            windowIds := WinGetList("ahk_pid " pid)
            windowId := 0 ; 初始化为0，防止未赋值报错

            ; 遍历进程的所有窗口，找到匹配标题的主窗口
            for hwnd in windowIds {
                WinGetPID(&winPid, "ahk_id " . hwnd)           ; 获取窗口所属进程PID
                windowId := WinGetID("ahk_id " . hwnd)           ; 获取窗口ID
                windowTitle := WinGetTitle("ahk_id " . hwnd)     ; 获取窗口标题
                ; 通过 PID + 标题双重校验定位主窗口
                if (winPid = pid and InStr(windowTitle, winTitle)) {
                    ; 找到匹配的窗口：PID匹配且标题包含关键词
                    MsgBox("窗口ID " hwnd " 属于进程PID " pid, , "T1")
                    break ; 找到匹配窗口后跳出循环
                } else {
                    ; 不匹配的窗口，关闭它们（可能是启动时的临时窗口）
                    WinClose("ahk_id " . hwnd)
                    windowId := 0 ; 未找到匹配窗口，ID设为0
                }
            }
            ; 记录窗口识别参数和ID到类成员变量中
            this.idArray.Push([exePath, winTitle, windowId])
            infoArray := this.idArray[this.idArray.Length]
            windowId := infoArray[infoArray.Length] + 0

            ; 如果通过PID方式未找到窗口（windowId=0），尝试使用窗口标题关键词搜索
            if (windowId = 0) {
                ; 备用方式：直接通过窗口标题关键词搜索所有匹配的窗口
                windowIds := WinGetList(winTitle)
                for hwnd in windowIds {
                    windowId := WinGetID("ahk_id " . hwnd)
                    windowTitle := WinGetTitle("ahk_id " . hwnd)
                    if (InStr(windowTitle, winTitle)) {
                        ; 找到匹配窗口，记录到临时数组中（备用处理）
                        idInfo := [hwnd, winTitle, windowTitle]
                        idArray.Push(idInfo)
                        break ; 找到后跳出循环
                    } else {
                        ; 不匹配的窗口，关闭它们
                        WinClose("ahk_id " . hwnd)
                        windowId := 0 ; 没找到则继续为0
                    }
                }
            } else {
                ; 成功通过PID方式找到窗口，显示确认消息
                MsgBox("已启动进程：" exePath "`n窗口标题包含：" winTitle "`n窗口ID：" windowId, , "T1")
            }
        }

        ; 备用方式处理：对通过标题搜索找到的窗口进行最终验证
        ; 此步骤确保idArray中的窗口ID确实存在于系统中
        newIdArray := []
        loop idArray.Length {
            idInfo := idArray[A_Index]
            windowIds := WinGetList(idInfo[2])  ; 通过标题关键词再次获取窗口列表
            for hwnd in windowIds {
                windowId := WinGetID("ahk_id " . hwnd)
                windowTitle := WinGetTitle("ahk_id " . hwnd)
                ; 验证窗口ID是否与记录的ID匹配（字符串匹配）
                if (InStr(windowId, idInfo[1])) {
                    ; 验证通过，记录到最终数组 [窗口ID, 窗口标题]
                    newIdArray.Push([idInfo[1], idInfo[3]])
                    continue ; 找到后跳出循环
                } else {
                    ; 不匹配的窗口，关闭它们
                    WinClose("ahk_id " . hwnd)
                }
            }
        }

        ; 保存并返回最终窗口ID数组
        this.newIdArray := newIdArray
        return this.newIdArray
    }

    ; ArrangeAllWindows - 排列所有已启动的应用程序窗口
    ; 说明：将已启动的所有窗口按网格方式排列到屏幕上，并最小化显示
    ; 算法：
    ;   1. 启动所有应用程序并获取窗口ID列表
    ;   2. 计算网格布局（行列数，使行列数的平方大于等于窗口数）
    ;   3. 根据屏幕尺寸和任务栏位置计算单元格大小
    ;   4. 生成网格分区区域列表
    ;   5. 将每个窗口移动到对应区域并最小化
    ; 返回：窗口ID数组
    ArrangeAllWindows() {
        startX := this.startX  ; 排列起始X坐标
        startY := this.startY  ; 排列起始Y坐标

        ; 第一步：启动所有应用程序并获取窗口ID数组
        this.newIdArray := this.StartAllApps()

        ; 获取屏幕尺寸
        OS_WinGetPos(&screenX, &screenY, &screenWidth, &screenHeight, "Program Manager")

        ; 第二步：计算网格布局的行列数（使行列数相等，且行列数的平方 >= 窗口数）
        ; 例如：9个窗口需要3×3网格，16个窗口需要4×4网格
        loop {
            numberOfHorizontalDevisions := A_Index  ; 水平方向分割数（列数）
            numberOfVerticalDevisions := A_Index    ; 垂直方向分割数（行数）
            if (this.newIdArray.Length = 0) {
                break  ; 如果没有窗口，退出循环
            }
            ; 当行列数的平方 >= 窗口数时，网格足够容纳所有窗口
            if (A_Index ** 2 >= this.newIdArray.Length) {
                break  ; 找到合适的网格大小，退出循环
            }
        }

        ; 第三步：计算单元格尺寸
        taskbarInfoArray := GetTaskbarInfo()
        taskbarHeight := taskbarInfoArray[5] + 0
        maxHeight := screenHeight - taskbarHeight  ; 最大可用高度（排除任务栏）

        ; 计算每个单元格的宽度和高度（减去10像素边距）
        cellWidth := Floor((screenWidth - startX) / numberOfHorizontalDevisions) - 10
        cellHeight := Floor((maxHeight - startY) / numberOfVerticalDevisions) - 10

        ; 生成网格分区区域列表（每个区域对应一个单元格）
        areaListArray := GenerateGridSubDevision(this.startX, this.startY, numberOfHorizontalDevisions, cellWidth, numberOfVerticalDevisions, cellHeight)

        ; 检查可用分区区域数量是否足够
        if (areaListArray.Length < this.newIdArray.Length) {
            MsgBox("Error: 可用分区区域数量不足以安置所有窗口。", , "T1")
            return
        }

        ; 第四步：将每个窗口移动到对应的网格区域并最小化
        loop this.newIdArray.Length {
            idInfo := this.newIdArray[A_Index]
            windowId := idInfo[1] + 0      ; 窗口ID
            windowTitle := idInfo[2]        ; 窗口标题

            ; 获取当前窗口对应的网格区域坐标
            appInfoOne := areaListArray[A_Index]
            x1 := appInfoOne[1] + 0  ; 区域左上角X坐标
            y1 := appInfoOne[2] + 0  ; 区域左上角Y坐标
            x2 := appInfoOne[3] + 0  ; 区域右下角X坐标
            y2 := appInfoOne[4] + 0  ; 区域右下角Y坐标

            ; 激活窗口并移动到指定区域
            OS_WinActivate("ahk_id " . windowId)
            OS_WinMove(x1, y1, x2 - x1, y2 - y1, "ahk_id " . windowId)  ; 移动到区域并调整大小
            Sleep(500)  ; 等待窗口移动完成

            ; 最小化窗口（使所有窗口以最小化状态排列）
            WinMinimize("ahk_id " . windowId)
            Sleep(defaultSleepTime)
        }

        return this.newIdArray
    }
}

; ========================= 工具函数区域 ==========================

global g_mouseLock := false     ; 鼠标锁定标志（false=允许操作，true=禁止操作）

; LockMouse - 锁定鼠标操作
LockMouse() {
    global g_mouseLock
    ; 进入锁定状态，阻止脚本发起新的鼠标操作
    g_mouseLock := true
}

; UnlockMouse - 解锁鼠标操作
UnlockMouse() {
    global g_mouseLock
    ; 恢复鼠标事件，允许后续调用执行
    g_mouseLock := false
}

; SafeMouseMove - 安全鼠标移动（仅在未锁定时执行）
SafeMouseMove(x, y) {
    global g_mouseLock
    if (!g_mouseLock) {
        ; 只在锁未激活时移动鼠标，避免与人工操作冲突
        OS_MouseMove(x, y)
    }
}

; SafeClick - 安全鼠标点击（仅在未锁定时执行）
SafeClick(opts := "") {
    global g_mouseLock
    if (!g_mouseLock) {
        ; 统一通过包装层发起点击
        OS_Click(opts)
    }
}

; SafeMouseWheel - 安全鼠标滚轮（仅在未锁定时执行）
SafeMouseWheel(direction := "Up", count := 1) {
    global g_mouseLock
    if (!g_mouseLock) {
        loop count
            if (direction = "Up")
                OS_Send("{WheelUp}")
            else if (direction = "Down")
                OS_Send("{WheelDown}")
        ; 其他方向暂未实现
    }
}

; SafeMouseDrag - 安全鼠标拖拽操作（仅在未锁定时执行）
SafeMouseDrag(x1, y1, x2, y2, speed := 10) {
    global g_mouseLock
    if (!g_mouseLock) {
        ; 起点移动后按下左键
        OS_MouseMove(x1, y1)
        MouseClick("left", , , 1, "D")
        Sleep(defaultSleepTime)
        ; 拖拽到目标坐标
        OS_MouseMove(x2, y2, speed)
        Sleep(defaultSleepTime)
        ; 松开左键完成拖拽
        MouseClick("left", , , 1, "U")
    }
}

SetAllCoordinateModesToClient(mode := "Client") {
    ; 统一设置各种操作的坐标模式
    if (A_CoordModeMouse != mode) {
        OS_CoordMode("Mouse", mode)
    }
    if (A_CoordModePixel != mode) {
        OS_CoordMode("Pixel", mode)
    }
    if (A_CoordModeToolTip != mode) {
        OS_CoordMode("ToolTip", mode)
    }
    if (A_CoordModeMenu != mode) {
        OS_CoordMode("Menu", mode)
    }
    if (A_CoordModeCaret != mode) {
        OS_CoordMode("Caret", mode)
    }
    ; 注意：重复检查Menu模式（可能是为了确保设置成功）
    if (A_CoordModeMenu != mode) {
        OS_CoordMode("Menu", mode)
    }
}

SmartSleep(milliseconds) {
    global g_debugConfig
    if (g_debugConfig["debugMode"]) {
        ; 调试模式下保持原始等待时间，方便观察
        Sleep(milliseconds)
    } else {
        ; 静默模式缩短等待，提升执行效率
        Sleep(milliseconds / g_debugConfig["debugSleepTimeDivisions"])  ; 静默模式：缩短休眠时间至1/10以提高运行速度
    }
}

; SafeActivateWindow - 安全激活窗口并获取位置和大小
; ======================================================================================================
SafeActivateWindow(windowId, coordinateMode := "Client") {
    ; 确保坐标模式设置为Client（客户端坐标）
    if (A_CoordModeMouse != "Client")
        SetAllCoordinateModesToClient()
    if (!IsNumber(windowId) or windowId <= 0) {
        MsgBox("Error: SafeActivateWindow函数的参数windowId必须是有效的窗口ID。", , "T1")
        return [windowId, 0, 0, 0, 0]
    }
    ; 第一步：验证并激活窗口
    loop {
        windowId := windowId + 0
        if (!WinExist("ahk_id " . windowId)) {
            ; 如果窗口已不存在，返回空结果
            return [windowId, 0, 0, 0, 0]
        }

        WinMoveTop("ahk_id " . windowId)
        Sleep(defaultSleepTime)

        ; 修复：直接激活目标窗口并检查是否成功
        OS_WinActivate("ahk_id " . windowId)
        Sleep(defaultSleepTime)

        if (A_Index > maxActivationAttemptsX || WinActive("ahk_id " . windowId)) {
            ; 达到最大尝试次数或激活成功即退出
            break
        }
    }

    SafeMouseMove(0, 0)                      ; 将鼠标移动到安全位置
    Sleep(defaultSleepTime)

    ; 第二步：获取窗口信息
    loop {
        try {
            WinGetClientPos(&x, &y, &width, &height, "ahk_id " . windowId)
        } catch {
            x := 0, y := 0, width := 0, height := 0
        }

        if (IsNumber(x) && IsNumber(y) && IsNumber(width) && IsNumber(height) && width > 0 && height > 0) {
            ; 再次确认激活
            OS_WinActivate("ahk_id " . windowId)
            Sleep(defaultSleepTime)

            try {
                if (coordinateMode = "Client") {
                    WinGetClientPos(&x, &y, &width, &height, "ahk_id " . windowId)
                    x := 0
                    y := 0
                } else if (coordinateMode = "Screen") {
                    OS_WinGetPos(&x, &y, &width, &height, "ahk_id " . windowId)
                    width := width + x
                    height := height + y
                } else {
                    MsgBox("Error: SafeActivateWindow函数的coordinateMode参数必须是'Client'或'Screen'。", , "T1")
                    return [windowId, 0, 0, 0, 0]
                }
            } catch {
                x := 0, y := 0, width := 0, height := 0
            }
            return [windowId, x, y, width, height]
        }

        if (A_Index > maxActivationAttemptsY) {
            ; 超过尝试次数仍失败，返回默认值
            return [windowId, 0, 0, 0, 0]
        }

        Sleep(defaultSleepTime)
    }
}

MoveAndClickLoop(xClick, yClick, NumClicks, defaultSleepTime) {
    ; 移动到目标位置后执行多次点击
    SafeMouseMove(xClick, yClick)
    Sleep(defaultSleepTime)
    loop NumClicks {
        OS_Click()
        Sleep(defaultSleepTime)
    }
}

; [工具函数] 数字管理和数组处理

IsValidNumber(value) {
    if (Type(value) != "String" && Type(value) != "Number" && Type(value) != "Float" && Type(value) != "Integer" && Type(value) != "Double" && Type(value) != "Int64") {
        MsgBox("Error: IsValidNumber函数的参数必须是字符串或数字类型。", , "T1")
        return false
    }
    ; 使用正则校验允许的数值格式（整数或小数，支持负号）
    return RegExMatch(value, "^-?\d+(\.\d+)?$")  ; 支持整数和小数
}

GetArrayMinimumValue(array) {
    if (Type(array) = "Array" && array.Length > 0) {
        minimum := ""
        loop array.Length {
            value := array[A_Index]
            if IsValidNumber(value) {
                num := Number(value)
                if (minimum = "" || num < minimum)
                    minimum := num
            }
        }

        array := ""
        return minimum
    }
    return ""
}

GetArrayMaximumValue(array) {
    if Type(array) = "Array" && array.Length > 0 {
        maximum := ""
        loop array.Length {
            value := array[A_Index]
            if IsValidNumber(value) {
                num := Number(value)
                if (maximum = "" || num > maximum)
                    maximum := num
            }
        }

        array := ""
        return maximum
    }
    return ""
}

SortArrayAscending(arr) {
    if (Type(arr) != "Array") {
        MsgBox("Error: SortArrayDescending函数的参数必须是数组类型。", , "T1")
        return []
    }

    sortedArr := []
    tempArr := arr.Clone()

    while (tempArr.Length > 0) {
        maxVal := GetArrayMinimumValue(tempArr)
        sortedArr.Push(maxVal)
        ; 从临时数组中移除最大值
        for index, value in tempArr {
            if (value = maxVal) {
                tempArr.RemoveAt(index)
                break
            }
        }
    }

    arr := ""
    tempArr := ""
    return sortedArr
}


SortArrayDescending(arr) {
    if (Type(arr) != "Array") {
        MsgBox("Error: SortArrayDescending函数的参数必须是数组类型。", , "T1")
        return []
    }

    sortedArr := []
    tempArr := arr.Clone()

    while (tempArr.Length > 0) {
        maxVal := GetArrayMaximumValue(tempArr)
        sortedArr.Push(maxVal)
        ; 从临时数组中移除最大值
        for index, value in tempArr {
            if (value = maxVal) {
                tempArr.RemoveAt(index)
                break
            }
        }
    }

    arr := ""
    tempArr := ""
    return sortedArr
}

; [工具函数] 格式转换和字符串处理

ConvertArrayToString(array, separator := "`r`n", subSeparator := "`t") {
    if (Type(array) = "Array" || Type(array) = "Object") {
        result := ""
        for index, value in array {
            if (Type(value) = "Array" || Type(value) = "Object") {
                innerResult := ""
                for innerIndex, innerValue in value {
                    ; 嵌套数组使用子分隔符拼接
                    innerResult .= innerValue . subSeparator
                }
                innerResult := TrimSubstringAll(innerResult, subSeparator)
                result .= innerResult . separator
                innerResult := ""
            } else {
                ; 非嵌套元素直接追加
                result .= value . separator
            }
        }
        result := TrimSubstringAll(result, separator)
        array := ""
        return result
    } else if (Type(array) = "String") {
        return array
    } else if (array = "") {
        return ""
    } else {
        return []
    }
}

ReplaceAllSubstrings(stringArray) {
    if (Type(stringArray) != "Array" or stringArray.Length != 3) {
        MsgBox("Error: ReplaceAllSubstrings函数需要一个包含三个元素的数组作为参数。", , "T1")
        return ""
    }

    str := stringArray[1]
    oldSubStr := stringArray[2]
    newSubStr := stringArray[3]
    if (str = "" || oldSubStr = "") {
        newStr := str
    }

    newStr := StrReplace(str, oldSubStr, newSubStr)
    while (newStr != str) {
        str := newStr
        newStr := StrReplace(str, oldSubStr, newSubStr)
    }

    if (Type(newStr) != "String") {
        MsgBox("Error: ReplaceAllSubstrings函数返回值不是字符串。", , "T1")
        return ""
    }
    return newStr
}

TrimSubstringAll(str, trimStr, mode := "both") {
    if (mode = "start" || mode = "both") {
        while (SubStr(str, 1, StrLen(trimStr)) = trimStr)
            str := SubStr(str, StrLen(trimStr) + 1, StrLen(str) - StrLen(trimStr))
    }
    if (mode = "end" || mode = "both") {
        while (SubStr(str, StrLen(str) - StrLen(trimStr) + 1, StrLen(trimStr)) = trimStr)
            str := SubStr(str, 1, StrLen(str) - StrLen(trimStr))
    }
    return str
}

; 验证数组格式是否符合要求，最高嵌套三层
VerifyArrayFormat(arr, arrNumArray) {
    if (Type(arr) != "Array" or Type(arrNumArray) != "Array") {
        ShowDebugMessage(Type(arr) "`r`n" Type(arrNumArray))
        arrResults := [arr, arrNumArray]
        return arrResults
    }
    if (arrNumArray.Length = 1) {
        ; 仅校验一层元素数量
        if (arr.Length = arrNumArray[1]) {
            return true
        } else {
            return false
        }
    }
    if (arrNumArray.Length = 2) {
        ; 校验外层长度与第一层子数组长度
        if (arr.Length = arrNumArray[1]) {
            arr1 := arr[1]
            if (arr1.Length = arrNumArray[2]) {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    if (arrNumArray.Length = 3) {
        ; 校验三层嵌套结构，确保逐层匹配
        if (arr.Length = arrNumArray[1]) {
            arr1 := arr[1]
            if (arr1.Length = arrNumArray[2]) {
                arr11 := arr1[1][1]
                if (arr11.Length = arrNumArray[3]) {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        } else {
            return false
        }
    }
}

ProcessModuloBorder(numberModArray, arrayCount := 2) {
    ; 验证输入参数格式
    if (Type(numberModArray) != "Array" or numberModArray.Length != arrayCount) {
        MsgBox("Error: ProcessModuloBorder函数需要一个包含" arrayCount "个元素的数组作为参数。", , "T1")
        return []
    }

    ; 提取总数量和模数
    totalNumber := numberModArray[1] + 0     ; 总数量（如：100）
    moduloNumber := numberModArray[2] + 0     ; 模数（如：30）

    ; 验证参数是否为有效数字
    if (!IsValidNumber(totalNumber) or !IsValidNumber(moduloNumber)) {
        MsgBox("Error: ProcessModuloBorder函数的参数必须是数字类型。", , "T1")
        return []
    }

    ; 计算商（可以完整分割的块数）和余数（毛边部分）
    moduloCount := Floor(totalNumber / moduloNumber)    ; 商：完整块数
    remainder := mod(totalNumber, moduloNumber)        ; 余数：无法整除的毛边
    processedArray := [totalNumber, moduloNumber, moduloCount, remainder]

    return processedArray
}


NormalizeRect(CoordinateInfo) {
    if (Type(CoordinateInfo) != "Array" or CoordinateInfo.Length != 4) {
        MsgBox("生成矩阵分割map结构的最外层数据结构不正确。", , "T1")
        ExitApp
    }
    loop CoordinateInfo.Length {
        if (IsNumber(CoordinateInfo[A_Index]) = false) {
            MsgBox("生成矩阵分割PointXYInfo的元素数据不全为数字。`r`n" "请检查第" A_Index "个数据", , "T1")
            ExitApp
        }
    }
    x1 := CoordinateInfo[1]
    y1 := CoordinateInfo[2]
    x2 := CoordinateInfo[3]
    y2 := CoordinateInfo[4]
    ; 将两点转换为左上/右下描述，方便统一处理
    xStart := Min(x1, x2)
    xEnd := Max(x1, x2)
    yStart := Min(y1, y2)
    yEnd := Max(y1, y2)
    CoordinateInfo := [xStart, yStart, xEnd, yEnd]
    return CoordinateInfo
}

GetFourConcerPoints(coordinateInfo) {
    coordinateInfo := NormalizeRect(coordinateInfo)
    x1 := coordinateInfo[1]
    y1 := coordinateInfo[2]
    x2 := coordinateInfo[3]
    y2 := coordinateInfo[4]
    FourConcerPoints := [[x1, y1], [x2, y1], [x1, y2], [x2, y2]]
    return FourConcerPoints
}

GetFourLineCenter(coordinateInfo) {
    coordinateInfo := NormalizeRect(coordinateInfo)
    x1 := coordinateInfo[1]
    y1 := coordinateInfo[2]
    x2 := coordinateInfo[3]
    y2 := coordinateInfo[4]
    xCenter := Floor((x1 + x2) / 2)
    yCenter := Floor((y1 + y2) / 2)
    FourLineCenter := [[xCenter, y1], [x1, yCenter], [x2, yCenter], [xCenter, y2]]
    return FourLineCenter
}


; 类定义：WindowColorRegion
; 窗口颜色区域高亮显示类
; 用于调试时高亮显示窗口内的指定颜色区域
; windowId - 目标窗口的句柄 ID
; colorCoordinatesClientInfo - 颜色区域的客户区坐标 [x1, y1, x2, y2]
; color - 高亮显示的颜色值（十六进制 RGB 格式，如 0xFF0000 表示红色）
; defaultDisplayTime - 高亮显示的默认持续时间（毫秒）
class WindowColorRegion {
    __New(windowId, colorCoordinatesClientInfo, color, defaultDisplayTime) {
        this.windowId := windowId
        this.windowInfo := SafeActivateWindow(this.windowId, "Client")
        this.colorCoordinatesClientInfo := colorCoordinatesClientInfo
        this.color := color
        this.defaultDisplayTime := defaultDisplayTime
    }

    UpdateCoordinates() {
        ; 重新激活窗口，防止坐标漂移
        SafeActivateWindow(this.windowId, "Client")
        this.x1Client := this.colorCoordinatesClientInfo[1]
        this.y1Client := this.colorCoordinatesClientInfo[2]
        this.x2Client := this.colorCoordinatesClientInfo[3]
        this.y2Client := this.colorCoordinatesClientInfo[4]
        WinGetClientPos(&winX, &winY, &winWidth, &winHeight, "ahk_id " this.windowId)
        ; 转换为屏幕坐标，方便 GUI 高亮显示
        this.x1Gui := this.x1Client + winX
        this.y1Gui := this.y1Client + winY
        this.x2Gui := this.x2Client + winX
        this.y2Gui := this.y2Client + winY
        winScreenLocationArray := [this.windowInfo, this.x1Gui, this.y1Gui, this.x2Gui, this.y2Gui]
        return winScreenLocationArray
    }

    ShowRegion() {
        this.UpdateCoordinates()
        colorFrame := Gui("+AlwaysOnTop -Caption +ToolWindow")
        colorFrame.BackColor := this.color
        ; 以无边框 GUI 矩形方式高亮目标区域
        colorFrame.Show("x" Min(this.x1Gui, this.x2Gui) " y" Min(this.y1Gui, this.y2Gui) " w" (Max(this.x1Gui, this.x2Gui) - Min(this.x1Gui, this.x2Gui)) " h" (Max(this.y1Gui, this.y2Gui) - Min(this.y1Gui, this.y2Gui)))
        Sleep(this.defaultDisplayTime)
        colorFrame.Destroy()
    }
}

; 类定义：WindowScreenshot
; 窗口截图类
; 用于对指定窗口的特定区域进行截图并保存为图像文件
; windowId - 目标窗口的句柄 ID
; screenshotCoordinatesClientInfo - 截图区域的客户区坐标 [x1, y1, x2, y2]
; savePath - 截图保存的文件路径
class WindowScreenshot {
    __New(windowId, screenshotCoordinatesClientInfo, savePath) {
        this.windowId := windowId
        this.screenshotCoordinatesClientInfo := screenshotCoordinatesClientInfo
        this.savePath := savePath
    }

    TakeScreenshot() {
        ; 激活目标窗口，确保截图时窗口在前端
        SafeActivateWindow(this.windowId, "Client")
        this.x1Client := this.screenshotCoordinatesClientInfo[1]
        this.y1Client := this.screenshotCoordinatesClientInfo[2]
        this.x2Client := this.screenshotCoordinatesClientInfo[3]
        this.y2Client := this.screenshotCoordinatesClientInfo[4]
        WinGetClientPos(&winX, &winY, &winWidth, &winHeight, "ahk_id " this.windowId)
        ; 转换为屏幕坐标，方便 GUI 高亮显示
        this.x1Gui := this.x1Client + winX
        this.y1Gui := this.y1Client + winY
        this.x2Gui := this.x2Client + winX
        this.y2Gui := this.y2Client + winY
        winScreenLocationArray := [this.windowId, this.x1Gui, this.y1Gui, this.x2Gui, this.y2Gui]
        return winScreenLocationArray
    }

    GetCurrentTime() {
        nowStr := FormatTime(A_Now, "yyyy年MM月dd日 HH时mm分ss秒")
        return nowStr
    }

    GeneratePath() {
        savePath := this.savePath
        nowStr := this.GetCurrentTime()
        filePath := savePath . "\截图_" . nowStr . ".png"
        return [savePath, filePath]
    }

    FilePathValidation() {
        filePathArray := this.GeneratePath()
        filePath := filePathArray[2]
        savePath := filePathArray[1]
        ; 确保保存目录存在
        loop {
            if (FileExist(savePath)) {
                ; 文件已存在则返回失败标记
                fileExistValid := true
            } else {
                fileExistValid := false
            }

            if (fileExistValid = true) {
                ; 文件已存在则返回失败标记
                return true
            } else {
                DirCreate(savePath)
            }
        }
    }

    ScreenLocationInfo() {
        this.TakeScreenshot()
        result := this.FilePathValidation()
        if (result = true) {
            filePath := this.GeneratePath()[2]
        } else {
            loop {
                filePath := this.GeneratePath()[2]
                if (this.FilePathValidation() = true) {
                    break
                }
            }
        }
        ; 获取自定义截屏区域坐标
        savePath := this.GeneratePath()[1]
        x := Min(this.x1Gui, this.x2Gui)
        y := Min(this.y1Gui, this.y2Gui)
        width := Max(this.x1Gui, this.x2Gui) - Min(this.x1Gui, this.x2Gui)
        height := Max(this.y1Gui, this.y2Gui) - Min(this.y1Gui, this.y2Gui)
        screenLocationArray := [x, y, width, height]
        ScreenScript := "$x = " x "`n"
        ScreenScript .= "$y = " y "`n"
        ScreenScript .= "$width = " width "`n"
        ScreenScript .= "$height = " height "`n"
        ScreenScript .= "Add-Type -AssemblyName System.Windows.Forms`n"
        ScreenScript .= "Add-Type -AssemblyName System.Drawing`n"
        ScreenScript .= "$bitmap = New-Object System.Drawing.Bitmap $width, $height`n"
        ScreenScript .= "$graphics = [System.Drawing.Graphics]::FromImage($bitmap)`n"
        ScreenScript .= "$graphics.CopyFromScreen(" x ", " y ", 0, 0, [System.Drawing.Size]::new(" width ", " height "))`n"
        ScreenScript .= "$bitmap.Save(" "`"" filePath "`"" ", [System.Drawing.Imaging.ImageFormat]::Png)`n"
        ScreenScript .= "$graphics.Dispose()`n"
        ScreenScript .= "$bitmap.Dispose()`n"
        screenInfo := [screenLocationArray, ScreenScript]
        return screenInfo
    }
}

; 类定义：GetBorderMod - 获取分割边界值
; 说明：根据输入的起始值、结束值和模数上限，计算分割边界信息
; 返回：包含分割边界信息的四维数组
; 注意：返回格式为 [[numStart, numEnd], [regionStart, regionEnd], [cellCount, cellInterval], [modStart, modEnd]]
; 分别表示总范围、有效区域范围、单元格数量与间隔、毛边起始与结束
class GetBorderMod {
    __New(numStart, numEnd, modMin) {
        ; 记录输入范围与模数上限，并预先执行合法性校验
        this.numStart := numStart
        this.numEnd := numEnd
        this.modMin := modMin
        this.resultDataValidation := this.DataValidation()
    }

    DataValidation() {
        if (!IsNumber(this.numStart) or !IsNumber(this.numEnd) or !IsNumber(this.modMin)) {
            ShowDebugMessage("矩阵分割函数部分获取分割边界值函数数据输入的数据不是数字")
            return false
        }
        ; 输入无误时返回 true 供后续流程使用
        return true
    }

    Calculate() {
        if (!this.resultDataValidation) {
            numDivisionInfo := [[0, 0], [0, 0], [0, 0], [0, 0]]
            return numDivisionInfo
        }

        modMin := this.modMin
        numStart := Round(this.numStart, 0)
        numEnd := Round(this.numEnd, 0)
        numTotal := Abs(this.numEnd - this.numStart)

        ; 第一步：将输入数字向下取整并调整为偶数（确保可以对称分割）
        regionNum := Floor(Number(numTotal)) - mod(Floor(Number(numTotal)), 2)
        modNum := Floor(Number(modMin)) - mod(Floor(Number(modMin)), 2)
        if (numTotal <= 0) {
            ShowDebugMessage("矩阵分割函数部分获取分割边界值函数输入的最大模数小于等于0")
            numDivisionInfo := [[0, 0], [0, 0], [0, 0], [0, 0]]
            return numDivisionInfo
        } else {
            ; 第二步：特殊情况1 - 尺寸在 modMin 到 2*modMin 之间（需要处理毛边）
            if ((regionNum > modNum * 1) and (regionNum <= modNum * 2)) {
                regionTotal := Round(regionNum, 0)
                cellInterval := modNum
                regionStart := Floor((regionTotal - cellInterval) / 2)
                regionEnd := regionTotal - regionStart
                cellCount := Round((regionEnd - regionStart) / cellInterval, 0)
                regionStart := regionStart + numStart
                regionEnd := regionEnd + numStart
                modStart := Round(regionStart - numStart, 0)
                modEnd := Round(numEnd - regionEnd, 0)
                numDivisionInfo := [[numStart, numEnd], [regionStart, regionEnd], [cellCount, cellInterval], [modStart, modEnd]]
                return numDivisionInfo
            }

            ; 第三步：特殊情况2 - 尺寸在 modMin / 2 到 modMin 之间（需要处理毛边）
            else if ((regionNum > Floor((modNum * 1) / 2)) and (regionNum <= Floor((modNum * 1) / 1))) {
                regionTotal := Round(regionNum, 0)
                cellInterval := Floor(modNum / 2) ; modMin减半
                regionStart := Floor((regionTotal - cellInterval) / 2)
                regionEnd := regionTotal - regionStart
                cellCount := Round((regionEnd - regionStart) / cellInterval, 0)
                regionStart := regionStart + numStart
                regionEnd := regionEnd + numStart
                modStart := Round(regionStart - numStart, 0)
                modEnd := Round(numEnd - regionEnd, 0)
                numDivisionInfo := [[numStart, numEnd], [regionStart, regionEnd], [cellCount, cellInterval], [modStart, modEnd]]
                return numDivisionInfo
            }

            ; 第四步：特殊情况3 - 尺寸在 0 到 modMin / 2 之间（不需要处理毛边）
            else if ((regionNum >= 0) and (regionNum <= Floor((modNum * 1) / 2))) {
                regionTotal := Round(regionNum, 0)
                cellInterval := 0
                regionStart := numStart
                regionEnd := numEnd
                regionStart := numStart
                regionEnd := numEnd
                modStart := Round(regionStart - numStart, 0)
                modEnd := Round(numEnd - regionEnd, 0)
                numDivisionInfo := [[numStart, numEnd], [regionStart, regionEnd], [1, Round(regionEnd - regionStart, 0)], [modStart, modEnd]]
                return numDivisionInfo
            }

            ; 第四步：通用情况 - 寻找最大的2的幂次方作为基础模数
            resultFourArray := []
            loop {
                ExponentialQuantity := A_Index
                if (Mod(regionNum, 2 ** ExponentialQuantity) < 2 ** ExponentialQuantity) {
                    numDivisionInfo := [regionNum, 2 ** ExponentialQuantity]
                    resultFourInfo := ProcessModuloBorder(numDivisionInfo, arrayCount := 2)
                    resultFourArray.Push(resultFourInfo)
                    if (resultFourInfo[1] = resultFourInfo[resultFourInfo.Length]) {
                        resultFourArray.RemoveAt(1)
                        resultFourArray.RemoveAt(resultFourArray.Length)
                        NewResultArray := resultFourArray
                        resultFourArray := []
                        break
                    }
                }
            }

            ; 第五步：从候选模数中反向查找（从大到小），找到不超过modMin的最大值
            loop NewResultArray.Length {
                IndexInfo := NewResultArray.Length - A_Index + 1
                NewresultInfo := NewResultArray[IndexInfo]
                modOne := NewresultInfo[NewresultInfo.Length]
                if (ModOne <= modMin) {
                    modNum := modOne
                    modOne := ""
                    break
                }
            }

            ; 第六步：计算最终的分割参数
            regionTotal := Round(regionNum, 0)
            cellInterval := Round(Max(modNum, modMin), 0)
            regionStart := Mod(regionTotal, cellInterval) / 2 + Floor(cellInterval / 2)
            regionEnd := regionTotal - regionStart
            cellCount := Round((regionEnd - regionStart) / cellInterval, 0)
            regionStart := Round(regionStart + numStart, 0)
            regionEnd := Round(regionEnd + numStart, 0)
            modStart := Round(regionStart - numStart, 0)
            modEnd := Round(numEnd - regionEnd, 0)
            numDivisionInfo := [[numStart, numEnd], [regionStart, regionEnd], [cellCount, cellInterval], [modStart, modEnd]]
            return numDivisionInfo
        }
    }
}

; 类定义： PointInfo - 一维点分割信息类
; 说明：根据输入的起始和结束数字，以及分割模数，生成对应的分割信息
; 参数说明：
; numStart - 起始数字
; numEnd - 结束数字
; modMin - 分割模数
; 返回：分割信息数组
class PointInfo {
    __New(numStart, numEnd, modMin) {
        ; 初始化区间、模数并缓存计算结果
        this.numStart := numStart
        this.numEnd := numEnd
        this.modMin := modMin
        this.numDivisionInfo := this.Calculate()
        this.basicInfo := this.Basic()
    }

    Calculate() {
        ; 基于 GetBorderMod 生成分割信息
        borderModInstance := GetBorderMod(this.numStart, this.numEnd, this.modMin)
        numDivisionInfo := borderModInstance.Calculate()
        return numDivisionInfo
    }

    Basic() {
        ; 拆解分割结果，整理出常用信息集合
        numDivisionInfo := this.numDivisionInfo
        totalStartEnd := numDivisionInfo[1]
        centerStartEnd := numDivisionInfo[2]
        modStartEnd := numDivisionInfo[4]
        cellDivisionInfo := numDivisionInfo[3]
        basicInfo := [totalStartEnd, centerStartEnd, cellDivisionInfo, modStartEnd]
        this.basicInfo := basicInfo
        return this.basicInfo
    }

    Start() {
        ; 返回整体区间起点到中心区间起点
        numStart := this.basicInfo[1][1]
        numEnd := this.basicInfo[2][1]
        startInfo := [numStart, numEnd]
        this.startInfo := startInfo
        return this.startInfo
    }

    End() {
        ; 返回整体区间终点到中心区间终点
        numEnd := this.basicInfo[1][2]
        numStart := this.basicInfo[2][2]
        endInfo := [numStart, numEnd]
        this.endInfo := endInfo
        return this.endInfo
    }

    Center() {
        ; 返回中心区间的起止坐标
        centerStart := this.basicInfo[2][1]
        centerEnd := this.basicInfo[2][2]
        centerInfo := [centerStart, centerEnd]
        this.centerInfo := centerInfo
        return this.centerInfo
    }

    cellDivision() {
        ; 返回单元格数量与间距
        cellCount := this.basicInfo[3][1]
        cellInterval := this.basicInfo[3][2]
        cellDivisionInfo := [cellCount, cellInterval]
        this.cellDivisionInfo := cellDivisionInfo
        return this.cellDivisionInfo
    }

    generateCellArray() {
        cellDivisionInfo := this.cellDivision()
        cellCount := cellDivisionInfo[1]
        cellInterval := cellDivisionInfo[2]
        centerInfo := this.Center()
        centerStart := centerInfo[1]
        cellArray := []
        loop cellCount {
            ; 以中心区间起点为基准依次生成单元格
            cellHead := centerStart + (A_Index - 1) * cellInterval
            cellEnd := cellHead + cellInterval
            cellInfo := [cellHead, cellEnd]
            cellArray.Push(cellInfo)
        }
        this.cellArray := cellArray
        return this.cellArray
    }
}

; 类定义： RectangleInfo - 矩形区域分割信息类
; 说明：根据输入的矩形坐标和X/Y方向的分割模数，生成对应的分割区域信息
; 参数说明：
; coordinateInfo - 矩形区域坐标数组 [x1, y1, x2, y2]
; xModNum - X方向分割模数
; yModNum - Y方向分割模数
class RectangleInfo {
    __New(coordinateInfo, xModNum, yModNum) {
        x1 := coordinateInfo[1]
        y1 := coordinateInfo[2]
        x2 := coordinateInfo[3]
        y2 := coordinateInfo[4]
        this.x1 := x1
        this.y1 := y1
        this.x2 := x2
        this.y2 := y2
        ; 归一化坐标后保存分割模数
        this.coordinateInfo := NormalizeRect([x1, y1, x2, y2])
        this.xModNum := xModNum
        this.yModNum := yModNum
    }

    OutsideBorder() {
        coordinateInfo := this.coordinateInfo
        xStart := coordinateInfo[1]
        yStart := coordinateInfo[2]
        xEnd := coordinateInfo[3]
        yEnd := coordinateInfo[4]
        outsideBorderInfo := [xStart, yStart, xEnd, yEnd]

        xPointInstance := PointInfo(xStart, xEnd, this.xModNum)
        yPointInstance := PointInfo(yStart, yEnd, this.yModNum)

        xStartInfo := xPointInstance.Start()
        yStartInfo := yPointInstance.Start()
        xEndInfo := xPointInstance.End()
        yEndInfo := yPointInstance.End()

        outsideBorderInfo := [xStartInfo, yStartInfo, xEndInfo, yEndInfo]
        this.outsideBorderInfo := outsideBorderInfo
        return this.outsideBorderInfo
    }

    TopRegion() {
        coordinateInfo := this.coordinateInfo
        Region := this.OutsideBorder()
        yUpperInfo := Region[2]
        xStart := coordinateInfo[1]
        yStart := yUpperInfo[1]
        xEnd := coordinateInfo[3]
        yEnd := yUpperInfo[2]
        TopRegionInfo := [xStart, yStart, xEnd, yEnd]
        this.TopRegionInfo := TopRegionInfo
        return this.TopRegionInfo
    }

    BottomRegion() {
        coordinateInfo := this.coordinateInfo
        Region := this.OutsideBorder()
        yBottomInfo := Region[4]
        xStart := coordinateInfo[1]
        yStart := yBottomInfo[1]
        xEnd := coordinateInfo[3]
        yEnd := yBottomInfo[2]
        BottomRegionInfo := [xStart, yStart, xEnd, yEnd]
        this.BottomRegionInfo := BottomRegionInfo
        return this.BottomRegionInfo
    }

    LeftRegion() {
        coordinateInfo := this.coordinateInfo
        Region := this.OutsideBorder()
        xLeftInfo := Region[1]
        xStart := xLeftInfo[1]
        yStart := coordinateInfo[2]
        xEnd := xLeftInfo[2]
        yEnd := coordinateInfo[4]
        leftRegionInfo := [xStart, yStart, xEnd, yEnd]
        this.leftRegionInfo := leftRegionInfo
        return this.leftRegionInfo
    }

    RightRegion() {
        coordinateInfo := this.coordinateInfo
        Region := this.OutsideBorder()
        xRightInfo := Region[3]
        xStart := xRightInfo[1]
        yStart := coordinateInfo[2]
        xEnd := xRightInfo[2]
        yEnd := coordinateInfo[4]
        rightRegionInfo := [xStart, yStart, xEnd, yEnd]
        this.rightRegionInfo := rightRegionInfo
        return this.rightRegionInfo
    }

    CenterRegion() {
        TopRegionInfo := this.TopRegion()
        BottomRegionInfo := this.BottomRegion()
        leftRegionInfo := this.LeftRegion()
        rightRegionInfo := this.RightRegion()
        xStart := leftRegionInfo[3]
        yStart := TopRegionInfo[4]
        xEnd := rightRegionInfo[1]
        yEnd := BottomRegionInfo[2]
        centerRegionInfo := [xStart, yStart, xEnd, yEnd]
        this.centerRegionInfo := centerRegionInfo
        return this.centerRegionInfo
    }


    XcellArray() {
        coordinateInfo := this.coordinateInfo
        xStart := coordinateInfo[1]
        xEnd := coordinateInfo[3]

        xPointInstance := PointInfo(xStart, xEnd, this.xModNum)
        xCellInfo := xPointInstance.generateCellArray()
        this.xCellInfo := xCellInfo
        return this.xCellInfo
    }

    YcellArray() {
        coordinateInfo := this.coordinateInfo
        yStart := coordinateInfo[2]
        yEnd := coordinateInfo[4]

        yPointInstance := PointInfo(yStart, yEnd, this.yModNum)
        yCellInfo := yPointInstance.generateCellArray()
        this.yCellInfo := yCellInfo
        return this.yCellInfo
    }
}

; 类定义：BaseRegionMap
; 通用类
; 用于生成基础区域映射
; 输入参数：
; windowId：窗口句柄
; coordinateInfo：窗口坐标信息 [x1, y1, x2, y2]
; xMinBorderInterval：X轴最小边界间隔
; yMinBorderInterval：Y轴最小边界间隔
; 输出结果：
; RegionMap：基础区域映射
; BorderRegionMap：边界区域映射
; 使用方法：
; regionMapScheme := BaseRegionMap(windowId, coordinateInfo, xMinBorderInterval, yMinBorderInterval)
; regionMap := regionMapScheme.GetRegionMap()
; borderRegionMap := regionMapScheme.GetBorderRegionMap()
; regionMap.Count为5，包含 LeftRegion、RightRegion、TopRegion、BottomRegion、CenterRegion 五个区域坐标
; borderRegionMap.Count为19，包含各边界及组合区域坐标。具体键名如下：
; "LeftRegion"：左边界区域
; "RightRegion"：右边界区域
; "TopRegion"：上边界区域
; "BottomRegion"：下边界区域
; "LeftTopCorner"：左上角区域
; "RightTopCorner"：右上角区域
; "LeftBottomCorner"：左下角区域
; "RightBottomCorner"：右下角区域
; "LeftCenter"：左侧中间区域
; "RightCenter"：右侧中间区域
; "TopCenter"：上方中间区域
; "BottomCenter"：下方中间区域
; "LeftCenterAndCenter"：左侧中间及中心区域
; "RightCenterAndCenter"：右侧中间及中心区域
; "TopCenterAndCenter"：上方中间及中心区域
; "BottomCenterAndCenter"：下方中间及中心区域
; "TopCenterAndCenterAndBottomCenter"：上方中间、中心及下方中间区域
; "LeftCenterAndCenterAndRightCenter"：左侧中间、中心及右侧中间区域
; "RegionCenter"：中心区域
class BaseRegionMap {
    __New(windowId, coordinateInfo, xMinBorderInterval, yMinBorderInterval) {
        this.windowId := windowId
        this.coordinateInfo := coordinateInfo
        this.xMinBorderInterval := xMinBorderInterval
        this.yMinBorderInterval := yMinBorderInterval
    }

    ActiveWindow() {
        SafeActivateWindow(this.windowId, "Client")
    }

    __BaseBorderMap() {
        windowId := this.windowId
        coordinateInfo := this.coordinateInfo
        xModNum := this.xMinBorderInterval
        yModNum := this.yMinBorderInterval
        rectangle := RectangleInfo(coordinateInfo, xModNum, yModNum)
        LeftRegion := rectangle.LeftRegion()
        RightRegion := rectangle.RightRegion()
        TopRegion := rectangle.TopRegion()
        BottomRegion := rectangle.BottomRegion()
        CenterRegion := rectangle.CenterRegion()
        RegionMap := Map()
        RegionMap["LeftRegion"] := LeftRegion
        RegionMap["RightRegion"] := RightRegion
        RegionMap["TopRegion"] := TopRegion
        RegionMap["BottomRegion"] := BottomRegion
        RegionMap["CenterRegion"] := CenterRegion
        BorderRegionMap := Map()
        x1Left := LeftRegion[1]
        y1Left := LeftRegion[2]
        x2Left := LeftRegion[3]
        y2Left := LeftRegion[4]
        x1Right := RightRegion[1]
        y1Right := RightRegion[2]
        x2Right := RightRegion[3]
        y2Right := RightRegion[4]
        x1Top := TopRegion[1]
        y1Top := TopRegion[2]
        x2Top := TopRegion[3]
        y2Top := TopRegion[4]
        x1Bottom := BottomRegion[1]
        y1Bottom := BottomRegion[2]
        x2Bottom := BottomRegion[3]
        y2Bottom := BottomRegion[4]
        BorderRegionMap["LeftRegion"] := [x1Left, y1Left, x2Left, y2Left]
        BorderRegionMap["RightRegion"] := [x1Right, y1Right, x2Right, y2Right]
        BorderRegionMap["TopRegion"] := [x1Top, y1Top, x2Top, y2Top]
        BorderRegionMap["BottomRegion"] := [x1Bottom, y1Bottom, x2Bottom, y2Bottom]
        BorderRegionMap["LeftTopCorner"] := [x1Left, y1Top, x2Left, y2Top]
        BorderRegionMap["RightTopCorner"] := [x1Right, y1Top, x2Right, y2Top]
        BorderRegionMap["LeftBottomCorner"] := [x1Left, y1Bottom, x2Left, y2Bottom]
        BorderRegionMap["RightBottomCorner"] := [x1Right, y1Bottom, x2Right, y2Bottom]
        BorderRegionMap["LeftCenter"] := [x1Left, y2Top, x2Left, y1Bottom]
        BorderRegionMap["RightCenter"] := [x1Right, y2Top, x2Right, y1Bottom]
        BorderRegionMap["TopCenter"] := [x2Left, y1Top, x1Right, y2Top]
        BorderRegionMap["BottomCenter"] := [x2Left, y1Bottom, x1Right, y2Bottom]
        BorderRegionMap["LeftCenterAndCenter"] := [x1Left, y2Top, x1Right, y1Bottom]
        BorderRegionMap["RightCenterAndCenter"] := [x2Left, y2Top, x2Right, y1Bottom]
        BorderRegionMap["TopCenterAndCenter"] := [x2Left, y1Top, x1Right, y1Bottom]
        BorderRegionMap["BottomCenterAndCenter"] := [x2Left, y2Top, x1Right, y2Bottom]
        BorderRegionMap["TopCenterAndCenterAndBottomCenter"] := [x2Left, y1Top, x1Right, y2Bottom]
        BorderRegionMap["LeftCenterAndCenterAndRightCenter"] := [x1Left, y2Top, x2Right, y1Bottom]
        BorderRegionMap["RegionCenter"] := CenterRegion
        return [RegionMap, BorderRegionMap]
    }

    GetRegionMap() {
        baseMap := this.__BaseBorderMap()
        RegionMap := baseMap[1]
        return RegionMap
    }

    GetBorderRegionMap() {
        baseMap := this.__BaseBorderMap()
        BorderRegionMap := baseMap[2]
        return BorderRegionMap
    }
}

; 类定义： CoordinateMapping - 矩形坐标分割映射类
; 说明：根据输入的点坐标和矩形区域，结合X/Y方向的分割模数，生成对应的分割映射结构
; 参数说明：
; PointXYInfo - 点坐标信息数组 [xPoint, yPoint]
; coordinateInfo - 矩形区域坐标数组 [x1, y1, x2, y2]
; xModNum - X方向分割模数
; yModNum - Y方向分割模数
; 返回值：
; Cell() - 矩形分割映射对象，键为"XIndex，YIndex"，值为对应的矩形坐标数组 [x1, y1, x2, y2]
; xMap() - X方向分割映射对象，键为XIndex，值为对应的X坐标数组 [x1, x2]
; yMap() - Y方向分割映射对象，键为YIndex，值为对应的Y坐标数组 [y1, y2]
; xyMap() - 点坐标所在的分割单元矩形坐标数组 [x1, y1, x2, y2]
; xStart() - X方向起始坐标
; xEnd() - X方向结束坐标
; yStart() - Y方向起始坐标
; yEnd() - Y方向结束坐标
; 注意事项：
; 1. 点坐标必须在矩形区域内，否则xyMap()返回[-1, -1]表示无效
; 2. 矩形区域坐标会被归一化为左上角和右下角表示
; 3. 分割模数必须为正整数
; 4. 返回的映射对象均为AutoHotkey Map类型，方便按键访问
; 嵌套类：
; PointInfo - 用于生成单方向分割信息，支持起止坐标和模数输入。
class CoordinateMapping {
    __New(PointXYInfo, coordinateInfo, xModNum, yModNum) {
        this.PointXYInfo := PointXYInfo
        this.coordinateInfo := coordinateInfo
        this.xModNum := xModNum
        this.yModNum := yModNum
        x1 := this.coordinateInfo[1]
        y1 := this.coordinateInfo[2]
        x2 := this.coordinateInfo[3]
        y2 := this.coordinateInfo[4]
        this.x1 := x1
        this.y1 := y1
        this.x2 := x2
        this.y2 := y2
        ; 归一化坐标后保存分割模数
        this.coordinateInfo := NormalizeRect([this.x1, this.y1, this.x2, this.y2])
        this.PointXYInfoActual := this.DataValidation()
        this.rectangleMap := this.Cell()
        this.xMap := this.xArray()
        this.yMap := this.yArray()
        this.xyArray := this.xyMap()
    }

    DataValidation() {
        PointXYInfo := this.PointXYInfo
        xPoint := PointXYInfo[1]
        yPoint := PointXYInfo[2]
        coordinateInfo := this.coordinateInfo
        coordinateInfo := NormalizeRect(coordinateInfo)
        x1 := coordinateInfo[1]
        y1 := coordinateInfo[2]
        x2 := coordinateInfo[3]
        y2 := coordinateInfo[4]
        if (xPoint < x1 or xPoint > x2 or yPoint < y1 or yPoint > y2) {
            ; 点坐标超出矩形范围，返回失败标记
            return [-1, -1]
        } else {
            return [xPoint, yPoint]
        }
    }

    Cell() {
        coordinateInfo := this.coordinateInfo
        xStart := coordinateInfo[1]
        yStart := coordinateInfo[2]
        xEnd := coordinateInfo[3]
        yEnd := coordinateInfo[4]

        xPointInstance := PointInfo(xStart, xEnd, this.xModNum)
        yPointInstance := PointInfo(yStart, yEnd, this.yModNum)

        xCellArray := xPointInstance.generateCellArray()
        yCellArray := yPointInstance.generateCellArray()

        rectangleArray := []
        rectangleMap := Map()

        for xIndex, xValue in xCellArray {
            for yIndex, yValue in yCellArray {
                rectangle := [xValue[1], yValue[1], xValue[2], yValue[2]]
                rectangleArray.Push(rectangle)

                ; 使用坐标对象作为键
                xykey := xIndex "，" yIndex
                rectangleMap[xykey] := rectangle
            }
        }

        this.rectangleArray := rectangleArray
        this.rectangleMap := rectangleMap
        return this.rectangleMap
    }

    xArray() {
        coordinateInfo := this.coordinateInfo
        xStart := coordinateInfo[1]
        xEnd := coordinateInfo[3]
        xPointInstance := PointInfo(xStart, xEnd, this.xModNum)
        xCellArray := xPointInstance.generateCellArray()
        xArray := []
        xMap := Map()
        for xIndex, xValue in xCellArray {
            xkey := xIndex
            xInfo := [xValue[1], xValue[2]]
            xMap[xkey] := xInfo ; <--- 修正：使用方括号赋值
            xArray.Push(xInfo)

        }
        this.xMap := xMap
        return this.xMap
    }

    yArray() {
        coordinateInfo := this.coordinateInfo
        yStart := coordinateInfo[2]
        yEnd := coordinateInfo[4]
        yPointInstance := PointInfo(yStart, yEnd, this.yModNum)
        yCellArray := yPointInstance.generateCellArray()
        yArray := []
        yMap := Map()
        for yIndex, yValue in yCellArray {
            ykey := yIndex
            yInfo := [yValue[1], yValue[2]]
            yMap[ykey] := yInfo ; <--- 修正：使用方括号赋值
            yArray.Push(yInfo)
        }
        this.yMap := yMap
        return this.yMap
    }

    xyMap() {
        rectangleMap := this.rectangleMap
        xMap := this.xMap
        yMap := this.yMap
        PointXYInfoActual := this.PointXYInfoActual
        xPoint := PointXYInfoActual[1]
        yPoint := PointXYInfoActual[2]
        if (xPoint = -1 and yPoint = -1) {
            ; 点坐标无效，返回失败标记
            return this.coordinateInfo
        } else {
            xIndex := -1 ; 初始化以防找不到
            yIndex := -1 ; 初始化以防找不到
            xIndexArray := []
            for xKey, xValue in xMap {
                xStart := xValue[1]
                xEnd := xValue[2]
                if (xPoint >= xStart and xPoint <= xEnd) {
                    xIndex := xKey
                    xIndexArray.Push(xKey)
                }
            }
            yIndexArray := []
            for yKey, yValue in yMap {
                yStart := yValue[1]
                yEnd := yValue[2]
                if (yPoint >= yStart and yPoint <= yEnd) {
                    yIndex := yKey
                    yIndexArray.Push(yKey)
                }
            }

            if (xIndex = -1 or yIndex = -1) {
                return [-1, -1, -1, -1] ; 如果未找到索引，返回错误标记
            } else {
                xIndexMin := GetArrayMinimumValue(xIndexArray)
                yIndexMin := GetArrayMinimumValue(yIndexArray)
                xIndexMax := GetArrayMaximumValue(xIndexArray)
                yIndexMax := GetArrayMaximumValue(yIndexArray)
                x1Min := xMap[xIndexMin][1]
                y1Min := yMap[yIndexMin][1]
                x2Max := xMap[xIndexMax][2]
                y2Max := yMap[yIndexMax][2]
                x1Middle := xPoint - Floor(Abs(x1Min - xPoint) / 2)
                y1Middle := yPoint - Floor(Abs(y1Min - yPoint) / 2)
                x2Middle := xPoint + Floor(Abs(x2Max - xPoint) / 2)
                y2Middle := yPoint + Floor(Abs(y2Max - yPoint) / 2)
                if (xIndexArray.Length > 1 and yIndexArray.Length > 1) {
                    rectangleInfo := [x1Middle, y1Middle, x2Middle, y2Middle]
                } else if (xIndexArray.Length > 1 and yIndexArray.Length = 1) {
                    rectangleInfo := [x1Middle, y1Min, x2Middle, y2Max]
                } else if (xIndexArray.Length = 1 and yIndexArray.Length > 1) {
                    rectangleInfo := [x1Min, y1Middle, x2Max, y2Middle]
                } else {
                    rectangleInfo := rectangleMap[xIndex "，" yIndex]
                }
                rectangleInfo := NormalizeRect(rectangleInfo)
                return rectangleInfo
            }
        }
    }

    xStart() {
        xyArray := this.xyArray
        this.x1 := xyArray[1]
        return this.x1
    }
    yStart() {
        xyArray := this.xyArray
        this.y1 := xyArray[2]
        return this.y1
    }
    xEnd() {
        xyArray := this.xyArray
        this.x2 := xyArray[3]
        return this.x2
    }
    yEnd() {
        xyArray := this.xyArray
        this.y2 := xyArray[4]
        return this.y2
    }
}

; 类定义：EdgeDetectionColor
; 通用工具类，嵌套类，用于边缘检测和颜色验证。
; 边缘检测类定义
; ColorValid 参数用于指定是否启用边缘颜色有效性检查，[Color, Tolerance] 格式的数组
; 例如：ColorValid := [[0xFF0000, 10], [0x00FF00, 10], [0x0000FF, 10], [0xFFFF00, 10]]
; ValidTrue 参数用于指定边缘颜色有效性检查的正确结果，可以是布尔值或数组字符串，每一个字符串的内容均为0，1，拼接而成
; 例如：ValidTrue := "1111" 表示四个边缘颜色均需通过验证，具体含义如下：
; 第1位：TopEdgeCenter 边缘颜色验证结果，1表示通过，0表示未过，组合如果是0101，则表示ColorValid的颜色有四种。
; 在该边缘位置上，只有第2和第4种颜色通过验证，其他第1种和第3种颜色未通过验证，注意验证标准是基于Tolerance容差值范围内的颜色匹配。0，1只是一种标记方式。
; ValidTrue的字符串元素位数必须与ColorValid数组的长度一致。
; 但是验证是否为正确验证需要和ValidTrue进行对比。如果ValidTrue的TopEdgeCenter所在位的通过验证的内容参考存在0000，这就代表只有该点的颜色均不在容差范围内，才算通过验证。
; 所以ValidTrue的每一位内容是和ColorValid数组的每一项内容进行对比的，1表示该颜色需要在容差范围内匹配成功，0表示该颜色需要在容差范围外匹配成功。
; 目前可以确定地是ValidTrue的字符串内容只能是0和1的组合，外层嵌套分为9个部分，分别对应9个边缘位置的颜色验证。
; 每个部分内容也可以设置多个匹配通过验证的颜色字符串0，1组合。只要有一个组合内容满足验证条件即可通过该边缘位置的颜色验证。
; 如果ColorValid数组为空，或者ValidTrue未设置，则表示不启用边缘颜色有效性检查，直接返回通过验证。
; ColorValid 和 ValidTrue 均为可选参数，如果不需要边缘颜色有效性检查，可以将其设置为空或省略。
; 标准格式示例：
; ColorValid := [[0xFF0000, 10], [0x00FF00, 10], [0x0000FF, 10], [0xFFFF00, 10]]
; ValidTrueMap := Map(
; "TopLeftCorner", ["1110", "1101", "1011", "0111"],
; "TopEdgeCenter", ["1110", "1101", "1011", "0111", "0000"],
; "TopRightCorner", [1100],
; "LeftEdgeCenter", [1001, 01101, 1010, 0101],
; "RegionCenter", ["1001", "0110", "0011", "1100"],
; "RightEdgeCenter", ["1001", "0110", "0011", "1100"],
; "BottomLeftCorner", ["1110", "1101", "1011", "0111"],
; "BottomEdgeCenter", ["1110", "1101", "1011", "0111", "0000"]
; "BottomRightCorner", ["1100"]
; )
; 注意：ColorValid 和 ValidTrueMap 的设置必须匹配，否则会导致验证失败。ValidTrueMap.Count 必须等于 9（对应 9 个边缘位置），
; 并且每个 ValidTrueMap 的值数组中的字符串长度必须等于 ColorValid 的长度。
; coordinateInfo 格式：[x1, y1, x2, y2], 实例化只一次，然后通过 __DetectEdges 方法多次调用进行边缘检测。
; PointXYInfo 格式：[x, y]，表示当前需要检测的点坐标。数组格式。内容为鼠标当前位置坐标。多次调用时传入不同的坐标点。
; xModNum 和 yModNum 用于坐标映射的精度控制。一般设置为边缘检测时的最小移动步长。数字格式。一般不小于5。也不会特别大。数值视具体情况而定。一般以coordinateInfo区域大小为参考。
; colorArray 为全局颜色数组变量，用于获取颜色和容差值。
class EdgeDetectionColor {
    __New(windowId, coordinateInfo, PointXYInfo, xModNum, yModNum, ColorValidArray, ValidTrueMap, colorArray) {
        this.windowId := windowId
        this.coordinateInfo := coordinateInfo
        this.PointXYInfo := PointXYInfo
        this.xModNum := xModNum
        this.yModNum := yModNum
        this.ColorValidArray := ColorValidArray
        this.ValidTrueMap := ValidTrueMap
        this.colorArray := colorArray
        this.loopNum := 0
        this.PointXYHistory := []
        this.CurrentXYHistory := []
        this.paramResult := this.__parameterReconfig()
        this.detectionResultMap := Map()
        ; 手动调用一次检测，避免空 Map
        this.__DetectEdgesLoop := 0
        this.GetPointResultsLoop := 0
        this.LoopBreakLoop := 0
        this.LoopBreak := false
        this.CellCornerAndCenterArray := []
    }

    DataValidation() {
        ; 检查 ColorValidArray
        if (Type(this.ColorValidArray) != "Array" or this.ColorValidArray.Length = 0) {
            Msgbox("边缘颜色有效性检查未启用 (ColorValidArray 为空或无效)，跳过验证。", , "T1")
            return true ; 根据注释，未设置时应视为通过
        }

        loop this.ColorValidArray.Length {
            EdgeColorInfo := this.ColorValidArray[A_Index]
            if (Type(EdgeColorInfo) != "Array" or EdgeColorInfo.Length != 2) {
                Msgbox("错误：ColorValidArray 的元素格式不正确，应为 [Color, Tolerance] 数组。位置：" . A_Index, , "T1")
                return false
            }
            EdgeColor := EdgeColorInfo[1]
            EdgeTolerance := EdgeColorInfo[2]
            if (!IsNumber(EdgeColor) or !IsNumber(EdgeTolerance)) {
                Msgbox("错误：ColorValidArray 的元素 [Color, Tolerance] 必须是数字。位置：" . A_Index, , "T1")
                return false
            }
        }

        ; 检查 ValidTrueMap
        if (Type(this.ValidTrueMap) != "Map" or this.ValidTrueMap.Count = 0) {
            Msgbox("边缘颜色有效性检查未启用 (ValidTrueMap 为空或无效)，跳过验证。", , "T1")
            return true ; 根据注释，未设置时应视为通过
        }

        expectedLength := this.ColorValidArray.Length
        for edgeName, validStringsArray in this.ValidTrueMap {
            if (Type(validStringsArray) != "Array") {
                Msgbox("错误：ValidTrueMap 中 '" . edgeName . "' 的值不是一个数组。", , "T1")
                return false
            }
            for i, strPattern in validStringsArray {
                if (Type(strPattern) != "String") {
                    Msgbox("错误：ValidTrueMap 中 '" . edgeName . "' 的数组包含非字符串元素。位置：" . i, , "T1")
                    return false
                }
                if (StrLen(strPattern) != expectedLength) {
                    Msgbox("错误：ValidTrueMap 中 '" . edgeName . "' 的验证字符串 '" . strPattern . "' 长度 (" . StrLen(strPattern) . ") 与 ColorValidArray 的长度 (" . expectedLength . ") 不匹配。", , "T1")
                    return false
                }
            }
        }

        ShowDebugMessage("边缘颜色有效性检查数据类型验证通过。", , "T1")
        return true
    }

    __parameterReconfig() {
        ; 获取坐标区域
        x1 := this.coordinateInfo[1]
        y1 := this.coordinateInfo[2]
        x2 := this.coordinateInfo[3]
        y2 := this.coordinateInfo[4]
        xOffset := x2 - x1 > 0 ? 1 : -1
        yOffset := y2 - y1 > 0 ? 1 : -1
        xStart := this.PointXYInfo[1]
        yStart := this.PointXYInfo[2]
        this.PointXYInfo := [xStart, yStart] ; 更新起始点坐标
        ; 数据验证
        if (this.DataValidation() = false) {
            Msgbox("错误：边缘颜色有效性检查数据验证未通过，无法继续检测。", , "T1")
            this.paramResult := [this.PointXYHistory, [0, 0]]
        }

        ; 初始化历史点
        this.PointXYHistory.Push(this.PointXYInfo)
        this.PointXYHistory := this.PointXYHistory
        ShowDebugMessage("初始化历史点完成，共记录 " . this.PointXYHistory.Length . " 个点。", , "T1")
        this.paramResult := [this.PointXYHistory, [this.xModNum, this.yModNum]]
        return this.paramResult
    }

    __DetectEdges() {
        this.__DetectEdgesLoop := this.__DetectEdgesLoop + 1
        ShowDebugMessage("开始第 " . this.__DetectEdgesLoop . " 次边缘检测。", , "T1")
        paramResult := this.paramResult
        CurrentXYHistory := paramResult[1]
        currentPointXY := CurrentXYHistory[CurrentXYHistory.Length]
        this.xModNum := paramResult[2][1]
        this.yModNum := paramResult[2][2]
        this.currentPointXY := this.PointXYHistory[this.PointXYHistory.Length]
        ; 坐标映射
        this.CurrentXYHistory.Push(this.currentPointXY)
        if (this.CurrentXYHistory.Length > 2 and
            this.CurrentXYHistory[this.CurrentXYHistory.Length][1] = this.CurrentXYHistory[this.CurrentXYHistory.Length - 1][1] and
            this.CurrentXYHistory[this.CurrentXYHistory.Length][2] = this.CurrentXYHistory[this.CurrentXYHistory.Length - 1][2]) {
            this.loopbreak := true
        }
        ShowDebugMessage("当前检测点坐标：(" . this.currentPointXY[1] . ", " . this.currentPointXY[2] . ")", , "T1")
        CellInfo := CoordinateMapping(this.currentPointXY, this.coordinateInfo, this.xModNum, this.yModNum).xyMap()
        CellX1Y1 := [CellInfo[1], CellInfo[2]]
        CellX2Y2 := [CellInfo[3], CellInfo[4]]
        CellX1Y2 := [CellInfo[1], CellInfo[4]]
        CellX2Y1 := [CellInfo[3], CellInfo[2]]

        ; 计算中心点
        LeftCenterXY := [CellX1Y1[1], Round((CellX1Y1[2] + CellX1Y2[2]) / 2, 0)]
        RightCenterXY := [CellX2Y1[1], Round((CellX2Y1[2] + CellX2Y2[2]) / 2, 0)]
        TopCenterXY := [Round((CellX1Y1[1] + CellX2Y1[1]) / 2, 0), CellX1Y1[2]]
        BottomCenterXY := [Round((CellX1Y2[1] + CellX2Y2[1]) / 2, 0), CellX1Y2[2]]
        CenterXY := [Round((CellX1Y1[1] + CellX2Y2[1]) / 2, 0), Round((CellX1Y1[2] + CellX2Y2[2]) / 2, 0)]

        ; 构建 Map
        CellCornerAndCenterMap := Map(
            "TopLeftCorner", CellX1Y1,
            "TopEdgeCenter", TopCenterXY,
            "TopRightCorner", CellX2Y1,
            "LeftEdgeCenter", LeftCenterXY,
            "RegionCenter", CenterXY,
            "RightEdgeCenter", RightCenterXY,
            "BottomLeftCorner", CellX1Y2,
            "BottomEdgeCenter", BottomCenterXY,
            "BottomRightCorner", CellX2Y2
        )

        keyArray := [
            "TopLeftCorner",
            "TopEdgeCenter",
            "TopRightCorner",
            "LeftEdgeCenter",
            "RegionCenter",
            "RightEdgeCenter",
            "BottomLeftCorner",
            "BottomEdgeCenter",
            "BottomRightCorner"
        ]
        ColorCornerAndCenterMap := Map()

        loop keyArray.Length {
            key := keyArray[A_Index]
            PointInfoXY := CellCornerAndCenterMap[key]
            ColorCornerAndCenterMap[key] := PixelGetColor(PointInfoXY[1], PointInfoXY[2])
        }

        this.detectionResultMap := Map(
            "keyArray", keyArray,
            "CellMap", CellCornerAndCenterMap,
            "ColorMap", ColorCornerAndCenterMap
        )
        return this.detectionResultMap
    }

    GetPointResults() {
        this.GetPointResultsLoop := this.GetPointResultsLoop + 1
        if (!this.detectionResultMap) {
            MsgBox("没有可用的检测结果", , "T1")
            this.loopbreak := true
            return this.PointXYInfo
        }
        keyArray := this.detectionResultMap["keyArray"]
        ColorMap := this.detectionResultMap["ColorMap"]
        CellMap := this.detectionResultMap["CellMap"]
        ColorValidArray := this.ColorValidArray
        ValidTrueMap := this.ValidTrueMap

        EdgeValidationResults := Map()

        loop keyArray.Length {
            edgeName := keyArray[A_Index]
            edgeColor := ColorMap[edgeName]

            ; 构建当前边缘颜色的验证结果字符串
            currentValidationString := ""
            loop ColorValidArray.Length {
                validColorInfo := ColorValidArray[A_Index]
                validColor := validColorInfo[1]
                tolerance := validColorInfo[2]

                colorMatch := IsColorWithinTolerance(edgeColor, validColor, tolerance) ? "1" : "0"
                currentValidationString .= colorMatch
            }

            ; 检查当前边缘的验证结果是否符合 ValidTrueMap 中的任一模式
            isValid := false
            if (ValidTrueMap.Has(edgeName)) {
                validPatterns := ValidTrueMap[edgeName]
                for i, pattern in validPatterns {
                    if (currentValidationString = pattern) {
                        isValid := true
                        break
                    }
                }
            } else {
                Msgbox("警告：ValidTrueMap 中未找到边缘 '" . edgeName . "' 的验证模式，默认视为不通过。", , "T1")
            }

            EdgeValidationResults[edgeName] := isValid
        }

        CellValidationResultsArray := []
        loop keyArray.Length {
            edgeName := keyArray[A_Index]
            edgeColorValid := EdgeValidationResults[edgeName]
            CellValidationResultsArray.Push([edgeName, edgeColorValid])
        }
        this.EdgeValidationResults := EdgeValidationResults
        return this.EdgeValidationResults
    }

    LoopBreakResult() {
        loop {
            this.LoopBreakLoop := this.LoopBreakLoop + 1
            this.detectionResultMap := this.__DetectEdges()
            keyArray := this.detectionResultMap["keyArray"]
            CellCornerAndCenterMap := this.detectionResultMap["CellMap"]
            this.EdgeValidationResults := this.GetPointResults()
            ; 检查所有边缘验证结果
            this.CellCornerAndCenterArray := []
            keyFalseArray := []
            keyTrueArray := []
            loop keyArray.Length {
                edgeName := keyArray[A_Index]
                if (this.EdgeValidationResults[edgeName] = false) {
                    keyFalseArray.Push(edgeName)
                } else {
                    keyTrueArray.Push(edgeName)
                }
            }
            LoopArray := [this.__DetectEdgesLoop, this.GetPointResultsLoop, this.LoopBreakLoop]

            xArray := []
            yArray := []
            loop keyTrueArray.Length {
                edgeName := keyTrueArray[A_Index]
                pointXY := CellCornerAndCenterMap[edgeName]
                xArray.Push(pointXY[1])
                yArray.Push(pointXY[2])
                this.CellCornerAndCenterArray.Push([edgeName, pointXY])
            }

            xMax := GetArrayMaximumValue(xArray)
            yMax := GetArrayMaximumValue(yArray)
            xMin := GetArrayMinimumValue(xArray)
            yMin := GetArrayMinimumValue(yArray)
            x1 := this.coordinateInfo[1]
            y1 := this.coordinateInfo[2]
            x2 := this.coordinateInfo[3]
            y2 := this.coordinateInfo[4]
            xOffset := x2 - x1 > 0 ? 1 : -1
            yOffset := y2 - y1 > 0 ? 1 : -1
            xStart := xOffset = 1 ? xMax : xMin
            yStart := yOffset = 1 ? yMax : yMin
            ; 更新坐标点
            this.PointXYInfo := [xStart, yStart]
            this.__parameterReconfig()

            MouseMove(xStart, yStart)
            Sleep(defaultSleepTime)
            this.currentPointXY := this.PointXYHistory[this.PointXYHistory.Length]
            CellInfo := CoordinateMapping(this.currentPointXY, this.coordinateInfo, this.xModNum, this.yModNum).xyMap()
            CellX1Y1 := [CellInfo[1], CellInfo[2]]
            CellX2Y2 := [CellInfo[3], CellInfo[4]]
            CellX1Y2 := [CellInfo[1], CellInfo[4]]
            CellX2Y1 := [CellInfo[3], CellInfo[2]]
            CellCornerArray := [CellX1Y1, CellX2Y1, CellX1Y2, CellX2Y2]
            this.CurrentXYInfo := this.PointXYHistory[this.PointXYHistory.Length]
            ; 检查是否达到停止条件
            if (this.LoopBreak = true) {
                ShowDebugMessage("边缘检测循环结束，返回最终坐标点。", , "T1")
                return this.PointXYInfo
            }
        }
    }
}

; 类定义：SingleDirectionBorderOffset
; 通用工具类
; 用于单方向边缘偏移计算
; 参数说明：
; windowId: 窗口ID
; coordinateInfo: 坐标信息 [x1, y1, x2, y2]
; directionModeNumArray: 方向模式编号数组 [[TopMode], [BottomMode], [LeftMode], [RightMode]]
; offsetValueArray: 偏移值数组 [[TopOffset], [BottomOffset], [LeftOffset], [RightOffset]]
; 返回值：
; 各边缘偏移坐标信息 Map("Top", [directionModeNum, offsetValue], "Bottom", [...], "Left", [...], "Right", [...])
; 示例用法：
; singleDirectionBorderOffset := SingleDirectionBorderOffset(windowId, coordinateInfo, directionModeNumArray, offsetValueArray)
; offsetCoordinates := singleDirectionBorderOffset.__parameterReconfig()
; GetTopOffsetCoordinate := singleDirectionBorderOffset.GetTopOffsetCoordinate()
; 嵌套类调用：
; 显示调试信息：
; ShowDebugMessage: 用于显示调试信息
; 默认显示时间：
; defaultDisplayTime: 预定义的默认显示时间变量
; 注意事项：
; 确保传入的参数格式正确，特别是方向模式编号数组和偏移值数组
; directionModeNumArray := [[1], [1], [1], [1]]
; offsetValueArray := [[10], [10], [10], [10]]
class SingleDirectionBorderOffset {
    __New(windowId, coordinateInfo, directionModeNumArray, offsetValueArray) {
        this.windowId := windowId
        this.coordinateInfo := coordinateInfo
        this.directionModeNumArray := directionModeNumArray
        this.offsetValueArray := offsetValueArray
    }

    DateValidation() {
        ; 这里可以添加参数验证逻辑
        if (Type(this.directionModeNumArray) != "Array" or Type(this.offsetValueArray) != "Array") {
            Msgbox("错误：方向模式数组和偏移值数组必须为数组类型。", , "T1")
            return false
        }
        if (this.directionModeNumArray.Length != this.offsetValueArray.Length or this.directionModeNumArray.Length != 4 or this.offsetValueArray.Length != 4) {
            Msgbox("错误：方向模式数组和偏移值数组长度不匹配。", , "T1")
            return false
        }
        ShowDebugMessage("单方向边缘偏移参数验证通过。", , "T1")
        DateValidationArray := []
        loop this.directionModeNumArray.Length {
            directionModeNumInfo := this.directionModeNumArray[A_Index]
            offsetValueInfo := this.offsetValueArray[A_Index]
            if (Type(directionModeNumInfo) != "Array" or Type(offsetValueInfo) != "Array") {
                Msgbox("错误：方向模式数组和偏移值数组的元素必须为数组类型。位置：" . A_Index, , "T1")
                DataArrayTypeValidation := false
            } else {
                DataArrayTypeValidation := true
            }
            if (directionModeNumInfo.Length != 1 or offsetValueInfo.Length != 1) {
                Msgbox("错误：方向模式数组和偏移值数组的元素长度必须为1。位置：" . A_Index, , "T1")
                DataArrayLengthValidation := false
            } else {
                DataArrayLengthValidation := true
            }
            DataElementTypeValidationArray := []
            loop directionModeNumInfo.Length {
                directionModeNum := directionModeNumInfo[A_Index]
                offsetValue := offsetValueInfo[A_Index]
                if (Type(directionModeNum) != "Integer" or Type(offsetValue) != "Integer") {
                    Msgbox("错误：方向模式编号和偏移值必须为数字类型。位置：" . A_Index . "，元素位置：" . A_Index, , "T1")
                    DataElementTypeValidation := false
                } else {
                    DataElementTypeValidation := true
                }
                DataElementTypeValidationArray.Push(DataElementTypeValidation)
            }
            if (DataElementTypeValidationArray.Length != 1 or DataElementTypeValidationArray[1] = false) {
                DataArrayElementTypeValidation := false
            } else {
                DataArrayElementTypeValidation := true
            }
            DateValidation := [DataArrayTypeValidation, DataArrayLengthValidation, DataArrayElementTypeValidation]
            DateValidationArray.Push(DateValidation)
        }


        ; 返回验证结果
        loop DateValidationArray.Length {
            validationResult := DateValidationArray[A_Index]
            loop validationResult.Length {
                validationResultItem := validationResult[A_Index]
                if (validationResultItem = false) {
                    return false
                }
            }
        }
        return true
    }

    __parameterReconfig() {
        if (this.DateValidation() = false) {
            Msgbox("错误：单方向边缘偏移参数验证未通过，无法继续计算。", , "T1")
            return Map(
                "Top", [0, 0],
                "Bottom", [0, 0],
                "Left", [0, 0],
                "Right", [0, 0]
            )
        } else {
            DateValidationArraydirectionModeoffsetValueMap := Map()
            loop this.directionModeNumArray.Length {
                directionModeNumInfo := this.directionModeNumArray[A_Index]
                offsetValueInfo := this.offsetValueArray[A_Index]
                directionModeNum := directionModeNumInfo[1]
                offsetValue := offsetValueInfo[1]
                if (A_Index = 1) {
                    edgeName := "Top"
                } else if (A_Index = 2) {
                    edgeName := "Bottom"
                } else if (A_Index = 3) {
                    edgeName := "Left"
                } else if (A_Index = 4) {
                    edgeName := "Right"
                }
                DateValidationArraydirectionModeoffsetValueMap[edgeName] := [directionModeNum, offsetValue]
            }
        }
        return DateValidationArraydirectionModeoffsetValueMap
    }

    GetTopOffsetCoordinate() {
        DateValidationArraydirectionModeoffsetValueMap := this.__parameterReconfig()
        windowId := this.windowId
        coordinateInfo := this.coordinateInfo
        Info := DateValidationArraydirectionModeoffsetValueMap["Top"]
        directionModeNum := Info[1]
        offsetValue := Info[2]
        x1 := coordinateInfo[1]
        y1 := coordinateInfo[2]
        x2 := coordinateInfo[3]
        if (directionModeNum > 0) {
            directionModeNum := 1
        } else if (directionModeNum < 0) {
            directionModeNum := -1
        } else {
            directionModeNum := 0
        }

        offsetValue := Abs(offsetValue)
        y := y1 + directionModeNum * offsetValue
        coordinateInfoTopLine := [x1, y1, x2, y]
        coordinateInfoTopLine := NormalizeRect(coordinateInfoTopLine)
        return coordinateInfoTopLine
    }

    GetBottomOffsetCoordinate() {
        DateValidationArraydirectionModeoffsetValueMap := this.__parameterReconfig()
        windowId := this.windowId
        coordinateInfo := this.coordinateInfo
        Info := DateValidationArraydirectionModeoffsetValueMap["Bottom"]
        directionModeNum := Info[1]
        offsetValue := Info[2]
        x1 := coordinateInfo[1]
        y2 := coordinateInfo[4]
        x2 := coordinateInfo[3]
        if (directionModeNum > 0) {
            directionModeNum := 1
        } else if (directionModeNum < 0) {
            directionModeNum := -1
        } else {
            directionModeNum := 0
        }

        offsetValue := Abs(offsetValue)
        y := y2 + directionModeNum * offsetValue
        coordinateInfoBottomLine := [x1, y, x2, y2]
        coordinateInfoBottomLine := NormalizeRect(coordinateInfoBottomLine)
        return coordinateInfoBottomLine
    }

    GetLeftOffsetCoordinate() {
        DateValidationArraydirectionModeoffsetValueMap := this.__parameterReconfig()
        windowId := this.windowId
        coordinateInfo := this.coordinateInfo
        Info := DateValidationArraydirectionModeoffsetValueMap["Left"]
        directionModeNum := Info[1]
        offsetValue := Info[2]
        y1 := coordinateInfo[2]
        x1 := coordinateInfo[1]
        y2 := coordinateInfo[4]
        if (directionModeNum > 0) {
            directionModeNum := 1
        } else if (directionModeNum < 0) {
            directionModeNum := -1
        } else {
            directionModeNum := 0
        }

        offsetValue := Abs(offsetValue)
        x := x1 + directionModeNum * offsetValue
        coordinateInfoLeftLine := [x1, y1, x, y2]
        coordinateInfoLeftLine := NormalizeRect(coordinateInfoLeftLine)
        return coordinateInfoLeftLine
    }

    GetRightOffsetCoordinate() {
        DateValidationArraydirectionModeoffsetValueMap := this.__parameterReconfig()
        windowId := this.windowId
        coordinateInfo := this.coordinateInfo
        Info := DateValidationArraydirectionModeoffsetValueMap["Right"]
        directionModeNum := Info[1]
        offsetValue := Info[2]
        y1 := coordinateInfo[2]
        x2 := coordinateInfo[3]
        y2 := coordinateInfo[4]
        if (directionModeNum > 0) {
            directionModeNum := 1
        } else if (directionModeNum < 0) {
            directionModeNum := -1
        } else {
            directionModeNum := 0
        }

        offsetValue := Abs(offsetValue)
        x := x2 + directionModeNum * offsetValue
        coordinateInfoRightLine := [x, y1, x2, y2]
        coordinateInfoRightLine := NormalizeRect(coordinateInfoRightLine)
        return coordinateInfoRightLine
    }

    GetLineOffsetMap() {
        coordinateInfoTopLine := this.GetTopOffsetCoordinate()
        coordinateInfoBottomLine := this.GetBottomOffsetCoordinate()
        coordinateInfoLeftLine := this.GetLeftOffsetCoordinate()
        coordinateInfoRightLine := this.GetRightOffsetCoordinate()
        LineOffsetMap := Map(
            "Top", coordinateInfoTopLine,
            "Bottom", coordinateInfoBottomLine,
            "Left", coordinateInfoLeftLine,
            "Right", coordinateInfoRightLine
        )
        return LineOffsetMap
    }
}

; 类定义：ColorCoordinateAreaSummary
; 颜色坐标区域汇总类
; 用于计算多个颜色区域矩形的最大外框和最小内框
; rects - 矩形列表，每个矩形为 [x1, y1, x2, y2]
; MaxArea() - 获取能包住所有矩形的最大外框
; MinArea(includeTouch) - 获取所有矩形共同重叠的最小内框。可能返回 [-1,-1,-1,-1] 表示无交集
; includeTouch - 是否将边界贴合视为有交集，默认为 true
; 示例用法：
; rects := [[10,10,50,50], [30,30,70,70], [60,60,90,90]]
; summary := ColorCoordinateAreaSummary(rects)
; maxArea := summary.MaxArea() ; 返回 [10,10,90,90]
; minArea := summary.MinArea() ; 返回 [60,60,50,50]（无交集时返回 [-1,-1,-1,-1]）
class ColorCoordinateAreaSummary {
    __New(rects := [], SummaryMode := "Default") {
        this.SummaryMode := SummaryMode
        this.SetRects(rects)
    }

    ; 一次性设置矩形列表
    SetRects(rects) {
        this.Rects := []
        for rect in rects {
            normalizedRect := this._normalize(rect)
            if (normalizedRect) { ; 如果 _normalize 返回 false，则不添加
                this.Rects.Push(normalizedRect)
            }
        }
        this._recompute()
        return this
    }

    ; 获取能包住所有矩形的最大外框 (并集外接矩形)
    MaxArea() {
        return [this.union_x1, this.union_y1, this.union_x2, this.union_y2]
    }

    ; 获取所有矩形共同重叠的最小内框 (交集矩形)
    ; includeTouch = true：边界刚好贴住也算有交集
    MinArea(includeTouch := true) {
        r := [this.intersect_x1, this.intersect_y1, this.intersect_x2, this.intersect_y2]
        if (!includeTouch) {
            if (r[1] >= r[3] || r[2] >= r[4])
                return [-1, -1, -1, -1]
        } else {
            if (r[1] > r[3] || r[2] > r[4])
                return [-1, -1, -1, -1]
        }
        return r
    }

    ; ===== 内部实现（你基本不用管）=====

    _recompute() {
        arr := this.Rects
        if (arr.Length = 0) {
            ; 空集合时初始化为 0
            this.union_x1 := this.union_y1 := this.union_x2 := this.union_y2 := 0
            this.intersect_x1 := this.intersect_y1 := this.intersect_x2 := this.intersect_y2 := 0
            return
        }

        r := arr[1]
        this.union_x1 := this.intersect_x1 := r[1]
        this.union_y1 := this.intersect_y1 := r[2]
        this.union_x2 := this.intersect_x2 := r[3]
        this.union_y2 := this.intersect_y2 := r[4]

        Loop (arr.Length - 1) {
            this._updateWith(arr[A_Index + 1])
        }
    }

    _updateWith(rect) {
        x1 := rect[1], y1 := rect[2], x2 := rect[3], y2 := rect[4]

        ; 并集：所有矩形一起能包住的外框
        this.union_x1 := Min(this.union_x1, x1)
        this.union_y1 := Min(this.union_y1, y1)
        this.union_x2 := Max(this.union_x2, x2)
        this.union_y2 := Max(this.union_y2, y2)

        ; 交集：所有矩形共同重叠的内框
        this.intersect_x1 := Max(this.intersect_x1, x1)
        this.intersect_y1 := Max(this.intersect_y1, y1)
        this.intersect_x2 := Min(this.intersect_x2, x2)
        this.intersect_y2 := Min(this.intersect_y2, y2)
    }

    ; 标准化：保证 [x1,y1,x2,y2] 且 x1<=x2, y1<=y2
    _normalize(rect) {
        SummaryMode := this.SummaryMode
        if (Type(SummaryMode) = "Array") {
            SummaryMode := ConvertArrayToString(SummaryMode)
        }

        if (!(rect is Array) || rect.Length < 4)
            throw Error("rect 必须是 [x1,y1,x2,y2] 的数组")

        x1 := rect[1], y1 := rect[2], x2 := rect[3], y2 := rect[4]
        nx1 := Min(x1, x2), ny1 := Min(y1, y2), nx2 := Max(x1, x2), ny2 := Max(y1, y2)

        ; 模式处理：类型转换
        if (InStr(SummaryMode, "integer") > 0) {
            nx1 := Floor(nx1), ny1 := Floor(ny1), nx2 := Floor(nx2), ny2 := Floor(ny2)
        } else if (InStr(SummaryMode, "float") > 0) {
            nx1 := Float(nx1), ny1 := Float(ny1), nx2 := Float(nx2), ny2 := Float(ny2)
        }

        ; 模式处理：有效性检查
        if (InStr(SummaryMode, "exclusive") > 0) {
            if (nx1 >= nx2)
                throw Error("rect 的 x1 必须小于 x2 (exclusive mode)")
            if (ny1 >= ny2)
                throw Error("rect 的 y1 必须小于 y2 (exclusive mode)")
        }

        if (InStr(SummaryMode, "Correct") > 0) {
            ; Correct 模式下，坐标必须非负
            if (nx1 < 0 or ny1 < 0 or nx2 < 0 or ny2 < 0) {
                if (InStr(SummaryMode, "Correct-Silent") > 0) {
                    return false
                }
                throw Error("rect 的坐标值必须非负 (Correct mode)")
            }
        }

        return [nx1, ny1, nx2, ny2]
    }
}

; 类定义：LoopBreakException
; 循环中断异常类
; 用于在循环过程中检测坐标序列的稳定性，并根据设定的条件决定是否中断循环
; CoordinateArray - 坐标数组，格式为 [[x1, y1, x2, y2], ...]
; ChangeInfo - 变化信息，格式为 [描述, 阈值]
; CountLimit - 计数限制，用于判断稳定性
; loopLimit - 循环上限，超过该值触发异常报警
; resultSummary - 结果汇总，用于记录稳定性检测结果
; AreaCountLimit01 - 稳定性检测的区域计数限制
; AreaBreak() - 计算坐标序列的稳定性
; MessageExplanation() - 输出调试说明，便于观察循环退出原因
; 示例用法：
; loopBreakInstance := LoopBreakException(CoordinateArray, ChangeInfo, CountLimit, loopLimit, resultSummary)
; stabilityResult := loopBreakInstance.AreaBreak()
; messageResult := loopBreakInstance.MessageExplanation()
class LoopBreakException {
    __New(CoordinateArray, ChangeInfo, CountLimit, loopLimit, resultSummary) {
        this.CoordinateArray := CoordinateArray
        ; 构造时立即计算当前坐标序列的稳定性
        this.resultInfo := this.AreaBreak()
        this.CountLimit := CountLimit
        this.loopLimit := loopLimit
        this.ChangeInfo := ChangeInfo
        this.resultSummary := resultSummary
    }

    AreaBreak() {
        CoordinateArray := this.CoordinateArray
        if (CoordinateArray.Length > 100) {
            ; 超过保护上限直接判失败
            return [false, CoordinateArray.Length, resultSummary]
        } else {
            if (CoordinateArray.Length <= AreaCountLimit01) {
                return [true, CoordinateArray.Length, 0]
            } else {
                loopCount := AreaCountLimit01
                resultSummary := 0 ; ← 修复点：初始化变量
                loop loopCount {
                    IndexOne := CoordinateArray.Length - loopCount + A_Index - 1
                    IndexTwo := CoordinateArray.Length - loopCount + A_Index
                    CoordinateArrayOne := CoordinateArray[IndexOne]
                    CoordinateArrayTwo := CoordinateArray[IndexTwo]
                    y1Diff := Abs(CoordinateArrayOne[2] - CoordinateArrayTwo[2])
                    y2Diff := Abs(CoordinateArrayOne[4] - CoordinateArrayTwo[4])
                    resultYDiff := Max(y1Diff, y2Diff)
                    if (resultYDiff <= 1) {
                        ; 差值在阈值内认为稳定
                        resultSummary += 1
                    } else {
                        resultSummary += 0
                    }
                }
                if (resultSummary = AreaCountLimit01) {
                    return [false, CoordinateArray.Length, resultSummary]
                } else {
                    resultSummary := 0
                    return [true, CoordinateArray.Length, resultSummary]
                }
            }
        }
    }

    MessageExplanation() {
        resultInfo := this.resultInfo
        CountLimit := this.CountLimit
        loopLimit := this.loopLimit
        ChangeInfo := this.ChangeInfo
        ; 输出调试说明，便于观察循环退出原因
        ShowDebugMessage("调试信息：坐标数组长度为" resultInfo[2] "，最近" resultInfo[3] "个坐标的Y轴变化量均小于等于" ChangeInfo[1] "。", , "T2")
        try {
            if (resultInfo[1] = false) {
                if (resultInfo[2] >= loopLimit) {
                    ; 达到循环上限，触发异常报警
                    ShowDebugMessage("Error: 坐标数组长度超过" loopLimit "，可能存在异常情况，请检查。", , "T1")
                    return "loopbreak"
                } else {
                    ; 正常稳定后中断
                    ShowDebugMessage("提示: 坐标数组长度为" resultInfo[2] "，且最近" CountLimit "个坐标的Y轴变化量均小于等于" ChangeInfo[1] "，已停止继续处理。", , "T1")
                    return "normalbreak"
                }
            }
        } catch {
            ShowDebugMessage("无异常，循环继续。", , "T1")
            return "continue"
        }
    }
}

; 类定义：CoordinateAreaCornerInfo
; 说明：用于在指定窗口和区域内搜索特定颜色，并根据不同模式返回颜色所在的坐标信息
; windowId - 目标窗口的句柄或ID
; colorCoordinateInfo - 颜色搜索区域的坐标信息，格式为 [x1, y1, x2, y2]
; Color - 需要搜索的颜色值，通常为十六进制格式（如 0xFF0000 表示红色）
; Tolerance - 颜色容差值，允许的颜色偏差范围
; ModeNum - 颜色搜索模式编号，决定返回的坐标信息类型
;    ModeNum = 1: 返回颜色所在区域的上下边界坐标（X轴不变，Y轴更新）
;    ModeNum = 2: 返回颜色所在区域的四个角的极值坐标
;    ModeNum != 1 and ModeNum != 2: 返回原始搜索区域坐标
class CoordinateAreaCornerInfo {
    __New(windowId, colorCoordinateInfo, Color, Tolerance, ModeNum) {
        this.windowId := windowId
        this.colorCoordinateInfo := colorCoordinateInfo
        this.Color := Color
        this.Tolerance := Tolerance
        this.Mode := g_colorPixelSearchMap[ModeNum]
        ; 构造阶段即依次完成基础信息与定位流程
        this.BasicTotalInfo := this.BasicInfo()
        this.coordinateInfo := this.Coordinate()
        this.colorExistInfo := this.ColorExist()
        this.colorCoordinateNewInfo := this.ColorValidation()
    }

    BasicInfo() {
        windowId := this.windowId
        colorCoordinateInfo := this.colorCoordinateInfo
        Color := this.Color
        Tolerance := this.Tolerance

        colorCoordinateInfo := NormalizeRect(colorCoordinateInfo)
        x1 := colorCoordinateInfo[1]
        y1 := colorCoordinateInfo[2]
        x2 := colorCoordinateInfo[3]
        y2 := colorCoordinateInfo[4]
        xStart := x1
        yStart := y1
        xEnd := x2
        yEnd := y2
        ; 计算颜色搜索区域的像素宽、像素高以及总像素数
        totalPixelsWidth := Abs(xEnd - xStart) + 1
        totalPixelsHeight := Abs(yEnd - yStart) + 1
        totalPixelsArea := (xEnd - xStart + 1) * (yEnd - yStart + 1)
        BasicTotalInfo := [windowId, Color, Tolerance, xStart, yStart, xEnd, yEnd, totalPixelsWidth, totalPixelsHeight, totalPixelsArea]
        this.BasicTotalInfo := BasicTotalInfo
        return this.BasicTotalInfo
    }

    Coordinate() {
        BasicTotalInfo := this.BasicTotalInfo
        Mode := this.Mode
        windowId := BasicTotalInfo[1]
        Color := BasicTotalInfo[2]
        Tolerance := BasicTotalInfo[3]
        xStart := BasicTotalInfo[4]
        yStart := BasicTotalInfo[5]
        xEnd := BasicTotalInfo[6]
        yEnd := BasicTotalInfo[7]
        totalPixelsWidth := BasicTotalInfo[8]
        totalPixelsHeight := BasicTotalInfo[9]
        totalPixelsArea := BasicTotalInfo[10]
        result1 := OS_PixelSearch(&foundX1, &foundY1, xStart, yStart, xEnd, yEnd, Color, Tolerance)
        result2 := OS_PixelSearch(&foundX2, &foundY2, xEnd, yEnd, xStart, yStart, Color, Tolerance)
        if (result1 = false or result2 = false) {
            ; 任一方向未找到颜色则返回失败标记
            coordinateInfo := [-1, -1, -1, -1]
        } else {
            if (Mode = "Area") { ; 仅更新 Y 轴范围，X 轴保持不变，ModeNum = 1
                coordinateInfo := [xStart, foundY1, xEnd, foundY2]
            } else if (Mode = "Corner") { ; 寻找四个角的极值坐标，ModeNum = 2
                coordinateInfo := [foundX1, foundY1, foundX2, foundY2]
            } else { ; 保持原始区域不变，ModeNum != 1 and ModeNum != 2
                coordinateInfo := [xStart, yStart, xEnd, yEnd]
            }
            coordinateInfo := NormalizeRect(coordinateInfo)
        }
        return coordinateInfo
    }

    ColorExist() {
        coordinateInfo := this.Coordinate()
        if (coordinateInfo[1] = -1 and coordinateInfo[2] = -1 and coordinateInfo[3] = -1 and coordinateInfo[4] = -1) {
            ; 全部未找到颜色，返回失败标记
            return false
        } else {
            return true
        }
    }

    ColorValidation() {
        result := this.ColorExist()
        if (result = false) {
            ; 未找到颜色区域时返回失败标记
            return [-1, -1, -1, -1]
        } else {
            coordinateInfo := this.Coordinate()
            x1 := coordinateInfo[1]
            y1 := coordinateInfo[2]
            x2 := coordinateInfo[3]
            y2 := coordinateInfo[4]
            xStart := x1
            yStart := y1
            xEnd := x2
            yEnd := y2
            return [xStart, yStart, xEnd, yEnd]
        }
    }

    ColorCoordinateCorner() {
        windowId := this.windowId
        colorCoordinateInfo := this.ColorValidation()
        Color := this.Color
        Tolerance := this.Tolerance
        xStart := colorCoordinateInfo[1]
        yStart := colorCoordinateInfo[2]
        xEnd := colorCoordinateInfo[3]
        yEnd := colorCoordinateInfo[4]

        result1 := OS_PixelSearch(&foundX1, &foundY1, xStart, yStart, xEnd, yEnd, Color, Tolerance)
        result2 := OS_PixelSearch(&foundX2, &foundY2, xEnd, yStart, xStart, yEnd, Color, Tolerance)
        result3 := OS_PixelSearch(&foundX3, &foundY3, xStart, yEnd, xEnd, yStart, Color, Tolerance)
        result4 := OS_PixelSearch(&foundX4, &foundY4, xEnd, yEnd, xStart, yStart, Color, Tolerance)
        Mode := this.Mode
        if (result1 = false or result2 = false or result3 = false or result4 = false) {
            ; 任一方向未找到目标颜色则放弃，返回 -1 标记
            return [-1, -1, -1, -1]
        } else {
            colorY1 := Min(foundY1, foundY3)
            colorY2 := Max(foundY2, foundY4)
            if (Mode = "Corner") {
                colorX1 := Min(foundX1, foundX3)
                colorX2 := Max(foundX2, foundX4)
                ColorCoordinateArea := [colorX1, colorY1, colorX2, colorY2]
            } else if (Mode = "Area") {
                ; Area 模式保留原始 X 范围，只更新 Y 区间
                colorX1 := xStart
                colorX2 := xEnd
                ColorCoordinateArea := [colorX1, colorY1, colorX2, colorY2]
            } else {
                ColorCoordinateArea := [xStart, yStart + 1, xEnd, yEnd - 1]
            }

            ColorCoordinateArea := NormalizeRect(ColorCoordinateArea)
            return ColorCoordinateArea
        }
    }

    colorCoordinateFinalInfo() {
        colorCoordinateInfo := this.ColorCoordinateCorner()
        colorCoordinateInfo := NormalizeRect(colorCoordinateInfo)
        x1 := colorCoordinateInfo[1]
        y1 := colorCoordinateInfo[2]
        x2 := colorCoordinateInfo[3]
        y2 := colorCoordinateInfo[4]
        ; 缓存最终定位矩形，供后续使用
        this.xStart := x1
        this.yStart := y1
        this.xEnd := x2
        this.yEnd := y2
        return [this.xStart, this.yStart, this.xEnd, this.yEnd]
    }

    PercentageInfo() {
        BasicTotalInfo := this.BasicTotalInfo
        windowId := BasicTotalInfo[1]
        Color := BasicTotalInfo[2]
        Tolerance := BasicTotalInfo[3]
        totalPixelsWidth := BasicTotalInfo[8]
        totalPixelsHeight := BasicTotalInfo[9]
        totalPixelsArea := BasicTotalInfo[10]
        colorCoordinateArea := this.colorCoordinateFinalInfo()
        if (colorCoordinateArea[1] = -1 and colorCoordinateArea[2] = -1 and colorCoordinateArea[3] = -1 and colorCoordinateArea[4] = -1) {
            ; 未检测到颜色区域时返回失败标记
            return [-1, -1, -1]
        } else {
            ; 计算颜色区域所占宽、高、面积百分比（取整）
            widthArea := Abs(colorCoordinateArea[3] - colorCoordinateArea[1]) + 1
            heightArea := Abs(colorCoordinateArea[4] - colorCoordinateArea[2]) + 1
            colorPixelsArea := widthArea * heightArea
            AreaPercentage := Floor((colorPixelsArea / totalPixelsArea) * 100)
            WidthPercentage := Floor((widthArea / totalPixelsWidth) * 100)
            HeightPercentage := Floor((heightArea / totalPixelsHeight) * 100)
            percentage := [AreaPercentage, WidthPercentage, HeightPercentage]
            return percentage
        }
    }
}


; 类定义：CoordinateCornerCollection
; 颜色角落集合类
; 用于在指定区域内查找特定颜色的四个角落坐标，并计算包含这些角落的最小矩形区域
; windowId - 窗口标识符
; colorCoordinateInfo - 颜色坐标信息，格式为 [x1, y1, x2, y2]
; Color - 目标颜色值
; Tolerance - 颜色容差值
; X1Y1() - 查找左上角坐标
; X2Y2() - 查找右下角坐标
; X2Y1() - 查找右上角坐标
; X1Y2() - 查找左下角坐标
; CornerArea() - 计算包含所有找到的角落的最小矩形区域
; 示例用法：
; cornerCollection := CoordinateCornerCollection(windowId, colorCoordinateInfo, Color, Tolerance)
; topLeft := cornerCollection.X1Y1()
; bottomRight := cornerCollection.X2Y2()
; topRight := cornerCollection.X2Y1()
; bottomLeft := cornerCollection.X1Y2()
; boundingArea := cornerCollection.CornerArea()
; 其中，boundingArea 返回格式为 [x1, y1, x2, y2]，表示包含所有找到角落的最小矩形区域
; 如果未找到任何角落，则返回 [-1, -1, -1, -1] 作为失败标记
; 注意：此类依赖于外部函数 OS_PixelSearch 用于颜色搜索，请确保该函数已正确定义和可用。搜索逻辑为四周角点搜索。
class CoordinateCornerCollection {
    __New(windowId, colorCoordinateInfo, Color, Tolerance) {
        this.windowId := windowId
        this.colorCoordinateInfo := colorCoordinateInfo
        this.Color := Color
        this.Tolerance := Tolerance
        ; 构造时先归一化坐标，方便后续多次 PixelSearch
        this.coordinateInfo := this.Coordinate()
    }

    Coordinate() {
        local colorCoordinateInfo := NormalizeRect(this.colorCoordinateInfo)
        this.xStart := colorCoordinateInfo[1]
        this.yStart := colorCoordinateInfo[2]
        this.xEnd := colorCoordinateInfo[3]
        this.yEnd := colorCoordinateInfo[4]
        return [this.xStart, this.yStart, this.xEnd, this.yEnd]
    }

    X1Y1() {
        ; ▼▼▼ 修正：使用 this.Color 和 this.Tolerance ▼▼▼
        result1 := OS_PixelSearch(&foundX1, &foundY1, this.xStart, this.yStart, this.xEnd, this.yEnd, this.Color, this.Tolerance)
        if (result1 = false) {
            ; 未找到返回占位坐标
            return [-1, -1]
        } else {
            return [foundX1, foundY1]
        }
    }

    X2Y2() {
        ; ▼▼▼ 修正：使用 this.Color 和 this.Tolerance ▼▼▼
        result2 := OS_PixelSearch(&foundX2, &foundY2, this.xEnd, this.yEnd, this.xStart, this.yStart, this.Color, this.Tolerance)
        if (result2 = false) {
            return [-1, -1]
        } else {
            return [foundX2, foundY2]
        }
    }

    X2Y1() {
        ; ▼▼▼ 修正：使用 this.Color 和 this.Tolerance ▼▼▼
        result3 := OS_PixelSearch(&foundX3, &foundY3, this.xEnd, this.yStart, this.xStart, this.yEnd, this.Color, this.Tolerance)
        if (result3 = false) {
            return [-1, -1]
        } else {
            return [foundX3, foundY3]
        }
    }

    X1Y2() {
        ; ▼▼▼ 修正：使用 this.Color 和 this.Tolerance ▼▼▼
        result4 := OS_PixelSearch(&foundX4, &foundY4, this.xStart, this.yEnd, this.xEnd, this.yStart, this.Color, this.Tolerance)
        if (result4 = false) {
            return [-1, -1]
        } else {
            return [foundX4, foundY4]
        }
    }

    CornerArea() {
        x1y1 := this.X1Y1()
        x2y2 := this.X2Y2()
        x2y1 := this.X2Y1()
        x1y2 := this.X1Y2()
        if (x1y1[1] = -1 and x1y1[2] = -1 and x2y2[1] = -1 and x2y2[2] = -1 and x2y1[1] = -1 and x2y1[2] = -1 and x1y2[1] = -1 and x1y2[2] = -1) {
            ; 全部未找到颜色，返回失败标记
            return [-1, -1, -1, -1]
        } else {
            colorX1 := Min(x1y1[1], x1y2[1])
            colorY1 := Min(x1y1[2], x2y1[2])
            colorX2 := Max(x2y2[1], x2y1[1])
            colorY2 := Max(x2y2[2], x1y2[2])
            colorCoordinateArea := [colorX1, colorY1, colorX2, colorY2]
            colorCoordinateArea := NormalizeRect(colorCoordinateArea)
            return colorCoordinateArea
        }
    }
}

; 类定义：GetColorCoordinatesArea
; 流程工具类
; 用于获取数据区域的颜色坐标
; 参数说明：
; windowId: 窗口ID
; coordinateInfo: 坐标信息 [x1, y1, x2, y2]
; colorDataIndexArray: 颜色数据索引数组
; colorOffset: 颜色偏移量
; 返回值：
; colorDataCoordinateArray: 颜色数据坐标数组
; 示例用法：
; GetColorCoordinatesArea := GetColorCoordinatesArea(windowId, coordinateInfo, colorDataIndexArray, ModeNum)
; colorDataCoordinateArray := GetColorCoordinatesArea.GetColorCoordinates()
; 嵌套类调用：
; CoordinateCornerCollection: 用于获取颜色坐标区域
; ColorCoordinateAreaSummary: 用于汇总颜色坐标区域信息
; 显示调试信息：
; ShowDebugMessage: 用于显示调试信息
; WindowColorRegion: 用于显示颜色区域
; 默认显示时间：
; defaultDisplayTime: 预定义的默认显示时间变量
; colorArray: 全局颜色数组变量
; 注意事项：
; 确保传入的参数格式正确，特别是坐标信息和颜色数据索引数组
class GetColorCoordinatesArea {
    __New(windowId, coordinateInfo, colorIndexArray, ModeNum, SummaryMode) {
        this.windowId := windowId
        this.coordinateInfo := coordinateInfo
        this.colorIndexArray := colorIndexArray
        this.ModeNum := ModeNum
        this.SummaryMode := SummaryMode
        this.colorCoordinatePercentageArray := []
        this.colorCoordinateArray := []
        this.colorPercentageArray := []
    }

    GetColorCoordinates() {
        windowId := this.windowId
        coordinateInfo := this.coordinateInfo
        colorIndexArray := this.colorIndexArray
        ModeNum := this.ModeNum
        colorCoordinateArray := []
        colorPercentageArray := []
        loop colorIndexArray.Length {
            ColorIndex := colorIndexArray[A_Index]
            Color := colorArray[ColorIndex][3]
            Tolerance := colorArray[ColorIndex][4]
            AreaCornerInfo := CoordinateAreaCornerInfo(windowId, coordinateInfo, Color, Tolerance, ModeNum)
            colorCoordinateArea := AreaCornerInfo.colorCoordinateFinalInfo() ; 测试角落坐标收集类
            PercentageResults := AreaCornerInfo.PercentageInfo() ; 获取颜色覆盖率信息
            colorCoordinateArray.Push(colorCoordinateArea)
            colorPercentageArray.Push(PercentageResults)
        }
        return [colorCoordinateArray, colorPercentageArray]
    }

    __BaseInfo() {
        this.colorCoordinatePercentageArray := this.GetColorCoordinates()
        BaseInfo := this.colorCoordinatePercentageArray
        this.colorCoordinateArray := BaseInfo[1]
        this.colorPercentageArray := BaseInfo[2]
        return [this.colorCoordinateArray, this.colorPercentageArray]
    }

    GetMaxMinAreas() {
        SummaryMode := this.SummaryMode
        this.__BaseInfo()
        summary := ColorCoordinateAreaSummary(this.colorCoordinateArray, SummaryMode)
        MaxArea := summary.MaxArea()
        MinArea := summary.MinArea()
        return [MaxArea, MinArea]
    }

    GetMaxAreaX1Y1() {
        areas := this.GetMaxMinAreas()
        MaxArea := areas[1]
        x1Max := MaxArea[1]
        y1Max := MaxArea[2]
        return [x1Max, y1Max]
    }

    GetMaxAreaX2Y1() {
        areas := this.GetMaxMinAreas()
        MaxArea := areas[1]
        x2Max := MaxArea[3]
        y1Max := MaxArea[2]
        return [x2Max, y1Max]
    }

    GetMaxAreaX1Y2() {
        areas := this.GetMaxMinAreas()
        MaxArea := areas[1]
        x1Max := MaxArea[1]
        y2Max := MaxArea[4]
        return [x1Max, y2Max]
    }

    GetMaxAreaX2Y2() {
        areas := this.GetMaxMinAreas()
        MaxArea := areas[1]
        x2Max := MaxArea[3]
        y2Max := MaxArea[4]
        return [x2Max, y2Max]
    }

    colorPercentage() {
        this.__BaseInfo()
        colorPercentageArray := this.colorPercentageArray
        return colorPercentageArray
    }
}

; ========================= 主程序逻辑开始 ==========================
ShowDebugMessage("开始执行数据收集应用程序的启动与排列。")
currentTimeStr := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
time1 := currentTimeStr

; 创建窗口排列管理器并排列所有窗口
windowArrangerScheme := WindowArranger(targetAppName, minWindowWidth, minWindowHeight)
screenLocationIndexArray := windowArrangerScheme.ArrangeWindows()

; 记录窗口位置信息到数组中
wechatAppScreenLocationArray := screenLocationIndexArray
arrayOne := wechatAppScreenLocationArray
arrayOneList := ConvertArrayToString(arrayOne, "`r`n", "`t")
; 输出窗口定位结果，便于调试查看
ShowDebugMessage(arrayOneList)

; 提取所有窗口ID到单独的数组
idArray := []
loop arrayOne.Length {
    ; 每个元素结构 [windowId, xStart, yStart, xEnd, yEnd]
    locationIndex := arrayOne[A_Index]
    windowId := locationIndex[1] + 0
    idArray.Push(windowId)
}

; 收集所有窗口的启动坐标（用于后续批量启动第三方应用）
xStartAppArray := []
yStartAppArray := []
loop arrayOne.Length {
    locationIndex := arrayOne[A_Index]
    xScreenStart := locationIndex[2] + 0
    yScreenStart := locationIndex[3] + 0
    xScreenEnd := locationIndex[4] + 0
    yScreenEnd := locationIndex[5] + 0
    ; 记录每个窗口的左上/右下坐标两次，用于计算整体布置范围
    xStartAppArray.Push(xScreenStart)
    yStartAppArray.Push(yScreenStart)
    xStartAppArray.Push(xScreenEnd)
    yStartAppArray.Push(yScreenEnd)
}

; 计算用于排列第三方应用的起始坐标
ShowDebugMessage("收集到的启动坐标数组已准备就绪。")
xStart := GetArrayMaximumValue(xStartAppArray)
yStart := GetArrayMinimumValue(yStartAppArray)

; 批量启动和排列第三方应用的代码（已注释，可按需启用）
ShowDebugMessage("开始批量启动和排列第三方应用。")
loop {
    launcher := BatchAppLauncherAndArranger(g_exeMap, xStart, yStart)
    newIdArray := launcher.ArrangeAllWindows()
    windowsExeIdArray := newIdArray
    arrayTwo := windowsExeIdArray
    Sleep(defaultSleepTime)
    if (arrayTwo.Length = g_exeMap.Length) {
        ; 全部程序已成功识别到主窗口，结束循环
        break
    } else {
        if (A_Index < 5) {
            ; 少于 5 次尝试继续重试
            continue
        } else {
            break
        }
    }
}
ShowDebugMessage("第三方应用程序批量启动与排列完成。")

; 激活所有第三方应用窗口，确保截图时窗口在前端
ExeNameMap := Map()
loop windowsExeIdArray.Length {
    Name := windowsExeIdArray[A_Index][2]
    if (InStr(Name, "PowerShell") > 0) {
        ExeNameMap["PowerShell"] := windowsExeIdArray[A_Index][1]
    } else if (InStr(Name, "Umi-OCR") > 0) {
        ExeNameMap["Umi-OCR"] := windowsExeIdArray[A_Index][1]
    } else if (InStr(Name, "命令提示符") > 0) {
        ExeNameMap["Cmd"] := windowsExeIdArray[A_Index][1]
    } else if (InStr(Name, "ShareX") > 0) {
        ExeNameMap["ShareX"] := windowsExeIdArray[A_Index][1]
    } else {
        continue
    }
}
windowId := ExeNameMap["PowerShell"]
PowerShellInfo := SafeActivateWindow(windowId, "Client")
Sleep(defaultSleepTime * 1)
; 准备截图保存路径
screenshotCoordinatesClientInfo := [PowerShellInfo[2], PowerShellInfo[3], PowerShellInfo[4], PowerShellInfo[5]]
savePath := A_ScriptDir . "\截图文件"
WindowScreenshot(windowId, screenshotCoordinatesClientInfo, savePath).FilePathValidation()
; 发送截图脚本到 PowerShell 窗口
ScreenScript := "cls" "`n"
ScreenScript .= "Set-Location " "`"" savePath "`"" "`n"
ScreenScript .= "Start-Sleep" " -Milliseconds 100 " "`n"
A_Clipboard := "" ; 清空剪贴板以防干扰
Sleep(defaultSleepTime * 1)
A_Clipboard := ScreenScript
SafeActivateWindow(windowId, "Client")
Sleep(defaultSleepTime * 1)
SendInput(ScreenScript)
Sleep(defaultSleepTime * 1)

; ========================= 调试区域 ==========================
ShowDebugMessage("开始查询截图区域。")
ids := WinGetList(targetAppName)
loop ids.Length {
    ; 参数准备
    windowId := ids[A_Index]
    windowInfo := SafeActivateWindow(windowId, "Client")
    x1 := windowInfo[2]
    y1 := windowInfo[3]
    x2 := windowInfo[4]
    y2 := windowInfo[5]
    coordinateInfo := [x1, y1, x2, y2]
    windowTotal := coordinateInfo
    ; 颜色配置参数
    modMin := g_splitConfig["modMin"]
    xCoarseAndFine := g_splitConfig["xCoarseAndFine"]
    xModNum := Round(modMin * xCoarseAndFine, 0)
    yCoarseAndFine := g_splitConfig["yCoarseAndFine"]
    yModNum := Round(modMin * yCoarseAndFine, 0)
    xDivisions := g_splitConfig["xDivisions"]
    yDivisions := g_splitConfig["yDivisions"]
    xMinBorderInterval := Round(xModNum / 1, 0)
    yMinBorderInterval := Round(yModNum / 1, 0)
    borderIntervalX := xMinBorderInterval
    borderIntervalY := yMinBorderInterval
    ModeNum := 1 ; 模式编号
    SummaryMode := "Correct-Silent"

    ; ========================= 测试 TotalRegionRightTopCornerLeftBottomCorner 类 ==========================
    colorIndexArray := [7, 8, 9, 10]
    PointX1Y1Info := GetColorCoordinatesArea(windowId, coordinateInfo, colorIndexArray, ModeNum, SummaryMode).GetMaxAreaX1Y1()
    PointX2Y2Info := GetColorCoordinatesArea(windowId, coordinateInfo, colorIndexArray, ModeNum, SummaryMode).GetMaxAreaX2Y2()
    x1Data := PointX1Y1Info[1]
    y1Data := PointX1Y1Info[2]
    x2Data := PointX2Y2Info[1]
    y2Data := PointX2Y2Info[2]
    if (x1Data = -1 or y1Data = -1 or x2Data = -1 or y2Data = -1) {
        ShowDebugMessage("Error: 未能成功定位数据区域的颜色坐标，请检查截图区域及颜色配置。", , "T1")
        DataAreaInfo := [-1, -1, -1, -1]
    } else {
        CellInfo := CoordinateMapping(PointX2Y2Info, windowTotal, xModNum, yModNum).xyMap()
        ColorShow := "0x00FF00"
        WindowColorRegion(windowId, CellInfo, ColorShow, defaultDisplayTime * 1).ShowRegion()
        x1 := CellInfo[1]
        y1 := CellInfo[2]
        x2 := CellInfo[3]
        y2 := CellInfo[4]
        coordinateInfo := windowTotal
        PointX2Y2Info := [x2, y2]
        PointDataEnd := PointX2Y2Info
        PointXYInfo := PointX2Y2Info
        MouseMove(x2, y2)
        Sleep(defaultSleepTime)
        ColorIndex1 := 2
        ColorIndex2 := 1
        Color1 := colorArray[ColorIndex1][3]
        Tolerance1 := colorArray[ColorIndex1][4]
        Color2 := colorArray[ColorIndex2][3]
        Tolerance2 := colorArray[ColorIndex2][4]
        ColorValidArray := [[Color1, Tolerance1]]
        ; 调用边缘检测类进行边缘检测
        ValidTrueMap := Map(
            "TopLeftCorner", ["1"],
            "TopEdgeCenter", ["1"],
            "TopRightCorner", ["1"],
            "LeftEdgeCenter", ["1"],
            "RegionCenter", ["1"],
            "RightEdgeCenter", ["1"],
            "BottomLeftCorner", ["1"],
            "BottomEdgeCenter", ["1"],
            "BottomRightCorner", ["1"]
        )

        edgeDetector := EdgeDetectionColor(windowId, coordinateInfo, PointXYInfo, xModNum, yModNum, ColorValidArray, ValidTrueMap, colorArray)
        PointXYInfo := edgeDetector.LoopBreakResult() ; 获取边缘检测结果坐标
        CellInfo := CoordinateMapping(PointXYInfo, windowTotal, xModNum, yModNum).xyMap()
        ColorShow := "0xFF00FF"
        WindowColorRegion(windowId, CellInfo, ColorShow, defaultDisplayTime * 1).ShowRegion()
        PointFontEnd := [CellInfo[3], CellInfo[4]]
        ; 截图区域定位
        coordinateInfo := [PointDataEnd[1], PointDataEnd[2], PointFontEnd[1], PointFontEnd[2]]
        coordinateInfo := NormalizeRect(coordinateInfo)
        ColorIndex := 3
        Color := colorArray[ColorIndex][3]
        Tolerance := colorArray[ColorIndex][4]
        colorCoordinateArea := CoordinateCornerCollection(windowId, coordinateInfo, Color, Tolerance).CornerArea() ; 测试角落坐标收集类
        ColorShow := "0xFF0000"
        WindowColorRegion(windowId, colorCoordinateArea, ColorShow, defaultDisplayTime * 1).ShowRegion()
        xClick := Round((colorCoordinateArea[1] + colorCoordinateArea[3]) / 2, 0)
        yClick := Round((colorCoordinateArea[2] + colorCoordinateArea[4]) / 2, 0)
        PointInfoXY := [xClick, yClick]
        NumClicks := 1
        MoveAndClickLoop(xClick, yClick, NumClicks, defaultSleepTime)
    }

    ; ========================= 测试 TotalRegionLeftTopCornerRightBottomCorner 类 ==========================
    ; windowInfo := SafeActivateWindow(windowId, "Client")
    ; x1 := windowInfo[2]
    ; y1 := windowInfo[3]
    ; x2 := windowInfo[4]
    ; y2 := windowInfo[5]
    ; coordinateInfo := [x1, y1, x2, y2]
    ; colorIndexArray := [1, 2] ; 颜色索引
    ; ModeNum := 1 ; 模式编号
    ; SummaryMode := "Correct-Silent"
    ; windowTotal := coordinateInfo
    ; LeftTopResultValidation := [[[90, 90, 90], [100, 100, 100]], [[-1, -1, -1], [0, 0, 0]]] ; 左上角结果验证
    ; RightBottomResultValidation := [[[90, 90, 90], [100, 100, 100]], [[-1, -1, -1], [0, 0, 0]]] ; 右下角结果验证
    ; TotalRegionInstance := TotalRegionLeftTopCornerRightBottomCorner(windowId, coordinateInfo, borderIntervalX, borderIntervalY, colorIndexArray, ModeNum, SummaryMode, LeftTopResultValidation, RightBottomResultValidation)
    ; finalCoordinateInfo := TotalRegionInstance.AreaFinalInfo()
    ; MsgBox("最终区域坐标：" . finalCoordinateInfo[1] . ", " . finalCoordinateInfo[2] . ", " . finalCoordinateInfo[3] . ", " . finalCoordinateInfo[4], , "T1")
    ; ColorShow := "0xDD0000" ; 蓝色显示最终区域
    ; WindowColorRegion(windowId, finalCoordinateInfo, ColorShow, defaultDisplayTime * 1).ShowRegion()


    ; ========================= 测试 TotalRegionLeftBottomCornerRightTopCorner 类 ==========================
    windowInfo := SafeActivateWindow(windowId, "Client")
    x1 := windowInfo[2]
    y1 := windowInfo[3]
    x2 := windowInfo[4]
    y2 := windowInfo[5]
    coordinateInfo := [x1, y1, x2, y2]
    colorIndexArray := [1, 2] ; 颜色索引
    ModeNum := 1 ; 模式编号
    SummaryMode := "Correct-Silent"
    windowTotal := coordinateInfo
    LeftBottomResultValidation := [[[90, 90, 90], [100, 100, 100]], [[-1, -1, -1], [0, 0, 0]]] ; 左上角结果验证
    RightTopResultValidation := [[[90, 90, 90], [100, 100, 100]], [[-1, -1, -1], [0, 0, 0]]] ; 右下角结果验证
    TotalRegionInstance := TotalRegionLeftBottomCornerRightTopCorner(windowId, coordinateInfo, borderIntervalX, borderIntervalY, colorIndexArray, ModeNum, SummaryMode, RightTopResultValidation, LeftBottomResultValidation)
    finalCoordinateInfo := TotalRegionInstance.AreaFinalInfo()
    MsgBox("最终区域坐标：" . finalCoordinateInfo[1] . ", " . finalCoordinateInfo[2] . ", " . finalCoordinateInfo[3] . ", " . finalCoordinateInfo[4], , "T1")
    ColorShow := "0x00FF00" ; 蓝色显示最终区域
    WindowColorRegion(windowId, finalCoordinateInfo, ColorShow, defaultDisplayTime * 1).ShowRegion()

    ; ========================= 测试 TotalRegionTopCenterBottomCenter 类 ==========================
    coordinateInfo := finalCoordinateInfo
     ; 使用上一个测试的最终区域作为输入区域
    colorIndexArray := [1, 6] ; 颜色索引
    ModeNum := 1 ; 模式编号
    SummaryMode := "Correct-Silent"
    windowTotal := finalCoordinateInfo
    modMin := g_splitConfig["modMin"]
    xCoarseAndFine := g_splitConfig["xCoarseAndFine"]
    xModNum := Round(modMin * xCoarseAndFine, 0)
    yCoarseAndFine := g_splitConfig["yCoarseAndFine"]
    yModNum := Round(modMin * yCoarseAndFine, 0)
    xDivisions := g_splitConfig["xDivisions"]
    yDivisions := g_splitConfig["yDivisions"]
     ; 计算边界间隔
    xMinBorderInterval := Round(xModNum * 12, 0)
    yMinBorderInterval := Round(yModNum * 1, 0)
    borderIntervalX := xMinBorderInterval
    borderIntervalY := yMinBorderInterval
    MsgBox("xMinBorderInterval: " . xMinBorderInterval . ", yMinBorderInterval: " . yMinBorderInterval, , "T2")
    TopCenterResultValidation := [[[-1, -1, -1], [0, 0, 0]], [[80, 80, 80], [100, 100, 100]]] 
    BottomCenterResultValidation := [[[-1, -1, -1], [0, 0, 0]], [[80, 80, 80], [100, 100, 100]]]
     ; 顶部中心与底部中心结果验证
    TotalRegionInstance := TotalRegionTopCenterBottomCenter(windowId, coordinateInfo, borderIntervalX, borderIntervalY, colorIndexArray, ModeNum, SummaryMode, TopCenterResultValidation, BottomCenterResultValidation)
    finalCoordinateInfo := TotalRegionInstance.AreaFinalInfo()
    MsgBox("最终区域坐标：" . finalCoordinateInfo[1] . ", " . finalCoordinateInfo[2] . ", " . finalCoordinateInfo[3] . ", " . finalCoordinateInfo[4], , "T10")
    ColorShow := "0x0000FF" ; 蓝色显示最终区域
    WindowColorRegion(windowId, finalCoordinateInfo, ColorShow, defaultDisplayTime * 10).ShowRegion()
}

ExitApp

; 类定义：TotalRegionLeftBottomCornerRightTopCorner
; 总区域类 - 左上角与右下角-通用工具类
class TotalRegionLeftTopCornerRightBottomCorner {
    __New(windowId, coordinateInfo, borderIntervalX, borderIntervalY, colorIndexArray, ModeNum, SummaryMode, LeftTopResultValidation, RightBottomResultValidation) {
        this.windowId := windowId
        windowInfo := SafeActivateWindow(windowId, "Client")
        this.xStart := windowInfo[2]
        this.yStart := windowInfo[3]
        this.xEnd := windowInfo[4]
        this.yEnd := windowInfo[5]
        this.coordinateInfo := coordinateInfo
        this.coordinateInfoNew := []
        this.borderIntervalX := borderIntervalX
        this.borderIntervalY := borderIntervalY
        this.colorIndexArray := colorIndexArray
        this.ModeNum := ModeNum
        this.SummaryMode := SummaryMode
        this.LeftTopResultValidation := LeftTopResultValidation
        this.RightBottomResultValidation := RightBottomResultValidation
        this.LeftTopCornerLoop := false
        this.RightBottomCornerLoop := false
        this.RegionMapArray := []
        this.LeftTopCorner := []
        this.RightBottomCorner := []
        this.CenterRegion := []
        this.loopBreakCount := 0
    }

    DataValueValidation() {
        LeftTopResultValidation := this.LeftTopResultValidation
        RightBottomResultValidation := this.RightBottomResultValidation
        colorIndexArray := this.colorIndexArray
        if (Type(LeftTopResultValidation) != "Array" or Type(RightBottomResultValidation) != "Array") {
            return false
        } else {
            if (LeftTopResultValidation.Length != colorIndexArray.Length or RightBottomResultValidation.Length != colorIndexArray.Length) {
                return false
            } else {
                loop colorIndexArray.Length {
                    LeftTopResultValidationOne := LeftTopResultValidation[A_Index]
                    RightBottomResultValidationOne := RightBottomResultValidation[A_Index]
                    if (Type(LeftTopResultValidationOne) != "Array" or LeftTopResultValidationOne.Length != 2 or Type(RightBottomResultValidationOne) != "Array" or RightBottomResultValidationOne.Length != 2) {
                        return false
                    } else {
                        loop LeftTopResultValidationOne.Length {
                            if (Type(LeftTopResultValidationOne[A_Index]) != "Array" or LeftTopResultValidationOne[A_Index].Length != 3) {
                                return false
                            } else {
                                loop LeftTopResultValidationOne.Length {
                                    ItemOne := LeftTopResultValidationOne[A_Index]
                                    if (Type(ItemOne) != "Array" or ItemOne.Length != 3) {
                                        return false
                                    } else {
                                        if (IsNumber(ItemOne[1]) = false or IsNumber(ItemOne[2]) = false or IsNumber(ItemOne[3]) = false) {
                                            return false
                                        }
                                    }
                                }
                            }
                        }
                        loop RightBottomResultValidationOne.Length {
                            if (Type(RightBottomResultValidationOne[A_Index]) != "Array" or RightBottomResultValidationOne[A_Index].Length != 3) {
                                return false
                            } else {
                                loop RightBottomResultValidationOne.Length {
                                    ItemTwo := RightBottomResultValidationOne[A_Index]
                                    if (Type(ItemTwo) != "Array" or ItemTwo.Length != 3) {
                                        return false
                                    } else {
                                        if (IsNumber(ItemTwo[1]) = false or IsNumber(ItemTwo[2]) = false or IsNumber(ItemTwo[3]) = false) {
                                            return false
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            return true
        }
    }

    GetRegionMap() {
        DataValueValidationResult := this.DataValueValidation()
        if (DataValueValidationResult = false) {
            MsgBox("TotalRegion 类的参数 LeftTopResultValidation 或 RightBottomResultValidation 格式不正确，无法继续执行。", , "错误提示")
        }
        windowId := this.windowId
        x1 := this.xStart
        x2 := this.xEnd
        if (this.loopBreakCount > 100) {
            MsgBox("TotalRegion 类在获取区域映射时循环次数过多，可能存在无法满足验证条件的情况，程序终止以防死循环。", , "错误提示")
            ExitApp
        } else {
            if (this.loopBreakCount > 0) {
                this.coordinateInfo := this.coordinateInfoNew
            } else {
                this.coordinateInfo := this.coordinateInfo
            }
        }
        coordinateInfo := this.coordinateInfo
        borderIntervalX := this.borderIntervalX
        borderIntervalY := this.borderIntervalY
        colorIndexArray := this.colorIndexArray
        ModeNum := this.ModeNum
        summaryMode := this.SummaryMode
        colorCoordinatesAreaCollector := GetColorCoordinatesArea(windowId, coordinateInfo, colorIndexArray, ModeNum, summaryMode)
        colorCoordinatesArea := colorCoordinatesAreaCollector.GetMaxMinAreas()
        colorPercentageArray := colorCoordinatesAreaCollector.colorPercentage()
        MaxArea := colorCoordinatesArea[1]
        MinArea := colorCoordinatesArea[2]
        MaxArea := [x1, MaxArea[2], x2, MaxArea[4]]
        MinArea := [x1, MinArea[2], x2, MinArea[4]]
        MaxArea := NormalizeRect(MaxArea)
        MinArea := NormalizeRect(MinArea)
        ; 验证左上角结果
        Area := [MaxArea, MinArea]
        this.coordinateInfoNew := ColorCoordinateAreaSummary(Area, "Correct-Silent").MinArea()
        ; ColorShow := "0xFF00FF" ; 蓝色显示当前区域
        ; WindowColorRegion(windowId, this.coordinateInfoNew, ColorShow, defaultDisplayTime).ShowRegion()
        RegionMap := BaseRegionMap(windowId, this.coordinateInfoNew, xMinBorderInterval, yMinBorderInterval)
        BorderRegionMap := RegionMap.GetBorderRegionMap()
        RegionMap := RegionMap.GetRegionMap()
        RegionMapArray := [RegionMap, BorderRegionMap]
        return RegionMapArray
    }

    __BaseInfo() {
        RegionMapArray := this.GetRegionMap()
        this.RegionMap := RegionMapArray[1]
        this.BorderRegionMap := RegionMapArray[2]
        LeftTopCorner := this.BorderRegionMap["LeftTopCorner"]
        RightBottomCorner := this.BorderRegionMap["RightBottomCorner"]
        CenterRegion := this.RegionMap["CenterRegion"]
        CenterRegion := [this.xStart, CenterRegion[2], this.xEnd, CenterRegion[4]]
        CenterRegion := NormalizeRect(CenterRegion)
        this.CenterRegion := CenterRegion
        this.LeftTopCorner := LeftTopCorner
        this.RightBottomCorner := RightBottomCorner
        RegionArray := [LeftTopCorner, RightBottomCorner, CenterRegion]
        return RegionArray
    }

    LeftTopCornerPercentageResult() {
        this.__BaseInfo()
        LeftTopCorner := this.LeftTopCorner
        windowId := this.windowId
        colorIndexArray := this.colorIndexArray
        ModeNum := this.ModeNum
        summaryMode := this.SummaryMode
        ; ColorShow := "0xFF0000" ; 绿色显示左上角区域
        ; WindowColorRegion(windowId, LeftTopCorner, ColorShow, defaultDisplayTime * 0.5).ShowRegion()
        colorCoordinatesAreaCollector := GetColorCoordinatesArea(windowId, LeftTopCorner, colorIndexArray, ModeNum, summaryMode)
        colorCoordinatesArea := colorCoordinatesAreaCollector.GetMaxMinAreas()
        colorPercentageArray := colorCoordinatesAreaCollector.colorPercentage()
        return colorPercentageArray
    }

    RightBottomCornerPercentageResult() {
        this.__BaseInfo()
        RightBottomCorner := this.RightBottomCorner
        windowId := this.windowId
        colorIndexArray := this.colorIndexArray
        ModeNum := this.ModeNum
        summaryMode := this.SummaryMode
        ; ColorShow := "0x0000FF" ; 红色显示右下角区域
        ; WindowColorRegion(windowId, RightBottomCorner, ColorShow, defaultDisplayTime * 0.5).ShowRegion()
        colorCoordinatesAreaCollector := GetColorCoordinatesArea(windowId, RightBottomCorner, colorIndexArray, ModeNum, summaryMode)
        colorCoordinatesArea := colorCoordinatesAreaCollector.GetMaxMinAreas()
        colorPercentageArray := colorCoordinatesAreaCollector.colorPercentage()
        return colorPercentageArray
    }

    GetLeftTopCorner() {
        colorPercentageArray := this.LeftTopCornerPercentageResult()
        LeftTopCorner := this.LeftTopCorner
        x1Max := this.coordinateInfo[1]
        x2Max := this.coordinateInfo[3]
        y2Max := this.coordinateInfo[4]
        if (this.LeftTopResultValidation.Length != colorPercentageArray.Length) {
            MsgBox("TotalRegion 类的参数 LeftTopResultValidation 格式不正确，无法继续执行。", , "错误提示")
        }
        loop this.LeftTopResultValidation.Length {
            expectedValues := this.LeftTopResultValidation[A_Index]
            expectedValuesMin := expectedValues[1]
            expectedValuesMax := expectedValues[2]
            actualValues := colorPercentageArray[A_Index]
            if (actualValues[1] >= expectedValuesMin[1] and actualValues[2] >= expectedValuesMin[2] and actualValues[3] >= expectedValuesMin[3] and actualValues[1] <= expectedValuesMax[1] and actualValues[2] <= expectedValuesMax[2] and actualValues[3] <= expectedValuesMax[3]) {
                this.LeftTopCornerLoop := true
                y1Max := LeftTopCorner[2]
                this.LeftTopCornerFinal := [x1Max, y1Max, x2Max, y2Max]
                break
            } else {
                this.LeftTopCornerLoop := false
                y1Max := LeftTopCorner[4]
                this.LeftTopCornerFinal := [x1Max, y1Max, x2Max, y2Max]
            }
        }
        return this.LeftTopCornerFinal
    }

    GetRightBottomCorner() {
        colorPercentageArray := this.RightBottomCornerPercentageResult()
        RightBottomCorner := this.RightBottomCorner
        x1Min := this.coordinateInfo[1]
        x2Min := this.coordinateInfo[3]
        y1Min := this.coordinateInfo[2]
        if (this.RightBottomResultValidation.Length != colorPercentageArray.Length) {
            MsgBox("TotalRegion 类的参数 RightBottomResultValidation 格式不正确，无法继续执行。", , "错误提示")
        }
        loop this.RightBottomResultValidation.Length {
            expectedValues := this.RightBottomResultValidation[A_Index]
            expectedValuesMin := expectedValues[1]
            expectedValuesMax := expectedValues[2]
            actualValues := colorPercentageArray[A_Index]
            if (actualValues[1] >= expectedValuesMin[1] and actualValues[2] >= expectedValuesMin[2] and actualValues[3] >= expectedValuesMin[3] and actualValues[1] <= expectedValuesMax[1] and actualValues[2] <= expectedValuesMax[2] and actualValues[3] <= expectedValuesMax[3]) {
                this.RightBottomCornerLoop := true
                y2Min := RightBottomCorner[4]
                this.RightBottomCornerFinal := [x1Min, y1Min, x2Min, y2Min]
                break
            } else {
                this.RightBottomCornerLoop := false
                y2Min := RightBottomCorner[2]
                this.RightBottomCornerFinal := [x1Min, y1Min, x2Min, y2Min]
            }
        }
        return this.RightBottomCornerFinal
    }

    loopBreakValidation() {
        if (this.LeftTopCornerLoop = true and this.RightBottomCornerLoop = true) {
            return true
        } else {
            ShowDebugMessage("需要继续循环检测区域。`nLeftTopCornerLoop: " . this.LeftTopCornerLoop . "`nRightBottomCornerLoop: " . this.RightBottomCornerLoop, , "T1")
            if (this.LeftTopCornerLoop = false and this.RightBottomCornerLoop = true) {
                this.LeftTopCornerFinal := this.GetLeftTopCorner()
            } else if (this.LeftTopCornerLoop = true and this.RightBottomCornerLoop = false) {
                this.RightBottomCornerFinal := this.GetRightBottomCorner()
            } else {
                this.LeftTopCornerFinal := this.GetLeftTopCorner()
                this.RightBottomCornerFinal := this.GetRightBottomCorner()
            }
            return false
        }
    }

    AreaFinalInfo() {
        this.loopBreakValidation()
        loop {
            ShowDebugMessage("开始第 " . (this.loopBreakCount + 1) . " 次循环检测区域。", , "T1")
            this.loopBreakCount += 1
            loopBreak := this.loopBreakValidation()
            ShowDebugMessage("LeftTopCornerLoop: " . this.LeftTopCornerLoop . "`nRightBottomCornerLoop: " . this.RightBottomCornerLoop . "`nloopBreak: " . loopBreak, , "T1")
            if (loopBreak = true) {
                finalCoordinateInfo := [this.LeftTopCornerFinal[1], this.LeftTopCornerFinal[2], this.RightBottomCornerFinal[3], this.RightBottomCornerFinal[4]]
                finalCoordinateInfo := NormalizeRect(finalCoordinateInfo)
                return finalCoordinateInfo
            } else {
                finalCoordinateInfo := [this.LeftTopCornerFinal[1], this.LeftTopCornerFinal[2], this.RightBottomCornerFinal[3], this.RightBottomCornerFinal[4]]
                this.coordinateInfoNew := NormalizeRect(finalCoordinateInfo)
                ShowDebugMessage("新的区域坐标为：" . this.coordinateInfo[1] . ", " . this.coordinateInfo[2] . ", " . this.coordinateInfo[3] . ", " . this.coordinateInfo[4], , "T1")
                continue
            }
        }
    }
}

; 类定义：TotalRegionLeftBottomCornerRightTopCorner
; 总区域类 - 左下角与右上角-通用工具类
class TotalRegionLeftBottomCornerRightTopCorner {
    __New(windowId, coordinateInfo, borderIntervalX, borderIntervalY, colorIndexArray, ModeNum, SummaryMode, RightTopResultValidation, LeftBottomResultValidation) {
        this.windowId := windowId
        windowInfo := SafeActivateWindow(windowId, "Client")
        this.xStart := windowInfo[2]
        this.yStart := windowInfo[3]
        this.xEnd := windowInfo[4]
        this.yEnd := windowInfo[5]
        this.coordinateInfo := coordinateInfo
        this.coordinateInfoNew := []
        this.borderIntervalX := borderIntervalX
        this.borderIntervalY := borderIntervalY
        this.colorIndexArray := colorIndexArray
        this.ModeNum := ModeNum
        this.SummaryMode := SummaryMode
        this.LeftBottomResultValidation := LeftBottomResultValidation
        this.RightTopResultValidation := RightTopResultValidation
        this.LeftBottomCornerLoop := false
        this.RightTopCornerLoop := false
        this.RegionMapArray := []
        this.LeftBottomCorner := []
        this.RightTopCorner := []
        this.CenterRegion := []
        this.loopBreakCount := 0
    }

    DataValueValidation() {
        LeftBottomResultValidation := this.LeftBottomResultValidation
        RightTopResultValidation := this.RightTopResultValidation
        colorIndexArray := this.colorIndexArray
        if (Type(LeftBottomResultValidation) != "Array" or Type(RightTopResultValidation) != "Array") {
            return false
        } else {
            if (LeftBottomResultValidation.Length != colorIndexArray.Length or RightTopResultValidation.Length != colorIndexArray.Length) {
                return false
            } else {
                loop colorIndexArray.Length {
                    LeftBottomResultValidationOne := LeftBottomResultValidation[A_Index]
                    RightTopResultValidationOne := RightTopResultValidation[A_Index]
                    if (Type(LeftBottomResultValidationOne) != "Array" or LeftBottomResultValidationOne.Length != 2 or Type(RightTopResultValidationOne) != "Array" or RightTopResultValidationOne.Length != 2) {
                        return false
                    } else {
                        loop LeftBottomResultValidationOne.Length {
                            if (Type(LeftBottomResultValidationOne[A_Index]) != "Array" or LeftBottomResultValidationOne[A_Index].Length != 3) {
                                return false
                            } else {
                                loop LeftBottomResultValidationOne.Length {
                                    ItemOne := LeftBottomResultValidationOne[A_Index]
                                    if (Type(ItemOne) != "Array" or ItemOne.Length != 3) {
                                        return false
                                    } else {
                                        if (IsNumber(ItemOne[1]) = false or IsNumber(ItemOne[2]) = false or IsNumber(ItemOne[3]) = false) {
                                            return false
                                        }
                                    }
                                }
                            }
                        }
                        loop RightTopResultValidationOne.Length {
                            if (Type(RightTopResultValidationOne[A_Index]) != "Array" or RightTopResultValidationOne[A_Index].Length != 3) {
                                return false
                            } else {
                                loop RightTopResultValidationOne.Length {
                                    ItemTwo := RightTopResultValidationOne[A_Index]
                                    if (Type(ItemTwo) != "Array" or ItemTwo.Length != 3) {
                                        return false
                                    } else {
                                        if (IsNumber(ItemTwo[1]) = false or IsNumber(ItemTwo[2]) = false or IsNumber(ItemTwo[3]) = false) {
                                            return false
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            return true
        }
    }

    GetRegionMap() {
        DataValueValidationResult := this.DataValueValidation()
        if (DataValueValidationResult = false) {
            MsgBox("TotalRegion 类的参数 LeftBottomResultValidation 或 RightTopResultValidation 格式不正确，无法继续执行。", , "错误提示")
        }
        windowId := this.windowId
        x1 := this.xStart
        x2 := this.xEnd
        if (this.loopBreakCount > 100) {
            MsgBox("TotalRegion 类在获取区域映射时循环次数过多，可能存在无法满足验证条件的情况，程序终止以防死循环。", , "错误提示")
            ExitApp
        } else {
            if (this.loopBreakCount > 0) {
                this.coordinateInfo := this.coordinateInfoNew
            } else {
                this.coordinateInfo := this.coordinateInfo
            }
        }
        coordinateInfo := this.coordinateInfo
        borderIntervalX := this.borderIntervalX
        borderIntervalY := this.borderIntervalY
        colorIndexArray := this.colorIndexArray
        ModeNum := this.ModeNum
        summaryMode := this.SummaryMode
        colorCoordinatesAreaCollector := GetColorCoordinatesArea(windowId, coordinateInfo, colorIndexArray, ModeNum, summaryMode)
        colorCoordinatesArea := colorCoordinatesAreaCollector.GetMaxMinAreas()
        colorPercentageArray := colorCoordinatesAreaCollector.colorPercentage()
        MaxArea := colorCoordinatesArea[1]
        MinArea := colorCoordinatesArea[2]
        MaxArea := [x1, MaxArea[2], x2, MaxArea[4]]
        MinArea := [x1, MinArea[2], x2, MinArea[4]]
        MaxArea := NormalizeRect(MaxArea)
        MinArea := NormalizeRect(MinArea)
        ; 验证左上角结果
        Area := [MaxArea, MinArea]
        this.coordinateInfoNew := ColorCoordinateAreaSummary(Area, "Correct-Silent").MinArea()
        ; ColorShow := "0xFF00FF" ; 蓝色显示当前区域
        ; WindowColorRegion(windowId, this.coordinateInfoNew, ColorShow, defaultDisplayTime).ShowRegion()
        RegionMap := BaseRegionMap(windowId, this.coordinateInfoNew, xMinBorderInterval, yMinBorderInterval)
        BorderRegionMap := RegionMap.GetBorderRegionMap()
        RegionMap := RegionMap.GetRegionMap()
        RegionMapArray := [RegionMap, BorderRegionMap]
        return RegionMapArray
    }

    __BaseInfo() {
        RegionMapArray := this.GetRegionMap()
        this.RegionMap := RegionMapArray[1]
        this.BorderRegionMap := RegionMapArray[2]
        LeftBottomCorner := this.BorderRegionMap["LeftBottomCorner"]
        RightTopCorner := this.BorderRegionMap["RightTopCorner"]
        CenterRegion := this.RegionMap["CenterRegion"]
        CenterRegion := [this.xStart, CenterRegion[2], this.xEnd, CenterRegion[4]]
        CenterRegion := NormalizeRect(CenterRegion)
        this.CenterRegion := CenterRegion
        this.LeftBottomCorner := LeftBottomCorner
        this.RightTopCorner := RightTopCorner
        RegionArray := [LeftBottomCorner, RightTopCorner, CenterRegion]
        return RegionArray
    }

    LeftBottomCornerPercentageResult() {
        this.__BaseInfo()
        LeftBottomCorner := this.LeftBottomCorner
        windowId := this.windowId
        colorIndexArray := this.colorIndexArray
        ModeNum := this.ModeNum
        summaryMode := this.SummaryMode
        ; ColorShow := "0xFF0000" ; 绿色显示左上角区域
        ; WindowColorRegion(windowId, LeftBottomCorner, ColorShow, defaultDisplayTime * 0.5).ShowRegion()
        colorCoordinatesAreaCollector := GetColorCoordinatesArea(windowId, LeftBottomCorner, colorIndexArray, ModeNum, summaryMode)
        colorCoordinatesArea := colorCoordinatesAreaCollector.GetMaxMinAreas()
        colorPercentageArray := colorCoordinatesAreaCollector.colorPercentage()
        ShowDebugMessage("LeftBottomCornerPercentageResult: `r`n" ConvertArrayToString(colorPercentageArray), , "T1")
        return colorPercentageArray
    }

    RightTopCornerPercentageResult() {
        this.__BaseInfo()
        RightTopCorner := this.RightTopCorner
        windowId := this.windowId
        colorIndexArray := this.colorIndexArray
        ModeNum := this.ModeNum
        summaryMode := this.SummaryMode
        ; ColorShow := "0x0000FF" ; 红色显示右下角区域
        ; WindowColorRegion(windowId, RightTopCorner, ColorShow, defaultDisplayTime * 0.5).ShowRegion()
        colorCoordinatesAreaCollector := GetColorCoordinatesArea(windowId, RightTopCorner, colorIndexArray, ModeNum, summaryMode)
        colorCoordinatesArea := colorCoordinatesAreaCollector.GetMaxMinAreas()
        colorPercentageArray := colorCoordinatesAreaCollector.colorPercentage()
        ShowDebugMessage("RightTopCornerPercentageResult: `r`n" ConvertArrayToString(colorPercentageArray), , "T1")
        return colorPercentageArray
    }

    GetRightTopCorner() {
        colorPercentageArray := this.RightTopCornerPercentageResult()
        RightTopCorner := this.RightTopCorner
        x1Max := this.coordinateInfo[1]
        x2Max := this.coordinateInfo[3]
        y2Max := this.coordinateInfo[4]
        if (this.RightTopResultValidation.Length != colorPercentageArray.Length) {
            MsgBox("TotalRegion 类的参数 RightTopResultValidation 格式不正确，无法继续执行。", , "错误提示")
        }
        loop this.RightTopResultValidation.Length {
            expectedValues := this.RightTopResultValidation[A_Index]
            expectedValuesMin := expectedValues[1]
            expectedValuesMax := expectedValues[2]
            actualValues := colorPercentageArray[A_Index]
            if (actualValues[1] >= expectedValuesMin[1] and actualValues[2] >= expectedValuesMin[2] and actualValues[3] >= expectedValuesMin[3] and actualValues[1] <= expectedValuesMax[1] and actualValues[2] <= expectedValuesMax[2] and actualValues[3] <= expectedValuesMax[3]) {
                this.RightTopCornerLoop := true
                y1Max := RightTopCorner[2]
                this.RightTopCornerFinal := [x1Max, y1Max, x2Max, y2Max]
                break
            } else {
                this.RightTopCornerLoop := false
                y1Max := RightTopCorner[4]
                this.RightTopCornerFinal := [x1Max, y1Max, x2Max, y2Max]
            }
        }
        return this.RightTopCornerFinal
    }

    GetLeftBottomCorner() {
        colorPercentageArray := this.LeftBottomCornerPercentageResult()
        LeftBottomCorner := this.LeftBottomCorner
        x1Min := this.coordinateInfo[1]
        x2Min := this.coordinateInfo[3]
        y1Min := this.coordinateInfo[2]
        if (this.LeftBottomResultValidation.Length != colorPercentageArray.Length) {
            MsgBox("TotalRegion 类的参数 LeftBottomResultValidation 格式不正确，无法继续执行。", , "错误提示")
        }
        loop this.LeftBottomResultValidation.Length {
            expectedValues := this.LeftBottomResultValidation[A_Index]
            expectedValuesMin := expectedValues[1]
            expectedValuesMax := expectedValues[2]
            actualValues := colorPercentageArray[A_Index]
            if (actualValues[1] >= expectedValuesMin[1] and actualValues[2] >= expectedValuesMin[2] and actualValues[3] >= expectedValuesMin[3] and actualValues[1] <= expectedValuesMax[1] and actualValues[2] <= expectedValuesMax[2] and actualValues[3] <= expectedValuesMax[3]) {
                this.LeftBottomCornerLoop := true
                y2Min := LeftBottomCorner[4]
                this.LeftBottomCornerFinal := [x1Min, y1Min, x2Min, y2Min]
                break
            } else {
                this.LeftBottomCornerLoop := false
                y2Min := LeftBottomCorner[2]
                this.LeftBottomCornerFinal := [x1Min, y1Min, x2Min, y2Min]
            }
        }
        return this.LeftBottomCornerFinal
    }

    loopBreakValidation() {
        if (this.LeftBottomCornerLoop = true and this.RightTopCornerLoop = true) {
            return true
        } else {
            ShowDebugMessage("需要继续循环检测区域。`nLeftBottomCornerLoop: " . this.LeftBottomCornerLoop . "`nRightTopCornerLoop: " . this.RightTopCornerLoop, , "T1")
            if (this.LeftBottomCornerLoop = false and this.RightTopCornerLoop = true) {
                this.LeftBottomCornerFinal := this.GetLeftBottomCorner()
            } else if (this.LeftBottomCornerLoop = true and this.RightTopCornerLoop = false) {
                this.RightTopCornerFinal := this.GetRightTopCorner()
            } else {
                this.LeftBottomCornerFinal := this.GetLeftBottomCorner()
                this.RightTopCornerFinal := this.GetRightTopCorner()
            }
            return false
        }
    }

    AreaFinalInfo() {
        this.loopBreakValidation()
        loop {
            ShowDebugMessage("开始第 " . (this.loopBreakCount + 1) . " 次循环检测区域。", , "T1")
            this.loopBreakCount += 1
            loopBreak := this.loopBreakValidation()
            ShowDebugMessage("LeftBottomCornerLoop: " . this.LeftBottomCornerLoop . "`nRightTopCornerLoop: " . this.RightTopCornerLoop . "`nloopBreak: " . loopBreak, , "T1")
            if (loopBreak = true) {
                finalCoordinateInfo := [this.LeftBottomCornerFinal[1], this.LeftBottomCornerFinal[4], this.RightTopCornerFinal[3], this.RightTopCornerFinal[2]]
                finalCoordinateInfo := NormalizeRect(finalCoordinateInfo)
                return finalCoordinateInfo
            } else {
                finalCoordinateInfo := [this.LeftBottomCornerFinal[1], this.LeftBottomCornerFinal[4], this.RightTopCornerFinal[3], this.RightTopCornerFinal[2]]
                this.coordinateInfoNew := NormalizeRect(finalCoordinateInfo)
                ShowDebugMessage("新的区域坐标为：" . this.coordinateInfo[1] . ", " . this.coordinateInfo[2] . ", " . this.coordinateInfo[3] . ", " . this.coordinateInfo[4], , "T1")
                continue
            }
        }
    }
}


class TotalRegionTopCenterBottomCenter {
    __New(windowId, coordinateInfo, borderIntervalX, borderIntervalY, colorIndexArray, ModeNum, SummaryMode, TopCenterResultValidation, BottomCenterResultValidation) {
        this.windowId := windowId
        windowInfo := SafeActivateWindow(windowId, "Client")
        this.xStart := windowInfo[2]
        this.yStart := windowInfo[3]
        this.xEnd := windowInfo[4]
        this.yEnd := windowInfo[5]
        this.coordinateInfo := coordinateInfo
        this.coordinateInfoNew := []
        this.borderIntervalX := borderIntervalX
        this.borderIntervalY := borderIntervalY
        this.colorIndexArray := colorIndexArray
        this.ModeNum := ModeNum
        this.SummaryMode := SummaryMode
        this.TopCenterResultValidation := TopCenterResultValidation
        this.BottomCenterResultValidation := BottomCenterResultValidation
        this.TopCenterLoop := false
        this.BottomCenterLoop := false
        this.RegionMapArray := []
        this.TopCenter := []
        this.BottomCenter := []
        this.CenterRegion := []
        this.loopBreakCount := 0
    }

    DataValueValidation() {
        TopCenterResultValidation := this.TopCenterResultValidation
        BottomCenterResultValidation := this.BottomCenterResultValidation
        colorIndexArray := this.colorIndexArray
        if (Type(TopCenterResultValidation) != "Array" or Type(BottomCenterResultValidation) != "Array") {
            return false
        } else {
            if (TopCenterResultValidation.Length != colorIndexArray.Length or BottomCenterResultValidation.Length != colorIndexArray.Length) {
                return false
            } else {
                loop colorIndexArray.Length {
                    TopCenterResultValidationOne := TopCenterResultValidation[A_Index]
                    BottomCenterResultValidationOne := BottomCenterResultValidation[A_Index]
                    if (Type(TopCenterResultValidationOne) != "Array" or TopCenterResultValidationOne.Length != 2 or Type(BottomCenterResultValidationOne) != "Array" or BottomCenterResultValidationOne.Length != 2) {
                        return false
                    } else {
                        loop TopCenterResultValidationOne.Length {
                            if (Type(TopCenterResultValidationOne[A_Index]) != "Array" or TopCenterResultValidationOne[A_Index].Length != 3) {
                                return false
                            } else {
                                loop TopCenterResultValidationOne.Length {
                                    ItemOne := TopCenterResultValidationOne[A_Index]
                                    if (Type(ItemOne) != "Array" or ItemOne.Length != 3) {
                                        return false
                                    } else {
                                        if (IsNumber(ItemOne[1]) = false or IsNumber(ItemOne[2]) = false or IsNumber(ItemOne[3]) = false) {
                                            return false
                                        }
                                    }
                                }
                            }
                        }
                        loop BottomCenterResultValidationOne.Length {
                            if (Type(BottomCenterResultValidationOne[A_Index]) != "Array" or BottomCenterResultValidationOne[A_Index].Length != 3) {
                                return false
                            } else {
                                loop BottomCenterResultValidationOne.Length {
                                    ItemTwo := BottomCenterResultValidationOne[A_Index]
                                    if (Type(ItemTwo) != "Array" or ItemTwo.Length != 3) {
                                        return false
                                    } else {
                                        if (IsNumber(ItemTwo[1]) = false or IsNumber(ItemTwo[2]) = false or IsNumber(ItemTwo[3]) = false) {
                                            return false
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            return true
        }
    }

    GetRegionMap() {
        DataValueValidationResult := this.DataValueValidation()
        if (DataValueValidationResult = false) {
            MsgBox("TotalRegion 类的参数 TopCenterResultValidation 或 BottomCenterResultValidation 格式不正确，无法继续执行。", , "错误提示")
        }
        windowId := this.windowId
        x1 := this.xStart
        x2 := this.xEnd
        if (this.loopBreakCount > 100) {
            MsgBox("TotalRegion 类在获取区域映射时循环次数过多，可能存在无法满足验证条件的情况，程序终止以防死循环。", , "错误提示")
            ExitApp
        } else {
            if (this.loopBreakCount > 0) {
                this.coordinateInfo := this.coordinateInfoNew
            } else {
                this.coordinateInfo := this.coordinateInfo
            }
        }
        coordinateInfo := this.coordinateInfo
        borderIntervalX := this.borderIntervalX
        borderIntervalY := this.borderIntervalY
        colorIndexArray := this.colorIndexArray
        ModeNum := this.ModeNum
        summaryMode := this.SummaryMode
        colorCoordinatesAreaCollector := GetColorCoordinatesArea(windowId, coordinateInfo, colorIndexArray, ModeNum, summaryMode)
        colorCoordinatesArea := colorCoordinatesAreaCollector.GetMaxMinAreas()
        colorPercentageArray := colorCoordinatesAreaCollector.colorPercentage()
        MaxArea := colorCoordinatesArea[1]
        MinArea := colorCoordinatesArea[2]
        MaxArea := [x1, MaxArea[2], x2, MaxArea[4]]
        MinArea := [x1, MinArea[2], x2, MinArea[4]]
        MaxArea := NormalizeRect(MaxArea)
        MinArea := NormalizeRect(MinArea)
        ; 验证左上角结果
        Area := [MaxArea, MinArea]
        this.coordinateInfoNew := ColorCoordinateAreaSummary(Area, "Correct-Silent").MinArea()
        ; ColorShow := "0xFF00FF" ; 蓝色显示当前区域
        ; WindowColorRegion(windowId, this.coordinateInfoNew, ColorShow, defaultDisplayTime).ShowRegion()
        RegionMap := BaseRegionMap(windowId, this.coordinateInfoNew, xMinBorderInterval, yMinBorderInterval)
        BorderRegionMap := RegionMap.GetBorderRegionMap()
        RegionMap := RegionMap.GetRegionMap()
        RegionMapArray := [RegionMap, BorderRegionMap]
        return RegionMapArray
    }

    __BaseInfo() {
        RegionMapArray := this.GetRegionMap()
        this.RegionMap := RegionMapArray[1]
        this.BorderRegionMap := RegionMapArray[2]
        TopCenter := this.BorderRegionMap["TopCenter"]
        BottomCenter := this.BorderRegionMap["BottomCenter"]
        CenterRegion := this.RegionMap["CenterRegion"]
        CenterRegion := [this.xStart, CenterRegion[2], this.xEnd, CenterRegion[4]]
        CenterRegion := NormalizeRect(CenterRegion)
        this.CenterRegion := CenterRegion
        this.TopCenter := TopCenter
        this.BottomCenter := BottomCenter
        RegionArray := [TopCenter, BottomCenter, CenterRegion]
        return RegionArray
    }

    TopCenterPercentageResult() {
        this.__BaseInfo()
        TopCenter := this.TopCenter
        windowId := this.windowId
        colorIndexArray := this.colorIndexArray
        ModeNum := this.ModeNum
        summaryMode := this.SummaryMode
        ; ColorShow := "0xFF0000" ; 绿色显示左上角区域
        ; WindowColorRegion(windowId, TopCenter, ColorShow, defaultDisplayTime * 0.5).ShowRegion()
        colorCoordinatesAreaCollector := GetColorCoordinatesArea(windowId, TopCenter, colorIndexArray, ModeNum, summaryMode)
        colorCoordinatesArea := colorCoordinatesAreaCollector.GetMaxMinAreas()
        colorPercentageArray := colorCoordinatesAreaCollector.colorPercentage()
        ShowDebugMessage("TopCenterPercentageResult: `r`n" ConvertArrayToString(colorPercentageArray), , "T1")
        return colorPercentageArray
    }

    BottomCenterPercentageResult() {
        this.__BaseInfo()
        BottomCenter := this.BottomCenter
        windowId := this.windowId
        colorIndexArray := this.colorIndexArray
        ModeNum := this.ModeNum
        summaryMode := this.SummaryMode
        ; ColorShow := "0x0000FF" ; 红色显示右下角区域
        ; WindowColorRegion(windowId, BottomCenter, ColorShow, defaultDisplayTime * 0.5).ShowRegion()
        colorCoordinatesAreaCollector := GetColorCoordinatesArea(windowId, BottomCenter, colorIndexArray, ModeNum, summaryMode)
        colorCoordinatesArea := colorCoordinatesAreaCollector.GetMaxMinAreas()
        colorPercentageArray := colorCoordinatesAreaCollector.colorPercentage()
        ShowDebugMessage("BottomCenterPercentageResult: `r`n" ConvertArrayToString(colorPercentageArray), , "T1")
        return colorPercentageArray
    }

    GetBottomCenter() {
        colorPercentageArray := this.BottomCenterPercentageResult()
        BottomCenter := this.BottomCenter
        x1Max := this.coordinateInfo[1]
        x2Max := this.coordinateInfo[3]
        y2Max := this.coordinateInfo[4]
        if (this.BottomCenterResultValidation.Length != colorPercentageArray.Length) {
            MsgBox("TotalRegion 类的参数 BottomCenterResultValidation 格式不正确，无法继续执行。", , "错误提示")
        }
        loop this.BottomCenterResultValidation.Length {
            expectedValues := this.BottomCenterResultValidation[A_Index]
            expectedValuesMin := expectedValues[1]
            expectedValuesMax := expectedValues[2]
            actualValues := colorPercentageArray[A_Index]
            if (actualValues[1] >= expectedValuesMin[1] and actualValues[2] >= expectedValuesMin[2] and actualValues[3] >= expectedValuesMin[3] and actualValues[1] <= expectedValuesMax[1] and actualValues[2] <= expectedValuesMax[2] and actualValues[3] <= expectedValuesMax[3]) {
                this.BottomCenterLoop := true
                y1Max := BottomCenter[4]
                this.BottomCenterFinal := [x1Max, y1Max, x2Max, y2Max]
                break
            } else {
                this.BottomCenterLoop := false
                y1Max := BottomCenter[2]
                this.BottomCenterFinal := [x1Max, y1Max, x2Max, y2Max]
            }
        }
        return this.BottomCenterFinal
    }

    GetTopCenter() {
        colorPercentageArray := this.TopCenterPercentageResult()
        TopCenter := this.TopCenter
        x1Min := this.coordinateInfo[1]
        x2Min := this.coordinateInfo[3]
        y1Min := this.coordinateInfo[2]
        if (this.TopCenterResultValidation.Length != colorPercentageArray.Length) {
            MsgBox("TotalRegion 类的参数 TopCenterResultValidation 格式不正确，无法继续执行。", , "错误提示")
        }
        loop this.TopCenterResultValidation.Length {
            expectedValues := this.TopCenterResultValidation[A_Index]
            expectedValuesMin := expectedValues[1]
            expectedValuesMax := expectedValues[2]
            actualValues := colorPercentageArray[A_Index]
            if (actualValues[1] >= expectedValuesMin[1] and actualValues[2] >= expectedValuesMin[2] and actualValues[3] >= expectedValuesMin[3] and actualValues[1] <= expectedValuesMax[1] and actualValues[2] <= expectedValuesMax[2] and actualValues[3] <= expectedValuesMax[3]) {
                this.TopCenterLoop := true
                y2Min := TopCenter[2]
                this.TopCenterFinal := [x1Min, y1Min, x2Min, y2Min]
                break
            } else {
                this.TopCenterLoop := false
                y2Min := TopCenter[4]
                this.TopCenterFinal := [x1Min, y1Min, x2Min, y2Min]
            }
        }
        return this.TopCenterFinal
    }

    loopBreakValidation() {
        if (this.TopCenterLoop = true and this.BottomCenterLoop = true) {
            return true
        } else {
            ShowDebugMessage("需要继续循环检测区域。`nTopCenterLoop: " . this.TopCenterLoop . "`nBottomCenterLoop: " . this.BottomCenterLoop, , "T1")
            if (this.TopCenterLoop = false and this.BottomCenterLoop = true) {
                this.TopCenterFinal := this.GetTopCenter()
            } else if (this.TopCenterLoop = true and this.BottomCenterLoop = false) {
                this.BottomCenterFinal := this.GetBottomCenter()
            } else {
                this.TopCenterFinal := this.GetTopCenter()
                this.BottomCenterFinal := this.GetBottomCenter()
            }
            return false
        }
    }

    AreaFinalInfo() {
        this.loopBreakValidation()
        loop {
            ShowDebugMessage("开始第 " . (this.loopBreakCount + 1) . " 次循环检测区域。", , "T1")
            this.loopBreakCount += 1
            loopBreak := this.loopBreakValidation()
            ShowDebugMessage("TopCenterLoop: " . this.TopCenterLoop . "`nBottomCenterLoop: " . this.BottomCenterLoop . "`nloopBreak: " . loopBreak, , "T1")
            if (loopBreak = true) {
                finalCoordinateInfo := [this.TopCenterFinal[1], this.TopCenterFinal[4], this.BottomCenterFinal[3], this.BottomCenterFinal[2]]
                finalCoordinateInfo := NormalizeRect(finalCoordinateInfo)
                return finalCoordinateInfo
            } else {
                finalCoordinateInfo := [this.TopCenterFinal[1], this.TopCenterFinal[4], this.BottomCenterFinal[3], this.BottomCenterFinal[2]]
                this.coordinateInfoNew := NormalizeRect(finalCoordinateInfo)
                ShowDebugMessage("新的区域坐标为：" . this.coordinateInfo[1] . ", " . this.coordinateInfo[2] . ", " . this.coordinateInfo[3] . ", " . this.coordinateInfo[4], , "T1")
                continue
            }
        }
    }
}

 