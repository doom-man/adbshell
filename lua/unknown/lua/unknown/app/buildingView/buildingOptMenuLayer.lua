buildingOptMenuLayer = class("buildingOptMenuLayer",function (csb)
     return cc.CSLoader:createNode(csb)
end)
buildingOptMenuLayer.__index = buildingOptMenuLayer
function buildingOptMenuLayer:create(csb)
    local layer = buildingOptMenuLayer.new(csb)
    if layer then 
        if layer:init() then 
            layer:registerScriptHandler(function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                end
            end)            
            return layer
        end
    end
    return nil 
end

buildingOptMenuLayer.BTN_INFO = "info"
buildingOptMenuLayer.BTN_UPGRADE = "upgrade"
buildingOptMenuLayer.BTN_DEFENSE = "defense"
buildingOptMenuLayer.BTN_BUILD  = "build"
buildingOptMenuLayer.BTN_SPY = "spy" --delete
buildingOptMenuLayer.BTN_TRAIN = "train"
buildingOptMenuLayer.BTN_STUDY = "study"
buildingOptMenuLayer.BTN_TREAT = "treat"
buildingOptMenuLayer.BTN_COLLECT = "collect"
buildingOptMenuLayer.BTN_LOG = "log" --瞭望塔日志
buildingOptMenuLayer.BTN_CHANGE = "change"
buildingOptMenuLayer.BTN_GAHTER = "gather"  --采集食物
buildingOptMenuLayer.BTN_MINING = "mining"  --挖矿
buildingOptMenuLayer.BTN_STOP = "stop" --delete
buildingOptMenuLayer.BTN_FASTER = "faster"  --加速
buildingOptMenuLayer.BTN_FASTER_ITEM = "faster_item"  --道具加速
buildingOptMenuLayer.BTN_FARMER = "farmer"  --生产农民
buildingOptMenuLayer.BTN_INBUILDING = "inbuilding" --入驻
buildingOptMenuLayer.BTN_HORSE = "horse" --市场礼包
buildingOptMenuLayer.BTN_TAX = "tax" --征税
buildingOptMenuLayer.BTN_ALLIANCESHOP = "shop" --联盟商店
buildingOptMenuLayer.BTN_GUARD = "guard" --坚守
buildingOptMenuLayer.BTN_WAR = "war" --联盟战争
buildingOptMenuLayer.BTN_BOAT = "boat" --跨服海战
buildingOptMenuLayer.BTN_SAILING = "sail" --航海
buildingOptMenuLayer.BTN_ALTAR = "altar" -- 特性研究 
buildingOptMenuLayer.BTN_RELIC = "relic" --
buildingOptMenuLayer.BTN_TRAIT = "trait" --圣物搜寻
buildingOptMenuLayer.BTN_WORSHIP = "worship" --供奉圣物
buildingOptMenuLayer.BTN_SKIN = "cloth" --皮肤
buildingOptMenuLayer.BTN_HERO = "hero" --名将
buildingOptMenuLayer.BTN_CHALLENGE = "challenge" --试炼
buildingOptMenuLayer.BTN_FUHUO = "fuhuo" --复活

buildingOptMenuLayer.BTN_SOLDIERSGUARD = "soldiersguard" --守军
buildingOptMenuLayer.BTN_SOLDIERSINFO = "soldiersinfo" --部队详情

buildingOptMenuLayer.BTN_HORNOR = "hornor" --荣誉
buildingOptMenuLayer.BTN_EXPEDITION = "expedition" --远征
buildingOptMenuLayer.BTN_BOATPVP = "boatpvp" --战舰竞技

buildingOptMenuLayer.Imgs = {
   [buildingOptMenuLayer.BTN_INFO] =  "zhucheng_anniu_xiangqing_zhengchang.png",
   [buildingOptMenuLayer.BTN_UPGRADE] =  "zhucheng_anniu_shengji_zhengchang.png",
   [buildingOptMenuLayer.BTN_DEFENSE] =  "zhucheng_chenfang_zhengchang.png",
   [buildingOptMenuLayer.BTN_BUILD] =  "zhucheng_jz_zhengchang.png",
   [buildingOptMenuLayer.BTN_SPY] =  "zhucheng_zhencha_zhengchang.png",
   [buildingOptMenuLayer.BTN_TRAIN] =  "zhucheng_xl_zhengchang.png",
   [buildingOptMenuLayer.BTN_STUDY] =  "zhucheng_yj_zhengchang.png",
   [buildingOptMenuLayer.BTN_TREAT] =  "zhucheng_yiliao_zhengchang.png",
   [buildingOptMenuLayer.BTN_COLLECT] =  "zhucheng_anniu_xiangqing_zhengchang.png",
   [buildingOptMenuLayer.BTN_CHANGE] =  "zhucheng_zhuanhuan_zhengchang.png",
   [buildingOptMenuLayer.BTN_GAHTER] =  "zhucheng_cj_1_zhengchang.png",
   [buildingOptMenuLayer.BTN_MINING] =  "zhucheng_cj_zhengchang.png",
   [buildingOptMenuLayer.BTN_STOP] =  "zhucheng_anniu_quxiao.png",
   [buildingOptMenuLayer.BTN_FASTER] =  "zhucheng_anniu_jiasu_1.png",
   [buildingOptMenuLayer.BTN_FARMER] =  "zhucheng_sc_1_zhengchang.png",
   [buildingOptMenuLayer.BTN_INBUILDING] =  "zhucheng_fp_1_zhengchang.png",
   [buildingOptMenuLayer.BTN_FASTER_ITEM] =  "zhucheng_anniu_jiasu.png",
   [buildingOptMenuLayer.BTN_LOG] =  "zhucheng_xx_zhengchang.png",
   [buildingOptMenuLayer.BTN_HORSE] =  "zhucheng_mache_zhengchang.png",
   [buildingOptMenuLayer.BTN_TAX] = "zhucheng_shuishou_zhengchang.png",
   [buildingOptMenuLayer.BTN_ALLIANCESHOP] = "zhucheng_anniu_shangchang_1.png",
   [buildingOptMenuLayer.BTN_GUARD] = "zhucheng_jianshou_zhengchang.png",
   [buildingOptMenuLayer.BTN_WAR] = "zhucheng_mz_zhengchang.png",
   [buildingOptMenuLayer.BTN_BOAT] = "zhucheng_anniu_jianchuan.png",
   [buildingOptMenuLayer.BTN_SAILING] = "zhucheng_anniu_hanghai1.png",
   [buildingOptMenuLayer.BTN_ALTAR] = "zhucheng_anniu_fuwen.png",
   [buildingOptMenuLayer.BTN_RELIC] = "zhucheng_anniu_souxun.png", --圣物搜寻
   [buildingOptMenuLayer.BTN_TRAIT] = "zhucheng_anniu_texing.png", --特性研究
   [buildingOptMenuLayer.BTN_WORSHIP] = "zhucheng_anniu_fuwen_gongfeng.png", --供奉圣物
   [buildingOptMenuLayer.BTN_SKIN] = "zhucheng_skin_zhengchang_btn.png", --皮肤
   [buildingOptMenuLayer.BTN_HERO] = "hero_btn.png", --皮肤
   [buildingOptMenuLayer.BTN_CHALLENGE] = "shiyan_btn.png",--皮肤
   [buildingOptMenuLayer.BTN_FUHUO] = "fuhuo_btn.png",--复活
   [buildingOptMenuLayer.BTN_SOLDIERSGUARD] = "zhucheng_guardbtn.png", --守军
   [buildingOptMenuLayer.BTN_SOLDIERSINFO] = "zhucheng_guardinfo.png", --部队详情
   [buildingOptMenuLayer.BTN_HORNOR] = "zhucheng_rongyu.png", --荣誉
   [buildingOptMenuLayer.BTN_EXPEDITION] = "zhucheng_yuanzheng.png", --远征
   [buildingOptMenuLayer.BTN_BOATPVP] = "zhucheng_yuanzheng.png", --远征
}
function buildingOptMenuLayer:ctor()   
    print("buildingOptMenuLayer ctor") 
    self.bgroup = {}
end
function buildingOptMenuLayer:init()   
    print("buildingOptMenuLayer init")   
    self.menus = me.assignWidget(self,"menus")
    self.bName = me.assignWidget(self,"buildName") 
    self.aniTag = nil
    self.s = 0 
    return true
end
function buildingOptMenuLayer:getInstance()
    if mainCity and nil == m_optMenu then
        m_optMenu = buildingOptMenuLayer:create("buildingOptMenuLayer.csb")
        mainCity:addChild(m_optMenu,me.MAXZORDER+1)
        m_optMenu:setVisible(false)      
        return  
    end
    return m_optMenu
end
function buildingOptMenuLayer:initOptMenuWithData(data,cfunc)
    if self.toftId and self.toftId ~= -1  and self.toftId ~= data.index then
        local building = mainCity.buildingMoudles[self.toftId]
        if building then            
            building.icon:stopAllActions()
            building.icon:setColor(cc.c3b(255,255,255))
        end
    end  --选中建筑变色
    self.toftId = data.index
    local def = data:getDef()
    if def.type == "food" or def.type == "stone" or def.type == "lumber" then 
      NetMan:send(_MSG.resourceBuildingInfo(self.toftId))
    end
    local bstr = def.button   
    local strLv = getLvStrByPlatform()
    if mainCity.buildingMoudles[self.toftId].state == BUILDINGSTATE_LEVEUP.key then 
       self.bName:setString(def.name.." "..strLv..(def.level - 1)) 
    else 
       self.bName:setString(def.name.." "..strLv..def.level) 
    end
    self.bName:setVisible(true)
    if data.state and data.state == BUILDINGSTATE_NORMAL.key then
        if bstr then
           local btns = me.split(bstr,",")
           if btns then
                for key, var in ipairs(btns) do
                    print("menu: "..var)
                    local isHave = true
                    if var == "tax" and user.newBtnIDs[me.toStr(OpenButtonID_Tax)] == nil then
                        isHave = false
                    end

                   if def.nextlvid == nil or def.nextlvid == "" then 
                      self:addButton(var,cfunc,true,isHave) 
                   else
                      self:addButton(var,cfunc,nil,isHave)  
                   end                          
               end           
           end
        end
--        if isWindowsPlatform() then            
--            if def.type == cfg.BUILDING_TYPE_HALL then
--                self:addButton(buildingOptMenuLayer.BTN_EXPEDITION,cfunc)
--                self:addButton(buildingOptMenuLayer.BTN_HORNOR,cfunc)                
--            end
--        end
    elseif data.state and (data.state == BUILDINGSTATE_LEVEUP.key or data.state == BUILDINGSTATE_BUILD.key or data.state == BUILDINGSTATE_CHANGE.key ) then --升级/建造等状态
        self:addButton(buildingOptMenuLayer.BTN_INFO,cfunc)
        local building = mainCity.buildingMoudles[self.toftId]
        if data.state == BUILDINGSTATE_LEVEUP.key then 
	        if def.type == cfg.BUILDING_TYPE_MARKET then
                self:addButton(buildingOptMenuLayer.BTN_HORSE,cfunc)
                self:addButton(buildingOptMenuLayer.BTN_ALLIANCESHOP,cfunc)
            elseif def.type == cfg.BUILDING_TYPE_CENTER then 
                self:addButton(buildingOptMenuLayer.BTN_TAX,cfunc,nil,user.newBtnIDs[me.toStr(OpenButtonID_Tax)] ~= nil)
                self:addButton(buildingOptMenuLayer.BTN_GUARD,cfunc)
                self:addButton(buildingOptMenuLayer.BTN_SKIN,cfunc)
            elseif def.type == cfg.BUILDING_TYPE_TOWER then                
                self:addButton(buildingOptMenuLayer.BTN_WAR,cfunc)
            elseif def.type == cfg.BUILDING_TYPE_ALTAR then                
                self:addButton(buildingOptMenuLayer.BTN_ALTAR,cfunc)
                self:addButton(buildingOptMenuLayer.BTN_TRAIT,cfunc)
            elseif def.type == cfg.BUILDING_TYPE_BOAT then
                self:addButton(buildingOptMenuLayer.BTN_SAILING,cfunc)
            elseif def.type == cfg.BUILDING_TYPE_ABBEY then
                self:addButton(buildingOptMenuLayer.BTN_FUHUO,cfunc)
            end    
        end
        if building.freeBtnState == false then 
            self:addButton(buildingOptMenuLayer.BTN_FASTER,cfunc) 
            local tarTools = getBackpackDatasByType(data.state)
            if table.nums(tarTools) > 0 then --判断是否加速道具
                self:addButton(buildingOptMenuLayer.BTN_FASTER_ITEM,cfunc)
            end
        end
    else --研究/训练等状态
        local tarTools = getBackpackDatasByType(data.state)
        if def.type == cfg.BUILDING_TYPE_TOWER then
            self:addButton(buildingOptMenuLayer.BTN_INFO,cfunc)
            self:addButton(buildingOptMenuLayer.BTN_FASTER,cfunc) 
            if table.nums(tarTools) > 0 then --判断是否加速道具
                self:addButton(buildingOptMenuLayer.BTN_FASTER_ITEM,cfunc)
            end
            self:addButton(buildingOptMenuLayer.BTN_LOG,cfunc)
            self:addButton(buildingOptMenuLayer.BTN_WAR,cfunc)
        elseif def.type ~= cfg.BUILDING_TYPE_CENTER then
           self:addButton(buildingOptMenuLayer.BTN_INFO,cfunc)
           self:addButton(buildingOptMenuLayer.BTN_FASTER,cfunc) 
           if table.nums(tarTools) > 0 then  --判断是否加速道具
                self:addButton(buildingOptMenuLayer.BTN_FASTER_ITEM,cfunc)
           end
           for key, var in pairs(BUILDINGSTATE_TOTAL) do
                if me.toNum(var.key) == me.toNum(data.state) and var.btn then
                    self:addButton(var.btn,cfunc)  --功能按钮      
                end
           end
           if def.type==cfg.BUILDING_TYPE_ABBEY then
                self:addButton(buildingOptMenuLayer.BTN_FUHUO,cfunc)
           end
        else
            if data.state ~= BUILDINGSTATE_WORK_TRAIN.key then
                self:addButton(buildingOptMenuLayer.BTN_INFO,cfunc)
                self:addButton(buildingOptMenuLayer.BTN_FASTER,cfunc) 
                if table.nums(tarTools) > 0 then  --判断是否加速道具
                    self:addButton(buildingOptMenuLayer.BTN_FASTER_ITEM,cfunc) 
                end
            else
                self:addButton(buildingOptMenuLayer.BTN_INFO,cfunc)
                self:addButton(buildingOptMenuLayer.BTN_FARMER,cfunc)
            end
       end
    end 

    -- 加上效率分配按钮(城镇中心，房屋在修建和升级的时候才能有分配按钮。其他建筑物常驻,且不分状态)
    if def.type ~= cfg.BUILDING_TYPE_CENTER and def.type ~= cfg.BUILDING_TYPE_HOUSE and (def.infarmer and def.infarmer >= 1 ) then
        self:addButton(buildingOptMenuLayer.BTN_INBUILDING,cfunc)
    elseif (def.type == cfg.BUILDING_TYPE_CENTER or def.type == cfg.BUILDING_TYPE_TOWER or def.type == cfg.BUILDING_TYPE_HOUSE or def.type == cfg.BUILDING_TYPE_ABBEY or def.type == cfg.BUILDING_TYPE_MARKET or def.type == cfg.BUILDING_TYPE_BOAT or def.type == cfg.BUILDING_TYPE_ALTAR) and (data.state == BUILDINGSTATE_BUILD.key or data.state == BUILDINGSTATE_LEVEUP.key) then
        self:addButton(buildingOptMenuLayer.BTN_INBUILDING,cfunc)
    end
    self:addjust()
    guideHelper.nextStepByOpt()
end
function buildingOptMenuLayer:initOptMenuForRes(data,cfunc,state_)   
    if self.toftId_res and self.toftId_res ~= -1 and self.toftId_res~= data.place then
        local res = mainCity.resMoudles[self.toftId_res]
        if res then
            res.icon:stopAllActions()
            res.icon:setColor(cc.c3b(255,255,255))
        end
    end  --选中建筑变色
   
    self.toftId_res = data.place
    local def = data:getDef()
    local bstr = nil
    state_ = state_ or resMoudle.RES_STATE_IDEL
    if state_ == resMoudle.RES_STATE_IDEL then
        if def.type == 1 then
            bstr = "info,gather" 
        elseif def.type == 2 then
            bstr = "info,mining"
        end   
    elseif state_ == resMoudle.RES_STATE_WORK then
        bstr = "info"
    elseif state_ == resMoudle.RES_STATE_EXHAUSTED then
        bstr = "info"
    end
    
    self.bName:setString(TID_CONNECT_POINT)
    self.bName:setVisible(true)
    if bstr then
       local btns = me.split(bstr,",")
       if btns then
           for key, var in ipairs(btns) do
               print("menu: "..var)
               self:addButton(var,cfunc)                            
           end           
       end
    end
    self:addjust()
end
--移除按钮上特效
function buildingOptMenuLayer:removeButtonAni()
    for key, var in pairs(self.bgroup) do
        if var.opt == self.aniTag and me.assignWidget(var,"buttonAni") then
            local ani = me.assignWidget(var,"buttonAni")
            ani:removeFromParent()
        end
    end
    self.aniTag = nil
end
function buildingOptMenuLayer:setAniTag(tag_)
    self.aniTag = tag_
end
--按钮上的特效
function buildingOptMenuLayer:playButtonAni()
    for key, var in pairs(self.bgroup) do
        if self.aniTag and var.opt == self.aniTag and me.assignWidget(var,"buttonAni") == nil then
            local ani = createArmature("circle_ani")
            ani:getAnimation():playWithIndex(0)
            ani:setName("buttonAni")
            ani:setAnchorPoint(cc.p(0.5,0.5))
            ani:setScale(1.2)
            ani:setPosition(cc.p(var:getContentSize().width/2,var:getContentSize().height/2))
            var:addChild(ani)
        end
        if var.opt == buildingOptMenuLayer.BTN_FASTER_ITEM and me.assignWidget(var,"buttonAni") == nil  then
            local ani = createArmature("circle_ani")
            ani:getAnimation():playWithIndex(0)
            ani:setName("buttonAni")
            ani:setAnchorPoint(cc.p(0.5,0.5))
            ani:setScale(1.2)
            ani:setPosition(cc.p(var:getContentSize().width/2,var:getContentSize().height/2))
            var:addChild(ani)
        end   
        -- 可收税提示
        if var.opt == buildingOptMenuLayer.BTN_TAX and me.assignWidget(var,"buttonAni") == nil then
          if user.taxInfo.newFreeCount + user.taxInfo.newPayCount < user.taxInfo.maxCount then
            local ani = createArmature("circle_ani")
            ani:getAnimation():playWithIndex(0)
            ani:setName("buttonAni")
            ani:setAnchorPoint(cc.p(0.5, 0.5))
            ani:setScale(1.2)
            ani:setPosition(cc.p(var:getContentSize().width / 2, var:getContentSize().height / 2))
            var:addChild(ani)
          end
        end
    end
end
function buildingOptMenuLayer:addButton(t,cfunc,isHighestLevel,isOpen_)
    if isOpen_ == false then
        return
    end
  if t ~= "horse" then 
    local button = ccui.Button:create()
    button:loadTextureNormal(buildingOptMenuLayer.Imgs[t],me.localType)
    button.opt = t

    if t == buildingOptMenuLayer.BTN_FASTER then        
      local building = mainCity.buildingMoudles[self.toftId]
      if building then
          local cost = building:getImmeCost()
          if cost and me.toNum(cost) > 0 then 
                local text = ccui.Text:create(cost,"",24)
                button:addChild(text)
                text:setAnchorPoint(cc.p(0.5,0.5))
                text:setTextColor(cc.c3b(255, 208, 63)) 
                text:setPosition(cc.p(button:getContentSize().width/2,button:getContentSize().height/3*2+12))
          end
      end
    end
    if t == buildingOptMenuLayer.BTN_UPGRADE then 
       if isHighestLevel then 
         return
       end
    end
    me.registGuiClickEvent(button,cfunc)
    self.bgroup[#self.bgroup + 1] = button 
    self.menus:addChild(button)
  else
  --礼包马车按钮
    --me.clearTimer(self.set_time)
    self.tradeButton = ccui.Button:create()
    self.tradeButton.opt = t
    if user.packageData.status == 0 then
      self.tradeButton:loadTextureNormal("zhucheng_mache_hui.png",me.localType)
    else
      self.tradeButton:loadTextureNormal("zhucheng_mache_zhengchang.png",me.localType)
      if user.packageData.status == 1 then
         self.tradeTimeNeeded = (user.packageData.times - (me.sysTime() - user.packageData.revtime)) / 1000
         local s = 0
         self.tradeButtonText = ccui.Text:create(me.formartSecTime(self.tradeTimeNeeded),"",26) 
         self.tradeButtonText:setAnchorPoint(0.5,0.5)
         self.tradeButtonText:setPosition(self.tradeButton:getContentSize().width/2,self.tradeButton:getContentSize().height/4-13)
         self.tradeButton:addChild(self.tradeButtonText)
         local function update(dt)
          s = s + dt
          self.tradeButtonText:setString(me.formartSecTime(self.tradeTimeNeeded - s))
         end
         self.set_time = me.registTimer(self.tradeTimeNeeded,update,1)
        elseif user.packageData.status == 2 then
         self.tradeButtonText = ccui.Text:create("点击领取","",26)
         self.tradeButtonText:setTextColor(cc.c3b(116, 255, 102))
         self.tradeButtonText:setAnchorPoint(0.5,0.5)
         self.tradeButtonText:setPosition(self.tradeButton:getContentSize().width/2,self.tradeButton:getContentSize().height/4-13)
         self.tradeButton:addChild(self.tradeButtonText)
       elseif user.packageData.status == 3 then
        self.tradeButton:loadTextureNormal("zhucheng_mache_zhengchang.png",me.localType)
        self.tradeButtonText = ccui.Text:create("今日已完","",26)
        self.tradeButtonText:setTextColor(cc.c3b(232,68,68))
        self.tradeButtonText:setAnchorPoint(0.5,0.5)
        self.tradeButtonText:setPosition(self.tradeButton:getContentSize().width/2,self.tradeButton:getContentSize().height/4-13)
        self.tradeButton:addChild(self.tradeButtonText)
       end             
    end
      
     me.registGuiClickEvent(self.tradeButton,cfunc)
     self.bgroup[#self.bgroup + 1] = self.tradeButton 
     self.menus:addChild(self.tradeButton)
     self.marketSeleceted = true
  end
  self:playButtonAni()
end
function buildingOptMenuLayer:showBuildingOpt(data,cfunc)
    if self.toftId ~= data.index then
        self:clearnButton()
        self:initOptMenuWithData(data,cfunc)
        self:setVisible(true)
    end
end
function buildingOptMenuLayer:showResOpt(data,cfunc,state_)
      if self.toftId_res ~= data.place then
       self:clearnButton()
       self:initOptMenuForRes(data,cfunc,state_)
       self:setVisible(true)     
      end            
end
local wd = 40
local height_group = {
    [1] = {
        [1] = 0
    },
    [2] = {
    [1] = wd,
    [2] = wd
    },
    [3] = {
    [1] = wd,
    [2] = 0,
    [3] = wd
    },
    [4]={
    [1] = wd*2,
    [2] = wd,
    [3] = wd,
    [4] = wd*2
    },
    [5]={
    [1] = wd*2,
    [2] = wd,
    [3] = 0,
    [4] = wd,
    [5] = wd*2
    }

}
function buildingOptMenuLayer:addjust()
   local spw = 24
   local sph = 10
   local num = #self.bgroup
   local bwidth = 89
   local bheight = 91
   local awidth = num * (bwidth + spw)-spw
   local n2 = math.floor(num/2)
   for key, var in ipairs(self.bgroup) do
       --local a1 =  cc.MoveTo:create(0.3,cc.p(me.winSize.width/2-awidth/2+bwidth/2 + (bwidth+spw)*(key-1),height_group[num][key])) 
             
       var:setPosition((1280-awidth)/2+bwidth/2 + (bwidth+spw)*(key-1),200)
       --var:runAction(cc.EaseBounceOut:create(a1))
       me.clickAni5(var)
   end
   self.menus:setPositionX(me.winSize.width/2)

end

function buildingOptMenuLayer:clearnButton() 
  if self.toftId and self.toftId ~= -1 then
        local building = mainCity.buildingMoudles[self.toftId]
        if building then
            building.icon:stopAllActions()
            building.icon:setColor(cc.c3b(255,255,255))
        end
    end  --选中建筑变色
    if self.toftId_res and self.toftId_res ~= -1 then
        local res = mainCity.resMoudles[self.toftId_res]
        if res then
            res.icon:stopAllActions()
            res.icon:setColor(cc.c3b(255,255,255))
        end
    end  --选中资源变色
    self.toftId = -1
    self.toftId_res = -1
   for key, var in ipairs(self.bgroup) do        
       var:stopAllActions()
   end   
   self.menus:removeAllChildren()
   self.bgroup = {}
   self:setVisible(false)
   me.clearTimer(self.set_time)
   self.marketSeleceted = false
end
function buildingOptMenuLayer:onEnter()
  print("buildingOptMenuLayer onEnter") 
  me.doLayout(self,me.winSize)  
end
function buildingOptMenuLayer:onExit()
    print("buildingOptMenuLayer onExit")    
end

--更新马车按钮
function buildingOptMenuLayer:updateTradeButton()
  print("updateTradeButton")
  if self.marketSeleceted then 
    if user.packageData.status == 1 then
             self.tradeTimeNeeded = (user.packageData.times - (me.sysTime() - user.packageData.revtime)) / 1000
             local s = 0
             self.tradeButtonText:setString(me.formartSecTime(self.tradeTimeNeeded))            
             self.tradeButtonText:setTextColor(cc.c3b(255, 255, 255))
           local function update(dt)
              s = s + dt
              self.tradeButtonText:setString(me.formartSecTime(self.tradeTimeNeeded - s))
           end
           self.set_time = me.registTimer(self.tradeTimeNeeded,update,1)
     elseif  user.packageData.status == 2 then
           me.clearTimer(self.set_time)
           self.tradeButtonText:setString("点击领取")
           self.tradeButtonText:setTextColor(cc.c3b(116, 255, 102))
     elseif user.packageData.status == 3 then 
         self.tradeButtonText:setString("今日已完")
         self.tradeButtonText:setTextColor(cc.c3b(232,68,68))
     end
  end
end

function buildingOptMenuLayer:getMenuBtnByOpt(opt_)
    for key, var in pairs(self.menus:getChildren()) do
        print("var.opt = "..var.opt)
        if var.opt == opt_ then
            return var
        end 
    end
    return nil
end