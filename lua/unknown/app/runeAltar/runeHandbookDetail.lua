local runeHandbookItem = class("runeHandbookItem",function (...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        return arg[1]
    end
end)
function runeHandbookItem:create(...)
    local layer = runeHandbookItem.new(...)
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

function runeHandbookItem:ctor()

end

function runeHandbookItem:onEnter()

end

function runeHandbookItem:onExit()

end

function runeHandbookItem:init()
    self.icon = me.assignWidget(self, "icon")
    self.box = me.assignWidget(self, "box")
    self.lvBox = me.assignWidget(self, "lvBox")
    self.lvBox:setVisible(false)
    self.typeBox = me.assignWidget(self, "typeBox")
    self.typeBox:setVisible(true)
    self.typeIco = me.assignWidget(self, "typeIco")
    self.nameBox = me.assignWidget(self, "nameBox")
    self.nameBox:setVisible(false)

    self.starNode = me.assignWidget(self, "starNode")
    self.star = me.assignWidget(self, "star")

    return true
end

function runeHandbookItem:setData(data)
    self.data=data
    local runeData= data.data
    self.icon:loadTexture(getRuneIcon(runeData.icon), me.plistType)
    self.box:loadTexture("levelbox"..runeData.level..".png", me.plistType)
    --self.nameTxt:setString(self.data.name)
    self.typeIco:loadTexture("rune_type_"..runeData.type..".png",me.plistType)
    self.typeBox:loadTexture("levelbox"..runeData.level.."_c2.png", me.plistType)
    
    
    self.starNode:removeAllChildren()
    if data.star~=nil then
        local starNums = data.star
        for i=1, starNums ,1 do 
            local star = self.star:clone():setVisible(true)
            star:setPositionX((i-1)*36)
            self.starNode:addChild(star)
        end
        self.starNode:setPositionX((357-starNums*36)/2)
    end

    if data.star~=nil then
       me.Helper:normalImageView(self.icon) 
       me.Helper:normalImageView(self.box)
       me.Helper:normalImageView(self.typeIco)
       me.Helper:normalImageView(self.typeBox)
       --self.nameTxt:setTextColor(cc.c3b(212,205,185))
       --self.lvTxt:setTextColor(cc.c3b(255,255,255))
       --me.Helper:normalImageView(self.typeIco)
    else
       me.Helper:grayImageView(self.icon) 
       me.Helper:grayImageView(self.box)
       me.Helper:grayImageView(self.typeIco)
       me.Helper:grayImageView(self.typeBox)
       --self.nameTxt:setTextColor(cc.c3b(112,109,99))
       --self.lvTxt:setTextColor(cc.c3b(112,109,99))
       --me.Helper:grayImageView(self.typeIco)
    end
end


runeHandbookDetail = class("runeHandbookDetail",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        return arg[1]:getChildByName(arg[2])
    end
end)
function runeHandbookDetail:create(...)
    local layer = runeHandbookDetail.new(...)
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

function runeHandbookDetail:ctor()
end

function runeHandbookDetail:onEnter()
    self.netListener = UserModel:registerLisener( function(msg)
        self:onRevMsg(msg)
    end )
end

function runeHandbookDetail:onExit()
    UserModel:removeLisener(self.netListener)
end

function runeHandbookDetail:onRevMsg(msg)
    
end

function runeHandbookDetail:init()
    print("runeHandbookDetail init")
    me.doLayout(self, me.winSize)
    me.registGuiClickEventByName(self, "close", function(node)
        self:removeFromParentAndCleanup(true)
    end )
    -- 符文icon
    self.runeIcon = runeHandbookItem:create(me.assignWidget(self, "runeIcon"), 1) 

    self.nameTxt = me.assignWidget(self, "nameTxt")

    --圣物合成
    me.registGuiClickEventByName(me.assignWidget(self, "cell1"), "btn_goto", function(node)
        if self.runeInfo.star~=nil then
            local rune_view = runeComposeView2nd:create("runeComposeView2nd.csb")
            me.runningScene():addChild(rune_view,me.MAXZORDER)
            me.showLayer(rune_view,"bg_frame")
            rune_view:setData(self.runeInfo.data)
            rune_view:setParentView(self)
        else
            local runeAltar = runeAltarView:create("rune/runeAltarView.csb",5 , 1)
            me.runningScene():addChild(runeAltar, me.MAXZORDER)
            me.showLayer(runeAltar,"bg")
        end
    end)
    
    --搜索圣物
    me.registGuiClickEventByName(me.assignWidget(self, "cell2"), "btn_goto", function(node)
        local runesearch = runeSearch:create("rune/runeSearch.csb")
        me.runningScene():addChild(runesearch, me.MAXZORDER)
        me.showLayer(runesearch,"bg")
    end)

    --活动获得
    me.registGuiClickEventByName(me.assignWidget(self, "cell3"), "btn_goto", function(node)
        local promotionView = promotionView:create("promotionView.csb")
        promotionView:setViewTypeID(1)
        me.runningScene():addChild(promotionView, me.MAXZORDER)
        me.showLayer(promotionView, "bg_frame")
    end)

    return true
end


function runeHandbookDetail:setData(runeInfo)
    self.runeInfo = runeInfo
    self.runeIcon:setData(runeInfo)
    self.nameTxt:setString(runeInfo.data.name)
    if runeInfo.star~=nil then
        me.assignWidget(self,"activeTxt"):setString("图鉴已开启")
    else
        me.assignWidget(self,"activeTxt"):setString("图鉴未开启")
    end
end
