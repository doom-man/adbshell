-- [Comment]
-- jnmo
monthCardCell = class("monthCardCell", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
monthCardCell.__index = monthCardCell
function monthCardCell:create(...)
    local layer = monthCardCell.new(...)
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
MONTH_CARD_KIND_MONTH = 7 -- 经典月卡
MONTH_CARD_KIND_NEW = 301 -- 新人周卡
MONTH_CARD_KIND_HOT = 302 -- 超值周卡
MONTH_CARD_KIND_WUNDER = 303 -- 奇迹周卡
MONTH_CARD_KIND_NEW1 = 304 -- 奇迹周卡
MONTH_CARD_KIND_NEW2 = 305 -- 奇迹周卡
MONTH_CARD_KIND_NEW3 = 306 -- 奇迹周卡
local CARD_RES = {
    [MONTH_CARD_KIND_MONTH] = { icon = "huodong_yueka_ka2.png", name = "huodong_yueka_jingdian.png" },
    [MONTH_CARD_KIND_NEW] = { icon = "huodong_yueka_ka4.png", name = "huodong_yueka_ziyuanzhouka.png" },
    [MONTH_CARD_KIND_HOT] = { icon = "huodong_yueka_ka1.png", name = "huodong_yueka_chaozhizhouka.png" },
    [MONTH_CARD_KIND_WUNDER] = { icon = "huodong_yueka_ka3.png", name = "huodong_yueka_qijizhouka.png" },
    [MONTH_CARD_KIND_NEW1] = { icon = "huodong_yueka_ka4.png", name = "huodong_yueka_ziyuanzhouka.png" },
    [MONTH_CARD_KIND_NEW2] = { icon = "huodong_yueka_ka1.png", name = "huodong_yueka_chaozhizhouka.png" },
    [MONTH_CARD_KIND_NEW3] = { icon = "huodong_yueka_ka3.png", name = "huodong_yueka_qijizhouka.png" },
}
function monthCardCell:ctor()
    print("monthCardCell ctor")
    self.selectIndex = 1
end
function monthCardCell:init()
    print("monthCardCell init")
    self.Button_buy = me.registGuiClickEventByName(self, "Button_buy", function(node)
            payMgr:getInstance():checkChooseIap(node.buyData) 
            me.setWidgetCanTouchDelay(node,1) 
    end )
    self.Button_Get = me.registGuiClickEventByName(self, "Button_Get", function(node)
           NetMan:send(_MSG.updateActivityDetail(ACTIVITY_ID_MONTHCARD,node.getData))    
    end )
    self.cardList = me.assignWidget(self, "cardList")
    self.giftlist = me.assignWidget(self, "giftlist")
    self.day_giftList = me.assignWidget(self, "day_giftList")
    self.desc_list = me.assignWidget(self, "desc_list")
    self.bicon = me.assignWidget(self, "bicon")
    self.Text_Time = me.assignWidget(self,"Text_Time")
    return true
end
function monthCardCell:initActivity(msg)
    self.data = msg
   
    local cardItem = me.assignWidget(self, "cardItem")
    self.cardList:removeAllChildren()
    local function click_callback(node)
        self.selectIndex = node.idx
        for key, var in pairs(self.selects) do
            var:setVisible(self.selectIndex == key)
        end
        self:initCard(msg.list[self.selectIndex])
    end
    self.selects = { }
    for key, var in pairs(msg.list) do
        local item = cardItem:clone()
        item.idx = key
        local icon = me.assignWidget(item, "icon")
        local name = me.assignWidget(item, "name")
        local selectImg = me.assignWidget(item, "selectImg")
        selectImg:setVisible(self.selectIndex == key)
        self.selects[key] = selectImg
        icon:ignoreContentAdaptWithSize(true)
        icon:loadTexture(CARD_RES[var.id].icon, me.localType)
        name:ignoreContentAdaptWithSize(true)
        name:loadTexture(CARD_RES[var.id].name, me.localType)
        name:ignoreContentAdaptWithSize(true)
        self.cardList:pushBackCustomItem(item)

        if var.status == 0 then
            me.assignWidget(item, "redpoint"):setVisible(true)
        else
            me.assignWidget(item, "redpoint"):setVisible(false)
        end
        me.registGuiClickEvent(item, click_callback)
    end
    self:initCard(msg.list[self.selectIndex])
    self.lisener = UserModel:registerLisener( function(msg)
        if checkMsg(msg.t, MsgCode.ACTIVITY_UPDATE_DETAIL) then 
               if msg.c.activityId == ACTIVITY_ID_MONTHCARD then          
                    self:initCard(user.activityMonthCardData[msg.c.activityId].list[self.selectIndex])                      
                    if user.UI_REDPOINT.promotionBtn[tostring(ACTIVITY_ID_MONTHCARD)]==1 then  --移除红点
                        self:removeRedPoint()
                    end  
               end          
        end
    end )
end

function monthCardCell:removeRedPoint()
    local listData = user.activityMonthCardData[ACTIVITY_ID_MONTHCARD].list
    for _, v in ipairs(listData) do
        if v.status == 0 then
            return
        end
    end
    removeRedpoint(ACTIVITY_ID_MONTHCARD)
end

function monthCardCell:initCard(data)
    local desc = "<txt0014,d4cdb9>" .. data.title .. ":&<txt0014,998b7c>" .. data.content .. "&"
    self.desc_list:removeAllChildren()
    local rt = mRichText:create(desc, 420)
    self.desc_list:pushBackCustomItem(rt)
    self.bicon:ignoreContentAdaptWithSize(true)
    self.bicon:loadTexture(CARD_RES[data.id].icon, me.localType)
    self.day_giftList:removeAllChildren()
    local gift_item = me.assignWidget(self, "gift_item")
    local index = 1
    for key, var in pairs(data.items) do
        local item = gift_item:clone()
        local etc = cfg[CfgType.ETC][tonumber(var[1])]
        local quality = me.assignWidget(item, "quality")
        local item_name = me.assignWidget(item, "item_name")
        local item_icon = me.assignWidget(item, "item_icon")
        local item_num = me.assignWidget(item, "item_num")
        local item_bg = me.assignWidget(item, "item_bg")
        quality:loadTexture(getQuality(etc.quality))
        item_icon:loadTexture(getItemIcon(etc.id))
        item_num:setString("x" .. var[2])
        item_name:setString(etc.name)
        me.resizeImage(item_icon, 46, 46)
        item_bg:setVisible(index % 2 ~= 0)
        item_bg:setOpacity(120)
        index = index + 1
        self.day_giftList:pushBackCustomItem(item)
    end
    self.giftlist:removeAllChildren()
    local def = user.recharge[tonumber( data.id)]
    self.Button_buy.buyData = def
    self.Button_Get.getData = tonumber( data.id)
    for key, var in pairs(def.items) do
        local item = me.assignWidget(self, "Button_item"):clone()
        item:setVisible(true)
        local etc = cfg[CfgType.ETC][me.toNum(var[1])]
        me.assignWidget(item, "Image_quality"):loadTexture(getQuality(etc.quality))
        local Goods_Icon =  me.assignWidget(item, "Goods_Icon")
        Goods_Icon:loadTexture(getItemIcon(etc.id))
        me.assignWidget(item, "label_num"):setString(var[2])
        me.assignWidget(item, "Button_item"):setSwallowTouches(false)
        me.registGuiClickEventByName(item, "Button_item", function()
            showPromotion(var[1], var[2])
        end )        
        me.resizeImage(Goods_Icon, 100, 100)
        self.giftlist:pushBackCustomItem(item)
    end
    me.assignWidget(self,"Text_RMB"):setString("￥"..def.rmb)
    
    local cardItem = self.selects[self.selectIndex]:getParent():getParent() --红点操作
    if data.status == -1 then
        self.Button_buy:setVisible(true)
        self.Button_Get:setVisible(false)
        if data.limit > 0 then
            self.Text_Time:setVisible(true)
            self.Text_Time:setString("限购"..data.limit.."次")
        else
            self.Text_Time:setVisible(false)
        end

        me.assignWidget(cardItem, "redpoint"):setVisible(false) 
    elseif data.status == 0 then
        self.Button_buy:setVisible(false)
        self.Button_Get:setVisible(true)        
        self.Text_Time:setVisible(true)
        self.Text_Time:setString("剩余"..data.day.."天")
        me.setButtonDisable(self.Button_Get,true)      
        
        me.assignWidget(cardItem, "redpoint"):setVisible(true) 
    elseif data.status == 1 then
        self.Button_buy:setVisible(false)
        self.Button_Get:setVisible(true)        
        self.Text_Time:setVisible(true)
        self.Text_Time:setString("剩余"..data.day.."天")
        me.setButtonDisable(self.Button_Get,false) 

        me.assignWidget(cardItem, "redpoint"):setVisible(false) 
    end

end
function monthCardCell:onEnter()
    print("monthCardCell onEnter")
    me.doLayout(self, me.winSize)
end
function monthCardCell:onEnterTransitionDidFinish()
    print("monthCardCell onEnterTransitionDidFinish")
end
function monthCardCell:onExit()
    print("monthCardCell onExit")
    UserModel:removeLisener(self.lisener)
end
function monthCardCell:close()
    self:removeFromParent()
end
