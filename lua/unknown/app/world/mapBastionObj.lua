-- jnmo
mapBastionObj = class("mapBastionObj", mapObj)
mapBastionObj.__index = mapBastionObj
function mapBastionObj:ctor()
    super(self)
end
-- mapCellData.id 主城的id
function mapBastionObj:create(id)
    local layer = mapBastionObj.new()
    layer.m_id = id 
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

function mapBastionObj:init()
    superfunc(self, "init")

    return true
end
function mapBastionObj:initObj()
    superfunc(self, "initObj")
    local data = self:getCellData()
    print("data.pointType =" .. data.pointType)
    if data then
        local owner = data:getOwnerData()
        if owner then
            self.icon:setVisible(true)
            self.nameBg:setVisible(false)
            self.icon:loadTexture(self:getIconByState(data.strongHoldNew), me.localType)
            local name = data.strongHoldName
            self.name:setString(name)
            if data.strongHoldNew and data.occState == OCC_STATE_OWN then
                self:initStrongTimeBar()                          
            end
             local ptype = owner:getProtectedType()  
             self.captiveIcon:setVisible(owner:isCaptived())
             self.captiveIcon:loadTexture(tabImageName["3"], me.localType)
             self.protectIcon:setVisible(owner:isProtected())
             if ptype ~= PROTECTED_TYPE_MINE then
                self.protectIcon:loadTexture(tabImageName[me.toStr(ptype)], me.localType)
             else
                self.protectIcon:setVisible(false)
             end

            -- 调整保护图标的位置
            if self.protectIcon:isVisible() then
                self.protectIcon:setPositionX(self.name:getPositionX() - self.name:getContentSize().width/2 - self.protectIcon:getContentSize().width/2)
                self.captiveIcon:setPositionX(self.protectIcon:getPositionX() - self.protectIcon:getContentSize().width)
            else
                self.captiveIcon:setPositionX(self.name:getPositionX() - self.name:getContentSize().width/2 - self.captiveIcon:getContentSize().width/2)
            end
        end
    end
    --self:setLocalZOrder(10)
end
function mapBastionObj:getIconByState(b)
    if b then --是否在建
        return "waicheng_tubiao_yaosai_jianzhao.png"
    else
        return "fortImg.png"
    end
end
function mapBastionObj:initStrongTimeBar()
    local data = self:getCellData()  
    if self.timeBar == nil and data ~= nil then
        local maxtime = cfg[CfgType.BASTION_DATA][1].time
        if user.Cross_Sever_Status == mCross_Sever then       
            maxtime = cfg[CfgType.CROSS_STRONG_HOLD][1].time     
        end
        local gtime = data.strongHoldtime-1
        self.timeBar = me.createNode("loadingBar.csb")
        local bg = me.assignWidget(self.timeBar, "bg")
        bg:loadTexture("waicheng_judian_kuang.png",me.plistType)
        local Text_time = me.assignWidget(self.timeBar, "Text_time")
        local LoadingBar_time = me.assignWidget(self.timeBar, "LoadingBar_time")
        self.timeBar:setPosition(cc.p(self:getContentSize().width / 2 - self.timeBar:getContentSize().width / 2, self:getContentSize().height / 3))
        local t = 0
        LoadingBar_time:setPercent((maxtime-gtime) * 100 / maxtime)
        self.gTimer = me.registTimer(gtime, function(dt) 
               gtime = gtime - dt             
               if gtime > 0 then
                    Text_time:setString(me.formartSecTime(gtime))
                    LoadingBar_time:setPercent((maxtime-gtime) * 100 / maxtime)
                else
                    me.clearTimer(self.gTimer)
                    self.timeBar:removeFromParentAndCleanup(true)                     
                    self.timeBar = nil
                end           
        end )
        self:addChild(self.timeBar, 10)
    end
end
function mapBastionObj:onEnter()
    superfunc(self, "onEnter")
    me.doLayout(self, self:getContentSize()) 
end
function mapBastionObj:onExit()
    superfunc(self, "onExit")  
end