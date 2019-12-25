-- [Comment]
-- jnmo
hornorLayer = class("hornorLayer", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
hornorLayer.__index = hornorLayer
function hornorLayer:create(...)
    local layer = hornorLayer.new(...)
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
function hornorLayer:ctor()
    print("hornorLayer ctor")
end
function hornorLayer:init()
    print("hornorLayer init")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.MSG_CITY_HONOUR_TECH) then
            self:initWithData(msg.c)
        elseif checkMsg(msg.t, MsgCode.MSG_CITY_HONOUR_TECH_UP_LEVEL) then             
            self.curNode:initWithData(self.curNode.data,self.curNode.need)
            self:initRightInfo()
            self.Text_Hornor:setString("总荣誉:" .. msg.c.totalHonour)
            self.Text_Num1:setString(msg.c.cu)
            self.Text_Num2:setString(msg.c.silver)
            self.Text_Num3:setString(msg.c.gold)
            -- 更新升级按钮的状态
            local techdata = cfg[CfgType.HORNOR_TECH][msg.c.defId]   
            me.setButtonDisable(self.Button_Level,self.curNode.need and techdata.nextid and techdata.nextid > 0 ) 
            -- 更新选择科技的defId
            self.chooseDefid = msg.c.defId
        end
    end )
    self.Text_Hornor = me.assignWidget(self, "Text_Hornor")
    self.Text_Num1 = me.assignWidget(me.assignWidget(self, "num1"), "Text_Num")

    self.Text_Num2 = me.assignWidget(me.assignWidget(self, "num2"), "Text_Num")
    self.Text_Num3 = me.assignWidget(me.assignWidget(self, "num3"), "Text_Num")
    me.registGuiClickEventByName(self, "Button_Tips", function(node)
         showSimpleTips("每升一级荣誉科技会获得1点荣誉，荣誉达到指定数量后将开启指定科技.",node)
    end )
    local function get_call1(node)
         local getWayView = runeGetWayView:create("rune/runeGetWayView.csb")
         me.runningScene():addChild(getWayView, me.MAXZORDER)
         me.showLayer(getWayView, "bg")
         getWayView:setData(959)
    end
    local function get_call2(node)
         local getWayView = runeGetWayView:create("rune/runeGetWayView.csb")
         me.runningScene():addChild(getWayView, me.MAXZORDER)
         me.showLayer(getWayView, "bg")
         getWayView:setData(960)
    end
    local function get_call3(node)
         local getWayView = runeGetWayView:create("rune/runeGetWayView.csb")
         me.runningScene():addChild(getWayView, me.MAXZORDER)
         me.showLayer(getWayView, "bg")
         getWayView:setData(961)
    end
    me.registGuiClickEventByName(me.assignWidget(self, "num1"),"Button_Add",get_call1    )
    me.registGuiClickEventByName(me.assignWidget(self, "num2"),"Button_Add",get_call2)
    me.registGuiClickEventByName(me.assignWidget(self, "num3"),"Button_Add",get_call3)
    self.leftlist = me.assignWidget(self,"leftlist")
    self.rightlist = me.assignWidget(self,"rightlist")
    
    self.Text_Title_Name = me.assignWidget(self,"Text_Title_Name")
    
    self.Button_Level = me.registGuiClickEventByName(self, "Button_Level", function(node)
        local  hornorLevelUp = hornorLevelUp:create("hornorLevelUp.csb")
        local techdata = cfg[CfgType.HORNOR_TECH][self.chooseDefid]
        hornorLevelUp:initWithData(self.chooseIdx,self.chooseDefid)
        me.popLayer(hornorLevelUp)
    end )
    return true
end
function hornorLayer:initRightInfo()
    local techdata = cfg[CfgType.HORNOR_TECH][self.chooseDefid]
    local techId = techdata.techid
    self.Text_Title_Name:setString(techdata.name)
    local ts = {}
    for key, var in pairs(cfg[CfgType.HORNOR_TECH]) do
          if var.techid == techId then
             table.insert(ts,var)
          end
    end
    table.sort(ts,function (a,b)
      return a.level < b . level 
    end)
    local Image_NeedItem = me.assignWidget(self,"Image_NeedItem")
    self.rightlist:removeAllChildren()
    for key, var in pairs(ts) do
         local cell = Image_NeedItem:clone()
         local level = me.assignWidget(cell,"level")
         local num = me.assignWidget(cell,"num")
         local cicon = me.assignWidget(cell,"cicon")
         local per = me.assignWidget(cell,"per")
         level:setString(var.level.."级")
         local baseNeedItemTxts = me.split(var.baseNeedItemTxt,":")
         if baseNeedItemTxts then
              num:setString(baseNeedItemTxts[2])
              cicon:loadTexture(getItemIcon(tonumber( baseNeedItemTxts[1] )) ,me.localType)
         end
         per:setString("+"..var.successtxt)
         me.assignWidget(cell,"cellBg"):setVisible(key%2==0)
         self.rightlist:pushBackCustomItem(cell)
    end 
    self.rightlist:jumpToTop()
end
function hornorLayer:initWithData(data)
    
    self.leftlist:removeAllChildren()
    self.Text_Hornor:setString("总荣誉:" .. data.totalHonour)
    self.Text_Num1:setString(data.cu)
    self.Text_Num2:setString(data.silver)
    self.Text_Num3:setString(data.gold)
    local globals = me.createNode("Node_HornorItem.csb")
    self.chooseIdx = 1 * 10 + 1
    local function choose_call(node)
        if node.chooseIdx ~= self.chooseIdx then
            me.dispatchCustomEvent("hornorCellItem_Choose", node.chooseIdx)
            self.chooseIdx = node.chooseIdx
            self.chooseDefid = node.defid
            self:initRightInfo()
            self.curNode  = node 
            me.setButtonDisable(self.Button_Level,node.need and cfg[CfgType.HORNOR_TECH][self.chooseDefid].nextid > 0 )
        end
    end
    for key, var in pairs(data.rankList) do
        local item = me.assignWidget(globals, "hornorItem"):clone()
        local Text_NeedNum = me.assignWidget(item, "Text_NeedNum")
        local techList = var.techList
        if key == 1 then
            Text_NeedNum:setVisible(false)
            me.assignWidget(item,"Text_13"):setVisible(false)
            me.assignWidget(item,"Text_13_1"):setVisible(false)
        else
            Text_NeedNum:setString(var.rankNeed)
        end
        me.assignWidget(item,"hornorItembg"):setVisible(key%2==0)
        table.sort(techList, function(a, b)
            return cfg[CfgType.HORNOR_TECH][a.defId].sort < cfg[CfgType.HORNOR_TECH][b.defId].sort
        end )
        for k, v in pairs(techList) do
            local cur = hornorCellItem:create(item, "item_bg" .. k)
            cur:initWithData(v,data.totalHonour >= var.rankNeed)
            cur.chooseIdx = key * 10 + k
            me.registGuiClickEvent(cur, choose_call)
            if self.chooseIdx == cur.chooseIdx then
                 self.chooseDefid = v.defId
                 self.curNode  = cur 
            end
        end
         self.leftlist:pushBackCustomItem(item)
    end
    self:initRightInfo()
    me.setButtonDisable(self.Button_Level,cfg[CfgType.HORNOR_TECH][self.chooseDefid].nextid > 0 )
    me.dispatchCustomEvent("hornorCellItem_Choose", self.chooseIdx)
end
function hornorLayer:onEnter()
    print("hornorLayer onEnter")
    me.doLayout(self, me.winSize)
end
function hornorLayer:onEnterTransitionDidFinish()
    print("hornorLayer onEnterTransitionDidFinish")
end
function hornorLayer:onExit()
    print("hornorLayer onExit")
    UserModel:removeLisener(self.modelkey)
end
function hornorLayer:close()
    self:removeFromParent()
end

