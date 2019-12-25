promotionView = class("promotionView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
promotionView.__index = promotionView

--当前活动id号
ACTIVITY_ID_SEVENTHLOGIN = 2 --7日登录
ACTIVITY_ID_NEWCOMER = 64 --新军礼包
ACTIVITY_ID_SIGNIN = 3 --签到
ACTIVITY_ID_RECHARGE = 5--充值返利
ACTIVITY_ID_FIRST = 1 --首充
ACTIVITY_ID_EXCHANGE = 111 --积分兑换
ACTIVITY_ID_TURNPLATE = 6 --积分转盘
ACTIVITY_ID_FRESHMEAT = 7 --盛宴
ACTIVITY_ID_ALLIANCEATTACK = 9 --联盟攻城
ACTIVITY_ID_PLUNDER = 8 --掠夺天下
ACTIVITY_ID_FOUNDATION = 10 --基金奖励
ACTIVITY_ID_GIFT = 11 --活动礼包
ACTIVITY_ID_TIMELIMIT = 12 --限时活动
ACTIVITY_ID_VIPTIMEL = 13 --VIP特惠
ACTIVITY_ID_VIPTIMEL_SKIP = 33 --VIP特惠
ACTIVITY_ID_NATIONALDAY = 14 --国庆特庆
ACTIVITY_ID_BOSS = 15 --boss战
ACTIVITY_ID_DAILY_HAPPY = 16 --每日狂欢
ACTIVITY_ID_GIFT_EXCHANGE = 17 --礼包兑换
ACTIVITY_ID_SHOP = 18 -- 限购商城
ACTIVITY_ID_GIFT_NEWYEAR = 19 --元旦集字
ACTIVITY_ID_GIFT_NEWYEAR_CHIANA = 20 --新年福卷
ACITVITY_ID_NEW_SPRING = 21 --新春礼包
ACTIVITY_ID_HONGBAO = 22 -- 天降红包
ACTIVITY_ID_VEVRYDAY = 23 -- 每日抢购
ACTIVITY_ID_LADOUR = 24 -- 五一活动
ACTIVITY_ID_LADOUR_ = 25 -- 端午节
ACTIVITY_ID_WEEKYSIGN = 26 --  周签到
ACTIVITY_ID_MEDAL = 27 --  武勋兑换活动
ACTIVITY_ID_WISH = 28 --许愿珠活动
ACTIVITY_SHIP_PACKAGE = 32 -- 战舰
ACTIVITY_ID_MID_AUTUMN_FESTIVAL = 30 --中秋节活动
ACTIVITY_ID_REDEEM = 31 --积分兑换

ACTIVITY_ID_DAYPAY = 35 --每日单次充值

ACTIVITY_ID_SUM_DAYPAY = 36 --每日总充值

ACTIVITY_ID_DAY_SPENDING = 40 --每日消费

ACTIVITY_ID_SUMPAY = 34 -- 累计充值
ACTIVITY_ID_SUMCOST = 39 -- 累计消费

ACTIVITY_ID_PAYRANK = 37 -- 累计充值排名
ACTIVITY_ID_NET_PAYRANK = 38 --跨服累计充值排名
ACTIVITY_ID_COSTRANK = 41 -- 累计消费排名
ACTIVITY_ID_NET_COSTRANK = 42 --跨服累计消费排名
ACTIVITY_ID_MONTHCARD = 43 --月卡周卡

ACTIVITY_ID_RECHARGE_GEM = 44 --充值

ACTIVITY_ID_DAYGIFT = 45 --每日礼包

ACTIVITY_ID_RUNE = 46 --圣物抽奖

ACTIVITY_ID_RESIST_INVASION = 48 --抵御蛮族
ACTIVITY_ID_QUEST = 47 --答题

ACTIVITY_ID_TIME_TURNPLATE = 49 --限时转盘

ACTIVITY_ID_DRAGON = 50 --击杀迅猛龙
ACTIVITY_ID_DRAGON_NEW = 52 --击杀迅猛龙
ACTIVITY_ID_NETBATTLE = 51 --跨服
ACTIVITY_ID_GIFT_NEWYEAR_CHIANA_NEW = 53
ACTIVITY_ID_BOSS_NEW = 54
ACTIVITY_ID_RESIST_INVASION_NEW = 55
ACTIVITY_ID_TIMELIMIT_NEW = 56
--限时兑换
ACTIVITY_ID_LIMITED_REDEMPTION = 58
ACTIVITY_ID_DIGORE = 57   --挖矿
-- 战力比拼
ACTIVITY_ID_FAP_RANK = 59
-- 中秋集福
ACTIVITY_ID_MID_AUTUMN_BLESS = 62
-- 累计登录
ACTIVITY_ID_CUMULATIVE_LOGIN = 63
-- 七日登录
ACTIVITY_ID_SEVEN_LOGIN = 66
-- 圣地试炼
ACTIVITY_ID_HOLY_TRAIN = 67
-- 圣地试炼上一次自动拉取数据时的阶段id，用于对比是否需要再次拉取数据
HOLY_TRAIN_STAGE_ID_LAST_PULL_DATA = -1
-- 领地扩张
ACTIVITY_ID_LAND_EXPAND = 68

--status:
--新军礼包，1：购买  2:已购买
--签到，1：可领取，2:已领取，3:未开放
--首充，1：可领取，2：已领取，3：充值跳转
--充值返利：1，领取，2:已领取，3:充值

ACTIVITY_STATUS_1 = 1
ACTIVITY_STATUS_2 = 2
ACTIVITY_STATUS_3 = 3

function promotionView:create(...)
    local layer = promotionView.new(...)
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

function promotionView:ctor()
    print("promotionView:ctor()")
    self.tableView = nil
    self.listData = {}
    self.selCellId = nil --当前所在什么子界面
    self.turnplateNode = nil --大转盘的子界面
    self.taskGuideIndex = nil --跳转到固定id
    -- 圣地试炼专用字段
    HOLY_TRAIN_STAGE_ID_LAST_PULL_DATA = -1
end
function promotionView:init()
    self.Image_left = me.assignWidget(self, "Image_left")
    self.Panel_right = me.assignWidget(self, "Panel_right")
    self.tableCell = me.assignWidget(self, "table_cell")
    self.tableCell:retain()

    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end)
    self.curEvt =  me.RegistCustomEvent("promotionViewclose",function (rev)
       self:close()
   end)
  return true
end

function promotionView:revInitList(msg)
    me.tableClear(self.listData)
    self.listData= {}
    if self.taskGuideIndex then
        self.listData[1]={gp=1, id=self.taskGuideIndex}
    else
        for key, var in pairs(user.activityList) do
            if me.toNum(var.gp) == self.typeid then
                self.listData[#self.listData+1] = var
            end
        end
    end
--    local function comp(a,b)
--        return cfg[CfgType.ACTIVITY_LIST][a.id].order <  cfg[CfgType.ACTIVITY_LIST][b.id].order
--    end
--    table.sort(self.listData,comp)
--    dump (self.listData)
    print ("#self.listData = ", #self.listData)

    local function numberOfCellsInTableView(table)
        return #self.listData
    end

    local function cellSizeForTable(table, idx)
        return 339, 81
    end
    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local node = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            node = self.tableCell:clone()
            cell:addChild(node)
            print("cell create")
        else
            node =me.assignWidget(cell, "table_cell")
            print("cell have")
        end
        node:setVisible(true)

        local tmp = self.listData[me.toNum(idx+1)]
        local def = cfg[CfgType.ACTIVITY_LIST][me.toNum(tmp.id)]
        dump(def)
        if tmp and def then
            local ImageView_cell_select = me.assignWidget(node, "ImageView_cell_select")
            local ImageView_cell_normal = me.assignWidget(node, "ImageView_cell_normal")
            local pIcon = me.assignWidget(node,"icon")
            pIcon:ignoreContentAdaptWithSize(true)

            --红点显示
            local redpointData = user.UI_REDPOINT["promotionBtn"][tostring(def.id)]
            local redpointData1 = user.UI_REDPOINT["payBtn"][tostring(def.id)]
            local redpointData2 = user.UI_REDPOINT["Button_Shop"][tostring(def.id)]
            if redpointData==1 or redpointData1==1 or redpointData2 == 1 then
                me.assignWidget(node,"redpoint"):setVisible(true)
            else
                me.assignWidget(node,"redpoint"):setVisible(false)
            end
            local ImageView_new = me.assignWidget(node, "ImageView_new")
            local nameTxt = me.assignWidget(node,"nameTxt")
            nameTxt:setString(def.name)
            nameTxt:enableShadow(cc.c4b(0x00, 0x00, 0x00, 0xff), cc.size(-1, -1))
            if def.id == ACTIVITY_ID_FIRST then -- 首冲
               pIcon:loadTexture("huodong_anniu_shouchong.png",me.plistType)
            elseif def.id == ACTIVITY_ID_SIGNIN then -- 连续登陆
               pIcon:loadTexture("huodong_anniu_qiri.png",me.plistType)
            elseif def.id == ACTIVITY_ID_NEWCOMER then -- 新军礼包
               pIcon:loadTexture("huodong_anniu_meiri.png",me.plistType)
            elseif def.id == ACTIVITY_ID_RECHARGE then -- 充值返利
               --pIcon:loadTexture("huodong_anniu_jifen.png",me.plistType)
            elseif def.id == ACTIVITY_ID_TURNPLATE then -- 转盘
               pIcon:loadTexture("huodong_anniu_chongzhi.png",me.plistType)
            elseif def.id == ACTIVITY_ID_FRESHMEAT then -- 盛宴
                pIcon:loadTexture("huodong_anniu_wanyan.png",me.plistType)
            elseif def.id == ACTIVITY_ID_ALLIANCEATTACK then -- 联盟攻城
                pIcon:loadTexture("huodong_anniu_gongcheng.png",me.plistType)
            elseif def.id == ACTIVITY_ID_FOUNDATION then -- 基金奖励活动
                pIcon:loadTexture("huodong_anniu_jijin.png",me.plistType)
            elseif  def.id == ACTIVITY_ID_PLUNDER then -- 掠夺天下
                pIcon:loadTexture("huodong_anniu_lueduo.png",me.plistType)
            elseif def.id == ACTIVITY_ID_GIFT then -- 限时礼包
                pIcon:loadTexture("huodong_anniu_xianshirexiao.png",me.plistType)
            elseif def.id == ACTIVITY_ID_TIMELIMIT or def.id == ACTIVITY_ID_TIMELIMIT_NEW then -- 限时活动
                pIcon:loadTexture("huodong_anniu_xianshi.png",me.plistType)
            elseif def.id == ACTIVITY_ID_VIPTIMEL then -- vip特惠
                pIcon:loadTexture("huodong_haoli_anniu_vip.png",me.plistType)
            elseif def.id == ACTIVITY_ID_VIPTIMEL_SKIP then -- vip特惠
                pIcon:loadTexture("huodong_anniu_jianchuan.png",me.plistType)
            elseif def.id == ACTIVITY_ID_NATIONALDAY then -- 国庆特庆
                pIcon:loadTexture("huodong_anniu_yuanxiao.png",me.plistType)
            elseif def.id == ACTIVITY_ID_BOSS or def.id ==ACTIVITY_ID_BOSS_NEW then -- boss活动
                pIcon:loadTexture("huodong_anniu_juntuan.png",me.plistType)
            elseif def.id == ACTIVITY_ID_DAILY_HAPPY then -- 每日狂欢
                pIcon:loadTexture("huodong_anniu_kuanghuan.png",me.plistType)
            elseif def.id == ACTIVITY_ID_GIFT_EXCHANGE then -- 礼包兑换
                pIcon:loadTexture("huodong_anniu_duihuanma.png",me.plistType)
            elseif def.id == ACTIVITY_ID_SHOP then --神秘商店
                pIcon:loadTexture("huodong_anniu_mystical.png",me.plistType)
            elseif def.id == ACTIVITY_ID_GIFT_NEWYEAR then --元旦快乐
                --pIcon:loadTexture("huodong_anniu_yuandan.png",me.plistType)
            elseif def.id == ACTIVITY_ID_MID_AUTUMN_BLESS then --中秋集福
                pIcon:loadTexture("huodong_anniu_zhongqiujifu.png",me.plistType)
            elseif def.id == ACTIVITY_ID_CUMULATIVE_LOGIN then  -- 累计登录
                pIcon:loadTexture("huodong_anniu_leijidenglu.png", me.plistType)
            elseif def.id == ACTIVITY_ID_SEVEN_LOGIN then  -- 七日登录
                pIcon:loadTexture("huodong_icon_qiridenglu.png", me.plistType)
            elseif def.id == ACTIVITY_ID_HOLY_TRAIN then  -- 圣地试炼
                pIcon:loadTexture("huodong_icon_yijishilian.png", me.plistType)
            elseif def.id == ACTIVITY_ID_LAND_EXPAND then  -- 领地扩张
                pIcon:loadTexture("huodong_icon_lingdikuozhang.png", me.plistType)
            elseif def.id == ACITVITY_ID_NEW_SPRING then --新春礼包
                --pIcon:loadTexture("huodong_anniu_xinchun.png",me.plistType)
            elseif def.id == ACTIVITY_ID_GIFT_NEWYEAR_CHIANA or def.id == ACTIVITY_ID_GIFT_NEWYEAR_CHIANA_NEW then -- 新年福卷
                 pIcon:loadTexture("huodong_nianshou.png",me.plistType)
            elseif def.id == ACTIVITY_ID_HONGBAO then --天降红包
                pIcon:loadTexture("huodong_anniu_hongbao.png",me.plistType)
            elseif def.id == ACTIVITY_ID_LADOUR then --五一活动
                --pIcon:loadTexture("huodong_anniu_wuyi.png",me.plistType)
            elseif def.id == ACTIVITY_ID_LADOUR_ then -- 端午节
                --pIcon:loadTexture("huodong_anniu_duanwu.png",me.plistType)
            elseif def.id == ACTIVITY_ID_WEEKYSIGN then -- 周签到
                --pIcon:loadTexture("huodong_anniu_jili.png",me.plistType)
            elseif def.id == ACTIVITY_ID_MEDAL then -- 武勋兑换活动
                --pIcon:loadTexture("huodong_anniu_wuxun.png",me.plistType)
            elseif def.id == ACTIVITY_ID_WISH then -- 许愿珠活动
                --pIcon:loadTexture("huodong_anniu_zhanbu.png",me.plistType)
            elseif def.id == ACTIVITY_SHIP_PACKAGE  then -- 战舰活动
                pIcon:loadTexture("huodong_anniu_hanghai.png",me.plistType)
            elseif def.id == ACTIVITY_ID_DAYGIFT then
                 pIcon:loadTexture("huodong_anniu_haoli.png",me.plistType)
            elseif def.id == ACTIVITY_ID_MID_AUTUMN_FESTIVAL then
                --pIcon:loadTexture("huodong_anniu_zhongqiu.png", UI_TEX_TYPE_LOCAL)
            elseif def.id == ACTIVITY_ID_REDEEM then
                --pIcon:loadTexture("huodong_anniu_xianshi_jifen.png", UI_TEX_TYPE_LOCAL)
            elseif def.id == ACTIVITY_ID_DAYPAY then
                pIcon:loadTexture("huodong_anniu_meiri_pay.png",me.plistType)
            elseif def.id == ACTIVITY_ID_SUM_DAYPAY then 
                pIcon:loadTexture("huodong_anniu_meiri_chongzhi.png",me.plistType)
            elseif def.id == ACTIVITY_ID_DAY_SPENDING then
                pIcon:loadTexture("huodong_anniu_day_xiaofei.png",me.plistType)
            elseif def.id == ACTIVITY_ID_SUMPAY then
                pIcon:loadTexture("huodong_anniu_paygem.png",me.plistType)
            elseif def.id == ACTIVITY_ID_RUNE then
                pIcon:loadTexture("huodong_icon_souxun.png",me.plistType)
            elseif def.id == ACTIVITY_ID_SUMCOST then
                pIcon:loadTexture("huodong_anniu_leijixiaofei.png",me.plistType)
            elseif def.id == ACTIVITY_ID_MONTHCARD then
                pIcon:loadTexture("huodong_anniu_yueka.png",me.plistType)   
            elseif def.id ==  ACTIVITY_ID_PAYRANK  then
                pIcon:loadTexture("huodong_anniu_payrank.png",me.plistType)
            elseif def.id == ACTIVITY_ID_NET_PAYRANK then
                 pIcon:loadTexture("huodong_icon_net_payrank.png",me.plistType)
            elseif def.id ==  ACTIVITY_ID_COSTRANK then
                pIcon:loadTexture("huodong_anniu_costpaiming.png",me.plistType)
            elseif def.id == ACTIVITY_ID_NET_COSTRANK then                
                pIcon:loadTexture("huodong_icon_net_payrank.png",me.plistType)
            elseif def.id == ACTIVITY_ID_RECHARGE_GEM then
                pIcon:loadTexture("huodong_anniu_gem.png",me.plistType)
            elseif def.id == ACTIVITY_ID_RESIST_INVASION or def.id == ACTIVITY_ID_RESIST_INVASION_NEW then
                pIcon:loadTexture("huodong_anniu_diyumancu.png",me.plistType) 
            elseif def.id == ACTIVITY_ID_TIME_TURNPLATE then
                pIcon:loadTexture("huodong_anniu_xianshiduobao.png",me.plistType) 
            elseif def.id == ACTIVITY_ID_QUEST then
                pIcon:loadTexture("huodong_youjiang.png",me.plistType)
            elseif def.id == ACTIVITY_ID_LIMITED_REDEMPTION then
                pIcon:loadTexture("huodong_icon_xianshiduihuan.png",me.plistType)
            elseif def.id == ACTIVITY_ID_DRAGON or def.id == ACTIVITY_ID_DRAGON_NEW then
                pIcon:loadTexture("huodong_anniu_long.png",me.plistType)
            elseif def.id == ACTIVITY_ID_NETBATTLE then
                pIcon:loadTexture("huodong_anniu_kuafu.png",me.plistType)
            elseif def.id == ACTIVITY_ID_DIGORE then
                pIcon:loadTexture("huodong_anniu_digore.png",me.plistType)
            elseif def.id == ACTIVITY_ID_FAP_RANK then
                pIcon:loadTexture("huodong_anniu_zhanlibipin.png",me.plistType)
            end
            if self.selCellId == me.toNum(tmp.id) then
                ImageView_cell_normal:setVisible(false)
                ImageView_cell_select:setVisible(true)
                nameTxt:setTextColor(cc.c3b(219,224,201))
            else
                ImageView_cell_normal:setVisible(true)
                ImageView_cell_select:setVisible(false)
                nameTxt:setTextColor(cc.c3b(192,178,151))
            end
        else
            node:setVisible(false)
        end
        return cell
    end

    local function tableCellTouched(table, cell)
        local data = self.listData[cell:getIdx()+1]
        if self.selCellId == data.id then
            return
        end

        if data.id == ACTIVITY_ID_TURNPLATE then
            if self.turnplateNode == nil then
                NetMan:send(_MSG.activityDetail(me.toNum(data.id)))
            else
                self:setSelectTableCell(ACTIVITY_ID_TURNPLATE)
                for key, var in pairs(self.Panel_right:getChildren()) do
                    if self.turnplateNode ~= var then
                        var:removeFromParentAndCleanup(true)
                    elseif self.turnplateNode and self.turnplateNode == var then
                        self.turnplateNode:setVisible(true)
                    end
                end
            end
        else
            NetMan:send(_MSG.activityDetail(me.toNum(data.id)))
        end
        HOLY_TRAIN_STAGE_ID_LAST_PULL_DATA = -1
    end

    if self.tableView == nil then
        self.tableView = cc.TableView:create(cc.size(339,580))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setPosition(6, 4)
        self.tableView:setAnchorPoint(cc.p(0,0))
        self.tableView:setDelegate()
        self.Image_left:addChild(self.tableView)
        self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
    self.tableView:reloadData()
end

function promotionView:setSelectTableCell(msgId_)
    local function getCellByid(id_)
        for key, var in pairs(self.listData) do
            if me.toNum(var.id) == me.toNum(id_) then
                local cell = self.tableView:cellAtIndex(me.toNum(key)-1)
                return cell
            end
        end
    end

    if self.selCellId ~= nil and self.selCellId ~= msgId_ then
       local lastCell = getCellByid(self.selCellId)
       if lastCell then
           me.assignWidget(lastCell, "ImageView_cell_normal"):setVisible(true)
           me.assignWidget(lastCell, "ImageView_cell_select"):setVisible(false)
           me.assignWidget(lastCell,"nameTxt"):setTextColor(cc.c3b(192,178,151))
       end
    end
    if self.taskGuideIndex==nil and user.activityDetail then
        user.activityDetail.activityId = msgId_
    end
    self.selCellId = msgId_
    local lastCell = getCellByid(self.selCellId)
    if lastCell then
        me.assignWidget(lastCell, "ImageView_cell_normal"):setVisible(false)
        me.assignWidget(lastCell, "ImageView_cell_select"):setVisible(true)
        me.assignWidget(lastCell,"nameTxt"):setTextColor(cc.c3b(219,224,201))
    end
end

function promotionView:removePanel_right()
    for key, var in pairs(self.Panel_right:getChildren()) do
        if self.turnplateNode ~= var then
            var:removeFromParentAndCleanup(true)
        else
            self.turnplateNode:setVisible(false)
        end
    end
end

function promotionView:revInitDetail(msg)
    if msg.c.activityId == nil then
        print("msg.c.activityId == nil !!!")
        return
    end

    self:removePanel_right()
    self:setSelectTableCell(msg.c.activityId)
    --加载活动的详情界面
    if msg.c.activityId == ACTIVITY_ID_NEWCOMER then
        local rightNode = newComerSubcell:create("newComerCell.csb")
        self.Panel_right:addChild(rightNode)
    elseif msg.c.activityId == ACTIVITY_ID_SEVENTHLOGIN then
        local rightNode = seventhLoginSubcell:create("seventhLoginCell.csb")
        self.Panel_right:addChild(rightNode)
    elseif msg.c.activityId == ACTIVITY_ID_SIGNIN then
        local signinNode = signinSubcell:create("signinCell.csb")
        self.Panel_right:addChild(signinNode)
    elseif msg.c.activityId == ACTIVITY_ID_RECHARGE then
        local rechargeNode = rechargeSubcell:create("rechargeCell.csb")
        self.Panel_right:addChild(rechargeNode)
    elseif msg.c.activityId == ACTIVITY_ID_FIRST then
        local firstNode = firstBuySubcell:create("firstBuyCell.csb")
        self.Panel_right:addChild(firstNode)
    elseif msg.c.activityId == ACTIVITY_ID_EXCHANGE then
        -- 策划临时删除
    elseif msg.c.activityId == ACTIVITY_ID_TURNPLATE then
        if self.turnplateNode == nil then
            self.turnplateNode = turnplateSubcell:create("turnplateCell.csb")
            self.Panel_right:addChild(self.turnplateNode)
        end
        self.turnplateNode:setVisible(true)
    elseif msg.c.activityId == ACTIVITY_ID_FRESHMEAT then
        local freshMeat = freshMeatSubcell:create("freshMeatCell.csb")
        self.Panel_right:addChild(freshMeat)
    elseif msg.c.activityId == ACTIVITY_ID_ALLIANCEATTACK then
        local allianceSH = allianceStrongholdSubcell:create("allianceStrongholdCell.csb")
        self.Panel_right:addChild(allianceSH)
    elseif msg.c.activityId == ACTIVITY_ID_FOUNDATION then
        local allianceFC = foundationSubcell:create("allianceFoundationCell.csb")
        self.Panel_right:addChild(allianceFC)
    elseif msg.c.activityId == ACTIVITY_ID_PLUNDER then
        local pw = plunderWorldSubcell:create("plunderTheWorldCell.csb")
        self.Panel_right:addChild(pw)
    elseif msg.c.activityId == ACTIVITY_ID_GIFT or msg.c.activityId == ACTIVITY_SHIP_PACKAGE or msg.c.activityId == ACTIVITY_ID_DAYGIFT then
        local gs = giftSubcell:create("giftCell.csb")
        gs.activityId = msg.c.activityId
        self.Panel_right:addChild(gs)
    elseif msg.c.activityId == ACTIVITY_ID_TIMELIMIT or msg.c.activityId == ACTIVITY_ID_TIMELIMIT_NEW then
        if msg.c.open == nil or msg.c.open == 0 then --活动未开启
            local tls = timeLimitSubcell:create("timeLimitCell.csb")
            self.Panel_right:addChild(tls)
        elseif msg.c.open ~= nil and msg.c.open == 1 then --活动开启
            local tlds = timeLimitDetailSubcell:create("timeLimitCell_detail.csb")
            self.Panel_right:addChild(tlds)
        end
    elseif msg.c.activityId == ACTIVITY_ID_VIPTIMEL then --vip特惠
        local vip = activityVIP:create("acivityVIP.csb")
        vip:setData(ACTIVITY_ID_VIPTIMEL)
        self.Panel_right:addChild(vip)
    elseif msg.c.activityId == ACTIVITY_ID_VIPTIMEL_SKIP then --vip特惠
        local vip = activityVIP:create("acivityVIP.csb")
        vip:setData(ACTIVITY_ID_VIPTIMEL_SKIP)
        self.Panel_right:addChild(vip)
    elseif msg.c.activityId == ACTIVITY_ID_NATIONALDAY then --国庆特惠
        local national = nationalDaySubcell:create("nationalDayCell.csb")
        self.Panel_right:addChild(national)
    elseif msg.c.activityId == ACTIVITY_ID_BOSS or msg.c.activityId ==ACTIVITY_ID_BOSS_NEW then -- boss战
        local boss = bossSubcell:create("bossCell.csb")
        self.Panel_right:addChild(boss)
    elseif msg.c.activityId == ACTIVITY_ID_DAILY_HAPPY then -- 每日狂欢
        local hvd = highVeryDaySubcell:create("highVeryDayCell.csb")
        self.Panel_right:addChild(hvd)
    elseif msg.c.activityId == ACTIVITY_ID_DAYPAY or msg.c.activityId == ACTIVITY_ID_SUM_DAYPAY 
    or msg.c.activityId == ACTIVITY_ID_DAY_SPENDING then --每日充值
        local dp = dayPayCell:create("dayPayCell.csb")
        dp:initActivity(msg.c.activityId)
        self.Panel_right:addChild(dp)
    elseif msg.c.activityId == ACTIVITY_ID_SUMPAY or msg.c.activityId == ACTIVITY_ID_RUNE  then        
        local spay = sumPayCell:create("sumPayCell.csb")
        spay:initActivity(msg.c.activityId)
        self.Panel_right:addChild(spay)
    elseif msg.c.activityId == ACTIVITY_ID_SUMCOST then
        local scost = sumCostCell:create("sumPayCell.csb")
        scost:initActivity(msg.c.activityId)
        self.Panel_right:addChild(scost)
    elseif msg.c.activityId == ACTIVITY_ID_PAYRANK
    or msg.c.activityId == ACTIVITY_ID_NET_PAYRANK
     then --充值排行榜
         local payrank = sumPayRankCell:create("sumPayRankCell.csb")
         payrank:initActivity(msg.c.activityId)
         
         self.Panel_right:addChild(payrank)
    elseif msg.c.activityId == ACTIVITY_ID_COSTRANK or 
    msg.c.activityId == ACTIVITY_ID_NET_COSTRANK then --消费排行榜
         local payrank = sumPayRankCell:create("sumPayRankCell.csb")
         payrank:initActivity(msg.c.activityId)         
         self.Panel_right:addChild(payrank) 
    elseif msg.c.activityId == ACTIVITY_ID_QUEST then
          local quest = questCell:create("questCell.csb")
          quest:initActivity(msg.c)      
          self.Panel_right:addChild(quest) 
    elseif msg.c.activityId == ACTIVITY_ID_LIMITED_REDEMPTION then        
        local ex = limitExchangeCell:create("limitExchangeCell.csb")
        self.Panel_right:addChild(ex) 
    elseif msg.c.activityId == ACTIVITY_ID_RECHARGE_GEM then --充值        
         local recharge = rechargeGemCell:create("rechargeGemCell.csb")
         self.Panel_right:addChild(recharge) 
    elseif msg.c.activityId == ACTIVITY_ID_MONTHCARD then --月卡周卡
         local month = monthCardCell:create("newMonthCardCell.csb")        
         month:initActivity(msg.c)
         self.Panel_right:addChild(month)
    elseif msg.c.activityId == ACTIVITY_ID_GIFT_EXCHANGE then -- 礼包兑换
        local ges = giftExchangeSubcell:create("giftExchangeCell.csb")
        self.Panel_right:addChild(ges)
    elseif msg.c.activityId == ACTIVITY_ID_GIFT_NEWYEAR then -- 元旦快乐
        local national = nationalDaySubcell:create("nationalDayCell.csb")
        self.Panel_right:addChild(national)
    elseif msg.c.activityId == ACTIVITY_ID_MID_AUTUMN_BLESS then -- 中秋集福
        local national = nationalDaySubcell:create("nationalDayCell.csb")
        self.Panel_right:addChild(national)
    elseif msg.c.activityId == ACTIVITY_ID_CUMULATIVE_LOGIN then -- 累计登录
        local loginCell = CumulativeLoginCell:create("CumulativeLoginCell.csb")
        loginCell:initActivity(msg.c)
        self.Panel_right:addChild(loginCell)
    elseif msg.c.activityId == ACTIVITY_ID_SEVEN_LOGIN then -- 七日登录
        local node = SevenLoginCell:create("SevenLoginCell.csb")
        node:setData(msg.c)
        self.Panel_right:addChild(node)
    elseif msg.c.activityId == ACTIVITY_ID_HOLY_TRAIN then -- 圣地试炼
        local node = HolyLandTrainCell:create("HolyLandTrainCell.csb")
        node:setData(msg.c)
        self.Panel_right:addChild(node)
    elseif msg.c.activityId == ACTIVITY_ID_LAND_EXPAND then -- 领地扩张
        local node = LandExpandCell:create("LandExpandCell.csb")
        node:setData(msg.c)
        self.Panel_right:addChild(node)
    elseif msg.c.activityId == ACTIVITY_ID_GIFT_NEWYEAR_CHIANA or msg.c.activityId == ACTIVITY_ID_GIFT_NEWYEAR_CHIANA_NEW then -- 新年福卷
        local newYear = NewYear:create("newYear.csb")
        self.Panel_right:addChild(newYear)
    elseif msg.c.activityId == ACTIVITY_ID_HONGBAO then -- 天降红包
        local hb = hongBao:create("hongbao.csb")
        self.Panel_right:addChild(hb)
    elseif msg.c.activityId == ACITVITY_ID_NEW_SPRING  then -- 新春礼包
        local gs = giftSubcell:create("giftCell.csb")
        gs:setType(msg.c.activityId)
        self.Panel_right:addChild(gs)
    elseif msg.c.activityId == ACTIVITY_ID_LADOUR or msg.c.activityId == ACTIVITY_ID_LADOUR_ then
        local gs = LabourActivity:create("giftCell.csb")
        gs:setType(msg.c.activityId)
        self.Panel_right:addChild(gs)
    elseif msg.c.activityId == ACTIVITY_ID_WEEKYSIGN then -- 周签到
        local wss = weekySignSubcell:create("weekySign.csb")
        self.Panel_right:addChild(wss)
    elseif msg.c.activityId == ACTIVITY_ID_MEDAL then -- 武勋兑换活动
        local ms = medalSubcell:create("medalExchangeCell.csb")
        self.Panel_right:addChild(ms)
    elseif msg.c.activityId == ACTIVITY_ID_WISH then -- 许愿活动
        local ws = wishSubcell:create("wishCell.csb")
        self.Panel_right:addChild(ws)
    elseif msg.c.activityId == ACTIVITY_ID_TIME_TURNPLATE then
        --限时转盘  
         local zp = timeTurnplateLayer:create("timeTurnplateLayer.csb")                
         zp:initWithData(msg)
         self.Panel_right:addChild(zp)
    elseif msg.c.activityId == ACTIVITY_ID_MID_AUTUMN_FESTIVAL then
        local gs = LabourActivity:create("giftCell.csb")
        gs:setType(msg.c.activityId)
        self.Panel_right:addChild(gs)
    elseif msg.c.activityId == ACTIVITY_ID_REDEEM then
        local ms = redeemExchangeCell:create("redeemExchangeCell.csb")
        self.Panel_right:addChild(ms)
    elseif msg.c.activityId == ACTIVITY_ID_RESIST_INVASION or msg.c.activityId == ACTIVITY_ID_RESIST_INVASION_NEW then
        local ms = resistInvasionCell:create("resistInvasionCell.csb")
        ms.wave = msg.c.expectWave
        self.Panel_right:addChild(ms)   
    elseif msg.c.activityId  == ACTIVITY_ID_NETBATTLE then
        local net = netBattleCell:create("netBattleCell.csb")
        net:initActivity(msg.c.activityId)         
        self.Panel_right:addChild(net)   
    elseif msg.c.activityId  == ACTIVITY_ID_SHOP then
        local ship = mysticalShipCell:create("mysticalShipCell.csb")
        self.Panel_right:addChild(ship) 
    elseif msg.c.activityId == ACTIVITY_ID_DRAGON or msg.c.activityId == ACTIVITY_ID_DRAGON_NEW then
        local ms = killDragonCell:create("dragonCell.csb")
        ms:setParent(self)
        self.Panel_right:addChild(ms)     
    elseif msg.c.activityId == ACTIVITY_ID_DIGORE then
        if self.Panel_right:getChildByName("digoreActivity")==nil then
            local ms = digoreActivity:create("digore/digoreActivity.csb")
            ms:setP(self)
            ms:setName("digoreActivity")
            self.Panel_right:addChild(ms) 
        end
    --战力排行榜
    elseif msg.c.activityId == ACTIVITY_ID_FAP_RANK then
        local fapRank = FapRankCell:create("FapRankCell.csb")
        fapRank:initActivity(msg.c)         
        self.Panel_right:addChild(fapRank) 
    end   
end

function promotionView:setViewTypeID(typeid)
    self.typeid = typeid
end

function promotionView:setSelectCellID(id)
    self.selCellId = id
end


function promotionView:onEnter()
    print("promotionView:onEnter()")
    --发送活动接口
    self.modelkey = UserModel:registerLisener(function(msg)  -- 注册消息通知
        self:update(msg)
    end)

    if self.taskGuideIndex==ACTIVITY_ID_TURNPLATE then
        me.assignWidget(self, "backpack_title"):setString("积分奖励")
    elseif self.taskGuideIndex==ACTIVITY_ID_RESIST_INVASION then
        
    end
    me.DelayRun(function ()
        if self.taskGuideIndex then
            self:revInitList()
            NetMan:send(_MSG.activityDetail(me.toNum(self.taskGuideIndex)))
        else
            NetMan:send(_MSG.activityList(self.typeid))
        end
    end)
    self.close_event = me.RegistCustomEvent("promotionView",function (evt)
        self:close()
    end)

    -- 活动等UI红点显示
    self.uiRedPointListener = me.RegistCustomEvent("UI_RED_POINT", handler(self, self.updateUIRedPoint))

    me.doLayout(self,me.winSize)
end

-- 活动等UI红点显示
function promotionView:updateUIRedPoint()
    local offset=self.tableView:getContentOffset()
    self.tableView:reloadData()
        
    local size=self.tableView:getContentSize()
    if offset.y<570-size.height then
        offset.y=570-size.height
    end
    self.tableView:setContentOffset(offset)
end

function promotionView:setTaskGuideIndex(index)
    self.taskGuideIndex = index
end
function promotionView:update(msg)
    if checkMsg(msg.t, MsgCode.ACTIVITY_LIST) then
        self:revInitList(msg)
    elseif checkMsg(msg.t, MsgCode.ACTIVITY_INIT_VIEW) then
        self:revInitDetail(msg)
    end
end
function promotionView:onExit()
    self.tableCell:release()
    me.RemoveCustomEvent(self.close_event)
    me.RemoveCustomEvent(self.uiRedPointListener)
    me.RemoveCustomEvent(self.curEvt)
    print("promotionView:onExit()")
end
function promotionView:close()
    print("promotionView:close()")
    UserModel:removeLisener(self.modelkey) -- 删除消息通知
    self:getParent().promotionView = nil
    self:removeFromParentAndCleanup(true)
    self.turnplateNode = nil
end

