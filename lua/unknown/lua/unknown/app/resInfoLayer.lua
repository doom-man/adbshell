-- 资源点详细信息
resInfoLayer = class("resInfoLayer", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end )
resInfoLayer.__index = resInfoLayer
function resInfoLayer:create(...)
    local layer = resInfoLayer.new(...)
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
function resInfoLayer:ctor()
    print("resInfoLayer ctor")
    -- 采集剩余时间
    self.leftTime = 0
    -- 剩余可采集量
    self.produce = 0
end
function resInfoLayer:init()
    print("resInfoLayer init")

    -- 注册点击事件
    me.registGuiClickEventByName(self, "close", function(node)
        me.DelayRun( function()
            self:close()
        end , 0.01)

    end )
    -- 注册点击事件
    local fixlayout = me.registGuiClickEventByName(self, "fixLayout", function(node)
        -- 为了解决关闭该层的时候，OPT菜单也关闭的问题
        me.DelayRun( function()
            self:close()
        end , 0.01)
    end )
    self.production = me.assignWidget(self, "production")
    self.needtime = me.assignWidget(self, "needtime")
    self.farmer = me.assignWidget(self, "farmer")
    self.rIcon = me.assignWidget(self, "rIcon")

    return true
end
function resInfoLayer:initWithData(data)
    self.data = data
    local def = data:getDef()
    local kind = def.type
    if kind == 1 then
        self.rIcon:loadTexture(ICON_RES_FOOD, me.localType)
    elseif kind == 2 then
        self.rIcon:loadTexture(ICON_RES_GOLD, me.localType)
    end
    self.production:setString(math.floor(def.out - data.value))
    self.farmer:setString("x" .. def.worker)
    local ofsettime =(me.sysTime() - data.startTime) / 1000
    self.leftTime = data.leftTime - ofsettime
    self.needtime:setString(me.formartSecTime(self.leftTime))
    if data.work == resMoudle.RES_STATE_WORK then
        self.produce = def.out - data.value
        self.produce = self.leftTime * def.out / def.time
        self.production:setString(math.floor(self.produce))
        print("self.leftTime = " .. self.leftTime)
        self.m_timer = me.registTimer(self.leftTime, function(dt, b)
            self.leftTime = self.leftTime - dt
            self.needtime:setString(me.formartSecTime(self.leftTime))
            self.produce = self.leftTime * def.out / def.time
            self.production:setString(math.floor(self.produce))
            if b then
                self.production:setString(0)
                self.needtime:setString(me.formartSecTime(0))
            end
        end , 1)
    elseif data.work == resMoudle.RES_STATE_EXHAUSTED then
        self.needtime:setString(me.formartSecTime(0))
    end
    
end
function resInfoLayer:close()
    -- me.hideLayer(self,true,"shopbg")
    self:removeFromParentAndCleanup(true)
end
function resInfoLayer:onEnter()
    print("resInfoLayer onEnter")
    me.doLayout(self, me.winSize)
end
function resInfoLayer:onExit()
    print("resInfoLayer onExit")
    me.clearTimer(self.m_timer)
end
