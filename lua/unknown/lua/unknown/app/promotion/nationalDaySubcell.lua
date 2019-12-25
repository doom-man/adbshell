nationalDaySubcell = class("nationalDaySubcell",function(...)
    return cc.CSLoader:createNode(...)
end)
nationalDaySubcell.__index = nationalDaySubcell
function nationalDaySubcell:create(...)
    local layer = nationalDaySubcell.new(...)
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

function nationalDaySubcell:ctor()
    print("nationalDaySubcell:ctor()")
end
function nationalDaySubcell:init()
    print("nationalDaySubcell:init()")

    self.ScrollView_item = me.assignWidget(self,"ScrollView_item")
    self.Node_richDetail = me.assignWidget(self,"Node_richDetail")
    self.ImageTitles = {}
    self.ImageTitles[#self.ImageTitles+1] = me.assignWidget(self,"Image_pu")
    self.ImageTitles[#self.ImageTitles+1] = me.assignWidget(self,"Image_tian")
    self.ImageTitles[#self.ImageTitles+1] = me.assignWidget(self,"Image_tong")
    self.ImageTitles[#self.ImageTitles+1] = me.assignWidget(self,"Image_qing")
    self.Text_countDown = me.assignWidget(self,"Text_countDown")
    return true
end

function nationalDaySubcell:setCellData(node,data)
    local function getTagetNeed(id)
        for key, var in pairs(user.activityDetail.needs) do
            if me.toNum(var.id) == me.toNum(id) then
                return var.num
            end
        end
    end

    local function getMinScore(ids)
        local minScore = nil
        for key, var in pairs(ids) do
            if minScore == nil then
                minScore = getTagetNeed(var)
            else
                minScore = math.min(minScore,getTagetNeed(var))
            end
        end
        return minScore
    end

    local Text_title = me.assignWidget(node,"Text_title")
    local Button_item = me.assignWidget(node,"Button_item")
    local Text_haveNum = me.assignWidget(node,"Text_haveNum")
    local Button_charge = me.assignWidget(node,"Button_charge")
    local def = cfg[CfgType.ETC][data.id]
    Text_title:setString(def.name)
    Button_item:loadTextureNormal(getItemIcon(def.id),me.localType)
    Button_item:loadTexturePressed(getItemIcon(def.id),me.localType)
    local currentScore = getMinScore(data.need)
    Text_haveNum:setString(currentScore)
    me.registGuiClickEvent(Button_item,function ()
        local gdc = giftDetailCell:create("giftDetailCell.csb")
        gdc:setItemData(def.useEffect)
        me.runningScene():addChild(gdc,me.MAXZORDER)                        
    end)
    me.registGuiClickEvent(Button_charge,function ()
        NetMan:send(_MSG.updateActivityDetail(user.activityDetail.activityId,data.id))
    end)

    me.buttonState(Button_charge,me.toNum(currentScore) > 0)
    me.assignWidget(node,"Image_HaveNum"):setVisible(me.toNum(currentScore) > 0)
    if me.toNum(currentScore) > 0 then
        Button_charge:setTitleColor(COLOR_WHITE)
    else
        Button_charge:setTitleColor(COLOR_GRAY)
    end
end
function nationalDaySubcell:initScrollData()
    self.ScrollView_item:removeAllChildren()
    local items = user.activityDetail.items
    self.ScrollView_item:setInnerContainerSize(cc.size(225*#items,270))
    for key, var in pairs(items) do
        local panel = me.assignWidget(self,"Panel_item"):clone()
        panel:setVisible(true)
        self.ScrollView_item:addChild(panel)
        panel:setPosition((me.toNum(key)-1)*275,0)
        self:setCellData(panel,var)
    end
    self.ScrollView_item:jumpToLeft()
end

function nationalDaySubcell:onEnter()
    print("nationalDaySubcell:onEnter()")
--    if user.activityDetail.activityId == ACTIVITY_ID_NATIONALDAY
--        and user.UI_REDPOINT.promotionBtn[tostring(ACTIVITY_ID_NATIONALDAY)] == 1 then
--        -- 移除红点
--        removeRedpoint(ACTIVITY_ID_NATIONALDAY)
--    end
--    if user.activityDetail.activityId == ACTIVITY_ID_MID_AUTUMN_BLESS
--        and user.UI_REDPOINT.promotionBtn[tostring(ACTIVITY_ID_MID_AUTUMN_BLESS)] == 1 then
--        -- 移除红点
--        removeRedpoint(ACTIVITY_ID_MID_AUTUMN_BLESS)
--    end
    removeRedpoint(user.activityDetail.activityId)
    me.doLayout(self,me.winSize)  
    self:setNeedsScore()
    self:initScrollData()
    self.modelkey = UserModel:registerLisener(function(msg) -- 注册消息通知
        if checkMsg(msg.t, MsgCode.ACTIVITY_UPDATE_DETAIL) then
            if msg.c.activityId == ACTIVITY_ID_NATIONALDAY or msg.c.activityId == ACTIVITY_ID_GIFT_NEWYEAR
                or msg.c.activityId == ACTIVITY_ID_MID_AUTUMN_BLESS then
                self:setNeedsScore()
                self:initScrollData()
            end
        end
    end)

    local cfg = cfg[CfgType.ACTIVITY_LIST][me.toNum(user.activityDetail.activityId)]
    local rt = mRichText:create(cfg.desc,640)
    rt:setPosition(0,0)
    rt:setAnchorPoint(cc.p(0,1))
    self.Node_richDetail:addChild(rt)
    self.Text_countDown:setString(me.GetSecTime(user.activityDetail.openDate) .. "-" .. me.GetSecTime(user.activityDetail.endDate))
end

function nationalDaySubcell:setNeedsScore()
    for key, var in pairs(user.activityDetail.needs) do
        local ImageTitles = self.ImageTitles[key]
        if ImageTitles then
            me.assignWidget(ImageTitles,"Text_score"):setString(var.num)
        end
    end

    if user.activityDetail.activityId == ACTIVITY_ID_NATIONALDAY then
        me.assignWidget(self,"Image_pu"):loadTexture("huodong_guoqing_zi_pu.png",me.localType)
        me.assignWidget(self,"Image_tian"):loadTexture("huodong_guoqing_zi_tian.png",me.localType)
        me.assignWidget(self,"Image_tong"):loadTexture("huodong_guoqing_zi_tong.png",me.localType)
        me.assignWidget(self,"Image_qing"):loadTexture("huodong_guoqing_zi_le.png",me.localType)
    elseif user.activityDetail.activityId == ACTIVITY_ID_GIFT_NEWYEAR then
        me.assignWidget(self,"Image_pu"):loadTexture("huodong_yuandan_zi_yuan.png",me.localType)
        me.assignWidget(self,"Image_tian"):loadTexture("huodong_yuandan_zi_dan.png",me.localType)
        me.assignWidget(self,"Image_tong"):loadTexture("huodong_yuandan_zi_kuai.png",me.localType)
        me.assignWidget(self,"Image_qing"):loadTexture("huodong_yuandan_zi_le.png",me.localType)
    elseif user.activityDetail.activityId == ACTIVITY_ID_MID_AUTUMN_BLESS then
        me.assignWidget(self,"Image_pu"):loadTexture("huodong_zhongqiu_zi_zhong.png",me.localType)
        me.assignWidget(self,"Image_tian"):loadTexture("huodong_zhongqiu_zi_qiu.png",me.localType)
        me.assignWidget(self,"Image_tong"):loadTexture("huodong_zhongqiu_zi_kuai.png",me.localType)
        me.assignWidget(self,"Image_qing"):loadTexture("huodong_zhongqiu_zi_le.png",me.localType)
    end
end

function nationalDaySubcell:onExit()
    print("nationalDaySubcell:onExit()")
    UserModel:removeLisener(self.modelkey) -- 删除消息通知
end
