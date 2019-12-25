--[Comment]
--jnmo
fortExperiment = class("fortExperiment",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
fortExperiment.__index = fortExperiment
function fortExperiment:create(...)
    local layer = fortExperiment.new(...)
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
function fortExperiment:ctor()   
    print("fortExperiment ctor") 
    self.cp = cc.p(0,0)
    self.pTime = nil
    self.pHeroTime = nil
end
function fortExperiment:init()   
    print("fortExperiment init")
    self.friend_Info_bg = me.assignWidget(self,"friend_Info_bg"):setVisible(false)
    local Button_friend = me.assignWidget(self,"Button_friend")
    Button_friend:setSwallowTouches(true)
    self.mFriendBool = false
    me.registGuiClickEvent(Button_friend,function (node)     
        if self.mFriendBool then
          self.friend_Info_bg:setVisible(false)     
          self.mFriendBool = false
        else
          self.friend_Info_bg:setVisible(true)     
          self.mFriendBool = true
        end                               
    end)

    me.registGuiClickEventByName(self,"fixLayout",function (node)
      self.friend_Info_bg:setVisible(false)             
    end)
    return true
end
function fortExperiment:initInfo()
    self.mHaveHero = {} -- 名将
    self.mFortHero = {} -- 要塞
    self.mCountTime = 0
   -- dump(user.fortheroData)
    for key, var in pairs(user.fortheroData) do
        table.insert(self.mHaveHero,var)
        if var.open == 1 then
           self.mCountTime = var.countdown/1000
        end
    end   

    local function HeroSort(pa,pb)
       if pa["heroDefid"] < pb["heroDefid"] then
          return true
       end
    end
   
    table.sort(self.mHaveHero,HeroSort)
    -- dump(self.mHaveHero)
    if self.pTime then
       me.clearTimer(self.pTime)
    end
    if self.mCountTime ~= 0 then
       self.pTime = me.registTimer(-1,function (dt)
       if self.mCountTime > 0 then
          self.mCountTime = self.mCountTime - 1
        else
          me.clearTimer(self.pTime)
        end
       end,1)
    end
    me.assignWidget(self, "left_table_Node"):removeAllChildren()
    self:initHeroTab() 
    local pPitchFortId = pWorldMap:getPichFortPoint()
    local pPtchBool = true
    if pPitchFortId then
       local pFortData =  gameMap.fortDatas[pPitchFortId]:getDef()
       for key, var in pairs(self.mHaveHero) do         
           local pHeroConfig = cfg[CfgType.HERO][var["heroDefid"]]
           if pHeroConfig["herotype"] == pFortData["herotype"] then
              local pheroData = var
              self.mPitchHero = var
              self:setHeroTableOffset(key)
              local pHeroConfig = cfg[CfgType.HERO][pheroData["heroDefid"]]
              self:setHeroInfo(pheroData)
              self:getFortFort(pHeroConfig["herotype"])
              pPtchBool = false
              break
           end
       end       
    end
    
    if table.maxn(self.mHaveHero) ~= 0  and pPtchBool then
       local pheroData = self.mHaveHero[1]
       local pHeroConfig = cfg[CfgType.HERO][pheroData["heroDefid"]]
       self:setHeroInfo(pheroData)
       self.mPitchHero = pheroData
       self:getFortFort(pHeroConfig["herotype"])
    end
end
function fortExperiment:getFortFort(heroType)
    me.tableClear(self.mFortHero)
    local pHaveNum = 1
    local pPitchFortId = pWorldMap:getPichFortPoint()
    local pPitchBool = true
    for key, var in pairs(gameMap.fortDatas) do
        local pConfig = var:getDef()
        local pId = var["id"]  
        if heroType == pConfig["herotype"] then              
            local pData = user.fortWorldData[pId]                                        
            if pData == nil or pData.vType == 0 or pData.vType == 3 then    -- 未占领
               var.OccType = 3
               table.insert(self.mFortHero,var)
            else                
               if pData["mine"] == 1 then -- 自己联盟占领
                  var.OccType = 1
                  if pPitchFortId == var["id"]  then
                     table.insert(self.mFortHero, 1,var)
                     pPitchBool = false
                  else
                     if pPitchBool then
                        table.insert(self.mFortHero, 1,var)
                     else
                       table.insert(self.mFortHero, 2,var)
                     end
                  end                 
                  pHaveNum = pHaveNum +1
               elseif pData["mine"] == 0 then -- 敌对占领   
                  var.OccType  = 2              
                  table.insert(self.mFortHero, pHaveNum,var)                 
               end             
             end 
          end            
    end

    local function SortFort(pa,pb)
        local pAPoint = me.getCoordByFortId(pa["id"])
        local pBPoint = me.getCoordByFortId(pb["id"])
        if me.toNum(pa["OccType"]) == me.toNum(pb["OccType"]) then   
           if me.toNum(pAPoint["x"]) < me.toNum(pBPoint["x"]) then
              return true      
           end                         
        else
             if me.toNum(pa["OccType"]) < me.toNum(pb["OccType"]) then
                return true
             end           
        end
    end

    table.sort(self.mFortHero,SortFort)

    local pData1 = self.mFortHero[1]
    self.mPitchOn = 1
    local pPitchBool = true
    for key, var in pairs(self.mFortHero) do 
        local pConfig = var:getDef()
        if heroType == pConfig["herotype"] then              
            if pPitchFortId == var["id"]  then
                pData1 = var
                pPitchBool = false
                break
            end
            self.mPitchOn =self.mPitchOn +1
        end
    end
    if pPitchBool then
       self.mPitchOn = 1
    end
    
    local pPoint = me.getCoordByFortId(pData1["id"])
    self.cp = cc.p(pPoint.x,pPoint.y)
    me.assignWidget(self, "up_table_Node"):removeAllChildren()
    self:initFortTab()
end
function fortExperiment:setHeroTableOffset(pTag)

    local pHeroNum = #self.mHaveHero
    if pTag > 3 then     
       local pOffset = cc.p(0,0)
       if (pTag + 2) < pHeroNum then
          pOffset = cc.p(0,-(pHeroNum - 2 - pTag) * 182)
       else
          pOffset = cc.p(0,0)
       end
       self.HerotableView:reloadData()
       self.HerotableView:setContentOffset(pOffset)      
    end
    self.HeroPitchImg:setPosition(cc.p(self:getHeroCellPoint(pTag,pHeroNum)))
end
function fortExperiment:setHeroInfo(pData)
    if pData then
--        dump(pData)      
       if self.pHeroTime ~= nil then
          me.clearTimer(self.pHeroTime)
       end      
       local pHeroId = pData["heroDefid"]
       if pData["open"] == 1 then
          pHeroId = pData["startId"]
       end
       self.mHeroId = pHeroId
       local pHeroConfig = cfg[CfgType.HERO][pHeroId]
    --   dump(pHeroConfig)
       local pheroConfigNow = cfg[CfgType.HERO][pData["heroDefid"]]
       local pHeroIcon = me.assignWidget(self,"right_bg_icon")
       pHeroIcon:loadTexture("shengjiang_quansheng_"..pheroConfigNow["icon"]..".png",me.plistType)

       local pHeroName = me.assignWidget(self,"next_name")
       pHeroName:setString(pHeroConfig["name"])

       local pNextConent = me.assignWidget(self,"next_conent")
       local pHpValue = 0
       local pOpenValue = 0
       local pBtnStr = "开启试炼"
       local pSurpurStr = ""
       if pData["open"] == 1 then
          pBtnStr = "正在试炼"
          pSurpurStr = "剩余试炼次数 "
          pHpValue = pData["surplusBlood"]
          pOpenValue = pData["CurNum"]
          local pCountTime = self.mCountTime
          pNextConent:setString("试炼结束倒计时"..me.formartSecTime(pCountTime))
          if pCountTime > 0 then
             self.pHeroTime = me.registTimer(-1,function (dt)
                 if pCountTime > 0 then
                    pCountTime = pCountTime - 1                  
                    pNextConent:setString("试炼结束倒计时"..me.formartSecTime(pCountTime))
                 else
                    me.clearTimer(self.pHeroTime)
                 end
            end,1)
          end
          
       else
          pBtnStr = "开启试炼"
          pHpValue = pHeroConfig["hp"]
          pOpenValue = pData["initNm"]
          pNextConent:setString("每天20:00-22:00盟主或副盟主可开启试炼")
          pSurpurStr = "试炼次数 "
       end

       local pHpNum = pHpValue/pHeroConfig["hp"]*100
       local pHpNumStr = pHpNum
       if pHpNum ~= 100 then
          pHpNumStr = string.format("%.2f",pHpNum)
       end
       local pBlodValue = me.assignWidget(self,"next_general_blood_value")
       pBlodValue:setString("剩余血量 "..pHpNumStr .. "%")
     
       local pLoadingBloodValue = me.assignWidget(self,"n_g_blood_value")
       pLoadingBloodValue:setString(pHpValue)

       local pLoading = me.assignWidget(self,"LoadingBar_blood")
       pLoading:setPercent(pHpNum)
       local pAmicaNum = 0
       local pAmicable = me.assignWidget(self,"next_general_amicable_value")
       pAmicable:setString("试炼度 "..pheroConfigNow["leveltxt"])
       local pHeroConfig = cfg[CfgType.HERO][pData["heroDefid"]]
       me.assignWidget(self,"next_general_amicable_value_0"):setString("试炼类型：".. battle_types[pHeroConfig.battletype])
       local pLoadingamicableValue = me.assignWidget(self,"n_g_amicable_value")
       if pheroConfigNow["nextid"] ~= 0  then
           local pheroConfigNext = cfg[CfgType.HERO][pheroConfigNow["nextid"]] 
           pAmicaNum = pData["amityExp"]/pheroConfigNext["exp"]*100    
           pLoadingamicableValue:setString(pData["amityExp"].."/"..pheroConfigNext["exp"])
       else
          pLoadingamicableValue:setString("-".."/".."-")
          pAmicaNum = 0
       end
      
       local pLoadingamicable = me.assignWidget(self,"LoadingBar_amicable")
       pLoadingamicable:setPercent(pAmicaNum)

       local pOpenValueLabel = me.assignWidget(self,"next_surplus_value")
       pOpenValueLabel:setString(pSurpurStr..pOpenValue)

       me.registGuiClickEvent(pHeroIcon,function (node)
          self.friend_Info_bg:setVisible(false)      
          self.mFriendBool = false
          local pHeroInfo = fortHeroInfo:create("fortheroInfoLayer.csb") 
          pHeroInfo:setData(pData)
          pWorldMap:addChild(pHeroInfo, me.MAXZORDER)
       end)

      local pButtonOpen = me.assignWidget(self,"Button_open")
      me.assignWidget(pButtonOpen, "text_title_btn"):setString(pBtnStr)
      me.registGuiClickEvent(pButtonOpen,function (node)
          if pData["open"] == 1 then               
                   local pPoint = cc.p(pData["x"],pData["y"])
                   local pos = cc.p(pPoint.x,pPoint.y)            
                  -- NetMan:send(_MSG.worldfortherorankgeneral(pPoint))   
                   LookMap(pos,"fortGeneralView")
               
          else
            NetMan:send(_MSG.worldfortheroopengeneral(self.cp))
          end          
      end)
     local pButtonRank = me.assignWidget(self,"Button_rank")
      me.registGuiClickEvent(pButtonRank,function (node)     
           local pHeroConfig = cfg[CfgType.HERO][self.mHeroId]    
           NetMan:send(_MSG.worldfortherohoistoryrankgeneral(pHeroConfig["herotype"]))
      end)
    end
end
function fortExperiment:initHeroTab()
    self.HerotableView = nil
    local pNum = #self.mHaveHero
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)
       self.mFriendBool = false
       local pheroData = self.mHaveHero[cell:getIdx()+1]
       local pHeroConfig = cfg[CfgType.HERO][pheroData["heroDefid"]]
       self:setHeroInfo(pheroData)
       self.mPitchHero = pheroData
       self:getFortFort(pHeroConfig["herotype"])     
       self.HeroPitchImg:setPosition(cc.p(self:getHeroCellPoint(cell:getIdx()+1,pNum)))
    end
    local function cellSizeForTable(table, idx)
        return 289, 172
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)
        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            local pHeroCell = me.assignWidget(self,"left_cell"):clone():setVisible(true)
            self:setHeroCell(pHeroCell,self.mHaveHero[idx+1])
            pHeroCell:setAnchorPoint(cc.p(0.5, 0.5))
            pHeroCell:setPosition(cc.p(144.5, 86))
            cell:addChild(pHeroCell)
        else 
           local pHeroCell = me.assignWidget(cell,"left_cell")
           self:setHeroCell(pHeroCell,self.mHaveHero[idx+1])
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        return pNum
    end

    tableView = cc.TableView:create(cc.size(289, 533))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setAnchorPoint(cc.p(0, 0))
    tableView:setPosition(cc.p(0, 0))
    tableView:setDelegate()
    me.assignWidget(self, "left_table_Node"):addChild(tableView)
    -- registerScriptHandler functions must be before the reloadData funtion
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
    self.HerotableView = tableView
    self.HeroPitchImg = ccui.ImageView:create()            
    self.HeroPitchImg:loadTexture("beibao_xuanzhong_guang.png", me.localType) 
    self.HeroPitchImg:setContentSize(cc.size(286, 184))
    self.HeroPitchImg:setScale9Enabled(true)
    self.HeroPitchImg:setCapInsets(cc.rect(20, 20, 1, 1))
    self.HeroPitchImg:setPosition(cc.p(self:getHeroCellPoint(1,pNum)))
    self.HeroPitchImg:setLocalZOrder(10)
    self.HerotableView:addChild(self.HeroPitchImg)  
end
function fortExperiment:getHeroCellPoint(pTag,pNum)
    pTag = me.toNum(pTag)
    local pPointX = 144.5
    local pPointY = (pNum - pTag) * 172 + 86
    return pPointX,pPointY
end
function fortExperiment:setHeroCell(pNode,pData)
    if pData then
       local pHeroId = pData["heroDefid"]
       if pData["open"] == 1 then
          pHeroId = pData["startId"]
       end
       local pHeroConfig = cfg[CfgType.HERO][pHeroId]
       local pheroConfigNow = cfg[CfgType.HERO][pData["heroDefid"]]
       local pHeroIcon = me.assignWidget(pNode,"left_bg_icon")
       local pIconName = "shengjiang_tou_"..pheroConfigNow["icon"]..".png"
       pHeroIcon:loadTexture(pIconName,me.plistType)

       local pHeroName = me.assignWidget(pNode,"left_name")
       pHeroName:setString(pHeroConfig["name"])
       local pAmicable = me.assignWidget(pNode,"left_amicable")
       pAmicable:setString("试炼度  "..pheroConfigNow["leveltxt"])
       if pData["open"] == 1 then
           me.assignWidget(pNode,"left_open"):setVisible(true)
       else
           me.assignWidget(pNode,"left_open"):setVisible(false)       
       end
       me.assignWidget(pNode,"Panel_start"):removeAllChildren()
       self:setStar(pHeroConfig["hardstar"],pNode)
    end
end
function fortExperiment:setStar(pStarNum,pNode)
      
     local pStar = math.floor(pStarNum / 2)
     local pmore = pStarNum % 2

     for var = 1 ,pStar do
         local pStarIcon = me.assignWidget(pNode,"start_one"):clone():setVisible(true)
         pStarIcon:setPosition(cc.p( (var - 1) * 18, 0))
         me.assignWidget(pNode,"Panel_start"):addChild(pStarIcon)
     end
     if pmore ~= 0 then
        local pStargalfIcon = me.assignWidget(pNode,"start_half"):clone():setVisible(true)
         pStargalfIcon:setPosition(cc.p((pStar) * 18, 0))
         me.assignWidget(pNode,"Panel_start"):addChild(pStargalfIcon)
     end
end
function fortExperiment:initFortTab()
    self.FortPitchImg = nil
    self.ForttableView = nil
    local pNum = #self.mFortHero
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)
        self.mFriendBool = false
        local pId = cell:getIdx()+1
        local pData = self.mFortHero[pId]
        if pData then
          local pFortData = user.fortWorldData[pData["id"]]            
          if pFortData == nil then    -- 未占领 
             showTips("未占领")        
           else                
            if pFortData["mine"] == 1 then -- 自己联盟占领
                self.FortPitchImg:setPosition(cc.p(self:getFortCellPoint(pId)))                 
                local pPoint = me.getCoordByFortId(pData["id"])
                self.cp = cc.p(pPoint.x,pPoint.y)
            elseif pFortData["mine"] == 0 then -- 敌对占领
               showTips("被敌方占领") 
            end             
         end 
        end       
    end
    local function cellSizeForTable(table, idx)
        return 269 + 20, 127
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)
        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            local pFortCell = me.assignWidget(self,"up_table_cell"):clone():setVisible(true)
            self:setFortCell(pFortCell,self.mFortHero[idx+1])
            local pButtonpoint = me.assignWidget(pFortCell,"up_fort_point")
            pButtonpoint:setTag(idx+1)
            me.registGuiClickEvent(pButtonpoint,function (node)
                local pId = node:getTag()
                local pData = self.mFortHero[idx+1]
                local pFortData = user.fortWorldData[pData["id"]]
                if pFortData   then
                   local pPoint = me.getCoordByFortId(pData["id"])
                   local pos = cc.p(pPoint.x,pPoint.y)
                   LookMap(pos,"fortGeneralView")
                end
                
            end)
            pButtonpoint:setSwallowTouches(true)
            pFortCell:setAnchorPoint(cc.p(0, 0))
            pFortCell:setPosition(cc.p(0, 0))
            cell:addChild(pFortCell)
        else 
           local pFortCell = me.assignWidget(cell,"up_table_cell")
           self:setFortCell(pFortCell,self.mFortHero[idx+1])
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        return pNum
    end

    tableView = cc.TableView:create(cc.size(858, 127))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setAnchorPoint(cc.p(0, 0))
    tableView:setPosition(cc.p(0, 0))
    tableView:setDelegate()
    me.assignWidget(self, "up_table_Node"):addChild(tableView)
    -- registerScriptHandler functions must be before the reloadData funtion
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
    self.ForttableView = tableView
    self.FortPitchImg = ccui.ImageView:create()            
    self.FortPitchImg:loadTexture("beibao_xuanzhong_guang.png", me.localType)
    self.FortPitchImg:setContentSize(cc.size(106, 106))
    self.FortPitchImg:setScale9Enabled(true)
    self.FortPitchImg:setCapInsets(cc.rect(20, 20, 1, 1))
    self.FortPitchImg:setPosition(cc.p(self:getFortCellPoint(self.mPitchOn)))
    self.FortPitchImg:setLocalZOrder(10)
    self.ForttableView:addChild(self.FortPitchImg)
end
function fortExperiment:getFortCellPoint(pTag)
    pTag = me.toNum(pTag)
    local pPointX = (pTag - 1) * 289 + 55
    local pPointY = 63.5
    return pPointX, pPointY
end
function fortExperiment:setFortCell(pNode,pData)
   if pData then    
      local pConfigData = GFortData()[pData["id"]]  
      local pFortIcon = me.assignWidget(pNode,"up_fort_icon")
      pFortIcon:loadTexture("shengjiang_yaosai_xiao_"..pConfigData["icon"]..".png",me.plistType)

      local pFortData = user.fortWorldData[pData["id"]]    
      local pFortOccupy = "yaosai_25.png"
      local pFortOccupyBg = "shengjiang_beijing_yaosai_hui.png"
      if pFortData == nil then    -- 未占领
            pFortOccupy = "yaosai_25.png"
            pFortOccupyBg = "shengjiang_beijing_yaosai_hui.png"
      else                
            if pFortData["mine"] == 1 then -- 自己联盟占领
                pFortOccupy = "yaosai_27.png"  
                pFortOccupyBg = "shengjiang_beijing_yaosai_lan.png"
            elseif pFortData["mine"] == 0 then -- 敌对占领
                pFortOccupy = "yaosai_26.png"
                pFortOccupyBg = "shengjiang_beijing_yaosai_hong.png"
            end             
       end     
      local pFortOccIconBg = me.assignWidget(pNode,"up_fort_bg")
      pFortOccIconBg:loadTexture(pFortOccupyBg,me.plistType)
              
      local pFortOccIcon = me.assignWidget(pNode,"up_fort_type_icon") 
      pFortOccIcon:loadTexture(pFortOccupy,me.plistType)

      local pFortName = me.assignWidget(pNode,"up_fort_name")
      pFortName:setString(pConfigData["name"])

      local pFortPoint = me.assignWidget(pNode,"up_fort_point")
      local pPoint = me.getCoordByFortId(pData["id"])
      pFortPoint:setString("("..pPoint.x..","..pPoint.y..")")
      if pPoint.x == self.mPitchHero.x and pPoint.y == self.mPitchHero.y and self.mPitchHero["open"] == 1 then
         me.assignWidget(pNode,"up_fort_exper"):setVisible(true)
      else
         me.assignWidget(pNode,"up_fort_exper"):setVisible(false) 
      end
   end 
end
function fortExperiment:updatement(msg)

    if checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_OPEN) then           
         local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
         pCityCommon:CommonSpecific(ALL_COMMON_OPEN_EXPER)
         pCityCommon:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2 + 50))
         me.runningScene():addChild(pCityCommon, me.ANIMATION)
         NetMan:send(_MSG.worldfortherogeneral()) 
    elseif checkMsg(msg.t, MsgCode.WORLD_FORTRESS_FAMILY_INIT) then   
        self:initInfo()
    elseif checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_HOSTORY_GENERAL) then
        local pfortRankView = fortRankView:create("fortRankview.csb") 
        pWorldMap:addChild(pfortRankView, me.MAXZORDER) 
    end    
end
function fortExperiment:onEnter()
    print("fortExperiment onEnter") 
	--me.doLayout(self,me.winSize)  
     self.modelkeyment = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:updatement(msg)
    end ,"fortExperiment")  
end
function fortExperiment:onEnterTransitionDidFinish()
	print("fortExperiment onEnterTransitionDidFinish") 
end
function fortExperiment:onExit()
    print("fortExperiment onExit")    
    UserModel:removeLisener(self.modelkeyment)
    me.clearTimer(self.pTime)
    me.clearTimer(self.pHeroTime)
end
function fortExperiment:close()
    self:removeFromParentAndCleanup(true)  
end
