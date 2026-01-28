; ===== 工程版 (Engineering Version) =====
; 特点：集成 GDI+ 内存截图技术 (DllCallPixelGetRsult)，大幅提升在大范围颜色扫描时的性能，适合生产环境使用。
; ======================================
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
    return true
}
; 兼容多次点击的原始实现
OS_Click_orig(btn, times) {
    Loop times {
        Click(btn)
    }
    return true
}


; Forward remaining params variadically while keeping first two ByRef
; 将 ByRef 输出直接传给 PixelSearch
OS_PixelSearch_orig(&outX, &outY, args*) {
    return PixelSearch(&outX, &outY, args*)
}

; 激活目标窗口
OS_WinActivate_orig(winId) {
    WinActivate(winId)
    return true
}
; Forward any combination of params to WinMove
; 保持参数灵活性的 WinMove 包装
OS_WinMove_orig(params*) {
    WinMove(params*)
    return true
}
; Keep first four ByRef, forward the rest
; 输出窗口位置与尺寸
OS_WinGetPos_orig(&x, &y, &w, &h, params*) {
    WinGetPos(&x, &y, &w, &h, params*)
    return true
}
; 设置鼠标/像素等的坐标模式
OS_CoordMode_orig(type, mode) {
    CoordMode(type, mode)
    return true
}
; ControlClick 的透传包装
OS_ControlClick_orig(params*) {
    ControlClick(params*)
    return true
}
; 调用 AHK 原生图像搜索
OS_ImageSearch_orig(&outX, &outY, args*) {
    return ImageSearch(&outX, &outY, args*)
}
; 发送按键序列
OS_Send_orig(keys) {
    Send(keys)
    return true
}
; 等待指定按键释放或超时
OS_KeyWait_orig(key, opts) {
    if (opts = "")
        KeyWait(key)
    else
        KeyWait(key, opts)
    return true
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
        MsgBox("ExitApp", , "T2")
    }
    ExitApp
}

; ========================= 全局配置区域 ==========================
; 用于描述外部程序与自动化流程所需的全局对象
; 程序启动配置，Map 中键为描述，值为 [exe 路径, 参数, 标签]
global g_programConfig := Map(
    "终端程序01", ["C:\\Program Files\\WindowsApps\\Microsoft.WindowsTerminal_1.23.12811.0_x64__8wekyb3d8bbwe\\wt.exe", '-p "Windows PowerShell"' "`t" "Windows PowerShell"],
    ; "终端程序02", ["C:\\Program Files\\WindowsApps\\Microsoft.WindowsTerminal_1.23.12811.0_x64__8wekyb3d8bbwe\\wt.exe", '-p "命令提示符"' "`t" "命令提示符"],
    ; "三方截图工具", ["C:\\Program Files\\ShareX\\ShareX.exe", "" "`t" "ShareX"],
    "OCR工具", ["D:\\Umi-OCR_Paddle_v2.1.5\\Umi-OCR.exe", "" "`t" "Umi-OCR"]
)

; [全局配置] 终端程序启动映射
; 终端窗口快捷映射
global g_terminalMap := Map(
    "Windows PowerShell", g_programConfig["终端程序01"],
    ; "命令提示符", g_programConfig["终端程序02"]
)

; 常用外部程序的快捷变量，便于后续引用
; global g_screenshotTool := g_programConfig["三方截图工具"]
global g_ocrTool := g_programConfig["OCR工具"]
global g_Terminal01 := g_terminalMap["Windows PowerShell"]
; global g_Terminal02 := g_terminalMap["命令提示符"]
; [全局配置] 外部应用程序启动映射
; ======================================================================================================
; 外部程序启动列表，按照执行顺序存储 exe 和参数
global g_exeMap := [
    { exe: g_Terminal01[1], param: g_Terminal01[2] }, 
    ; { exe: g_screenshotTool[1], param: g_screenshotTool[2] }, 
    { exe: g_ocrTool[1], param: g_ocrTool[2] }
    ; { exe: g_Terminal02[1], param: g_Terminal02[2] }
]

; ========================= 窗口与操作参数 ==========================
global loopPatternConfig := Map(
    "maxScreenNumber", 500,
    "maxFolderSize", 70000
)


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
    "mouseRandomFiveClicks", 4,
    "defaultSleepTime", 10,
    "defaultDisplayTime", 500,
)

; ========================= 鼠标与点击参数 ==========================
; 鼠标事件相关延迟配置
global g_mouseConfig := Map(
    "mouseLock", false,
    "clickSleepTime", 100,
    "dragSleepTime", 100,
    "wheelSleepTime", 100
)

; ========================= 调试与提示参数 ==========================
; 调试提示与声音反馈配置
global g_debugConfig := Map(
    "debugMode", false,
    "debugMsgTimeT0.5", "T0.5",
    "debugMsgTimeT1", "T1",
    "debugMsgTimeT2", "T2",
    "debugMsgTimeT5", "T5",
    "debugMsgTimeT10", "T10",
    "debugSleepTime", 100,
    "debugSleepTimeDivisions", 1,
    "beepFrequency", 523,
    "beepDuration", 2000,
    "soundVolume", 60,
    "timeMsgBox", 3,
    "colorOffset", 16 ** 5 * 8, ; 颜色容差偏移值
    "defaultTransparent", 240,
    "overlay", true,
    "debugModeBreak", false
)

; ========================= 参数映射赋值部分 ==========================
global g_LoopBreakMap := Map(
    "continue", 0,
    "break", 1,
    "AreaCountLimit01", 5
)

; ========================= 应用与分割参数 ==========================
; 图像或区域划分相关的配置
global g_splitConfig := Map(
    "colorOffset", 16 ** 5 * 8, ; 颜色容差偏移值
    "modMin", 4, ; 最小单元长度单位, 也是单元格间隔基准
    "xCoarseAndFine01", 1, ; 横向粗细分割比例，宽度倍数
    "yCoarseAndFine01", 1, ; 纵向粗细分割比例，高度倍数
    "xCoarseAndFine02", 2, ; 横向粗细分割比例，宽度倍数
    "yCoarseAndFine02", 2, ; 纵向粗细分割比例，高度倍数
    "xCoarseAndFine03", 3, ; 横向粗细分割比例，宽度倍数
    "yCoarseAndFine03", 3, ; 纵向粗细分割比例，高度倍数
    "xCoarseAndFine04", 4, ; 横向粗细分割比例，宽度倍数
    "yCoarseAndFine04", 4, ; 纵向粗细分割比例，高度倍数
    "xMinOffset", 15, ; 横向最小偏移
    "yMinOffset", 15, ; 纵向最小偏移
    "xDivisions", 3, ; 横向分割数量，计算得出
    "yDivisions", 20,  ; 纵向分割数量，计算得出
    "DataWidthMin", 160 ; 数据区域最小宽度
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
    "dashedColor01", ["0xE5E5E5", 3],
    "dashedColor02", ["0xEAEAEA", 3],
    "dashedColor03", ["0xF5F5F5", 3],
    "dashedColor04", ["0xFAFAFA", 3],
    "betMultiplierColor", ["0xE1E1E1", 0],
    "saveButtonColor", ["0xD0021B", 0],
    "OCRBackgroundColor", ["0x0C0C0C", 0],
    "OCRFontColor", ["0xCCCCCC", 0],
    "OCRAppAlertRed", ["0xFF0000", 3],
    "OCRAppRecognizeGreen", ["0xB6D9B6", 10]
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
    "保存按钮颜色", "saveButtonColor",
    "OCR背景颜色", "OCRBackgroundColor",
    "OCR字体颜色", "OCRFontColor",
    "OCR应用提示红色", "OCRAppAlertRed",
    "OCR应用识别绿色", "OCRAppRecognizeGreen"
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
    "16", "保存按钮颜色",
    "17", "OCR背景颜色",
    "18", "OCR字体颜色",
    "19", "OCR应用提示红色",
    "20", "OCR应用识别绿色"    
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
debugMsgTimeT10 := g_debugConfig["debugMsgTimeT10"]
debugMsgTimeT5 := g_debugConfig["debugMsgTimeT5"]
debugMsgTimeT2 := g_debugConfig["debugMsgTimeT2"]
debugMsgTimeT1 := g_debugConfig["debugMsgTimeT1"]
debugMsgTimeT0 := g_debugConfig["debugMsgTimeT0.5"]
debugSleepTime := g_debugConfig["debugSleepTime"]
debugModeBreak := g_debugConfig["debugModeBreak"]

soundVolume := g_debugConfig["soundVolume"]
beepFrequency := g_debugConfig["beepFrequency"]
beepDuration := g_debugConfig["beepDuration"]
timeMsgBox := g_debugConfig["timeMsgBox"]
colorOffset := g_debugConfig["colorOffset"]
AreaCountLimit01 := g_LoopBreakMap["AreaCountLimit01"]

; 读取分割配置中的常用字段，便于后续直接使用
modMin := g_splitConfig["modMin"]
xMinOffset := g_splitConfig["xMinOffset"]
yMinOffset := g_splitConfig["yMinOffset"]
DataWidthMin := g_splitConfig["DataWidthMin"]

; 将常用配置缓存为局部全局变量，便于频繁使用
minWindowWidth := g_windowConfig["minWindowWidth"]
minWindowHeight := g_windowConfig["minWindowHeight"]
windowArrangementXMultiplier := g_windowConfig["windowArrangementXMultiplier"]
windowArrangementYMultiplier := g_windowConfig["windowArrangementYMultiplier"]
mouseRandomFiveClicks := g_windowConfig["mouseRandomFiveClicks"]
defaultTransparent := g_debugConfig["defaultTransparent"]
overlay := g_debugConfig["overlay"]

maxScreenNumber := loopPatternConfig["maxScreenNumber"]
maxFolderSize := loopPatternConfig["maxFolderSize"]
; ========================= 参数导入结束 ==========================

; ========================= 十六进制到十进制映射 ==========================
; 16 进制字符到十进制数值的查找表
global g_hexToDecimalMap := Map(
    "0", 0, "1", 1, "2", 2, "3", 3, "4", 4, "5", 5,
    "6", 6, "7", 7, "8", 8, "9", 9, "A", 10, "B", 11,
    "C", 12, "D", 13, "E", 14, "F", 15
)

global g_decimalToHexMap := Map(
    0, "0", 1, "1", 2, "2", 3, "3", 4, "4", 5, "5",
    6, "6", 7, "7", 8, "8", 9, "9", 10, "A", 11, "B",
    12, "C", 13, "D", 14, "E", 15, "F"
)

; 将十进制颜色数值转换为 0xRRGGBB 格式
ConvertNumToRGB(num) {
    ; 将映射表转为数组，方便按索引取值
    num := Round(Abs(Number(num)), 0)
    ; 初始化结果字符串
    if (num > Number(0xFFFFFF)) {
        num := Mod(num, Number("0x1000000"))  ; 超出范围取模
    }
    hexList := "0x"
    loop 6 {
        if (Mod(6 - A_Index, 2) = 1) {
            ; 奇数位跳过，只处理偶数位拼接
            continue
        } else {
            Divisionpart := Floor((6 - A_Index) / 2)
        }
        ; 每两位计算一次对应的高低位字符
        ; 每两位计算一次对应的高低位字符
        devisor := (16 ** 2) ** (Divisionpart)
        numNew := Mod(num, devisor)
        quotient := Floor(num / devisor)
        FirstString := g_decimalToHexMap[quotient // 16]
        SecondString := g_decimalToHexMap[Mod(quotient, 16)]
        hexList := hexList . FirstString . SecondString
        num := numNew
    }
    return hexList
}

; 将十进制颜色数值转换为 0xRRGGBB 格式
ConvertNumToARGB(num) {
    ; 将映射表转为数组，方便按索引取值
    num := Round(Abs(Number(num)), 0)
    hexList := "0x"
    loop 8 {
        if (Mod(8 - A_Index, 2) = 1) {
            ; 奇数位跳过，只处理偶数位拼接
            continue
        } else {
            Divisionpart := Floor((8 - A_Index) / 2)
        }
        ; 每两位计算一次对应的高低位字符
        ; 每两位计算一次对应的高低位字符
        devisor := (16 ** 2) ** (Divisionpart)
        numNew := Mod(num, devisor)
        quotient := Floor(num / devisor)
        FirstString := g_decimalToHexMap[quotient // 16]
        SecondString := g_decimalToHexMap[Mod(quotient, 16)]
        hexList := hexList . FirstString . SecondString
        num := numNew
    }
    return hexList
}

; 将 0xRRGGBB 颜色转换为 [R,G,B] 数组
ConvertHexToRGB(hexColor) {
    ; 去掉前缀后按照两个字符解析 R/G/B
    suffix := "0x"
    if (SubStr(hexColor, 1, StrLen(suffix)) = suffix && RegExMatch(hexColor, "^0x[A-Fa-f0-9]{6}$") and StrLen(hexColor) = 8) {
        hexColor := SubStr(hexColor, StrLen(suffix) + 1, StrLen(hexColor) - StrLen(suffix))
    } else if (RegExMatch(hexColor, "^..[A-Fa-f0-9]{6}$") and SubStr(hexColor, 1, 2) != "0x" and StrLen(hexColor) = 8) {
        ; 前两位是任意字符，后面是6位十六进制
        hexColor := SubStr(hexColor, StrLen(suffix) + 1, StrLen(hexColor) - StrLen(suffix))
    } else {
        MsgBox("Error: 颜色值格式错误，必须为0xRRGGBB或##RRGGBB格式。", , "T2")
        return [false, false, false]
    }

    suffix := SubStr(hexColor, 1, 2)
    hexColor := StrReplace(suffix, "0x", "")
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
        MsgBox("Error: ColorConvertNewColor函数的参数Color必须是有效的十六进制数字。", , "T2")
    }
    ; 根据偏移量生成新的颜色值
    newColor := ConvertNumToRGB(Mod((Floor(Number(Color) / 16 ** 4) * 16 ** 4 + colorOffset), 16 ** 6))
    return newColor
}

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
        timeout := g_debugConfig["debugMsgTimeT1"]
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

GetFilteredWindowIds(appName, filterClass, exclude := false) {
    filteredIds := []
    allIds := WinGetList(appName)
    for id in allIds {
        id := allIds[A_Index] + 0
        windowClass := WinGetClass("ahk_id " . id)
        classMatch := (windowClass = filterClass or InStr(windowClass, filterClass) > 0 or InStr(filterClass, windowClass) > 0)
        if (exclude != classMatch) {
            filteredIds.Push(id)
        }
    }
    return filteredIds
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
    __New(targetAppName, filterClass, minWidth := 5, minHeight := 5) {
        this.targetAppName := targetAppName
        this.filterClass := filterClass
        this.minWidth := minWidth
        this.minHeight := minHeight
        this.windowIds := []
        this.windowIds := GetFilteredWindowIds(targetAppName, filterClass)
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
                    MsgBox("窗口ID " hwnd " 属于进程PID " pid, , "T2")
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
                MsgBox("已启动进程：" exePath "`n窗口标题包含：" winTitle "`n窗口ID：" windowId, , "T2")
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
            MsgBox("Error: 可用分区区域数量不足以安置所有窗口。", , "T2")
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
        MsgBox("Error: SafeActivateWindow函数的参数windowId必须是有效的窗口ID。", , "T2")
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
                    MsgBox("Error: SafeActivateWindow函数的coordinateMode参数必须是'Client'或'Screen'。", , "T2")
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

MoveAndClickLoop(ClickArea, NumClicks, defaultSleepTime) {
    ; 移动到目标位置后执行多次点击
    xRange := Round(Abs(ClickArea[3] - ClickArea[1]) / 4, 0)
    yRange := Round(Abs(ClickArea[4] - ClickArea[2]) / 4, 0)
    xClick := Round((ClickArea[1] + ClickArea[3]) / 2, 0) + Round(xRange * Random(-1, 1), 0)
    yClick := Round((ClickArea[2] + ClickArea[4]) / 2, 0) + Round(yRange * Random(-1, 1), 0)
    PointInfoXY := [xClick, yClick]
    SafeMouseMove(xClick, yClick)
    Sleep(defaultSleepTime)
    loop NumClicks {
        OS_Click()
        Sleep(defaultSleepTime)
    }
}

IsValidNumber(value) {
    if (Type(value) != "String" && Type(value) != "Number" && Type(value) != "Float" && Type(value) != "Integer" && Type(value) != "Double" && Type(value) != "Int64") {
        MsgBox("Error: IsValidNumber函数的参数必须是字符串或数字类型。", , "T2")
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
        MsgBox("Error: SortArrayDescending函数的参数必须是数组类型。", , "T2")
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
        MsgBox("Error: SortArrayDescending函数的参数必须是数组类型。", , "T2")
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
        MsgBox("Error: ReplaceAllSubstrings函数需要一个包含三个元素的数组作为参数。", , "T2")
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
        MsgBox("Error: ReplaceAllSubstrings函数返回值不是字符串。", , "T2")
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

UniqueArray(arr) {
    result := []
    seen := Map()
    for _, v in arr {
        if !seen.Has(v) {
            result.Push(v)
            seen[v] := true
        }
    }
    return result
}

ProcessModuloBorder(numberModArray, arrayCount := 2) {
    ; 验证输入参数格式
    if (Type(numberModArray) != "Array" or numberModArray.Length != arrayCount) {
        MsgBox("Error: ProcessModuloBorder函数需要一个包含" arrayCount "个元素的数组作为参数。", , "T2")
        return []
    }

    ; 提取总数量和模数
    totalNumber := numberModArray[1] + 0     ; 总数量（如：100）
    moduloNumber := numberModArray[2] + 0     ; 模数（如：30）

    ; 验证参数是否为有效数字
    if (!IsValidNumber(totalNumber) or !IsValidNumber(moduloNumber)) {
        MsgBox("Error: ProcessModuloBorder函数的参数必须是数字类型。", , "T2")
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
        MsgBox("生成矩阵分割map结构的最外层数据结构不正确。", , "T2")
        ExitApp
    }
    loop CoordinateInfo.Length {
        if (IsNumber(CoordinateInfo[A_Index]) = false) {
            MsgBox("生成矩阵分割PointXYInfo的元素数据不全为数字。`r`n" "请检查第" A_Index "个数据", , "T2")
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

SplitOneDirection(distance) {
    modMap := Map()
    distance := distance - Mod(distance, 2) ; 保证为偶数

    Loop { ; A_Index 从 1 开始
        cellStep := 2 ** (A_Index)
        if (distance < cellStep * 2)
            break

        cellNum := Floor(distance / cellStep)
        modRest := Mod(distance, cellStep)

        if (Round(modRest / cellStep, 2) * 100 >= 50)
            cellNum += 2
        else
            cellNum += 1

        ; 去除两侧对称毛边
        cellNum := cellNum - 2
        if (cellNum <= 0) {
            if (cellNum = 0) {
                cellNum := 1
            } else {
                cellNum := 0
            }
        } else if (cellNum = 1) {

        } else {
            continue
        }


        cellTotal := cellStep * cellNum
        modRestTotal := distance - cellTotal
        modRestStart := Floor(modRestTotal / 2)

        startStep := [0, modRestStart]
        endStep := [modRestStart + cellTotal, distance]

        key := cellStep "，" cellNum "，" startStep[2] "，" endStep[1]
        stepArray := []

        stepArray.Push(startStep)
        Loop (cellNum) {
            si := A_Index
            stepStart := modRestStart + (si - 1) * cellStep
            stepEnd := modRestStart + si * cellStep
            stepArray.Push([stepStart, stepEnd])
        }
        stepArray.Push(endStep)

        modMap[key] := stepArray
    }
    return modMap
}

; 根据缩放比例调整坐标
AdjustCoordinates(Num) {
    hDC := DllCall("GetDC", "ptr", 0, "ptr")
    dpi := DllCall("GetDeviceCaps", "ptr", hDC, "int", 88) ; 88 = LOGPIXELSX
    DllCall("ReleaseDC", "ptr", 0, "ptr", hDC)
    scale := dpi / 96.0 ; 96 DPI corresponds to 100% scaling
    adjustedNum := Round(Num / scale, 0)
    return adjustedNum
}

WaitForFile(path, timeout := 3500) {
    start := A_TickCount
    while (A_TickCount - start < timeout) {
        if (FileExist(path)) {
            size1 := FileGetSize(path)
            Sleep(100)
            size2 := FileGetSize(path)
            if (size1 = size2 && size1 > 0)
                return true
        }
        Sleep(100)
    }
    return false
}


class DllCallPixelGetRsult {
    __New(windowId, coordinateInfo, CoordModeStr := A_CoordModePixel) {
        this.windowId := windowId
        Horizontal := coordinateInfo[3] - coordinateInfo[1]
        Vertical := coordinateInfo[4] - coordinateInfo[2]
        this.DirectionMode := [Horizontal, Vertical]
        coordinateInfo := NormalizeRect(coordinateInfo)
        this.xStart := coordinateInfo[1]
        this.yStart := coordinateInfo[2]
        width := coordinateInfo[3] - coordinateInfo[1] + 1
        height := coordinateInfo[4] - coordinateInfo[2] + 1
        this.width := width
        this.height := height
        this.keyArray := []
        this.pixels := []
        this.xKeyIndexUnique := []
        this.yKeyIndexUnique := []
        this.xCoord := 0
        this.yCoord := 0
        this.offsetX := 0
        this.offsetY := 0
        this.xScreen := 0
        this.yScreen := 0
    }

    DataValidation() {
        if (!IsNumber(this.xStart) || !IsNumber(this.yStart) || !IsNumber(this.width) || !IsNumber(this.height)) {
            MsgBox("Error: DllCallPixelGetColor类的坐标和尺寸参数必须是数字类型。", , "T2")
            return false
        }
        if (this.width <= 0 || this.height <= 0) {
            MsgBox("Error: DllCallPixelGetColor类的宽度和高度参数必须大于0。", , "T2")
            return false
        }
        return true
    }

    DirectionValidation() {
        if (this.DirectionMode[1] > 0 && this.DirectionMode[2] > 0) {
            this.scanDirection := [1, 1]  ; 同时水平和垂直扫描
        } else if (this.DirectionMode[1] > 0 && this.DirectionMode[2] = 0) {
            this.scanDirection := [1, 0]  ; 仅水平扫描
        } else if (this.DirectionMode[1] > 0 && this.DirectionMode[2] < 0) {
            this.scanDirection := [1, -1]  ; 仅垂直扫描
        } else if (this.DirectionMode[1] = 0 && this.DirectionMode[2] > 0) {
            this.scanDirection := [0, 1]  ; 仅垂直扫描
        } else if (this.DirectionMode[1] = 0 && this.DirectionMode[2] = 0) {
            this.scanDirection := [0, 0]  ; 不扫描
        } else if (this.DirectionMode[1] = 0 && this.DirectionMode[2] < 0) {
            this.scanDirection := [0, -1]  ; 仅水平扫描（反向）
        } else if (this.DirectionMode[1] < 0 && this.DirectionMode[2] > 0) {
            this.scanDirection := [-1, 1]  ; 仅垂直扫描（反向）
        } else if (this.DirectionMode[1] < 0 && this.DirectionMode[2] = 0) {
            this.scanDirection := [-1, 0]  ; 仅水平扫描（反向）
        } else if (this.DirectionMode[1] < 0 && this.DirectionMode[2] < 0) {
            this.scanDirection := [-1, -1]  ; 同时水平和垂直扫描（反向）
        } else {
            MsgBox("Error: DllCallPixelGetColor类的扫描方向参数无效。", , "T2")
            return false
        }
        return true
    }

    PixelGetColor() {
        ; 数据验证
        if (!this.DataValidation() or !this.DirectionValidation()) {
            return false
        }
        xStart := this.xStart
        yStart := this.yStart
        Width := this.width
        Height := this.height
        ; 确保宽高至少为1
        if (Width < 1)
            Width := 1
        if (Height < 1)
            Height := 1

        xStart := Floor(xStart)
        yStart := Floor(yStart)
        Width := Floor(Width)
        Height := Floor(Height)

        if (A_CoordModePixel = "Client") {
            WinGetClientPos(&clientX, &clientY, &clientWidth, &clientHeight, "ahk_id " . this.windowId)
            offsetX := clientX
            offsetY := clientY
        } else if (A_CoordModePixel = "Window") {
            WinGetPos(&winX, &winY, &winWidth, &winHeight, "ahk_id " . this.windowId)
            offsetX := winX
            offsetY := winY
        } else if (A_CoordModePixel = "Screen") {
            ; 直接使用屏幕坐标，无需调整
            offsetX := 0
            offsetY := 0
        } else {
            ShowDebugMessage("Error: DllCallPixelGetColor类的坐标模式必须是'Screen'、'Client'或'Window'。", , "T2")
        }

        xScreen := xStart + offsetX
        yScreen := yStart + offsetY
        this.xScreen := xScreen
        this.yScreen := yScreen
        Width := this.width
        height := this.height
        if (Width < 1)
            Width := 1
        if (Height < 1)
            Height := 1
        Width := Floor(Width)
        Height := Floor(Height)
        this.Width := Width
        this.Height := Height

        ; 获取屏幕 HDC
        hdc := DllCall("GetDC", "ptr", 0, "ptr")
        memDC := DllCall("CreateCompatibleDC", "ptr", hdc, "ptr")

        ; 创建 BITMAPINFOHEADER 缓冲区
        bi := Buffer(40, 0)
        NumPut("uint", 40, bi, 0)      ; biSize
        NumPut("int", this.Width, bi, 4)        ; biWidth
        NumPut("int", -this.Height, bi, 8)       ; biHeight (负数表示自顶向下)
        NumPut("ushort", 1, bi, 12)    ; biPlanes
        NumPut("ushort", 32, bi, 14)   ; biBitCount
        NumPut("uint", 0, bi, 16)      ; biCompression

        pBits := 0
        hbm := DllCall("CreateDIBSection", "ptr", memDC, "ptr", bi, "uint", 0, "ptr*", &pBits, "ptr", 0, "uint", 0)
        DllCall("SelectObject", "ptr", memDC, "ptr", hbm)

        ; 一次性拷贝整个区域
        DllCall("BitBlt"
            , "ptr", memDC
            , "int", 0, "int", 0
            , "int", this.Width, "int", this.Height
            , "ptr", hdc
            , "int", this.xScreen, "int", this.yScreen
            , "uint", 0x00CC0020)

        if (A_CoordModePixel = "Client") {
            WinGetClientPos(&clientX, &clientY, &clientWidth, &clientHeight, "ahk_id " . this.windowId)
            this.xCoord := this.xScreen - clientX
            this.yCoord := this.yScreen - clientY
        } else if (A_CoordModePixel = "Window") {
            WinGetPos(&winX, &winY, &winWidth, &winHeight, "ahk_id " . this.windowId)
            this.xCoord := this.xScreen - winX
            this.yCoord := this.yScreen - winY
        } else if (A_CoordModePixel = "Screen") {
            this.xCoord := this.xScreen
            this.yCoord := this.yScreen
        }

        pixels := [] ; 存储 ARGB，4字节/像素
        keyArray := []
        keyIndex := []
        xKeyIndex := []
        yKeyIndex := []
        keyIndexCount := 0
        loop Height {
            yIndex := A_Index
            currentY := this.yCoord + yIndex - 1
            loop Width {
                xIndex := A_Index
                currentX := this.xCoord + xIndex - 1
                offset := ((xIndex - 1) + (yIndex - 1) * Width) * 4
                color := NumGet(pBits, offset, "uint") ; 包含 ARGB
                pixels.Push(color)
                key := currentX . "," . currentY
                keyIndexCount += 1
                keyArray.Push(key)
                xKeyIndex.Push(currentX)
                yKeyIndex.Push(currentY)
            }
        }

        this.pixels := pixels

        ; 释放资源
        DllCall("DeleteObject", "ptr", hbm)
        DllCall("DeleteDC", "ptr", memDC)
        DllCall("ReleaseDC", "ptr", 0, "ptr", hdc)
        return [this.xCoord, this.yCoord, pixels]
    }

    GetAreaColorInfoMap() {
        this.PixelGetColor()
        AreaColorInfoMap := Map()
        xCoord := this.xCoord
        yCoord := this.yCoord
        Width := this.Width
        Height := this.Height
        pixels := this.pixels
        xStart := xCoord
        yStart := yCoord
        xEnd := xCoord + Width - 1
        yEnd := yCoord + Height - 1
        AreaInfo := [xStart, yStart, xEnd, yEnd]
        AreaColorInfoMap["xStart"] := xStart
        AreaColorInfoMap["yStart"] := yStart
        AreaColorInfoMap["xEnd"] := xEnd
        AreaColorInfoMap["yEnd"] := yEnd
        AreaColorInfoMap["Area"] := AreaInfo
        AreaColorInfoMap["width"] := width
        AreaColorInfoMap["height"] := height
        AreaColorInfoMap["Pixels"] := Pixels
        return AreaColorInfoMap
    }
}

; 类定义：WindowColorRegion
; 窗口颜色区域高亮显示类
; 用于调试时高亮显示窗口内的指定颜色区域
; windowId - 目标窗口的句柄 ID
; colorCoordinatesClientInfo - 颜色区域的客户区坐标 [x1, y1, x2, y2]
; color - 高亮显示的颜色值（十六进制 RGB 格式，如 0xFF0000 表示红色）
; defaultDisplayTime - 高亮显示的默认持续时间（毫秒）
class WindowColorRegion {
    __New(windowId, colorCoordinatesClientInfo, color, defaultDisplayTime, defaultTransparent, overlay) {
        this.windowId := windowId
        this.windowInfo := SafeActivateWindow(this.windowId, "Client")
        this.colorCoordinatesClientInfo := colorCoordinatesClientInfo
        this.color := color
        this.defaultDisplayTime := defaultDisplayTime
        this.defaultTransparent := defaultTransparent ; 透明度 0~255
        this.overlay := overlay         ; 是否覆盖（置顶）
        this.xStart := this.colorCoordinatesClientInfo[1]
        this.yStart := this.colorCoordinatesClientInfo[2]
        this.width := Abs(this.colorCoordinatesClientInfo[3] - this.colorCoordinatesClientInfo[1])
        this.height := Abs(this.colorCoordinatesClientInfo[4] - this.colorCoordinatesClientInfo[2])
    }

    GetScreenCoordinates() {
        xStart := this.xStart
        yStart := this.yStart
        Width := AdjustCoordinates(this.width)
        Height := AdjustCoordinates(this.height)
        ; 确保宽高至少为1
        if (Width < 1)
            Width := 1
        if (Height < 1)
            Height := 1

        xStart := Floor(xStart)
        yStart := Floor(yStart)
        Width := Floor(Width)
        Height := Floor(Height)

        if (A_CoordModePixel = "Client") {
            WinGetClientPos(&clientX, &clientY, &clientWidth, &clientHeight, "ahk_id " . this.windowId)
            offsetX := clientX
            offsetY := clientY
        } else if (A_CoordModePixel = "Window") {
            WinGetPos(&winX, &winY, &winWidth, &winHeight, "ahk_id " . this.windowId)
            offsetX := winX
            offsetY := winY
        } else if (A_CoordModePixel = "Screen") {
            ; 直接使用屏幕坐标，无需调整
            offsetX := 0
            offsetY := 0
        } else {
            ShowDebugMessage("Error: DllCallPixelGetColor类的坐标模式必须是'Screen'、'Client'或'Window'。", , "T2")
        }

        xScreen := xStart + offsetX
        yScreen := yStart + offsetY
        this.xScreen := xScreen
        this.yScreen := yScreen
        this.Width := Width
        this.Height := Height
        return [this.xScreen, this.yScreen, this.xScreen + this.Width, this.yScreen + this.Height]
    }

    UpdateCoordinates() {
        ; 重新激活窗口，防止坐标漂移
        SafeActivateWindow(this.windowId, "Client")
        ScreenCoordinates := this.GetScreenCoordinates()
        ; 转换为屏幕坐标，方便 GUI 高亮显示
        this.x1Gui := ScreenCoordinates[1]
        this.y1Gui := ScreenCoordinates[2]
        this.x2Gui := ScreenCoordinates[3]
        this.y2Gui := ScreenCoordinates[4]
        ; 返回窗口屏幕坐标信息
        winScreenLocationArray := [this.windowInfo, this.x1Gui, this.y1Gui, this.x2Gui, this.y2Gui]
        return winScreenLocationArray
    }

    ShowRegion() {
        this.UpdateCoordinates()
        opts := "+ToolWindow -Caption"
        if (this.overlay)
            opts .= " +AlwaysOnTop"
        opts .= " +E0x20" ; 支持透明点击穿透
        colorFrame := Gui(opts)
        colorFrame.BackColor := this.color
        colorFrame.Show("x" Min(this.x1Gui, this.x2Gui) " y" Min(this.y1Gui, this.y2Gui) " w" (Max(this.x1Gui, this.x2Gui) - Min(this.x1Gui, this.x2Gui)) " h" (Max(this.y1Gui, this.y2Gui) - Min(this.y1Gui, this.y2Gui)))
        WinSetTransparent(this.defaultTransparent, colorFrame.Hwnd) ; 透明度 0~255
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
        this.windowInfo := SafeActivateWindow(this.windowId, "Client")
        this.screenshotCoordinatesClientInfo := screenshotCoordinatesClientInfo
        this.savePath := savePath
        this.GeneratePath()
        ; ↓ 统一字段大小写
        this.xStart := this.screenshotCoordinatesClientInfo[1]
        this.yStart := this.screenshotCoordinatesClientInfo[2]
        this.Width := Abs(this.screenshotCoordinatesClientInfo[3] - this.screenshotCoordinatesClientInfo[1])
        this.Height := Abs(this.screenshotCoordinatesClientInfo[4] - this.screenshotCoordinatesClientInfo[2])
    }

    GetScreenCoordinates() {
        xStart := Floor(this.xStart)
        yStart := Floor(this.yStart)

        Width := Floor(AdjustCoordinates(this.Width))
        Height := Floor(AdjustCoordinates(this.Height))

        if (Width < 1)
            Width := 1
        if (Height < 1)
            Height := 1

        if (A_CoordModePixel = "Client") {
            WinGetClientPos(&cx, &cy, &cw, &ch, "ahk_id " . this.windowId)
            offsetX := cx, offsetY := cy
        } else if (A_CoordModePixel = "Window") {
            WinGetPos(&wx, &wy, &ww, &wh, "ahk_id " . this.windowId)
            offsetX := wx, offsetY := wy
        } else if (A_CoordModePixel = "Screen") {
            offsetX := 0, offsetY := 0
        } else {
            ShowDebugMessage("坐标模式必须是 Screen/Client/Window", , "T2")
            return [-1, -1, -1, -1]
        }

        this.xScreen := xStart + offsetX
        this.yScreen := yStart + offsetY
        this.Width := Width
        this.Height := Height

        return [this.xScreen, this.yScreen, this.xScreen + Width, this.yScreen + Height]
    }

    UpdateCoordinates() {
        SafeActivateWindow(this.windowId, "Client")
        ScreenCoordinates := this.GetScreenCoordinates()

        this.x1Gui := ScreenCoordinates[1]
        this.y1Gui := ScreenCoordinates[2]
        this.x2Gui := ScreenCoordinates[3]
        this.y2Gui := ScreenCoordinates[4]

        return [this.windowInfo, this.x1Gui, this.y1Gui, this.x2Gui, this.y2Gui]
    }

    GetCurrentTime() {
        return FormatTime(A_Now, "yyyy-MM-dd_HH-mm-ss")
    }

    GeneratePath() {
        savePath := this.savePath
        nowStr := this.GetCurrentTime()
        return [savePath, savePath . "\截图_" . nowStr . ".png"]
    }

    EnsureSavePathExists() {
        try {
            if !DirExist(this.savePath)
                DirCreate(this.savePath)
            return true
        } catch {
            ShowDebugMessage("无法创建目录: " . this.savePath, , "T5")
            return false
        }
    }

    TakeScreenshot() {
        this.UpdateCoordinates()

        if !this.EnsureSavePathExists()
            return false

        filePath := this.GeneratePath()[2]

        x := Min(this.x1Gui, this.x2Gui)
        y := Min(this.y1Gui, this.y2Gui)
        w := Abs(this.x2Gui - this.x1Gui)
        h := Abs(this.y2Gui - this.y1Gui)

        this._GDIPlus_SaveBitmap(x, y, w, h, filePath)

        return Map(
            "Location", [x, y, w, h],
            "filePath", filePath
        )
    }

    ; ===============================
    ;          GDI+   核心
    ; ===============================
    _GDIPlus_SaveBitmap(x, y, w, h, filePath) {
        ; ----------------------------------------------------------
        ; 启动 GDI+
        ; ----------------------------------------------------------
        if !DllCall("GetModuleHandle", "str", "gdiplus", "ptr")
            DllCall("LoadLibrary", "str", "gdiplus", "ptr")

        sizeSI := (A_PtrSize = 8 ? 24 : 16)
        si := Buffer(sizeSI, 0)
        NumPut("uint", 1, si, 0)
        NumPut("ptr", 0, si, 4)

        global gdipToken := 0
        status := DllCall("gdiplus\GdiplusStartup"
            , "ptr*", &gdipToken
            , "ptr", si
            , "ptr", 0)

        if (status != 0 || gdipToken = 0) {
            MsgBox("GDI+ 启动失败，状态: " status)
            ExitApp
        }

        ; ----------------------------------------------------------
        ; PNG CLSID
        ; ----------------------------------------------------------
        clsidPng := Buffer(16, 0)
        NumPut("uint", 0x557CF406, clsidPng, 0)
        NumPut("ushort", 0x1A04, clsidPng, 4)
        NumPut("ushort", 0x11D3, clsidPng, 6)
        NumPut("uchar", 0x9A, clsidPng, 8)
        NumPut("uchar", 0x73, clsidPng, 9)
        NumPut("uchar", 0x00, clsidPng, 10)
        NumPut("uchar", 0x00, clsidPng, 11)
        NumPut("uchar", 0xF8, clsidPng, 12)
        NumPut("uchar", 0x1E, clsidPng, 13)
        NumPut("uchar", 0xF3, clsidPng, 14)
        NumPut("uchar", 0x2E, clsidPng, 15)

        ; ----------------------------------------------------------
        ; BITMAPINFOHEADER
        ; ----------------------------------------------------------
        bi := Buffer(40, 0)
        NumPut("uint", 40, bi, 0)
        NumPut("int", w, bi, 4)
        NumPut("int", -h, bi, 8)
        NumPut("ushort", 1, bi, 12)
        NumPut("ushort", 32, bi, 14)
        ; ----------------------------------------------------------
        ; 主循环
        ; ----------------------------------------------------------

        try {
            ; --- 获取 DC ---
            hdcScreen := DllCall("GetDC", "ptr", 0, "ptr")
            hdcMem := DllCall("CreateCompatibleDC", "ptr", hdcScreen, "ptr")

            ; --- 建立 DIBSection ---
            pBits := 0
            hbm := DllCall("CreateDIBSection"
                , "ptr", hdcMem
                , "ptr", bi
                , "uint", 0
                , "ptr*", &pBits
                , "ptr", 0
                , "uint", 0
                , "ptr")

            obm := DllCall("SelectObject", "ptr", hdcMem, "ptr", hbm, "ptr")

            ; --- 屏幕到内存 DC ---
            DllCall("BitBlt"
                , "ptr", hdcMem
                , "int", 0, "int", 0
                , "int", w, "int", h
                , "ptr", hdcScreen
                , "int", x, "int", y
                , "uint", 0x00CC0020)

            ; --- GDI+ Bitmap ---
            pBitmap := 0
            DllCall("gdiplus\GdipCreateBitmapFromHBITMAP"
                , "ptr", hbm
                , "ptr", 0
                , "ptr*", &pBitmap)

            ; =============================
            ; ★ 新增：每一帧都保存 PNG
            ; =============================
            savePath := filePath

            DllCall("gdiplus\GdipSaveImageToFile"
                , "ptr", pBitmap
                , "wstr", savePath
                , "ptr", clsidPng
                , "ptr", 0)

            ; --- 释放句柄 ---
            DllCall("gdiplus\GdipDisposeImage", "ptr", pBitmap)
            DllCall("SelectObject", "ptr", hdcMem, "ptr", obm)
            DllCall("DeleteObject", "ptr", hbm)
            DllCall("DeleteDC", "ptr", hdcMem)
            DllCall("ReleaseDC", "ptr", 0, "ptr", hdcScreen)
        } catch {
            MsgBox("截图过程中出现错误。", , "T2")
        }
        ; ----------------------------------------------------------
        ; GDI+ 关闭
        ; ----------------------------------------------------------
        DllCall("gdiplus\GdiplusShutdown", "ptr", gdipToken)
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
        this.numDivisionInfo := this.Calculate()
        this.basicInfo := this.Basic()
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
            this.numDivisionInfo := numDivisionInfo
            return this.numDivisionInfo
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
            this.numDivisionInfo := numDivisionInfo
            return this.numDivisionInfo
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
                this.numDivisionInfo := numDivisionInfo
                return this.numDivisionInfo
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
                this.numDivisionInfo := numDivisionInfo
                return this.numDivisionInfo
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
                this.numDivisionInfo := numDivisionInfo
                return this.numDivisionInfo
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
            this.numDivisionInfo := numDivisionInfo
            return this.numDivisionInfo
        }
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

class GenerateMatrixPoint {
    __New(startPoint, endPoint, xModNum, yModNum) {
        this.startPoint := startPoint
        this.endPoint := endPoint
        this.xModNum := xModNum
        this.yModNum := yModNum
        this.DataValidation()
        this.pointCountInfo := []
    }

    DataValidation() {
        if (Type(this.startPoint) != "Array" || Type(this.endPoint) != "Array" || this.startPoint.Length != 2 || this.endPoint.Length != 2) {
            MsgBox("Error: GenerateMatrix类的坐标参数必须是包含两个元素的数组。", , "T2")
            return false
        }
        if (!IsNumber(this.startPoint[1]) || !IsNumber(this.startPoint[2]) || !IsNumber(this.endPoint[1]) || !IsNumber(this.endPoint[2])) {
            MsgBox("Error: GenerateMatrix类的坐标参数必须是数字类型。", , "T2")
            return false
        }
        if (!IsNumber(this.xModNum) || !IsNumber(this.yModNum) || this.xModNum <= 0 || this.yModNum <= 0) {
            MsgBox("Error: GenerateMatrix类的分割数量参数必须是大于0的数字类型。", , "T2")
            return false
        }
        return true
    }

    GenerateCell() {
        ; 数据验证
        if (!this.DataValidation()) {
            return false
        }
        x1 := this.startPoint[1]
        y1 := this.startPoint[2]
        x2 := this.endPoint[1]
        y2 := this.endPoint[2]
        xDistance := x2 - x1
        yDistance := y2 - y1

        xStepCount := Floor(xDistance / this.xModNum)
        yStepCount := Floor(yDistance / this.yModNum)
        return [xStepCount, yStepCount]
    }

    ValidStepCount() {
        stepCountArray := this.GenerateCell()
        if (stepCountArray[1] = 0) {
            if (this.startPoint[1] = this.endPoint[1]) {
                xStepCount := 1
            } else {
                xStepCount := 2
            }
        }
        if (stepCountArray[2] = 0) {
            if (this.startPoint[2] = this.endPoint[2]) {
                yStepCount := 1
            } else {
                yStepCount := 2
            }
        }
        if (stepCountArray[1] > 0) {
            xStepCount := stepCountArray[1]
        }
        if (stepCountArray[2] > 0) {
            yStepCount := stepCountArray[2]
        }

        xPointCount := xStepCount + 1
        yPointCount := yStepCount + 1
        this.pointCountInfo := [xPointCount, yPointCount]
        return this.pointCountInfo
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
        this.outsideBorderInfo := this.OutsideBorder()
    }

    OutsideBorder() {
        coordinateInfo := this.coordinateInfo
        xStart := coordinateInfo[1]
        yStart := coordinateInfo[2]
        xEnd := coordinateInfo[3]
        yEnd := coordinateInfo[4]
        outsideBorderInfo := [xStart, yStart, xEnd, yEnd]

        xPointInstance := GetBorderMod(xStart, xEnd, this.xModNum)
        yPointInstance := GetBorderMod(yStart, yEnd, this.yModNum)

        xStartInfo := xPointInstance.Start()
        yStartInfo := yPointInstance.Start()
        xEndInfo := xPointInstance.End()
        yEndInfo := yPointInstance.End()
        xCenterInfo := xPointInstance.Center()
        yCenterInfo := yPointInstance.Center()

        outsideBorderInfo := [xStartInfo, yStartInfo, xEndInfo, yEndInfo, xCenterInfo, yCenterInfo]
        this.outsideBorderInfo := outsideBorderInfo
        return this.outsideBorderInfo
    }

    TopRegion() {
        coordinateInfo := this.coordinateInfo
        Region := this.outsideBorderInfo
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
        Region := this.outsideBorderInfo
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
        Region := this.outsideBorderInfo
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
        Region := this.outsideBorderInfo
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
        coordinateInfo := this.coordinateInfo
        Region := this.outsideBorderInfo
        xCenterInfo := Region[5]
        yCenterInfo := Region[6]
        xStart := xCenterInfo[1]
        yStart := yCenterInfo[1]
        xEnd := xCenterInfo[2]
        yEnd := yCenterInfo[2]
        centerRegionInfo := [xStart, yStart, xEnd, yEnd]
        this.centerRegionInfo := centerRegionInfo
        return this.centerRegionInfo
    }


    XcellArray() {
        coordinateInfo := this.coordinateInfo
        xStart := coordinateInfo[1]
        xEnd := coordinateInfo[3]

        xPointInstance := GetBorderMod(xStart, xEnd, this.xModNum)
        xCellInfo := xPointInstance.generateCellArray()
        this.xCellInfo := xCellInfo
        return this.xCellInfo
    }

    YcellArray() {
        coordinateInfo := this.coordinateInfo
        yStart := coordinateInfo[2]
        yEnd := coordinateInfo[4]

        yPointInstance := GetBorderMod(yStart, yEnd, this.yModNum)
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

    GetRegionMapKeyList() {
        regionMap := this.GetRegionMap()
        keyList := []
        for key, value in regionMap {
            keyList.Push(key)
        }
        return keyList
    }

    GetBorderRegionMapKeyList() {
        borderRegionMap := this.GetBorderRegionMap()
        keyList := []
        for key, value in borderRegionMap {
            keyList.Push(key)
        }
        return keyList
    }

    GetTotalRegionMap() {
        regionMapKey := this.GetRegionMapKeyList()
        borderRegionMapKey := this.GetBorderRegionMapKeyList()
        regionMap := this.GetRegionMap()
        borderRegionMap := this.GetBorderRegionMap()
        TotalRegionMap := Map()
        TotalRegionMap["RegionMap"] := [regionMapKey, regionMap]
        TotalRegionMap["BorderRegionMap"] := [borderRegionMapKey, borderRegionMap]
        return TotalRegionMap
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
    __New(windowId, coordinateInfo, xModNum, yModNum) {
        this.windowId := windowId
        SafeActivateWindow(this.windowId, A_CoordModePixel)
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
        this.rectangleMap := Map()
    }

    DataValidation() {
        coordinateInfo := this.coordinateInfo
        coordinateInfo := NormalizeRect(coordinateInfo)
        x1 := coordinateInfo[1]
        y1 := coordinateInfo[2]
        x2 := coordinateInfo[3]
        y2 := coordinateInfo[4]
        this.coordinateInfo := [x1, y1, x2, y2]
        return this.coordinateInfo
    }

    CellMap() {
        this.DataValidation()
        coordinateInfo := this.coordinateInfo
        xStart := coordinateInfo[1]
        yStart := coordinateInfo[2]
        xEnd := coordinateInfo[3]
        yEnd := coordinateInfo[4]

        xPointInstance := GetBorderMod(xStart, xEnd, this.xModNum)
        yPointInstance := GetBorderMod(yStart, yEnd, this.yModNum)

        xCellArray := xPointInstance.generateCellArray()
        yCellArray := yPointInstance.generateCellArray()

        xMap := Map()
        yMap := Map()
        loop xCellArray.Length {
            xIndex := A_Index
            xCellInfo := xCellArray[A_Index]
            xMap[xIndex] := xCellInfo
        }
        loop yCellArray.Length {
            yIndex := A_Index
            yCellInfo := yCellArray[A_Index]
            yMap[yIndex] := yCellInfo
        }

        this.rectangleMapArray := [xMap, yMap]
        return this.rectangleMapArray
    }
}

class GetCellInfo {
    __New(coordinateInfo, PointXYInfo, rectangleMapArray) {
        this.coordinateInfo := coordinateInfo
        this.PointXYInfo := PointXYInfo
        this.rectangleMapArray := rectangleMapArray
    }

    DataValidation() {
        PointXYInfo := this.PointXYInfo
        if (Type(PointXYInfo) != "Array" or PointXYInfo.Length != 2 or (IsNumber(PointXYInfo[1]) = false) or (IsNumber(PointXYInfo[2]) = false) or (PointXYInfo[1] < 0) or (PointXYInfo[2] < 0)) {
            ; 点坐标无效，返回失败标记
            return false
        }
        xPoint := PointXYInfo[1]
        yPoint := PointXYInfo[2]

        coordinateInfo := this.coordinateInfo
        if (Type(coordinateInfo) != "Array" or coordinateInfo.Length != 4 or (IsNumber(coordinateInfo[1]) = false) or (IsNumber(coordinateInfo[2]) = false) or (IsNumber(coordinateInfo[3]) = false) or (IsNumber(coordinateInfo[4]) = false) or (coordinateInfo[1] < 0) or (coordinateInfo[2] < 0) or (coordinateInfo[3] < 0) or (coordinateInfo[4] < 0)) {
            ; 矩形坐标无效，返回失败标记
            return false
        }
        coordinateInfo := NormalizeRect(coordinateInfo)
        x1 := coordinateInfo[1]
        y1 := coordinateInfo[2]
        x2 := coordinateInfo[3]
        y2 := coordinateInfo[4]
        if (xPoint < x1 or xPoint > x2 or yPoint < y1 or yPoint > y2) {
            ; 点坐标超出矩形范围，返回失败标记
            return false
        }

        rectangleMapArray := this.rectangleMapArray
        if (Type(rectangleMapArray) != "Array" or rectangleMapArray.Length != 2) {
            ; 矩形映射无效，返回失败标记
            return false
        }
        xMap := rectangleMapArray[1]
        yMap := rectangleMapArray[2]
        if (Type(xMap) != "Map" or Type(yMap) != "Map") {
            ; 矩形映射无效，返回失败标记
            return false
        }
        for xKey, xValue in xMap {
            if (Type(xValue) != "Array" or xValue.Length != 2 or (IsNumber(xValue[1]) = false) or (IsNumber(xValue[2]) = false) or (xValue[1] < 0) or (xValue[2] < 0) or (xValue[1] < x1) or (xValue[1] > x2) or (xValue[2] < x1) or (xValue[2] > x2)) {
                ; 矩形映射无效，返回失败标记
                return false
            }
        }
        for yKey, yValue in yMap {
            if (Type(yValue) != "Array" or yValue.Length != 2 or (IsNumber(yValue[1]) = false) or (IsNumber(yValue[2]) = false) or (yValue[1] < 0) or (yValue[2] < 0) or (yValue[1] < y1) or (yValue[1] > y2) or (yValue[2] < y1) or (yValue[2] > y2)) {
                ; 矩形映射无效，返回失败标记
                return false
            }
        }

        ; 输入无误时返回 true 供后续流程使用
        return true
    }

    CellInfo() {
        isValid := this.DataValidation()
        if (isValid = false) {
            ; 输入无效，返回失败标记
            return [-1, -1, -1, -1]
        }
        coordinateInfo := this.coordinateInfo
        PointXYInfo := this.PointXYInfo
        rectangleMapArray := this.rectangleMapArray
        xMap := rectangleMapArray[1]
        yMap := rectangleMapArray[2]

        xPoint := PointXYInfo[1]
        yPoint := PointXYInfo[2]
        if (xPoint = -1 and yPoint = -1) {
            ; 点坐标无效，返回失败标记
            return coordinateInfo
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
                    rectangleInfo := [x1Min, y1Min, x2Max, y2Max]
                }
                rectangleInfo := NormalizeRect(rectangleInfo)
                return rectangleInfo
            }
        }
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
; CornerMode 参数用于指定边缘检测的参考角落位置，可选值包括 "TopLeft"、"TopRight"、"BottomLeft"、"BottomRight"。字符串格式。
; colorArray 为全局颜色数组变量，用于获取颜色和容差值。
class EdgeDetectionColor {
    __New(windowId, coordinateInfo, pixels, PointXYInfo, xModNum, yModNum, ColorValidArray, ValidTrueMap, CornerMode, colorArray) {
        this.windowId := windowId
        this.coordinateInfo := coordinateInfo
        this.xStart := coordinateInfo[1]
        this.yStart := coordinateInfo[2]
        this.xEnd := coordinateInfo[3]
        this.yEnd := coordinateInfo[4]
        this.xRange := Abs(this.xEnd - this.xStart)
        this.yRange := Abs(this.yEnd - this.yStart)
        this.pixels := pixels
        this.PointXYInfo := PointXYInfo
        this.xModNum := xModNum
        this.yModNum := yModNum
        this.ColorValidArray := ColorValidArray
        this.ValidTrueMap := ValidTrueMap
        this.colorArray := colorArray
        this.CornerMode := CornerMode
        this.CellInfo := []
        this.CornerInfo := []
        this.loopNum := 0
        this.PointXYHistory := []
        this.CurrentXYHistory := []
        this.paramResult := this.__parameterReconfig()
        this.rectangleMapArray := this.DataBasicGeneration()
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

    DataBasicGeneration() {
        ; 生成基础数据
        windowId := this.windowId
        coordinateInfo := this.coordinateInfo
        xModNum := this.xModNum
        yModNum := this.yModNum
        PointXYInfo := this.PointXYInfo
        ; 坐标映射
        CoordinateMappingInstance := CoordinateMapping(windowId, coordinateInfo, xModNum, yModNum)
        rectangleMapArray := CoordinateMappingInstance.CellMap()
        this.rectangleMapArray := rectangleMapArray
        return this.rectangleMapArray
    }

    __parameterReconfig() {
        ; 获取坐标区域
        CornerMode := this.CornerMode
        if (CornerMode = "TopLeft") {
            this.CornerInfo := [
                this.coordinateInfo[1] + Floor(Abs(this.coordinateInfo[3] - this.coordinateInfo[1]) / 2),
                this.coordinateInfo[2] + Floor(Abs(this.coordinateInfo[4] - this.coordinateInfo[2]) / 2),
                this.coordinateInfo[1],
                this.coordinateInfo[2]
            ]
        } else if (CornerMode = "TopRight") {
            this.CornerInfo := [
                this.coordinateInfo[1] + Floor(Abs(this.coordinateInfo[3] - this.coordinateInfo[1]) / 2),
                this.coordinateInfo[2] + Floor(Abs(this.coordinateInfo[4] - this.coordinateInfo[2]) / 2),
                this.coordinateInfo[3],
                this.coordinateInfo[2]
            ]
        } else if (CornerMode = "BottomLeft") {
            this.CornerInfo := [
                this.coordinateInfo[1] + Floor(Abs(this.coordinateInfo[3] - this.coordinateInfo[1]) / 2),
                this.coordinateInfo[2] + Floor(Abs(this.coordinateInfo[4] - this.coordinateInfo[2]) / 2),
                this.coordinateInfo[1],
                this.coordinateInfo[4]
            ]
        } else if (CornerMode = "BottomRight") {
            this.CornerInfo := [
                this.coordinateInfo[1] + Floor(Abs(this.coordinateInfo[3] - this.coordinateInfo[1]) / 2),
                this.coordinateInfo[2] + Floor(Abs(this.coordinateInfo[4] - this.coordinateInfo[2]) / 2),
                this.coordinateInfo[3],
                this.coordinateInfo[4]
            ]
        } else {
            ; 保持原始坐标不变
            this.CornerInfo := this.coordinateInfo
        }
        x1 := this.CornerInfo[1]
        y1 := this.CornerInfo[2]
        x2 := this.CornerInfo[3]
        y2 := this.CornerInfo[4]
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
        windowId := this.windowId
        pixels := this.pixels
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
        RectangleMapArray := this.rectangleMapArray
        CellInfo := GetCellInfo(coordinateInfo, this.currentPointXY, rectangleMapArray).CellInfo()
        CellX1Y1 := [CellInfo[1], CellInfo[2]]
        CellX2Y2 := [CellInfo[3], CellInfo[4]]
        CellX1Y2 := [CellInfo[1], CellInfo[4]]
        CellX2Y1 := [CellInfo[3], CellInfo[2]]
        this.CellInfo := CellInfo

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
            xPoint := PointInfoXY[1]
            yPoint := PointInfoXY[2]
            offsetX := this.xEnd - this.xStart + 1
            offsetY := this.yEnd - this.yStart + 1
            offset := (xPoint - this.xStart + 1) + (yPoint - this.yStart) * offsetX
            colorPoint := ConvertNumToRGB(pixels[offset])
            ColorCornerAndCenterMap[key] := colorPoint
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
        windowId := this.windowId
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
            x1 := this.CornerInfo[1]
            y1 := this.CornerInfo[2]
            x2 := this.CornerInfo[3]
            y2 := this.CornerInfo[4]
            xOffset := x2 - x1 > 0 ? 1 : -1
            yOffset := y2 - y1 > 0 ? 1 : -1
            xStart := xOffset = 1 ? xMax : xMin
            yStart := yOffset = 1 ? yMax : yMin
            ; 更新坐标点
            this.PointXYInfo := [xStart, yStart]
            this.__parameterReconfig()

            this.currentPointXY := this.PointXYHistory[this.PointXYHistory.Length]
            CellInfo := this.CellInfo
            CellX1Y1 := [CellInfo[1], CellInfo[2]]
            CellX2Y2 := [CellInfo[3], CellInfo[4]]
            CellX1Y2 := [CellInfo[1], CellInfo[4]]
            CellX2Y1 := [CellInfo[3], CellInfo[2]]
            CellCornerArray := [CellX1Y1, CellX2Y1, CellX1Y2, CellX2Y2]

            this.CurrentXYInfo := this.PointXYHistory[this.PointXYHistory.Length]
            ; 检查是否达到停止条件
            if (this.LoopBreak = true) {
                ShowDebugMessage("边缘检测循环结束，返回最终坐标点。", , "T1")
                this.pixels := []
                return this.PointXYInfo
            }
        }
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
    __New(windowId, coordinateInfo, colorIndexArray, colorArray, SummaryMode) {
        this.windowId := windowId
        this.coordinateInfo := coordinateInfo
        this.colorIndexArray := colorIndexArray
        this.colorArray := colorArray
        this.SummaryMode := SummaryMode
        this.colorCoordinatePercentageArray := []
        this.colorCoordinateArray := []
        this.colorPercentageArray := []
    }

    GetColorCoordinates() {
        windowId := this.windowId
        coordinateInfo := this.coordinateInfo
        colorIndexArray := this.colorIndexArray
        colorArray := this.colorArray
        colorCoordinateArray := []
        colorPercentageArray := []
        loop colorIndexArray.Length {
            ColorIndex := colorIndexArray[A_Index]
            Color := colorArray[ColorIndex][3]
            Tolerance := colorArray[ColorIndex][4]
            AreaCornerInfo := CoordinateCornerCollection(windowId, coordinateInfo, Color, Tolerance)
            colorCoordinateArea := AreaCornerInfo.CornerArea() ; 获取颜色坐标区域
            colorCoordinateArray.Push(colorCoordinateArea)
        }
        return colorCoordinateArray
    }

    GetMaxMinAreas() {
        SummaryMode := this.SummaryMode
        this.colorCoordinateArray := this.GetColorCoordinates() ; 填充 colorCoordinateArray
        ; 计算最大和最小区域
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
}

; ========================= 主程序逻辑开始 ==========================
ShowDebugMessage("开始执行数据收集应用程序的启动与排列。")
currentTimeStr := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
time1 := currentTimeStr

; 创建窗口排列管理器并排列所有窗口
filterClass := "ahk_class Chrome_WidgetWin_0"
idArray := GetFilteredWindowIds(targetAppName, filterClass)
windowArrangerScheme := WindowArranger(targetAppName, filterClass, minWindowWidth, minWindowHeight)
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

ShowDebugMessage("开始激活所有第三方应用窗口。")
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
ShowDebugMessage("激活所有第三方应用窗口完毕。")

; ========================= 调试区域 ==========================
ShowDebugMessage("开始查询截图区域。")
windowRegionClickMap := Map()

ShowDebugMessage("截图区域查询完成。")
windowIdAreaMap := Map()
ids := idArray
loop idArray.Length {
    ; 参数准备
    windowId := idArray[A_Index]
    windowInfo := SafeActivateWindow(windowId, "Client")
    windowRegionClickMap[windowId] := Map()
    ; 获取窗口坐标信息
    x1 := windowInfo[2]
    y1 := windowInfo[3]
    x2 := windowInfo[4]
    y2 := windowInfo[5]
    coordinateInfo := [x1, y1, x2, y2]
    windowTotal := coordinateInfo
    ; 颜色配置参数
    modMin := g_splitConfig["modMin"]
    xCoarseAndFine01 := g_splitConfig["xCoarseAndFine01"] * 1.0
    xModNum := Round(modMin * xCoarseAndFine01, 0)
    yCoarseAndFine01 := g_splitConfig["yCoarseAndFine01"] * 1.0
    yModNum := Round(modMin * yCoarseAndFine01, 0)
    colorTarget := [1, 2, 6] ; 目标颜色索引数组
    ; 执行像素矩阵二值化
    PixelMatrixBinarizationInstance := PixelMatrixBinarization(windowId, coordinateInfo, xModNum, yModNum, colorTarget, colorArray)
    PixelsAreaWidthHeight := PixelMatrixBinarizationInstance.GetPixels()
    MartrixInfo := PixelMatrixBinarizationInstance.GetMartrix()
    GetColorIndexRowMap := PixelMatrixBinarizationInstance.GetColorIndexRowMap()
    xLineIndexArray := MartrixInfo[2]
    yLineIndexArray := MartrixInfo[3]
    rowCount := yLineIndexArray.Length - 1
    colCount := xLineIndexArray.Length - 1
    ColorIndexRowMap := GetColorIndexRowMap

    ; 提取指定颜色索引的行数据
    colorIndex := 1 ; 指定颜色索引
    IsValidXYArray := []
    loop rowCount + 1 {
        rowIndex := A_Index
        for key, value in ColorIndexRowMap {
            if (key[1] != colorIndex) {
                continue
            } else {
                if (key[2] != rowIndex) {
                    continue
                } else {
                    IsValidXYArray.Push(value)
                    break
                }
            }
        }
    }

    ; 构建单元格角落坐标数组
    CellCornerArray := []
    TotalCount := rowCount * colCount
    CellTopLeftCornerArray := []
    CellTopRightCornerArray := []
    CellBottomLeftCornerArray := []
    CellBottomRightCornerArray := []
    loop TotalCount {
        rowIndex := Ceil(A_Index / colCount)
        colIndex := A_Index - (rowIndex - 1) * colCount
        x1 := xLineIndexArray[colIndex]
        y1 := yLineIndexArray[rowIndex]
        x2 := xLineIndexArray[colIndex + 1]
        y2 := yLineIndexArray[rowIndex + 1]
        CellArea := [x1, y1, x2, y2]
        ; 计算单元格角落状态值
        TopLeftCorner := IsValidXYArray[rowIndex][colIndex] + 0
        TopRightCorner := IsValidXYArray[rowIndex][colIndex + 1] + 0
        BottomLeftCorner := IsValidXYArray[rowIndex + 1][colIndex] + 0
        BottomRightCorner := IsValidXYArray[rowIndex + 1][colIndex + 1] + 0
        CellCornerOne := TopLeftCorner * 2 + TopRightCorner * 4 + BottomLeftCorner * 8 + BottomRightCorner * 16
        ; 查找符合条件的单元格（状态值为 30）
        if (CellCornerOne = 30) {
            CellCornerArray.Push(CellArea)
        } else {
            continue
        }
    }
    coordinateInfo := ColorCoordinateAreaSummary(CellCornerArray, "Correct-Silent").MaxArea()
    coordinateInfo := NormalizeRect(coordinateInfo)
    ColorShow := "0xFF0000"
    WindowColorRegion(windowId, coordinateInfo, ColorShow, defaultDisplayTime * 1, defaultTransparent, overlay).ShowRegion()
    TotalArea := coordinateInfo
    windowIdAreaMap[windowId] := Map()
    windowIdAreaMap[windowId]["TotalArea"] := TotalArea

    ; 提取指定颜色索引的行数据
    colorIndex := 2 ; 指定颜色索引
    IsValidXYArray := []
    loop rowCount + 1 {
        rowIndex := A_Index
        for key, value in ColorIndexRowMap {
            if (key[1] != colorIndex) {
                continue
            } else {
                if (key[2] != rowIndex) {
                    continue
                } else {
                    IsValidXYArray.Push(value)
                    break
                }
            }
        }
    }

    ; 构建单元格角落坐标数组
    CellCornerArray := []
    TotalCount := rowCount * colCount
    CellTopLeftCornerArray := []
    CellTopRightCornerArray := []
    CellBottomLeftCornerArray := []
    CellBottomRightCornerArray := []
    loop TotalCount {
        rowIndex := Ceil(A_Index / colCount)
        colIndex := A_Index - (rowIndex - 1) * colCount
        x1 := xLineIndexArray[colIndex]
        y1 := yLineIndexArray[rowIndex]
        x2 := xLineIndexArray[colIndex + 1]
        y2 := yLineIndexArray[rowIndex + 1]
        if (x1 >= TotalArea[1] and y1 >= TotalArea[2] and x2 <= TotalArea[3] and y2 <= TotalArea[4]) {
            CellArea := [x1, y1, x2, y2]
        } else {
            continue
        }
        ; 计算单元格角落状态值
        TopLeftCorner := IsValidXYArray[rowIndex][colIndex] + 0
        TopRightCorner := IsValidXYArray[rowIndex][colIndex + 1] + 0
        BottomLeftCorner := IsValidXYArray[rowIndex + 1][colIndex] + 0
        BottomRightCorner := IsValidXYArray[rowIndex + 1][colIndex + 1] + 0
        CellCornerOne := TopLeftCorner * 2 + TopRightCorner * 4 + BottomLeftCorner * 8 + BottomRightCorner * 16
        ; 查找符合条件的单元格（状态值为 30）
        if (CellCornerOne = 30) {
            CellCornerArray.Push(CellArea)
        } else {
            continue
        }
    }
    coordinateInfo := ColorCoordinateAreaSummary(CellCornerArray, "Correct-Silent").MaxArea()
    coordinateInfo := NormalizeRect(coordinateInfo)
    ColorShow := "0x00FF00"
    WindowColorRegion(windowId, coordinateInfo, ColorShow, defaultDisplayTime * 1, defaultTransparent, overlay).ShowRegion()
    WhiteGroundArea := coordinateInfo

    ; ========================= 分隔区域颜色定位 ==========================
    ShowDebugMessage("开始执行分隔区域颜色定位。")
    ; 提取指定颜色索引的行数据
    colorIndex := 3 ; 指定颜色索引
    IsValidXYArray := []
    loop rowCount + 1 {
        rowIndex := A_Index
        for key, value in ColorIndexRowMap {
            if (key[1] != colorIndex) {
                continue
            } else {
                if (key[2] != rowIndex) {
                    continue
                } else {
                    IsValidXYArray.Push(value)
                    break
                }
            }
        }
    }

    ; 构建单元格角落坐标数组
    CellCornerArray := []
    TotalCount := rowCount * colCount
    CellTopLeftCornerArray := []
    CellTopRightCornerArray := []
    CellBottomLeftCornerArray := []
    CellBottomRightCornerArray := []
    loop TotalCount {
        rowIndex := Ceil(A_Index / colCount)
        colIndex := A_Index - (rowIndex - 1) * colCount
        x1 := xLineIndexArray[colIndex]
        y1 := yLineIndexArray[rowIndex]
        x2 := xLineIndexArray[colIndex + 1]
        y2 := yLineIndexArray[rowIndex + 1]
        if (x1 >= TotalArea[1] and y1 >= TotalArea[2] and x2 <= TotalArea[3] and y2 <= TotalArea[4]) {
            CellArea := [x1, y1, x2, y2]
        } else {
            continue
        }
        CellArea := [x1, y1, x2, y2]
        ; 计算单元格角落状态值
        TopLeftCorner := IsValidXYArray[rowIndex][colIndex] + 0
        TopRightCorner := IsValidXYArray[rowIndex][colIndex + 1] + 0
        BottomLeftCorner := IsValidXYArray[rowIndex + 1][colIndex] + 0
        BottomRightCorner := IsValidXYArray[rowIndex + 1][colIndex + 1] + 0
        CellCornerOne := TopLeftCorner * 2 + TopRightCorner * 4 + BottomLeftCorner * 8 + BottomRightCorner * 16
        ; 查找符合条件的单元格（状态值为 30）
        if (CellCornerOne = 30) {
            CellCornerArray.Push(CellArea)
        } else {
            continue
        }
    }
    coordinateInfo := ColorCoordinateAreaSummary(CellCornerArray, "Correct-Silent").MaxArea()
    coordinateInfo := NormalizeRect(coordinateInfo)
    ColorShow := "0x0000FF"
    WindowColorRegion(windowId, coordinateInfo, ColorShow, defaultDisplayTime * 1, defaultTransparent, overlay).ShowRegion()
    SeparatorArea := coordinateInfo

    ; ========================= 数据区域颜色定位 ==========================
    ShowDebugMessage("开始执行数据区域颜色定位。")
    TotalDataArea := [TotalArea[1], SeparatorArea[4], TotalArea[3], TotalArea[4]]
    ; 数据区域颜色定位
    coordinateInfo := TotalDataArea
    colorIndexArray := [7, 8, 9, 10]
    SummaryMode := "Correct-Silent"
    ClickClearButtomInstance := ClickClearButtom(windowId, coordinateInfo, xModNum, yModNum, colorIndexArray, colorArray, SummaryMode)
    ClickClearButtomInstance.ClickClearArea()
    ShowDebugMessage("清除数据操作已完成。")

    ; ========================= 随机区域颜色定位 ==========================
    ShowDebugMessage("开始执行随机区域颜色定位。")
    ; 提取指定颜色索引的行数据
    colorIndex := 1 ; 指定颜色索引
    IsValidXYArray := []
    loop rowCount + 1 {
        rowIndex := A_Index
        for key, value in ColorIndexRowMap {
            if (key[1] != colorIndex) {
                continue
            } else {
                if (key[2] != rowIndex) {
                    continue
                } else {
                    IsValidXYArray.Push(value)
                    break
                }
            }
        }
    }

    ; 构建单元格角落坐标数组
    CellCornerArray := []
    TotalCount := rowCount * colCount
    CellTopLeftCornerArray := []
    CellTopRightCornerArray := []
    CellBottomLeftCornerArray := []
    CellBottomRightCornerArray := []
    loop TotalCount {
        rowIndex := Ceil(A_Index / colCount)
        colIndex := A_Index - (rowIndex - 1) * colCount
        x1 := xLineIndexArray[colIndex]
        y1 := yLineIndexArray[rowIndex]
        x2 := xLineIndexArray[colIndex + 1]
        y2 := yLineIndexArray[rowIndex + 1]
        if (x1 >= TotalArea[1] and y1 >= TotalArea[2] and x2 <= TotalArea[3] and y2 <= SeparatorArea[2]) {
            CellArea := [x1, y1, x2, y2]
        } else {
            continue
        }
        ; 计算单元格角落状态值
        TopLeftCorner := IsValidXYArray[rowIndex][colIndex] + 0
        TopRightCorner := IsValidXYArray[rowIndex][colIndex + 1] + 0
        BottomLeftCorner := IsValidXYArray[rowIndex + 1][colIndex] + 0
        BottomRightCorner := IsValidXYArray[rowIndex + 1][colIndex + 1] + 0
        CellCornerOne := TopLeftCorner * 2 + TopRightCorner * 4 + BottomLeftCorner * 8 + BottomRightCorner * 16
        ; 查找符合条件的单元格（状态值为 30）
        if (CellCornerOne = 30) {
            CellCornerArray.Push(CellArea)
        } else {
            continue
        }
    }
    coordinateInfo := ColorCoordinateAreaSummary(CellCornerArray, "Correct-Silent").MaxArea()
    coordinateInfo := NormalizeRect(coordinateInfo)
    ColorShow := "0xFFFF00"
    WindowColorRegion(windowId, coordinateInfo, ColorShow, defaultDisplayTime * 1, defaultTransparent, overlay).ShowRegion()
    RandomArea := coordinateInfo
    windowIdAreaMap[windowId]["RandomArea"] := RandomArea

    xCoarseAndFine := g_splitConfig["xCoarseAndFine01"] * 2
    yCoarseAndFine := g_splitConfig["yCoarseAndFine01"] * 2
    xModNum := Round(modMin * xCoarseAndFine, 0)
    yModNum := Round(modMin * yCoarseAndFine, 0)
    SummaryMode := "Correct-Silent"
    xClick := Round((coordinateInfo[1] + coordinateInfo[3]) / 2, 0)
    yClick := Round((coordinateInfo[2] + coordinateInfo[4]) / 2, 0)
    PointCenter := [xClick, yClick]
    colorInsideIndex := 2
    colorOutsideIndex := 1
    colorInside := colorArray[colorInsideIndex][3]
    colorInsideTolerance := colorArray[colorInsideIndex][4]
    colorOutside := colorArray[colorOutsideIndex][3]
    colorOutsideTolerance := colorArray[colorOutsideIndex][4]
    ColorValidArray := [[colorInside, colorInsideTolerance], [colorOutside, colorOutsideTolerance]]
    CornerMode := []
    pixels := DllCallPixelGetRsult(windowId, RandomArea).PixelGetColor()[3]
    BorderRegion := GetOutsideBorderRegion(windowId, PointCenter, coordinateInfo, pixels, xModNum, yModNum, colorInside, colorInsideTolerance, colorOutside, colorOutsideTolerance, SummaryMode, CornerMode, colorArray)
    CellArea := BorderRegion.FindOutsideBorderRegion()
    CellArea := [Round(CellArea[1] - xModNum, 0), Round(CellArea[2] - yModNum, 0), Round(CellArea[3] + xModNum, 0), Round(CellArea[4] + yModNum, 0)]
    RandomClickOneArea := CellArea
    coordinateInfo := [RandomClickOneArea[3], RandomClickOneArea[2], RandomArea[3], RandomArea[4]]
    xClick := Round((coordinateInfo[1] + coordinateInfo[3]) / 2, 0)
    yClick := Round((coordinateInfo[2] + coordinateInfo[4]) / 2, 0)
    PointCenter := [xClick, yClick]
    colorInsideIndex := 2
    colorOutsideIndex := 1
    colorInside := colorArray[colorInsideIndex][3]
    colorInsideTolerance := colorArray[colorInsideIndex][4]
    colorOutside := colorArray[colorOutsideIndex][3]
    colorOutsideTolerance := colorArray[colorOutsideIndex][4]
    ColorValidArray := [[colorInside, colorInsideTolerance], [colorOutside, colorOutsideTolerance]]
    CornerMode := []
    coordinateInfo := RandomArea
    pixels := DllCallPixelGetRsult(windowId, coordinateInfo).PixelGetColor()[3]
    BorderRegion := GetOutsideBorderRegion(windowId, PointCenter, coordinateInfo, pixels, xModNum, yModNum, colorInside, colorInsideTolerance, colorOutside, colorOutsideTolerance, SummaryMode, CornerMode, colorArray)
    CellArea := BorderRegion.FindOutsideBorderRegion()
    CellArea := [Round(CellArea[1] - xModNum, 0), Round(CellArea[2] - yModNum, 0), Round(CellArea[3] + xModNum, 0), Round(CellArea[4] + yModNum, 0)]
    RandomClickFiveArea := CellArea

    RandomClickArea := [RandomClickOneArea, RandomClickFiveArea]
    loop RandomClickArea.Length {
        ClickArea := RandomClickArea[A_Index]
        coordinateInfo := ClickArea
        colorTarget := [1, 2] ; 目标颜色索引数组
        xModNum := Round(modMin * xCoarseAndFine01, 0) * 2
        yModNum := Round(modMin * yCoarseAndFine01, 0) * 2
        ; 执行像素矩阵二值化
        PixelMatrixBinarizationInstance := PixelMatrixBinarization(windowId, coordinateInfo, xModNum, yModNum, colorTarget, colorArray)
        PixelsAreaWidthHeight := PixelMatrixBinarizationInstance.GetPixels()
        MartrixInfo := PixelMatrixBinarizationInstance.GetMartrix()
        GetColorIndexRowMap := PixelMatrixBinarizationInstance.GetColorIndexRowMap()
        xLineIndexArray := MartrixInfo[2]
        yLineIndexArray := MartrixInfo[3]
        rowCount := yLineIndexArray.Length - 1
        colCount := xLineIndexArray.Length - 1
        ColorIndexRowMap := GetColorIndexRowMap
        ; 提取指定颜色索引的行数据
        colorIndex := 2 ; 指定颜色索引
        IsValidXYArray := []
        loop rowCount + 1 {
            rowIndex := A_Index
            for key, value in ColorIndexRowMap {
                if (key[1] != colorIndex) {
                    continue
                } else {
                    if (key[2] != rowIndex) {
                        continue
                    } else {
                        IsValidXYArray.Push(value)
                        break
                    }
                }
            }
        }

        ; 构建单元格角落坐标数组
        CellCornerArray := []
        TotalCount := rowCount * colCount
        CellTopLeftCornerArray := []
        CellTopRightCornerArray := []
        CellBottomLeftCornerArray := []
        CellBottomRightCornerArray := []
        loop TotalCount {
            rowIndex := Ceil(A_Index / colCount)
            colIndex := A_Index - (rowIndex - 1) * colCount
            x1 := xLineIndexArray[colIndex]
            y1 := yLineIndexArray[rowIndex]
            x2 := xLineIndexArray[colIndex + 1]
            y2 := yLineIndexArray[rowIndex + 1]
            CellArea := [x1, y1, x2, y2]
            ; 计算单元格角落状态值
            colorTarget := [2] ; 目标颜色索引数组
            coordinateInfo := CellArea
            PixelMatrixBinarizationInstance := PixelMatrixBinarization(windowId, coordinateInfo, xModNum, yModNum, colorTarget, colorArray)
            PixelsAreaWidthHeight := PixelMatrixBinarizationInstance.GetPixels()
            pixels := PixelsAreaWidthHeight[1]
            area := PixelsAreaWidthHeight[2]
            width := PixelsAreaWidthHeight[3]
            height := PixelsAreaWidthHeight[4]
            rowIndexResultSummary := 0
            loop pixels.Length {
                IndexOne := A_Index
                pixel := ConvertNumToRGB(pixels[IndexOne])
                rowIndexResultCount := 0
                loop colorTarget.Length {
                    targetIndex := colorTarget[A_Index]
                    targetColor := colorArray[targetIndex][3]
                    targetTolerance := colorArray[targetIndex][4]
                    result := IsColorWithinTolerance(pixel, targetColor, targetTolerance)
                    result = true ? 1 : 0
                    rowIndexResultCount += result
                }
                rowIndexResultSummary += rowIndexResultCount
            }
            if (rowIndexResultSummary = (width * height)) {
                CellCornerArray.Push(CellArea)
            } else {
                continue
            }
        }
        WhiteGroundArea := ColorCoordinateAreaSummary(CellCornerArray, "Correct-Silent").MaxArea()
        WhiteGroundArea := NormalizeRect(WhiteGroundArea)
        if (A_Index = 1) {
            ColorShow := "0x00FFFF"
            coordinateInfo := WhiteGroundArea
            RandomClickOneArea := coordinateInfo
            windowIdAreaMap[windowId]["RandomClickOneArea"] := RandomClickOneArea
        } else {
            ColorShow := "0xFF00FF"
            coordinateInfo := WhiteGroundArea
            RandomClickFiveArea := coordinateInfo
            windowIdAreaMap[windowId]["RandomClickFiveArea"] := RandomClickFiveArea
        }
        WindowColorRegion(windowId, WhiteGroundArea, ColorShow, defaultDisplayTime * 1, defaultTransparent, overlay).ShowRegion()
    }
    DataArea := [TotalArea[1], SeparatorArea[4], TotalArea[3], TotalArea[4]]
    windowIdAreaMap[windowId]["DataArea"] := DataArea
    DashLineAreaArray := []
    loop {
        ClickArea := RandomClickArea[1]
        NumClicks := 1
        MoveAndClickLoop(ClickArea, NumClicks, defaultSleepTime)
        Sleep(defaultSleepTime * 1)
        ; 检查数据区域是否已清除完毕
        if (DashLineAreaArray.Length = 0) {
            coordinateInfo := [DataArea[1], DataArea[2], DataArea[3], DataArea[4]]
        } else {
            coordinateInfo := [DataArea[1], DashLineAreaArray[DashLineAreaArray.Length][4], DataArea[3], DataArea[4]]
        }
        ; 提取指定颜色索引的行数据
        colorTarget := [2] ; 目标颜色索引数组
        ; 执行像素矩阵二值化
        PixelMatrixBinarizationInstance := PixelMatrixBinarization(windowId, coordinateInfo, xModNum, yModNum, colorTarget, colorArray)
        PixelsAreaWidthHeight := PixelMatrixBinarizationInstance.GetPixels()
        MartrixInfo := PixelMatrixBinarizationInstance.GetMartrix()
        GetColorIndexRowMap := PixelMatrixBinarizationInstance.GetColorIndexRowMap()
        xLineIndexArray := MartrixInfo[2]
        yLineIndexArray := MartrixInfo[3]
        rowCount := yLineIndexArray.Length - 1
        colCount := xLineIndexArray.Length - 1
        ColorIndexRowMap := GetColorIndexRowMap
        ; 提取指定颜色索引的行数据
        colorIndex := 1 ; 指定颜色索引
        IsValidXYArray := []
        loop rowCount + 1 {
            rowIndex := A_Index
            for key, value in ColorIndexRowMap {
                if (key[1] != colorIndex) {
                    continue
                } else {
                    if (key[2] != rowIndex) {
                        continue
                    } else {
                        IsValidXYArray.Push(value)
                        break
                    }
                }
            }
        }

        ; 构建单元格角落坐标数组
        CellCornerArray := []
        TotalCount := rowCount * colCount
        CellTopLeftCornerArray := []
        CellTopRightCornerArray := []
        CellBottomLeftCornerArray := []
        CellBottomRightCornerArray := []
        loop TotalCount {
            rowIndex := Ceil(A_Index / colCount)
            colIndex := A_Index - (rowIndex - 1) * colCount
            x1 := xLineIndexArray[colIndex]
            y1 := yLineIndexArray[rowIndex]
            x2 := xLineIndexArray[colIndex + 1]
            y2 := yLineIndexArray[rowIndex + 1]
            CellArea := [x1, y1, x2, y2]
            ; 计算单元格角落状态值
            TopLeftCorner := IsValidXYArray[rowIndex][colIndex] + 0
            TopRightCorner := IsValidXYArray[rowIndex][colIndex + 1] + 0
            BottomLeftCorner := IsValidXYArray[rowIndex + 1][colIndex] + 0
            BottomRightCorner := IsValidXYArray[rowIndex + 1][colIndex + 1] + 0
            CellCornerOne := TopLeftCorner * 2 + TopRightCorner * 4 + BottomLeftCorner * 8 + BottomRightCorner * 16
            ; 查找符合条件的单元格（状态值为 30）
            if (CellCornerOne = 30) {
                CellCornerArray.Push(CellArea)
            } else {
                continue
            }
        }
        WhiteGroundArea := ColorCoordinateAreaSummary(CellCornerArray, "Correct-Silent").MaxArea()
        WhiteGroundArea := NormalizeRect(WhiteGroundArea)

        DashLineAreaArray.Push(WhiteGroundArea)
        ; 显示定位区域
        if (WhiteGroundArea[1] = 0 and WhiteGroundArea[2] = 0 and WhiteGroundArea[3] = 0 and WhiteGroundArea[4] = 0) {
            ; 未找到符合条件的区域，退出循环
            DashLineAreaArray.RemoveAt(DashLineAreaArray.Length)
            break
        } else {
            coordinateInfo := [DataArea[1], WhiteGroundArea[4], DataArea[3], DataArea[4]]
            coordinateInfo := NormalizeRect(coordinateInfo)
            ; 检查是否已覆盖整个数据区域
            num := 70
            AdjustNum := Round(AdjustCoordinates(Num), 0)
            if (Abs(coordinateInfo[4] - coordinateInfo[2]) < AdjustNum) {
                break
            } else {
                continue
            }
        }
    }

    ShowDebugMessage("随机区域颜色定位完成。")
    colorTarget := [11, 12, 13, 14] ; 目标颜色索引数组
    rowIndexResultArray := []
    loop DashLineAreaArray.Length {
        area := DashLineAreaArray[A_Index]
        coordinateInfo := area
        yStartDash := coordinateInfo[2]
        yEndDash := coordinateInfo[4]
        ; 执行像素矩阵二值化
        PixelMatrixBinarizationInstance := PixelMatrixBinarization(windowId, coordinateInfo, xModNum, yModNum, colorTarget, colorArray)
        PixelsAreaWidthHeight := PixelMatrixBinarizationInstance.GetPixels()
        pixels := PixelsAreaWidthHeight[1]
        area := PixelsAreaWidthHeight[2]
        width := PixelsAreaWidthHeight[3]
        height := PixelsAreaWidthHeight[4]
        rowIndexArray := []
        rowIndexArrayMap := Map()
        rowIndexResultCount := 0
        loop pixels.Length {
            IndexOne := A_Index
            pixel := ConvertNumToRGB(pixels[IndexOne])
            rowIndexResultSummary := 0
            loop colorTarget.Length {
                targetIndex := colorTarget[A_Index]
                targetColor := colorArray[targetIndex][3]
                targetTolerance := colorArray[targetIndex][4]
                result := IsColorWithinTolerance(pixel, targetColor, targetTolerance)
                result = true ? 1 : 0
                rowIndexResultSummary += result
            }
            rowIndexResultSummary := rowIndexResultSummary > 0 ? 1 : 0
            rowIndex := Ceil(IndexOne / width)
            key := rowIndex
            rowIndexResultCount += rowIndexResultSummary
            rowIndexArray.Push([key, rowIndexResultSummary])
        }
        ; 判断是否为有效虚线区域
        loop rowIndexArray.Length {
            rowData := rowIndexArray[A_Index]
            rowIndex := rowData[1]
            rowValue := rowData[2]
            if (rowIndexArrayMap.Has(rowIndex)) {
                rowIndexArrayMap[rowIndex] := rowIndexArrayMap[rowIndex] + rowValue
            } else {
                rowIndexArrayMap[rowIndex] := rowValue
            }
        }
        rowIndexResultArrayOne := []
        loop rowIndexArrayMap.Count {
            key := A_Index
            value := rowIndexArrayMap[key]
            if (value > (width / 4)) {
                ; 该行有效像素数超过宽度一半，视为实线，非虚线区域
                rowIndexResult := yStartDash + key - 1
                rowIndexResultArrayOne.Push(rowIndexResult)
            }
        }
        rowIndexResultArray.Push(rowIndexResultArrayOne[rowIndexResultArrayOne.Length])
        if (A_Index = DashLineAreaArray.Length) {
            yStartDash := GetArrayMinimumValue(rowIndexResultArray)
            yEndDash := GetArrayMaximumValue(rowIndexResultArray)
            yDashRange := Round((yEndDash - yStartDash) / (rowIndexResultArray.Length - 1), 0)
            coordinateInfo := [DataArea[1], yStartDash - yDashRange, DataArea[3], yStartDash]
            DashAreaFirst := NormalizeRect(coordinateInfo)
            coordinateInfo := DashAreaFirst
            rowFinalResultArray := []
            rowFinalResultArray.Push(yStartDash - yDashRange)
            loop rowIndexResultArray.Length {
                yDash := rowIndexResultArray[A_Index]
                rowFinalResultArray.Push(yDash)
            }
            break
        } else {
            continue
        }
    }

    yDashLineRangeArray := []
    loop rowIndexResultArray.Length {
        yStartDash := rowFinalResultArray[A_Index]
        yEndDash := rowFinalResultArray[A_Index + 1]
        yDashLineRangeArray.Push([yStartDash, yEndDash])
    }

    ; ========================= 特殊颜色定位区域 ==========================
    coordinateInfo := [coordinateInfo[1], yDashLineRangeArray[1][1], coordinateInfo[3], yDashLineRangeArray[1][2]]
    FirstDashArea := NormalizeRect(coordinateInfo)
    ColorShow := "0x00FFFF"
    WindowColorRegion(windowId, coordinateInfo, ColorShow, defaultDisplayTime * 1, defaultTransparent, overlay).ShowRegion()
    ShowDebugMessage("特殊颜色定位区域完成。")
    ; 执行像素矩阵二值化
    coordinateInfo := FirstDashArea
    colorTarget := [1, 2] ; 目标颜色索引数组
    xModNum := Round(modMin * xCoarseAndFine01, 0) * 8
    yModNum := Round(modMin * yCoarseAndFine01, 0) * 4
    PixelMatrixBinarizationInstance := PixelMatrixBinarization(windowId, coordinateInfo, xModNum, yModNum, colorTarget, colorArray)
    PixelsAreaWidthHeight := PixelMatrixBinarizationInstance.GetPixels()
    MartrixInfo := PixelMatrixBinarizationInstance.GetMartrix()
    GetColorIndexRowMap := PixelMatrixBinarizationInstance.GetColorIndexRowMap()
    xLineIndexArray := MartrixInfo[2]
    yLineIndexArray := MartrixInfo[3]
    rowCount := yLineIndexArray.Length - 1
    colCount := xLineIndexArray.Length - 1
    ColorIndexRowMap := GetColorIndexRowMap
    ; 提取指定颜色索引的行数据
    colorIndex := 2 ; 指定颜色索引
    IsValidXYArray := []
    loop rowCount + 1 {
        rowIndex := A_Index
        for key, value in ColorIndexRowMap {
            if (key[1] != colorIndex) {
                continue
            } else {
                if (key[2] != rowIndex) {
                    continue
                } else {
                    IsValidXYArray.Push(value)
                    break
                }
            }
        }
    }

    ; 构建单元格角落坐标数组
    CellCornerArray := []
    TotalCount := rowCount * colCount
    CellTopLeftCornerArray := []
    CellTopRightCornerArray := []
    CellBottomLeftCornerArray := []
    CellBottomRightCornerArray := []
    loop TotalCount {
        rowIndex := Ceil(A_Index / colCount)
        colIndex := A_Index - (rowIndex - 1) * colCount
        x1 := xLineIndexArray[colIndex]
        y1 := yLineIndexArray[rowIndex]
        x2 := xLineIndexArray[colIndex + 1]
        y2 := yLineIndexArray[rowIndex + 1]
        CellArea := [x1, y1, x2, y2]
        ; 计算单元格角落状态值
        colorTarget := [2] ; 目标颜色索引数组
        coordinateInfo := CellArea
        PixelMatrixBinarizationInstance := PixelMatrixBinarization(windowId, coordinateInfo, xModNum, yModNum, colorTarget, colorArray)
        PixelsAreaWidthHeight := PixelMatrixBinarizationInstance.GetPixels()
        pixels := PixelsAreaWidthHeight[1]
        area := PixelsAreaWidthHeight[2]
        width := PixelsAreaWidthHeight[3]
        height := PixelsAreaWidthHeight[4]
        rowIndexResultSummary := 0
        loop pixels.Length {
            IndexOne := A_Index
            pixel := ConvertNumToRGB(pixels[IndexOne])
            rowIndexResultCount := 0
            loop colorTarget.Length {
                targetIndex := colorTarget[A_Index]
                targetColor := colorArray[targetIndex][3]
                targetTolerance := colorArray[targetIndex][4]
                result := IsColorWithinTolerance(pixel, targetColor, targetTolerance)
                result = true ? 1 : 0
                rowIndexResultCount += result
            }
            rowIndexResultSummary += rowIndexResultCount
        }
        if (rowIndexResultSummary = (width * height)) {
            CellCornerArray.Push(CellArea)
        } else {
            continue
        }
    }
    WhiteGroundArea := ColorCoordinateAreaSummary(CellCornerArray, "Correct-Silent").MaxArea()
    WhiteGroundArea := NormalizeRect(WhiteGroundArea)
    coordinateInfo := [FirstDashArea[1], FirstDashArea[2], WhiteGroundArea[1], FirstDashArea[4]]
    ColorShow := "0x00FF00"
    WindowColorRegion(windowId, coordinateInfo, ColorShow, defaultDisplayTime * 1, defaultTransparent, overlay).ShowRegion()
    ; ========================= 特殊颜色定位区域完成 ==========================
    ShowDebugMessage("特殊颜色定位区域完成。")
    ; 执行像素矩阵二值化
    colorTarget := [1, 2] ; 目标颜色索引数组
    xModNum := Round(modMin * xCoarseAndFine01, 0) * 2
    yModNum := Round(modMin * yCoarseAndFine01, 0) * 2
    PixelMatrixBinarizationInstance := PixelMatrixBinarization(windowId, coordinateInfo, xModNum, yModNum, colorTarget, colorArray)
    PixelsAreaWidthHeight := PixelMatrixBinarizationInstance.GetPixels()
    MartrixInfo := PixelMatrixBinarizationInstance.GetMartrix()
    GetColorIndexRowMap := PixelMatrixBinarizationInstance.GetColorIndexRowMap()
    xLineIndexArray := MartrixInfo[2]
    yLineIndexArray := MartrixInfo[3]
    rowCount := yLineIndexArray.Length - 1
    colCount := xLineIndexArray.Length - 1
    ColorIndexRowMap := GetColorIndexRowMap
    ; 提取指定颜色索引的行数据
    colorIndex := 2 ; 指定颜色索引
    IsValidXYArray := []
    loop rowCount + 1 {
        rowIndex := A_Index
        for key, value in ColorIndexRowMap {
            if (key[1] != colorIndex) {
                continue
            } else {
                if (key[2] != rowIndex) {
                    continue
                } else {
                    IsValidXYArray.Push(value)
                    break
                }
            }
        }
    }

    ; 构建单元格角落坐标数组
    CellCornerArray := []
    TotalCount := rowCount * colCount
    CellTopLeftCornerArray := []
    CellTopRightCornerArray := []
    CellBottomLeftCornerArray := []
    CellBottomRightCornerArray := []
    loop TotalCount {
        rowIndex := Ceil(A_Index / colCount)
        colIndex := A_Index - (rowIndex - 1) * colCount
        x1 := xLineIndexArray[colIndex]
        y1 := yLineIndexArray[rowIndex]
        x2 := xLineIndexArray[colIndex + 1]
        y2 := yLineIndexArray[rowIndex + 1]
        CellArea := [x1, y1, x2, y2]
        ; 计算单元格角落状态值
        colorTarget := [7, 8, 9, 10] ; 目标颜色索引数组
        coordinateInfo := CellArea
        PixelMatrixBinarizationInstance := PixelMatrixBinarization(windowId, coordinateInfo, xModNum, yModNum, colorTarget, colorArray)
        PixelsAreaWidthHeight := PixelMatrixBinarizationInstance.GetPixels()
        pixels := PixelsAreaWidthHeight[1]
        area := PixelsAreaWidthHeight[2]
        width := PixelsAreaWidthHeight[3]
        height := PixelsAreaWidthHeight[4]
        rowIndexResultSummary := 0
        loop pixels.Length {
            IndexOne := A_Index
            pixel := ConvertNumToRGB(pixels[IndexOne])
            rowIndexResultCount := 0
            loop colorTarget.Length {
                targetIndex := colorTarget[A_Index]
                targetColor := colorArray[targetIndex][3]
                targetTolerance := colorArray[targetIndex][4]
                result := IsColorWithinTolerance(pixel, targetColor, targetTolerance)
                result = true ? 1 : 0
                rowIndexResultCount += result
            }
            rowIndexResultSummary += rowIndexResultCount
        }
        if (rowIndexResultSummary > 0) {
            CellCornerArray.Push(CellArea)
        } else {
            continue
        }
    }
    coordinateInfo := ColorCoordinateAreaSummary(CellCornerArray, "Correct-Silent").MaxArea()
    coordinateInfo := NormalizeRect(coordinateInfo)
    ColorShow := "0xFF00FF"
    WindowColorRegion(windowId, coordinateInfo, ColorShow, defaultDisplayTime * 1, defaultTransparent, overlay).ShowRegion()
    DataArea := coordinateInfo
    DataAreaSuffix := [DashAreaFirst[1], DashAreaFirst[2], DataArea[1] + xModNum, DashAreaFirst[4]]
    coordinateInfo := DataAreaSuffix

    ; 执行像素矩阵二值化
    colorTarget := [1, 2] ; 目标颜色索引数组
    xModNum := Round(modMin * xCoarseAndFine01, 0) * 2
    yModNum := Round(modMin * yCoarseAndFine01, 0) * 2
    PixelMatrixBinarizationInstance := PixelMatrixBinarization(windowId, coordinateInfo, xModNum, yModNum, colorTarget, colorArray)
    PixelsAreaWidthHeight := PixelMatrixBinarizationInstance.GetPixels()
    MartrixInfo := PixelMatrixBinarizationInstance.GetMartrix()
    GetColorIndexRowMap := PixelMatrixBinarizationInstance.GetColorIndexRowMap()
    xLineIndexArray := MartrixInfo[2]
    yLineIndexArray := MartrixInfo[3]
    rowCount := yLineIndexArray.Length - 1
    colCount := xLineIndexArray.Length - 1
    ColorIndexRowMap := GetColorIndexRowMap
    ; 提取指定颜色索引的行数据
    colorIndex := 2 ; 指定颜色索引
    IsValidXYArray := []
    loop rowCount + 1 {
        rowIndex := A_Index
        for key, value in ColorIndexRowMap {
            if (key[1] != colorIndex) {
                continue
            } else {
                if (key[2] != rowIndex) {
                    continue
                } else {
                    IsValidXYArray.Push(value)
                    break
                }
            }
        }
    }

    ; 构建单元格角落坐标数组
    CellCornerArray := []
    TotalCount := rowCount * colCount
    CellTopLeftCornerArray := []
    CellTopRightCornerArray := []
    CellBottomLeftCornerArray := []
    CellBottomRightCornerArray := []
    loop TotalCount {
        rowIndex := Ceil(A_Index / colCount)
        colIndex := A_Index - (rowIndex - 1) * colCount
        x1 := xLineIndexArray[colIndex]
        y1 := yLineIndexArray[rowIndex]
        x2 := xLineIndexArray[colIndex + 1]
        y2 := yLineIndexArray[rowIndex + 1]
        CellArea := [x1, y1, x2, y2]
        ; 计算单元格角落状态值
        colorTarget := [2] ; 目标颜色索引数组
        coordinateInfo := CellArea
        PixelMatrixBinarizationInstance := PixelMatrixBinarization(windowId, coordinateInfo, xModNum, yModNum, colorTarget, colorArray)
        PixelsAreaWidthHeight := PixelMatrixBinarizationInstance.GetPixels()
        pixels := PixelsAreaWidthHeight[1]
        area := PixelsAreaWidthHeight[2]
        width := PixelsAreaWidthHeight[3]
        height := PixelsAreaWidthHeight[4]
        rowIndexResultSummary := 0
        loop pixels.Length {
            IndexOne := A_Index
            pixel := ConvertNumToRGB(pixels[IndexOne])
            rowIndexResultCount := 0
            loop colorTarget.Length {
                targetIndex := colorTarget[A_Index]
                targetColor := colorArray[targetIndex][3]
                targetTolerance := colorArray[targetIndex][4]
                result := IsColorWithinTolerance(pixel, targetColor, targetTolerance)
                result = true ? 1 : 0
                rowIndexResultCount += result
            }
            rowIndexResultSummary += rowIndexResultCount
        }
        if (rowIndexResultSummary = (width * height)) {
            CellCornerArray.Push(CellArea)
        } else {
            continue
        }
    }
    coordinateInfo := ColorCoordinateAreaSummary(CellCornerArray, "Correct-Silent").MaxArea()
    coordinateInfo := NormalizeRect(coordinateInfo)
    coordinateInfoSuffix := coordinateInfo
    ColorShow := "0xFF0000"
    WindowColorRegion(windowId, coordinateInfo, ColorShow, defaultDisplayTime * 1, defaultTransparent, overlay).ShowRegion()
    colorTarget := [2] ; 目标颜色索引数组
    xModNum := Round(modMin * xCoarseAndFine01, 0) * 1
    yModNum := Round(modMin * yCoarseAndFine01, 0) * 1
    coordinateInfo := [coordinateInfo[1], FirstDashArea[2], coordinateInfo[3] + xModNum, FirstDashArea[4]]
    PixelMatrixBinarizationInstance := PixelMatrixBinarization(windowId, coordinateInfo, xModNum, yModNum, colorTarget, colorArray)
    PixelsAreaWidthHeight := PixelMatrixBinarizationInstance.GetPixels()
    MartrixInfo := PixelMatrixBinarizationInstance.GetMartrix()
    GetColorIndexRowMap := PixelMatrixBinarizationInstance.GetColorIndexRowMap()
    xLineIndexArray := MartrixInfo[2]
    yLineIndexArray := MartrixInfo[3]
    rowCount := yLineIndexArray.Length - 1
    colCount := xLineIndexArray.Length - 1
    ColorIndexRowMap := GetColorIndexRowMap
    ; 提取指定颜色索引的行数据
    colorIndex := 2 ; 指定颜色索引
    IsValidXYArray := []
    loop rowCount + 1 {
        rowIndex := A_Index
        for key, value in ColorIndexRowMap {
            if (key[1] != colorIndex) {
                continue
            } else {
                if (key[2] != rowIndex) {
                    continue
                } else {
                    IsValidXYArray.Push(value)
                    break
                }
            }
        }
    }

    ; 构建单元格角落坐标数组
    CellCornerArray := []
    TotalCount := rowCount * colCount
    CellTopLeftCornerArray := []
    CellTopRightCornerArray := []
    CellBottomLeftCornerArray := []
    CellBottomRightCornerArray := []
    loop TotalCount {
        rowIndex := Ceil(A_Index / colCount)
        colIndex := A_Index - (rowIndex - 1) * colCount
        x1 := xLineIndexArray[colIndex]
        y1 := yLineIndexArray[rowIndex]
        x2 := xLineIndexArray[colIndex + 1]
        y2 := yLineIndexArray[rowIndex + 1]
        CellArea := [x1, y1, x2, y2]
        ; 计算单元格角落状态值
        colorTarget := [2] ; 目标颜色索引数组
        coordinateInfo := CellArea
        PixelMatrixBinarizationInstance := PixelMatrixBinarization(windowId, coordinateInfo, xModNum, yModNum, colorTarget, colorArray)
        PixelsAreaWidthHeight := PixelMatrixBinarizationInstance.GetPixels()
        pixels := PixelsAreaWidthHeight[1]
        area := PixelsAreaWidthHeight[2]
        width := PixelsAreaWidthHeight[3]
        height := PixelsAreaWidthHeight[4]
        rowIndexResultSummary := 0
        loop pixels.Length {
            IndexOne := A_Index
            pixel := ConvertNumToRGB(pixels[IndexOne])
            rowIndexResultCount := 0
            loop colorTarget.Length {
                targetIndex := colorTarget[A_Index]
                targetColor := colorArray[targetIndex][3]
                targetTolerance := colorArray[targetIndex][4]
                result := IsColorWithinTolerance(pixel, targetColor, targetTolerance)
                result = true ? 1 : 0
                rowIndexResultCount += result
            }
            rowIndexResultSummary += rowIndexResultCount
        }
        if (rowIndexResultSummary < (width * height)) {
            CellCornerArray.Push(CellArea)
        } else {
            continue
        }
    }

    SpecialArea := ColorCoordinateAreaSummary(CellCornerArray, "Correct-Silent").MaxArea()
    SpecialArea := NormalizeRect(SpecialArea)
    if (SpecialArea[1] = 0 and SpecialArea[2] = 0 and SpecialArea[3] = 0 and SpecialArea[4] = 0) {
        SpecialArea := [coordinateInfoSuffix[1], coordinateInfoSuffix[2], coordinateInfoSuffix[3] - xModNum, coordinateInfoSuffix[4]]
    }
    ColorShow := "0xFFFF00"
    WindowColorRegion(windowId, SpecialArea, ColorShow, defaultDisplayTime * 1, defaultTransparent, overlay).ShowRegion()

    DataIndexAreaArray := []
    loop DashLineAreaArray.Length {
        yStartDash := yDashLineRangeArray[A_Index][1]
        yEndDash := yDashLineRangeArray[A_Index][2]
        coordinateInfo := [SpecialArea[3], yStartDash, WhiteGroundArea[1], yEndDash]
        if (A_Index = 1) {
            ColorShow := "0xFFAA00"
            WindowColorRegion(windowId, coordinateInfo, ColorShow, defaultDisplayTime * 1, defaultTransparent, overlay).ShowRegion()
        }
        DataIndexAreaArray.Push(coordinateInfo)
    }

    windowIdAreaMap[windowId]["DataIndexAreaArray"] := DataIndexAreaArray
    ; ========================= 清除数据操作 ==========================
    ShowDebugMessage("开始执行清除数据操作。")
    coordinateInfo := TotalDataArea
    colorIndexArray := [7, 8, 9, 10]
    SummaryMode := "Correct-Silent"
    xModNum := Round(modMin * xCoarseAndFine01, 0) * 2
    yModNum := Round(modMin * yCoarseAndFine01, 0) * 2
    ClickClearButtomInstance := ClickClearButtom(windowId, coordinateInfo, xModNum, yModNum, colorIndexArray, colorArray, SummaryMode)
    CellArea := ClickClearButtomInstance.ClickClearArea()
    ClickClearButtomArea := CellArea
    windowIdAreaMap[windowId]["ClickClearButtomArea"] := ClickClearButtomArea
    ShowDebugMessage("清除数据操作已完成。")
}

windowIdAreaMapKeyArray := []
windowIdAreaMapKeyArray := [
    "TotalArea",
    "RandomArea",
    "RandomClickOneArea",
    "RandomClickFiveArea",
    "DataArea",
    "DataIndexAreaArray",
    "ClickClearButtomArea"
]

for key, value in windowIdAreaMap {
    windowId := key
    areaMap := value
    loop windowIdAreaMapKeyArray.Length {
        areaKey := windowIdAreaMapKeyArray[A_Index]
        if (areaMap.Has(areaKey) = false) {
            areaMap[areaKey] := []
        } else {
            tempArray := areaMap[areaKey]
            if (Type(tempArray) != "Array") {
                areaMap[areaKey] := []
            } else {
                if (IsNumber(tempArray[tempArray.Length]) = false and Type(tempArray[tempArray.Length]) != "Array") {
                    areaMap[areaKey] := []
                } else if (Type(tempArray) = "Array" and tempArray.Length = 4 and IsNumber(tempArray[1]) and IsNumber(tempArray[2]) and IsNumber(tempArray[3]) and IsNumber(tempArray[4])) {
                    ; 单个区域坐标，转换为二维数组
                    areaMap[areaKey] := [tempArray]
                } else {
                    ; 保持原样
                    continue
                }
            }
        }
    }
}

; ========================= 截图保存操作 ==========================
ShowDebugMessage("开始执行截图保存操作。")
startTick := A_TickCount
loop {
    loopBreak := false
    loop idArray.Length {
        windowId := idArray[A_Index]
        ShowDebugMessage("完成窗口 ID：" . windowId . " 的所有操作。")
        SafeActivateWindow(windowId, "Client")
        AreaMap := windowIdAreaMap[windowId]
        TotalArea := AreaMap["TotalArea"][1]
        RandomClickOneArea := AreaMap["RandomClickOneArea"][1]
        RandomClickFiveArea := AreaMap["RandomClickFiveArea"][1]
        DataArea := AreaMap["DataArea"][1]
        DataIndexAreaArray := AreaMap["DataIndexAreaArray"]
        ClickClearButtomArea := AreaMap["ClickClearButtomArea"][1]
        DataSummaryArea := ColorCoordinateAreaSummary(DataIndexAreaArray, "Correct-Silent").MaxArea()

        ; 确保数据区域已清除完毕
        ClickArea := RandomClickFiveArea
        NumClicks := 4
        MoveAndClickLoop(ClickArea, NumClicks, defaultSleepTime)
        savePath := A_ScriptDir . "\" . targetAppName . "\" . "Screenshots"
        SafeActivateWindow(windowId, "Client")
        coordinateInfo := DataSummaryArea
        screenshotCoordinatesClientInfo := coordinateInfo
        result := WindowScreenshot(windowId, screenshotCoordinatesClientInfo, savePath).EnsureSavePathExists()
        if (result = false) {
            MsgBox("无法创建截图保存路径：" . savePath . "，请检查文件夹权限设置。", , "T2")
            ExitApp
        }
        WindowScreenshotInstance := WindowScreenshot(windowId, screenshotCoordinatesClientInfo, savePath)
        screenInfoMap := WindowScreenshotInstance.TakeScreenshot()
        filePath := screenInfoMap["filePath"]
        ; 等待截图完成
        colorIndexArray := [3]
        SummaryMode := "Correct-Silent"
        PixelValidArray := []
        loop {
            IndexNumCount := A_Index
            coordinateInfo := [TotalArea[1], DataSummaryArea[4], TotalArea[3], TotalArea[4]]
            TotalAreaClearBottom := coordinateInfo
            DllCallPixelGetRsultInstance := DllCallPixelGetRsult(windowId, coordinateInfo)
            AreaColorInfoMap := DllCallPixelGetRsultInstance.GetAreaColorInfoMap()
            Pixels := AreaColorInfoMap["Pixels"]
            Area := AreaColorInfoMap["Area"]
            width := AreaColorInfoMap["width"]
            height := AreaColorInfoMap["height"]
            xStart := AreaColorInfoMap["xStart"]
            yStart := AreaColorInfoMap["yStart"]
            xEnd := xStart + width - 1
            yEnd := yStart + height - 1
            colorFound := false
            xCellInfo := GetBorderMod(xStart, xEnd, modMin * xCoarseAndFine01).generateCellArray()
            yCellInfo := GetBorderMod(yStart, yEnd, modMin * yCoarseAndFine01).generateCellArray()
            PixelValid := []
            loop yCellInfo.Length {
                yCellStart := yCellInfo[A_Index][1]
                yCellEnd := yCellInfo[A_Index][2]
                loop xCellInfo.Length {
                    xCellStart := xCellInfo[A_Index][1]
                    xCellEnd := xCellInfo[A_Index][2]
                    coordinateInfo := [xCellStart, yCellStart, xCellEnd, yCellEnd]
                    PointCenter := [Round((xCellStart + xCellEnd) / 2, 0), Round((yCellStart + yCellEnd) / 2, 0)]
                    PointCenterIndex := (PointCenter[2] - yStart) * width + (PointCenter[1] - xStart) + 1
                    Pixel := ConvertNumToRGB(Pixels[PointCenterIndex])
                    PixelValid.Push(Pixel)
                }
            }
            PixelValidArray.Push(PixelValid)
            if (PixelValidArray.Length >= 2) {
                PreviousPixelValid := PixelValidArray[PixelValidArray.Length - 1]
                CurrentPixelValid := PixelValidArray[PixelValidArray.Length]
                MatchingCount := 0
                loop PreviousPixelValid.Length {
                    IndexOne := A_Index
                    prevPixel := PreviousPixelValid[IndexOne]
                    currPixel := CurrentPixelValid[IndexOne]
                    if (prevPixel = currPixel) {
                        MatchingCount += 1
                    }
                }
                MatchingRate := MatchingCount / PreviousPixelValid.Length
                if (MatchingRate >= 0.95) {
                    colorIndexArray := [3]
                    SummaryMode := "Correct-Silent"
                    coordinateInfo := TotalAreaClearBottom
                    GetColorCoordinatesAreaInstance := GetColorCoordinatesArea(windowId, coordinateInfo, colorIndexArray, colorArray, SummaryMode)
                    PointX1Y1Info := GetColorCoordinatesAreaInstance.GetMaxAreaX1Y1()
                    PointX2Y2Info := GetColorCoordinatesAreaInstance.GetMaxAreaX2Y2()
                    x1Color := PointX1Y1Info[1]
                    y1Color := PointX1Y1Info[2]
                    x2Color := PointX2Y2Info[1]
                    y2Color := PointX2Y2Info[2]
                    ColorAreaInfo := [x1Color, y1Color, x2Color, y2Color]
                    if (ColorAreaInfo[1] != 0 and ColorAreaInfo[2] != 0 and ColorAreaInfo[3] != 0 and ColorAreaInfo[4] != 0) {
                        ClickArea := ColorAreaInfo
                        NumClicks := 1
                        MoveAndClickLoop(ClickArea, NumClicks, defaultSleepTime)
                        break
                    } else {
                        continue
                    }
                } else {
                    continue
                }
            } else {
                continue
            }
        }
    }

    ShowDebugMessage("截图保存路径已确认：" . savePath)
    FolderSize := 0
    fileCount := 0
    Loop Files, savePath "\*.png", "R" {
        FolderSize += A_LoopFileSize
        fileCount += 1
    }
    if (Mod(fileCount, 10) <= 1) {
        if (Mod(fileCount, 10) = 0) {
            nowTick := A_TickCount
            elapsedTime := nowTick - startTick
            mouseX := 0
            mouseY := 0
            MouseGetPos(&mouseX, &mouseY)
            ToolTip("已截图数量：" . fileCount . "`n耗时：" . elapsedTime . " 毫秒。", mouseX + 20, mouseY + 20)
            ShowDebugMessage("已截图数量：" . fileCount . "，耗时：" . elapsedTime . " 毫秒。")
        } else {
            ShowDebugMessage("已截图数量：" . fileCount . "。")
            Loop Files, savePath "\*.png", "R" {
                filePath := A_LoopFileFullPath
                FileDelete(filePath)
                break
            }
        }
    }
    if (fileCount >= maxScreenNumber) {
        loopBreak := true
        saveTime := FormatTime(A_LoopFileTimeModified, "yyyy-MM-dd HH_mm")
        baseNewPath := A_ScriptDir . "\" . targetAppName . "\" . saveTime
        savePathNew := baseNewPath

        ; 如果重名，追加自动序号
        idx := 1
        while DirExist(savePathNew) {
            savePathNew := baseNewPath . "_" . idx
            idx++
        }
        try {
            DirMove(savePath, savePathNew)
        } catch as err {
            MsgBox("移动目录失败: " err.Message)
        }
        break
    }
}

; 等待 3 秒
Sleep(3000)

; 取消（隐藏）这个 ToolTip
ToolTip()

OCRExePath := g_programConfig["OCR工具"][1]
TempFile := savePathNew "\temp.txt"

; 构建 PowerShell 命令（单行）
Cmd0 := "& " "`"" . OCRExePath . "`"" " --add_page 0"
Cmd1 := "& " "`"" . OCRExePath . "`"" " --del_page 0"
Cmd2 := "powershell -Command " "`"& `"" "`"" . OCRExePath . "`"" " --all_pages --output_append `"" "`'" . TempFile . "`'" "`""
Cmd3 := "& " "`"" . OCRExePath . "`"" " --add_page 1"
; 激活 Terminal
PowerShellIdInfo := SafeActivateWindow(ExeNameMap["PowerShell"], "Client")
PowerShellId := PowerShellIdInfo[1]
if (!WinExist(PowerShellId)) {
    MsgBox("无法激活 PowerShell 窗口")
    ExitApp
}

SafeActivateWindow(PowerShellId, "Client")
WindowsTerminalInPutInstance := WindowsTerminalInPut(windowId , "cls" . "`r")
WindowsTerminalInPutInstance.SendInputText()
Sleep(defaultSleepTime * 5)
SafeActivateWindow(PowerShellId, "Client")
WindowsTerminalInPutInstance := WindowsTerminalInPut(windowId , Cmd0)
WindowsTerminalInPutInstance.SendInputText()
Sleep(defaultSleepTime * 5)

TextArray := []
MatchingCount := 0
loop {
    ; 输入命令
    SafeActivateWindow(PowerShellId, "Client")
    WindowsTerminalInPutInstance := WindowsTerminalInPut(windowId , "cls" . "`r")
    WindowsTerminalInPutInstance.SendInputText()
    Sleep(defaultSleepTime * 5)
    windowId := PowerShellId
    WindowsTerminalInPutInstance := WindowsTerminalInPut(windowId , Cmd2)
    WindowsTerminalInPutInstance.SendInputText()
    SafeActivateWindow(ExeNameMap["Umi-OCR"], "Client")
    Sleep(defaultSleepTime * 10)
    ; 输入命令
    SafeActivateWindow(PowerShellId, "Client")
    WindowsTerminalInPutInstance := WindowsTerminalInPut(windowId , "cls" . "`r")
    WindowsTerminalInPutInstance.SendInputText()
    Sleep(defaultSleepTime * 5)
    windowId := PowerShellId
    WindowsTerminalInPutInstance := WindowsTerminalInPut(windowId , Cmd2)
    WindowsTerminalInPutInstance.SendInputText()
    SendText("`r")   ; ← 回车结束输入
    WaitForFile(TempFile)
    ; 等待命令执行完成
    MsgBox("请确认 `r`n" TempFile "`r`n 真实存在，然后点击确定继续。", , "T2")
    if (!FileExist(TempFile)) {
        MsgBox("未找到临时文件：" . TempFile, , "T2")
        continue
    }

    ; 读取输出
    Text := FileRead(TempFile, "UTF-8")

    TextArray.Push(Text)
    if (TextArray.Length >= 3) {
        TextArrayCurrent := TextArray[TextArray.Length]
        TextArrayPrevious := TextArray[TextArray.Length - 1]
        TextArrayCurrentInfo := StrSplit(TextArrayCurrent, "`n")
        TextArrayPreviousInfo := StrSplit(TextArrayPrevious, "`n")
        if (TextArrayCurrentInfo.Length != TextArrayPreviousInfo.Length) {
            FileDelete(TempFile)
            continue
        } else {
            MatchingCount += 1
            if (MatchingCount >= 2) {
                break
            } else {
                FileDelete(TempFile)
                continue
            }
        }
    } else {
        FileDelete(TempFile)
        continue
    }
}


SafeActivateWindow(PowerShellId, "Client")
SendText("cls" . "`r")   ; ← 回车结束输入
Sleep(defaultSleepTime * 5)
windowId := PowerShellId
WindowsTerminalInPutInstance := WindowsTerminalInPut(windowId , Cmd3)
WindowsTerminalInPutInstance.SendInputText()
SendText("`r")   ; ← 回车结束输入
Sleep(defaultSleepTime * 5)
if (FileExist(TempFile)) {
    FileDelete(TempFile)
}

Cmd1 := "& " "`"" . OCRExePath . "`"" " --del_page 0"
SafeActivateWindow(PowerShellId, "Client")
WindowsTerminalInPutInstance := WindowsTerminalInPut(windowId , "cls" . "`r")
WindowsTerminalInPutInstance.SendInputText()
Sleep(defaultSleepTime * 5)
windowId := PowerShellId
WindowsTerminalInPutInstance := WindowsTerminalInPut(windowId , Cmd1)
WindowsTerminalInPutInstance.SendInputText()
Sleep(defaultSleepTime * 50)

Loop Files, savePath "\*.", "R" {
    filePath := A_LoopFileFullPath
    fileName := A_LoopFileName
    Size := FileGetSize(fileName, "KB")
    if (InStr(filePath, ".png") > 0 and Size > 20 and Size < 30) {
        continue
    } else {
        FileDelete(filePath)
    }
}

MsgBox("OCR 处理已完成，结果保存在：" . savePathNew . "\OCR.txt", , "T1")
Cmd4 := "& " "`"" . OCRExePath . "`"" " --path `"" . savePathNew . "`"" " --output_append " "`"" . savePathNew . "\OCR.txt`""
SafeActivateWindow(PowerShellId, "Client")
WindowsTerminalInPutInstance := WindowsTerminalInPut(windowId , "cls" . "`r")
WindowsTerminalInPutInstance.SendInputText()
Sleep(defaultSleepTime * 50)
windowId := PowerShellId
WindowsTerminalInPutInstance := WindowsTerminalInPut(windowId , Cmd4)
WindowsTerminalInPutInstance.SendInputText()
SendText("`r")   ; ← 回车结束输入
Sleep(defaultSleepTime * 50)
; 清理临时文件夹
; ========================= 截图保存操作完成 ==========================
loop {
    targetExeName := "Umi-OCR"
    filterClass := "ahk_class Qt5152QWindowOwnDCIcon"
    ExeArray := GetFilteredWindowIds(targetExeName, filterClass)
    if (ExeArray.Length = 0) {
        break
    }
    if (ExeArray.Length = 0) {
        MsgBox("未检测到 Umi-OCR 窗口，请确认其已启动并打开主窗口。", , "T2")
        continue
    } else if (ExeArray.Length > 1) {
        MsgBox("检测到多个 Umi-OCR 窗口，请确保只打开一个主窗口后再继续。", , "T2")
        continue
    } else {
        Umi_OCRId := ExeArray[1]    
    }
    Umi_OCRIdInfo := SafeActivateWindow(Umi_OCRId, "Client")
    Umi_OCRId := Umi_OCRIdInfo[1]
    x1 := Umi_OCRIdInfo[2]
    y1 := Umi_OCRIdInfo[3]
    x2 := Umi_OCRIdInfo[4]
    y2 := Umi_OCRIdInfo[5]
    coordinateInfo := [x1, y1, x2, y2]
    colorIndexArray := [19]
    SummaryMode := "Correct-Silent"
    GetColorCoordinatesAreaInstance := GetColorCoordinatesArea(Umi_OCRId, coordinateInfo, colorIndexArray, colorArray, SummaryMode)
    PointX1Y1Info := GetColorCoordinatesAreaInstance.GetMaxAreaX1Y1()
    PointX2Y2Info := GetColorCoordinatesAreaInstance.GetMaxAreaX2Y2()
    x1Color := PointX1Y1Info[1]
    y1Color := PointX1Y1Info[2]
    x2Color := PointX2Y2Info[1]
    y2Color := PointX2Y2Info[2]
    ColorAreaInfo := [x1Color, y1Color, x2Color, y2Color]
    if (ColorAreaInfo[1] = 0 and ColorAreaInfo[2] = 0 and ColorAreaInfo[3] = 0 and ColorAreaInfo[4] = 0) {
        MsgBox("未能在 Umi-OCR 窗口中检测到可点击区域，请确认其主窗口已打开且界面正常显示。", , "T2")
        break
    } else {
        coordinateInfo := ColorAreaInfo
        ColorShow := "0x00FF00"
        WindowColorRegion(Umi_OCRId, coordinateInfo, ColorShow, defaultDisplayTime * 1, defaultTransparent, overlay).ShowRegion()
        Sleep(3500)
        continue
    }
}

MsgBox("所有截图操作已完成。`r`n程序运行完毕，即将退出", , "T2")
ExitApp

class GetOutsideBorderRegion {
    __New(windowId, PointCenter, coordinateInfo, pixels, borderIntervalX, borderIntervalY, colorInside, colorInsideTolerance, colorOutside, colorOutsideTolerance, SummaryMode, CornerMode, colorArray) {
        this.windowId := windowId
        this.PointCenter := PointCenter
        this.coordinateInfo := coordinateInfo
        this.xStart := coordinateInfo[1]
        this.yStart := coordinateInfo[2]
        this.xEnd := coordinateInfo[3]
        this.yEnd := coordinateInfo[4]
        this.pixels := pixels
        this.xModNum := borderIntervalX
        this.yModNum := borderIntervalY
        this.colorInside := colorInside
        this.colorInsideTolerance := colorInsideTolerance
        this.colorOutside := colorOutside
        this.colorOutsideTolerance := colorOutsideTolerance
        ColorValidArray := [
            [this.colorInside, this.colorInsideTolerance],
            [this.colorOutside, this.colorOutsideTolerance]
        ]
        this.ColorValidArray := ColorValidArray
        this.SummaryMode := SummaryMode
        this.CornerMode := CornerMode
        this.colorArray := colorArray
        this.debugModeBreak := debugModeBreak

        this.ValidTrueMap := Map(
            "TopLeftCorner", ["10"],
            "TopEdgeCenter", ["10"],
            "TopRightCorner", ["10"],
            "LeftEdgeCenter", ["10"],
            "RegionCenter", ["10"],
            "RightEdgeCenter", ["10"],
            "BottomLeftCorner", ["10"],
            "BottomEdgeCenter", ["10"],
            "BottomRightCorner", ["10"]
        )

        this.CornerModeArray := ["TopLeft", "TopRight", "BottomLeft", "BottomRight"]
    }

    ColorValidArrayDataValidation() {
        ColorValidArray := this.ColorValidArray
        if (Type(ColorValidArray) != "Array" or ColorValidArray.Length != 2) {
            return false
        } else {
            loop ColorValidArray.Length {
                ColorValidArrayOne := ColorValidArray[A_Index]
                if (Type(ColorValidArrayOne) != "Array" or ColorValidArrayOne.Length != 2) {
                    return false
                }
            }
            return true
        }
    }

    TotalParameterValidation() {
        ColorValidArrayValidationResult := this.ColorValidArrayDataValidation()
        if (ColorValidArrayValidationResult = false) {
            MsgBox("GetOutsideBorderRegion 类的 ColorValidArray 参数格式不正确，无法继续执行。", , "T2")
            return false
        }
        if (this.xModNum < 1 or this.yModNum < 1) {
            MsgBox("GetOutsideBorderRegion 类的 xModNum 或 yModNum 参数值不正确，无法继续执行。", , "T2")
            return false
        }
        if (this.SummaryMode != "Correct-Silent") {
            MsgBox("GetOutsideBorderRegion 类的 SummaryMode 参数值不正确，无法继续执行。", , "T2")
            return false
        }
        if (this.colorInside = "" or this.colorOutside = "") {
            MsgBox("GetOutsideBorderRegion 类的 colorInside 或 colorOutside 参数值不正确，无法继续执行。", , "T2")
            return false
        }
        if (Type(this.PointCenter) != "Array" or this.PointCenter.Length != 2) {
            MsgBox("GetOutsideBorderRegion 类的 PointCenter 参数格式不正确，无法继续执行。", , "T2")
            return false
        }
        if (Type(this.coordinateInfo) != "Array" or this.coordinateInfo.Length != 4) {
            MsgBox("GetOutsideBorderRegion 类的 coordinateInfo 参数格式不正确，无法继续执行。", , "T2")
            return false
        }
        if (IsNumber(this.coordinateInfo[1]) = false or IsNumber(this.coordinateInfo[2]) = false or IsNumber(this.coordinateInfo[3]) = false or IsNumber(this.coordinateInfo[4]) = false) {
            MsgBox("GetOutsideBorderRegion 类的 coordinateInfo 参数值不正确，无法继续执行。", , "T2")
            return false
        }
        if (this.PointCenter[1] < this.coordinateInfo[1] or this.PointCenter[1] > this.coordinateInfo[3] or this.PointCenter[2] < this.coordinateInfo[2] or this.PointCenter[2] > this.coordinateInfo[4]) {
            MsgBox("GetOutsideBorderRegion 类的 PointCenter 参数值不在 coordinateInfo 范围内，无法继续执行。", , "T2")
            return false
        }
        return true
    }

    FindOutsideBorderRegion() {
        TotalParameterValidationResult := this.TotalParameterValidation()
        if (TotalParameterValidationResult = false) {
            return [-1, -1, -1, -1]
        }
        ; 调用边缘检测类进行边缘检测
        ValidTrueMap := this.ValidTrueMap
        CornerRegionArray := []
        CornerModeArray := this.CornerModeArray
        CornerMode := this.CornerMode
        if (CornerMode != "" and CornerMode != "All" and Type(CornerMode) = "String") {
            CornerMode := Trim(CornerMode)
            CornerModeArray := []
            if (InStr(CornerMode, "TopLeft") > 0) {
                CornerModeArray.Push("TopLeft")
            }
            if (InStr(CornerMode, "TopRight") > 0) {
                CornerModeArray.Push("TopRight")
            }
            if (InStr(CornerMode, "BottomLeft") > 0) {
                CornerModeArray.Push("BottomLeft")
            }
            if (InStr(CornerMode, "BottomRight") > 0) {
                CornerModeArray.Push("BottomRight")
            }
        } else {
            CornerModeArray := this.CornerModeArray
        }

        ; MsgBox("开始检测 外边缘区域，CornerModeArray 参数为：`r`n" . ConvertArrayToString(CornerModeArray), , "T2")
        windowId := this.windowId
        coordinateInfo := this.coordinateInfo
        pixels := this.pixels
        PointXYInfo := this.PointCenter
        xModNum := this.xModNum
        yModNum := this.yModNum
        ColorValidArray := this.ColorValidArray
        SummaryMode := this.SummaryMode
        colorArray := this.colorArray
        debugModeBreak := this.debugModeBreak
        xStart := this.xStart
        yStart := this.yStart
        CoordinateMappingInstance := CoordinateMapping(windowId, coordinateInfo, xModNum, yModNum)
        RectangleMapArray := CoordinateMappingInstance.CellMap()
        loop CornerModeArray.Length {
            CornerMode := CornerModeArray[A_Index]
            ; MsgBox("开始检测 第 " A_Index " 次" . CornerMode . " 边缘区域。", , "T2")
            edgeDetector := EdgeDetectionColor(windowId, coordinateInfo, pixels, PointXYInfo, xModNum, yModNum, ColorValidArray, ValidTrueMap, CornerMode, colorArray)
            PointConnerInfo := edgeDetector.LoopBreakResult() ; 获取边缘检测结果坐标
            CellInfo := GetCellInfo(coordinateInfo, PointConnerInfo, rectangleMapArray).CellInfo()
            CornerRegionArray.Push(CellInfo)
            ; 显示检测到的区域
            if (debugModeBreak) {
                ; 显示检测到的区域
                ColorShow := "0xAAAA00"
                WindowColorRegion(windowId, CellInfo, ColorShow, defaultDisplayTime * 1, defaultTransparent, overlay).ShowRegion()
            } else {
                ShowDebugMessage("检测到的 " . CornerMode . " 边缘区域坐标为：`r`n" . ConvertArrayToString(CellInfo), , "T2")
            }
        }

        ; 随机点击区域
        CellArea := ColorCoordinateAreaSummary(CornerRegionArray, this.SummaryMode).MaxArea()
        return CellArea
    }
}

class PixelMatrixBinarization {
    __New(windowId, coordinateInfo, xModNum, yModNum, colorTarget, colorArray) {
        this.windowId := windowId
        this.coordinateInfo := coordinateInfo
        this.Width := coordinateInfo[3] - coordinateInfo[1] + 1
        this.Height := coordinateInfo[4] - coordinateInfo[2] + 1
        this.colorTarget := colorTarget
        this.colorArray := colorArray
        this.xModNum := xModNum
        this.yModNum := yModNum
        this.PixelsInfo := []
        this.martrixData := []
        this.IsValidInfo := []
    }

    GetPixels() {
        windowId := this.windowId
        coordinateInfo := this.coordinateInfo
        DllCallPixelGetRsultInstance := DllCallPixelGetRsult(windowId, coordinateInfo)
        AreaColorInfoMap := DllCallPixelGetRsultInstance.GetAreaColorInfoMap()
        Pixels := AreaColorInfoMap["Pixels"]
        width := AreaColorInfoMap["width"]
        height := AreaColorInfoMap["height"]
        Area := AreaColorInfoMap["Area"]
        this.Pixels := Pixels
        this.Area := Area
        this.Width := Width
        this.Height := Height
        this.PixelsInfo := [Pixels, Area, Width, Height]
        return this.PixelsInfo
    }

    GetMartrix() {
        Area := this.PixelsInfo[2]
        Pixels := this.PixelsInfo[1]
        Width := this.PixelsInfo[3]
        Height := this.PixelsInfo[4]
        xModNum := this.xModNum
        yModNum := this.yModNum
        xStart := Area[1]
        yStart := Area[2]
        xEnd := Area[3]
        yEnd := Area[4]
        ; 计算 X 方向分割线索引数组
        xCellRange := GetBorderMod(Area[1], Area[3], xModNum).generateCellArray()
        xLineIndexArray := []
        xPointMap := Map()
        xPointCenterMap := Map()
        loop xCellRange.Length {
            xIndexNum := A_Index
            xCellStart := xCellRange[xIndexNum][1]
            xCellEnd := xCellRange[xIndexNum][2]
            xLineIndex := Ceil((xCellStart + xCellEnd) / 2)
            xLineIndexArray.Push(xLineIndex)
            xPointMap[xLineIndex] := xIndexNum
            xPointCenterMap[xIndexNum] := [xCellStart, xCellEnd]
        }

        ; 计算 Y 方向分割线索引数组
        yCellRange := GetBorderMod(Area[2], Area[4], yModNum).generateCellArray()
        yLineIndexArray := []
        yPointMap := Map()
        yPointCenterMap := Map()
        loop yCellRange.Length {
            yIndexNum := A_Index
            yCellStart := yCellRange[A_Index][1]
            yCellEnd := yCellRange[A_Index][2]
            yLineIndex := Ceil((yCellStart + yCellEnd) / 2)
            yLineIndexArray.Push(yLineIndex)
            yPointMap[yLineIndex] := yIndexNum
            yPointCenterMap[yIndexNum] := [yCellStart, yCellEnd]
        }

        ; 遍历所有分割线索引，获取对应的像素颜色值
        PixelsCenterArray := []
        PointsCenterMap := Map()
        loop yLineIndexArray.Length {
            ; 偏移计算；因为 Pixels 数组是从 (xStart, yStart) 开始的
            yLineIndex := yLineIndexArray[A_Index] - yStart + 1
            loop xLineIndexArray.Length {
                ; 偏移计算；因为 Pixels 数组是从 (xStart, yStart) 开始的
                xLineIndex := xLineIndexArray[A_Index] - xStart + 1
                pixelIndex := yLineIndex * Width + xLineIndex + 1
                pixelColor := Pixels[pixelIndex]
                pixelColorRGB := ConvertNumToRGB(pixelColor)
                PixelsCenterArray.Push(pixelColorRGB)
            }
        }

        this.PixelsCenterArray := PixelsCenterArray
        this.xLineIndexArray := xLineIndexArray
        this.yLineIndexArray := yLineIndexArray
        this.xPointCenterMap := xPointCenterMap
        this.yPointCenterMap := yPointCenterMap
        this.martrixData := [PixelsCenterArray, xLineIndexArray, yLineIndexArray, xPointCenterMap, yPointCenterMap]
        return this.martrixData
    }

    GetBinarization() {
        martrixData := this.martrixData
        PixelsCenterArray := martrixData[1]
        xLineIndexArray := martrixData[2]
        yLineIndexArray := martrixData[3]
        colorIndexArray := this.colorTarget
        colorArray := this.colorArray
        colorToleranceArray := []
        loop ColorIndexArray.Length {
            ColorIndex := ColorIndexArray[A_Index]
            colorInfo := colorArray[ColorIndex]
            colorValue := colorInfo[3]
            colorTolerance := colorInfo[4]
            colorToleranceArray.Push([colorValue, colorTolerance])
        }

        PixelsTransposeRGBArray := []
        ; 遍历像素颜色值，检查是否在容差范围内
        loop PixelsCenterArray.Length {
            isMatch := false
            pixelColorRGB := PixelsCenterArray[A_Index]
            loop colorToleranceArray.Length {
                colorToleranceInfo := colorToleranceArray[A_Index]
                colorValue := colorToleranceInfo[1]
                colorTolerance := colorToleranceInfo[2]
                colorValueRGB := ConvertNumToRGB(colorValue)
                isMatch := IsColorWithinTolerance(pixelColorRGB, colorValueRGB, colorTolerance)
                if (isMatch = true) {
                    ; 找到匹配颜色，记录并跳出内层循环
                    PixelsTransposeRGBArray.Push(colorValueRGB)
                    break
                }
            }
            if (isMatch = false) {
                PixelsTransposeRGBArray.Push(pixelColorRGB)
            }
        }

        ; 输出处理结果
        CellXCount := xLineIndexArray.Length
        CellYCount := yLineIndexArray.Length
        IsValidCountArray := []
        IsValidXYArray := []
        IsValidCount := 0
        loop colorToleranceArray.Length {
            colorToleranceIndex := A_Index
            colorToleranceInfo := colorToleranceArray[colorToleranceIndex]
            colorValue := colorToleranceInfo[1]
            colorTolerance := colorToleranceInfo[2]
            colorToleranceArray[colorToleranceIndex] := [ConvertNumToRGB(colorValue), colorTolerance]
            loop PixelsTransposeRGBArray.Length {
                Index := A_Index
                pixelOne := PixelsTransposeRGBArray[Index]
                rowIndex := Ceil(Index / CellXCount)
                IsValid := IsColorWithinTolerance(pixelOne, colorValue, colorTolerance)
                IsValidCount += IsValid = true ? 1 : 0
                if (Mod(Index, CellXCount) = 1) {
                    IsValidXArray := []
                    IsValidXArray.Push(IsValid)
                } else if (Mod(Index, CellXCount) = 0) {
                    IsValidXArray.Push(IsValid)
                    IsValidCountArray.Push([rowIndex, colorValue, IsValidCount])
                    IsValidCount := 0
                    IsValidXYArray.Push([colorValue, IsValidXArray])
                } else {
                    IsValidXArray.Push(IsValid)
                }
            }
        }
        this.IsValidInfo := [IsValidCountArray, IsValidXYArray]
        return this.IsValidInfo
    }

    GetColorIndexRowMap() {
        this.GetPixels()
        pixelsAndAreaInfo := this.PixelsInfo
        pixels := pixelsAndAreaInfo[1]
        area := pixelsAndAreaInfo[2]
        width := pixelsAndAreaInfo[3]
        height := pixelsAndAreaInfo[4]
        ; 获取截图区域坐标信息
        this.GetMartrix()
        PointInfo := this.martrixData
        PixelsCenterArray := PointInfo[1]
        xLineIndexArray := PointInfo[2]
        yLineIndexArray := PointInfo[3]
        xPointCenterMap := PointInfo[4]
        yPointCenterMap := PointInfo[5]
        this.GetBinarization()
        IsValidInfo := this.IsValidInfo
        IsValidCountArray := IsValidInfo[1]
        IsValidXYArray := IsValidInfo[2]
        rowCount := yLineIndexArray.Length - 1
        colCount := xLineIndexArray.Length - 1
        ColorIndexRowArray := []
        ColorIndexRowMap := Map()
        loop IsValidXYArray.Length {
            rowIndex := A_Index
            rowColorIndex := Ceil(rowIndex / yLineIndexArray.Length)
            rowIndexColor := rowIndex - (rowColorIndex - 1) * yLineIndexArray.Length
            keyColorIndex := [rowColorIndex, rowIndexColor]
            ColorIndexRowArray.Push(keyColorIndex)
            ColorIndexRowMap[keyColorIndex] := IsValidXYArray[rowIndex][2]
        }
        return ColorIndexRowMap
    }

    GetColorIndexColMap() {
        this.GetPixels()
        pixelsAndAreaInfo := this.PixelsInfo
        pixels := pixelsAndAreaInfo[1]
        area := pixelsAndAreaInfo[2]
        width := pixelsAndAreaInfo[3]
        height := pixelsAndAreaInfo[4]
        ; 获取截图区域坐标信息
        this.GetMartrix()
        PointInfo := this.martrixData
        PixelsCenterArray := PointInfo[1]
        xLineIndexArray := PointInfo[2]
        yLineIndexArray := PointInfo[3]
        xPointCenterMap := PointInfo[4]
        yPointCenterMap := PointInfo[5]
        this.GetBinarization()
        IsValidInfo := this.IsValidInfo
        IsValidCountArray := IsValidInfo[1]
        IsValidXYArray := IsValidInfo[2]
        rowCount := yLineIndexArray.Length - 1
        colCount := xLineIndexArray.Length - 1
        ColorIndexRowArray := []
        ColorIndexRowMap := Map()
        loop IsValidXYArray.Length {
            colIndex := A_Index
            colColorIndex := Ceil(colIndex / xLineIndexArray.Length)
            colIndexColor := colIndex - (colColorIndex - 1) * xLineIndexArray.Length
            keyColorIndex := [colColorIndex, colIndexColor]
            ColorIndexRowArray.Push(keyColorIndex)
            ColorIndexRowMap[keyColorIndex] := IsValidXYArray[colIndex][2]
        }
        return ColorIndexRowMap
    }
}

class ClickClearButtom {
    __New(windowId, coordinateInfo, xModNum, yModNum, colorIndexArray, colorArray, SummaryMode := "Correct-Silent") {
        this.windowId := windowId
        this.coordinateInfo := coordinateInfo
        this.xModNum := xModNum
        this.yModNum := yModNum
        this.colorIndexArray := colorIndexArray
        this.colorArray := colorArray
        this.SummaryMode := SummaryMode
        this.PointDataEnd := []
        this.PointFontEnd := []
        this.clickValid := false
    }

    FindClickArea() {
        windowId := this.windowId
        coordinateInfo := this.coordinateInfo
        xModNum := this.xModNum
        yModNum := this.yModNum
        colorIndexArray := this.colorIndexArray
        colorArray := this.colorArray
        SummaryMode := this.SummaryMode
        GetColorCoordinatesAreaInstance := GetColorCoordinatesArea(windowId, coordinateInfo, colorIndexArray, colorArray, SummaryMode)
        PointX1Y1Info := GetColorCoordinatesAreaInstance.GetMaxAreaX1Y1()
        PointX2Y2Info := GetColorCoordinatesAreaInstance.GetMaxAreaX2Y2()
        x1Color := PointX1Y1Info[1]
        y1Color := PointX1Y1Info[2]
        x2Color := PointX2Y2Info[1]
        y2Color := PointX2Y2Info[2]
        ColorAreaInfo := [x1Color, y1Color, x2Color, y2Color]
        ; 显示数据区域颜色定位结果
        ColorShow := "0x0000FF"
        WindowColorRegion(windowId, ColorAreaInfo, ColorShow, defaultDisplayTime * 1, defaultTransparent, overlay).ShowRegion()
        ; 数据区域定位失败处理
        if (x1Color <= 0 and y1Color <= 0 and x2Color <= 0 and y2Color <= 0) {
            ShowDebugMessage("Error: 未能成功定位数据区域的颜色坐标，请检查截图区域及颜色配置。", , "T2")
            this.clickValid := false
            x1Color := 0
            y1Color := 0
            x2Color := 0
            y2Color := 0
            ColorAreaInfo := [x1Color, y1Color, x2Color, y2Color]
        } else {
            ; 进一步精确数据区域定位
            this.clickValid := true
            CoordinateMappingInstance := CoordinateMapping(windowId, coordinateInfo, xModNum, yModNum)
            RectangleMapArray := CoordinateMappingInstance.CellMap()
            PointXYInfo := [x2Color, y2Color]
            CellInfo := GetCellInfo(coordinateInfo, PointXYInfo, rectangleMapArray).CellInfo()
            ColorShow := "0x00FF00"
            WindowColorRegion(windowId, CellInfo, ColorShow, defaultDisplayTime * 1, defaultTransparent, overlay).ShowRegion()
            x1 := CellInfo[1]
            y1 := CellInfo[2]
            x2 := CellInfo[3]
            y2 := CellInfo[4]
            PointX2Y2Info := [x2, y2]
            PointDataEnd := PointX2Y2Info
            PointXYInfo := PointX2Y2Info
            MouseMove(x2, y2)
            Sleep(defaultSleepTime)
            PointCenter := PointX2Y2Info
            SummaryMode := "Correct-Silent"
            ColorIndex1 := 2
            ColorIndex2 := 1
            colorInside := colorArray[ColorIndex1][3]
            colorInsideTolerance := colorArray[ColorIndex1][4]
            colorOutside := colorArray[ColorIndex2][3]
            colorOutsideTolerance := colorArray[ColorIndex2][4]
            ColorValidArray := [[colorInside, colorInsideTolerance], [colorOutside, colorOutsideTolerance]]
            CornerMode := "BottomRight"
            pixels := DllCallPixelGetRsult(windowId, coordinateInfo).PixelGetColor()[3]
            BorderRegion := GetOutsideBorderRegion(windowId, PointCenter, coordinateInfo, pixels, xModNum, yModNum, colorInside, colorInsideTolerance, colorOutside, colorOutsideTolerance, SummaryMode, CornerMode, colorArray)
            CellArea := BorderRegion.FindOutsideBorderRegion()
            ColorShow := "0x00AAAA"
            WindowColorRegion(windowId, CellArea, ColorShow, defaultDisplayTime * 1, defaultTransparent, overlay).ShowRegion()
            this.PointDataEnd := PointDataEnd
            return CellArea
        }
    }

    ClickClearArea() {
        CellArea := this.FindClickArea()
        if (this.clickValid = false) {
            ShowDebugMessage("Error: 数据区域颜色定位失败，无法执行清除数据操作。", , "T2")
            return
        }
        windowId := this.windowId
        PointDataEnd := this.PointDataEnd
        PointFontEnd := [CellArea[3], CellArea[2]]
        ; 截图区域定位
        coordinateInfo := [PointDataEnd[1], PointDataEnd[2], PointFontEnd[1], PointFontEnd[2]]
        coordinateInfo := NormalizeRect(coordinateInfo)
        ColorIndex := 3
        Color := colorArray[ColorIndex][3]
        Tolerance := colorArray[ColorIndex][4]
        colorCoordinateArea := CoordinateCornerCollection(windowId, coordinateInfo, Color, Tolerance).CornerArea() ; 测试角落坐标收集类
        ColorShow := "0xFF0000"
        WindowColorRegion(windowId, colorCoordinateArea, ColorShow, defaultDisplayTime * 1, defaultTransparent, overlay).ShowRegion()
        ; 执行点击操作
        ClickArea := colorCoordinateArea
        NumClicks := 1
        MoveAndClickLoop(ClickArea, NumClicks, defaultSleepTime)
        return CellArea
    }
}

class WindowsTerminalInPut {
    __New(windowId, inputText) {
        this.windowId := windowId
        this.inputText := inputText
        this.StringParts := []
    }

    SendInputText() {
        inputText := this.inputText
        if (inputText = "") {
            return
        } else {
            inputText := Trim(inputText)
        }

        if (StrLen(inputText) > 2) {
            StringParts := []
            StrLenMin := 1
            LoopNum := Ceil(StrLen(inputText) / StrLenMin)
            loop LoopNum - 1 {
                StartIndex := (A_Index - 1) * StrLenMin + 1
                SubString := SubStr(inputText, StartIndex, StrLenMin)
                StringParts.Push(SubString)
            }
            ; 添加最后一部分
            LastStartIndex := (LoopNum - 1) * StrLenMin + 1
            LastSubString := SubStr(inputText, LastStartIndex)
            StringParts.Push(LastSubString "`n")
        } else {
            StringParts := [inputText "`n"]
        }
        this.StringParts := StringParts
        
        windowId := this.windowId
        SafeActivateWindow(windowId, "Client")
        SendText("cls`n")   ; ← 回车结束输入
        loop StringParts.Length {
            inputText := StringParts[A_Index]
            SendText(inputText)
            Sleep(defaultSleepTime * 1)
        }
    }
}