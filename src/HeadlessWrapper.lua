#@
-- This wrapper allows the program to run headless on any OS (in theory)
-- It can be run using a standard lua interpreter, although LuaJIT is preferable

__pobDirPath__ = '/home/xuhaojun/Desktop/PathOfBuilding/src'
package.path = __pobDirPath__ .. '/?.lua;' .. package.path

LibDeflate = require("LibDeflate")

local xml = require("xml")
local json = require("json")

bit = bit or bit32 or require("bitop.funcs")
unpack = unpack or table.unpack
loadstring = loadstring or load

local lua_version = _VERSION:sub(-3)
if lua_version > "5.2" then
	_old_string_format = string.format
	local function string_format(fmt, ...)
		local args, n = { ... }, select('#', ...)
		local fmt2 = string.gsub(fmt, "%%d", "%%.0f")
		fmt2 = string.gsub(fmt2, "%%%+d", "%%+.0f")
		print(unpack(args, 1, n))
		return _old_string_format(fmt2, unpack(args, 1, n))
	end
	_G.string.format = string_format
end

math = math or {}
function math.pow(a, b)
    return a ^ b
end

local Path = require('path')
_oldLoadfile = loadfile
function loadfile(path)
  if Path.isabs(path) then
    return _oldLoadfile(path)
  else
    modifiedPath = __pobDirPath__ .. "/" .. path
    -- print("loadfile: " .. modifiedPath)
    return _oldLoadfile(modifiedPath)
  end
end
_oldDofile = dofile
function dofile(path)
  if Path.isabs(path) then
    return _oldDofile(path)
  else
    modifiedPath = __pobDirPath__ .. "/" .. path
    -- print(""dofile: "" .. modifiedPath)
    return _oldDofile(modifiedPath)
  end
end
_oldIo = io
local function open(path, mode)
  if Path.isabs(path) then
    return _oldIo.open(path)
  else
    if string.match(path, '%.png') or string.match(path, '%.jpg') then
      return nil
    else
      modifiedPath = __pobDirPath__ .. "/" .. path
      -- print(""io.open: "" .. modifiedPath)
      return _oldIo.open(modifiedPath, mode)
    end
  end
end
local function lines(path)
  if Path.isabs(path) then
    return _oldIo.lines(path)
  else
    modifiedPath = __pobDirPath__ .. '/' .. path
    -- print(""io.lines: "" .. modifiedPath)
    return _oldIo.lines(modifiedPath)
  end
end
io = { open=open, lines=lines, read=_oldIo.read, write=_oldIo.write, close=_oldIo.close, stderr=_oldIo.stderr }

t_insert = table.insert
t_remove = table.remove
m_min = math.min
m_max = math.max
m_floor = math.floor
m_abs = math.abs
s_format = string.format

-- Callbacks
local callbackTable = { }
local mainObject
function runCallback(name, ...)
	if callbackTable[name] then
		return callbackTable[name](...)
	elseif mainObject and mainObject[name] then
		return mainObject[name](mainObject, ...)
	end
end
function SetCallback(name, func)
	callbackTable[name] = func
end
function GetCallback(name)
	return callbackTable[name]
end
function SetMainObject(obj)
	mainObject = obj
end

-- Image Handles
local imageHandleClass = { }
imageHandleClass.__index = imageHandleClass
function NewImageHandle()
	return setmetatable({ }, imageHandleClass)
end
function imageHandleClass:Load(fileName, ...)
	self.valid = true
end
function imageHandleClass:Unload()
	self.valid = false
end
function imageHandleClass:IsValid()
	return self.valid
end
function imageHandleClass:SetLoadingPriority(pri) end
function imageHandleClass:ImageSize()
	return 1, 1
end

-- Rendering
function RenderInit() end
function GetScreenSize()
	return 1920, 1080
end
function SetClearColor(r, g, b, a) end
function SetDrawLayer(layer, subLayer) end
function SetViewport(x, y, width, height) end
function SetDrawColor(r, g, b, a) end
function DrawImage(imgHandle, left, top, width, height, tcLeft, tcTop, tcRight, tcBottom) end
function DrawImageQuad(imageHandle, x1, y1, x2, y2, x3, y3, x4, y4, s1, t1, s2, t2, s3, t3, s4, t4) end
function DrawString(left, top, align, height, font, text) end
function DrawStringWidth(height, font, text)
	return 1
end
function DrawStringCursorIndex(height, font, text, cursorX, cursorY)
	return 0
end
function StripEscapes(text)
	return text:gsub("%^%d",""):gsub("%^x%x%x%x%x%x%x","")
end
function GetAsyncCount()
	return 0
end

-- Search Handles
function NewFileSearch() end

-- General Functions
function SetWindowTitle(title) end
function GetCursorPos()
	return 0, 0
end
function SetCursorPos(x, y) end
function ShowCursor(doShow) end
function IsKeyDown(keyName) end
function Copy(text) end
function Paste() end
function Deflate(data)
	return LibDeflate:CompressZlib(data)
end
function Inflate(data)
	return LibDeflate:DecompressZlib(data)
end
function GetTime()
	return 0
end
function GetScriptPath()
	return ""
end
function GetRuntimePath()
	return ""
end
function GetUserPath()
	return ""
end
function MakeDir(path) end
function RemoveDir(path) end
function SetWorkDir(path) end
function GetWorkDir()
	return ""
end
function LaunchSubScript(scriptText, funcList, subList, ...) end
function AbortSubScript(ssID) end
function IsSubScriptRunning(ssID) end
function LoadModule(fileName, ...)
	if not fileName:match("%.lua") then
		fileName = fileName .. ".lua"
	end
	local func, err = loadfile(fileName)
	if func then
		return func(...)
	else
		error("LoadModule() error loading '"..fileName.."': "..err)
	end
end
function PLoadModule(fileName, ...)
	if not fileName:match("%.lua") then
		fileName = fileName .. ".lua"
	end
	local func, err = loadfile(fileName)
	if func then
		return PCall(func, ...)
	else
		error("PLoadModule() error loading '"..fileName.."': "..err)
	end
end
function PCall(func, ...)
	local ret = { pcall(func, ...) }
	if ret[1] then
		table.remove(ret, 1)
		return nil, unpack(ret)
	else
		return ret[2]
	end	
end
function ConPrintf(fmt, ...)
	-- Optional
	print(string.format(fmt, ...))
end
function ConPrintTable(tbl, noRecurse) end
function ConExecute(cmd) end
function ConClear() end
function SpawnProcess(cmdName, args) end
function OpenURL(url) end
function SetProfiling(isEnabled) end
function Restart() end
function Exit() end

local l_require = require
function require(name)
	-- Hack to stop it looking for lcurl, which we don't really need
	if name == "lcurl.safe" then
		return
	end
	return l_require(name)
end


print("before Launch.lua")
dofile("Launch.lua")
print("after Launch.lua")

-- Prevents loading of ModCache
-- Allows running mod parsing related tests without pushing ModCache
-- The CI env var will be true when run from github workflows but should be false for other tools using the headless wrapper 
mainObject.continuousIntegrationMode = true

runCallback("OnInit")
runCallback("OnFrame") -- Need at least one frame for everything to initialise

mainObject.DownloadPage = DownloadPage
mainObject.CheckForUpdate = function () end

if mainObject.promptMsg then
    -- Something went wrong during startup
    error("ERROR: "..mainObject.promptMsg)
    return
end

-- if mainObject.promptMsg then
-- -- Something went wrong during startup
-- 	print(mainObject.promptMsg)
-- 	io.read("*l")
-- 	return
-- end


-- The build module; once a build is loaded, you can find all the good stuff in here
build = mainObject.main.modes["BUILD"]

build.actionOnSave = nil
if GlobalCache then GlobalCache.useFullDPS = true end

-- Here's some helpful helper functions to help you get started
function newBuild()
	mainObject.main:SetMode("BUILD", false, "Help, I'm stuck in Path of Building!")
	runCallback("OnFrame")
end
function loadBuildFromXML(xmlText, name)
	mainObject.main:SetMode("BUILD", false, name or "", xmlText)
	runCallback("OnFrame")
end
function loadBuildFromJSON(getItemsJSON, getPassiveSkillsJSON)
	mainObject.main:SetMode("BUILD", false, "")
	runCallback("OnFrame")
	local charData = build.importTab:ImportItemsAndSkills(getItemsJSON)
	build.importTab:ImportPassiveTreeAndJewels(getPassiveSkillsJSON, charData)
	-- You now have a build without a correct main skill selected, or any configuration options set
	-- Good luck!
end

function codeToXml(buf)
		local xmlText = Inflate(common.base64.decode(buf:gsub("-","+"):gsub("_","/")))
		return xmlText
end

function saveBuildToXml()
    local xmlText = build:SaveDB("dummy")
		if mainObject.promptMsg then
    		-- Something went wrong during startup
    		error("ERROR: "..mainObject.promptMsg)
    		return
		end
    if not xmlText then
        print("Failed to prepare save XML")
        os.exit(1)
    end
    return xmlText
end

function getBuildXmlByXml(xmlText)
	loadBuildFromXML(xmlText, "Imported Build")
	if mainObject.promptMsg then
    	-- Something went wrong during startup
    	error("ERROR: "..mainObject.promptMsg)
    	return
	end
	local result = saveBuildToXml()
	return result
end

-- local foo = codeToXml("eNrlXVuTm0iyfp7-FURH7HmxbFN38LF3Q33vmbbdI7Xt8XlxFFC0GCOQAXW7vbH__WQBkkACCV28sXPOzk6PBJlZVZlf5aWqQK__8X0cGg8qSYM4enOMXpjHhorc2Aui-zfHH-4unlvH__j70etbmY3e-yfTINR3_n70y-v8sxGqBxW-ObbtYyOTyb3KPs5EkS8gaiKjbKTi6K38M04uY-_N8bs4UseGIyMvyGbf3FCm6Ts5Vm-O79R4Esrk2JCpqyLvdHHncioTL5ARkI9kIt1MJTe68f40i9_GHlD4MkxB2lgG0TB2v6rsMomnkzfH_Nh4CNRjQXQ3OD-v9CuIqv2Ccf3y-jaUTyoZZjIzUvjz5rjvZsGDAlIY100wDjKQJ8MpCMPm8csWHlCpvFdXFeJNtCfTJM3O5Bg-buYZTpTy5mTkBaVtlLeJOvd9lY_hNAmy05GM3A4tbEv7dhpmwSQMVDKnRy9YG8fVinBktoq_izMZnt0ON3ekoIw7KP1TkI1OQlBiJ7ma-vo-CjLVmfw2DtI42qrXnYhPp2EIU7AT7UClKnmQWdCxI6fx2AmijjoZKhmexnHoxY_RgvqFwOsY3srvC9S26iMYKyDU9Olirr1AvI3hrYzkaZwuzM7sdaS3KgHnktU4zA0MQ-XG4I-qLNjEL2zeoaFm9tYWbwJfdafcajAlw7a92W0c58OudFsL3q1DA3Ct3SiH8TTsSJkt_B1mpH0mfqtSIobaKM_U9wqZWCOwRklbgXgdLYZBGF4jsEqJLNLew4dYu5SOju386nZOaWNGXxCLYyIsLlq7fDt6SgM39xbBeDqGYHEnv6qoMgxO2vF6P8oi8JBtzNQmrVq9CBLVyic4anecobcT30jGaRtjEPnrJuXCVGuSBPeVJr2O3G4T_UOU5CGjklugdfQDmH06e3FC1Y1h0UA5hbvE_6KlexWVzT11G8yNUu7oErLBgcxUN0e_MBq11qtVU1fVSvBawU2KtZjVjWVZVRS9oJzYzAIki3YwayHNakM2ZIzr2LZU3Xmkkvun4ShQYWV8hOAuDLPencpJJ95c_VUBVTOgdnXU22xUi8le8C7sW6rnE1Qu3aLTlig_f5Bp1REjisV6tRUMVY3ZrYp-qyA_Bg5PLaXqa2qN-E9daYTbsfWTcTythFHMmLl2GAVDdRTC3hRLispqoLypWwtevJXzJIQqcmkMmK7pWBg2sdDWBvpZJt2vZ7F3r7pWWnkrW3HMi7-cdTidTMCtaBAsCSDWuqAIlURQSYcE20z8HjBcm9Prgmdn-QviZfmbM4LlRnhHjuWW2nOtPJ4vNfOcmx3Il9vYbM-34CTGEBbypYC3sVetlFpRegHVY6fqLifsWJLexo_Q-ZFe_0m3o-5UDl4kKvrx1Fl-jbxTA-eRN030ZOjcxjJHp2Y6rCMVN1fXhpaWhWzbekEpsUxb_xFtzMuLRExYNhWEWxQjdFCmlRUawgR5AdmJBd00qVjP17Bes0LZuF7TsZXm1ZstmFfXcrYcX9M0WiFes7KzQrthZWdVdsPKTscx1GoNjDlbR7g-gWlkWZ9MrbA05pqY4y70W_aue8qnV6xCCKtnMpOGV9bHH2USyCjDOvQZqZKJO7oBT38hw9CBuP_muHpVf1tiRLOY-fplvtiuP12PJ3GSGeq7_s-tTLKn2bp3TphfATlpFkQ5OMCDhOGxMRzFj33vQXusuzgO0_liuZxMVOTVZNwlShlyljK4uhP5GPUXYyzTDHRXBCEQ809CBeoRZiHzX71_IgtTs0cQY1x_w5jSHrIIZ_CNE8bsHqeW0N-ISWzS45DoUfgGMmzRQ9ikmo9apimAklP8r9pGwLWnvasRxTBACN_EsnrEtijqIdPCdg9xIVjPJjbulY0RW_AeQ3AbxAFye4QQZMJ1SkWPQe3Ee4iZgvTggmn2EEUM9ajA8BcEcxCMESVaPGEgQXALhiO46BUdpiY0akMd1uMm1QMnAlk9Cp6S9Bi27B7AUoDYXCuFNjgmJrQMXYU2Ge5hSrjuLrJBU8QEgYRzkXcXOso4Qlx3F7MetpigvUJvIMmGrpvUNnuU2yCHYxMj6AZ0W7fEzJ6g0By2LNADtRGIJIIi0Akzdc9BX9BTxi3dPZOAKaBywtAFgWgPqggOWkIMmmU2DB1aM0F52CZYtwc9QzYzQUlgfRBvcRDGGdF6EJa-zCh0GIMmgZxQPRDT1nq3wQaMUQtEgieB_jFMtCZsMDhClMFdDCPDpgkjoLYN3QZRHKRY0GsubGiNIov2bFB7L8ceZ1qZMCxCe1AQa_1r-EBnAQegXdHDAECwBTbBoKBWu2chkhsO_mI777AtMDBypjUPKOwBFSibMabBjU0b_lpCDxh6ynuCgbWYaeK8NybYA0yuB2MRIAE8AaCYhgUhFgwSSLCGobBgIMzU8AF1gLIBgKAm00JYgwEB0KgJg8Vgbp6rDyQLBhKY0H3nplYiBkgRGBiYU_sPvfopk6d-fZaYx0YG07iyGYdJuc-mb7N8Rv_y-sPgJv_wyyjLJumrly8fHx9fTGQ2in31Haq4F248fjkBJvAFz9OvQRg-12Jf9uF_J_cfzu5HP9wxP_929-Hy6tebMzr4EsXf-Z04_XytbNsfBWfJaDTuk4EI7sbiw4PzNLn78vvJr3di5N35Tnp5_R4_DN0P3z5JNTD7D-hk9ImY1jv_wvpmZ_GT-dm-fJ7dOO9u_ROHMTz9-Pzxt9tvRN7-esGf0wc8Mj-4Nw_9y8l18uXr2PqW_Po4iK4eHs4-DSeP93_cWFcX978Nye3Xx-w-Vc_fj8a_iU_47PSjf539fudcPkQevsHh5eVvH4OLNH34Pny8C2_O3o8-_p79OJd_8qfPvz6m7_78wm-_3McBT6ZX9-_7gzP0PfkYmL-r719u7tQ78-P_pI-Zf_359uKPT3jwzv7EwH1exN639F2WnHsPp5d3kerjt148uI7Pb34bJv2brP_9YoAu3o6yc8wvRP-jFSbJOxHyZPI54eG03_dt-WV0dfPI6R9_ZOcD8-TqYfjlw5fnJ3j6-SE4-_zFuof-5IZ8ObPk62LnMy3MWn7LPaa2u_Y-xwbkQWP9bbafAuxVrte6FEkC8LFFbHupHX8ehXRk0B_exZnKafXF2ZfXQ42P1EghMF2qcXryBLnGhQ6dS9lHGVo09VBlRXCs8rw5zpKp0tHQl9NQX_99KsNARzqzevWm2HqO4mQ8XykGURDpdJFbSLx7muhQ0b-5Ke70w6wUppubhb0ivJUdMgJvFvLKi_mOcn_R61MZumne7yBywymoNirLKuhNEOoNdL0g6s0GkoaxziOVnMSRgY6Xxc1b--U1dKpkvgxjR4Z4LkITlvlJvQuVO-XF4XQ8jkHZpxKsGEeXcahAL-VGPbKPay2gWgsaFQX7CUgoOZfbzpv9VmhRM5wVFjk27gtYvVWZ9CAPenkNOEtfakW_zBnhUyG83rNvFesuac6Np1GBkEiOy2ykEGGUMozVTrZo4OUmHc80JDZrKIdX0cp5mBfhMizKeJ1hpdurZw7YVqFb62kuw-gn46fDD79Q9ntIBCMdHob1Xm4_8guo7aD6Kar3rUdbchsl-9yv6U7_rKmMd5rKnfWsj8JAIj-rdHaccc1Suqq15DZK9oODqD9N5Bn8W6zI7oyds-ABwsuJrsAABFuPsmA35vydh2ltGuaVLpd2tl2du-toCq6fOwNgvA_az_1M_M8dGEy3rxGYZmc9tkva3pnORXQGycaIe-2qM5mOdh7eRRKnmRMG0dft3eaC9eXuOUj3Wf81yDKVOHGW_oy8oiZ-t7SirYfVvustiAOa_0yB2HG5XrOzBpqldPaANe6f6zuuVDhW2c_1HWcKKuNE7uF7VyV01-WM83AYOY2jh9jdDyFNMrqOqcr7c9FxEudT72eCo5bAggYPlMC-VXLXNEuzHj7HGsggzRvIkt3nQaOQruPKmY0Z978jwvSjYAxTb3aioDHGVC7qAc8WIXZU0FKLW2qo5DYWp9trQae87ZXSO2ODbzUHih2e3YG_KqQz8HNWI-f92X7FezJmRvo3rcAM5D2UE8NJkOi93i1XYOrMh0-W6vJ3y5YKGUZDJ1uUcHAAzxPzi9id7rPw0iJo-wKh4D9c6C-7WKw5zJuZHQjYebzr5W0_7EKA8RhkI6M415T-LHe199gbxWzpskrug9v5SkaeCxV8P8oCN5jsuzKyVlzXIX-IQqUL1IMPNj9hOJyEO1W_lcRrVUr3zAt4jZJ5JQKVHyFDyPc_ih0O_TF39DnFdTSZZrnAN8fjIHW_OFPf14-awWizJH-K7vzi4vz07vrjeXlYoMqSa-RLNB07-rmp4r_6ibWCcqjys4pGOnXS4uOb44-Besw7AjWbDPQDMm4chnKSqvk2fr6FUfY8BL410nKqq2D-3FmzrAVBu6Tz7yrJYLyfZOImgWrt1_z-hk4VDeqTGvpwRZs0fXaoXVDhiE4B_8WpjRZN5See2qXop9tah3M6D2uNvNfjiQxbWy7vbtBEpjexAK2BH7j6dMp6k-str4JqjV5cd5pI92mNvcvToe0y8sNYbQKKm-3MxYGqNu7y7hqt5oe5WrVa3G1nP1OubB17cbOdeX4QKI7ypzubpcyp1kh6V8YgmDT9INRxtNWyEGfnJO0C32cjlZRHc9okvQUfNSNZO3GSwJlm7dO4QrFGV3lN0KKhec7fyFo8jdEyBn1vjSeqnRBrUWiVpl1UcXK_1ZGtYy227lr1Vx4SXmOCslZpUX-lIGxWwuzRgJbxl7fXTJLc__Yf4sArFkZapssS2TqHEbtf9xeTH37fX8zyafj9JV5ADvG11d7l3Xb2D1mgE5cGKUX20kmInlT7SdBzaz8Jg-VEYsE7WJ9C5P4rX5Bz1VoHNqdZY99sGi12FvcSlXereSIshraVrMKVN450a4kFQMsnB9dhuCDZIAhi0dWabKebpPkjCldKhvr0dBzuJ3DlCcm9xhlnKVRFZ_os8J4D1UeJpxMQNuvZ-6Z0dWHSZamvX84KifzUrU7tyyPBwyzRJ4J_xPH4c17L6E_liSdSnnKCJO8sAFUnOURm7WjCP2Ynk1_nBVN55Kq62DlNVfHkdLEOkF-uHIbSpNWDUAMJae7TK2PQH5wf3Y5iFQXfjctYekd6Z0DpR2WMT6CHow9R8G2qjOuzVwYhDGHq-Myzle9LajFHIiGx4EQ50hHM5y78X5pIYiWl8m0sPVsQmziUmy4-yjuRj_mVwdhReXDrlWEelcfVXhknz-Gfo5xmoL69Mrh9BDl1CKWuvouOimI9NTwAooHNv-klwwRqWeWVBfwRr12cPSw2u4tp9a72jUZ-hlwVjsXQZUW9Ed7UyD_dRPqZ8v71TPchiw29hWgsDvfkZScUjQMZ3Ssj0X_1qxTYcWmDsjBtpcAbKchGCrqRYnbwP6_C6zDBDTD5FCvjfAwF-PjoJImjH8q400_-lPscR0UGo2HCy88noLLyUdcgVNp8FTTZrq1siWyPOgpx5nGEkMU8C7keRp5vctuxEADM80ygci3X95TjEkVcphyLqTqaSAuaBs8vq2jidTQ9I7Y23rjwRvmq9dEzhPW1YgRHzwReoUC8iggdlwyYKUaeDhmzhxGOBsrXpXpqYLSMQi2xWKco6lmVpKuI0s_d_VURtYaCt2OONGDubJp-NS4TmU7AMSWgwQF4piqMKNeosB1kMmUJjxPmcE9IxDwPC4cCyDzXY8JVpm-Di3J8KRQgzHWlwMJFS05JVMBCzSWw4AawYKKvXUcZJJ_BvfbbR8_4KmSeEVG9pv0OAI3khpZhaCyWXSunDiuYKElzTGiszZ9nrNH_34cIbYBIsRNh3KoI0rns6DTQq3QwtcbTUGVVqGDkIKqU6XCBObeZJbHrIU96LrOZchnxkQUxzcKSQUyzbWlKx3SYyRzbJhaExipUBF0LFaTNBTFfRffZKDfZmfqeKd1tuGtV7x4hUfMnuo6ZxZlnBFVxUxS5M4f7jDcB0mqMRxX3Qv4fuJc1FKIdXawBXZdJMNZnk6GoBIPf5yeU87Ny83iHMGqNdzWDQWgUR9V1irXxkSDsuy6ERQtbyKMIY5vYpuUzbvkupdISruUrSrALcRKSLup6lu9R13GFbwvJ6mgl7dnW80E1QlpVJJuzaNgCQFs0eDq66ukIzzHX5LX-g4DXBAneFJPkuDhXZUAa9Hg0hK9BpoziGNQiDeKoSxrEkQ1OydYJs86luUQm8Rhjvm9bljAdl5mug4hve9Il2CIK_hUmwT6hvu8ibzl-NZkZkqCNZqarcYzwaiJkoyZbb3I27C_vbJpQIRpQMZCTbArDvHuE6HM0zJ7uAxkZH4NUVc0NeS4jVHAHK88xOfex5_qIYshoJXchLEH2TF3kM4hJlkAckhfiAUQ8U2FhEbNubmth437FugzXw9GVTA1k9J2nNIUMo2ABk9trZjbjq9Zm5urMxvYGBCD7rzD1f1a-YjUA5S5OdK4HCkzcERgw9AIoovJjcouYYtKuMQWj7jFFCOUwy6fEJZD2EEiYTc-BvFk_BYktRRkAzYcizIGi3WMOFcSXHnIYtSybI5cto2_ubFg9pgzqNTxddjaklv-UMabufCyrIbeh7VjSnqZS2Jev0jDyrcC_vL-xG2AEsSf2jE-JnBydyCwLlXEjx6BAmcxRRDFpR1GxXwBENp59WYsdxpCywHkRKaQgJnGEY8M323N8DhEKQ5KshKQY8OUwz-Y-ZQoyElvqx3ntpXpdoNZ8ZLCak9hL-KE5XioJdeGtylHoNRxdJNaXego95Jl4SQfhaxVj88UgBYp5wfKLxgTmZ_FgLuTcjf4OatNkOsn-YlDbzachc21OdBPHE_BxE_ljpVZ3GeVQrDP4Y7u-pI5lC0UBSFRg7DgeFOjcUsgHSFEEyQ4jLrYt5pvYA3h59eAnWBUiKwWY1e4qnlFryf-QJvw8o3Rd7cUb0lzamO08o-j_Swzcre5CS4vSb_uX16d6IdpTUb7oWjzOlc_FfLfKiH0jG0GN78bhU1ZLsHxPedz1mcTCtKHih8SK2JQC3IQJ5ZIkpu0yBsEOKcc2GXFMJbgEQPpCckytOsbMqptqg5sJRaKMMsixCCQ70LW8o7OFwHyxr1hQXlqbnlNod3MgIDSqFzept693SvUhMvVfchKn_53qZba8kJmr-ExNQqUndVXBDvcopKlQgpqWY1oud2yfMcWkxT1sUgLZK7EhjyCSCIm4iXwf5q7HKEI2FKr1OEBEs4KxqCtYL7km-k1voLbyDU25V55Cdg0qyLVeXTgx8uMaQAyZb23iGt5Un-Eyih2tA82tRqWTJqXf6vecB1qlKpmpHRSQZD_qwIZ4Mo41qKqaNxEhSHpSIN9RyqIUeyaolwnhEVuCWSR1ddlgg1f1sM05Z8DiuZDQSeYjt6Z5jps1T5YqQ4zaNc8q9wqF5nYY6XVw8KNP8XQbde9VpyPa4kLAlU_jaWoMgxDmWl3LQ8gGJgGMprYvQRQikOpAqS2l6zCITg5FTNjERXrlhUvBTd-G8MW56wpGMBLcpSan0nOUtGtapmY3fOtFuYVjKPS82Eqg-JB63g_WrEnPnwJPAY4D92u6pOZhFvi-fryy5kJsZinhK2nZnqV8G5QLVYeNpOWAY-Ec-bbjcaVM0-XMsphQ4KHBaXtYucT06z66BccrNUce88t95xmSj1hN78UOjk4R802duX_-tyl3abXpw7vr3z-cHxWb7k86iujtWQe-Gb-qRxXWciso5hRziC0cgrmnhM1tqUyHudIUej_EoSZ1HNuSJnYs4rg-EkT4wjEJR8pFddjio4H0gimo7kYraskZ10qtWgp0XV5Ocy3O382ZFukPRMVAp1dasiH1WgkoJ_V1PezlOyGTSVjES70vKzMDm-bfyskaJMUrug6eajcaommB5yKehsYl1Ffq6HIk0wy6ev6kVi1hUvAbTElhQRqioPgBz-CYHoN4KADGOutlyOeE-A4CkwnJPIy192a-YIrQmiUs2rquY873qUfyQRkINVklL2pq-9l57Y2QIT0vD0T6CQedsJY7DjXafMmP1GgXSewSQ94JQIabnzPVjCchAFY7qKsgqz1H8J-75qtfF9N-kqL-JpkwzvI379w6HwY3-mxHcQB88VqY-Wt5Zp1pYzlRMKPry3P6XRQzfnMT_6zJZRlsexm4k4z81rUHApbeRFTIyqeEsXg30ayprsMYPsrJcj_4AfTBD6CPbWTka3rLAsgWAoothWUJaJsuNEBrJzU02YQdwCboADLolgpZkIu9MHmIOdpNRnHea3YirJBY5FgVGyC8EyDxnnAie46gYj1ENnWg2HvdB0TNc4pvLWHBwHcZdTU-oN1Gvc30K05DLBjornglB_Ch28hoHjrdE3MVzKONqtDLmFUOspXT3HqsCwa203xme-qmYh3EdptNeO_5uH-UpPsGarqLd28KE2Srnsyfaj-8k2OHCvzoMCPC-5po62RsQW_t5nj4YUbO9vaA24Aqd2DVgLObttEBXP_BJhU7jCH4nskP3duQ-6ZfVbuKPTRBDuUcDiZolzplwYK30MWCy94LlAfyiztPkj2hdLD4gA_gKQ4hAx1qQAdzW6uCihWo2RsJ8sd78hcSxJEf3K-8XkCvS-VLcfoNOcXTuE4ch0pGZSq3-kYCFanx03V6EuvXJM5eYXAbRJF0wyb6eRPnmvF0FIShfi58UzN1tvx58fzVnZ35ruSDqj_pu4nVSWTk5WuKI-XdxXnDWzSon_QfKH3aJXzadnzFI-ktfbwNpatGceippGqD8odYZu-EENXfx2uir_320IyLbGCar8_OXgAxY8SYog3tVX4geMbF1rNUf0lqzrJpWHBl-87plrbnytfOFwwWbSUfz3_tWP8-jEqUN8xfNaFfMTJUob8Qgtjm8W2rk7nVbvXDkHNbd2Ta2gIaWMvKtKq_fNtmgW26p_WwDX35e25xGOYr9tWJsp5xFsPnsKCi-quobVBfVsCmmVX_3bltUDh_dH8OIRPRdm2kwX0Qvvfzn9UCEOa_XzXnnD1mWoaH1y-Xf8j9fwHyaYJm")
-- print(foo)
-- getBuildXmlByXml(foo)