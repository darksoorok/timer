if (A_IsAdmin = false) {
    Run *RunAs "%A_ScriptFullPath%" ,, UseErrorLevel
}
#SingleInstance force
#NoEnv
DetectHiddenWindows on

Time_Hour := 00
Time_Min := 00
Time_Sec := 00
Time_Hour_Up := 23
Time_Min_Up := 59
Time_Sec_Up := 59
Time_Hour_Down := 01
Time_Min_Down := 01
Time_Sec_Down := 01
Active := "Запустить"
processButton := "Выберите процесс"
Indicator := " "
Indicator1 := " "
ResultTimes := A_Hour ":" A_Min ":" A_Sec

Action := "Звуковое оповещение"
hideWindow := 250
stateWindow := 0
yTime := 60
yIndicator := 58
yTextToResult := 170
yButton := 190
yTextToAction := 550
ProcessName := ""

RegRead, Value_OnExit, HKEY_CURRENT_USER, Software\Timer, OnExit
if (Value_OnExit == "")
    RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Timer, OnExit, 0

Menu, Tray, NoStandard
Menu, tray, add, Открыть меню, GuiHide, Default
Menu, tray, add
Menu, tray, add, Выключать при закрытии, OnExit
Menu, tray, add, Перезагрузить, ReloadScript
Menu, tray, add, Выключить, ExitScript

if (Value_OnExit)
    Menu, tray, ToggleCheck, Выключать при закрытии

Gui, Destroy
Gui, +LastFound

Gui, Font, S36 Bold
Gui, Font, cD3D3D3
Gui, Add, Text, x13 y5 w70 h55 vTime_Hour_Up gHour_Up, %Time_Hour_Up%
Gui, Add, Text, x98 y5 w70 h55 vTime_Min_Up gMin_Up, %Time_Min_Up%
Gui, Add, Text, x183 y5 w70 h55 vTime_Sec_Up gSec_Up, %Time_Sec_Up%

Gui, Add, Text, x13 y115 w70 h55 vTime_Hour_Down gHour_Down, %Time_Hour_Down%
Gui, Add, Text, x98 y115 w70 h55 vTime_Min_Down gMin_Down, %Time_Min_Down%
Gui, Add, Text, x183 y115 w70 h55 vTime_Sec_Down gSec_Down, %Time_Sec_Down%

Gui, Font, S40 Bold
Gui, Font, cBlack
Gui, Add, Text, x77 y%yIndicator% w15 h55 vIndicator, %Indicator%
Gui, Add, Text, x162 y%yIndicator% w15 h55 vIndicator1, %Indicator1%
Gui, Font, S40 Bold
Gui, Add, Text, x10 y%yTime% w70 h55 vTime_Hour, %Time_Hour%
Gui, Add, Text, x95 y%yTime% w70 h55 vTime_Min, %Time_Min%
Gui, Add, Text, x180 y%yTime% w70 h55 vTime_Sec, %Time_Sec%
Gui, Font, S10 Bold, Calibri
Gui, Add, Text, x0 y%yTextToResult% w260 h20 Center vTextToResultTime, Таймер сработает в %ResultTimes%
Gui, Font, S10 Norm
Gui, Add, Button, x10 y%yButton% w240 h25 gActives vActive, %Active%
Gui, Add, DropDownList, x10 y220 w240 h200 vAction gEditAction, Звуковое оповещение|Перезагрузить компьютер|Выключить компьютер|Завершить процесс
Gui, Add, Text, x0 y%yTextToAction% w260 h20 Center vTextToAction, %Action%

Gui, Add, Button, x10 y250 w240 h20 gChoiseProcess vprocessButton, %processButton%
SetTimer, UpdateResultTime, 150
Gui, Show, w260 h%hideWindow%, Таймер
GuiControl, Choose, Action, %Action%
Return

OnExit:
Menu, tray, ToggleCheck, Выключать при закрытии
RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Timer, OnExit, % (Value_OnExit := !Value_OnExit)
Return

GuiHide:
Gui, Show, w260 h%hideWindow%, Таймер
Return

ChoiseProcess:
Gui, 2:New, -DPIScale
Gui, 2:Add, ListView, x0 y0 w630 h480 gChoiseProcessName, Имя процесса|Путь
Gosub, CreateList
LV_ModifyCol()
Gui, 2:Add, Button, x0 y490 w130 h20 gUpdate, Обновить список
Gui, 2:Show,, Список процессов
return

ChoiseProcessName:
if (A_GuiEvent == "DoubleClick")
{
    LV_GetText(ProcessName, A_EventInfo)
    Gui, 2:Destroy
    GuiControl, 1:, processButton, % "Выбрано | " ProcessName
}
Return

Update:
LV_Delete()
CreateList:
for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process") {
        LV_Add("", process.Description, process.ExecutablePath)
}
Return

EditAction:
Gui, Submit, NoHide
if (Action == "Завершить процесс")
{
    while (hideWindow <= 280)
    {
        Gui, Show, w260 h%hideWindow%, Таймер
        Sleep, 20
        hideWindow := hideWindow + 10
    }
    hideWindow := 280
    stateWindow := 1
}
else
{
    while (hideWindow >= 250)
    {
        Gui, Show, w260 h%hideWindow%, Таймер
        Sleep, 20
        hideWindow := hideWindow - 10
    }
    hideWindow := 250
    stateWindow := 0
}
Return

Actives:
if (Time_Hour != 00) or (Time_Min != 00) or (Time_Sec != 00)
{
    Gui, Submit, NoHide
    if (Action == "Завершить процесс") and (!ProcessName)
    {
        TrayTip, Таймер, Для начала работы таймера выберите процесс из списка.
        Return
    }
    a := !a
    GuiControl, Move, Time_Hour, % "y" (a ? "10" : yTime)
    GuiControl, Move, Time_Min,  % "y" (a ? "10" : yTime)
    GuiControl, Move, Time_Sec, % "y" (a ? "10" : yTime)
    GuiControl, Move, Indicator, % "y" (a ? "8" : yIndicator)
    GuiControl, Move, Indicator1, % "y" (a ? "8" : yIndicator)
    GuiControl, Move, Active, % "y" (a ? "115" : yButton)
    GuiControl, Move, TextToResultTime, % "y" (a ? "70" : yTextToResult)
    GuiControl, Move, TextToAction, % "y" (a ? "90" : yTextToAction)

    SetTimer, UpdateResultTime, % (a ? "Off" : 150)
    SetTimer, activeIndicator, % (a ? 650 : "Off")
    SetTimer, Timer, % (a ? 1000 : "Off")

    if (a) {
        LHour := Time_Hour
        LMin := Time_Min
        LSec := Time_Sec
        Sleep, 200
        while (hideWindow >= 145)
        {
            Gui, Show, w260 h%hideWindow%, Таймер
            Sleep, 20
            hideWindow := hideWindow - 10
        }
        hideWindow := 145
        StringLower, Lower_Action, Action
        TrayTip, Таймер, Таймер успешно запущен.`nЧерез %Time_Hour% ч. %Time_Min% мин. %Time_Sec% сек. будет выполнено действие: ''%Lower_Action%''.
    } else {
        Time_Hour := LHour
        Time_Min := LMin
        Time_Sec := LSec
        if (stateWindow)
        {
            while (hideWindow <= 280)
            {
                Gui, Show, w260 h%hideWindow%, Таймер
                Sleep, 20
                hideWindow := hideWindow + 10
            }
            hideWindow := 280
        } else {
            while (hideWindow <= 250)
            {
                Gui, Show, w260 h%hideWindow%, Таймер
                Sleep, 20
                hideWindow := hideWindow + 10
            }
            hideWindow := 250
        }
        if (Indicator = ":") or (Indicator1 = ":") 
        {
            Sleep, 150
            Indicator := " "
            Indicator1 := " "
            GuiControl,, Indicator, %Indicator%
            GuiControl,, Indicator1, %Indicator1%
        }
    }
    
    GuiControl,, TextToAction, %Action%
    GuiControl,, Time_Hour_Up, % (a ? "" : Time_Hour_Up)
    GuiControl,, Time_Min_Up, % (a ? "" : Time_Min_Up)
    GuiControl,, Time_Sec_Up, % (a ? "" : Time_Sec_Up)
    GuiControl,, Time_Hour_Down, % (a ? "" : Time_Hour_Down)
    GuiControl,, Time_Min_Down, % (a ? "" : Time_Min_Down)
    GuiControl,, Time_Sec_Down, % (a ? "" : Time_Sec_Down)
    GuiControl,, Time_Hour, %Time_Hour%
    GuiControl,, Time_Min, %Time_Min%
    GuiControl,, Time_Sec, %Time_Sec%
    Active := (a ? "Остановить" : "Запустить")
    GuiControl,, Active, %Active%
}
Return

activeIndicator:
if (Indicator == ":") {
    Indicator := " "
    Indicator1 := " "
} else {
    Indicator := ":"
    Indicator1 := ":"
}

GuiControl,, Indicator, %Indicator%
GuiControl,, Indicator1, %Indicator1%
Return

UpdateResultTime:
if (Time_Hour != 00 or Time_Min != 00 or Time_Sec != 00)
{
    GuiControl, Show, TextToResultTime
    ResultTimes := getResultTime(Time_Hour, Time_Min, Time_Sec)
    GuiControl,, TextToResultTime, Таймер сработает в %ResultTimes%
}
Else
{
    GuiControl, Hide, TextToResultTime
}
Return

Timer:
if (Time_Hour == 00) and (Time_Min == 00) and (Time_Sec == 00) {
    Active := "Время закончилось"
    GuiControl,, Active, %Active%
    SetTimer, activeIndicator, Off
    SetTimer, Timer, Off
    Indicator := ":"
    Indicator1 := ":"
    GuiControl,, Indicator, %Indicator%
    GuiControl,, Indicator1, %Indicator1%
    a := !a
    Sleep, 3000

    ; ДЕЙСТВИЕ
    Gui, Submit, NoHide
    if (Action == "Завершить процесс") {
        Process, Close, % ProcessName
        GuiControl, 1:, processButton, %processButton%
    } 
    else if (Action == "Перезагрузить компьютер")
        Shutdown, 2
    else if (Action == "Выключить компьютер")
        Shutdown, 5
    else if (Action == "Звуковое оповещение") 
        SoundPlay, %A_WinDir%\Media\ding.wav
    
    Indicator := " "
    Indicator1 := " "
    Time_Hour := LHour
    Time_Min := LMin
    Time_Sec := LSec
    GuiControl, Move, Time_Hour, % "y" (a ? "10" : yTime)
    GuiControl, Move, Time_Min,  % "y" (a ? "10" : yTime)
    GuiControl, Move, Time_Sec, % "y" (a ? "10" : yTime)
    GuiControl, Move, Indicator, % "y" (a ? "8" : yIndicator)
    GuiControl, Move, Indicator1, % "y" (a ? "8" : yIndicator)
    GuiControl, Move, Active, % "y" (a ? "85" : yButton)
    GuiControl,, Indicator, %Indicator%
    GuiControl,, Indicator1, %Indicator1%
    GuiControl,, Time_Hour, %Time_Hour%
    GuiControl,, Time_Min, %Time_Min%
    GuiControl,, Time_Sec, %Time_Sec%
    GuiControl,, Time_Hour_Up, % (a ? "" : Time_Hour_Up)
    GuiControl,, Time_Min_Up, % (a ? "" : Time_Min_Up)
    GuiControl,, Time_Sec_Up, % (a ? "" : Time_Sec_Up)
    GuiControl,, Time_Hour_Down, % (a ? "" : Time_Hour_Down)
    GuiControl,, Time_Min_Down, % (a ? "" : Time_Min_Down)
    GuiControl,, Time_Sec_Down, % (a ? "" : Time_Sec_Down)
    Active := "Запустить"
    GuiControl,, Active, %Active%
    
    if (stateWindow)
    {
        while (hideWindow <= 280)
        {
            Gui, Show, w260 h%hideWindow% NoActivate, Таймер
            Sleep, 20
            hideWindow := hideWindow + 10
        }
        hideWindow := 280
    } else {
        while (hideWindow <= 250)
        {
            Gui, Show, w260 h%hideWindow% NoActivate, Таймер
            Sleep, 20
            hideWindow := hideWindow + 10
        }
        hideWindow := 250
    }
    Return
}
Time_Sec--

if (Time_Sec == -1) {
    Time_Sec := 59
    Time_Min--
}
if (Time_Min == -1) {
    Time_Min := 59
    Time_Hour--
}

Time_Hour := RegExReplace(Time_Hour, "^\d{1}$", "0" Time_Hour)
Time_Min := RegExReplace(Time_Min, "^\d{1}$", "0" Time_Min)
Time_Sec := RegExReplace(Time_Sec, "^\d{1}$", "0" Time_Sec)
GuiControl,, Time_Hour, %Time_Hour%
GuiControl,, Time_Sec, %Time_Sec%
GuiControl,, Time_Min, %Time_Min%
Return

Hour_Up:
if (!a)
{
    Time_Hour++
    Time_Hour_Up := Time_Hour - 1
    Time_Hour_Down := Time_Hour + 1
    Time_Hour := RegExReplace(Time_Hour, "^\d{1}$", "0" Time_Hour)
    Time_Hour_Up := RegExReplace(Time_Hour_Up, "^\d{1}$", "0" Time_Hour_Up)
    Time_Hour_Down := RegExReplace(Time_Hour_Down, "^\d{1}$", "0" Time_Hour_Down)
    if (Time_Hour == 24)
        Time_Hour := 00
    if (Time_Hour_Up == 24)
        Time_Hour_Up := 00
    if (Time_Hour_Down == 24)
        Time_Hour_Down := 00
    else if (Time_Hour_Down == 25)
        Time_Hour_Down := 01

    GuiControl,, Time_Hour, %Time_Hour%
    GuiControl,, Time_Hour_Up, %Time_Hour_Up%
    GuiControl,, Time_Hour_Down, %Time_Hour_Down%
}
Return
Hour_Down:
if (!a)
{
    Time_Hour--
    Time_Hour_Up := Time_Hour - 1
    Time_Hour_Down := Time_Hour + 1

    Time_Hour := RegExReplace(Time_Hour, "^\d{1}$", "0" Time_Hour)
    Time_Hour_Up := RegExReplace(Time_Hour_Up, "^\d{1}$", "0" Time_Hour_Up)
    Time_Hour_Down := RegExReplace(Time_Hour_Down, "^\d{1}$", "0" Time_Hour_Down)
    if (Time_Hour == -1)
        Time_Hour := 23
    if (Time_Hour_Up == -1)
        Time_Hour_Up := 23
    else if (Time_Hour_Up == -2)
        Time_Hour_Up := 22
    else if (Time_Hour_Up == 24)
        Time_Hour_Up := 00
    if (Time_Hour_Down == 24)
        Time_Hour_Down := 00
    else if (Time_Hour_Down == 25)
        Time_Hour_Down := 01

    GuiControl,, Time_Hour, %Time_Hour%
    GuiControl,, Time_Hour_Up, %Time_Hour_Up%
    GuiControl,, Time_Hour_Down, %Time_Hour_Down%
}
Return
Min_Up:
if (!a)
{
    Time_Min++
    Time_Min_Up := Time_Min - 1
    Time_Min_Down := Time_Min + 1
    Time_Min := RegExReplace(Time_Min, "^\d{1}$", "0" Time_Min)
    Time_Min_Up := RegExReplace(Time_Min_Up, "^\d{1}$", "0" Time_Min_Up)
    Time_Min_Down := RegExReplace(Time_Min_Down, "^\d{1}$", "0" Time_Min_Down)
    if (Time_Min == 60)
        Time_Min := 00
    if (Time_Min_Up == 60)
        Time_Min_Up := 00
    if (Time_Min_Down == 60)
        Time_Min_Down := 00
    else if (Time_Min_Down == 61)
        Time_Min_Down := 01

    GuiControl,, Time_Min, %Time_Min%
    GuiControl,, Time_Min_Up, %Time_Min_Up%
    GuiControl,, Time_Min_Down, %Time_Min_Down%
}
Return
Min_Down:
if (!a)
{
    Time_Min--
    Time_Min_Up := Time_Min - 1
    Time_Min_Down := Time_Min + 1

    Time_Min := RegExReplace(Time_Min, "^\d{1}$", "0" Time_Min)
    Time_Min_Up := RegExReplace(Time_Min_Up, "^\d{1}$", "0" Time_Min_Up)
    Time_Min_Down := RegExReplace(Time_Min_Down, "^\d{1}$", "0" Time_Min_Down)
    if (Time_Min == -1)
        Time_Min := 59
    if (Time_Min_Up == -1)
        Time_Min_Up := 59
    else if (Time_Min_Up == -2)
        Time_Min_Up := 58
    else if (Time_Min_Up == 60)
        Time_Min_Up := 00
    if (Time_Min_Down == 60)
        Time_Min_Down := 00
    else if (Time_Min_Down == 61)
        Time_Min_Down := 01

    GuiControl,, Time_Min, %Time_Min%
    GuiControl,, Time_Min_Up, %Time_Min_Up%
    GuiControl,, Time_Min_Down, %Time_Min_Down%
}
Return
Sec_Up:
if (!a)
{
    Time_Sec++
    Time_Sec_Up := Time_Sec - 1
    Time_Sec_Down := Time_Sec + 1
    Time_Sec := RegExReplace(Time_Sec, "^\d{1}$", "0" Time_Sec)
    Time_Sec_Up := RegExReplace(Time_Sec_Up, "^\d{1}$", "0" Time_Sec_Up)
    Time_Sec_Down := RegExReplace(Time_Sec_Down, "^\d{1}$", "0" Time_Sec_Down)
    if (Time_Sec == 60)
        Time_Sec := 00
    if (Time_Sec_Up == 60)
        Time_Sec_Up := 00
    if (Time_Sec_Down == 60)
        Time_Sec_Down := 00
    else if (Time_Sec_Down == 61)
        Time_Sec_Down := 01

    GuiControl,, Time_Sec, %Time_Sec%
    GuiControl,, Time_Sec_Up, %Time_Sec_Up%
    GuiControl,, Time_Sec_Down, %Time_Sec_Down%
}
Return
Sec_Down:
if (!a)
{
    Time_Sec--
    Time_Sec_Up := Time_Sec - 1
    Time_Sec_Down := Time_Sec + 1

    Time_Sec := RegExReplace(Time_Sec, "^\d{1}$", "0" Time_Sec)
    Time_Sec_Up := RegExReplace(Time_Sec_Up, "^\d{1}$", "0" Time_Sec_Up)
    Time_Sec_Down := RegExReplace(Time_Sec_Down, "^\d{1}$", "0" Time_Sec_Down)
    if (Time_Sec == -1)
        Time_Sec := 59
    if (Time_Sec_Up == -1)
        Time_Sec_Up := 59
    else if (Time_Sec_Up == -2)
        Time_Sec_Up := 58
    else if (Time_Sec_Up == 60)
        Time_Sec_Up := 00
    if (Time_Sec_Down == 60)
        Time_Sec_Down := 00
    else if (Time_Sec_Down == 61)
        Time_Sec_Down := 01

    GuiControl,, Time_Sec, %Time_Sec%
    GuiControl,, Time_Sec_Up, %Time_Sec_Up%
    GuiControl,, Time_Sec_Down, %Time_Sec_Down%
}
Return

ReloadScript:
Reload
Return

ExitScript:
ExitApp
Return

GuiClose:
if (!Value_OnExit) or (a) {
    Gui, Submit, Hide
    TrayTip, Таймер, Программа всё ещё запущена.`nЧтобы открыть меню`, нажмите правой кнопкой мыши по иконке.
}
else
    ExitApp
Return

getResultTime(TimerHours, TimerMinutes, TimerSeconds)
{
    CurrentHours := A_Hour
    CurrentMinutes := A_Min
    CurrentSeconds := A_Sec

    CurrentTotalSeconds := CurrentHours * 3600 + CurrentMinutes * 60 + CurrentSeconds
    TimerTotalSeconds := TimerHours * 3600 + TimerMinutes * 60 + TimerSeconds

    ResultTotalSeconds := Mod(CurrentTotalSeconds + TimerTotalSeconds, 86400)

    ResultHours := Floor(ResultTotalSeconds / 3600)
    ResultMinutes := Floor((ResultTotalSeconds - ResultHours * 3600) / 60)
    ResultSeconds := ResultTotalSeconds - ResultHours * 3600 - ResultMinutes * 60

    ResultTime := Format("{:02}:{:02}:{:02}", ResultHours, ResultMinutes, ResultSeconds)

    return ResultTime
}