-- 领主管理-任命-2015-12-17

lairappoint = class("lairappoint",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end)
lairappoint.__index = lairappoint
function lairappoint:create(...)
    local layer = lairappoint.new(...)
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
function lairappoint:ctor()
        self.pParent = nil  
        self.ButtonMake = me.registGuiClickEventByName(self,"Button_a_make",function (node)  -- 禅让盟主
            if self.mData~= nil then    
                 NetMan:send(_MSG.updateDegreeFamily(self.mData["uid"],1))   -- 任命                           
            end         
        end)  

        self.ButtonLeader = me.registGuiClickEventByName(self,"Button_a_Vice_Chief",function (node)  -- 副盟主
            if self.mData~= nil then
                 NetMan:send(_MSG.updateDegreeFamily(self.mData["uid"],2))   -- 任命
            end         
        end)  

        self.ButtonOfficer = me.registGuiClickEventByName(self,"Button_a_officer",function (node)    -- 官员
            if self.mData~= nil then
                 NetMan:send(_MSG.updateDegreeFamily(self.mData["uid"],3))   -- 任命
            end                
        end)   

        self.ButtonMember = me.registGuiClickEventByName(self,"Button_a_member",function (node)      -- 成员
             if self.mData~= nil then
                 NetMan:send(_MSG.updateDegreeFamily(self.mData["uid"],4))   -- 任命
            end      
        end)     


        
        self.ButtonExit = me.registGuiClickEventByName(self,"Button_a_dismiss",function (node)       -- 辞退
             if self.mData~= nil then
                 NetMan:send(_MSG.kickFamily(self.mData["uid"])) 
            end      
        end)       

        self.ButtonDetail = me.registGuiClickEventByName(self,"Button_a_detail",function (node)       -- 详情
            local detail = allianceLevelDetial:create("allianceLevelDetail.csb")
            me.runningScene():addChild(detail)
            me.showLayer(detail, "bg_frame")   
            self:close() 
        end) 

         me.registGuiClickEventByName(self,"fixLayout",function (node)
        local pTouch = node:getTouchBeganPosition()                  
        local pNode = me.assignWidget(self, "Node_touch_size")    
        pNode:setContentSize(cc.size(330,380))
        pNode:setAnchorPoint(cc.p(0.5,0.5))    
        local pLayer = cc.LayerColor:create(cc.c3b(144,144,100)) 
        pLayer:setAnchorPoint(cc.p(0,0))
        pLayer:setContentSize(cc.size(pNode:getContentSize()))
        pLayer:setPosition(cc.p(0,0))
        pNode:addChild(pLayer)           
        local pPoint = self:contains(pNode,pTouch.x,pTouch.y)
        if pPoint then
        -- 点击在节点中                                       
        else 
         -- 点击在节点外
         self:close()
        end      
   end) 
   
end
function lairappoint:close()
     if self.mSprite ~= nil then
        self.mSprite:setVisible(false)  
     end
      self:removeFromParentAndCleanup(true)
end
-- 判断是否点击在节点中
function lairappoint:contains(node, x, y)    
        local point = cc.p(x,y)
        local pRect = cc.rect(0,0,node:getContentSize().width,node:getContentSize().height)  
        local locationInNode = node:convertToNodeSpace(point)     -- 世界坐标转换成节点坐标
        return cc.rectContainsPoint(pRect, locationInNode)      
end
function lairappoint:setPitchOn(pSprite,pData,pParent,degreeList)   
      self.mSprite = nil     
      self.pParent = pParent
      self.degreeList=degreeList
      if pSprite ~= nil then     
        self.mSprite = pSprite
      end
    
     self.mData = pData    
     local pMyData = user.familyMember
     local pMyDegree = pMyData["degree"]   -- 我的职位
     local pDegree = pData["degree"]       -- 点击人的职位
     
     local unionCfg = cfg[CfgType.FAMILY_BASE][user.famliyInit.level]
     me.assignWidget(self.ButtonLeader, "infoTxt"):setString("("..self.degreeList[2].."/"..unionCfg.depLeader..")")
     me.assignWidget(self.ButtonOfficer, "infoTxt"):setString("("..self.degreeList[3].."/"..unionCfg.official..")")

     -- 禅让盟主
     if pMyDegree == 1 and user.familyabdicatetime == 0 then
        self:setButton(self.ButtonMake,true)
        else
        self:setButton(self.ButtonMake,false)
     end

     -- 副盟主
     if pMyDegree == 1 and pDegree ~=2  then
        self:setButton(self.ButtonLeader,true)
        else
        self:setButton(self.ButtonLeader,false)
     end
     -- 官员
     if pMyDegree < 3 and (pMyDegree - pDegree) < 0  and pDegree ~= 3 then
         self:setButton(self.ButtonOfficer,true)
         else
         self:setButton(self.ButtonOfficer,false)
     end
     -- 成员
     if pMyDegree < 3 and pDegree ~= 4 and (pMyDegree - pDegree) < 0 then
         self:setButton(self.ButtonMember,true)
         else
         self:setButton(self.ButtonMember,false)
     end

     -- 辞退
     if pMyDegree < 3 and (pMyDegree - pDegree) < 0 then
         self:setButton(self.ButtonExit,true)
         else
         self:setButton(self.ButtonExit,false)
     end
end

function lairappoint:setButton(button,b)
    button:setTouchEnabled(b)
    button:setBright(b)
end
function lairappoint:init()   
    return true
end
function lairappoint:update(msg)     
    if checkMsg(msg.t, MsgCode.MSG_FAMILY_INIT_MEMBER_LIST) or checkMsg(msg.t, MsgCode.MSG_FAMILY_UPDATA_MEMBER_LIST)  then            -- 联盟成员数据列表    
        self:removeFromParentAndCleanup(true)         
    end
end

function lairappoint:onEnter()   
	me.doLayout(self,me.winSize)  
     self.modelkey = UserModel:registerLisener(function(msg)  -- 注册消息通知
         self:update(msg)
    end)
end
function lairappoint:onExit()  
    UserModel:removeLisener(self.modelkey)   -- 删除消息通知
end

