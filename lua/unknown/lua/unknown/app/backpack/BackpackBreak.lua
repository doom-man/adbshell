BackpackBreak = class("BackpackBreak",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
function BackpackBreak:create(...)
    local layer = BackpackBreak.new(...)
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

function BackpackBreak:ctor()
end

function BackpackBreak:onEnter()
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end )
end

function BackpackBreak:onEnterTransitionDidFinish()
end

function BackpackBreak:onExit()
    UserModel:removeLisener(self.modelkey)
end

function BackpackBreak:update(msg)
    if checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM_ADD) then
        self:getGoodsAnimation(msg)
    elseif checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM_CHANGE) then
        self:getGoodsAnimation(msg)
    elseif checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM_BREAK) then 
        showTips("分解成功")   
        self.requestFlag=false
        disWaitLayer()
        self:removeFromParent()
    end
end

function BackpackBreak:getGoodsAnimation(msg)
    local i = { }
    i[#i + 1] = { }
    i[#i]["defId"] = msg.c.iteminfo["defId"]
    local itemCfg = self.itemData:getDef()
    local cailiaoList = string.split(itemCfg.breakEffect,",")
    local cailiaoData = string.split(cailiaoList[1],":")
    i[#i]["itemNum"] = cailiaoData[2]
    i[#i]["needColorLayer"] = true
    getItemAnim(i)
end

function BackpackBreak:init()
    print("BackpackBreak init")
    me.doLayout(self, me.winSize)
    me.registGuiClickEventByName(self, "close", function(node)
        self:removeFromParentAndCleanup(true)
    end )

    self.itemIcon = BackpackCell:create("backpack/backpackcell.csb")
    self.itemIcon:setPosition(345, 128)
    me.assignWidget(self, "box"):addChild(self.itemIcon)

    self.cailiaoItem = me.assignWidget(self, "cailiaoItem")
    self.itemNode = me.assignWidget(self, "itemNode")
    self.detailBox = me.assignWidget(self, "detailBox")

    self.requestFlag=false
    me.registGuiClickEventByName(self, "btn_takeoff", function(sender)
        local function continue(str)
            if str=="ok" and self.requestFlag==false then
                self.requestFlag=true
                NetMan:send(_MSG.itemBreak(self.itemData.uid, 1))
                showWaitLayer()
            end
        end
        me.showMessageDialog("确认分解吗？", continue)
    end )

    return true
end



function BackpackBreak:setItemData(itemData)
    self.itemData = itemData
    print(itemData)
    self:updateBreakView()
end


function BackpackBreak:cailiaoTouch(node, event)  
    if event == ccui.TouchEventType.began then
        self.detailBox:setVisible(true)
        self.detailBox:setPositionX(node:getPositionX())

        local etc = cfg[CfgType.ETC][me.toNum(node["itemId"])]
        me.assignWidget(self.detailBox, "cailiaoIcon"):loadTexture(getItemIcon(node["itemId"]), me.localType)
        me.assignWidget(self.detailBox, "cailiaoNums"):setString(node["nums"])
        me.assignWidget(self.detailBox, "nameTxt"):setString(etc.name)

    elseif event == ccui.TouchEventType.ended or event == ccui.TouchEventType.canceled then
        self.detailBox:setVisible(false)
    end
end

function BackpackBreak:updateBreakView ()
    local itemCfg = self.itemData:getDef()

    self.itemIcon:setUI(self.itemData)

    local cailiaoList = string.split(itemCfg.breakEffect,",")
    local count=0
    for i, v in ipairs(cailiaoList) do
        local cailiaoData = string.split(v,":")
        local cailiaoItem = self.cailiaoItem:clone():setVisible(true)
        local etc = cfg[CfgType.ETC][me.toNum(cailiaoData[1])]
        me.assignWidget(cailiaoItem, "cailiaoIcon"):loadTexture(getItemIcon(cailiaoData[1]), me.localType)
        me.assignWidget(cailiaoItem, "cailiaoNums"):setString(cailiaoData[2])
        cailiaoItem["nums"]=cailiaoData[2]
        cailiaoItem["itemId"]=cailiaoData[1]
        cailiaoItem:setPosition(count*93, 0)
        me.registGuiTouchEvent(cailiaoItem, handler(self, self.cailiaoTouch))
        self.itemNode:addChild(cailiaoItem)
        count=count+1
    end
    self.itemNode:setPositionX((855-count*93)/2)
end
