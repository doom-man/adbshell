fortIdentifyView = class("fortIdentifyView", function(...)
    return cc.CSLoader:createNode(...)
end )
fortIdentifyView.__index = fortIdentifyView
fortIdentifyView.Hero_NoEnough = 0 -- 试炼度不够
fortIdentifyView.Hero_Activating = 1 -- 等待激活
fortIdentifyView.Hero_Using = 2 -- 使用中
function fortIdentifyView:create(...)
    local layer = fortIdentifyView.new(...)
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

function fortIdentifyView:ctor()
    print("fortIdentifyView:ctor()")
end
function fortIdentifyView:init()
    self.currentIndex = 1
    self.selHeadPanel = nil
    self.fiuv = nil
    self.Panel_property = me.assignWidget(self, "Panel_property")
    self.Panel_skills = me.assignWidget(self, "Panel_skills")
    self.Sprite_CardBg = me.assignWidget(self, "Sprite_CardBg")
    self.Image_star = me.assignWidget(self, "Image_star")
    self.ArmatureNode_open = me.assignWidget(self, "ArmatureNode_open")
    me.registGuiClickEventByName(self, "close", function()
        self:close()
    end )
    print("fortIdentifyView:init()")
    return true
end
function fortIdentifyView:close()
    self:removeFromParentAndCleanup(true)
end
function fortIdentifyView:onEnter()
    print("fortIdentifyView:onEnter()")
    self.Button_upgrade = me.registGuiClickEventByName(self, "Button_upgrade", function()
        local tempDef = user.worldIdentifyList.heroList[self.currentIndex]:getDef()
        NetMan:send(_MSG.worldHeroDetail(tempDef.id))
    end )

    me.registGuiClickEventByName(self, "Button_activity", function()
        local tempDef = user.worldIdentifyList.heroList[self.currentIndex]:getDef()
        NetMan:send(_MSG.worldHeroActivition(tempDef.id, tempDef.herobookid))
    end )

    me.registGuiClickEventByName(self, "Image_Ask", function()
        local tmpPanel = cc.CSLoader:createNode("Layer_HeroAllProperty.csb")
        me.doLayout(me.assignWidget(tmpPanel, "fixLayout"), me.winSize)
        me.registGuiClickEventByName(tmpPanel, "close", function()
            tmpPanel:removeFromParent()
        end )
        local tempData = user.worldIdentifyList:getAllProperty()
        me.assignWidget(tmpPanel, "Text_attack_attack"):setString(tempData.attack)
        me.assignWidget(tmpPanel, "Text_attack_defense"):setString(tempData.defense)
        me.assignWidget(tmpPanel, "Text_attack_damage"):setString(tempData.damage)
        self:addChild(tmpPanel)
    end )
    NetMan:send(_MSG.worldfortherogeneral())
    self:setGenenalTable()
    self.curEVT = me.RegistCustomEvent("closeEventfortIdentifyView",function (args)
      self:close()
end)
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_UPGRADE_DETIAL) then
            if self.fiuv == nil then
                self.fiuv = fortIdentifyUpgradeView:create("fortIdentifyUpgradeView.csb")
                local heroData = user.worldIdentifyList.heroList[self.currentIndex]
                self.fiuv:setCurrentHeroData(heroData)
                self:addChild(self.fiuv)
            end
        elseif checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_ACTIVITION) then
            self:setGenenalTable()
        elseif checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_UPGRADE_FINISH) then
            local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
            pCityCommon:CommonSpecific(ALL_COMMON_HEROLEVELUP)
            pCityCommon:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2 + 100))
            me.runningScene():addChild(pCityCommon, me.ANIMATION)
            self:setGenenalTable()
        elseif checkMsg(msg.t, MsgCode.WORLD_FORTRESS_FAMILY_INIT) then
            self:initInfo()
        end
    end )
end
function fortIdentifyView:initFortTab()
    if self.fortCellUI==nil then
        self.fortCellUI = me.assignWidget(me.createNode("Node_Identify.csb"), "up_table_cell")
        self:addChild(self.fortCellUI)
        self.fortCellUI:setVisible(false)
    end
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(tbl, cell)
--        local pId = cell:getIdx()+1
--        local pData = self.mFortHero[pId]
--        if pData then
--          local pFortData = user.fortWorldData[pData["id"]]            
--          if pFortData == nil then    -- 未占领 
--             showTips("未占领")        
--           else                
--            if pFortData["mine"] == 1 then -- 自己联盟占领
--                self.FortPitchImg:setPosition(cc.p(self:getFortCellPoint(pId)))                 
--                local pPoint = me.getCoordByFortId(pData["id"])
--                self.cp = cc.p(pPoint.x,pPoint.y)
--            elseif pFortData["mine"] == 0 then -- 敌对占领
--               showTips("被敌方占领") 
--            end             
--         end 
--        end       
    end
    local function cellSizeForTable(tbl, idx)
        return 269, 127 + 5
    end

    local function tableCellAtIndex(tbl, idx)
        -- print(idx)
        local cell = tbl:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            local pFortCell = self.fortCellUI:clone():setVisible(true)
            self:setFortCell(pFortCell,self.mFortHero[idx+1])
            local pButtonpoint = me.assignWidget(pFortCell,"up_fort_point")
            pButtonpoint:setTag(idx+1)
            me.registGuiClickEvent(pButtonpoint,function (node)
                local pId = node:getTag()
                local pData = self.mFortHero[idx+1]
                --local pFortData = user.fortWorldData[pData["id"]]
                --if pFortData   then
                   local pPoint = me.getCoordByFortId(pData["id"])
                   local pos = cc.p(pPoint.x,pPoint.y)
                   LookMap(pos,"closeEventfortIdentifyView")
                --end
                
            end)
            pButtonpoint:setSwallowTouches(false)
            pFortCell:setPosition(cc.p(0, 5))
            cell:addChild(pFortCell)
        else 
           local pFortCell = me.assignWidget(cell,"up_table_cell")
           self:setFortCell(pFortCell,self.mFortHero[idx+1])
           local pButtonpoint = me.assignWidget(pFortCell,"up_fort_point")
            pButtonpoint:setTag(idx+1)
            me.registGuiClickEvent(pButtonpoint,function (node)
                local pId = node:getTag()
                local pData = self.mFortHero[idx+1]
                --local pFortData = user.fortWorldData[pData["id"]]
                --if pFortData   then
                   local pPoint = me.getCoordByFortId(pData["id"])
                   local pos = cc.p(pPoint.x,pPoint.y)
                   LookMap(pos,"closeEventfortIdentifyView")
                --end
                
            end)
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        return #self.mFortHero
    end
    if self.ForttableView == nil then
        local tableView = cc.TableView:create(cc.size(269, 340))
        tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        tableView:setAnchorPoint(cc.p(0, 0))
        tableView:setPosition(cc.p(0, 0))
        tableView:setDelegate()
        me.assignWidget(self, "Panel_FortList"):addChild(tableView)
        -- registerScriptHandler functions must be before the reloadData funtion
        tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
        tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
        tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
        tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
        self.ForttableView = tableView
    end
    self.ForttableView:reloadData()

end
function fortIdentifyView:getFortCellPoint(pTag)
    pTag = me.toNum(pTag)
    local pPointX =(pTag - 1) * 315 + 51
    local pPointY = 51
    return pPointX, pPointY
end
function fortIdentifyView:setFortCell(pNode, pData)
    if pData then
        local pConfigData = GFortData()[pData["id"]]
        local pFortIcon = me.assignWidget(pNode, "up_fort_icon")
        pFortIcon:loadTexture("shengjiang_yaosai_xiao_" .. pConfigData["icon"] .. ".png", me.plistType)

        local pFortData = user.fortWorldData[pData["id"]]
        local pFortOccupy = "yaosai_25.png"
        local pFortOccupyBg = "shengjiang_beijing_yaosai_hui.png"
        if pFortData == nil then
            -- 未占领
            pFortOccupy = "yaosai_25.png"
            pFortOccupyBg = "shengjiang_beijing_yaosai_hui.png"
        else
            if pFortData["mine"] == 1 then
                -- 自己联盟占领
                pFortOccupy = "yaosai_27.png"
                pFortOccupyBg = "shengjiang_beijing_yaosai_lan.png"
            elseif pFortData["mine"] == 0 then
                -- 敌对占领
                pFortOccupy = "yaosai_26.png"
                pFortOccupyBg = "shengjiang_beijing_yaosai_hong.png"
            end
        end
        local pFortOccIconBg = me.assignWidget(pNode, "up_fort_bg")
        pFortOccIconBg:loadTexture(pFortOccupyBg, me.plistType)

        local pFortOccIcon = me.assignWidget(pNode, "up_fort_type_icon")
        pFortOccIcon:loadTexture(pFortOccupy, me.plistType)

        local pFortName = me.assignWidget(pNode, "up_fort_name")
        pFortName:setString(pConfigData["name"])

        local pFortPoint = me.assignWidget(pNode, "up_fort_point")
        local pPoint = me.getCoordByFortId(pData["id"])
        pFortPoint:setString("(" .. pPoint.x .. "," .. pPoint.y .. ")")
        --      if pPoint.x == self.mPitchHero.x and pPoint.y == self.mPitchHero.y and self.mPitchHero["open"] == 1 then
        --         me.assignWidget(pNode,"up_fort_exper"):setVisible(true)
        --      else
        --         me.assignWidget(pNode,"up_fort_exper"):setVisible(false)
        --      end
    end
end
function fortIdentifyView:getFortFort(heroType)
    me.tableClear(self.mFortHero)
    self.mFortHero = { }

    for key, var in pairs(gameMap.fortDatas) do
        local pConfig = var:getDef()
        local pId = var["id"]
        if heroType == pConfig["herotype"] then
            local pData = user.fortWorldData[pId]
            if pData == nil or pData.vType == 0 or pData.vType == 3 then
                -- 未占领
                var.OccType = 3
                table.insert(self.mFortHero, var)
            else
                if pData["mine"] == 1 then
                    -- 自己联盟占领
                    var.OccType = 1
                    table.insert(self.mFortHero, var)

                elseif pData["mine"] == 0 then
                    -- 敌对占领
                    var.OccType = 2
                    table.insert(self.mFortHero, var)
                end
            end
        end
    end

    local function SortFort(pa, pb)
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

    table.sort(self.mFortHero, SortFort)

    local pData1 = self.mFortHero[1]
    self.mPitchOn = 1
    local pPitchBool = true
    for key, var in pairs(self.mFortHero) do
        local pConfig = var:getDef()
        if heroType == pConfig["herotype"] then
            if pPitchFortId == var["id"] then
                pData1 = var
                pPitchBool = false
                break
            end
            self.mPitchOn = self.mPitchOn + 1
        end
    end
    if pPitchBool then
        self.mPitchOn = 1
    end
    local pPoint = me.getCoordByFortId(pData1["id"])
    self.cp = cc.p(pPoint.x, pPoint.y)   
    self:initFortTab()
end
-- 设置名将列表
function fortIdentifyView:setGenenalTable()
    --    dump(user.worldIdentifyList.heroList)
    local function numberOfCellsInTableView(tbl)
        return #user.worldIdentifyList.heroList
    end

    local function cellSizeForTable(tbl, idx)
        return 180, 128
    end

    local function tableCellAtIndex(tbl, idx)
        local cell = tbl:dequeueCell()
        local tmpData = user.worldIdentifyList.heroList[me.toNum(idx + 1)]
        local tmpDef = tmpData:getDef()
        local headPanel = nil
        local Sprite_Head = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            local node = me.assignWidget(self, "Node_HeroSmallHead")
            headPanel = me.assignWidget(node, "Panel_HeroHead"):clone()
            headPanel:setVisible(true)
            headPanel:setSwallowTouches(false)
            headPanel:setPosition(cc.p(90, 64))
            cell:addChild(headPanel)
            Sprite_Head = ccui.ImageView:create()
            Sprite_Head:loadTexture(heroSmallHeadIcon(tmpDef.herobookicon), me.plistType)
            Sprite_Head:setAnchorPoint(cc.p(0.5, 0.5))
            Sprite_Head:setPosition(cc.p(86.5, 52.5))
            Sprite_Head:ignoreContentAdaptWithSize(false)
            Sprite_Head:setContentSize(cc.size(173, 105))
            me.assignWidget(headPanel, "Panel_spr"):addChild(Sprite_Head)
            Sprite_Head:setTag(555)
        else
            headPanel = cell:getChildByName("Panel_HeroHead")
            Sprite_Head = me.assignWidget(headPanel, "Panel_spr"):getChildByTag(555)
            Sprite_Head:loadTexture(heroSmallHeadIcon(tmpDef.herobookicon), me.plistType)
            Sprite_Head:ignoreContentAdaptWithSize(false)
            Sprite_Head:setContentSize(cc.size(173, 105))
        end

        me.assignWidget(headPanel, "Panel_stars"):removeAllChildren()
        if tmpData.herobookStatus == fortIdentifyView.Hero_NoEnough then
            self:setStars(me.assignWidget(headPanel, "Panel_stars"), tmpDef, 0.9, true)
            me.assignWidget(headPanel, "Image_buttum"):setVisible(false)
            me.assignWidget(headPanel, "Image_activiting"):setVisible(false)
            me.graySprite(Sprite_Head)
        elseif tmpData.herobookStatus == fortIdentifyView.Hero_Activating then
            self:setStars(me.assignWidget(headPanel, "Panel_stars"), tmpDef, 0.9, true)
            me.assignWidget(headPanel, "Image_buttum"):setVisible(false)
            me.graySprite(Sprite_Head)
            me.assignWidget(headPanel, "Image_activiting"):setVisible(true)
        elseif tmpData.herobookStatus == fortIdentifyView.Hero_Using then
            self:setStars(me.assignWidget(headPanel, "Panel_stars"), tmpDef, 0.9, false)
            if me.toNum(tmpDef.herobooklv) -1 > 0 then
                me.assignWidget(headPanel, "Image_buttum"):setVisible(true)
                me.assignWidget(headPanel, "Text_lv"):setString("+" .. me.toNum(tmpDef.herobooklv) -1)
            else
                me.assignWidget(headPanel, "Image_buttum"):setVisible(false)
            end
            me.assignWidget(headPanel, "Image_activiting"):setVisible(false)
            me.revokeSprite(Sprite_Head)
        end

        if idx + 1 == self.currentIndex then
            self.selHeadPanel = headPanel
            me.assignWidget(headPanel, "Image_select"):setVisible(true)
        else
            me.assignWidget(headPanel, "Image_select"):setVisible(false)
        end
        headPanel:setTag(me.toNum(idx + 1))

        me.registGuiClickEvent(headPanel, function(node)
            if self.selHeadPanel then
                me.assignWidget(self.selHeadPanel, "Image_select"):setVisible(false)
            end
            self.selHeadPanel = headPanel
            self.currentIndex = node:getTag()
            self:setBottomInfos()
            me.assignWidget(headPanel, "Image_select"):setVisible(true)
        end )
        return cell
    end

    if self.tableView == nil then
        local ImageView_up = me.assignWidget(self, "ImageView_up")
        self.tableView = cc.TableView:create(cc.size(ImageView_up:getContentSize().width, ImageView_up:getContentSize().height))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
        self.tableView:setDelegate()
        self.tableView:setAnchorPoint(cc.p(0, 0))
        self.tableView:setPosition(cc.p(0, 0))
        ImageView_up:addChild(self.tableView)
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end

    self.tableView:reloadData()
    self:setBottomInfos()
end

function fortIdentifyView:setStars(node, def, scale, needGrey)
    node:removeAllChildren()
    scale = scale or 1
    local offW = 24 * scale
    local star = user.worldIdentifyList:getBookStarsById(def.id)
    local int, float = math.floor(star / 2), star % 2
    for var = 1, int do
        local star_img = ccui.ImageView:create()
        if needGrey then
            star_img:loadTexture("yaosai_17.png", me.localType)
        else
            star_img:loadTexture("yaosai_15.png", me.localType)
            star_img:setScale(scale)
        end
        star_img:setAnchorPoint(cc.p(0, 0))
        star_img:setPosition((var - 1) * offW, 0)
        node:addChild(star_img)
    end
    if float > 0 then
        local star_img = ccui.ImageView:create()
        if needGrey then
            star_img:loadTexture("yaosai_18.png", me.localType)
        else
            star_img:loadTexture("yaosai_16.png", me.localType)
            star_img:setScale(scale)
        end
        star_img:setAnchorPoint(cc.p(0, 0))
        star_img:setPosition(int * offW, 0)
        node:addChild(star_img)
    end
end

function fortIdentifyView:setBottomInfos()
    local tmpDef = user.worldIdentifyList.heroList[self.currentIndex]:getDef()
    local status = user.worldIdentifyList:getHeroStatusById(tmpDef.id)

    if cfg[CfgType.HERO_BOOK_TYPE][tmpDef.nextbookid] == nil then
        -- 满级
        self.Button_upgrade:setVisible(false)
        self.Panel_skills:setAnchorPoint(cc.p(0, 0))
        self.Panel_skills:setPositionX(71)
    else
        self.Button_upgrade:setVisible(true)
        self.Panel_skills:setAnchorPoint(cc.p(0, 0))
        self.Panel_skills:setPositionX(71)
    end

    me.assignWidget(self, "Text_generalName"):setString(tmpDef.herobookname)
    me.setSpriteTexture(self.Sprite_CardBg, heroBgHeadIcon(tmpDef.herobookicon))

    me.assignWidget(self, "Image_tips"):setVisible(status == fortIdentifyView.Hero_NoEnough)
    self.Panel_skills:setVisible(status == fortIdentifyView.Hero_Using)
    self.Panel_property:setVisible(status == fortIdentifyView.Hero_Using)
    me.assignWidget(self, "Button_activity"):setVisible(status == fortIdentifyView.Hero_Activating)
    self:setStars(me.assignWidget(self.Image_star, "Panel_stars"), tmpDef)
    status = 1
    if status == fortIdentifyView.Hero_Using then
        me.revokeSprite(self.Sprite_CardBg)
        self.ArmatureNode_open:setVisible(ture)
        self:setHeroSkills()
        self:setPropertyInfo()
    elseif status == fortIdentifyView.Hero_Activating then
        me.graySprite(self.Sprite_CardBg)
        self.ArmatureNode_open:setVisible(true)

    else
        self.ArmatureNode_open:setVisible(true)
        local level = "1"
        for key, var in pairs(cfg[CfgType.HERO_BOOK]) do
            if me.toNum(var.needherotypeid) == me.toNum(tmpDef.herobookid) then
                level = var.needherolevel
            end
        end
        me.assignWidget(self, "Text_tips_up"):setString("要塞试炼度达到" .. level .. "可以激活")
        me.graySprite(self.Sprite_CardBg)
    end
    if status == fortIdentifyView.Hero_NoEnough then
        self:getFortFort(tmpDef.herobookid)  
        me.assignWidget(self, "Panel_FortList"):setVisible(true)   
    else
       
        me.assignWidget(self, "Panel_FortList"):setVisible(true)
    end
end
function fortIdentifyView:initInfo()



end
function fortIdentifyView:setHeroSkills()
    me.assignWidget(self.Panel_skills, "Panel_items"):removeAllChildren()

    local skillList = user.worldIdentifyList.heroList[self.currentIndex]:getSkills()
    local node = me.assignWidget(self, "Node_skill")
    local openSkillId = nil
    local currentDef = user.worldIdentifyList.heroList[self.currentIndex]:getDef()
    local nextDef = cfg[CfgType.HERO_BOOK_TYPE][currentDef.nextbookid]
    if nextDef and me.toNum(nextDef.openskill) > 0 then
        openSkillId = me.toNum(nextDef.openskill)
    end

    for key, var in pairs(skillList) do
        local skillDef = cfg[CfgType.HERO_SKILL][var.id]
        local skillSpr = me.createSprite(getHeroSkillIcon(skillDef.skillicon))
        if me.toNum(var.status) == 0 then
            me.graySprite(skillSpr)
        end
        skillPanel = me.assignWidget(node, "Panel_singleSkill"):clone()
        if openSkillId ~= nil and openSkillId == me.toNum(var.id) then
            me.assignWidget(skillPanel, "Text_nextOpen"):setVisible(true)
        else
            me.assignWidget(skillPanel, "Text_nextOpen"):setVisible(false)
        end

        skillPanel:setTag(var.id)
        skillPanel:setVisible(true)
        if skillDef.skilltype == 2 then
            -- 主动技能
            --            me.assignWidget(skillPanel, "Image_skill"):loadTexture("shengjiang_jineng_kuang_yuan.png", me.localType)
            local pCityCommon = nil
            if var.status == 0 then
                -- 未开启
                pCityCommon = allAnimation:createAnimation("shenjiang_jineng_an")
            else
                pCityCommon = allAnimation:createAnimation("shenjiang_jineng_hong")
            end
            local Panel_skillAni = me.assignWidget(skillPanel, "Panel_skillAni")
            Panel_skillAni:addChild(pCityCommon, me.ANIMATION)
            Panel_skillAni:setPosition(cc.p(Panel_skillAni:getContentSize().width / 2, Panel_skillAni:getContentSize().height / 2))
            pCityCommon:heroSkillAni()
        elseif skillDef.skilltype == 1 then
            -- 被动技能
            --            me.assignWidget(skillPanel, "Image_skill"):loadTexture("shengjiang_jineng_kuang_fang.png", me.localType)
        end

        -- 设置星级
        local Panel_star = me.assignWidget(skillPanel, "Panel_star")
        if me.toNum(var.status) ~= 0 then
            setHeroSkillStars(Panel_star, skillDef.star)
        end

        skillSpr:setAnchorPoint(cc.p(0.5, 0.5))
        skillSpr:setPosition(cc.p(skillPanel:getContentSize().width / 2, skillPanel:getContentSize().height / 2))
        me.assignWidget(skillPanel, "Panel_spr"):addChild(skillSpr)
        skillPanel:setAnchorPoint(cc.p(0, 0.5))
        skillPanel:setPosition(cc.p(me.toNum(key - 1) * 125 + 10, self.Panel_skills:getContentSize().height / 2))
        me.assignWidget(self.Panel_skills, "Panel_items"):addChild(skillPanel)
        me.registGuiTouchEvent(skillPanel, function(node, event)
            if event == ccui.TouchEventType.began then
                if self.panel_skillDetail ~= nil then
                    self.panel_skillDetail:removeFromParent()
                    self.panel_skillDetail = nil
                end
                self.panel_skillDetail = showHeroSkillDetail(node:getTag())
                self.panel_skillDetail:setAnchorPoint(cc.p(0.5, 0.5))
                self.panel_skillDetail:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
                self:addChild(self.panel_skillDetail)
            elseif event == ccui.TouchEventType.ended or event == ccui.TouchEventType.canceled then
                if self.panel_skillDetail ~= nil then
                    self.panel_skillDetail:removeFromParent()
                    self.panel_skillDetail = nil
                end
            end
        end )
    end
end

function fortIdentifyView:setPropertyInfo()
    me.assignWidget(self.Panel_property, "Panel_items"):removeAllChildren()
    local tmpDef = user.worldIdentifyList.heroList[self.currentIndex]:getDef()
    local nextDef = cfg[CfgType.HERO_BOOK_TYPE][tmpDef.nextbookid]
    local node = me.assignWidget(self, "Node_proerty")
    me.assignWidget(self.Panel_property, "Text_title"):setString("所有兵种增加")

    local propertyList = { }
    local function setPropertyListData(title, preNum, nextStr)
        propertyList[#propertyList + 1] = { }
        propertyList[#propertyList].title = title
        propertyList[#propertyList].preNum = preNum
        if nextDef then
            propertyList[#propertyList].nextNum = nextDef[nextStr]
        end
    end

    setPropertyListData("附加攻击", tmpDef.atkplus, "atkplus")
    setPropertyListData("附加防御", tmpDef.defplus, "defplus")
    setPropertyListData("附加伤害", tmpDef.dmgplus, "dmgplus")
    --    dump(propertyList)
    local Panel_items = me.assignWidget(self.Panel_property, "Panel_items")
    for key, var in pairs(propertyList) do
        local sp = me.assignWidget(node, "Panel_singleProperty"):clone()
        sp:setAnchorPoint(cc.p(0, 0))
        sp:setVisible(true)
        me.assignWidget(sp, "text_name"):setString(var.title)
        me.assignWidget(sp, "Text_pre"):setString(var.preNum)
        if var.nextNum then
            me.assignWidget(sp, "Text_next"):setString(var.nextNum)
            me.assignWidget(sp, "Image_up"):setVisible(true)
            me.assignWidget(sp, "Text_next"):setPositionX(me.assignWidget(sp, "Image_up"):getPositionX() + 7)
            sp:setPosition(cc.p(0, Panel_items:getContentSize().height - 60 * me.toNum(key)))
        else
            me.assignWidget(sp, "Text_next"):setVisible(false)
            me.assignWidget(sp, "Image_up"):setVisible(false)
            sp:setPosition(cc.p(0, Panel_items:getContentSize().height - 60 * me.toNum(key)))
        end
        me.assignWidget(self.Panel_property, "Panel_items"):addChild(sp)
    end
end

function fortIdentifyView:onExit()
    UserModel:removeLisener(self.modelkey)
    -- 删除消息通知
    print("fortIdentifyView:onExit()")
    me.RemoveCustomEvent(self.curEVT)
end
