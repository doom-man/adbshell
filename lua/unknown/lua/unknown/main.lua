require("socket")
package.path = package.path .. ";src/?.lua"
local targetPlatform = cc.Application:getInstance():getTargetPlatform()
function print(...)
        release_print(...)

end
-- 测试一下合并
require_ = function(...)
    print(...)
    require(...)
end
collectgarbage_ = function(...)
    print("垃圾回收---------")
    collectgarbage(...)
end
super = function(s, ...)
    s.super.ctor(s, ...)
end
superfunc = function(s, f, ...)
    s.super[tostring(f)](s, ...)
end
-- 缓存动画数据
createArmature = function(aname)
    print("aname = " .. aname)
    if aniCache == nil then
        aniCache = { }
    end
    if aniCache[aname] == nil then
        me.mAddArmatureFileInfo(aname .. ".ExportJson")
    end
    aniCache[aname] = true
    return ccs.Armature:create(aname)
end
cc.FileUtils:getInstance():setPopupNotify(false)
-- 更新文件存储路径
pathToSave = cc.FileUtils:getInstance():getWritablePath() .. "emp_update"
cc.FileUtils:getInstance():addSearchPath("src")
cc.FileUtils:getInstance():addSearchPath("res")
require "cocos.init"
require_ "Resources"
require_ "config"
-- 是否开启在线更新
OPEN_ONLINE_UPDATE = false
-- 优先搜索更新目录
if (cc.PLATFORM_OS_ANDROID == targetPlatform) or(cc.PLATFORM_OS_IPAD == targetPlatform)
    -- or(cc.PLATFORM_OS_ANDROID == targetPlatform)
    --or (cc.PLATFORM_OS_WINDOWS == targetPlatform)
then
    OPEN_ONLINE_UPDATE = true
    addSearchPath(pathToSave, true)
    addSearchPath(pathToSave .. "/src", true)
    addSearchPath(pathToSave .. "/res", true)
    for var = 1,#RES_SEARCH_PATH do
        addSearchPath(pathToSave .. "/" .. RES_SEARCH_PATH[var], true)
    end
end
for var = 1,#RES_SEARCH_PATH do
    cc.FileUtils:getInstance():addSearchPath(RES_SEARCH_PATH[var])
end
require_ "verConfig"
require_ "packages/mKit"
require_ "packages/tipsMgr"
require_ "app/updateLayer"
require_ "app/waitLayer"
-- require_ ""
app = nil
lines = "----------------The early bird catches the worm---------------------"
function __G__TRACKBACK__(msg)
    local message = msg
    local msg = debug.traceback(msg, 3)
    print(msg)
    if isWindowsPlatform() then
        showErrorMsg(msg, -1)
    end
    return msg
end
local function main()
    app = require("packages.AppBase"):create()
    cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_PVRTC4)
    if OPEN_ONLINE_UPDATE then
        local layer = updateLayer:create("updateLayer.csb")
        local s = cc.Scene:create()
        s:addChild(layer)
        app:runWithScene(s)
    else
        luaReload("requireList")
        local m = loginView:create("loginScene.csb")
        local s = cc.Scene:create()
        s:addChild(m)
        app:runWithScene(s)
    end
end
local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
function applicationDidEnterBackground()
    print("EnterBackground")
end
function applicationWillEnterForeground()
    print("EnterForeground")

end