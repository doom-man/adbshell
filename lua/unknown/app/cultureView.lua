cultureView = class("cultureView", function(csb)
    return cc.CSLoader:createNode(csb)
end )
cultureView.__index = cultureView

-- 文明列表
local CultureList = {
    [1] = {name = "北欧文明", flag = "wmxz_1.png"},
    [2] = {name = "西欧文明", flag = "wmxz_2.png"},
    [3] = {name = "阿拉伯文明", flag = "wmxz_3.png"},
    [4] = {name = "亚洲文明", flag = "wmxz_4.png"},
    [5] = {name = "美洲文明", flag = "wmxz_5.png"},
}

function cultureView:create(csb)
    local layer = cultureView.new(csb)
    if layer then
        if layer:init() then
            layer:registerScriptHandler( function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                end
            end )
            return layer
        end
    end
    return nil
end
function cultureView:ctor()
    print("cultureView ctor")

    self.cList = nil
    self.curSelect = me.getRandom(5)
    print(self.curSelect )
    self.startTime = -1
end
local coords = {
[1] = cc.p(-52,-84),
[2] = cc.p(-30,-90),
[3] = cc.p(-34,-99),
[4] = cc.p(-30,-82),
[5] = cc.p(-46,-72),
}
function cultureView:init()
    print("cultureView init")

    self:loadRaceInfoData()

    local fixLayout = me.assignWidget(self, "fixLayout")
    self.img_flag = me.assignWidget(self, "img_flag")
    self.text_name = me.assignWidget(self, "text_name")
    self.descTxt = me.assignWidget(self, "descTxt")
    --self.descTxt:getVirtualRenderer():setLineHeight(50)

    self.arrowAnim = me.assignWidget(self, "arrowAnim")
    local action = cc.CSLoader:createTimeline("selectculture/arrowAnim.csb")
    self.arrowAnim:runAction(action)
    action:gotoFrameAndPlay(0, true)
   
    --[[
   self.msgEvent = me.RegistCustomEvent(USER_EVT_WEBSOCKET_MESSAGE,function(event)
        local msg = me.cjson.decode(event._userData)
        print("-----cultureView-msg-------"..msg.t)
        me.LogTable(msg)
        if checkMsg(msg.t,260) then --进入游戏
            mainCity = cityView:create("cityScene.csb")
            me.runScene(mainCity)
        end
    end)
    ]]
    self.msgkey = NetMan:registMsgLisener( function(msg)
        if checkMsg(msg.t, 260) then
            TalkingData_onCreateRole(msg.c.value)
            -- 进入游戏
       --     mainCity = cityView:create("cityScene.csb")
       --     me.runScene(mainCity)
      --      NetMan:send(_MSG.loadDataMsg(0))  
           user.countryId = msg.c.value  
           local load_ = loadingLayer:create("loadScene.csb",true)
           me.runScene(load_)
        end
    end )
    local function cultureSelect_callback(node, event)
        if event ~= ccui.TouchEventType.ended then return end
        print("------selectCountryMsg-------" .. node:getTag())

        if self.curSelect ~= node:getTag() then
            self:unSelectCulture(self.curSelect)
            self:stopCountryMusic()
            self.curSelect = node:getTag()
            self:selectCulture(self.curSelect)
            self:setCountryData(self.curSelect)
        end
    end
    -- 注册点击事件
    me.registGuiClickEventByName(self, "enterGame", function(node)
        me.setWidgetCanTouchDelay(node)
        local msg = _MSG.selectCountryMsg(self.curSelect)
        NetMan:send(msg)
    end )

    for var = 1, 5 do
        local node =  me.assignWidget(fixLayout, "c" .. var)
        me.registGuiTouchEventByName(node, "c", cultureSelect_callback, var)
        me.registGuiTouchEventByName(node, "c13", cultureSelect_callback, var)  
        local spine_jz = sp.SkeletonAnimation:create("animation/ui_anim_wenmxuanze_0"..(var+1) .. "_jianzhu.json", "animation/ui_anim_wenmxuanze_0"..(var+1) .. "_jianzhu.atlas", 1)  
        spine_jz:setPosition(coords[var])
        spine_jz:setAnimation(0, "animation", true)   
        node:addChild(spine_jz,-1)
        if self.curSelect == node:getTag() then
            self:selectCulture(var)
            self:setCountryData(var)
        end
    end

    local spine_bg = sp.SkeletonAnimation:create("animation/ui_anim_wenmxuanze_01_bj.json", "animation/ui_anim_wenmxuanze_01_bj.atlas", 1)  
    spine_bg:setPosition(me.winSize.width / 2, me.winSize.height/2)
    spine_bg:setAnimation(0, "animation", true)   
    me.assignWidget(self,"fixLayout"):addChild(spine_bg,-1)
    mAudioMusic:setBackMusic(MUSIC_TYPE.MUSIC_BACK_MAP, true)

    return true
end

function cultureView:selectCulture(var)
    local node =  me.assignWidget(self, "c" .. var)
    me.assignWidget(node, "c0"):setVisible(true)
    self.img_flag:loadTexture(CultureList[var].flag, me.localType)
    print(CultureList[var].flag, "aaa")
    self.text_name:setString(CultureList[var].name)
    local p = cc.p(me.assignWidget(node, "pos"):getPosition())
    local p1 = node:convertToWorldSpace(p)
    self.arrowAnim:setPosition(p1)
end

function cultureView:unSelectCulture(var)
    local node =  me.assignWidget(self, "c" .. var)
    me.assignWidget(node, "c0"):setVisible(false)
end

function cultureView:loadRaceInfoData()
    initCfg(CfgType.COUNTRY, "country.json")
    initCfg(CfgType.BUILDING, "building.json") 

end

function cultureView:playCountryMusic(pCountry)
    if pCountry == 1 then  -- 北欧
       mAudioMusic:setPlayEffect(MUSIC_TYPE.MUSIC_EFFECT_N_EUROPE,false)
    elseif pCountry ==2 then  -- 西欧
       mAudioMusic:setPlayEffect(MUSIC_TYPE.MUSIC_EFFECT_W_EUROPE,false)
    elseif pCountry == 3 then  -- 阿拉伯
       mAudioMusic:setPlayEffect(MUSIC_TYPE.MUSIC_EFFECT_ARAB,false)
    elseif pCountry == 4 then -- 亚洲
       mAudioMusic:setPlayEffect(MUSIC_TYPE.MUSIC_EFFECT_ASIAN,false)
    elseif pCountry == 5 then -- 美洲
       mAudioMusic:setPlayEffect(MUSIC_TYPE.MUSIC_EFFECT_AMERICA,false)
    end
end

function cultureView:stopCountryMusic()
    if self.curSelect == 1 then  -- 北欧
       mAudioMusic:stopPalyEffect(MUSIC_TYPE.MUSIC_EFFECT_N_EUROPE)
    elseif self.curSelect ==2 then  -- 西欧
       mAudioMusic:stopPalyEffect(MUSIC_TYPE.MUSIC_EFFECT_W_EUROPE)
    elseif self.curSelect == 3 then  -- 阿拉伯
       mAudioMusic:stopPalyEffect(MUSIC_TYPE.MUSIC_EFFECT_ARAB)
    elseif self.curSelect == 4 then -- 亚洲
       mAudioMusic:stopPalyEffect(MUSIC_TYPE.MUSIC_EFFECT_ASIAN)
    elseif self.curSelect == 5 then -- 美洲
       mAudioMusic:stopPalyEffect(MUSIC_TYPE.MUSIC_EFFECT_AMERICA)
    end

end

function cultureView:setCountryData(CountryId)
    self:playCountryMusic(CountryId)
    
    local pCountryIntroduction = cfg[CfgType.COUNTRY][CountryId]["desces"]
    -- 文明的描述
    local strTbl = {}
    for key, var in pairs(pCountryIntroduction) do
        local pData = pCountryIntroduction[key]
        table.insert(strTbl, pData)
    end
    local str = table.concat(strTbl, "   ")
    self.descTxt:setString(str)
    --[[
    local len = getStringCnLength(str)
    if len>110 then
        self.descTxt:setString(utf8sub(str,1,45).."\n\n".. utf8sub(str,46,len))
    else
        self.descTxt:setString(str)
    end
    ]]
end
function cultureView:playCG()
    local function removeVideo()
        me.assignWidget(self, "fixLayout"):setVisible(true)
        me.assignWidget(self, "videoLayer"):setVisible(false)
        self:checkWhite()
        self.video:runAction(cc.Sequence:create(cc.CallFunc:create( function() end), cc.RemoveSelf:create()))
    end

    me.registGuiClickEventByName(self, "Button_skipCG", function(node)
        if self.video then
            removeVideo()
        end
    end )

    cc.UserDefault:getInstance():setStringForKey("isPlayCG", 1)
    cc.UserDefault:getInstance():flush()
    me.assignWidget(self, "fixLayout"):setVisible(false)
    me.assignWidget(self, "videoLayer"):setVisible(true)

    self.video = require("app.VideoLayer").create("startCG.mp4", removeVideo)
    self:addChild(self.video)
end

function cultureView:onEnter()
    print("cultureView onEnter")
    me.doLayout(self, me.winSize)
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if targetPlatform == cc.PLATFORM_OS_ANDROID then
        cc.Director:getInstance():setClearColor(cc.c4f(0, 0, 0, 0))     
        self:playCG()    
    end
end
function cultureView:initInfo(cid)

end
function cultureView:initCountryList(cid)
    local data = countyObj_objs[me.toStr(cid)]
    me.LogTable(data)
    if data then
        self.cList = mListMenu:createListMenu()
        self.cList:setContentSize(cc.size(me.winSize.width * 0.9, 500))
        for key, var in pairs(data) do
            self.cList:addMenuItem(self:createMiracleById(var.id))
        end
        self.cCountryNode:addChild(self.cList)
        self.cList:setPosition(me.winSize.width / 2, me.winSize.height / 2 - 50)
    end
end


function cultureView:createMiracleById(cid)
    local img = ccui.ImageView:create("culture_miracle_" .. cid .. ".png", me.localType)
    img:setScale(0.7)
    return img
end
function cultureView:onExit()
    print("cultureView onExit")
    -- me.RemoveCustomEvent(self.msgEvent)
    
    self:stopCountryMusic()
    mAudioMusic:stopBackMusic(false)

    NetMan:removeMsgLisener(self.msgkey)
end

