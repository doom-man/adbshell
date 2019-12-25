-- 加载场景
loadBackMenu = class("loadBackMenu",loadingLayer)
loadBackMenu.__index = loadBackMenu
function loadBackMenu:create(...)
    local layer = loadBackMenu.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler( function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                elseif "enterTransitionFinish"  ==  tag  then
                    layer:onEnterTransitionDidFinish()
                end
            end )
            return layer
        end
    end
    return nil
end
function loadBackMenu:ctor()
    print("loadBackMenu ctor")
 
end

function loadBackMenu:init()
    print("loadBackMenu init")
    superfunc(self,"init")
    self:initCloud()
    CUR_GAME_STATE = GAME_STATE_LOADING_MENU
    return true
end
function loadBackMenu:releaseRes()
    if aniCache then
    for key, var in pairs(aniCache) do
        print("release "..key)
        ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(key..".ExportJson")
    end     
    aniCache = nil     
    end
    cc.Director:getInstance():purgeCachedData()
    cc.TextureCache:getInstance():removeAllTextures()            
    collectgarbage_("collect")
    user.Cross_Sever_Status = mCross_Sever_Out
    First_City = false
    NewnetWork = 1
end
function loadBackMenu:initLoad()  
    Queue.clear(self.loadQue)   
    self:prepareLoad(load_empty, RES_TYPE_FUNC)  
end
function loadBackMenu:loadComplete()
    print("loadBackMenu:loadComplete")   
    self.detimer =  me.registTimer(1,function(dt,b)
        if b then
             me.clearTimer(self.detimer)   
             UserModel:goLogon()  
        end
    end)    
end
function loadBackMenu:onEnter()
    print("loadBackMenu onEnter")
    me.doLayout(self, me.winSize) 
    self:releaseRes()
    self:initLoad()
    self:doLoad() 
end
function loadBackMenu:onExit()
    print("loadBackMenu onExit")
    
end
function loadBackMenu:onEnterTransitionDidFinish()
    print("loadBackMenu onEnterTransitionDidFinish")    
end

