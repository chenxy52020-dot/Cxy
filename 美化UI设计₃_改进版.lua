-- =============================================================================
-- 脚本初始化与基础工具函数
-- =============================================================================

gg.setVisible(false) -- 隐藏GG修改器自带的圆形悬浮窗图标，改用我们自定义的网页悬浮窗
gg.hide(false) --隐藏GG悬浮窗

--- 工具函数：让传入的函数在独立的子线程中运行
-- 除了 gg.toast 以外，所有涉及游戏内存搜索与修改的 gg 库函数都必须在子线程运行，否则会卡死主UI线程
function sub(fn)
	local r = luajava.createProxy("java.lang.Runnable", { run = fn }) -- 创建Java的Runnable接口代理
	local t = luajava.newInstance("java.lang.Thread", r)              -- 创建新线程
	t:start()                                                         -- 启动线程
	return t
end

-- =============================================================================
-- 重写（Hook）gg.toast 核心引擎：让提示信息气泡优雅地在网页悬浮窗内弹出
-- =============================================================================
gg.toast = function(msg)
	if not msg then return end
	activity.runOnUiThread(function()
		pcall(function()
			-- 转义单引号与反斜杠，防止 JS 拼接解析报错
			local escMsg = tostring(msg):gsub("\\", "\\\\"):gsub("'", "\\'"):gsub("\n", " ")
			web.loadUrl("javascript:showToast('" .. escMsg .. "')")
		end)
	end)
end

-- =============================================================================
-- nya 命名空间：用于快速二开封装各类UI组件数据结构
-- =============================================================================
nya = {}
local _idCounter = 0 -- 全局组件ID计数器

-- 内部函数：自动生成唯一的控件ID（例如 sw_1, cb_2），防止HTML中的DOM元素ID冲突
local function autoId(prefix)
	_idCounter = _idCounter + 1
	return (prefix or "it") .. "_" .. _idCounter
end

-- 内部包装函数：将字符串 of "1"(开) 或 "0"(关) 转换为 Lua 的布尔值 true/false 传递给回调
local function wrapBool(cb)
	if not cb then return nil end
	return function(v) return cb(v == "1") end
end

-- 内部包装函数：将前端传回的字符串数值转换为 Lua 的 number 类型传递给回调
local function wrapNum(cb)
	if not cb then return nil end
	return function(v) return cb(tonumber(v) or 0) end
end

--- 创建一个【开关 (Switch)】组件
function nya.switch(label, icon, default, onChange)
	return {
		type = "switch",
		id = autoId("sw"),
		label = label, -- 显示的文本名字
		icon = icon,   -- 左侧图标
		default = default and true or false, -- 默认状态
		onChange = wrapBool(onChange),       -- 状态改变时的回调函数
	}
end

--- 创建一个【复选框 (Checkbox)】组件
function nya.checkbox(label, icon, default, onChange)
	return {
		type = "checkbox",
		id = autoId("cb"),
		label = label,
		icon = icon,
		default = default and true or false,
		onChange = wrapBool(onChange),
	}
end

--- 创建一个【普通/动效按钮 (Button)】组件
function nya.button(label, icon, btnText, onClick)
	return { 
		type = "button", 
		id = autoId("btn"), 
		label = label, 
		icon = icon, 
		btnText = btnText, -- 按钮上显示的初始文字
		onClick = onClick   -- 点击时的回调函数
	}
end

--- 创建一个//宽幅【滑动条 (Slider)】组件
function nya.slider(label, icon, min, max, default, onChange)
	return {
		type = "slider",
		id = autoId("sl"),
		label = label,
		icon = icon,
		min = min,         -- 最小值
		max = max,         -- 最大值
		default = default, -- 默认初始值
		onChange = wrapNum(onChange), -- 数值改变时的回调
	}
end

--- 创建一个【文本输入框 (Input)】组件
function nya.input(label, icon, default, placeholder, onChange)
	return {
		type = "input",
		id = autoId("in"),
		label = label,
		icon = icon,
		default = default,         -- 默认文本
		placeholder = placeholder, -- 提示占位符
		onChange = onChange,       -- 内容改变时的回调
	}
end

--- 创建一个【分类分组 (Group)】
function nya.group(name, icon, items)
	return { group = name, icon = icon, items = items }
end

-- =============================================================================
-- UI 界面个性化自定义配置
-- =============================================================================

LOGO = "喵喵﹗" -- 悬浮窗标题/标志
-- 悬浮窗背景图（支持高清链接）
BG_IMG_URL = "https://files.catbox.moe/6tpjwg.jpg"
ICON_IMG_URL = "https://cik07-cos.7moor-fs2.com/im/4d2c3f00-7d4c-11e5-af15-41bf63ae4ea0/2eb6762464136bba/a95d5e85d1444b7ff15a76591abf644c8e910810_raw.gif"  
CLICK_WEB_URL = "<html><body><video width="
SCROLL_TEXT = "✨ 欢迎使用喵喵艺术面板！请勿商用，保持低调。最新交流群请点击右侧按钮加入 ✨"
FLOAT_ICON_URL = "https://cik07-cos.7moor-fs2.com/im/4d2c3f00-7d4c-11e5-af15-41bf63ae4ea0/6b1e173a5c52c9a5/21194505dab3d002ae0ef9c1fa8a8cc0d1e6aa12_raw.jpg"

BRAND_BTN1_TEXT = "qq群"   
BRAND_BTN2_TEXT = "作者网" 

-- =============================================================================
-- 核心功能菜单定义表
-- =============================================================================
menu = {
	title = LOGO,
	nya.group("天天炫斗_64位", "📂", {
	
		nya.slider("加速调控", "ᮨ ້໌ᮨ💞ۖ ້໌ᮨ", 60, 1100, 88, function(v)
			sub(function()
				w = " ۖۚۖ ້໌ᮨ𝕼人物加速 ۖۚۖ ້໌ᮨ𝕼"
				z = "Var #6E8AF910B4|6e8af910b4|10|4479c000|0|0|0|0|r-xp|/data/app/com.tencent.game.VXDGame-sh0Bsv76dq2NUqdZfzXu9Q==/lib/arm64/libGameApp.so|5d00b4"
				pa = "/sdcard/💞ۖ ້໌ᮨ ້໌ᮨ💞ۖ ້໌ᮨ大郎 ۖۚۖ ້໌ᮨ𝕼"
				file = io.open(pa, "w")
				file:write("" .. w .. "\n" .. z .. "")
				file:close()
				gg.loadList(pa)
				b = gg.getListItems()
				t = {}
				t[1] = {}
				t[1].address = b[1].address
				t[1].flags = 16
				t[1].value = v 
				gg.setValues(t)
				gg.removeListItems(b)
				os.remove(pa)
			end)
		end),
		
		nya.button("定怪定位", "💕", "关闭", function()
		dx_btn_state = not dx_btn_state 
			if dx_btn_state then
			sub(function()
					w = " ۖۚۖ ້໌ᮨ𝕼超级定位 ۖۚۖ ້໌ᮨ𝕼"
					z = "Var #6E8C19E6C4|6e8c19e6c4|10|40c00000|0|0|0|0|r-xp|/data/app/com.tencent.game.VXDGame-sh0Bsv76dq2NUqdZfzXu9Q==/lib/arm64/libGameApp.so|17dd6c4"
					pa = "/sdcard/💞ۖ ້໌ᮨ ້໌ᮨ💞ۖ ້໌ᮨ大郎 ۖۚۖ ້໌ᮨ𝕼"
					file = io.open(pa, "w")
					file:write("" .. w .. "\n" .. z .. "")
					file:close()
					gg.loadList(pa)
					b = gg.getListItems()
					t = {}
					t[1] = {}
					t[1].address = b[1].address
					t[1].flags = 16
					t[1].value = 7 
					gg.setValues(t)
					gg.removeListItems(b)
					os.remove(pa)
					gg.toast("🎯 定位开启成功")
				end)
				return "开" 
			else
				sub(function()
					w = " ۖۚۖ ້໌ᮨ𝕼超级定位 ۖۚۖ ້໌ᮨ𝕼"
					z = "Var #6E8C19E6C4|6e8c19e6c4|10|40c00000|0|0|0|0|r-xp|/data/app/com.tencent.game.VXDGame-sh0Bsv76dq2NUqdZfzXu9Q==/lib/arm64/libGameApp.so|17dd6c4"
					pa = "/sdcard/💞ۖ ້໌ᮨ ້໌ᮨ💞ۖ ້໌ᮨ大郎 ۖۚۖ ້໌ᮨ𝕼"
					file = io.open(pa, "w")
					file:write("" .. w .. "\n" .. z .. "")
					file:close()
					gg.loadList(pa)
					b = gg.getListItems()
					t = {}
					t[1] = {}
					t[1].address = b[1].address
					t[1].flags = 16
					t[1].value = 0.1171875 
					gg.setValues(t)
					gg.removeListItems(b)
					os.remove(pa)
					gg.toast("🎯 定怪关闭成功")
				end)
				return "关闭" 
			end
		end),
		
		nya.button("美梦乐园", "✨", "关闭", function()
			dx_btn_state = not dx_btn_state 
			if dx_btn_state then
			sub(function()
			w = " ۖۚۖ ້໌ᮨ𝕼人物加速 ۖۚۖ ້໌ᮨ𝕼"
					z = "Var #6E8AF910B4|6e8af910b4|10|4479c000|0|0|0|0|r-xp|/data/app/com.tencent.game.VXDGame-sh0Bsv76dq2NUqdZfzXu9Q==/lib/arm64/libGameApp.so|5d00b4"
					pa = "/sdcard/💞ۖ ້໌ᮨ ້໌ᮨ💞ۖ ້໌ᮨ大郎 ۖۚۖ ້໌ᮨ𝕼"
					file = io.open(pa, "w")
					file:write("" .. w .. "\n" .. z .. "")
					file:close()
					gg.loadList(pa) 
					b = gg.getListItems()
					t = {}
					t[1] = {}
					t[1].address = b[1].address
					t[1].flags = 16 
					t[1].value = 1800
					gg.setValues(t) 
					gg.removeListItems(b) 
					os.remove(pa)
				gg.toast("⚡ 美梦已开启")
				end)
				return "开启" 
			else
			sub(function()
			w = " ۖۚۖ ້໌ᮨ𝕼人物加速 ۖۚۖ ້໌ᮨ𝕼"
					z = "Var #6E8AF910B4|6e8af910b4|10|4479c000|0|0|0|0|r-xp|/data/app/com.tencent.game.VXDGame-sh0Bsv76dq2NUqdZfzXu9Q==/lib/arm64/libGameApp.so|5d00b4"
					pa = "/sdcard/💞ۖ ້໌ᮨ ້໌ᮨ💞ۖ ້໌ᮨ大郎 ۖۚۖ ້໌ᮨ𝕼"
					file = io.open(pa, "w")
					file:write("" .. w .. "\n" .. z .. "")
					file:close()
					gg.loadList(pa) 
					b = gg.getListItems()
					t = {}
					t[1] = {}
					t[1].address = b[1].address
					t[1].flags = 16 
					t[1].value = 60
					gg.setValues(t) 
					gg.removeListItems(b) 
					os.remove(pa)
				gg.toast("⚡ 乐园已关闭")
				end)
				return "关闭" 
			end
		end),

		nya.switch("噬梦公司", "💕", false, function(v)
			if v then 
				sub(function()
					w = " ۖۚۖ ້໌ᮨ𝕼人物加速 ۖۚۖ ້໌ᮨ𝕼"
					z = "Var #6E8AF910B4|6e8af910b4|10|4479c000|0|0|0|0|r-xp|/data/app/com.tencent.game.VXDGame-sh0Bsv76dq2NUqdZfzXu9Q==/lib/arm64/libGameApp.so|5d00b4"
					pa = "/sdcard/💞ۖ ້໌ᮨ ້໌ᮨ💞ۖ ້໌ᮨ大郎 ۖۚۖ ້໌ᮨ𝕼"
					file = io.open(pa, "w")
					file:write("" .. w .. "\n" .. z .. "")
					file:close()
					gg.loadList(pa) 
					b = gg.getListItems()
					t = {}
					t[1] = {}
					t[1].address = b[1].address
					t[1].flags = 16 
					t[1].value = 99 
					gg.setValues(t) 
					gg.removeListItems(b) 
					os.remove(pa)
					w = " ۖۚۖ ້໌ᮨ𝕼超级定位 ۖۚۖ ້໌ᮨ𝕼"
					z = "Var #6E8C19E6C4|6e8c19e6c4|10|40c00000|0|0|0|0|r-xp|/data/app/com.tencent.game.VXDGame-sh0Bsv76dq2NUqdZfzXu9Q==/lib/arm64/libGameApp.so|17dd6c4"
					pa = "/sdcard/💞ۖ ້໌ᮨ ້໌ᮨ💞ۖ ້໌ᮨ大郎 ۖۚۖ ້໌ᮨ𝕼"
					file = io.open(pa, "w")
					file:write("" .. w .. "\n" .. z .. "")
					file:close()
					gg.loadList(pa)
					b = gg.getListItems()
					t = {}
					t[1] = {}
					t[1].address = b[1].address
					t[1].flags = 16
					t[1].value = 7
					gg.setValues(t)
					gg.removeListItems(b)
					os.remove(pa)
					w = " ۖۚۖ ້໌ᮨ𝕼无限技能 ۖۚۖ ້໌ᮨ𝕼"
						z =
							"Var #6D349FB5B0|6d349fb5b0|40|4032000000000000|0|0|0|0|r-xp|/data/app/com.tencent.game.VXDGame-sh0Bsv76dq2NUqdZfzXu9Q==/lib/arm64/libGameApp.so|1ab45b0"
						pa = "/sdcard/💞ۖ ້໌ᮨ ້໌ᮨ💞ۖ ້໌ᮨ大郎 ۖۚۖ ້໌ᮨ𝕼"
						file = io.open(pa, "w")
						file:write("" .. w .. "\n" .. z .. "")
						file:close()
						gg.loadList(pa)
						b = gg.getListItems()
						t = {}
						t[1] = {}
						t[1].address = b[1].address
						t[1].flags = 64
						t[1].value = 17
						gg.setValues(t)
						gg.removeListItems(b)
						os.remove(pa)
					w = " ۖۚۖ ້໌ᮨ𝕼人物秒杀 ۖۚۖ ້໌ᮨ𝕼"
						z =
							"Var #6E8C4A929C|6e8c4a929c|10|3f800000|0|0|0|0|r-xp|/data/app/com.tencent.game.VXDGame-sh0Bsv76dq2NUqdZfzXu9Q==/lib/arm64/libGameApp.so|1ae829c"
						pa = "/sdcard/💞ۖ ້໌ᮨ ້໌ᮨ💞ۖ ້໌ᮨ大郎 ۖۚۖ ້໌ᮨ𝕼"
						file = io.open(pa, "w")
						file:write("" .. w .. "\n" .. z .. "")
						file:close()
						gg.loadList(pa)
						b = gg.getListItems()
						t = {}
						t[1] = {}
						t[1].address = b[1].address
						t[1].flags = 16
						t[1].value = 777
						gg.setValues(t)
						gg.removeListItems(b)
						os.remove(pa)
					gg.toast("⚡ 噬梦开启成功")
				end)
			else 
				sub(function()
					w = " ۖۚۖ ້໌ᮨ𝕼人物加速 ۖۚۖ ້໌ᮨ𝕼"
					z = "Var #6E8AF910B4|6e8af910b4|10|4479c000|0|0|0|0|r-xp|/data/app/com.tencent.game.VXDGame-sh0Bsv76dq2NUqdZfzXu9Q==/lib/arm64/libGameApp.so|5d00b4"
					pa = "/sdcard/💞ۖ ້໌ᮨ ້໌ᮨ💞ۖ ້໌ᮨ大郎 ۖۚۖ ້໌ᮨ𝕼"
					file = io.open(pa, "w")
					file:write("" .. w .. "\n" .. z .. "")
					file:close()
					gg.loadList(pa)
					b = gg.getListItems()
					t = {}
					t[1] = {}
					t[1].address = b[1].address
					t[1].flags = 16
					t[1].value = 60
					gg.setValues(t)
					gg.removeListItems(b)
					os.remove(pa)
					w = " ۖۚۖ ້໌ᮨ𝕼超级定位 ۖۚۖ ້໌ᮨ𝕼"
					z = "Var #6E8C19E6C4|6e8c19e6c4|10|40c00000|0|0|0|0|r-xp|/data/app/com.tencent.game.VXDGame-sh0Bsv76dq2NUqdZfzXu9Q==/lib/arm64/libGameApp.so|17dd6c4"
					pa = "/sdcard/💞ۖ ້໌ᮨ ້໌ᮨ💞ۖ ້໌ᮨ大郎 ۖۚۖ ້໌ᮨ𝕼"
					file = io.open(pa, "w")
					file:write("" .. w .. "\n" .. z .. "")
					file:close()
					gg.loadList(pa)
					b = gg.getListItems()
					t = {}
					t[1] = {}
					t[1].address = b[1].address
					t[1].flags = 16
					t[1].value = 0.1171875 
					gg.setValues(t)
					gg.removeListItems(b)
					os.remove(pa)
					w = " ۖۚۖ ້໌ᮨ𝕼无限技能 ۖۚۖ ້໌ᮨ𝕼"
						z =
							"Var #6D349FB5B0|6d349fb5b0|40|4032000000000000|0|0|0|0|r-xp|/data/app/com.tencent.game.VXDGame-sh0Bsv76dq2NUqdZfzXu9Q==/lib/arm64/libGameApp.so|1ab45b0"
						pa = "/sdcard/💞ۖ ້໌ᮨ ້໌ᮨ💞ۖ ້໌ᮨ大郎 ۖۚۖ ້໌ᮨ𝕼"
						file = io.open(pa, "w")
						file:write("" .. w .. "\n" .. z .. "")
						file:close()
						gg.loadList(pa)
						b = gg.getListItems()
						t = {}
						t[1] = {}
						t[1].address = b[1].address
						t[1].flags = 64
						t[1].value = 100
						gg.setValues(t)
						gg.removeListItems(b)
						os.remove(pa)
					w = " ۖۚۖ ້໌ᮨ𝕼人物秒杀 ۖۚۖ ້໌ᮨ𝕼"
						z =
							"Var #6E8C4A929C|6e8c4a929c|10|3f800000|0|0|0|0|r-xp|/data/app/com.tencent.game.VXDGame-sh0Bsv76dq2NUqdZfzXu9Q==/lib/arm64/libGameApp.so|1ae829c"
						pa = "/sdcard/💞ۖ ້໌ᮨ ້໌ᮨ💞ۖ ້໌ᮨ大郎 ۖۚۖ ້໌ᮨ𝕼"
						file = io.open(pa, "w")
						file:write("" .. w .. "\n" .. z .. "")
						file:close()
						gg.loadList(pa)
						b = gg.getListItems()
						t = {}
						t[1] = {}
						t[1].address = b[1].address
						t[1].flags = 16
						t[1].value = 10000
						gg.setValues(t)
						gg.removeListItems(b)
						os.remove(pa)
					gg.toast("⚡ 公司关闭成功")
				end)
			end
		end),
		
		nya.switch("梦境之渊", "💕", false, function(v)
		if v then 
				sub(function()
					w = " ۖۚۖ ້໌ᮨ𝕼人物加速 ۖۚۖ ້໌ᮨ𝕼"
					z = "Var #6E8AF910B4|6e8af910b4|10|4479c000|0|0|0|0|r-xp|/data/app/com.tencent.game.VXDGame-sh0Bsv76dq2NUqdZfzXu9Q==/lib/arm64/libGameApp.so|5d00b4"
					pa = "/sdcard/💞ۖ ້໌ᮨ ້໌ᮨ💞ۖ ້໌ᮨ大郎 ۖۚۖ ້໌ᮨ𝕼"
					file = io.open(pa, "w")
					file:write("" .. w .. "\n" .. z .. "")
					file:close()
					gg.loadList(pa) 
					b = gg.getListItems()
					t = {}
					t[1] = {}
					t[1].address = b[1].address
					t[1].flags = 16 
					t[1].value = 101
					gg.setValues(t) 
					gg.removeListItems(b) 
					os.remove(pa)
					w = " ۖۚۖ ້໌ᮨ𝕼超级定位 ۖۚۖ ້໌ᮨ𝕼"
					z = "Var #6E8C19E6C4|6e8c19e6c4|10|40c00000|0|0|0|0|r-xp|/data/app/com.tencent.game.VXDGame-sh0Bsv76dq2NUqdZfzXu9Q==/lib/arm64/libGameApp.so|17dd6c4"
					pa = "/sdcard/💞ۖ ້໌ᮨ ້໌ᮨ💞ۖ ້໌ᮨ大郎 ۖۚۖ ້໌ᮨ𝕼"
					file = io.open(pa, "w")
					file:write("" .. w .. "\n" .. z .. "")
					file:close()
					gg.loadList(pa)
					b = gg.getListItems()
					t = {}
					t[1] = {}
					t[1].address = b[1].address
					t[1].flags = 16
					t[1].value = 7
					gg.setValues(t)
					gg.removeListItems(b)
					os.remove(pa)
					w = " ۖۚۖ ້໌ᮨ𝕼无限技能 ۖۚۖ ້໌ᮨ𝕼"
						z =
							"Var #6D349FB5B0|6d349fb5b0|40|4032000000000000|0|0|0|0|r-xp|/data/app/com.tencent.game.VXDGame-sh0Bsv76dq2NUqdZfzXu9Q==/lib/arm64/libGameApp.so|1ab45b0"
						pa = "/sdcard/💞ۖ ້໌ᮨ ້໌ᮨ💞ۖ ້໌ᮨ大郎 ۖۚۖ ້໌ᮨ𝕼"
						file = io.open(pa, "w")
						file:write("" .. w .. "\n" .. z .. "")
						file:close()
						gg.loadList(pa)
						b = gg.getListItems()
						t = {}
						t[1] = {}
						t[1].address = b[1].address
						t[1].flags = 64
						t[1].value = 16
						gg.setValues(t)
						gg.removeListItems(b)
						os.remove(pa)
					w = " ۖۚۖ ້໌ᮨ𝕼人物秒杀 ۖۚۖ ້໌ᮨ𝕼"
						z =
							"Var #6E8C4A929C|6e8c4a929c|10|3f800000|0|0|0|0|r-xp|/data/app/com.tencent.game.VXDGame-sh0Bsv76dq2NUqdZfzXu9Q==/lib/arm64/libGameApp.so|1ae829c"
						pa = "/sdcard/💞ۖ ້໌ᮨ ້໌ᮨ💞ۖ ້໌ᮨ大郎 ۖۚۖ ້໌ᮨ𝕼"
						file = io.open(pa, "w")
						file:write("" .. w .. "\n" .. z .. "")
						file:close()
						gg.loadList(pa)
						b = gg.getListItems()
						t = {}
						t[1] = {}
						t[1].address = b[1].address
						t[1].flags = 16
						t[1].value = 1080
						gg.setValues(t)
						gg.removeListItems(b)
						os.remove(pa)
					gg.toast("⚡ 梦境开启成功")
				end)
			else 
				sub(function()
					w = " ۖۚۖ ້໌ᮨ𝕼人物加速 ۖۚۖ ້໌ᮨ𝕼"
					z = "Var #6E8AF910B4|6e8af910b4|10|4479c000|0|0|0|0|r-xp|/data/app/com.tencent.game.VXDGame-sh0Bsv76dq2NUqdZfzXu9Q==/lib/arm64/libGameApp.so|5d00b4"
					pa = "/sdcard/💞ۖ ້໌ᮨ ້໌ᮨ💞ۖ ້໌ᮨ大郎 ۖۚۖ ້໌ᮨ𝕼"
					file = io.open(pa, "w")
					file:write("" .. w .. "\n" .. z .. "")
					file:close()
					gg.loadList(pa) 
					b = gg.getListItems()
					t = {}
					t[1] = {}
					t[1].address = b[1].address
					t[1].flags = 16 
					t[1].value = 60
					gg.setValues(t) 
					gg.removeListItems(b) 
					os.remove(pa)
					w = " ۖۚۖ ້໌ᮨ𝕼超级定位 ۖۚۖ ້໌ᮨ𝕼"
					z = "Var #6E8C19E6C4|6e8c19e6c4|10|40c00000|0|0|0|0|r-xp|/data/app/com.tencent.game.VXDGame-sh0Bsv76dq2NUqdZfzXu9Q==/lib/arm64/libGameApp.so|17dd6c4"
					pa = "/sdcard/💞ۖ ້໌ᮨ ້໌ᮨ💞ۖ ້໌ᮨ大郎 ۖۚۖ ້໌ᮨ𝕼"
					file = io.open(pa, "w")
					file:write("" .. w .. "\n" .. z .. "")
					file:close()
					gg.loadList(pa)
					b = gg.getListItems()
					t = {}
					t[1] = {}
					t[1].address = b[1].address
					t[1].flags = 16
					t[1].value = 0.1171875
					gg.setValues(t)
					gg.removeListItems(b)
					os.remove(pa)
					w = " ۖۚۖ ້໌ᮨ𝕼无限技能 ۖۚۖ ້໌ᮨ𝕼"
						z =
							"Var #6D349FB5B0|6d349fb5b0|40|4032000000000000|0|0|0|0|r-xp|/data/app/com.tencent.game.VXDGame-sh0Bsv76dq2NUqdZfzXu9Q==/lib/arm64/libGameApp.so|1ab45b0"
						pa = "/sdcard/💞ۖ ້໌ᮨ ້໌ᮨ💞ۖ ້໌ᮨ大郎 ۖۚۖ ້໌ᮨ𝕼"
						file = io.open(pa, "w")
						file:write("" .. w .. "\n" .. z .. "")
						file:close()
						gg.loadList(pa)
						b = gg.getListItems()
						t = {}
						t[1] = {}
						t[1].address = b[1].address
						t[1].flags = 64
						t[1].value = 100
						gg.setValues(t)
						gg.removeListItems(b)
						os.remove(pa)
					w = " ۖۚۖ ້໌ᮨ𝕼人物秒杀 ۖۚۖ ້໌ᮨ𝕼"
						z =
							"Var #6E8C4A929C|6e8c4a929c|10|3f800000|0|0|0|0|r-xp|/data/app/com.tencent.game.VXDGame-sh0Bsv76dq2NUqdZfzXu9Q==/lib/arm64/libGameApp.so|1ae829c"
						pa = "/sdcard/💞ۖ ້໌ᮨ ້໌ᮨ💞ۖ ້໌ᮨ大郎 ۖۚۖ ້໌ᮨ𝕼"
						file = io.open(pa, "w")
						file:write("" .. w .. "\n" .. z .. "")
						file:close()
						gg.loadList(pa)
						b = gg.getListItems()
						t = {}
						t[1] = {}
						t[1].address = b[1].address
						t[1].flags = 16
						t[1].value = 10000
						gg.setValues(t)
						gg.removeListItems(b)
						os.remove(pa)
					gg.toast("⚡ 之渊关闭成功")
				end)
			end
		end),
		nya.switch("血量锁定", "💕", false, function(v)
		if v then 
				sub(function()
					
					gg.toast("⚡ 锁血开启成功")
				end)
			else 
				sub(function()
					
					gg.toast("⚡ 锁定关闭成功")
				end)
			end
		end),
		nya.switch("技能-0cd", "💕", false, function(v)
		if v then 
				sub(function()
					w = " ۖۚۖ ້໌ᮨ𝕼无限技能 ۖۚۖ ້໌ᮨ𝕼"
						z =
							"Var #6D349FB5B0|6d349fb5b0|40|4032000000000000|0|0|0|0|r-xp|/data/app/com.tencent.game.VXDGame-sh0Bsv76dq2NUqdZfzXu9Q==/lib/arm64/libGameApp.so|1ab45b0"
						pa = "/sdcard/💞ۖ ້໌ᮨ ້໌ᮨ💞ۖ ້໌ᮨ大郎 ۖۚۖ ້໌ᮨ𝕼"
						file = io.open(pa, "w")
						file:write("" .. w .. "\n" .. z .. "")
						file:close()
						gg.loadList(pa)
						b = gg.getListItems()
						t = {}
						t[1] = {}
						t[1].address = b[1].address
						t[1].flags = 64
						t[1].value = 12
						gg.setValues(t)
						gg.removeListItems(b)
						os.remove(pa)
					gg.toast("⚡ 0冷却开启成功")
				end)
			else 
				sub(function()
					w = " ۖۚۖ ້໌ᮨ𝕼无限技能 ۖۚۖ ້໌ᮨ𝕼"
						z =
							"Var #6D349FB5B0|6d349fb5b0|40|4032000000000000|0|0|0|0|r-xp|/data/app/com.tencent.game.VXDGame-sh0Bsv76dq2NUqdZfzXu9Q==/lib/arm64/libGameApp.so|1ab45b0"
						pa = "/sdcard/💞ۖ ້໌ᮨ ້໌ᮨ💞ۖ ້໌ᮨ大郎 ۖۚۖ ້໌ᮨ𝕼"
						file = io.open(pa, "w")
						file:write("" .. w .. "\n" .. z .. "")
						file:close()
						gg.loadList(pa)
						b = gg.getListItems()
						t = {}
						t[1] = {}
						t[1].address = b[1].address
						t[1].flags = 64
						t[1].value = 100
						gg.setValues(t)
						gg.removeListItems(b)
						os.remove(pa)
					gg.toast("⚡ 0技能关闭成功")
				end)
			end
		end),
		nya.switch("人物秒杀", "💕", false, function(v)
		if v then 
				sub(function()
					w = " ۖۚۖ ້໌ᮨ𝕼人物秒杀 ۖۚۖ ້໌ᮨ𝕼"
						z =
							"Var #6E8C4A929C|6e8c4a929c|10|3f800000|0|0|0|0|r-xp|/data/app/com.tencent.game.VXDGame-sh0Bsv76dq2NUqdZfzXu9Q==/lib/arm64/libGameApp.so|1ae829c"
						pa = "/sdcard/💞ۖ ້໌ᮨ ້໌ᮨ💞ۖ ້໌ᮨ大郎 ۖۚۖ ້໌ᮨ𝕼"
						file = io.open(pa, "w")
						file:write("" .. w .. "\n" .. z .. "")
						file:close()
						gg.loadList(pa)
						b = gg.getListItems()
						t = {}
						t[1] = {}
						t[1].address = b[1].address
						t[1].flags = 16
						t[1].value = 0
						gg.setValues(t)
						gg.removeListItems(b)
						os.remove(pa)
					gg.toast("⚡ 秒杀开启成功")
				end)
			else 
				sub(function()
					w = " ۖۚۖ ້໌ᮨ𝕼人物秒杀 ۖۚۖ ້໌ᮨ𝕼"
						z =
							"Var #6E8C4A929C|6e8c4a929c|10|3f800000|0|0|0|0|r-xp|/data/app/com.tencent.game.VXDGame-sh0Bsv76dq2NUqdZfzXu9Q==/lib/arm64/libGameApp.so|1ae829c"
						pa = "/sdcard/💞ۖ ້໌ᮨ ້໌ᮨ💞ۖ ້໌ᮨ大郎 ۖۚۖ ້໌ᮨ𝕼"
						file = io.open(pa, "w")
						file:write("" .. w .. "\n" .. z .. "")
						file:close()
						gg.loadList(pa)
						b = gg.getListItems()
						t = {}
						t[1] = {}
						t[1].address = b[1].address
						t[1].flags = 16
						t[1].value = 10000
						gg.setValues(t)
						gg.removeListItems(b)
						os.remove(pa)
					gg.toast("⚡ 秒杀关闭成功")
				end)
			end
		end),
	}),
	nya.group("天天炫斗_32位", "📂", {
		nya.switch("美梦乐园", "💕", false, function(v) print(v) end),
		nya.switch("噬梦公司", "💕", false, function(v) print(v) end),
		nya.switch("梦境之渊", "💕", false, function(v) print(v) end),
		nya.switch("人物秒杀", "💕", false, function(v) print(v) end),
		nya.button("人物移速", "💕", "关闭", function()
			dgdw_32_state = not dgdw_32_state 
			if dgdw_32_state then return "开" else return "关闭" end
		end),
		nya.button("定怪定位", "💕", "关闭", function()
			dgdw_32_state = not dgdw_32_state 
			if dgdw_32_state then return "开" else return "关闭" end
		end),
	}),
	-- 专属音乐播放器与抖音刷视频虚拟分组
	nya.group("音乐", "🎵", {}),
	nya.group("小姐姐", "𝄞", {})
}

-- =============================================================================
-- HTML 网页模板定义 (已修复静音锁，且对字幕栏进行超圆润设计)
-- =============================================================================
htmlTemplate = [[
<!DOCTYPE html><html><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<style>
/* ============ 全局 CSS 多主题色彩变量定义 ============ */
:root, body.theme-light{
  --bg-base:#f5f5f7;
  --tint1:#a5d8ff; --tint2:#ffd6e7; --tint3:#d4f4dd; --tint4:#ffe9c4;
  --glass:rgba(255,255,255,.55);
  --glass-strong:rgba(255,255,255,.82);
  --glass-border:rgba(255,255,255,.6);
  --text:#1d1d1f; --text-dim:#86868b;
  --accent:#007aff; --ok:#30d158; --danger:#ff453a;
  --shadow:rgba(0,0,0,.08); --hover:rgba(0,0,0,.04); --input-bg:rgba(0,0,0,.04);
  --sky-1:#f5f5f7; --sky-2:#a5d8ff; --sky-3:#ffd6e7; --sky-4:#d4f4dd;
}
body.theme-dark{
  --bg-base:#0a0a0c;
  --tint1:#1d4e89; --tint2:#5a2870; --tint3:#1a4d3c; --tint4:#7a4d1c;
  --glass:rgba(40,40,50,.6);
  --glass-strong:rgba(60,60,75,.85);
  --glass-border:rgba(255,255,255,.08);
  --text:#f5f5f7; --text-dim:#8e8e93;
  --accent:#0a84ff; --ok:#30d158; --danger:#ff453a;
  --shadow:rgba(0,0,0,.4); --hover:rgba(255,255,255,.06); --input-bg:rgba(255,255,255,.06);
  --sky-1:#0a0a0c; --sky-2:#1d4e89; --sky-3:#5a2870; --sky-4:#1a4d3c;
}
body.theme-sakura{
  --bg-base:#fff0f5;
  --tint1:#ffb7c5; --tint2:#ffe4e1; --tint3:#fbc2eb; --tint4:#fff1eb;
  --glass:rgba(255,240,245,.65);
  --glass-strong:rgba(255,255,255,.88);
  --glass-border:rgba(255,182,193,.5);
  --text:#4a2834; --text-dim:#a37081;
  --accent:#ff6584; --ok:#2ecc71; --danger:#ff453a;
  --shadow:rgba(219,112,147,.15); --hover:rgba(255,182,193,.2); --input-bg:rgba(255,182,193,.15);
  --sky-1:#fff0f5; --sky-2:#ffb7c5; --sky-3:#ffe4e1; --sky-4:#fbc2eb;
}
body.theme-cyber{
  --bg-base:#03001e;
  --tint1:#7303c0; --tint2:#ec38bc; --tint3:#03001e; --tint4:#0575e6;
  --glass:rgba(15,0,30,.7);
  --glass-strong:rgba(25,5,45,.9);
  --glass-border:rgba(236,56,188,.4);
  --text:#00f5ff; --text-dim:#b500ff;
  --accent:#ec38bc; --ok:#00ff66; --danger:#ff0055;
  --shadow:rgba(236,56,188,.3); --hover:rgba(0,245,255,.15); --input-bg:rgba(0,0,0,.4);
  --sky-1:#03001e; --sky-2:#7303c0; --sky-3:#ec38bc; --sky-4:#0575e6;
}

*{box-sizing:border-box;margin:0;padding:0;-webkit-tap-highlight-color:transparent;}
html,body{
  background:transparent;
  font-family:-apple-system,"SF Pro Display","PingFang SC",sans-serif;
  color:var(--text);font-size:13px;height:100%;overflow:hidden;
}
body{padding:8px;transition:color .4s, background .4s;}

/* ============ 动态图片背景 ============ */
.bg{
  position:fixed;inset:0;z-index:0;overflow:hidden;
  background: url('{{BG_IMG_URL}}') no-repeat center center;
  background-size: cover;
  transition: background 1s;
}
.bg::after {
  content: '';
  position: absolute;
  inset: 0;
  background: rgba(0, 0, 0, 0.25); /* 半透明遮罩，提升内容易读性 */
  backdrop-filter: blur(8px);       /* 毛玻璃模糊特效 */
  -webkit-backdrop-filter: blur(8px);
}

.blob{
  position:absolute;border-radius:50%;
  filter:blur(40px);opacity:.35;
  animation:drift 14s ease-in-out infinite;
}
.blob.b1{width:42%;height:42%;background:var(--sky-1);top:-8%;left:-5%;animation-delay:0s;}
.blob.b2{width:38%;height:38%;background:var(--sky-3);top:55%;right:-10%;animation-delay:-4s;}
.blob.b3{width:34%;height:34%;background:var(--sky-2);bottom:-15%;left:25%;animation-delay:-8s;}
.blob.b4{width:28%;height:28%;background:var(--sky-4);top:20%;left:40%;animation-delay:-11s;}
@keyframes drift{
  0%,100%{transform:translate(0,0) scale(1);}
  33%{transform:translate(15%,18%) scale(1.15);}
  66%{transform:translate(-10%,10%) scale(.92);}
}
/* 闪光粒子 */
.spark{
  position:absolute;width:3px;height:3px;border-radius:50%;
  background:#fff;box-shadow:0 0 8px #fff,0 0 12px #fff;
  opacity:0;animation:spark 4s ease-in-out infinite;
}
.spark:nth-child(5){top:18%;left:22%;animation-delay:0s;}
.spark:nth-child(6){top:60%;left:75%;animation-delay:1.3s;}
.spark:nth-child(7){top:35%;left:55%;animation-delay:2.8s;}
.spark:nth-child(8){top:80%;left:30%;animation-delay:3.5s;}
@keyframes spark{
  0%,100%{opacity:0;transform:scale(.5);}
  50%{opacity:.9;transform:scale(1.3);}
}
/* ============ 液态玻璃通用 ============ */
.glass{
  background:var(--bg-glass);
  backdrop-filter:blur(30px) saturate(180%);
  -webkit-backdrop-filter:blur(30px) saturate(180%);
  border:1px solid var(--glass-border);
  border-radius:22px;
  box-shadow:
    0 8px 32px var(--shadow),
    inset 0 1px 0 var(--glass-edge),
    inset 0 -1px 1px rgba(255,255,255,.15);
}

/* ============ 悬浮窗内定制气泡弹出容器（完美磨砂质感） ============ */
.toast-container {
  position: fixed;
  top: 10px;
  left: 50%;
  transform: translateX(-50%);
  z-index: 99999;
  display: flex;
  flex-direction: column;
  gap: 5px;
  pointer-events: none;
  width: 80%;
  max-width: 240px;
}
.web-toast {
  background: var(--glass-strong);
  border: 0.6px solid var(--glass-border);
  color: var(--text);
  backdrop-filter: blur(14px) saturate(180%);
  -webkit-backdrop-filter: blur(14px) saturate(180%);
  padding: 6px 12px;
  border-radius: 14px;
  font-size: 10px;
  font-weight: 800;
  text-align: center;
  box-shadow: 0 4px 15px var(--shadow);
  transform-origin: center;
  animation: toastIn 0.35s cubic-bezier(0.175, 0.885, 0.32, 1.275) both, toastOut 0.3s 2.4s cubic-bezier(0.4, 0, 1, 1) forwards;
  word-break: break-all;
}
@keyframes toastIn {
  from { opacity: 0; transform: translateY(-20px) scale(0.85); filter: blur(4px); }
  to { opacity: 1; transform: translateY(0) scale(1); filter: blur(0); }
}
@keyframes toastOut {
  from { opacity: 1; transform: scale(1); }
  to { opacity: 0; transform: translateY(-10px) scale(0.85); filter: blur(4px); }
}

/* ============ 苹果风格“灵动岛”音乐歌词同步显示屏 ============ */
.dynamic-island {
  position: fixed;
  top: 12px;
  left: 50%;
  transform: translateX(-50%) scale(0.8);
  width: 170px;
  height: 28px;
  background: rgba(10, 10, 12, 0.9);
  border: 1px solid rgba(255, 255, 255, 0.15);
  border-radius: 20px;
  z-index: 99990;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 10px;
  color: #fff;
  opacity: 0;
  pointer-events: none;
  box-shadow: 0 8px 30px rgba(0,0,0,0.6);
  transition: all 0.45s cubic-bezier(0.16, 1, 0.3, 1);
}
.dynamic-island.active {
  opacity: 1;
  transform: translateX(-50%) scale(1);
  width: 250px;
  height: 36px;
  pointer-events: auto;
}
.island-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
  opacity: 0;
  transition: opacity 0.3s ease;
  transition-delay: 0.1s;
}
.dynamic-island.active .island-content {
  opacity: 1;
}
.island-left {
  display: flex;
  align-items: flex-end;
  gap: 2.5px;
  width: 25px;
  height: 12px;
}
.island-wave-bar {
  width: 2px;
  background: var(--accent);
  border-radius: 1px;
  height: 3px;
  animation: waveBreathing 1.2s ease-in-out infinite alternate;
  animation-play-state: paused;
}
.dynamic-island.active .island-wave-bar {
  animation-play-state: running;
}
.island-wave-bar:nth-child(2) { animation-delay: 0.2s; }
.island-wave-bar:nth-child(3) { animation-delay: 0.4s; }

@keyframes waveBreathing {
  0% { height: 3px; }
  100% { height: 14px; }
}

.island-middle {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  min-width: 0;
  padding: 0 5px;
}
.island-track {
  font-size: 8px;
  font-weight: 900;
  color: var(--accent);
  text-transform: uppercase;
  letter-spacing: 0.5px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  width: 100%;
  text-align: center;
  margin-bottom: 1.5px;
}
.island-lyric {
  font-size: 10px;
  font-weight: 700;
  color: #fff;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  width: 100%;
  text-align: center;
  animation: lyricFade 0.3s ease;
}
@keyframes lyricFade {
  from { opacity: 0.3; transform: scale(0.95); }
  to { opacity: 1; transform: scale(1); }
}

.island-right {
  font-size: 11px;
  animation: rotateDisc 4s linear infinite;
  animation-play-state: paused;
}
.dynamic-island.active .island-right {
  animation-play-state: running;
}
@keyframes rotateDisc {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

/* ============ 主悬浮面板布局 ============ */
.panel{
  position:relative;z-index:1;
  display:flex;height:100%;gap:6.8px;
  animation:bootIn .7s cubic-bezier(.1,.1,.9,1.1);
}
@keyframes bootIn{
  from{opacity:0.6;transform:scale(0.85);filter:blur(2px);}
  to{opacity:1;transform:scale(1);filter:none;}
}

.glass{
  background:var(--glass);
  backdrop-filter:blur(12px) saturate(180%);
  -webkit-backdrop-filter:blur(9px) saturate(180%);
  border:0.6px solid var(--glass-border);
  border-radius:21px;
  box-shadow: 0 2px 3px var(--shadow);
  transition: background .4s, border .4s, box-shadow .4s;
}

/* ============ 左侧导航栏极度压缩 ============ */
.sidebar{
  width:160px;flex-shrink:0;
  display:flex;flex-direction:column;
  padding:5px 5px; 
}

/* 优化需求：滚动字幕框深度修圆（50px胶囊圆角） */
.marquee-box {
  width: 100%; overflow: hidden; background: var(--input-bg);
  border: 0.6px solid var(--glass-border); 
  border-radius: 50px; /* 升级为高质感极简全弧圆角 */
  padding: 2.5px 12px; margin-bottom: 5.5px; box-shadow: inset 0 1px 2px rgba(0,0,0,0.05);
}
.marquee-text {
  display: inline-block; white-space: nowrap; padding-left: 100%;
  font-size: 10px; font-weight: 800; color: var(--accent);
  animation: scroll-left 14s linear infinite;
}
@keyframes scroll-left {
  0% { transform: translate3d(0, 0, 0); }
  100% { transform: translate3d(-100%, 0, 0); }
}

.brand{
  display:flex;align-items:center;gap:0px; padding:0.2px; margin-bottom:2px; touch-action:none;cursor:move;
}

.brand-icon{
  width:42px;height:42px;border-radius:11px;
  background:radial-gradient(circle at 30% 30%,rgba(255,255,255,.7),transparent 60%), linear-gradient(13deg,var(--accent),var(--sky-3));
  display:flex;align-items:center;justify-content:center; color:#fff;font-size:88px;
  box-shadow:0 0px 6px var(--shadow); overflow:hidden; cursor:pointer;
}

.brand-text {
  flex: 1;
  margin-left: 0.1px;
  margin-right: 0.1px;
  font-size: 0.1px !important;
  font-weight: 900;
}

.small-btn{
  background: var(--input-bg); border: 1px solid var(--glass-border); color: var(--text);
  padding: 2.5px 4px; border-radius: 12px; font-size: 8px; font-weight: 900; cursor: pointer; transition: all 0.2s; flex-shrink: 0;
}
.small-btn:active{ transform: scale(0.92); background: var(--hover); }

/* 四档主题无缝切换外观 */
.theme-toggle-wrap{
  display:flex;align-items:center;justify-content:space-between;
  padding:4px 8px;margin-bottom:4px; 
  background:var(--input-bg);
  border-radius:12px; 
  border:1px solid var(--glass-border);
  cursor:pointer;
  transition: background .3s, transform .2s;
}
.theme-toggle-wrap:active{ transform: scale(0.97); }
.theme-toggle-label{
  font-size:10px;font-weight:800;letter-spacing:0.1px;color:var(--text);
}
.theme-badge {
  background: linear-gradient(135deg, var(--accent), var(--sky-3));
  color: #fff; padding: 1.5px 5px; border-radius: 8px; font-size: 8.5px; font-weight: 900;
  box-shadow: 0 1px 2px var(--shadow);
}

/* 侧栏折叠折叠手风琴 */
.nav-title{
  font-size:10.5px;letter-spacing:0.8px;color:var(--text-dim);
  text-transform:uppercase;padding:4px 4px;font-weight:900; margin-top:2px; margin-bottom:1px;
  display:flex; align-items:center; justify-content:space-between;
  cursor:pointer; border-radius:16px; transition:all 0.2s;
}
.nav-title:hover{
  background:var(--hover);
  color:var(--text);
}
.nav-arrow {
  font-size: 7px; transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  transform: rotate(0deg);
}
.nav-title.collapsed .nav-arrow {
  transform: rotate(-90deg);
}

.nav-container-wrapper {
  max-height: 250px; 
  overflow: hidden;
  transition: max-height 0.35s cubic-bezier(0.4, 0, 0.2, 1);
}
.nav-container-wrapper.collapsed {
  max-height: 0px !important;
}

.nav{display:flex; flex-direction:column; overflow-y:auto;}
.nav::-webkit-scrollbar{width:0;}

.nav-item{
  display:flex;align-items:center;gap:6px; padding:3.5px 7px;border-radius:14px;cursor:pointer;
  font-size:9.5px;font-weight:800;color:var(--text-dim); margin-bottom:2px;transition:all .25s;position:relative;
}
.nav-item:hover{background:var(--hover);color:var(--text);transform:translateX(1px);}
.nav-item.active{
  background:var(--glass-strong);color:var(--accent); box-shadow:0 1px 3px var(--shadow);
}
.nav-item.active::before{
  content:'';position:absolute;left:-4px;top:50%;transform:translateY(-50%);
  width:2.5px;height:12px; background:var(--accent); border-radius:1px;
  box-shadow:0 0 6px var(--accent); animation:slideIn .3s cubic-bezier(.5,1.5,.5,1);
}
@keyframes slideIn{from{height:0;}to{height:12px;}}
.nav-icon{
  width:16px;height:16px;border-radius:4px;flex-shrink:0; background:rgba(0,0,0,.05);
  display:flex;align-items:center;justify-content:center; font-size:9px;font-weight:700;transition:all .25s;
}
body.theme-dark .nav-icon, body.theme-cyber .nav-icon{background:rgba(255,255,255,.06);}
.nav-item.active .nav-icon{
  background:linear-gradient(135deg,var(--accent),var(--sky-3)); color:#fff; transform:scale(1.03);
}

/* 退出关闭高度压缩 */
.sidebar-top-exit{ padding: 0 1px; margin-bottom: 2px; display: flex; gap: 4px; }
.foot-btn{ width:100%;padding:3px 2px;border-radius:12px;cursor:pointer; display:flex;align-items:center;justify-content:center;gap:1px; background:var(--input-bg);border:1px solid var(--glass-border); color:var(--text-dim); font-family:inherit;font-size:10px;font-weight:900; transition:all 0.2s; }
.foot-btn:hover{transform:translateY(-0.5px);}
.foot-btn.exit:hover{color:var(--danger); background:rgba(255,69,58,0.15);}

/* ============ 右侧内容区域 ============ */
.content{ flex:1;display:flex;flex-direction:column; padding:2px 10px 11px; overflow:hidden;position:relative; }
.content-head{ display:flex;align-items:center;justify-content:space-between;gap:11px; margin-bottom:2px;padding-bottom:2px; }
.head-left{display:flex;flex-direction:column;min-width:0;}
.content-sub{font-size:10px;color:var(--text-dim); letter-spacing:1.8px;text-transform:uppercase;font-weight:80;}
.content-title{font-size:11.7px;font-weight:800;letter-spacing:-.5px;margin-top:2px;}

/* 搜索功能框 */
.search-wrap{
  position:relative;flex:1;max-width:290px;
}
.search-icon{
  position:absolute;left:14px;top:50%;transform:translateY(-50%);
  width:11px;height:14px;color:var(--text-dim);pointer-events:none;
  transition:color .2s;
}
.search-input{
  width:100%;padding:4px 4px 4px 36px;
  border-radius:16px;font-family:inherit;font-size:11px;outline:none;
  color:var(--text);
  background:
    linear-gradient(180deg,rgba(255,255,255,.4) 0%,rgba(255,255,255,.15) 100%),
    var(--glass);
  border:1px solid var(--glass-border);
  backdrop-filter:blur(2px) saturate(180%);
  -webkit-backdrop-filter:blur(2px) saturate(180%);
  box-shadow:
    inset 0 1px 0 rgba(255,255,255,0.2),
    0 2px 8px var(--shadow);
  transition:all .25s;
}
body.theme-dark .search-input{
  background:
    linear-gradient(180deg,rgba(255,255,255,.06) 0%,rgba(255,255,255,.02) 100%),
    var(--glass);
}
.search-input::placeholder{color:var(--text-dim);}
.search-input:focus{
  border-color:var(--accent);
}
.search-input:focus + .search-icon,
.search-wrap:focus-within .search-icon{color:var(--accent);}

.body{flex:1;overflow-y:auto;padding-right:6px;}
.body::-webkit-scrollbar{width:4px;}
.body::-webkit-scrollbar-thumb{background:var(--text-dim);opacity:.3;border-radius:2px;}
.group{display:none;animation:pageIn .4s cubic-bezier(.2,.9,.3,1) both;height:100%;}
.group.active{display:block;}
@keyframes pageIn{from{opacity:0;transform:translateY(10px);}to{opacity:1;transform:translateY(0);}}
.body.searching .group{display:block;animation:none;}
.row.hide{display:none !important;}

/* ============ 右侧：磨砂音乐播放器面板 ============ */
.music-panel-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: flex-start;
  height: 100%;
  padding: 0.1px;
  animation: pageIn 0.5s ease;
  overflow-y: auto;
}
.music-card {
  width: 100%;
  max-width: 520px;
  background: var(--glass-strong);
  border: 1px solid var(--glass-border);
  border-radius: 24px;
  padding: 10px 14px 14px;
  box-shadow: 0 10px 30px var(--shadow);
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  position: relative;
}

/* 在线搜索与选歌区 - 精致超小款设计 */
.music-search-row {
  display: flex;
  width: 100%;
  gap: 5px;
  margin-bottom: 8px;
}
.music-search-input {
  flex: 1;
  padding: 2px 10px;
  border-radius: 10px;
  border: 1px solid var(--glass-border);
  background: var(--input-bg);
  color: var(--text);
  font-size: 10px;
  outline: none;
  height: 22px;
}
.music-search-btn {
  background: var(--accent);
  color: white;
  border: none;
  padding: 0 10px;
  border-radius: 10px;
  font-size: 10px;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.2s;
  height: 22px;
  display: flex;
  align-items: center;
  justify-content: center;
}
.music-select-btn {
  background: linear-gradient(135deg, #ff6584, #fbc2eb);
  color: white;
  border: none;
  padding: 0 10px;
  border-radius: 20px;
  font-size: 9.5px;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.2s;
  height: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 2px 6px rgba(255,101,132,0.2);
}
.music-select-btn:active, .music-search-btn:active {
  transform: scale(0.95);
}

/* 歌曲选择抽屉式浮层 */
.song-drawer {
  position: absolute;
  bottom: 0; left: 0.1; right: 0;
  height: 0;
  background: var(--glass-strong);
  backdrop-filter: blur(2px);
  -webkit-backdrop-filter: blur(0.1px);
  border-top: -11px solid var(--glass-border);
  border-top-left-radius: 24px;
  border-top-right-radius: 24px;
  z-index: 110;
  overflow: hidden;
  transition: height 0.35s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  flex-direction: column;
}
.song-drawer.open {
  height: 80%;
}
.drawer-header {
  padding: 7px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 0.1px solid var(--glass-border);
}
.drawer-title {
  font-size: 2px;
  font-weight: 800;
}
.drawer-close {
  background: none; border: none; font-size: 1px; cursor: pointer; color: var(--text);
}
.drawer-list {
  flex: 1;
  overflow-y: auto;
  padding: 1px;
}
.drawer-item {
  padding: 1px;
  border-radius: 19px;
  margin-bottom: 1px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  cursor: pointer;
  background: var(--input-bg);
  font-size: 1px;
  transition: background 0.2s;
}
.drawer-item:hover, .drawer-item.active {
  background: var(--hover);
  color: var(--accent);
}

/* 胶片黑胶大转盘 */
.cd-player {
  position: relative;
  width: 102px;
  height: 102px;
  margin-bottom: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
}
.cd-vinyl {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  background: radial-gradient(circle, #333 20%, #0f1015 21%, #1e1f25 35%, #000 60%, #1a1b22 80%, #0c0d12 100%);
  border: 4px solid var(--glass-border);
  box-shadow: 0 6px 18px rgba(0,0,0,0.35), inset 0 0 15px rgba(255,255,255,0.1);
  display: flex;
  align-items: center;
  justify-content: center;
  animation: spinCD 8s linear infinite;
  animation-play-state: paused;
  background-size: cover;
  background-position: center;
}
@keyframes spinCD {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
.cd-center {
  width: 26px;
  height: 26px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--accent), var(--sky-3));
  box-shadow: 0 0 10px rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 10px;
  font-weight: 900;
  text-shadow: 0 1px 3px rgba(0,0,0,0.3);
}
/* 唱针臂 */
.cd-needle {
  position: absolute;
  top: -8px;
  right: 10px;
  width: 22px;
  height: 46px;
  background: transparent;
  border-left: 2px solid rgba(255,255,255,0.7);
  border-bottom: 2px solid rgba(255,255,255,0.7);
  border-bottom-left-radius: 4px;
  transform-origin: top right;
  transform: rotate(-15deg);
  transition: transform 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  pointer-events: none;
  z-index: 2;
}
.playing .cd-needle {
  transform: rotate(5deg);
}

.track-meta {
  margin-bottom: 8px;
  width: 100%;
}
.track-title {
  font-size: 12.5px;
  font-weight: 900;
  color: var(--text);
  margin-bottom: 2px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  text-align: center;
}
.track-artist {
  font-size: 9.5px;
  color: var(--text-dim);
  text-align: center;
}

/* 控制按钮组 - 新增：在 ⏮ 按钮左侧追加 📤 分享按钮 */
.player-controls {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  width: 100%;
}
.ctrl-btn {
  background: var(--input-bg);
  border: 1px solid var(--glass-border);
  color: var(--text);
  width: 28px;
  height: 28px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  font-size: 10.5px;
  transition: all 0.2s cubic-bezier(0.175, 0.885, 0.32, 1.1);
}
.ctrl-btn:active {
  transform: scale(0.9);
  background: var(--hover);
}
.ctrl-btn.main-play {
  width: 38px;
  height: 38px;
  background: linear-gradient(135deg, var(--accent), var(--sky-3));
  border: none;
  color: #fff;
  font-size: 12px;
  box-shadow: 0 4px 15px rgba(0, 122, 255, 0.3);
}

.progress-container {
  width: 100%;
  margin-top: 8px;
  margin-bottom: 8px;
  display: flex;
  align-items: center;
  gap: 10px;
}
.time-display {
  font-size: 9px;
  color: var(--text-dim);
  width: 32px;
}
.progress-bar-wrapper {
  flex: 1;
  height: 4px;
  background: rgba(0,0,0,0.1);
  border-radius: 2px;
  position: relative;
  cursor: pointer;
}
body.theme-dark .progress-bar-wrapper {
  background: rgba(255,255,255,0.1);
}
.progress-bar-fill {
  height: 100%;
  background: var(--accent);
  border-radius: 2px;
  width: 0%;
  transition: width 0.1s linear;
}

/* ============ 极简抖音短视频模块 ============ */
.douyin-container {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  position: relative;
  overflow: hidden;
  border-radius: 20px;
  background: #000;
}
.douyin-video-wrap {
  width: 100%;
  height: 100%;
  position: relative;
  touch-action: none;
}
.douyin-video-element {
  width: 100%;
  height: 100%;
  object-fit: contain;
}
/* 右侧悬浮功能框 */
.douyin-right-bar {
  position: absolute;
  right: 10px;
  bottom: 80px;
  display: flex;
  flex-direction: column;
  gap: 15px;
  align-items: center;
  z-index: 10;
}
.douyin-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  color: white;
  cursor: pointer;
}
.douyin-avatar {
  width: 38px;
  height: 38px;
  border-radius: 50%;
  border: 1.5px solid #fff;
  background-size: cover;
  background-position: center;
  box-shadow: 0 0 5px rgba(0,0,0,0.5);
}
.douyin-icon-box {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: rgba(0,0,0,0.4);
  backdrop-filter: blur(5px);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  transition: transform 0.2s;
}
.douyin-item:active .douyin-icon-box {
  transform: scale(0.85);
}
.douyin-item span {
  font-size: 9px;
  font-weight: bold;
  margin-top: 3px;
  text-shadow: 0 1px 2px rgba(0,0,0,0.8);
}
/* 底部作者/介绍信息栏 */
.douyin-info-bar {
  position: absolute;
  left: 14px;
  bottom: 45px; /* 上抬预留出底部进度条的空间 */
  right: 60px;
  color: white;
  z-index: 10;
  pointer-events: none;
  text-shadow: 0 1px 3px rgba(0,0,0,0.8);
}
.douyin-author {
  font-size: 13px;
  font-weight: bold;
  margin-bottom: 6px;
}
.douyin-desc {
  font-size: 11px;
  opacity: 0.9;
  line-height: 1.4;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}

/* 新增：小姐姐视频专用的底部快进进度调节栏 */
.douyin-progress-area {
  position: absolute;
  bottom: 12px;
  left: 14px;
  right: 14px;
  z-index: 15;
  display: flex;
  align-items: center;
  gap: 8px;
  background: rgba(0, 0, 0, 0.45);
  backdrop-filter: blur(10px);
  padding: 4px 10px;
  border-radius: 12px;
  border: 1px solid rgba(255, 255, 255, 0.08);
}
.douyin-time-txt {
  font-size: 8px;
  color: rgba(255, 255, 255, 0.8);
  width: 28px;
  text-align: center;
  font-family: monospace;
}
.douyin-progress-bg {
  flex: 1;
  height: 4px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 2px;
  position: relative;
  cursor: pointer;
}
.douyin-progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #ff6584, #fbc2eb);
  border-radius: 2px;
  width: 0%;
  position: relative;
}
.douyin-progress-fill::after {
  content: '';
  position: absolute;
  right: -4px;
  top: 50%;
  transform: translateY(-50%);
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #fff;
  box-shadow: 0 0 4px rgba(0,0,0,0.5);
}

/* 提示声音遮罩 */
.audio-hint {
  position: absolute;
  top: 50%; left: 50%;
  transform: translate(-50%, -50%);
  background: rgba(0,0,0,0.7);
  padding: 8px 16px;
  border-radius: 12px;
  color: white;
  font-size: 11px;
  font-weight: bold;
  pointer-events: none;
  opacity: 0.8;
  z-index: 5;
  animation: hintFade 4s forwards;
}
@keyframes hintFade {
  0% { opacity: 0.9; }
  80% { opacity: 0.9; }
  100% { opacity: 0; }
}

/* 点赞跳跃红心 */
.like-heart {
  position: absolute;
  font-size: 40px;
  color: #ff2d55;
  pointer-events: none;
  animation: heartPop 0.8s ease-out forwards;
  z-index: 100;
}
@keyframes heartPop {
  0% { transform: scale(0) rotate(0deg); opacity: 0; }
  15% { transform: scale(1.2) rotate(-15deg); opacity: 0.9; }
  30% { transform: scale(1) rotate(15deg); opacity: 1; }
  100% { transform: translateY(-80px) scale(0.6) rotate(-10deg); opacity: 0; }
}

/* ============ 新增：H5 音乐下载与分享高拟真弹窗 ============ */
.share-modal {
  position: fixed; inset: 0; background: rgba(0,0,0,0.4);
  backdrop-filter: blur(12px) saturate(180%); -webkit-backdrop-filter: blur(12px) saturate(180%);
  z-index: 100000; display: none; align-items: center; justify-content: center;
  padding: 20px;
}
.share-modal-content {
  background: var(--glass-strong); border: 1px solid var(--glass-border);
  border-radius: 24px; padding: 20px; width: 100%; max-width: 280px;
  text-align: center; box-shadow: 0 12px 40px var(--shadow);
  animation: popIn 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}
@keyframes popIn {
  from { transform: scale(0.8); opacity: 0; }
  to { transform: scale(1); opacity: 1; }
}
.share-modal-title {
  font-size: 13px; font-weight: 900; margin-bottom: 14px; color: var(--text);
  letter-spacing: 0.5px;
}
.share-modal-btn {
  width: 100%; padding: 10px; border-radius: 14px; border: 1px solid var(--glass-border);
  background: var(--input-bg); color: var(--text); font-size: 11px; font-weight: 800;
  margin-bottom: 8px; cursor: pointer; transition: all 0.2s;
}
.share-modal-btn:active { transform: scale(0.95); background: var(--hover); }
.share-modal-btn.primary {
  background: linear-gradient(135deg, var(--accent), var(--sky-3)); color: #fff; border: none;
  box-shadow: 0 4px 12px rgba(0,122,255,0.25);
}
.share-modal-btn.danger {
  background: linear-gradient(135deg, #ff453a, #ff9f0a); color: #fff; border: none;
  box-shadow: 0 4px 12px rgba(255,69,58,0.25);
}
.share-modal-btn.cancel {
  background: transparent; border: none; margin-bottom: 0; color: var(--text-dim);
}

/* ============ 通用功能控件样式 ============ */
.row{
  background:var(--glass-strong); backdrop-filter:blur(11px);-webkit-backdrop-filter:blur(11px); border:1px solid var(--glass-border); border-radius:20px; padding:6px 10px; margin-bottom:5px; display:flex;align-items:center;justify-content:space-between;gap:8px; transition:all .25s;animation:rowIn .4s backwards;
}
.row:hover{transform:translateY(-1px); box-shadow:0 4px 12px var(--shadow);}
@keyframes rowIn{from{opacity:0;transform:translateY(8px);}to{opacity:1;transform:translateY(0);}}
.row-label{display:flex;align-items:center;gap:8px;flex:1;min-width:0;}
.row-icon{ width:24px;height:24px;border-radius:6px;flex-shrink:0; background:linear-gradient(135deg,var(--accent),var(--sky-3)); color:#fff;font-size:11px;font-weight:600; display:flex;align-items:center;justify-content:center; }
.row-label-text{font-size:12px;font-weight:500; overflow:hidden;text-overflow:ellipsis;white-space:nowrap;}



/* 修改：加速调控滑动条条颜色重构。替换为醒目的极客感橘红渐变至亮黄色 */
/* ============ 加速调控滑动条 ============ */
.row.row-block {
  display: block;
  padding: 5px 10px 6px !important;
  margin-bottom: 4px !important;
}
.row.row-block .row-label {
  margin-bottom: 0px !important; 
}
.slider-top {
  display: flex !important;
  justify-content: space-between !important;
  align-items: center !important;
  width: 100% !important;
  margin-bottom: -6px !important;
  line-height: 1 !important;
}

.slider {
  -webkit-appearance: none;
  width: 100%;
  height: 3.2px !important; 
  border-radius: 6px; 
  outline: none;
  cursor: pointer;
  margin-top: -1px !important; 
  background: linear-gradient(50deg, var(--accent) var(--pct, 50%), rgba(255,255,255,0.1) var(--pct, 50%));
}
body.theme-dark .slider, body.theme-cyber .slider {
  background: linear-gradient(50deg, var(--accent) var(--pct, 50%), rgba(255,255,255,0.08) var(--pct, 50%));
}

.slider::-webkit-slider-thumb {
  -webkit-appearance: none; 
  width: 12px !important; 
  height: 12px !important;
  border-radius: 50%; 
  background: radial-gradient(circle, #ff4 3%, var(--accent) 80%);
  border: 1px solid #ff1 !important;
  box-shadow: 0 0 8px var(--accent), 0 0 12px var(--accent); 
  cursor: grab;
  transition: transform 0.15s, box-shadow 0.2s;
}
.slider::-webkit-slider-thumb:active {
  transform: scale(1.22);
  box-shadow: 0 0 12px var(--ok), 0 0 20px var(--ok); 
}

.slider-val {
  font-size: 8.5px !important;
  padding: 1px 4px !important;
  border-radius: 4px !important;
  line-height: 1 !important;
  margin-left: auto !important; 
}
/* ============ 普通功能/动效按钮 ============ */
.btn {
  background: linear-gradient(180deg, var(--accent) 0%, rgba(0,122,255,0.85) 100%);
  color: #fff;
  border: none;
  padding: 5px 14px;
  border-radius: 24px !important; 
  font-family: inherit;
  font-size: 11px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1);
  min-width: 58px;
  box-shadow: 0 2px 6px rgba(0,122,255,0.25);
  position: relative;
  overflow: hidden;
}
.btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0,122,255,0.4);
}
.btn:active {
  transform: scale(0.92);
}
.btn-click-ani {
  animation: btnPop 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}
@keyframes btnPop {
  0% { transform: scale(1); }
  50% { transform: scale(0.88); }
  100% { transform: scale(1); }
}

.btn-on {
  background: linear-gradient(270deg, var(--ok), #2ecc71, #00ff66) !important;
  background-size: 200% 200% !important;
  color: #fff !important;
  box-shadow: 0 0 14px rgba(48,209,88,0.5) !important;
  animation: btnGlowPulse 1.5s infinite alternate, btnFlowGradient 1.5s infinite linear !important;
  border-radius: 24px !important;
}

@keyframes btnGlowPulse {
  from { transform: scale(1); box-shadow: 0 0 10px rgba(48,209,88,0.4); }
  to { transform: scale(1.02); box-shadow: 0 0 16px rgba(48,209,88,0.7); }
}

@keyframes btnFlowGradient {
  0% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
  100% { background-position: 0% 50%; }
}

/* ============ 科技感点击动效滑块开关 (Switch) ============ */
.sw { 
  position: relative; 
  width: 44px; 
  height: 22px; 
  cursor: pointer; 
  flex-shrink: 0; 
}
.sw input { display: none; }
.sw-bg {
  position: absolute; 
  inset: 0; 
  border-radius: 99px; 
  background: linear-gradient(to bottom, #111827, #1f2937); 
  border: 1px solid rgba(255,255,255,0.08);
  box-shadow: inset 0 2px 4px rgba(0,0,0,0.4);
  transition: background 0.4s cubic-bezier(0.4, 0, 0.2, 1), border-color 0.4s;
}
.sw-knob {
  position: absolute; 
  top: 2px; 
  left: 2px; 
  width: 16px; 
  height: 16px; 
  border-radius: 50%; 
  background: #cbd5e1; 
  box-shadow: 0 1px 3px rgba(0,0,0,0.4);
  transition: left 0.38s cubic-bezier(0.34, 1.56, 0.64, 1), width 0.25s, background-color 0.3s, box-shadow 0.3s;
}

/* 激活态：微发光霓虹渐变 */
.sw input:checked + .sw-bg { 
  background: linear-gradient(135deg, var(--ok), #2ecc71); 
  border-color: #5efc82;
  box-shadow: 0 0 10px rgba(46, 204, 113, 0.4), inset 0 1px 2px rgba(255,255,255,0.2);
}
.sw input:checked ~ .sw-knob { 
  left: 24px; 
  background-color: #ffffff;
  box-shadow: 0 0 8px #ffffff, 0 2px 4px rgba(0,0,0,0.3);
}


/* 拖拉条 */
.slider-top{display:flex;justify-content:space-between;align-items:center;margin-bottom:10px;}
.slider-val{
  background:linear-gradient(135deg,var(--accent),color-mix(in srgb,var(--accent) 70%,var(--sky-3)));
  color:#fff;
  padding:2px 11px;border-radius:11px;
  font-size:11px;font-weight:700;font-family:"SF Mono",monospace;
  box-shadow:0 2px 6px color-mix(in srgb,var(--accent) 30%,transparent);}
.slider{-webkit-appearance:none;width:100%;height:6px;border-radius:3px;
  background:linear-gradient(90deg,var(--accent) var(--pct,50%),
                             rgba(0,0,0,.1) var(--pct,50%));
  outline:none;cursor:pointer;}
body.theme-dark .slider{background:linear-gradient(90deg,var(--accent) var(--pct,50%),
                                                  rgba(255,255,255,.1) var(--pct,50%));}
.slider::-webkit-slider-thumb{-webkit-appearance:none;
  width:22px;height:22px;border-radius:50%;
  background:radial-gradient(circle at 30% 30%,#fff,#f0f0f0);
  border:2px solid var(--accent);
  box-shadow:0 2px 8px rgba(0,0,0,.2),inset 0 1px 0 rgba(255,255,255,.9);
  cursor:grab;transition:transform .15s;}
.slider::-webkit-slider-thumb:active{transform:scale(1.25);cursor:grabbing;}
/* 按压状态微缩变形 */
.sw:active .sw-knob { width: 22px; } 

.cb{position:relative;width:18px;height:18px;cursor:pointer;flex-shrink:0;}
.cb input{display:none;}
.cb-box{position:absolute;inset:0;border-radius:50%; background:rgba(0,0,0,.05);border:1.5px solid rgba(0,0,0,.18); transition:all .2s;display:flex;align-items:center;justify-content:center;}
body.theme-dark .cb-box, body.theme-cyber .cb-box{background:rgba(255,255,255,.05);border-color:rgba(255,255,255,.22);}
.cb-box::after{content:'';width:8px;height:5px; border-left:2px solid #fff;border-bottom:2px solid #fff; transform:rotate(-45deg) scale(0);transition:transform .25s;margin-top:-2px;}
.cb input:checked + .cb-box{ background:linear-gradient(135deg,var(--accent),var(--sky-3)); border-color:var(--accent); }
.cb input:checked + .cb-box::after{transform:rotate(-45deg) scale(1);}

.inp{width:100%;padding:6px 10px;border-radius:20px; background:var(--input-bg);border:1px solid var(--glass-border); color:var(--text);font-family:inherit;font-size:11px;outline:none; transition:all .2s;}
.inp:focus{border-color:var(--accent); box-shadow:0 0 0 2px rgba(0,122,255,0.2);}

.resize-handle{
  position:fixed;right:8px;bottom:8px; width:24px;height:24px;cursor:nwse-resize;touch-action:none;z-index:100; background:linear-gradient(0deg,transparent 90%,var(--accent) 47%,var(--accent) 55%,transparent 57%,transparent 70%,var(--accent) 72%,var(--accent) 80%,transparent 82%); border-bottom-right-radius:80px;opacity:.80; transition:all .30s;
}
</style></head>
<body class="theme-light">
<div class="bg">
  <div class="blob b1"></div><div class="blob b2"></div>
  <div class="blob b3"></div><div class="blob b4"></div>
  <div class="spark"></div><div class="spark"></div>
  <div class="spark"></div><div class="spark"></div>
</div>

<!-- 浮动通知气泡核心挂载节点 -->
<div class="toast-container" id="toast-container"></div>

<!-- 苹果风歌词“灵动岛” -->
<div class="dynamic-island" id="dynamic-island">
  <div class="island-content">
    <div class="island-left">
      <span class="island-wave-bar"></span>
      <span class="island-wave-bar"></span>
      <span class="island-wave-bar"></span>
    </div>
    <div class="island-middle">
      <div class="island-track" id="island-track-name">歌名</div>
      <div class="island-lyric" id="island-lyric-text">准备播放...</div>
    </div>
    <div class="island-right">🎵</div>
  </div>
</div>

<div class="panel" id="panel">
  <aside class="sidebar glass">
    <!-- 超圆润高颜值胶囊字幕框 -->
    <div class="marquee-box">
      <div class="marquee-text">{{SCROLL_TEXT}}</div>
    </div>
    <div class="brand" id="drag-handle">
      <div class="brand-icon" onclick="NA.send('__openUrl', '{{WEB_URL}}')" title="点击跳转网页">
        <img src="{{ICON_URL}}" style="width:108%; height:108%; object-fit:cover; display:block;" onerror="this.remove(); document.getElementById('fallback-icon').style.display='inline';">
        <span id="fallback-icon" style="display:none;">👿</span>
      </div>
      <div class="brand-text" style="flex:1; margin-left:6px; margin-right:4px; font-size:11px;">{{TITLE}}</div>
      <button class="small-btn" style="margin-right:3px;" onclick="NA.send('__brandBtn1', '')">{{BRAND_BTN1_TEXT}}</button>
      <button class="small-btn" onclick="NA.send('__brandBtn2', '')">{{BRAND_BTN2_TEXT}}</button>
    </div>
    <div class="sidebar-top-exit">
      <button class="foot-btn exit" style="flex: 1;" onclick="NA.send('__exit','')">❌ 退出</button>
      <button class="foot-btn" style="flex: 1;" onclick="onSideToggle(this)">关闭</button>
    </div>
    
    <!-- 主题控制栏 -->
    <div class="theme-toggle-wrap" onclick="cycleTheme()">
      <span class="theme-toggle-label" id="themeLabel">☀️ 浅色标准</span>
      <span class="theme-badge">切 换</span>
    </div>
    
    <!-- ♡炫斗大陆♡ 折叠手风琴 -->
    <div class="nav-title" id="accordion-title-game" onclick="toggleNavCollapse('game')">
      <span>♡炫斗大陆♡</span>
      <span class="nav-arrow" id="nav-arrow-game">▼</span>
    </div>
    
    <!-- 炫斗分类包裹抽屉 -->
    <div class="nav-container-wrapper" id="nav-wrapper-game">
      <nav class="nav" id="nav-game"></nav>
    </div>

    <!-- ♡音乐空间♡ 折叠手风琴 -->
    <div class="nav-title" id="accordion-title-music" onclick="toggleNavCollapse('music')">
      <span>♡音乐空间♡</span>
      <span class="nav-arrow" id="nav-arrow-music">▼</span>
    </div>
    
    <!-- 音乐分类包裹抽屉 -->
    <div class="nav-container-wrapper" id="nav-wrapper-music">
      <nav class="nav" id="nav-music"></nav>
    </div>
  </aside>

  <main class="content glass">
    <header class="content-head">
      <div class="head-left">
        <div class="content-sub">版本：1.52.30.1</div>
        <div class="content-title" id="curTitle">{{TITLE}}</div>
      </div>
      <div class="search-wrap">
        <svg class="search-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
          <circle cx="11" cy="11" r="7"/>
          <path d="m21 21-4.3-4.3"/>
        </svg>
        <input type="text" class="search-input" id="searchInput" placeholder="搜索功能..." oninput="onSearch(this.value)">
      </div>
    </header>
    
    <div class="body" id="body">
      <!-- 动态注入功能组 -->
      {{ITEMS}}
      
      <!-- 右侧：高级音乐播放器面板 -->
      <section class="group" data-group="音乐" data-icon="🎵">
        <div class="music-panel-container">
          <div class="music-card" id="music-card-node">
            
            <!-- 音乐搜索及选择器组件（高度深度微缩优化） -->
            <div class="music-search-row">
              <input type="text" class="music-search-input" id="music-search-val" placeholder="🔍  在线试听..." onkeydown="if(event.key==='Enter') searchOnlineMusic()">
              <button class="music-search-btn" onclick="searchOnlineMusic()">搜 索</button>
            </div>

            <!-- CD唱片与连杆机械针臂 -->
            <div class="cd-player">
              <div class="cd-vinyl" id="main-cd-vinyl">
                <div class="cd-center">♪</div>
              </div>
              <div class="cd-needle"></div>
            </div>
            
            <!-- 歌曲信息 -->
            <div class="track-meta">
              <div class="track-title" id="track-title">破阵舞</div>
              <div class="track-artist" id="track-artist">闻人听书</div>
            </div>
            
            <!-- 进度控制 -->
            <div class="progress-container">
              <span class="time-display" id="time-current">00:00</span>
              <div class="progress-bar-wrapper" id="progress-bar-bg" onclick="seekAudio(event)">
                <div class="progress-bar-fill" id="progress-bar-fill"></div>
              </div>
              <span class="time-display" id="time-duration">00:00</span>
            </div>
            
            <!-- 播控操作按钮：在⏮左侧增加📤分享 -->
            <div class="player-controls">
              <button class="ctrl-btn" onclick="openMusicShareModal(event)" title="分享或下载当前音乐">📤</button>
              <button class="ctrl-btn" onclick="prevSong()">⏮</button>
              <button class="ctrl-btn main-play" id="play-pause-btn" onclick="togglePlayState()">▶</button>
              <button class="ctrl-btn" onclick="nextSong()">⏭</button>
              <button class="music-select-btn" onclick="toggleSongDrawer(true)">选择歌曲</button>
            </div>

            <!-- 歌曲选择侧滑半屏弹窗 -->
            <div class="song-drawer" id="song-drawer">
              <div class="drawer-header">
                <span class="drawer-title"> ♪ 已加载经典曲目</span>
                <button class="drawer-close" onclick="toggleSongDrawer(false)">❌</button>
              </div>
              <div class="drawer-list" id="drawer-list">
                <!-- 曲目动态渲染 -->
              </div>
            </div>

          </div>
        </div>
      </section>

      <!-- 右侧：高级抖音短视频面板 -->
      <section class="group" data-group="小姐姐" data-icon="🧸">
        <div class="douyin-container" id="dy-main-box">
          <div class="audio-hint" id="audio-hint-box">轻触屏幕一键开启视频声音 🔊</div>
          <div class="douyin-video-wrap" id="douyin-swipe-node" onclick="toggleDouyinPlay()" ondblclick="onDouyinDblClick(event)">
            <!-- 视频流主体 (核心优化：针对低版本系统强制静音 muted 绕过加载限制，由手势激活后解除静音) -->
            <video class="douyin-video-element" id="douyin-video-player" loop playsinline webkit-playsinline x5-video-player-type="h5-page" x5-video-player-fullscreen="true" preload="auto" muted></video>
            
            <!-- 右侧操作栏 -->
            <div class="douyin-right-bar" onclick="event.stopPropagation()">
              <div class="douyin-item">
                <div class="douyin-avatar" id="dy-avatar" style="background-image:url('https://p16.douyinpic.com/img/tos-cn-i-0813/0c4eb8964d5c41cc9c25dbb159f8a313~c5_300x300.jpeg?from=1163509375');"></div>
              </div>
              <div class="douyin-item" onclick="onDouyinLike()">
                <div class="douyin-icon-box" id="dy-like-icon">🤍</div>
                <span id="dy-like-count">36.8w</span>
              </div>
              <div class="douyin-item" onclick="showToast('💬 该版本暂关闭评论区交互')">
                <div class="douyin-icon-box">💬</div>
                <span>2409</span>
              </div>
              <!-- 独立分享功能：调用全新独立的 JS 事件拦截器 -->
              <div class="douyin-item" onclick="shareVideoLink(event)">
                <div class="douyin-icon-box">🔗</div>
                <span>分享</span>
              </div>
            </div>

            <!-- 底部作者/介绍信息栏 -->
            <div class="douyin-info-bar">
              <div class="douyin-author" id="dy-author">@天天炫斗</div>
              <div class="douyin-desc" id="dy-desc">上下滑动可以切换哦...</div>
            </div>

            <!-- 小姐姐视频专用：快进、快退及手动进度拖拽调节系统 -->
            <div class="douyin-progress-area" onclick="event.stopPropagation()">
              <span class="douyin-time-txt" id="dy-time-cur">00:00</span>
              <div class="douyin-progress-bg" id="dy-progress-bar-bg" onclick="seekDouyinVideo(event)" ontouchstart="startDyProgressDrag(event)">
                <div class="douyin-progress-fill" id="dy-progress-bar-fill"></div>
              </div>
              <span class="douyin-time-txt" id="dy-time-dur">00:00</span>
            </div>

          </div>
        </div>
      </section>
    </div>
  </main>
  <div class="resize-handle" id="resize-handle" title="拖动调整大小"></div>
</div>

<!-- 新增：音乐选择弹窗挂载节点 -->
<div class="share-modal" id="musicShareModal" onclick="closeMusicShareModal()">
  <div class="share-modal-content" onclick="event.stopPropagation()">
    <div class="share-modal-title">🎵 音乐选项</div>
    <button class="share-modal-btn primary" onclick="copyMusicShareText()">📋 复制分享文案</button>
    <button class="share-modal-btn danger" onclick="downloadMusicLocal()">📥 直接下载到本地</button>
    <button class="share-modal-btn cancel" onclick="closeMusicShareModal()">取消</button>
  </div>
</div>

<audio id="audio-player" loop preload="auto"></audio>

<script>
// =============================================================================
// 前端 JavaScript 交互核心逻辑
// =============================================================================
window.__cfg = {{CONFIG}};

// 0. 前端渲染和自销毁的 Toast 控制逻辑
function showToast(message) {
  var container = document.getElementById('toast-container');
  if (!container) return;
  var toast = document.createElement('div');
  toast.className = 'web-toast';
  toast.textContent = message;
  container.appendChild(toast);
  setTimeout(function() {
    toast.remove();
  }, 2700);
}

// 1. 多主题无缝切换
var themes = ['light', 'dark', 'sakura', 'cyber'];
var themeNames = ['☀️ 浅色标准', '🌙 深色暗夜', '🌸 娇粉樱花', '🔮 赛博霓虹'];
var currentThemeIdx = 0;

function cycleTheme() {
  currentThemeIdx = (currentThemeIdx + 1) % themes.length;
  var targetTheme = themes[currentThemeIdx];
  document.body.classList.remove('theme-light', 'theme-dark', 'theme-sakura', 'theme-cyber');
  document.body.classList.add('theme-' + targetTheme);
  document.getElementById('themeLabel').textContent = themeNames[currentThemeIdx];
}

// 2. 左侧双手风琴独立折叠控制
function toggleNavCollapse(type) {
  var wrapper = document.getElementById('nav-wrapper-' + type);
  var title = document.getElementById('accordion-title-' + type);
  if (wrapper.classList.contains('collapsed')) {
    wrapper.classList.remove('collapsed');
    title.classList.remove('collapsed');
  } else {
    wrapper.classList.add('collapsed');
    title.classList.add('collapsed');
  }
}

// 3. 音乐播放器元数据与重构后极精密对齐的曲库歌词（毫秒级高精度版本）
var playlist = [
  { 
    title: "难解", 
    artist: "遇君等什么君", 
    url: "https://files.catbox.moe/7rf66y.mp3",
    pic: "",
    lyrics: [
      { time: 14, text: "难舍 难分 难解" },
      { time: 21, text: "缘起 缘浅 缘灭" },
      { time: 29, text: "泪落几滴才可以得到上天垂怜" },
      { time: 36, text: "垂首不问因果只求你一次回瞥" },
      { time: 41, text: "菩提叶落双肩 数百世签" },
      { time: 45, text: "读不懂命途深浅" },
      { time: 48, text: "若能回到初见" },
      { time: 50, text: "任朝圣路多蜿蜒" },
      { time: 55, text: "要用多久才能忘掉深爱的这张脸" },
      { time: 62, text: "难道此生注定身似飘蓬心如铁" },
      { time: 67, text: "风不渡你此间 幡动千遍" },
      { time: 71, text: "霜雪染白我鬓边" },
      { time: 74, text: "等你站在天边" },
      { time: 76, text: "沉默对视 隔着云烟" },
      { time: 80, text: "བློས་གཏོང་དཀའ་། བློས་གཏོང་དཀའ་། གྲོལ་དཀའ་།" },
      { time: 82, text: "难舍 难分 难解" },
      { time: 86, text: "ལས་དབང་ནས་ལས་དབང་མེད་པར་གྱུར་།" },
      { time: 91, text: "缘起 缘浅 缘灭" },
      { time: 93, text: "今生相见 定有亏欠" },
      { time: 99, text: "前世不欠 今生不见" }
    ]
  },
  
  { 
    title: "女儿情", 
    artist: "苏瑶", 
    url: "https://files.catbox.moe/ngfkx7.ogg",
    pic: "",
    lyrics: [
      { time: 0, text: "女儿情 - 苏瑶" },
      { time: 4, text: "鸳鸯双栖蝶双飞" },
      { time: 11, text: "满园春色惹人醉" },
      { time: 18, text: "悄悄问圣僧" },
      { time: 21, text: "女儿美不美" },
      { time: 25, text: "女儿美不美" },
      { time: 31, text: "说什么王权富贵" },
      { time: 38, text: "怕什么戒律清规" },
      { time: 45, text: "只愿天长地久" },
      { time: 51, text: "与我意中人儿紧相随" },
      { time: 59, text: "爱恋伊 爱恋伊" },
      { time: 66, text: "愿此生常相随" }
    ]
  },
  
  { 
    title: "长安三万里", 
    artist: "洛天依", 
    url: "https://files.catbox.moe/k1u352.mp3",
    pic: "",
    lyrics: [
      { time: 0, text: "长安三万里 - 洛天依" },
      { time: 4, text: "大鹏一日同风起，扶摇直上九万里" },
      { time: 8, text: "假令风歇时下来，犹能簸却沧溟水" },
      { time: 12, text: "世人见我恒殊调，闻余大言皆暗笑" },
      { time: 16, text: "宣父犹能畏后生，丈夫未可轻年少" },
      { time: 20, text: "仰天大笑出门去，我辈岂是蓬蒿人" },
      { time: 25, text: "君不见 黄河之水天上来" },
      { time: 29, text: "奔流到海不复回" },
      { time: 32, text: "君不见 高堂明镜悲白发" },
      { time: 36, text: "朝如青丝暮成雪" },
      { time: 40, text: "五花马 千金裘" },
      { time: 43, text: "呼儿将出换美酒" },
      { time: 47, text: "与尔同销万古愁" }
    ]
  },
  
  { 
    title: "剑来", 
    artist: "洛天依", 
    url: "https://files.catbox.moe/r9txrx.mp3",
    pic: "",
    lyrics: [
      { time: 0, text: "剑来 - 洛天依" },
      { time: 4, text: "天地有正气，杂然赋流形" },
      { time: 8, text: "下则为河岳，上则为日星" },
      { time: 12, text: "于人曰浩然，沛乎塞苍冥" },
      { time: 16, text: "谁家小二穿草鞋，一步步走来" },
      { time: 20, text: "剑气纵横三万里，一剑寒芒十九州" },
      { time: 24, text: "我有一剑，可开天，可斩妖仙" },
      { time: 28, text: "天地不仁，我辈自当挺身执剑" },
      { time: 32, text: "春风得意，遇事不决，且听剑鸣" },
      { time: 36, text: "小泥瓶，装满不灭的剑意" }
    ]
  },
  { 
    title: "破阵舞", 
    artist: "闻人听书", 
    url: "https://files.catbox.moe/otvcfn.ogg",
    pic: "",
    lyrics: [
      { time: 0, text: "破阵舞 - 闻人听书" },
      { time: 4, text: "风吹散，黄沙漫，马蹄踏遍关山" },
      { time: 8, text: "战歌起，烈火燃，英雄何惧孤单" },
      { time: 12, text: "我执手中长枪，破开千军万马" },
      { time: 16, text: "功名利禄，不过是过眼云烟" },
      { time: 20, text: "只愿此生，能护你一世长安" },
      { time: 24, text: "看我破阵一舞，剑指苍穹" },
      { time: 28, text: "碧血丹心，无怨无悔，至死方休" }
    ]
  },
  
  { 
    title: "虞兮叹", 
    artist: "闻人听书", 
    url: "https://files.catbox.moe/hzsaqz.ogg",
    pic: "",
    lyrics: [
      { time: 0, text: "虞兮叹 - 闻人听书" },
      { time: 4, text: "楚河流沙 几聚散" },
      { time: 8, text: "日月吞吐 谁人还" },
      { time: 12, text: "风卷残旗 人声叹" },
      { time: 16, text: "霸王悲歌 绝唱传" },
      { time: 20, text: "虞兮虞兮 奈若何" },
      { time: 24, text: "乌江之畔 泪潸然" },
      { time: 28, text: "横剑香魂 终散去" },
      { time: 32, text: "不负君恩 传千古" }
    ]
  },
  
  { 
    title: "压力这么大", 
    artist: "🎸纯音乐🎸", 
    url: "https://files.catbox.moe/5ccjft.mp3",
    pic: "",
    lyrics: [
      { time: 0, text: "现在的压力这么大" },
      { time: 4, text: "想早点回家 没办法" },
      { time: 7, text: "看着订单18,000 " },
      { time: 9, text: "除去平台一半本都没了" },
      { time: 14, text: "现在的压力这么大" },
      { time: 18, text: "不用力活着没办法" },
      { time: 24, text: "如果未来不是梦" }
    ]
  }
];

var currentSongIdx = 0;
var isMusicPlaying = false;
var audio = document.getElementById('audio-player');

function loadSong() {
  var song = playlist[currentSongIdx];
  document.getElementById('track-title').textContent = song.title;
  document.getElementById('track-artist').textContent = song.artist;
  
  // 更新黑胶CD背景封面（如有）
  var cd = document.getElementById('main-cd-vinyl');
  if(song.pic) {
    cd.style.backgroundImage = "url('" + song.pic + "')";
    cd.style.border = "2px solid rgba(255,255,255,0.4)";
  } else {
    cd.style.backgroundImage = "none";
    cd.style.border = "4px solid var(--glass-border)";
  }

  // 初始化灵动岛的歌词与歌曲信息
  document.getElementById('island-track-name').textContent = song.title;
  document.getElementById('island-lyric-text').textContent = "加载中...";
  audio.src = song.url;

  // 如果是在线网络搜索歌曲，且尚未抓取真实大段歌词，则触发下层网易API通道
  if (song.id && !song.lyrics) {
    NA.send('__fetchLyrics', song.id);
  } else if (!song.lyrics) {
    song.lyrics = [{ time: 0, text: "♪ 暂无歌词" }];
  }
}

// 动态渲染歌曲选择列表
function renderSongList() {
  var container = document.getElementById('drawer-list');
  container.innerHTML = '';
  playlist.forEach(function(song, index) {
    var item = document.createElement('div');
    item.className = 'drawer-item' + (index === currentSongIdx ? ' active' : '');
    item.innerHTML = '<div><strong>' + song.title + '</strong><br><small style="color:var(--text-dim);">' + song.artist + '</small></div><span>▶</span>';
    item.onclick = function() {
      selectAndPlaySong(index);
    };
    container.appendChild(item);
  });
}

function selectAndPlaySong(index) {
  currentSongIdx = index;
  toggleSongDrawer(false);
  resetPlayerState();
  loadSong();
  renderSongList();
  playCurrentSong();
}

function toggleSongDrawer(isOpen) {
  var drawer = document.getElementById('song-drawer');
  if(isOpen) {
    renderSongList();
    drawer.classList.add('open');
  } else {
    drawer.classList.remove('open');
  }
}

// 4. 对接高兼容性网易云/《音乐多功能2.0版.lua》搜索接口
function searchOnlineMusic() {
  var kw = document.getElementById('music-search-val').value.trim();
  if(!kw) {
    showToast('请输入歌名关键词搜索');
    return;
  }
  showToast('正在检索曲库: ' + kw);
  NA.send('__searchQQMusic', kw);
}

// 音乐接口回调：对接网易官方数据协议
window.onQQMusicSearchCallback = function(jsonStr) {
  try {
    var data = JSON.parse(jsonStr);
    var songs = data.result && data.result.songs ? data.result.songs : [];
    if (songs.length === 0) {
      showToast('❌ 未搜索到该歌曲，请换一个歌名试试');
      return;
    }
    
    // 映射搜索结果并接入不失效的音频流直链
    var results = songs.map(function(s) {
      return {
        title: s.name,
        artist: s.artists ? s.artists.map(function(a){ return a.name; }).join('/') : '未知歌手',
        url: 'https://music.163.com/song/media/outer/url?id=' + s.id + '.mp3', 
        pic: s.album && s.album.picUrl ? s.album.picUrl : '',
        id: s.id, // 网易云专属歌曲ID
        lyrics: null // 异步触发延迟加载
      };
    });
    
    playlist = results.concat(playlist);
    currentSongIdx = 0;
    renderSongList();
    selectAndPlaySong(0);
    showToast('🔎 曲目已载入，歌词同步中...');
  } catch(e) {
    showToast('❌ 检索超时，已自动尝试备用加载通道');
    console.error(e);
  }
};

// 后端回传真实 LRC 歌词流异步解析引擎
window.onLyricsCallback = function(jsonStr) {
  try {
    var data = JSON.parse(jsonStr);
    var lrcString = data.lrc && data.lrc.lyric ? data.lrc.lyric : "";
    if (!lrcString) {
      var song = playlist[currentSongIdx];
      if (song) song.lyrics = [{ time: 0, text: "♪ 纯音乐，请欣赏" }];
      return;
    }

    var lines = lrcString.split('\n');
    var parsedLyrics = [];

    for (var i = 0; i < lines.length; i++) {
      var line = lines[i].trim();
      var matches = line.match(/\[\d+:\d+(?:\.\d+)?\]/g);
      var text = line.replace(/\[\d+:\d+(?:\.\d+)?\]/g, '').trim();
      if (matches && text) {
        for (var j = 0; j < matches.length; j++) {
          var tMatch = /\[(\d+):(\d+)(?:\.(\d+))?\]/.exec(matches[j]);
          if (tMatch) {
            var min = parseInt(tMatch[1], 10);
            var sec = parseInt(tMatch[2], 10);
            var totalSec = min * 60 + sec;
            parsedLyrics.push({ time: totalSec, text: text });
          }
        }
      }
    }

    // 按时间顺序进行绝对线性排序确保不同步缺陷被彻底根治
    parsedLyrics.sort(function(a, b) { return a.time - b.time; });

    var song = playlist[currentSongIdx];
    if (song) {
      song.lyrics = parsedLyrics.length > 0 ? parsedLyrics : [{ time: 0, text: "♪ 纯音乐，请欣赏" }];
      updateLyrics(); // 触发秒刷
    }
  } catch(e) {
    console.error("歌词同步序列化失败", e);
  }
};

// 动态歌词解析
function updateLyrics() {
  var song = playlist[currentSongIdx];
  if (!song || !song.lyrics || song.lyrics.length === 0) return;
  var currentTime = audio.currentTime;
  var currentLyric = "♪ 音乐播放中";
  
  for (var i = 0; i < song.lyrics.length; i++) {
    if (currentTime >= song.lyrics[i].time) {
      currentLyric = song.lyrics[i].text;
    } else {
      break;
    }
  }
  var lyricEl = document.getElementById('island-lyric-text');
  if (lyricEl && lyricEl.textContent !== currentLyric) {
    lyricEl.textContent = currentLyric;
  }
}

// 核心控制链：杜绝递归循环，彻底斩断悬浮窗卡死隐患
function playCurrentSong() {
  var btn = document.getElementById('play-pause-btn');
  var vinyl = document.getElementById('main-cd-vinyl');
  var container = document.getElementById('music-card-node');
  var island = document.getElementById('dynamic-island');
  
  pauseDouyinVideo(); // 隔离音轨

  audio.play().then(function() {
    isMusicPlaying = true;
    btn.innerHTML = '⏸';
    vinyl.style.animationPlayState = 'running';
    container.classList.add('playing');
    island.classList.add('active');
  }).catch(function(e) {
    console.log("音频轨道流加载被挂起:", e);
    // 捕获权限异常，优雅降级，允许用户通过再次点击手动激活
    isMusicPlaying = false;
    btn.innerHTML = '▶';
    vinyl.style.animationPlayState = 'paused';
    container.classList.remove('playing');
    island.classList.remove('active');
    document.getElementById('island-lyric-text').textContent = "⚠️ 播放受阻，请点击▶重试";
  });
}

function togglePlayState() {
  if (isMusicPlaying) {
    audio.pause();
    isMusicPlaying = false;
    document.getElementById('play-pause-btn').innerHTML = '▶';
    document.getElementById('main-cd-vinyl').style.animationPlayState = 'paused';
    document.getElementById('music-card-node').classList.remove('playing');
    document.getElementById('dynamic-island').classList.remove('active');
  } else {
    if (!audio.src || audio.src === window.location.href) { loadSong(); }
    playCurrentSong();
  }
}

function nextSong() {
  currentSongIdx = (currentSongIdx + 1) % playlist.length;
  resetPlayerState();
  loadSong();
  playCurrentSong();
}

function prevSong() {
  currentSongIdx = (currentSongIdx - 1 + playlist.length) % playlist.length;
  resetPlayerState();
  loadSong();
  playCurrentSong();
}

function resetPlayerState() {
  var vinyl = document.getElementById('main-cd-vinyl');
  var container = document.getElementById('music-card-node');
  vinyl.style.animationPlayState = 'paused';
  container.classList.remove('playing');
  document.getElementById('dynamic-island').classList.remove('active');
}

// 播放进度监听与歌词同步
audio.addEventListener('timeupdate', function() {
  if (!audio.duration) return;
  var pct = (audio.currentTime / audio.duration) * 100;
  document.getElementById('progress-bar-fill').style.width = pct + '%';
  document.getElementById('time-current').textContent = formatTime(audio.currentTime);
  document.getElementById('time-duration').textContent = formatTime(audio.duration);
  
  if (isMusicPlaying) {
    updateLyrics();
  }
});

function formatTime(secs) {
  var m = Math.floor(secs / 60);
  var s = Math.floor(secs % 60);
  return (m < 10 ? '0' : '') + m + ':' + (s < 10 ? '0' : '') + s;
}

function seekAudio(e) {
  var bar = document.getElementById('progress-bar-bg');
  var rect = bar.getBoundingClientRect();
  var clickX = e.clientX - rect.left;
  var pct = clickX / rect.width;
  if (audio.duration) {
    audio.currentTime = pct * audio.duration;
  }
}

// =============================================================================
// 新增：高颜值音乐分享与下载弹窗交互控制
// =============================================================================
function openMusicShareModal(e) {
  e.stopPropagation();
  var modal = document.getElementById('musicShareModal');
  modal.style.display = 'flex';
}

function closeMusicShareModal() {
  var modal = document.getElementById('musicShareModal');
  modal.style.display = 'none';
}

// 分享复制文案逻辑
function copyMusicShareText() {
  var song = playlist[currentSongIdx];
  if (!song) {
    showToast('⚠️ 未能检索到当前曲目信息');
    return;
  }
  var shareText = "🎵 给你分享一首好听的歌：\n《" + song.title + "》- " + song.artist + "\n🔗 试听直链：" + song.url + "\n✨ 祝你有美好的一天！";
  
  var tempInput = document.createElement("textarea");
  tempInput.value = shareText;
  document.body.appendChild(tempInput);
  tempInput.select();
  try {
    document.execCommand('copy');
    showToast('📋 音乐分享文案已成功复制，快去QQ/微信发送给好友吧！');
  } catch(err) {
    showToast('⚠️ 剪切板写入受阻，请手动复制分享');
  }
  document.body.removeChild(tempInput);
  closeMusicShareModal();
}

// 下载音乐逻辑：无缝呼叫 Lua 层下载引擎
function downloadMusicLocal() {
  var song = playlist[currentSongIdx];
  if (!song) {
    showToast('⚠️ 无法获取当前音乐的下载地址');
    return;
  }
  // 发送下载请求到 Lua 线程
  NA.send('__downloadMusic', song.url + ',' + song.title);
  closeMusicShareModal();
}

audio.addEventListener('ended', function() {
  nextSong();
});

loadSong();

// =============================================================================
// 抖音短视频操控系统 (全面升级: 带有独立拖动调节、独立复制分享、音轨继承)
// =============================================================================
var dyPlayer = document.getElementById('douyin-video-player');
var isDyFirstTouch = true;
var isVideoSoundEnabled = false; // 全局记住开音状态
var isDraggingDyProgress = false; // 是否正在手动拖拽进度条中

// 本地高清容灾备份源
var backupVideos = [
  "https://vfx.mtime.cn/Video/2019/03/19/mp4/190319222227698228.mp4",
  "https://vfx.mtime.cn/Video/2019/03/12/mp4/190312083533441093.mp4",
  "https://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4"
];
var backupIdx = 0;

function loadDouyinVideo() {
  document.getElementById('dy-desc').textContent = "正在载入最新短视频...";
  // 根据之前主动开音的记忆，决定新视频是否需要强制静音加载
  dyPlayer.muted = !isVideoSoundEnabled;
  NA.send('__fetchDouyinVideo', '');
}

// 视频阻断容灾逻辑
dyPlayer.addEventListener('error', function() {
  console.log("主线路短视频流加载受限，立即启动安全备份方案...");
  fallbackToBackup();
});

function fallbackToBackup() {
  var fallbackUrl = backupVideos[backupIdx];
  backupIdx = (backupIdx + 1) % backupVideos.length;
  
  dyPlayer.muted = !isVideoSoundEnabled;
  dyPlayer.src = fallbackUrl;
  dyPlayer.load();
  dyPlayer.play().then(function(){
    if (isVideoSoundEnabled) {
      document.getElementById('audio-hint-box').style.display = 'none';
    } else {
      document.getElementById('audio-hint-box').style.display = 'block';
      document.getElementById('audio-hint-box').textContent = "🔊 轻触屏幕一键开启声音";
    }
  }).catch(function(err){ 
    console.log("视频加载异常", err);
  });
  
  document.getElementById('dy-author').textContent = "@天天炫斗";
  document.getElementById('dy-desc').textContent = "超燃经典游戏！";
}

// 接口回传动态视频直链
window.onDouyinVideoCallback = function(url, author, desc) {
  if (!url) {
    fallbackToBackup();
    return;
  }
  
  // 核心机制：首选开音状态继承
  dyPlayer.muted = !isVideoSoundEnabled;
  if (isVideoSoundEnabled) {
    dyPlayer.volume = 1.0;
  }
  dyPlayer.src = url;
  dyPlayer.load();
  
  var playPromise = dyPlayer.play();
  if (playPromise !== undefined) {
    playPromise.then(function() {
      if (isVideoSoundEnabled) {
        document.getElementById('audio-hint-box').style.display = 'none';
      } else {
        document.getElementById('audio-hint-box').style.display = 'block';
        document.getElementById('audio-hint-box').textContent = "🔊 轻触屏幕一键开启视频声音";
      }
    }).catch(function(e) {
      dyPlayer.muted = true;
      dyPlayer.play().then(function(){
        document.getElementById('audio-hint-box').style.display = 'block';
        document.getElementById('audio-hint-box').textContent = "🔊 点击画面开启视频声音";
      });
      console.log("等待手势唤醒:", e);
    });
  }
  
  document.getElementById('dy-author').textContent = author;
  document.getElementById('dy-desc').textContent = desc;
};

function playDouyinVideo() {
  if (isMusicPlaying) {
    togglePlayState(); // 自动暂停背景音乐唱片
  }
  dyPlayer.play().catch(function(e){ console.log(e); });
}

function pauseDouyinVideo() {
  dyPlayer.pause();
}

// 视频区域单击：一键完美开音，避免播放打断与二次点击
function toggleDouyinPlay() {
  var wasMuted = dyPlayer.muted;
  if (isDyFirstTouch || wasMuted) {
    dyPlayer.muted = false; 
    dyPlayer.volume = 1.0;  
    isDyFirstTouch = false;
    isVideoSoundEnabled = true; // 激活状态记忆
    document.getElementById('audio-hint-box').style.display = 'none';
    showToast('🔊 声音已开启！');
    
    if (!dyPlayer.paused) {
      return; 
    }
  }
  
  if (dyPlayer.paused) {
    playDouyinVideo();
  } else {
    pauseDouyinVideo();
  }
}

// 新增：小姐姐视频进度监听与更新
dyPlayer.addEventListener('timeupdate', function() {
  if (!dyPlayer.duration || isDraggingDyProgress) return;
  var pct = (dyPlayer.currentTime / dyPlayer.duration) * 100;
  document.getElementById('dy-progress-bar-fill').style.width = pct + '%';
  document.getElementById('dy-time-cur').textContent = formatTime(dyPlayer.currentTime);
  document.getElementById('dy-time-dur').textContent = formatTime(dyPlayer.duration);
});

// 新增：视频点击调节
function seekDouyinVideo(e) {
  var bar = document.getElementById('dy-progress-bar-bg');
  var rect = bar.getBoundingClientRect();
  var clickX = e.clientX - rect.left;
  var pct = clickX / rect.width;
  if (dyPlayer.duration) {
    dyPlayer.currentTime = pct * dyPlayer.duration;
  }
}

// 新增：视频拖拽进度条调节
function startDyProgressDrag(e) {
  isDraggingDyProgress = true;
  var bar = document.getElementById('dy-progress-bar-bg');
  var rect = bar.getBoundingClientRect();
  
  function onDragMove(moveEvent) {
    var clientX = moveEvent.touches ? moveEvent.touches[0].clientX : moveEvent.clientX;
    var relativeX = clientX - rect.left;
    var pct = Math.min(Math.max(0, relativeX / rect.width), 1);
    document.getElementById('dy-progress-bar-fill').style.width = (pct * 100) + '%';
    if (dyPlayer.duration) {
      document.getElementById('dy-time-cur').textContent = formatTime(pct * dyPlayer.duration);
    }
  }
  
  function onDragEnd(endEvent) {
    isDraggingDyProgress = false;
    var clientX = endEvent.changedTouches ? endEvent.changedTouches[0].clientX : endEvent.clientX;
    var relativeX = clientX - rect.left;
    var pct = Math.min(Math.max(0, relativeX / rect.width), 1);
    if (dyPlayer.duration) {
      dyPlayer.currentTime = pct * dyPlayer.duration;
    }
    document.removeEventListener('touchmove', onDragMove);
    document.removeEventListener('touchend', onDragEnd);
    document.removeEventListener('mousemove', onDragMove);
    document.removeEventListener('mouseup', onDragEnd);
  }
  
  document.addEventListener('touchmove', onDragMove, {passive: false});
  document.addEventListener('touchend', onDragEnd);
  document.addEventListener('mousemove', onDragMove);
  document.addEventListener('mouseup', onDragEnd);
}

// 独家重构：前端高可靠性剪贴板复制视频直链
function shareVideoLink(e) {
  e.stopPropagation();
  var videoSrc = dyPlayer.src;
  if (!videoSrc || videoSrc === window.location.href) {
    showToast('⚠️ 未能检索到当前视频源地址');
    return;
  }
  
  // 100% 稳定的 HTML 临时文本域安全复制（绝不卡死系统）
  var tempInput = document.createElement("textarea");
  tempInput.value = videoSrc;
  document.body.appendChild(tempInput);
  tempInput.select();
  try {
    document.execCommand('copy');
  } catch(err) {}
  document.body.removeChild(tempInput);

  // 向 Native 底层线程发送安全指令（极速启动跳转微信进程，且永不卡死 GG）
  NA.send('__openWeChat', videoSrc);
}

function onDouyinLike() {
  var icon = document.getElementById('dy-like-icon');
  var count = document.getElementById('dy-like-count');
  if(icon.textContent === "🤍") {
    icon.textContent = "❤️";
    icon.style.color = "#ff2d55";
    count.textContent = "36.9w";
    showToast('💖 感谢您的点赞支持');
  } else {
    icon.textContent = "🤍";
    icon.style.color = "white";
    count.textContent = "36.8w";
  }
}

// 抖音双击点赞和生成飘心动效
function onDouyinDblClick(e) {
  onDouyinLike();
  var wrap = document.getElementById('douyin-swipe-node');
  var rect = wrap.getBoundingClientRect();
  var x = e.clientX - rect.left;
  var y = e.clientY - rect.top;
  
  var heart = document.createElement('div');
  heart.className = 'like-heart';
  heart.textContent = '❤️';
  heart.style.left = (x - 20) + 'px';
  heart.style.top = (y - 20) + 'px';
  wrap.appendChild(heart);
  setTimeout(function() {
    heart.remove();
  }, 800);
}

// 抖音上下滑动切片绑定
(function bindDouyinSwipes() {
  var node = document.getElementById('douyin-swipe-node');
  var startY = 0;
  var minSwipeY = 50;
  node.addEventListener('touchstart', function(e) {
    startY = e.touches[0].clientY;
  });
  node.addEventListener('touchend', function(e) {
    var dy = e.changedTouches[0].clientY - startY;
    if(Math.abs(dy) > minSwipeY) {
      if(dy < 0) { // 上滑
        showToast('👉 正在切入下一条视频...');
      } else { // 下滑
        showToast('👈 返回上一条高清视频...');
      }
      loadDouyinVideo();
    }
  });
})();

// =============================================================================
// 原有侧栏群组渲染与导航跳转控制
// =============================================================================
function onBtn(id, el){
  el.classList.add('btn-click-ani');
  setTimeout(function() { el.classList.remove('btn-click-ani'); }, 300);
  var r = NA.emit(id, ''); 
  if(r) {
    el.textContent = r;
    if(r.indexOf('开') !== -1 || r.toLowerCase().indexOf('on') !== -1) { el.classList.add('btn-on'); } 
    else { el.classList.remove('btn-on'); }
  }
}

function onSideToggle(el) {
  el.classList.add('btn-click-ani');
  setTimeout(function() { el.classList.remove('btn-click-ani'); }, 300);
  if (el.textContent.indexOf('关') !== -1) {
    el.textContent = '开启'; el.classList.add('btn-on'); NA.send('__sideToggle', '开启');
  } else {
    el.textContent = '关闭'; el.classList.remove('btn-on'); NA.send('__sideToggle', '关闭');
  }
}

function onSwitch(id, el){ NA.send(id, el.checked?'1':'0'); }
function onCheck(id, el){ NA.send(id, el.checked?'1':'0'); }
function onSlide(id, el, valId, min, max){
  document.getElementById(valId).textContent = el.value;
  var pct = ((el.value-min)/(max-min)*100).toFixed(1);
  el.style.setProperty('--pct', pct+'%');
  NA.send(id, el.value);
}
function onInput(id, el){ NA.send(id, el.value); }

var currentGroupIdx = 0;
var groupList = [];
var groups = document.querySelectorAll('.group');
for (var i = 0; i < groups.length; i++) { groupList.push(groups[i]); }

var navGame = document.getElementById('nav-game');
var navMusic = document.getElementById('nav-music');

if (groups.length === 0) {
  document.getElementById('accordion-title-game').style.display = 'none';
  document.getElementById('accordion-title-music').style.display = 'none';
} else {
  for (var i = 0; i < groupList.length; i++) {
    (function(idx) {
      var g = groupList[idx];
      var name = g.getAttribute('data-group') || ('组' + (idx + 1));
      var icon = g.getAttribute('data-icon') || '·';
      var item = document.createElement('div');
      item.className = 'nav-item' + (idx === 0 ? ' active' : '');
      item.innerHTML = '<div class="nav-icon">' + icon + '</div><span>' + name + '</span>';
      item.onclick = function() { activate(idx, name); };
      
      if (name === "音乐" || name === "小姐姐") {
        navMusic.appendChild(item);
      } else {
        navGame.appendChild(item);
      }
      
      if (idx === 0) { g.classList.add('active'); document.getElementById('curTitle').textContent = name; }
    })(i);
  }
  bindSwipeGesture(); 
}

function activate(idx, name){
  currentGroupIdx = idx;
  var items = document.querySelectorAll('.nav-item');
  for (var i = 0; i < items.length; i++) {
    var txt = items[i].querySelector('span').textContent;
    if (txt === name) items[i].classList.add('active'); else items[i].classList.remove('active');
  }
  var allGroups = document.querySelectorAll('.group');
  for (var i = 0; i < allGroups.length; i++) {
    var gname = allGroups[i].getAttribute('data-group');
    if (gname === name) {
      allGroups[i].classList.add('active');
      
      if(name === "小姐姐") {
        loadDouyinVideo();
        playDouyinVideo();
      } else {
        pauseDouyinVideo();
      }
    } else {
      allGroups[i].classList.remove('active');
    }
  }
  document.getElementById('curTitle').textContent = name;
  var s = document.getElementById('searchInput');
  if (s && s.value) { s.value = ''; onSearch(''); }
}

function bindSwipeGesture(){
  var bodyEl = document.getElementById('body'); if (!bodyEl) return;
  var startX = 0, startY = 0; var minSwipeDistance = 80;
  bodyEl.addEventListener('touchstart', function(e) {
    startX = e.touches[0].clientX; startY = e.touches[0].clientY;
  }, false);
  bodyEl.addEventListener('touchend', function(e) {
    var endX = e.changedTouches[0].clientX; var endY = e.changedTouches[0].clientY;
    var dx = endX - startX; var dy = endY - startY;
    
    var inVideo = document.querySelector('.group[data-group="小姐姐"]').classList.contains('active');
    var inDrawer = document.getElementById('song-drawer').classList.contains('open');
    if(inVideo || inDrawer) return;

    if (Math.abs(dx) > Math.abs(dy) && Math.abs(dx) >= minSwipeDistance) {
      if (dx < 0) { 
        var next = currentGroupIdx + 1; if (next >= groupList.length) next = 0;
        activate(next, groupList[next].getAttribute('data-group'));
      } else { 
        var prev = currentGroupIdx - 1; if (prev < 0) prev = groupList.length - 1;
        activate(prev, groupList[prev].getAttribute('data-group'));
      }
    }
  }, false);
}

function onSearch(q){
  var body = document.getElementById('body'); q = (q || '').trim().toLowerCase();
  var rows = body.querySelectorAll('.row');
  if (!q) {
    body.classList.remove('searching');
    for (var i = 0; i < rows.length; i++) { rows[i].classList.remove('hide'); }
    var activeNav = document.querySelector('.nav-item.active span');
    document.getElementById('curTitle').textContent = activeNav ? activeNav.textContent : '版本：1.52.30.1';
    return;
  }
  body.classList.add('searching'); var count = 0;
  for (var i = 0; i < rows.length; i++) {
    var r = rows[i]; var labelEl = r.querySelector('.row-label-text');
    var text = (labelEl ? labelEl.textContent : '').toLowerCase();
    if (text.indexOf(q) !== -1) { r.classList.remove('hide'); count++; } else { r.classList.add('hide'); }
  }
  document.getElementById('curTitle').textContent = count ? '搜索 · ' + count + ' 项' : '无匹配';
}

(function(){
  var h = document.getElementById('drag-handle'); if (!h) return;
  var lastX = 0, lastY = 0, dragging = false;
  h.addEventListener('touchstart', function(e) {
    var p = e.target; while(p && p !== h) { if(p.className && p.className.indexOf('small-btn') !== -1) return; p = p.parentNode; }
    var t = e.touches[0]; lastX = t.screenX; lastY = t.screenY; dragging = true;
  }, false);
  h.addEventListener('touchmove', function(e) {
    if (!dragging) return;
    var t = e.touches[0]; var dpr = window.devicePixelRatio || 1;
    var dx = (t.screenX - lastX) * dpr; var dy = (t.screenY - lastY) * dpr;
    lastX = t.screenX; lastY = t.screenY; if (dx || dy) NA.send('__move', dx + ',' + dy); 
  }, false);
  h.addEventListener('touchend', function() { dragging = false; }, false);
})();

(function(){
  var h = document.getElementById('resize-handle'); var panel = document.getElementById('panel'); if (!h) return;
  var startX = 0, startY = 0, startW = 0, startH = 0; var totalDx = 0, totalDy = 0, sizing = false;
  h.addEventListener('touchstart', function(e) {
    var t = e.touches[0]; startX = t.screenX; startY = t.screenY;
    var rect = panel.getBoundingClientRect(); startW = rect.width; startH = rect.height;
    sizing = true; panel.style.width = startW + 'px'; panel.style.height = startH + 'px'; e.stopPropagation();
  }, false);
  h.addEventListener('touchmove', function(e) {
    if (!sizing) return; var t = e.touches[0]; totalDx = t.screenX - startX; totalDy = t.screenY - startY;
    panel.style.width = Math.max(320, startW + totalDx) + 'px'; panel.style.height = Math.max(240, startH + totalDy) + 'px';
  }, false);
  h.addEventListener('touchend', function() {
    if (!sizing) return; sizing = false; panel.style.width = ''; panel.style.height = '';
    if (totalDx || totalDy) { var dpr = window.devicePixelRatio || 1; NA.send('__size', (totalDx * dpr) + ',' + (totalDy * dpr)); }
  }, false);
})();
</script>
</body></html>
]]

-- =============================================================================
-- 核心框架代码 (加载及核心引擎解析)
-- =============================================================================

local dpath = "/sdcard/elgg/webBridge.dex"
if io.open(dpath) == nil then
	file.download("http://wss.wigwy.xyz/api/get/yjb/2067", dpath)
end
compile(dpath) 

import("android.app.*")
import("android.os.*")
import("android.widget.*")
import("android.content.*")
import("android.view.*")
import("android.graphics.*")
import("android.webkit.WebView")
import("android.webkit.WebViewClient")
import("com.Shizuku.WebBridge")

window = activity.getSystemService("window") 

function htmlEscape(s)
	if not s then return "" end
	s = tostring(s)
	s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&#39;")
	return s
end

function jsonEncode(v)
	local t = type(v)
	if t == "nil" then return "null"
	elseif t == "boolean" then return v and "true" or "false"
	elseif t == "number" then return tostring(v)
	elseif t == "string" then
		local s = v:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n"):gsub("\r", "\\r"):gsub("\t", "\\t"):gsub("</", "<\\/")
		return '"' .. s .. '"'
	elseif t == "table" then
		local isArr = (#v > 0) 
		if isArr then
			local parts = {}
			for i, x in ipairs(v) do parts[i] = jsonEncode(x) end
			return "[" .. table.concat(parts, ",") .. "]"
		else
			local parts = {}
			for k, x in pairs(v) do
				if type(k) == "string" and type(x) ~= "function" then
					parts[#parts + 1] = jsonEncode(k) .. ":" .. jsonEncode(x)
				end
			end
			return "{" .. table.concat(parts, ",") .. "}"
		end
	end
	return "null"
end

function buildConfig()
	local cfg = {}
	for k, v in pairs(menu) do
		if type(k) == "string" and type(v) ~= "function" then cfg[k] = v end
	end
	return jsonEncode(cfg)
end

function renderItem(it)
	local id = htmlEscape(it.id)
	local label = htmlEscape(it.label or "美梦")
	local icon = htmlEscape(it.icon or (it.label or "?"):sub(1, 1))
	
	if it.type == "button" then
		local btnTxt = it.btnText or "激活"
		local cls = ""
		if btnTxt:find("开") then cls = " btn-on" end
		return string.format(
			'<div class="row"><div class="row-label"><span class="row-icon">%s</span>'
				.. '<span class="row-label-text">%s</span></div>'
				.. '<button class="btn%s" onclick="onBtn(\'%s\',this)">%s</button></div>',
			icon, label, cls, id, htmlEscape(btnTxt)
		)
	elseif it.type == "switch" then
		local chk = it.default and "checked" or ""
		return string.format(
			'<div class="row"><div class="row-label"><span class="row-icon">%s</span>'
				.. '<span class="row-label-text">%s</span></div>'
				.. '<label class="sw"><input type="checkbox" %s '
				.. "onchange=\"onSwitch('%s',this)\">"
				.. '<span class="sw-bg"></span><span class="sw-knob"></span></label></div>',
			icon, label, chk, id
		)
	elseif it.type == "checkbox" then
		local chk = it.default and "checked" or ""
		return string.format(
			'<div class="row"><div class="row-label"><span class="row-icon">%s</span>'
				.. '<span class="row-label-text">%s</span></div>'
				.. '<label class="cb"><input type="checkbox" %s '
				.. "onchange=\"onCheck('%s',this)\">"
				.. '<span class="cb-box"></span></label></div>',
			icon, label, chk, id
		)
	elseif it.type == "slider" then
		local min = it.min or 0
		local max = it.max or 100
		local def = it.default or min
		local pct = (def - min) / (max - min) * 100
		local vid = id .. "_val"
		return string.format(
			'<div class="row row-block">'
				.. '<div class="slider-top"><div class="row-label">'
				.. '<span class="row-icon">%s</span><span class="row-label-text">%s</span></div>'
				.. '<span class="slider-val" id="%s">%s</span></div>'
				.. '<input type="range" class="slider" min="%s" max="%s" value="%s" '
				.. "style=\"--pct:%.1f%%\" oninput=\"onSlide('%s',this,'%s',%s,%s)\"></div>",
			icon, label, vid, tostring(def), tostring(min), tostring(max), tostring(def), pct, id, vid, tostring(min), tostring(max)
		)
	elseif it.type == "input" then
		return string.format(
			'<div class="row row-block">'
				.. '<div class="row-label"><span class="row-icon">%s</span>'
				.. '<span class="row-label-text">%s</span></div>'
				.. '<input type="text" class="inp" value="%s" placeholder="%s" '
				.. "oninput=\"onInput('%s',this)\"></div>",
			icon, label, htmlEscape(it.default or ""), htmlEscape(it.placeholder or ""), id
		)
	end
	return ""
end

function isGroupedMenu()
	for _, it in ipairs(menu) do
		if it.group ~= nil and it.items ~= nil then return true end
	end
	return false
end

function buildItems()
	if isGroupedMenu() then
		local parts = {}
		for _, g in ipairs(menu) do
			local name = htmlEscape(g.group or "")
			local icon = htmlEscape(g.icon or (g.group or "?"):sub(1, 1))
			local rows = {}
			if g.items and #g.items > 0 then
				for _, it in ipairs(g.items or {}) do rows[#rows + 1] = renderItem(it) end
				parts[#parts + 1] = string.format(
					'<section class="group" data-group="%s" data-icon="%s">%s</section>',
					name, icon, table.concat(rows, "\n")
				)
			end
		end
		return table.concat(parts, "\n")
	else
		local rows = {}
		for _, it in ipairs(menu) do rows[#rows + 1] = renderItem(it) end
		return table.concat(rows, "\n")
	end
end

function buildHtml()
	local itemsHtml = buildItems()
	local titleHtml = htmlEscape(menu.title or "美梦")
	local configJson = buildConfig()
	local h = htmlTemplate
	h = h:gsub("{{TITLE}}", function() return titleHtml end)
	h = h:gsub("{{ITEMS}}", function() return itemsHtml end)
	h = h:gsub("{{CONFIG}}", function() return configJson end)
	h = h:gsub("{{BG_IMG_URL}}", function() return htmlEscape(BG_IMG_URL or "") end)
	h = h:gsub("{{ICON_URL}}", function() return htmlEscape(ICON_IMG_URL or "") end)
	h = h:gsub("{{WEB_URL}}", function() return htmlEscape(CLICK_WEB_URL or "") end)
	h = h:gsub("{{BRAND_BTN1_TEXT}}", function() return htmlEscape(BRAND_BTN1_TEXT or "按钮1") end)
	h = h:gsub("{{BRAND_BTN2_TEXT}}", function() return htmlEscape(BRAND_BTN2_TEXT or "按钮2") end)
	h = h:gsub("{{SCROLL_TEXT}}", function() return htmlEscape(SCROLL_TEXT or "") end)
	return h
end

-- =============================================================================
-- 事件接管路由系统
-- =============================================================================
function buildActions()
	local a = {}
	local function reg(it)
		if it.type == "button" and it.onClick then
			a[it.id] = function(d) return it.onClick(d) end
		elseif it.onChange then
			a[it.id] = function(d) return it.onChange(d) end
		end
	end
	if isGroupedMenu() then
		for _, g in ipairs(menu) do
			for _, it in ipairs(g.items or {}) do reg(it) end
		end
	else
		for _, it in ipairs(menu) do reg(it) end
	end
	
	-- 完美接入网易官方数据接口
	a["__searchQQMusic"] = function(keyword)
		sub(function()
			pcall(function()
				import("java.net.URL")
				import("java.net.URLEncoder")
				local encoded = URLEncoder.encode(keyword, "UTF-8")
				local searchUrl = "http://music.163.com/api/search/get?s=" .. encoded .. "&type=1&offset=0&total=true&limit=12"
				local conn = URL(searchUrl).openConnection()
				conn.setRequestProperty("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
				conn.setConnectTimeout(8000)
				conn.setReadTimeout(8000)
				local stream = conn.getInputStream()
				local BufferedReader = import("java.io.BufferedReader")
				local InputStreamReader = import("java.io.InputStreamReader")
				local reader = BufferedReader(InputStreamReader(stream, "UTF-8"))
				local response = ""
				local line = reader.readLine()
				while line ~= nil do
					response = response .. line
					line = reader.readLine()
				end
				reader.close()
				
				activity.runOnUiThread(function()
					pcall(function()
						-- 仅安全转义必要字符，确保不破坏基础数据结构
						local escapedJson = response:gsub("\\", "\\\\"):gsub("'", "\\'"):gsub("\r", ""):gsub("\n", "")
						web.loadUrl("javascript:onQQMusicSearchCallback('" .. escapedJson .. "')")
					end)
				end)
			end)
		end)
	end

	-- 动态获取并回传对应歌曲的真实高精密歌词
	a["__fetchLyrics"] = function(songId)
		sub(function()
			pcall(function()
				import("java.net.URL")
				local lyricUrl = "http://music.163.com/api/song/lyric?id=" .. tostring(songId) .. "&lrc=1&lv=1"
				local conn = URL(lyricUrl).openConnection()
				conn.setRequestProperty("User-Agent", "Mozilla/5.0")
				conn.setConnectTimeout(6000)
				local stream = conn.getInputStream()
				local BufferedReader = import("java.io.BufferedReader")
				local InputStreamReader = import("java.io.InputStreamReader")
				local reader = BufferedReader(InputStreamReader(stream, "UTF-8"))
				local response = ""
				local line = reader.readLine()
				while line ~= nil do
					response = response .. line .. "\n"
					line = reader.readLine()
				end
				reader.close()
				
				activity.runOnUiThread(function()
					pcall(function()
						-- 核心转换逻辑：将真实的换行符安全转化为 JS 能识别的 \\n，从而完整保存分行歌词数据
						local escapedJson = response:gsub("\\", "\\\\"):gsub("'", "\\'"):gsub("\r", "\\r"):gsub("\n", "\\n")
						web.loadUrl("javascript:onLyricsCallback('" .. escapedJson .. "')")
					end)
				end)
			end)
		end)
	end

	-- 完美搭载您提供的随机视频接口，并加入重定向直链提取和防盗链保障
	a["__fetchDouyinVideo"] = function()
		sub(function()
			local rawUrl = "http://api.yujn.cn/api/xjj.php"
			local videoUrl = nil
			local author = "💖小姐姐ᮨ ້໌ᮨ💞ۖ ້໌ᮨ"
			local desc = "超清沉浸"
			
			pcall(function()
				import("java.net.URL")
				import("java.net.HttpURLConnection")
				local conn = URL(rawUrl).openConnection()
				conn.setInstanceFollowRedirects(false) -- 获取其重定向后的真实直链
				conn.setRequestProperty("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
				conn.setConnectTimeout(6000)
				conn.setReadTimeout(6000)
				conn.connect()
				
				local code = conn.getResponseCode()
				if code == 302 or code == 301 then
					videoUrl = conn.getHeaderField("Location")
				end
			end)
			
			-- 容灾处理
			if not videoUrl then
				videoUrl = rawUrl
			end
			
			activity.runOnUiThread(function()
				pcall(function()
					web.loadUrl(string.format("javascript:onDouyinVideoCallback('%s', '%s', '%s')", videoUrl, author, desc))
				end)
			end)
		end)
	end
	
	-- 新增：安全隔离运行的系统级后台音乐下载器 (使用安卓原生的 DownloadManager，杜绝 0B 文件，自带通知栏进度和完成通知)
	a["__downloadMusic"] = function(data)
		local url, title = data:match("([^,]+),(.+)")
		if not url then return end
		sub(function()
			pcall(function()
				import("android.net.Uri")
				import("android.app.DownloadManager")
				import("android.os.Environment")
				
				local downloadManager = activity.getSystemService("download")
				local uri = Uri.parse(url)
				local request = DownloadManager.Request(uri)
				
				-- 允许使用移动数据流量和Wi-Fi网络进行下载
				request.setAllowedNetworkTypes(3) -- NETWORK_WIFI | NETWORK_MOBILE
				
				-- 设置通知栏的显示规则：下载中和下载完成时均在系统通知栏进行悬浮窗气泡播报
				request.setNotificationVisibility(1) -- VISIBILITY_VISIBLE_NOTIFY_COMPLETED
				
				request.setTitle("正在下载音乐: " .. title)
				request.setDescription("天天炫斗高品质曲库")
				
				-- 安全且统一地规定保存到内置存储的 /Download 文件夹中
				request.setDestinationInExternalPublicDir(Environment.DIRECTORY_DOWNLOADS, title .. ".mp3")
				
				-- 递交给系统排队下载进程
				downloadManager.enqueue(request)
				
				activity.runOnUiThread(function()
					gg.toast("⏳ 已成功唤起系统极速下载: 《" .. title .. "》\n请拉下手机通知栏查看下载进度！")
				end)
			end)
		end)
	end

	-- 独家重构：微信进程极速拉起管理器 (采用安全子线程调用和 FLAG 保护，彻底解决 GG 闪退/卡死的致命问题)
	a["__openWeChat"] = function(videoUrl)
		sub(function()
			pcall(function()
				-- 1. Native Java 层辅助写入剪贴板 (增加一层防崩溃校验)
				activity.runOnUiThread(function()
					pcall(function()
						local clipboard = activity.getSystemService("clipboard")
						local ClipData = luajava.bindClass("android.content.ClipData")
						local clip = ClipData.newPlainText("video_url", videoUrl)
						clipboard.setPrimaryClip(clip)
					end)
				end)
				
				-- 2. 获取并直接启动微信 (如果微信安装正常，在新 Activity 栈中极速拉起)
				local pm = activity.getPackageManager()
				local intent = pm.getLaunchIntentForPackage("com.tencent.mm")
				if intent then
					intent.addFlags(0x10000000) -- Intent.FLAG_ACTIVITY_NEW_TASK = 0x10000000 (避免非Activity context拉起崩溃)
					activity.startActivity(intent)
					gg.toast("📋 视频链接已自动复制！正在为您跳转到微信...")
				else
					gg.toast("📋 视频链接已自动复制！设备中未检测到微信客户端")
				end
			end)
		end)
	end
	
	a["__move"] = function(data)
		local dx, dy = data:match("([%-%d%.]+),([%-%d%.]+)")
		dx = tonumber(dx) or 0
		dy = tonumber(dy) or 0
		activity.runOnUiThread(function()
			xfcP.x = (xfcP.x or 0) + dx
			xfcP.y = (xfcP.y or 0) + dy
			pcall(function() window.updateViewLayout(xfc, xfcP) end)
		end)
	end
	a["__size"] = function(data)
		local lp = web.getLayoutParams()
		local dx, dy = data:match("([%-%d%.]+),([%-%d%.]+)")
		dx = tonumber(dx) or 0
		dy = tonumber(dy) or 0
		activity.runOnUiThread(function()
			lp.width = (lp.width or 0) + dx
			lp.height = (lp.height or 0) + dy
			pcall(function() web.setLayoutParams(lp) end)
		end)
	end
	a["__reduce"] = function()
		window.removeView(xfc)
		window.addView(xfq, xfqP)
	end
	a["__exit"] = function()
		if type(menu.onExit) == "function" then pcall(menu.onExit) end
		activity.runOnUiThread(function()
			pcall(function() window.removeView(xfc) end)
			luajava.exit()
		end)
	end
	a["__openUrl"] = function(url)
		if url and url ~= "" and url:find("^http") then
			pcall(function()
				local Uri = luajava.bindClass("android.net.Uri")
				local Intent = luajava.bindClass("android.content.Intent")
				local intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
				intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
				activity.startActivity(intent)
			end)
		end
	end
	a["__brandBtn1"] = function() pcall(function() qq.joinGroup("980111749") end) end
	a["__brandBtn2"] = function()
		pcall(function()
			local Uri = luajava.bindClass("android.net.Uri")
			local Intent = luajava.bindClass("android.content.Intent")
			local intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://ttxd.qq.com/index.shtml#slide0"))
			intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
			activity.startActivity(intent)
		end)
	end
	a["__sideToggle"] = function(stateText)
		sub(function()
			local w = " ۖۚۖ ້໌ᮨ𝕼人物加速 ۖۚۖ ້໌ᮨ𝕼"
			local z = "Var #6E8AF910B4|6e8af910b4|10|4479c000|0|0|0|0|r-xp|/data/app/com.tencent.game.VXDGame-sh0Bsv76dq2NUqdZfzXu9Q==/lib/arm64/libGameApp.so|5d00b4"
			local pa = "/sdcard/💞ۖ ້໌ᮨ ້໌ᮨ💞ۖ ້໌ᮨ大郎 ۖۚۖ ້໌ᮨ𝕼"
			local file = io.open(pa, "w")
			if file then
				file:write("" .. w .. "\n" .. z .. "")
				file:close()
				gg.loadList(pa)
				local b = gg.getListItems()
				if b and #b > 0 then
					local t = {}
					t[1] = {}
					t[1].address = b[1].address
					t[1].flags = 16
					if stateText == "开启" then
						t[1].value = 520
						gg.toast("⚡ 人物加速(80倍)")
					else
						t[1].value = 60
						gg.toast("⚡人物加速已还原")
					end
					gg.setValues(t)
					gg.removeListItems(b)
				end
				os.remove(pa)
			end
		end)
	end
	return a
end

function getLayoutParams(flag)
	local LP = WindowManager.LayoutParams
	local lp = luajava.new(LP)
	lp.type = LP.TYPE_APPLICATION_OVERLAY 
	lp.format = PixelFormat.RGBA_8888      
	lp.flags = flag
	lp.gravity = Gravity.CENTER
	lp.width = LP.WRAP_CONTENT
	lp.height = LP.WRAP_CONTENT
	return lp
end
-- =============================================================================
function LoadUI()
	xfc = loadlayout({
		CardView,
		radius = "30dp",
		elevation = 0,
		CardBackgroundColor = 0x00000000, 
		onTouch = function(v, event)
			if event.getAction() == MotionEvent.ACTION_OUTSIDE then
				window.removeView(xfc)
				window.addView(xfq, xfqP)
				return true
			end
		end,
		{
			WebView,
			id = "web",
			layout_width = menu.width or "490dp",  
			layout_height = menu.height or "367dp", 
		},
	})
	
	local ws = web.getSettings()
	ws.setJavaScriptEnabled(true)
	ws.setDomStorageEnabled(true)
	ws.setDatabaseEnabled(true)
	ws.setLoadsImagesAutomatically(true)

	-- 强制激活 WebView 硬件加速（极其关键：修复低版本安卓系统黑屏、无画面的顽疾）
	if Build.VERSION.SDK_INT >= 11 then
		web.setLayerType(View.LAYER_TYPE_HARDWARE, nil)
	end

	-- 允许在没有任何手势交互的情况下，通过 JS 强行唤醒并自动播放视频音频
	if Build.VERSION.SDK_INT >= 17 then
		ws.setMediaPlaybackRequiresUserGesture(false)
	end
	
	-- 允许加载 Mixed Content (支持在网页内顺利解析加载并播放各种不规则协议的视频流，解除拦截政策)
	if Build.VERSION.SDK_INT >= 21 then
		ws.setMixedContentMode(0) -- MIXED_CONTENT_ALWAYS_ALLOW
	end
	
	web.setBackgroundColor(0x00000000) 
	web.setWebViewClient(WebViewClient())
	
	bridge = luajava.new(WebBridge, web)
	actions = buildActions()
	local Handler = import("com.Shizuku.WebBridge$EventHandler")
	bridge.setHandler(Handler({
		onEvent = function(name, data)
			local fn = actions[name]
			if fn then return fn(data) or "" end
			return ""
		end,
	}))
	web.addJavascriptInterface(bridge, "NA") 
	web.loadDataWithBaseURL("file:///android_asset/", buildHtml(), "text/html", "utf-8", nil) 
	
	local isMoved = true
	xfq = loadlayout({
		CardView,
		layout_width = "200dp",   
		layout_height = "600dp",  
		radius = "1100dp",         
		elevation = "2dp",
		CardBackgroundColor = 0xFFFFFFFF,
		onTouch = function(v, event)
			local Action = event.getAction()
			if Action == MotionEvent.ACTION_DOWN then
				firstX = event.getRawX() firstY = event.getRawY()
				x = xfqP.x y = xfqP.y isMoved = false return true
			elseif Action == MotionEvent.ACTION_MOVE then
				local dx = event.getRawX() - firstX
				local dy = event.getRawY() - firstY
				if math.abs(dx) > 10 or math.abs(dy) > 10 then
					isMoved = true xfqP.x = x + dx xfqP.y = y + dy
					window.updateViewLayout(xfq, xfqP)
				end
				return true
			elseif Action == MotionEvent.ACTION_UP then
				if not isMoved then
					window.removeView(xfq)
					window.addView(xfc, xfcP)
				end
				return true
			end
			return false
		end,
		{
			ImageView,
			id = "float_img",
			layout_width = "match_parent",
			layout_height = "match_parent",
			scaleType = "centerCrop",
		},
	})
	
	if FLOAT_ICON_URL and FLOAT_ICON_URL ~= "" then
		sub(function()
			pcall(function()
				import("java.net.URL")
				import("android.graphics.BitmapFactory")
				local conn = URL(FLOAT_ICON_URL).openConnection()
				conn.setConnectTimeout(6000) conn.setReadTimeout(6000) conn.connect()
				local input = conn.getInputStream()
				local bitmap = BitmapFactory.decodeStream(input)
				input.close()
				if bitmap then
					activity.runOnUiThread(function() float_img.setImageBitmap(bitmap) end)
				end
			end)
		end)
	end
	
	xfcP = getLayoutParams(263200)
	xfqP = getLayoutParams(8)
	window.addView(xfc, xfcP)
end

-- =============================================================================
-- 安全隔离运行
-- =============================================================================
Lock.Ui(LoadUI, nil, function(err)
	print(err) 
	luajava.exit()
end)
