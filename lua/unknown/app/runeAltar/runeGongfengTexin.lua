runeGongfengTexin = class("runeGongfengTexin",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        return arg[1]:getChildByName(arg[2])
    end
end)
function runeGongfengTexin:create(...)
    local layer = runeGongfengTexin.new(...)
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

function runeGongfengTexin:ctor()
    self.netListener = UserModel:registerLisener( function(msg)
        self:onRevMsg(msg)
    end )
end

function runeGongfengTexin:onEnter()

end

function runeGongfengTexin:onExit()
    UserModel:removeLisener(self.netListener)
end


function runeGongfengTexin:init()
    me.doLayout(self, me.winSize)
    me.registGuiClickEventByName(self, "close", function(node)
        self:removeFromParentAndCleanup(true)
    end )
    
    self.listView1 = me.assignWidget(self, "ListView1")
    self.listView1:setScrollBarWidth(8)
    self.listView1:setScrollBarPositionFromCornerForVertical(cc.p(2, 2))
    self.listView1:removeAllItems()

    self.listView2 = me.assignWidget(self, "ListView2")
    self.listView2:setScrollBarWidth(8)
    self.listView2:setScrollBarPositionFromCornerForVertical(cc.p(2, 2))
    self.listView2:removeAllItems()

    self.listView3 = me.assignWidget(self, "ListView3")
    self.listView3:setScrollBarWidth(8)
    self.listView3:setScrollBarPositionFromCornerForVertical(cc.p(2, 2))
    self.listView3:removeAllItems()

    self.ListItem = me.assignWidget(self, "ListItem")
    return true
end

function runeGongfengTexin:initData(caseIndex, caseTxt)
    local str="未激活"
    me.assignWidget(self, "caseTxt"):setTextColor(cc.c3b(237, 213, 137))
    if caseIndex==user.runeEquipIndex then
        str="激活中"
        me.assignWidget(self, "caseTxt"):setTextColor(cc.c3b(0, 255, 0))
    end
    me.assignWidget(self, "caseTxt"):setString(caseTxt.."("..str..")")
    
    NetMan:send(_MSG.Rune_case_feature(caseIndex))

    if user.runeEquipedRedpoint[caseIndex]==true then
        NetMan:send(_MSG.Rune_texin_redpoint_remove(caseIndex))
        user.runeEquipedRedpoint[caseIndex]=false
    end
end

function runeGongfengTexin:showContent(idList)
    local FeatureCfg = cfg[CfgType.RUNE_FEATURE]
    local listData = {}
    local idType = {}
    for _, v in pairs(FeatureCfg) do
        if idType[v.type]==nil then
            idType[v.type]=0
        end
        if idList[v.id] then
            idType[v.type]=v.id
        end

        if listData[v.type]==nil then
            listData[v.type]={}
        end
        listData[v.type][v.level]=v
    end
    
    for k1, v1 in pairs(listData) do
        for _, v in ipairs(v1) do 
            local listItem = self.ListItem:clone():setVisible(true)
            local conTxt = me.assignWidget(listItem, "conTxt")
            conTxt:setString("LV"..v.level.." "..v.conditionDesc)

            local descTxt = me.assignWidget(listItem, "descTxt")
            descTxt:setString(v.glassDesc)
            
            if idType[k1]>v.id then
                conTxt:setTextColor(cc.c3b(255, 255, 255))
                descTxt:setTextColor(cc.c3b(255, 255, 255))
            elseif idType[k1]==v.id then
                conTxt:setTextColor(cc.c3b(0, 204, 0))
                descTxt:setTextColor(cc.c3b(0, 204, 0))
            else
                conTxt:setTextColor(cc.c3b(125, 125, 125))
                descTxt:setTextColor(cc.c3b(125, 125, 125))
            end

            if k1==1 then --强化
                self.listView1:pushBackCustomItem(listItem)
            elseif k1==2 then --星级
                self.listView2:pushBackCustomItem(listItem)
            elseif k1==3 then --品质
                self.listView3:pushBackCustomItem(listItem)
            end
        end
    end

end

function runeGongfengTexin:onRevMsg(msg)
    if checkMsg(msg.t, MsgCode.RUNE_CASE_FEATURE) then
        local idlist={}
        for _, v in ipairs(msg.c.ids) do
            idlist[v]=1
        end
        self:showContent(idlist)
    end
end
