--[Comment]
--jnmo
warship_tech = class("warship_tech",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
warship_tech.__index = warship_tech
function warship_tech:create(...)
    local layer = warship_tech.new(...)
    if layer then 
        if layer:init() then 
            layer:registerScriptHandler(function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
				elseif "enterTransitionFinish" == tag then
                    layer:onEnterTransitionDidFinish()
                end
            end)            
            return layer
        end
    end
    return nil 
end
function warship_tech:ctor()   
    print("warship_tech ctor") 
    self.WarshipType = 1
    self.pBool = true
end
function warship_tech:init()   
    print("warship_tech init")
	me.registGuiClickEventByName(self,"close",function (node)
        self:close()     
    end)    
    self.title = me.assignWidget(self,"title")
    return true
end
function warship_tech:setDataTidy(pType)
     self.WarshipType = pType
     local pData = user.Warship_Tech[self.WarshipType]
     self.HaveData = user.warshipData[self.WarshipType]  
     self.mData = {}
     local pNum = 0
     for key, var in pairs(pData) do        
         table.insert(self.mData,var)             
     end
     function Techorder(ta,tb)
          local pTaConfig = ta.Config 
          local pTbConfig = tb.Config 
          if pTaConfig["order"] < pTbConfig["order"] then
             return true
          end
     end
     table.sort(self.mData, Techorder)
     self:setUI()
end
function warship_tech:setUI()
    local pNum = 5
    me.assignWidget(self,"Panel_warship"):setSwallowTouches(false)
    local Panel_addition = me.assignWidget(self,"Panel_addition"):setVisible(true) 
    local Panel_addNum = me.assignWidget(self,"Panel_addNum"):setVisible(true) 
    local pNamel
     Panel_addition:removeAllChildren()
     Panel_addNum:removeAllChildren()
     local pWidth = 0
     for key, var in pairs(self.mData) do  
          local pConfig = var.Config  
          local Panel = me.assignWidget(self,"Panel_"..pNum)   
          Panel:removeAllChildren()              
          local pTechStr = cfg[CfgType.LORD_INFO][pConfig.exttype]
          local before = pConfig.beforetxt
          local success = pConfig.successtxt

          local pnameStr = string.sub(pConfig.name,1,12)
          print("pnameStr"..pnameStr)
          local pStrNature = "<txt0013,dccd90>"..pnameStr.." Lv."..pConfig.level.." :  + ".. before .."&"     
          local rcfn = mRichText:create(pStrNature)
          rcfn:setAnchorPoint(cc.p(0,0.5))
          rcfn:setPosition(cc.p(0,- (pNum-5) * 25))
          Panel_addition:addChild(rcfn)
          pWidth = math.max(rcfn:getContentSize().width,pWidth)

          local pStrNatureNum = "<img3838,000000>zhanjian_jiantou_lv_you.png&<txt0012,13d43c> "..success.."&"     
          local rcf = mRichText:create(pStrNatureNum, 500, nil,5)
          rcf:setAnchorPoint(cc.p(0,0.5))
          rcf:setPosition(cc.p(0,- (pNum-5) * 25))
          Panel_addNum:addChild(rcf)

          pNum = pNum + 1
          local Panel_warship = me.assignWidget(self,"Panel_warship_cell"):clone():setVisible(true)
          Panel_warship:setAnchorPoint(cc.p(0.5,0.5))
          Panel_warship:setPosition(cc.p(40,90))
          Panel:addChild(Panel_warship)
          
          local warship_cell_icon = me.assignWidget(Panel_warship,"warship_cell_icon")
          warship_cell_icon:loadTexture("battleship_"..pConfig["icon"]..".png",me.plistType)
          me.resizeImage(warship_cell_icon, 155,149)

          local Text_2 = me.assignWidget(Panel_warship,"cell_name")
          Text_2:setString(pnameStr)
          me.assignWidget(Panel_warship,"Button_cell_up"):setTag(key)
          me.registGuiClickEventByName(Panel_warship,"Button_cell_up",function (node)
                
                local key = node:getTag()
                print("Button_cell_up"..key)
                local pdata = self.mData[key]                
                local Warship_tech_up = Warship_tech_up:create("warship_science_up.csb")
                Warship_tech_up:setData(pdata)
                me.showLayer(Warship_tech_up)
                self:addChild(Warship_tech_up, me.MAXZORDER)              
          end)

          local pLv = pConfig.level
          local pShipLv = self.HaveData.baseShipCfg.lv
          if pShipLv ~= pLv and self:getBoolHave(pConfig.nextid) then                 
             me.assignWidget(Panel_warship,"Image_up"):setVisible(true)
          else   
             me.assignWidget(Panel_warship,"Image_up"):setVisible(false)
          end
          
     end
     Panel_addNum:setPosition(cc.p(pWidth+875,Panel_addNum:getPositionY()))
     local pHaveData = user.warshipData[self.WarshipType] 
     local baseShipCfg = pHaveData.baseShipCfg
     local warship_icon = me.assignWidget(self,"warship_icon")
     warship_icon:loadTexture("zhanjian_tupian_zhanjian_"..baseShipCfg.icon..".png",me.plistType)
     warship_icon:ignoreContentAdaptWithSize(false)

     local Text_2 = me.assignWidget(self,"Text_2")
     Text_2:setString(baseShipCfg.name) 
     
     me.registGuiClickEventByName(self,"Button_up",function (node)     
         if self.pBool then
            Panel_addNum:setVisible(false)
            self.pBool  =false
         else
            Panel_addNum:setVisible(true)
            self.pBool  =true
         end
     end)
end
function warship_tech:getBoolHave(nextId)
    local pdata = cfg[CfgType.SHIP_TECH][me.toNum(nextId)] 
    local pBool = false
    if pdata then   
        pNeedExp = pdata.needItem
        local pTable = me.split(pdata.itemType,",")
           
        local pUse = user.pkg
        for key, var in pairs(pTable) do
            local pStr = me.split(var,":")
            local pId = me.toNum(pStr[1])
            local pConfig = cfg[CfgType.ETC][pId]
            local pTechData = {}
            pTechData.Config = pConfig
            local pCount = 0
            local HaveData = nil
            for key, var in pairs(pUse) do
                if var.defid == pId then
                    pBool = true 
                    return pBool
                end
            end
         end
       end
       return pBool
end
function warship_tech:update(msg)
    if checkMsg(msg.t, MsgCode.MSG_SHIP_TECH_UP) then  
       self:setDataTidy(self.WarshipType)  
    end
end
function warship_tech:onEnter()
    print("warship_tech onEnter") 
	me.doLayout(self,me.winSize)  
    self.modelkey = UserModel:registerLisener(function(msg)  -- 注册消息通知
        self:update(msg)        
    end)
end
function warship_tech:onEnterTransitionDidFinish()
	print("warship_tech onEnterTransitionDidFinish") 
end
function warship_tech:onExit()
    print("warship_tech onExit")    
    UserModel:removeLisener(self.modelkey) -- 删除消息通知
end
function warship_tech:close()
    self:removeFromParentAndCleanup(true)  
end
