--[Comment]
--jnmo
Warship_tech_up = class("Warship_tech_up",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
Warship_tech_up.__index = Warship_tech_up
function Warship_tech_up:create(...)
    local layer = Warship_tech_up.new(...)
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
function Warship_tech_up:ctor()   
    print("Warship_tech_up ctor") 
    self.mData = {}
end
function Warship_tech_up:init()   
    print("Warship_tech_up init")
	me.registGuiClickEventByName(self,"close",function (node)
        self:close()     
    end)    
    return true
end
function Warship_tech_up:setData(pdata)
    if pdata then
       self.mData = pdata 
       local pConfig = pdata.Config
       local pdata = cfg[CfgType.SHIP_TECH][me.toNum(self.mData.Config.nextid)] 
       local pNeedExp = 0
       local pTechNeed = {} 
       if pdata then   
           pNeedExp = pdata.needItem
           local pTable = me.split(pdata.itemType,",")
           
           local pUse = user.pkg
           for key, var in pairs(pTable) do
               local pStr = me.split(var,":")
               local pId = me.toNum(pStr[1])
               local pConfig = cfg[CfgType.ETC][pId]
               local pTechData = {}
               pTechData.Config = pConfig
               local pCount = 0
               local HaveData = nil
               for key, var in pairs(pUse) do
                   if var.defid == pId then
                      pCount = var.count
                      HaveData = var 
                      break
                   end
               end
               pTechData.count = pCount
               pTechData.HaveData = HaveData
               table.insert(pTechNeed,pTechData)
              end
        end
       local pWarshipIcon = me.assignWidget(self,"warship_icon")
       pWarshipIcon:loadTexture("battleship_"..pConfig["icon"]..".png",me.plistType)
       
       local title = me.assignWidget(self,"title")
       title:setString(pConfig.name.."  lv."..pConfig.level)

      -- local pTechStr = cfg[CfgType.LORD_INFO][pConfig.exttype]
       local Panel_nature = me.assignWidget(self,"Panel_nature")
       Panel_nature:removeAllChildren()
       local before = pConfig.beforetxt
       local success = pConfig.successtxt
       local pStrNature = "<txt0016,dad6c0>"..pConfig.desc.. " + ".. before .." &<img3232,000000>zhanjian_jiantou_lv_you.png&<txt0016,4ce22e> "..success.."&"     
       local rcf = mRichText:create(pStrNature, 600, nil,5)
       rcf:setAnchorPoint(cc.p(0,0.5))
       Panel_nature:addChild(rcf)
      
       local Panel_up_need = me.assignWidget(self,"Panel_up_need")
       Panel_up_need:removeAllChildren()
       local pNeed = pNeedExp - self.mData.exp
       local pNeedStr = "<txt0016,d6d1c9>距离下一级升级还需要&<txt0016,72e744>".. pNeed .."&<txt0016,d6d1c9>艘舰船&"
       local rcfNeed = mRichText:create(pNeedStr, 500, nil,5)
       rcfNeed:setAnchorPoint(cc.p(0,0.5))
     --  Panel_up_need:addChild(rcfNeed)

       local pexp_num = me.assignWidget(self,"exp_num")
       pexp_num:setString(self.mData.exp.."/"..pNeedExp)

       local LoadingBar_2 = me.assignWidget(self,"LoadingBar_2")
       LoadingBar_2:setPercent(self.mData.exp*100/pNeedExp)
       me.assignWidget(self, "Panel_table"):removeAllChildren()
       self:initTechTable(pTechNeed)
    end
end
--
function Warship_tech_up:initTechTable(pTechTab)
    local iNum  = #pTechTab
            
    local function scrollViewDidScroll(view)
        -- print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        -- print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)
        
    end

    local function cellSizeForTable(table, idx)
        return 730, 121
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()       
        if nil == cell then
           cell = cc.TableViewCell:new()
           local pTechCell = me.assignWidget(self,"Panel_cell"):clone():setVisible(true)
           pTechCell:setPosition(cc.p(375,60))
           self:setCell(pTechCell,pTechTab[idx+1],idx+1)  
           local Button_formation = me.assignWidget(pTechCell,"Button_formation")
           Button_formation:setTag(idx+1)
           -- 编队
           me.registGuiClickEvent(Button_formation,function (node)
                print("编队")
                local pConfig = self.mData.Config
                dump(pConfig)
                local pEtcConfig =pTechTab[idx+1] 
                dump(pEtcConfig)
           --     NetMan:send(_MSG.Ship_Tech_up(me.toNum(pConfig.type),me.toNum(pConfig.order),pEtcConfig.uid,1))
                  self.BackpackUse = BackpackUse:create("backpack/BackpackUse.csb")
                  self:addChild(self.BackpackUse, me.MAXZORDER);  
                  self.BackpackUse:setData(pEtcConfig.HaveData)                    
                  self.BackpackUse:setTypee(BackpackUse.WarshipTech)
                  self.BackpackUse:setWarship(me.toNum(pConfig.type),me.toNum(pConfig.order),1)
                --  self.BackpackUse:setParent(self)
                  me.showLayer(self.BackpackUse, "bg")     
           end)
           local Button_gain = me.assignWidget(pTechCell,"Button_gain")
           Button_gain:setTag(idx+1)
           -- 获取
           me.registGuiClickEvent(Button_gain,function (node)
                print("获取")

                local function gotoGetWayCallback(getWayType)
                    if getWayType == 1 then
                        local shipSail = shipSailView:create("warning/shipSailView.csb")
                        mainCity:addChild(shipSail, me.MAXZORDER)
                        me.showLayer(shipSail,"bg")
                    elseif getWayType == 2 then
                        -- TODO:cityView 1224行有cityView.promotionView == nil的判断！！
                        mainCity.promotionView = promotionView:create("paymentView.csb")
                        mainCity.promotionView:setViewTypeID(2)
                        mainCity.promotionView:setTaskGuideIndex(ACTIVITY_SHIP_PACKAGE)
                        mainCity:addChild(mainCity.promotionView, me.MAXZORDER);
                        me.showLayer(mainCity.promotionView, "bg_frame")
                    end
                    self:removeFromParentAndCleanup (true)
                end

                local teachData = pTechTab[idx+1]

                local itenNum = 0
                for k, v in pairs (user.pkg) do
                  if v.defid == teachData.Config.id then
                    itenNum = itemNum + v.count
                  end
                end

       

                local getWayView = runeGetWayView:create("rune/runeGetWayView.csb")
                mainCity:addChild(getWayView, me.MAXZORDER)
                me.showLayer(getWayView,"bg")
                getWayView:setData(teachData.Config.id)
           end)
           Button_formation:setSwallowTouches(false)
           cell:addChild(pTechCell)                                 
        else
           local pTechCell = me.assignWidget(cell,"Panel_cell")
           self:setCell(pTechCell,pTechTab[idx+1],idx+1)  
        end  
        return cell
    end

    function numberOfCellsInTableView(table)
        return iNum
    end

    tableView = cc.TableView:create(cc.size(750,300))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setPosition(0, 0)
    tableView:setDelegate()
    me.assignWidget(self, "Panel_table"):addChild(tableView)
    -- registerScriptHandler functions must be before the reloadData funtion
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()   
    self.TableView = tableView
end
function Warship_tech_up:setCell(node,pData,pId)
   if pData then  
    local pConfig = pData.Config
    local pPanel_icon = me.assignWidget(node,"Panel_icon")
    pPanel_icon:removeAllChildren()

    local pIcon = me.createSprite("item_"..pConfig["icon"]..".png")
    pIcon:setScale(0.8)
    pPanel_icon:addChild(pIcon)   

    local pName = me.assignWidget(node,"cell_name")
    pName:setString(pConfig.name)

    local pDesic = me.assignWidget(node,"cell_desice")
    pDesic:setString(pConfig.describe)

    local cell_num = me.assignWidget(node,"cell_num")
    cell_num:setString(pData.count)
    local Image_txt_bg = me.assignWidget(node,"Image_txt_bg")
    local Button_formation = me.assignWidget(node,"Button_formation")

    local Button_gain = me.assignWidget(node,"Button_gain")
    if pData.count == 0 then
       Button_gain:setVisible(true)
       Button_formation:setVisible(false)
       Image_txt_bg:setVisible(false)       
       me.graySprite(pIcon)
    else
       Button_gain:setVisible(false)
       Button_formation:setVisible(true)
       Image_txt_bg:setVisible(true)
       me.revokeSprite(pIcon)
    end
   end
end
function Warship_tech_up:update(msg)
    if checkMsg(msg.t, MsgCode.MSG_SHIP_TECH_UP) then  
       local pConfig = self.mData.Config 
       local pdata = user.Warship_Tech[me.toNum(pConfig.type)][me.toNum(pConfig.order)]
       self:setShowExp(pdata)
       self:setData(pdata)  
    end
end
function Warship_tech_up:setShowExp(pdata)
    if pdata then
       local pOldCon = self.mData.Config 
       local pNewCon = pdata.Config
       local pGainExp = 0
       if pOldCon.level == pNewCon.level then
          pGainExp = pdata.exp - self.mData.exp
       elseif pNewCon.level > pOldCon.level then
          local pLevel = pNewCon.level- pOldCon.level
          
          print("pLevel"..pLevel)
          if pLevel > 1 then
             local mNextdata = nil
             for var = 1 , pLevel do
                 if var  ==1 then
                   local pNextdata = cfg[CfgType.SHIP_TECH][me.toNum(self.mData.Config.nextid)]    
                   if pNextdata then
                       mNextdata = pNextdata
                      pGainExp = pNextdata.needItem - self.mData.exp           
                   end
                 elseif var == pNewCon.level then
                     pGainExp = pGainExp - pdata.exp   
                 else
                    local pNextdata = cfg[CfgType.SHIP_TECH][me.toNum(mNextdata.nextid)]  
                      
                    if pNextdata then
                      mNextdata = pNextdata
                      pGainExp = pNextdata.needItem  +  pGainExp   
                    end
                 end
             end          
          else
            local pNextdata = cfg[CfgType.SHIP_TECH][me.toNum(self.mData.Config.nextid)]    
            if pNextdata then
               pGainExp = pNextdata.needItem - self.mData.exp + pdata.exp                     
             end           
          end
       end
       if pGainExp > 0  then
          showTips("获得"..pGainExp.."艘舰船")
       end     
    end
end
function Warship_tech_up:onEnter()
    print("Warship_tech_up onEnter") 
	me.doLayout(self,me.winSize)  
    self.modelkey = UserModel:registerLisener(function(msg)  -- 注册消息通知
        self:update(msg)        
    end)
end
function Warship_tech_up:onEnterTransitionDidFinish()
	print("Warship_tech_up onEnterTransitionDidFinish") 
end
function Warship_tech_up:onExit()
    print("Warship_tech_up onExit")
    UserModel:removeLisener(self.modelkey) -- 删除消息通知      
end
function Warship_tech_up:close()
    self:removeFromParentAndCleanup(true)  

end
