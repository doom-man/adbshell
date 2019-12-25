--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion
runeMaterialStyle = class("runeMaterialStyle", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
runeMaterialStyle.__index = runeMaterialStyle

function runeMaterialStyle:create(...)
    local layer = runeMaterialStyle.new(...)
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

function runeMaterialStyle:ctor()
    self.netListener = UserModel:registerLisener( function(msg)
        if checkMsg(msg.t, MsgCode.RUNE_COMPOUND_STYLE) then
            self:close()
        end
    end )
end



function runeMaterialStyle:init()
    
    for i=1, 5 do
        local p = me.assignWidget(me.assignWidget(self, "cell"..i), "panel")
        p.id=i
        me.registGuiClickEvent(p, handler(self, self.clickCheck))
        me.assignWidget(p,"cbox"):setTouchEnabled(false)
    end
    self.closeBtn = me.registGuiClickEventByName(self, "close", function(node)
        me.DelayRun(function (args)
           self:close()
        end)
    end)
    me.registGuiClickEventByName(self, "okBtn", handler(self, self.ok))

    return true
end


function runeMaterialStyle:setData(data)
    self.data=data
    local index=1
    local defId = data.defid
    local count = data.count
    while(true)
    do
        
        local hcCfg = cfg[CfgType.RUNE_MAP][defId]
        if hcCfg==nil or hcCfg.destID=='' or hcCfg.destID==0 then
            break
        end

        local hcCfg1 = cfg[CfgType.RUNE_MAP][hcCfg.destID]
        local tmp = string.split(hcCfg1.needItem, ":")
        tmp[1] = tonumber(tmp[1])
        tmp[2] = tonumber(tmp[2])

        if count<tmp[2] then
            break
        end

        local p = me.assignWidget(self, "cell"..index)
        p:setVisible(true)
        count = math.floor(count/tmp[2])

        me.assignWidget(p, "panel").defId=hcCfg.destID

        me.assignWidget(p, "cailiao"):loadTexture(getItemIcon(hcCfg.destID), me.localType)
        me.assignWidget(p, "Text_9"):setString(count)
        local baseData = cfg[CfgType.ETC][hcCfg.destID]
        me.assignWidget(p, "nameTxt"):setString(baseData.name)

        count = self:getMtNums(hcCfg.destID)+count
        defId=hcCfg.destID
        index=index+1
    end
    for i=index, 5 do
        local p = me.assignWidget(self, "cell"..i)
        p:setVisible(false)
    end

    if index==1 then
        me.assignWidget(self, "tips"):setVisible(true)
    else
        me.assignWidget(self, "tips"):setVisible(false)
    end
end


---
-- 查找指定材料个数
--
function runeMaterialStyle:getMtNums(id)
    local count=0
    for key, var in pairs(user.materBackpack) do
        --print("var.defid = "..var.defid)
        if tonumber(var.defid) == tonumber(id) then
            count=count+var.count
        end
    end
    return count
end

function runeMaterialStyle:ok()
    for i=1, 5 do
        local p = me.assignWidget(me.assignWidget(self, "cell"..i), "panel")
        local checkBox = me.assignWidget(p, "cbox")
        if checkBox:isSelected() then
            print(i)
            NetMan:send(_MSG.Prop_compound_style(self.data.defid ,self.data.count, p.defId))
            showWaitLayer()
            return
        end
    end
    showTips("选择合成的材料")
end

function runeMaterialStyle:clickCheck(node)
    id = node.id
    for i=1, 5 do
        local p = me.assignWidget(me.assignWidget(self, "cell"..i), "panel")
        local checkBox = me.assignWidget(p, "cbox")
        checkBox:setSelected(false)
        if i==id then
            checkBox:setSelected(true)
        end
    end
end

function runeMaterialStyle:onEnter()
    
    me.doLayout(self,me.winSize)
end


function runeMaterialStyle:onExit()
    print("runeMaterialStyle:onExit()")
    UserModel:removeLisener(self.netListener)
end
function runeMaterialStyle:close()
    self:removeFromParentAndCleanup(true)
    
end

