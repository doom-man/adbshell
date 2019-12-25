--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion
conquerConfirm = class("conquerConfirm", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
conquerConfirm.__index = conquerConfirm

function conquerConfirm:create(...)
    local layer = conquerConfirm.new(...)
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

function conquerConfirm:ctor()

end



function conquerConfirm:init()
    
    self.itemNode = me.assignWidget(self, "itemNode")
    self.closeBtn = me.registGuiClickEventByName(self, "close", function(node)
        me.DelayRun(function (args)
           self:close()
        end)
    end)

    me.registGuiClickEventByName(self, "gotoBtn", handler(self, self.showExped))

    return true
end

function conquerConfirm:setData(data, isWin, revert, revertGem)
    self.data = data
    self.revertData = {isWin=isWin,revert=revert, revertGem=revertGem}
    local maxTxt=me.assignWidget(self, "maxTxt")
    maxTxt:setString(data.baseData.level)
    local tempSize = maxTxt:getContentSize()
    me.assignWidget(self, "maxTxt1"):setPositionX(maxTxt:getPositionX() - tempSize.width / 2 - 5)
    me.assignWidget(self, "maxTxt2"):setPositionX(maxTxt:getPositionX() + tempSize.width / 2 + 5)

    local baseData = cfg[CfgType.HEROLEVEL_BASE][self.data.baseData.id]
    local tmp = string.split(baseData.npc,":")
    local soldierData =  cfg[CfgType.CFG_SOLDIER][tonumber(tmp[1])]

    me.assignWidget(self, "s_icon"):loadTexture(soldierIcon(soldierData), me.plistType)
    me.assignWidget(self, "army_type"):setString(soldierType[me.toStr(soldierData.smallType)])
    me.assignWidget(self, "army_num"):setString(tmp[2])
    me.assignWidget(self, "army_name"):setString(soldierData.name)
    if baseData.battletype==1 then
        me.assignWidget(self, "battle_type"):setString("城战")
    else
        me.assignWidget(self, "battle_type"):setString("野战")
    end

    local skillcfg = me.split(soldierData.skill,",")
    if skillcfg then
        for key, var in ipairs(skillcfg) do
            local skilldata = cfg[CfgType.CFG_SOLDIER_SKILL][me.toNum(var)]
            me.assignWidget(self, "skillname"..key):setString(skilldata.name)
            me.assignWidget(self, "skilldesc"..key):setString(skilldata.desc)
        end           
    end

    local tmp = string.split(baseData.basereward,",")
    local normalJianli = me.assignWidget(self, "normalJianli")
    local w = 50
    for key, var in ipairs(tmp) do
        local tmp1 = string.split(var, ":")
        local item = self.itemNode:clone():setVisible(true)
        local txt = me.assignWidget(item, "numsTxt")
        txt:setString("+"..tmp1[2])
        local icon = me.assignWidget(item, "itemNode")
        icon:loadTexture(getItemIcon(tmp1[1]))
        normalJianli:addChild(item)
        me.registGuiClickEventByName(item,"itemNode",function ()
            showPromotion(tonumber(tmp1[1]),tmp1[2])
        end) 
        local w1 = 0
        if tonumber(tmp1[2]) > 100 then
            me.resizeImage(icon, 45, 45)
            w1 = 45
            txt:setPositionX(44)
        else
            me.resizeImage(icon, 55, 55)
            w1 = 55
            txt:setPosition(50, 25)
        end
        item:setPosition(w, 22)
        w = w + w1 + txt:getPositionX() + txt:getContentSize().width + 10
    end

    if baseData.bonusreward=="" or baseData.bonusreward==nil then
        me.assignWidget(self, "firstNode"):setVisible(false)
        me.assignWidget(self, "Text_74_0"):setPositionY(200)
        me.assignWidget(self, "gotoBtn"):setPositionY(70)
    else
        me.assignWidget(self, "firstNode"):setVisible(true)
        local tmp = string.split(baseData.bonusreward,",")
        local firsstJianli = me.assignWidget(self, "firsstJianli")
        local w = 50
        for key, var in ipairs(tmp) do
            local tmp1 = string.split(var, ":")
            local item = self.itemNode:clone():setVisible(true)
            local txt = me.assignWidget(item, "numsTxt")
            txt:setString("+"..tmp1[2])
            local icon = me.assignWidget(item, "itemNode")
            icon:loadTexture(getItemIcon(tmp1[1]))
            firsstJianli:addChild(item)
            me.registGuiClickEventByName(item,"itemNode",function ()
                showPromotion(tonumber(tmp1[1]),tmp1[2])
            end) 
            local w1 = 0
            if tonumber(tmp1[2])>100 then
                me.resizeImage(icon, 45, 45)
                w1 = 45
                txt:setPositionX(44)
            else
                me.resizeImage(icon, 55, 55)
                w1 = 55
                txt:setPosition(50, 25)
            end
            item:setPosition(w, 22)
            w = w + w1 + txt:getPositionX() + txt:getContentSize().width + 10
        end
    end
end

function conquerConfirm:showExped()

    local exped = expedLayer:create("expeditionLayer.csb")
    exped:setExpedState(EXPED_STATE_HEROLEVEL)
    exped:setBoosType("herolevel")
    exped:setHerolevelData(self.revertData)
    
    --exped:setQueueNum(self.queueNum)
    exped:setPaths({ori=cc.p(self.data.level,self.data.posi), tag=cc.p(1,1)})
    --exped:setNpc(msg.c.npc,msg.c.show)
    exped:setStar(user.soldierData)
    --[[
    local cellData = gameMap.mapCellDatas[me.getIdByCoord(tag)]  --新增随机事情（宝箱）消耗体力
    local randEvent =nil
    if cellData then
        randEvent = cellData:getEventDef()
    end
    if randEvent and (randEvent.type==5 or randEvent.type==6) then
        exped:setBoosType("randevent")
    else
        exped:setBoosType(self.mbossType)
    end
    ]]
    me.runningScene():addChild(exped, me.MAXZORDER)
    self:close()
end

function conquerConfirm:onEnter()
    
    me.doLayout(self,me.winSize)
end


function conquerConfirm:onExit()
    print("conquerConfirm:onExit()")
end
function conquerConfirm:close()
    self:removeFromParentAndCleanup(true)
    
end

