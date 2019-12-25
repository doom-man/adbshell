--[[
local __g = _G
-- export global variable
gv = {}
setmetatable(gv, {
    __newindex = function(_, name, value)
        rawset(__g, name, value)
    end,

__index = function(_, name)
        return rawget(__g, name)
    end
})
-- disable create unexpected global variable
setmetatable(__g, {
    __newindex = function(_, name, value)
        local msg = "USE 'gv.%s = value' INSTEAD OF SET GLOBAL VARIABLE"
        error(string.format(msg, name), 0)
    end
})
]]
local AppBase = class("AppBase")
function AppBase:ctor(configs)
    collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
    cc.Director:getInstance():setAnimationInterval(ANIMATIONINTERVAL)

    local frameSize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    me.fSize = frameSize
    local desSize = cc.size(DRS_WIDTH, DRS_HEIGHT)
    local fRate = frameSize.width / frameSize.height
    local dRate = desSize.width / desSize.height

    if fRate < dRate then
        cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(DRS_WIDTH,
        DRS_HEIGHT, cc.ResolutionPolicy.FIXED_WIDTH)

    else
        cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(DRS_WIDTH,
        DRS_HEIGHT, cc.ResolutionPolicy.FIXED_HEIGHT)
    end
    me.winSize = cc.Director:getInstance():getVisibleSize()
    print("w = " .. me.winSize.width, "h = " .. me.winSize.height)
    cc.Director:getInstance():setDisplayStats(CC_SHOW_FPS) 
    initTipsManager()
    self:onCreate()
end
function AppBase:onCreate()
end
function AppBase:runWithScene(scene_)
    cc.Director:getInstance():runWithScene(scene_)
end
function unLoadPackage()
    local unReloadModule = { ["common.string"] = 1, ["common.class"] = 1, ["common.event"] = 1, ["common.luadata"] = 1, ["libs.protobuf"] = 1, ["pb.protoList"] = 1 }
    for k, v in pairs(package.loaded) do
        local path = string.gsub(k, "%.", "/");
        print(">> " .. path)
        path = CCFileUtils:sharedFileUtils():fullPathForFilename(path .. ".lua");
        local file = io.open(path);
        if file and unReloadModule[k] == nil then
            file:close();
            local parent = require(k);
            if type(parent) == "table" then
                for k1, _ in pairs(parent) do
                    parent[k1] = nil;
                end
            end
            package.loaded[k] = nil;
            _G[k] = nil;
        end
    end
end
function luaReload(m)
   package.loaded[m] = nil;
   require_ (m)
end
return AppBase
