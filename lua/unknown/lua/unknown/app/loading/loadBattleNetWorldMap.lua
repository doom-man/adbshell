-- 加载场景
loadBattleNetWorldMap = class("loadBattleNetWorldMap",loadingLayer)
loadBattleNetWorldMap.__index = loadBattleNetWorldMap
function loadBattleNetWorldMap:create(...)
    local layer = loadBattleNetWorldMap.new(...)
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
function loadBattleNetWorldMap:ctor()
    print("loadBattleNetWorldMap ctor")
    self.m_WarningPoint = nil
end


--[Comment]
--var首字母大写
function loadBattleNetWorldMap:getWarningPoint()
	return self.m_WarningPoint
end
function loadBattleNetWorldMap:setWarningPoint(m_WarningPoint_)
	self.m_WarningPoint = m_WarningPoint_
end

function loadBattleNetWorldMap:init()
    print("loadBattleNetWorldMap init")
    superfunc(self,"init")
    self:initCloud()
    CUR_GAME_STATE = GAME_STATE_LOADING_WORLD
    return true
end
function loadBattleNetWorldMap:releaseRes()
    if aniCache then
    for key, var in pairs(aniCache) do
        print("release "..key)
        ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(key..".ExportJson")
    end     
    aniCache = nil     
    end
    --军队数据重置
    gameMap.troopData = {}
    me.tableClear(user.mailList) -- 邮件清除
    gameMap.bastionData = {} -- 据点重置

    collectgarbage_("collect")
end
function loadBattleNetWorldMap:initFortData()
    local data = cfg[CfgType.NETBATTLE_FORTDATA]
    me.tableClear(gameMap.fortDatas)
    gameMap.fortDatas = {}
    for key, var in pairs(data) do
        gameMap.fortDatas[var.id] = fortData.new(var.id)
        -- 存储加成描述
        local tb = me.split(var.ext, ",")
        local tbD = me.split(var.desc, "|")
        for key, var in pairs(tb) do       
            local tbDe = tbD[key]      
            local tbExt = me.split(var, ":")
            local tbDesc = me.split(tbDe, ":")
            if not gameMap.fortDesc[tbExt[1]] then
                gameMap.fortDesc[tbExt[1]] = { }
                gameMap.fortDesc[tbExt[1]].value = 0
                gameMap.fortDesc[tbExt[1]].text = tbDesc[2] .. ":+"
            end
         end
    end
end
function loadBattleNetWorldMap:initLoad()  
    mainCity = nil

    Queue.clear(self.loadQue)
    local imgs ={
        "netbattlemap.png",
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
    local function loadFortdata()
      self:initFortData()
    end
    self:prepareLoad(res_anis, RES_TYPE_ANI)   
    self:prepareLoad(loadFortdata,RES_TYPE_FUNC)
    self:prepareLoad(load_cfg_mapBattleNetEventData, RES_TYPE_FUNC)
end
function loadBattleNetWorldMap:loadComplete()
    print("loadBattleNetWorldMap:loadComplete")
    cc.Director:getInstance():getTextureCache():dumpCachedTextureInfo() 
    if netBattleMan then
        netBattleMan:send(_MSG.NetBattleEnterMsg())
    end   
    netBattleLookAt = self.m_WarningPoint
    CUR_GAME_STATE = GAME_STATE_WORLDMAP_NETBATTLE    
end
function loadBattleNetWorldMap:onEnter()
    print("loadBattleNetWorldMap onEnter")
    me.doLayout(self, me.winSize)
    --youwenti zaishuo
 --   netBattleMan:send(_MSG.worldMapView(user.majorCityCrood.x,user.majorCityCrood.y,0))
 --   self.modelkey = UserModel:registerLisener( function(msg)
 --   if checkMsg(msg.t,MsgCode.WORLD_MAP_VIEW) then            
          self:releaseRes()
          self:initLoad()
          self:doLoad()
   --    end
   -- end )
end
function loadBattleNetWorldMap:onExit()
    print("loadBattleNetWorldMap onExit")
    UserModel:removeLisener(self.modelkey)
end
function loadBattleNetWorldMap:onEnterTransitionDidFinish()
    print("loadBattleNetWorldMap onEnterTransitionDidFinish")    
end

