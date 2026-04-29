-- VXJediEssentials Traditional Chinese Locale (zhTW)
---@class AE
local AE = select(2, ...)
if GetLocale() ~= "zhTW" then return end
local L = AE.L

------------------------------------------------------------------------
-- General / Shared
------------------------------------------------------------------------
L["On"] = "開啟"
L["Off"] = "關閉"
L["Enabled"] = "已啟用"
L["Disabled"] = "已停用"
L["Enable"] = "啟用"
L["Error"] = "錯誤"
L["Note"] = "注意"
L["Show"] = "顯示"
L["Required"] = "必需"
L["Coming Soon"] = "即將推出"
L["Database not available"] = "資料庫不可用"
L["None"] = "無"

------------------------------------------------------------------------
-- GUI Sidebar Sections
------------------------------------------------------------------------
L["Combat"] = "戰鬥"
L["Custom Buffs"] = "自訂增益"
L["Optimize"] = "最佳化"
L["Profiles"] = "設定檔"
L["Quality of Life"] = "便捷功能"

------------------------------------------------------------------------
-- GUI Sidebar Entries
------------------------------------------------------------------------
L["Combat Timer"] = "戰鬥計時器"
L["Combat Cross"] = "戰鬥準星"
L["Combat Texts"] = "戰鬥文字"
L["Combat Res"] = "戰鬥復活"
L["Missing Buffs"] = "缺失增益"
L["Pet Status Texts"] = "寵物狀態文字"
L["Focus Castbar"] = "焦點施法條"
L["Target Castbar"] = "目標施法條"
L["Hunters Mark Missing"] = "獵人印記缺失"
L["Gateway Alert"] = "傳送門提醒"
L["Automation"] = "自動化"
L["Copy Anything"] = "複製任意內容"
L["Cursor Circle"] = "游標圓圈"
L["Dragon Riding UI"] = "馭龍術介面"
L["Externals & Defensives"] = "外部與防禦技能"
L["System Optimization"] = "系統最佳化"
L["Profile Manager"] = "設定檔管理器"

------------------------------------------------------------------------
-- Home Page
------------------------------------------------------------------------
L["Getting Started"] = "入門指南"
L["Support"] = "支援"

------------------------------------------------------------------------
-- Combat Timer
------------------------------------------------------------------------
L["Enable Combat Timer"] = "啟用戰鬥計時器"
L["Print Combat Duration to Chat"] = "在聊天中顯示戰鬥持續時間"
L["Combat lasted "] = "戰鬥持續了 "
L["Format"] = "格式"
L["Bracket Style"] = "括號樣式"
L["Font Size"] = "字型大小"
L["Font"] = "字型"
L["Font Outline"] = "字型輪廓"
L["Font Shadow"] = "字型陰影"
L["Font Settings"] = "字型設定"

------------------------------------------------------------------------
-- Combat Cross
------------------------------------------------------------------------
L["Enable Combat Cross"] = "啟用戰鬥準星"
L["Cross Size"] = "準星大小"
L["Size"] = "大小"
L["This is a static crosshair overlay and will not adjust with camera panning."] = "這是一個靜態準星覆蓋層，不會隨攝影機移動而調整。"

------------------------------------------------------------------------
-- Combat Messages
------------------------------------------------------------------------
L["Enable Combat Messages"] = "启用战斗消息"
L["Combat Res Tracker"] = "战斗复活追踪器"
L["Enable Combat Res Tracker"] = "启用战斗复活追踪器"
L["Enter Combat Message"] = "进入战斗消息"
L["Exit Combat Message"] = "离开战斗消息"
L["Low Durability Warning"] = "低耐久度警告"
L["LOW DURABILITY"] = "低耐久度"
L["Message Spacing"] = "消息间距"
L["Durability Threshold (%)"] = "耐久度阈值 (%)"
L["Text"] = "文字"
L["Text Settings"] = "文字設定"

------------------------------------------------------------------------
-- Pet Status Texts
------------------------------------------------------------------------
L["Enable Pet Status Texts"] = "启用宠物状态文本"
L["PET DEAD"] = "宠物死亡"
L["PET MISSING"] = "宠物缺失"
L["PET PASSIVE"] = "宠物被动"
L["Pet Dead Text"] = "宠物死亡文本"
L["Pet Missing Text"] = "宠物缺失文本"
L["Pet Passive Text"] = "宠物被动文本"
L["Dead Color"] = "死亡颜色"
L["Missing Color"] = "缺失颜色"
L["Passive Color"] = "被动颜色"

------------------------------------------------------------------------
-- Focus / Target Castbar
------------------------------------------------------------------------
L["Enable Focus Castbar"] = "启用焦点施法条"
L["Enable Target Castbar"] = "启用目标施法条"
L["Bar Height"] = "条高度"
L["Bar Texture"] = "条纹理"
L["Width"] = "宽度"
L["Height"] = "高度"
L["Target Names"] = "目标名称"
L["Casting"] = "施法中"
L["Channeling"] = "引导中"
L["Empowering"] = "蓄力中"
L["Not Interruptible"] = "不可打断"
L["Interrupted"] = "已打断"
L["Cast Success"] = "施法成功"
L["Colors"] = "顏色"
L["Color Settings"] = "顏色設定"
L["Hold Timer"] = "保持计时器"
L["Enable Hold Timer"] = "启用保持计时器"
L["Hold Duration"] = "保持时间"
L["Kick Indicator"] = "打断指示器"
L["Enable Kick Indicator"] = "启用打断指示器"
L["Kick Ready Tick"] = "打断就绪标记"
L["Kick Not Ready"] = "打断未就绪"
L["Hide Non-Interruptible Casts"] = "隐藏不可打断的施法"
L["Timer Text Color"] = "计时器文本颜色"
L["Enable Shadow"] = "启用阴影"
L["Shadow Color"] = "阴影颜色"
L["Shadow X Offset"] = "阴影X偏移"
L["Shadow Y Offset"] = "阴影Y偏移"
L["Shadow X"] = "阴影X"
L["Shadow Y"] = "阴影Y"

------------------------------------------------------------------------
-- Hunter's Mark
------------------------------------------------------------------------
L["Enable Hunters Mark Tracking"] = "启用猎人印记追踪"
L["Hunters Mark Tracking"] = "猎人印记追踪"
L["MISSING MARK"] = "印记缺失"
L["This module only works inside raid instances and while out of combat."] = "此模块仅在团队副本中且脱离战斗时有效。"

------------------------------------------------------------------------
-- Gateway Alert
------------------------------------------------------------------------
L["Enable Gateway Alert"] = "启用传送门提醒"
L["Gateway Usable Alert"] = "传送门可用提醒"
L["GATE USABLE"] = "传送门可用"
L["Alert Color"] = "提醒颜色"

------------------------------------------------------------------------
-- Missing Buffs
------------------------------------------------------------------------
L["Enable Missing Buffs"] = "启用缺失增益"
L["Consumable & Buff Tracking"] = "消耗品与增益追踪"
L["Stance & Form Tracking"] = "姿态与形态追踪"
L["Stance Text Display"] = "姿态文本显示"
L["Enable Stance Text"] = "启用姿态文本"
L["Hide in Rested Areas"] = "在休息区域隐藏"
L["MISSING"] = "缺失"
L["Balance: Require Moonkin Form"] = "平衡：需要枭兽形态"
L["Feral: Require Cat Form"] = "野性：需要猎豹形态"
L["Guardian: Require Bear Form"] = "守护：需要巨熊形态"
L["Require Shadowform"] = "需要暗影形态"
L["Require Attunement"] = "需要调谐"
L["Shadow Priest Shadowform"] = "暗影牧师暗影形态"
L["Augmentation Evoker Attunement"] = "增辉唤魔师调谐"
L["Druid Forms"] = "德鲁伊形态"

------------------------------------------------------------------------
-- Automation
------------------------------------------------------------------------
L["Enable Automation"] = "启用自动化"
L["Merchant Automation"] = "商人自动化"
L["Quest Automation"] = "任务自动化"
L["Social"] = "社交"
L["Cinematics & Dialogs"] = "过场动画与对话"
L["Convenience"] = "便利"
L["Group Finder"] = "寻找队伍"
L["Auto Sell Junk (Grey Items)"] = "自动出售垃圾物品"
L["Auto Repair Gear"] = "自动修理装备"
L["Use Guild Funds for Repair"] = "使用公会资金修理"
L["Auto Accept Quests"] = "自动接受任务"
L["Auto Turn In Quests"] = "自动交还任务"
L["Hold to Pause Auto-Quest"] = "按住暂停自动任务"
L["Auto Loot"] = "自动拾取"
L["Auto Accept Role Check"] = "自动确认角色检查"
L["Auto Decline Duels"] = "自动拒绝决斗"
L["Auto Decline Pet Battle Duels"] = "自动拒绝宠物对战"
L["Auto-Fill DELETE Text"] = "自动填写删除文本"
L["Skip Cinematics & Movies"] = "跳过过场动画"
L["Hide Talking Head Frame"] = "隐藏说话头像"
L["Auto Filter AH to Current Expansion"] = "拍卖行自动筛选当前资料片"

------------------------------------------------------------------------
-- Copy Anything
------------------------------------------------------------------------
L["Enable Copy Anything"] = "启用复制任意内容"
L["Keybind"] = "按键"
L["Keybinding"] = "按键绑定"
L["Copy Keybind, Supports Single Letter Only"] = "复制按键，仅支持单个字母"
L["Copy Modifier Key(s)"] = "修饰键"

------------------------------------------------------------------------
------------------------------------------------------------------------
L["State Settings"] = "状态设置"
L["In Combat Color"] = "战斗中颜色"
L["Non Combat Color"] = "非战斗颜色"
L["Fade Duration (seconds)"] = "淡出时间（秒）"

------------------------------------------------------------------------
-- Cursor Circle
------------------------------------------------------------------------
L["Enable Cursor Circle"] = "启用光标圆圈"
L["Radius"] = "半径"

------------------------------------------------------------------------
-- Dragon Riding / Skyriding
------------------------------------------------------------------------
L["Enable Skyriding UI"] = "启用驭龙术界面"
L["Skyriding UI"] = "驭龙术界面"
L["Hide When Grounded"] = "着陆时隐藏"
L["Speed Font Size"] = "速度字体大小"
L["Vigor"] = "活力"
L["Vigor (Thrill)"] = "活力（刺激）"
L["Second Wind"] = "第二风"
L["Second Wind (On CD)"] = "第二风（冷却中）"
L["Whirling Surge"] = "旋风涌动"
L["Whirling Surge (On CD)"] = "旋风涌动（冷却中）"
L["Countdown Size"] = "倒计时大小"

------------------------------------------------------------------------
-- Externals & Defensives (Buff Icons)
------------------------------------------------------------------------
L["Enable Externals & Defensives"] = "启用外部与防御技能"
L["General Settings"] = "一般設定"
L["General Icon Settings"] = "图标设置"
L["Tracker Selection"] = "追踪器选择"
L["Tracker Settings"] = "追踪器设置"
L["Edit Tracker"] = "编辑追踪器"
L["Growth Direction"] = "增长方向"
L["Icon Size"] = "图标大小"
L["Icon Spacing"] = "图标间距"
L["Row Spacing"] = "行间距"
L["Spacing"] = "间距"
L["Show Cooldown Text"] = "显示冷却文本"
L["Duration (sec)"] = "持续时间（秒）"
L["Spell"] = "法术"
L["Type"] = "类型"
L["Reverse Icon"] = "反转图标"
L["Separator"] = "分隔符"
L["Separator Character"] = "分隔符字符"
L["Separator Color"] = "分隔符颜色"
L["Low Duration Warning"] = "低持续时间警告"
L["Warn Before Expiry"] = "到期前警告"
L["Minutes Left"] = "剩余分钟"
L["Charges Available"] = "充能可用"
L["Charges Unavailable"] = "充能不可用"
L["Charge Prefix"] = "充能前缀"

------------------------------------------------------------------------
-- Position & Layout (shared widgets)
------------------------------------------------------------------------
L["Position"] = "位置"
L["Display Settings"] = "顯示設定"
L["X Offset"] = "X偏移"
L["Y Offset"] = "Y偏移"
L["Strata"] = "层级"
L["Anchor"] = "锚点"
L["Anchored To"] = "锚定到"
L["Color"] = "顏色"
L["Color Mode"] = "顏色模式"
L["Custom Color"] = "自訂顏色"
L["Outline"] = "轮廓"

------------------------------------------------------------------------
-- Backdrop (shared)
------------------------------------------------------------------------
L["Backdrop Settings"] = "背景设置"
L["Enable Backdrop"] = "启用背景"
L["Backdrop Color"] = "背景颜色"
L["Backdrop Width"] = "背景宽度"
L["Backdrop Height"] = "背景高度"
L["Border"] = "边框"
L["Border Color"] = "边框颜色"
L["Border Size"] = "边框大小"
L["Background"] = "背景"
L["Use Shadow"] = "使用阴影"

------------------------------------------------------------------------
-- Profiles
------------------------------------------------------------------------
L["Active Profile"] = "当前配置"
L["Current Profile"] = "当前配置文件"
L["Global Profile"] = "全局配置"
L["Use Global Profile"] = "使用全局配置"
L["Profile Actions"] = "配置操作"
L["Profile Name"] = "設定檔名稱"
L["Profile Name (leave empty for default)"] = "配置名称（留空使用默认值）"
L["Profile"] = "設定檔"
L["New Name"] = "新名称"
L["Rename Profile"] = "重命名配置"
L["Copy From Profile"] = "从配置复制"
L["Source Profile"] = "源配置"
L["Profile to Delete"] = "要删除的配置"
L["Profile to Rename"] = "要重命名的配置"
L["Cannot delete the active profile"] = "无法删除当前活动配置"
L["Quick Actions"] = "快速操作"
L["Import / Export"] = "导入/导出"
L["Load"] = "載入"
L["Presets"] = "預設"

------------------------------------------------------------------------
-- Optimize
------------------------------------------------------------------------
L["Apply All"] = "全部套用"
L["Revert All"] = "全部還原"
L["Apply"] = "套用"
L["Revert"] = "還原"
L["Current"] = "目前"
L["Optimal"] = "最佳"
L["Saved"] = "已儲存"
L["No backup"] = "無備份"

------------------------------------------------------------------------
-- Notes / Info Strings
------------------------------------------------------------------------

------------------------------------------------------------------------
-- New keys (untranslated, will fall back to enUS)
------------------------------------------------------------------------
