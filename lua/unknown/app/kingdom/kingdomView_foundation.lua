kingdomView_foundation = class("kingdomView_foundation", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
kingdomView_foundation.__index = kingdomView_foundation
function kingdomView_foundation:create(...)
    local layer = kingdomView_foundation.new(...)
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
function kingdomView_foundation:ctor()
    print("kingdomView_foundation:ctor()")
end
function kingdomView_foundation:init()
    self.Panel_table = me.assignWidget(self,"Panel_table")
    self.Text_food = me.assignWidget(self,"Text_food")
    self.Text_wood = me.assignWidget(self,"Text_wood")
    self.Text_stone = me.assignWidget(self,"Text_stone")
    self.Text_gold = me.assignWidget(self,"Text_gold")
    
    me.registGuiClickEventByName(self, "Button_given1" ,function (node)
        NetMan:send(_MSG.kingdom_given_salary())
        showWaitLayer()
    end)

    
    local tmpDef = cfg[CfgType.KINGDOM_OFFICER][me.toNum(user.kingdom_OfficerData.myDegree)]
    if tmpDef then
        me.assignWidget(self,"degreeTxt"):setString(tmpDef.name)
        me.assignWidget(self, "Button_given1"):setVisible(true)
        if user.kingdon_foundationData.salary==1 then
            me.buttonState(me.assignWidget(self, "Button_given1"),true)
        else
            me.buttonState(me.assignWidget(self, "Button_given1"),false)
        end
    else
        me.assignWidget(self,"degreeTxt"):setString("无职位")
        me.assignWidget(self, "Button_given1"):setVisible(false)
    end
    

    return true
end
function kingdomView_foundation:update(msg)
    if checkMsg(msg.t, MsgCode.KINGDOM_FOUNDATION_DONATE) then
        if #msg.c.list <= 0 and self.donateSubcell == nil then
            showTips("没有可用捐赠物品!")
            return
        end

        if self.donateSubcell == nil then
            self.donateSubcell = kingdomView_foundation_donate:create("kingdomView_foundation_donate.csb")
            self.donateSubcell:setItemListData(msg.c.list)
            self.donateSubcell:setFatherNode(self)
            pWorldMap:addChild(self.donateSubcell,me.MAXZORDER)
        else        
            showTips("捐赠成功！")
            self.donateSubcell:setItemListData(msg.c.list,true)
        end


    elseif checkMsg(msg.t, MsgCode.KINGDOM_TYPE_DETAIL) then
        self:setFoundationData()
        self.tableView:reloadData()

        if user.kingdon_foundationData.salary==1 then
            me.buttonState(me.assignWidget(self, "Button_given1"),true)
        else
            me.buttonState(me.assignWidget(self, "Button_given1"),false)
        end
    elseif checkMsg(msg.t, MsgCode.KINGDOM_GIVEN_SALARY) then
        disWaitLayer()
        
        local tmpView = kingdomView_foundation_award:create("kingdomView_foundation_award.csb")
        tmpView:setData(msg.c)
        me.runningScene():addChild(tmpView, me.MAXZORDER)
        me.showLayer(tmpView, "bg")

        --[[
        if self.pTime ~= nil then
            me.clearTimer(self.pTime)
        end

        local pReardsNum=#msg.c.items
        local mGoodsData = {}
        for key, var in pairs(msg.c.items) do
            table.insert(mGoodsData,1,var)
        end
        local pIndx = 1
        self:RewardsAnimation(mGoodsData,pIndx)
        pIndx = pIndx +1
        if pReardsNum > 1 then
            self.pTime = me.registTimer(-1, function(dt)
            self:RewardsAnimation(mGoodsData,pIndx)
                if pIndx == pReardsNum then
                    me.clearTimer(self.pTime)
                    self.pTime = nil
                end
                pIndx = pIndx +1
            end , 0.5)
        end
        ]]
    end
end

function kingdomView_foundation:RewardsAnimation(pData,pIndx)
         local function arrive(node)
             node:removeFromParentAndCleanup(true)
         end
         local function getGoodsIcon(pId)
            local pCfgData = cfg[CfgType.ETC][pId]
            local pIconStr = "item_"..pCfgData["icon"]..".png"
            return pIconStr
         end

         local var = pData[pIndx]
         local globalItems = me.createNode("Node_rewards_bg.csb")
         local pRewards = me.assignWidget(globalItems,"rewards_bg"):clone():setVisible(true)
         pRewards:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2))
         self:addChild(pRewards,me.ANIMATION)


         local pRewardsIcon = me.assignWidget(pRewards,"rewards_icon")
         pRewardsIcon:loadTexture(getGoodsIcon(var[1]),me.plistType)
         local pRewardsNum = me.assignWidget(pRewards,"rewards_num")
         pRewardsNum:setString("×"..Scientific(var[2]))


         local pMoveBy = cc.MoveBy:create(0.8,cc.p(0,90))
         local pFadeOut = cc.FadeOut:create(0.8)
         local pFadeOut1 = cc.FadeOut:create(0.8)
         local pFadeOut2 = cc.FadeOut:create(0.8)
         local pSpawn = cc.Spawn:create(pMoveBy,pFadeOut)

         local callback = cc.CallFunc:create(arrive)
         pRewardsIcon:runAction(pFadeOut1)
         pRewardsNum:runAction(pFadeOut2)
         pRewards:runAction(cc.Sequence:create(pSpawn, callback))
end

function kingdomView_foundation:onEnter()
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end,"kingdomView_foundation")
    self:setFoundationData()
    self:setTableView()
end
function kingdomView_foundation:setFoundationData()
    self.Text_food:setString(user.kingdon_foundationData.food)
    self.Text_wood:setString(user.kingdon_foundationData.wood)
    self.Text_stone:setString(user.kingdon_foundationData.stone)
    self.Text_gold:setString(user.kingdon_foundationData.gold)
end

function kingdomView_foundation:onEnterTransitionDidFinish()
end
function kingdomView_foundation:onExit()
    UserModel:removeLisener(self.modelkey)
    print("kingdomView_foundation:onExit()")
end
function kingdomView_foundation:setTableView()
    local function cellSizeForTable(table, idx)
        return 1040, 100
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()        
        local item =  me.createNode("Layer_KingdomFoundation_Item.csb")
        local infoStr = user.kingdon_foundationData.exHistory[#user.kingdon_foundationData.exHistory-idx]
        local infos = me.split2(infoStr,",")
        local layer = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            layer = me.assignWidget(item, "Panel_base"):clone()
            cell:setTag(idx)     
            cell:addChild(layer)  
        else
            layer = me.assignWidget(cell,"Panel_base")
        end    
        self:analyzeStrInfo(infos,layer)
        return cell
    end

    function numberOfCellsInTableView(table)
        return #user.kingdon_foundationData.exHistory
    end

    self.tableView = cc.TableView:create(cc.size(self.Panel_table:getContentSize().width,self.Panel_table:getContentSize().height))
    self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.tableView:setPosition(0, 0)
    self.tableView:setDelegate()
    self.Panel_table:addChild(self.tableView)
    self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.tableView:reloadData()
end

function kingdomView_foundation:analyzeStrInfo(infos, cell)
    me.assignWidget(cell,"Image_1"):setOpacity(50)
--    dump(infos)
    local richId = infos[2]
    local richTxt = ""
    me.assignWidget(cell,"Panel_richText"):removeAllChildren()
    me.assignWidget(cell,"Image_1_1"):setVisible(true)
    me.assignWidget(cell,"Image_1_0"):setVisible(true)
    me.assignWidget(cell,"Image_1_0_0"):setVisible(true)
    me.assignWidget(cell,"Image_1_0_0_0"):setVisible(true)
    if me.toNum(richId) == 2001 then--征税 
        me.assignWidget(cell,"Image_status"):loadTexture("wangzuo_tubiao_zhi_sui_lv.png",me.localType)
        me.assignWidget(cell,"Text_food"):setString("+"..infos[5])
        me.assignWidget(cell,"Text_wood"):setString("+"..infos[6])
        me.assignWidget(cell,"Text_stone"):setString("+"..infos[7])
        me.assignWidget(cell,"Text_gold"):setString("+"..infos[8])
        local day, sec = me.GetSecTime_Foundation(infos[1]/1000)
        me.assignWidget(cell,"Text_time_day"):setString(day)
        me.assignWidget(cell,"Text_time"):setString(sec)
        local pConfig = cfg[CfgType.NOTICE_INFO][me.toNum(richId)]
        local pStrData = me.split(pConfig["data"],"|")
        for key, var in pairs(pStrData) do
            richTxt = richTxt..pStrData[key]..infos[key+2]
        end
    elseif me.toNum(richId) == 2002 then--赏赐
        me.assignWidget(cell,"Image_status"):loadTexture("wangzuo_tubiao_zhi_chi_hong.png",me.localType)
        me.assignWidget(cell,"Text_food"):setString("+"..infos[7])
        me.assignWidget(cell,"Text_wood"):setString("+"..infos[8])
        me.assignWidget(cell,"Text_stone"):setString("+"..infos[9])
        me.assignWidget(cell,"Text_gold"):setString("+"..infos[10])
        local day, sec = me.GetSecTime_Foundation(infos[1]/1000)
        me.assignWidget(cell,"Text_time_day"):setString(day)
        me.assignWidget(cell,"Text_time"):setString(sec)
        local pConfig = cfg[CfgType.NOTICE_INFO][me.toNum(richId)]
        local pStrData = me.split(pConfig["data"],"|")
        for key, var in pairs(pStrData) do
            richTxt = richTxt..pStrData[key]..infos[key+2]
        end
    elseif me.toNum(richId) == 2003 then --国王变更
        richTxt = richTxt..cfg[CfgType.NOTICE_INFO][me.toNum(richId)].data
        me.assignWidget(cell,"Image_status"):loadTexture("wangzuo_tubiao_zhi_huan.png",me.localType)
        local day, sec = me.GetSecTime_Foundation(infos[1]/1000)
        me.assignWidget(cell,"Text_time_day"):setString(day)
        me.assignWidget(cell,"Text_time"):setString(sec)
        me.assignWidget(cell,"Text_food"):setString("-"..infos[3])
        me.assignWidget(cell,"Text_wood"):setString("-"..infos[4])
        me.assignWidget(cell,"Text_stone"):setString("-"..infos[5])
        me.assignWidget(cell,"Text_gold"):setString("-"..infos[6])
    elseif me.toNum(richId) == 2004 then --领取俸禄
        richTxt = richTxt..cfg[CfgType.NOTICE_INFO][me.toNum(richId)].data
        richTxt = me.strReplace(richTxt, "|", {infos[3], infos[4], infos[5]})
        me.assignWidget(cell,"Image_status"):loadTexture("wangzuo_tubiao_zhi_huan.png",me.localType)
        local day, sec = me.GetSecTime_Foundation(infos[1]/1000)
        me.assignWidget(cell,"Text_time_day"):setString(day)
        me.assignWidget(cell,"Text_time"):setString(sec)
        me.assignWidget(cell,"Text_food"):setString("-"..infos[6])
        me.assignWidget(cell,"Text_wood"):setString("-"..infos[7])
        me.assignWidget(cell,"Text_stone"):setString("-"..infos[8])
        me.assignWidget(cell,"Text_gold"):setString("-"..infos[9])
    elseif me.toNum(richId) == 2005 then 
        richTxt = richTxt..cfg[CfgType.NOTICE_INFO][me.toNum(richId)].data
        richTxt = me.strReplace(richTxt, "|", {infos[3], infos[4], infos[5], infos[6]})
        me.assignWidget(cell,"Image_status"):loadTexture("wangzuo_tubiao_zhi_huan.png",me.localType)
        local day, sec = me.GetSecTime_Foundation(infos[1]/1000)
        me.assignWidget(cell,"Text_time_day"):setString(day)
        me.assignWidget(cell,"Text_time"):setString(sec)
        me.assignWidget(cell,"Text_food"):setString("-"..infos[7])
        me.assignWidget(cell,"Text_wood"):setString("-"..infos[8])
        me.assignWidget(cell,"Text_stone"):setString("-"..infos[9])
        me.assignWidget(cell,"Text_gold"):setString("-"..infos[10])

    elseif me.toNum(richId) == 2006 then 
        richTxt = richTxt..cfg[CfgType.NOTICE_INFO][me.toNum(richId)].data
        richTxt = me.strReplace(richTxt, "|", {infos[3], infos[4], infos[5], infos[6]})
        me.assignWidget(cell,"Image_status"):loadTexture("wangzuo_tubiao_zhi_huan.png",me.localType)
        local day, sec = me.GetSecTime_Foundation(infos[1]/1000)
        me.assignWidget(cell,"Text_time_day"):setString(day)
        me.assignWidget(cell,"Text_time"):setString(sec)
        me.assignWidget(cell,"Text_food"):setString("")
        me.assignWidget(cell,"Text_wood"):setString("")
        me.assignWidget(cell,"Text_stone"):setString("")
        me.assignWidget(cell,"Text_gold"):setString("")
        me.assignWidget(cell,"Image_1_1"):setVisible(false)
        me.assignWidget(cell,"Image_1_0"):setVisible(false)
        me.assignWidget(cell,"Image_1_0_0"):setVisible(false)
        me.assignWidget(cell,"Image_1_0_0_0"):setVisible(false)
    else
        __G__TRACKBACK__("新的配置id")
    end
    local rt = mRichText:create(richTxt,me.assignWidget(cell,"Panel_richText"):getContentSize().width,nil,0)
    me.assignWidget(cell,"Panel_richText"):addChild(rt)
    rt:setPosition(0,0)
    rt:setTouchEnabled(false)
end