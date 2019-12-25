-- [Comment]
-- jnmo
defSoldierAutoFillRecord = class("defSoldierAutoFillRecord", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
defSoldierAutoFillRecord.__index = defSoldierAutoFillRecord
function defSoldierAutoFillRecord:create(...)
    local layer = defSoldierAutoFillRecord.new(...)
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
function defSoldierAutoFillRecord:ctor()
    print("defSoldierAutoFillRecord ctor")
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.MSG_GUARD_AUTOFILL_RECORD) then
              self:initLog(msg.c.list)
        end
    end )
end


function defSoldierAutoFillRecord:init()
    print("defSoldierAutoFillRecord init")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    return true
end


---
-- 初始化补兵日志
--
function defSoldierAutoFillRecord:initLog(data)
    self.ListView:removeAllChildren()
    local index = 1
    for inKey, inVar in ipairs(data) do
        local cItem = self.logcell:clone():setVisible(true)
        local descTxt = me.assignWidget(cItem, "descTxt")
        local descTxt1 = me.assignWidget(cItem, "descTxt1")
        
        self.ListView:pushBackCustomItem(cItem)
        index = index + 1
        local itemPng = "ui_ty_cell_bg.png"
        if index % 2 == 0 then
            itemPng = "alliance_alpha_bg.png"
        end

        local timeObj = os.date("*t", inVar.time)
        local str = timeObj.month.."月" .. timeObj.day.."日 "..timeObj.hour..":" .. timeObj.min.."  "
        if inVar.id==11 then
            str=str.."内城兵力不足，无法补充兵力"
        elseif inVar.id==12 then
            str=str.."禁卫军数量超过上限，无法补充兵力"
        else
            str=str.."自动补充："
            for k, v in ipairs(inVar.record) do
                local soldierData =  cfg[CfgType.CFG_SOLDIER][tonumber(v[1])]
                str=str..soldierData.name.."x"..v[2]..","
            end
            str = string.sub(str,1,string.len(str)-1)
            --str=str.." 至禁卫军"
        end
        descTxt:setString(str)
        --descTxt1:setString(str)
        local w = descTxt1:getContentSize().width
        if w>737 then
            cItem:setContentSize(cc.size(748, 70))
            descTxt:setPositionY(50)
        end
        cItem:loadTexture(itemPng, me.localType)
    end
end

function defSoldierAutoFillRecord:onEnter()
    print("defSoldierAutoFillRecord onEnter")
    self.ListView = me.assignWidget(self, "ListView")
    self.logcell = me.assignWidget(self, "logcell")
    me.doLayout(self, me.winSize)
end
function defSoldierAutoFillRecord:onEnterTransitionDidFinish()
    print("defSoldierAutoFillRecord onEnterTransitionDidFinish")
end
function defSoldierAutoFillRecord:onExit()
    UserModel:removeLisener(self.modelkey)
end
function defSoldierAutoFillRecord:close()
    self:removeFromParent()
end


