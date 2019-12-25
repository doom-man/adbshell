-- 加载场景
loadingLayer = class("loadingLayer", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
loadingLayer.__index = loadingLayer
function loadingLayer:create(csb, state)
    local layer = loadingLayer.new(csb)
    loadingLayer.fisrtInCity = state
    if layer then
        if layer:init() then
            layer:registerScriptHandler( function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                elseif "enterTransitionFinish" == tag then
                    layer:onEnterTransitionDidFinish()
                end
            end )
            return layer
        end
    end
    return nil
end
function loadingLayer:ctor()
    print("loadingLayer ctor")
end
function loadingLayer:init()
    print("loadingLayer init")
    self.loadingbar = me.assignWidget(self, "LoadingBar")
    self.info = me.assignWidget(self, "info")
    self.loadQue = Queue.new()
    CUR_GAME_STATE = GAME_STATE_LOADING_CITY
    return true
end
function loadingLayer:initCloud()
    me.assignWidget(self, "bg"):setVisible(false)
    me.assignWidget(self, "Image_1"):setVisible(false)
    self.info:setVisible(false)
    self.info:setString("0%")
    me.assignWidget(self, "cloud_left"):setVisible(true)
    me.assignWidget(self, "cloud_right"):setVisible(true)
end
function loadingLayer:releaseRes()
    if loadingLayer.fisrtInCity then
        if aniCache then
           for key, var in pairs(aniCache) do
              print("release "..key)
              ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(key .. ".ExportJson")
           end           
        end
        aniCache = nil 
        cc.TextureCache:getInstance():removeAllTextures()            
        cc.Director:getInstance():purgeCachedData()
        collectgarbage_("collect")
    else
        me.removeImage("tiled.png")
        me.removeImage("netbattlemap.png")
    end
end
RES_TYPE_FUNC = 1
RES_TYPE_MUSIC = 2
RES_TYPE_VOC = 3
RES_TYPE_IMG = 4
RES_TYPE_IMG_PLIST = 5
RES_TYPE_ANI = 6
RES_TYPE_FUNC_ARGS = 7

function loadingLayer:initLoad()
    Queue.clear(self.loadQue)
    if loadingLayer.fisrtInCity  then
        local plists = self:fixPlistImg(RES_IMG_PLIST)
        self:prepareLoad(plists, RES_TYPE_IMG_PLIST)
        plists = self:fixPlistImg(RES_UIRES_PLIST)
        self:prepareLoad(plists, RES_TYPE_IMG_PLIST)
        --self:prepareLoad(RES_IMG_PLIST, RES_TYPE_IMG_PLIST)   
        self:prepareLoad(RES_MUSIC, RES_TYPE_MUSIC)
        self:prepareLoad(RES_VOC, RES_TYPE_VOC)
        self:loadConfig()
        self:setSingleSeasonMapImg()
        -- self:prepareLoad(RES_IMG, RES_TYPE_IMG)
        -- self:prepareLoad(RES_UIRES_IMG, RES_TYPE_IMG)
        local mbox_pngs = {
        "titlewordRedBg.png",
        "btn_jijie.png",
        "btn_yuanzhu.png",
        }
        self:prepareLoad(mbox_pngs, RES_TYPE_IMG)
    end   
    local Anicfg = {
        "keji_jiesuo.ExportJson",
        "nongminAni.ExportJson",
        "yang_3634.ExportJson",
        "ying_fx.ExportJson",
        "ying_fxy.ExportJson",
        "i_button_activit_1.ExportJson",
        "fire.ExportJson"
        -- "battle_fight.ExportJson",
    }
    self:prepareLoad(Anicfg, RES_TYPE_ANI)
    if loadingLayer.fisrtInCity  then
        local size = Queue.count(self.loadQue)
        local n = table.nums(CfgFileList)
        n = math.ceil(n/size)
        local count=0
        local index=1
        for key, var in me.pairs(CfgFileList) do
            local res = {k=RES_TYPE_FUNC_ARGS, func=initCfg, args1=key, args2=var}
            self.loadQue = Queue.insert(self.loadQue, index, res)
            count=count+1
            if count>=n then
                count=0
                index=index+2
                local ss = Queue.count(self.loadQue)
                if index>=ss then
                    index=ss
                end
            end
        end
    end
end
function loadingLayer:loadConfig()
    self:prepareLoad(load_cfg_path, RES_TYPE_FUNC)
    self:prepareLoad(load_cfg_buildingInfoTitle, RES_TYPE_FUNC)
    self:prepareLoad(load_cfg_lordInfo, RES_TYPE_FUNC)
    self:prepareLoad(load_cfg_noticeInfo, RES_TYPE_FUNC)
    self:prepareLoad(load_cfg_sysNotice, RES_TYPE_FUNC)
    self:prepareLoad(load_cfg_unionLog, RES_TYPE_FUNC)
    self:prepareLoad(load_cfg_buildingTips, RES_TYPE_FUNC)
    self:prepareLoad(load_cfg_mapEventData, RES_TYPE_FUNC)
    self:prepareLoad(load_cfg_chatNotice,RES_TYPE_FUNC)
    self:prepareLoad(load_cfg, RES_TYPE_FUNC)
end
function loadingLayer:prepareLoad(tab, k)

    if type(tab) == "function" then
        local res = { }
        res.v = tab
        res.k = k
        Queue.push(self.loadQue, res)
    elseif type(tab) == "table" then
        for key, var in pairs(tab) do
            local res = { }
            res.v = var
            res.k = k
            Queue.push(self.loadQue, res)

        end
    elseif type(tab) == "string" then
        local res = { }
        res.v = tab
        res.k = k
        Queue.push(self.loadQue, res)
    end

end

function loadingLayer:doLoad()
    local size_ = Queue.count(self.loadQue)
    print("loadingLayer =" .. size_)
    local p_ = 0
    local function checkComplete()
        p_ = p_ + 1
        local pencent = p_ * 100 / size_
        if self.loadingbar then
            self.loadingbar:setPercent(pencent)
        end
        if self.info then
            self.info:setString(math.floor(pencent) .. "%")
        end
        if p_ == size_ then
            me.DelayRun( function()
                self:loadComplete()
            end )
        end
    end
    local function load_()
        while Queue.isEmpty(self.loadQue) == false do
            local res = Queue.pop(self.loadQue)
            local k = res.k
            local v = res.v
            if k == RES_TYPE_FUNC then
                print(k)
                v()
                checkComplete()
            elseif k == RES_TYPE_MUSIC then
                AudioEngine.preloadMusic(v)
                checkComplete()
            elseif k == RES_TYPE_FUNC_ARGS then
                res.func(res.args1, res.args2)
                checkComplete()
            elseif k == RES_TYPE_VOC then
                AudioEngine.preloadMusic(v)
                checkComplete()
            elseif k == RES_TYPE_IMG then
                me.addImageAsync(v, function(args)
                    checkComplete()
                end )
            elseif k == RES_TYPE_IMG_PLIST then
                print("loading " .. v)
                me.addSpriteWithFileSync(v, function(args)
                    print("---------------" .. args)
                    checkComplete()
                end )
            elseif k == RES_TYPE_ANI then
                if aniCache == nil then
                    aniCache = { }
                end
                aniCache[v] = true
                me.mAddArmatureFileInfoAsync(v, function(x)
                    checkComplete()
                end )
            else              
                error("not found res type")
            end
            coroutine.yield()
        end
    end
    self.cthread = coroutine.create( function()
        load_()
    end )
    self.schid = me.coroStart(self.cthread)
end
function loadingLayer:fixPlistImg(tbl)
    local p = { }
    for key, var in pairs(tbl) do
        local str = var
        local _, _, name = string.find(str, "(.+).plist")
        local _, _, id = string.find(name, "build_c(%d+)")
        if id then
            if me.toNum(id) == me.toNum(user.countryId) then
                table.insert(p, name)
            end
        else
            table.insert(p, name)
        end
    end
    return p
end
function loadingLayer:setSingleSeasonMapImg()
    for i = #RES_IMG, 1, -1 do
        local _, _, id = string.find(RES_IMG[i], "neicheng_(%d+)")
        if id then
            if me.toNum(id) ~= seasonId then
                table.remove(RES_IMG, i)
            end
        end
    end
end
function loadingLayer:loadComplete()
    print("loadingLayer:loadComplete")
     NetMan:send(_MSG.pingMsg())
    if NetMan.bShowNetInterrupt == false then
        cc.Director:getInstance():getTextureCache():dumpCachedTextureInfo()
        mainCity = cityView:create("cityScene.csb", not loadingLayer.fisrtInCity)
        me.runScene(mainCity)
        if loadingLayer.fisrtInCity then
            self:initFortData()      
            NetMan:send(_MSG.loadDataMsg(0))
            --NetMan:send(_MSG.getChatRecord())
            --NetMan:send(_MSG.Rune_info())
            --NetMan:send(_MSG.Rune_backpack())
            --  NetMan:send(_MSG.ship_expedition_init())
            -- NetMan:send(_MSG.warShip_init())
            --  NetMan:send(_MSG.fortressInit()) --获取要塞信息        
        else
            NetMan:send(_MSG.loadDateLineDataMsg())
        end
    end
end
function loadingLayer:initFortData()
    local data = GFortData()
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
function loadingLayer:onEnter()
    print("loadingLayer onEnter")
    me.doLayout(self, me.winSize)
    enterLoadtingTime = me.sysTime()
    self.sk = sp.SkeletonAnimation:create("animation/diguo.json", "animation/diguo.atlas", 0.26)
    me.assignWidget(self, "spineNode"):addChild(self.sk)
    self.sk:setPosition(me.winSize.width / 2, -100)
    self.sk:setAnimation(0, "animation", true)   
    if not loadingLayer.fisrtInCity then
        self:initCloud()
    end
end
function loadingLayer:onExit()
    print("loadingLayer onExit")
    me.coroClear(self.schid)
end
function loadingLayer:onEnterTransitionDidFinish()
    print("loadingLayer onEnterTransitionDidFinish")
    self:releaseRes()
    seasonId = me.getRandom(4)
    self:initLoad()
    self:doLoad()
end


