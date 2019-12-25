--[Comment]
--jnmo
fortrecruit = class("fortrecruit",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
fortrecruit.__index = fortrecruit
function fortrecruit:create(...)
    local layer = fortrecruit.new(...)
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
function fortrecruit:ctor()   
    print("fortrecruit ctor") 
    self.pFortSolider = nil
end
function fortrecruit:init()   
    print("fortrecruit init")
	 
    self.mHeroSoldier = {}  
    for key, var in pairs(user.fortHeroSoldierList) do
        local pHeroConfig = cfg[CfgType.HERO][var["heroid"]]
        local pRecuritConfig = cfg[CfgType.MIRACLE_RECTUIT_DEF][var["soldierid"]]
        local pRecurit = 0 -- 不可招募
        if pHeroConfig["level"] >= pRecuritConfig["needherolevel"] then
           pRecurit = 1  
        end
        var.Recurit = pRecurit
        table.insert(self.mHeroSoldier,var)
    end
    local function RecuritSort(pa,pb)
        if me.toNum(pa["Recurit"]) > me.toNum(pb["Recurit"]) then
           return true
        end
    end
    table.sort(self.mHeroSoldier,RecuritSort)
    self:initHeroTab()  
     
    return true
end
function fortrecruit:initHeroTab()
     
    local pNum = #self.mHeroSoldier
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)
        local pId = cell:getIdx()+1
        local pHero = self.mHeroSoldier[pId]
        self.mHero = pHero
        local pHeroConfig = cfg[CfgType.HERO][pHero["heroid"]]
        local pRecuritConfig = cfg[CfgType.MIRACLE_RECTUIT_DEF][pHero["soldierid"]]
        if pHeroConfig["level"] < pRecuritConfig["needherolevel"] then
           showTips("试炼度不够")
        else
            NetMan:send(_MSG.worldSoldierRecurit(pHeroConfig["herotype"])) 
        end
       
    end
    local function cellSizeForTable(table, idx)
        return 872, 166 + 8
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)
        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            local pHeroCell = me.assignWidget(self,"Right_hero_cell"):clone():setVisible(true)
            self:setHeroCell(pHeroCell,self.mHeroSoldier[idx+1])
            pHeroCell:setSwallowTouches(false)
            local Button_Recurit = me.assignWidget(pHeroCell,"Button_Recurit")
            Button_Recurit:setTag(idx+1)
            me.registGuiClickEvent(Button_Recurit,function (node)
                local pId = node:getTag()                
                  
            end)
            Button_Recurit:setSwallowTouches(false)
            pHeroCell:setPosition(cc.p(0, 8))
            cell:addChild(pHeroCell)
        else 
           local pHeroCell = me.assignWidget(cell,"Right_hero_cell")
           local Button_Recurit = me.assignWidget(pHeroCell,"Button_Recurit")
            Button_Recurit:setTag(idx+1)
           self:setHeroCell(pHeroCell,self.mHeroSoldier[idx+1])
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        return pNum
    end

    tableView = cc.TableView:create(cc.size(872, 530))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setAnchorPoint(cc.p(0, 0))
    tableView:setPosition(cc.p(0, 0))
    tableView:setDelegate()
    me.assignWidget(self, "Table_Node"):addChild(tableView)
    -- registerScriptHandler functions must be before the reloadData funtion
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData() 
end
function fortrecruit:setHeroCell(pNode,pData)
    if pData then
      local pHeroConfig = cfg[CfgType.HERO][pData["heroid"]]
      --local hero_icon_lage = me.assignWidget(pNode,"hero_icon_lage")
      --hero_icon_lage:loadTexture("shengjiang_quansheng_"..pHeroConfig["icon"]..".png",me.plistType)

      -- local Panel_Icon = me.assignWidget(pNode,"Panel_Icon")
      -- Panel_Icon:removeAllChildren()

      -- local tempSize = Panel_Icon:getContentSize()
      -- local hero_icon = ccui.ImageView:create()            
      -- hero_icon:loadTexture(heroSmallHeadIcon(pHeroConfig["icon"]), me.plistType)
      -- hero_icon:setAnchorPoint(cc.p(0.5, 0.5))
      -- hero_icon:setPosition(cc.p(tempSize.width / 2, tempSize.height / 2))
      -- Panel_Icon:addChild(hero_icon)

      local img_hero = me.assignWidget(pNode, "img_hero")
      img_hero:loadTexture(heroSmallHeadIcon(pHeroConfig["icon"]), me.localType)

       local hero_friendly = me.assignWidget(pNode,"hero_friendly")
       hero_friendly:setString("试炼度"..pHeroConfig["leveltxt"])

       local hero_name = me.assignWidget(pNode,"hero_name")
       hero_name:setString(pHeroConfig["name"])

       local Node_star = me.assignWidget(pNode,"Panel_star")
       Node_star:removeAllChildren()
       local pRecuritConfig = cfg[CfgType.MIRACLE_RECTUIT_DEF][pData["soldierid"]]
       local hero_Recruit_soldier = me.assignWidget(pNode,"hero_Recruit_soldier")
       hero_Recruit_soldier:setString(pRecuritConfig["daytxt"])
       local need_level = me.assignWidget(pNode,"need_level")
       local Button_Recurit = me.assignWidget(pNode,"Button_Recurit")
       local pOpenBool = false 
       if pHeroConfig["level"] < pRecuritConfig["needherolevel"] then
          Button_Recurit:setVisible(false)
          me.graySprite(img_hero)
          need_level:setVisible(true)
          need_level:setString("试炼度 "..pRecuritConfig["herolvtxt"].." 才可招募")
          pOpenBool = false
          hero_Recruit_soldier:setTextColor(cc.c3b(0xb6, 0xb6, 0xb6))
          hero_name:setTextColor(cc.c3b(0xb6, 0xb6, 0xb6))
          me.assignWidget(pNode,"Text_3"):setVisible(false)
          hero_friendly:setTextColor(cc.c3b(0x5b, 0xa9, 0x30))
        else
          Button_Recurit:setVisible(true)
          need_level:setVisible(false)
          me.revokeSprite(img_hero)
          pOpenBool = true
          hero_Recruit_soldier:setTextColor(cc.c3b(0xe5, 0xd7, 0xac))
          hero_name:setTextColor(cc.c3b(0xd6, 0xa7, 0x27))
          hero_friendly:setTextColor(cc.c3b(0x5b, 0xa9, 0x30))
          me.assignWidget(pNode,"Text_3"):setVisible(true)         
          self:setStar(pHeroConfig["qijistar"],Node_star,pOpenBool)
       end      
       local Panel_ash = me.assignWidget(pNode,"Panel_ash")
       Panel_ash:removeAllChildren()
       self:setHeroStar(pHeroConfig["qijistar"],Panel_ash,pOpenBool)

    end
end
function fortrecruit:setHeroStar(pStarNum,pNode,pOpenBool)
     local pStar = math.floor(pStarNum / 2)
     local pmore = pStarNum % 2
     if pOpenBool then
        for var = 1 ,pStar do
         local pStarIcon = me.assignWidget(self,"recruit_star"):clone():setVisible(true)
         pStarIcon:setScale(1.0)
         pStarIcon:setPosition(cc.p((var-1) * 24, 0))
         pNode:addChild(pStarIcon)
       end
       if pmore ~= 0 then
          local pStargalfIcon = me.assignWidget(self,"recruit_star_half"):clone():setVisible(true)
          pStargalfIcon:setScale(1.0)
          pStargalfIcon:setPosition(cc.p((pStar) * 24, 0))
          pNode:addChild(pStargalfIcon)
         end
     else
         for var = 1 ,pStar do
           local pStarIcon = me.assignWidget(self,"recruit_star_ash"):clone():setVisible(true)
           pStarIcon:setPosition(cc.p((var-1) * 24, 0))
           pNode:addChild(pStarIcon)
         end
         if pmore ~= 0 then
            local pStargalfIcon = me.assignWidget(self,"recruit_star_half_ash"):clone():setVisible(true)
            pStargalfIcon:setPosition(cc.p((pStar) * 24, 0))
            pNode:addChild(pStargalfIcon)
         end       
     end     
end
function fortrecruit:setStar(pStarNum,pNode,pOpenBool)
     local pStar = math.floor(pStarNum / 2)
     local pmore = pStarNum % 2
     if pOpenBool then
        for var = 1 ,pStar do
         local pStarIcon = me.assignWidget(self,"recruit_star"):clone():setVisible(true)
         pStarIcon:setPosition(cc.p((var-1) * 24, 0))
         pNode:addChild(pStarIcon)
       end
       if pmore ~= 0 then
          local pStargalfIcon = me.assignWidget(self,"recruit_star_half"):clone():setVisible(true)
          pStargalfIcon:setPosition(cc.p((pStar) * 24, 0))
          pNode:addChild(pStargalfIcon)
        end
     else
         for var = 1 ,pStar do
           local pStarIcon = me.assignWidget(self,"recruit_star_ash"):clone():setVisible(true)
            pStarIcon:setScale(1.0)
           pStarIcon:setPosition(cc.p((var-1) * 24, 0))
           pNode:addChild(pStarIcon)
         end
         if pmore ~= 0 then
            local pStargalfIcon = me.assignWidget(self,"recruit_star_half_ash"):clone():setVisible(true)
            pStargalfIcon:setScale(1.0)
            pStargalfIcon:setPosition(cc.p((pStar) * 24, 0))
            pNode:addChild(pStargalfIcon)
         end     
     end 
     
end
function fortrecruit:update(msg)
    if checkMsg(msg.t, MsgCode.WORLD_FORT_RECURIT_SOLDIER) then
       if self.pFortSolider == nil then
          self.pFortSolider = fortSoldier:create("fortRecuitSoldier.csb")
          self.pFortSolider:setData(self.mHero,self)
          pWorldMap:addChild(self.pFortSolider,me.MAXZORDER)       
       end       
    end
end
 function fortrecruit:setParent()
     self.pFortSolider = nil
 end
function fortrecruit:onEnter()
    print("fortrecruit onEnter") 
--	me.doLayout(self,me.winSize) 
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end )   
end
function fortrecruit:onEnterTransitionDidFinish()
	print("fortrecruit onEnterTransitionDidFinish") 
end
function fortrecruit:onExit()
    print("fortrecruit onExit")   
    UserModel:removeLisener(self.modelkey) 
end
function fortrecruit:close()
    self:removeFromParentAndCleanup(true)  
end
