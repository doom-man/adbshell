-- 加载场景
loadWorldMap = class("loadWorldMap",loadingLayer)
loadWorldMap.__index = loadWorldMap
function loadWorldMap:create(...)
    local layer = loadWorldMap.new(...)
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
function loadWorldMap:ctor()
    print("loadWorldMap ctor")
    self.m_WarningPoint = nil
end


--[Comment]
--var首字母大写
function loadWorldMap:getWarningPoint()
	return self.m_WarningPoint
end
function loadWorldMap:setWarningPoint(m_WarningPoint_)
	self.m_WarningPoint = m_WarningPoint_
end

---
-- 设置打开世界地图默认操作
--
function loadWorldMap:setOpenOpt(cate)
	self.optCate = cate
end

function loadWorldMap:init()
    print("loadWorldMap init")
    superfunc(self,"init")
    self:initCloud()
    CUR_GAME_STATE = GAME_STATE_LOADING_WORLD
    return true
end
function loadWorldMap:releaseRes()
    if aniCache then
        for key, var in pairs(aniCache) do
            print("release "..key)
            ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(key..".ExportJson")
        end     
        aniCache = nil     
    end
    --军队数据重置
    gameMap.troopData = {}
    collectgarbage_("collect")
end
function loadWorldMap:initLoad()  
    mainCity = nil

    Queue.clear(self.loadQue)
    local imgs ={
        "tiled.png",
    }
    self:prepareLoad(imgs, RES_TYPE_IMG) 
    local res_anis = {
        "bing_4101.ExportJson",
        "battle_fight.ExportJson",
        "qizi_1.ExportJson",
        "flag.ExportJson",
        "bing_maoyi.ExportJson",
        "bing_daoju.ExportJson",
        "bing_1201.ExportJson",
        "circle_ani.ExportJson",
        "keji_jiesuo.ExportJson",
        "nongminAni.ExportJson",
        "yang_3634.ExportJson",
        "ying_fx.ExportJson",
        "ying_fxy.ExportJson",
        "i_button_activit_1.ExportJson",
        "task_ani_1.ExportJson",
        "protect.ExportJson",
        "ani_jingxi.ExportJson",
        "fire.ExportJson",
        "bing_qizi.ExportJson",
        "shenjiang_texiao_jihuo.ExportJson",
    }  
    self:prepareLoad(res_anis, RES_TYPE_ANI)   
end
function loadWorldMap:loadComplete()
    print("loadWorldMap:loadComplete")
    if NetMan.bShowNetInterrupt == false then
        cc.Director:getInstance():getTextureCache():dumpCachedTextureInfo()   
        CUR_GAME_STATE = GAME_STATE_WORLDMAP
        pWorldMap = WorldMapView:create("cityScene.csb")    
        pWorldMap:setWarningPoint(self:getWarningPoint())
        pWorldMap:setOpenOpt(self.optCate)
        me.runScene(pWorldMap)
    end
end
function loadWorldMap:onEnter()
    print("loadWorldMap onEnter")
    me.doLayout(self, me.winSize)
    --youwenti zaishuo
 --     NetMan:send(_MSG.worldMapView(user.majorCityCrood.x,user.majorCityCrood.y,0))
 --   self.modelkey = UserModel:registerLisener( function(msg)
 --   if checkMsg(msg.t,MsgCode.WORLD_MAP_VIEW) then            
          self:releaseRes()
          self:initLoad()
          self:doLoad()
   --    end
   -- end )
end
function loadWorldMap:onExit()
    print("loadWorldMap onExit")
    UserModel:removeLisener(self.modelkey)
end
function loadWorldMap:onEnterTransitionDidFinish()
    print("loadWorldMap onEnterTransitionDidFinish")    
end

