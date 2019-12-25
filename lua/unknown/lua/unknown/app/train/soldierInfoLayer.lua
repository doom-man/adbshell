-- 士兵详情介绍界面
soldierInfoLayer = class("soldierInfoLayer", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
soldierInfoLayer.__index = soldierInfoLayer
soldierBigType = {
    ["1"] = "步兵",
    ["2"] = "骑兵",
    ["3"] = "弓兵",
    ["4"] = "车兵",
    ["99"] = "陷阱",
}
soldierType = {
    ["11"] = "剑兵",
    ["12"] = "枪兵",
    ["13"] = "勇士",
    ["21"] = "游骑",
    ["22"] = "骑士",
    ["23"] = "异骑",
    ["31"] = "射击",
    ["32"] = "投掷",
    ["33"] = "骑射",
    ["34"] = "枪火",
    ["41"] = "投石",
    ["42"] = "冲车",
    ["43"] = "火炮",
    ["9901"] = "落石",
    ["9902"] = "火箭",
    ["9903"] = "滚木",
}
function soldierInfoLayer:create(...)
    local layer = soldierInfoLayer.new(...)
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
function soldierInfoLayer:ctor()
    print("soldierInfoLayer ctor")
   
end
function soldierInfoLayer:init()
    print("soldierInfoLayer init")
    -- 注册点击事件
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    self.title = me.assignWidget(self, "title")
    self.s_icon = me.assignWidget(self, "s_icon")
    self.s_num = me.assignWidget(self, "s_num")
    self.s_reduce = me.assignWidget(self, "s_reduce")
    self.att = me.assignWidget(self, "att")
    self.def = me.assignWidget(self, "def")
    self.hp = me.assignWidget(self, "hp")
    self.att_add = me.assignWidget(self, "att_add")
    self.def_add = me.assignWidget(self, "def_add")
    self.hp_add = me.assignWidget(self, "hp_add")
    self.speed = me.assignWidget(self, "speed")
    self.weight = me.assignWidget(self, "weight")
    self.range = me.assignWidget(self, "range")
    self.skill_panel = me.assignWidget(self, "skill_panel")
    self.s_type = me.assignWidget(self, "s_type")
    self.s_type_label = me.assignWidget(self,"s_type_label")
    return true
end
function soldierInfoLayer:onEnter()
    print("soldierInfoLayer onEnter")
    me.doLayout(self, me.winSize)
end
function soldierInfoLayer:initWithData(data,filter,pBool)
    local function getNumByType(num_)
        local tmp = num_
        if me.toNum(data.bigType) == 99 and me.toNum(num_) == 0 then
            tmp = "-"
        end
        return tmp
    end

    self.data = data
    self.filter = filter
    me.LogTable(data,"soldierInfoLayer ---------------------")
    self.title:setString(data.name)
    self.s_icon:loadTexture(soldierIcon(data), me.plistType)
    self.s_type:setString(soldierType[me.toStr(data.smallType)])
    --1000 9000
    self.att:setString(getNumByType(data.attack))
    self.def:setString(getNumByType(data.defense))
    self.hp:setString(getNumByType(data.hp))
    local sum_att = 0 
    local sum_def = 0 
    local sum_hp = 0 
    if data.bigType == 1 then
        if data.id > 1000 and data.id < 9000 then
            sum_att = sum_att + (user.propertyValue["AtkBigType6Plus"] or 0)     
            sum_def = sum_def + (user.propertyValue["DefBigType6Plus"] or 0)
            sum_hp = sum_hp + (user.propertyValue["HpBigType6Plus"] or 0)     
        end
        sum_att = sum_att + (user.propertyValue["AtkBigType5Plus"] or 0)     
        sum_def = sum_def + (user.propertyValue["DefBigType5Plus"] or 0)
        sum_hp = sum_hp + (user.propertyValue["HpBigType5Plus"] or 0)    

        sum_att = sum_att + (user.propertyValue["AtkBigType1Plus"] or 0)     
        sum_def = sum_def + (user.propertyValue["DefBigType1Plus"] or 0)
        sum_hp = sum_hp + (user.propertyValue["HpBigType1Plus"] or 0)            
    elseif data.bigType == 2 then
        if data.id > 1000 and data.id < 9000 then
            sum_att = sum_att + (user.propertyValue["AtkBigType6Plus"] or 0)     
            sum_def = sum_def + (user.propertyValue["DefBigType6Plus"] or 0)
            sum_hp = sum_hp + (user.propertyValue["HpBigType6Plus"] or 0)     
        end
        sum_att = sum_att + (user.propertyValue["AtkBigType5Plus"] or 0)     
        sum_def = sum_def + (user.propertyValue["DefBigType5Plus"] or 0)
        sum_hp = sum_hp + (user.propertyValue["HpBigType5Plus"] or 0)    

        sum_att = sum_att + (user.propertyValue["AtkBigType2Plus"] or 0)     
        sum_def = sum_def + (user.propertyValue["DefBigType2Plus"] or 0)
        sum_hp = sum_hp + (user.propertyValue["HpBigType2Plus"] or 0)            
    elseif data.bigType == 3 then
        if data.id > 1000 and data.id < 9000 then
            sum_att = sum_att + (user.propertyValue["AtkBigType6Plus"] or 0)     
            sum_def = sum_def + (user.propertyValue["DefBigType6Plus"] or 0)
            sum_hp = sum_hp + (user.propertyValue["HpBigType6Plus"] or 0)     
        end
        sum_att = sum_att + (user.propertyValue["AtkBigType5Plus"] or 0)     
        sum_def = sum_def + (user.propertyValue["DefBigType5Plus"] or 0)
        sum_hp = sum_hp + (user.propertyValue["HpBigType5Plus"] or 0)    

        sum_att = sum_att + (user.propertyValue["AtkBigType3Plus"] or 0)     
        sum_def = sum_def + (user.propertyValue["DefBigType3Plus"] or 0)
        sum_hp = sum_hp + (user.propertyValue["HpBigType3Plus"] or 0)            
    elseif data.bigType == 4 then
        if data.id > 1000 and data.id < 9000 then
            sum_att = sum_att + (user.propertyValue["AtkBigType6Plus"] or 0)     
            sum_def = sum_def + (user.propertyValue["DefBigType6Plus"] or 0)
            sum_hp = sum_hp + (user.propertyValue["HpBigType6Plus"] or 0)     
        end
        sum_att = sum_att + (user.propertyValue["AtkBigType5Plus"] or 0)     
        sum_def = sum_def + (user.propertyValue["DefBigType5Plus"] or 0)
        sum_hp = sum_hp + (user.propertyValue["HpBigType5Plus"] or 0)    

        sum_att = sum_att + (user.propertyValue["AtkBigType4Plus"] or 0)     
        sum_def = sum_def + (user.propertyValue["DefBigType4Plus"] or 0)
        sum_hp = sum_hp + (user.propertyValue["HpBigType4Plus"] or 0)            
    end
    self.att_add:setString("+".. sum_att)
    self.att_add:setVisible(sum_att>0)
    self.def_add:setString("+"..sum_def)
    self.def_add:setVisible(sum_def>0)
    self.hp_add:setString("+"..sum_hp)
    self.hp_add:setVisible(sum_hp>0)
    self.speed:setString(getNumByType(data.speed))
    self.weight:setString(getNumByType(data.carry))
    self.range:setString(getNumByType(data.atkRange))
    
    if me.toNum(data.bigType) == 99 then
        self.s_type_label:setString("陷阱类型")
        self.s_icon:setVisible(true)
    else
        self.s_type_label:setString("兵种类型")
--        self.s_icon:setVisible(false)
--        local sani =  soldierMoudle:createSoldierById(data.id)
--        sani:doAction(MANI_STATE_IDLE,DIR_LEFT_BOTTOM)
--        me.assignWidget(self,"s_bg"):addChild(sani)
--        sani:setTag(0xff2321)
--        sani:setScale(1.3)
--        sani:setPosition(115,100)    
    end
    if filter == nil then
        self.s_num:setVisible(false)
    else
        self.s_num:setString(filter["num"])
        self.s_num:setVisible(true)
    end
    if pBool == nil then
      me.assignWidget(self,"Text_17"):setString("拥有")
    else
      me.assignWidget(self,"Text_17"):setString("购买")
    end
    local skillcfg = me.split(data.skill,",")
    local ofx = 40
    local ofw = 15
    local ofh = 25
    local ofy = self.skill_panel:getContentSize().height - 10
    if skillcfg then
        --me.LogTable(skillcfg,"da-------------")
        for key, var in pairs(skillcfg) do
            local skilldata = cfg[CfgType.CFG_SOLDIER_SKILL][me.toNum(var)]
            local sname = ccui.Text:create(skilldata.name,"",22)
            sname:setPosition(ofx, ofy - sname:getContentSize().height/2)
            sname:setColor(cc.c3b(255,194,98))
            self.skill_panel:addChild(sname)
            local sinfo = ccui.Text:create(skilldata.desc,"",22)
            me.putNodeOnRight(sname,sinfo,ofw,cc.p(0,2))
            self.skill_panel:addChild(sinfo)
            ofy = ofy - ofh - sname:getContentSize().height/2
        end           
    end
end
function soldierInfoLayer:onExit()
    print("soldierInfoLayer onExit")
end
function soldierInfoLayer:close()
    -- me.hideLayer(self,true,"shopbg")
    self:removeFromParentAndCleanup(true)
end