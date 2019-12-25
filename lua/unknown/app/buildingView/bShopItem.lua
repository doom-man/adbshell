bShopItem = class("bShopItem", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
bShopItem.__index = bShopItem
function bShopItem:create(...)
    local layer = bShopItem.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler( function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                elseif "enterTransitionFinish" == tag then
                    layer:enterTransitionFinish()
                end
            end )
            return layer
        end
    end
    return nil
end
function bShopItem:ctor()
    print("bShopItem ctor")
    self.builddata = nil
end
function bShopItem:init()
    print("bShopItem init")

    return true
end
function bShopItem:getBuildData()
    return self.builddata
end
function bShopItem:initWithBuildData(build, guideType, force)
    self.builddata = build
    self.guideType = guideType
    self.force = false
    if force then
        self.force = true
    end
    local name = me.assignWidget(self, "name")
    local peasant = me.assignWidget(self, "peasant")
    local num = me.assignWidget(self, "num")
    local time = me.assignWidget(self, "time")
    local icon = me.assignWidget(self, "icon")
    local mask = me.assignWidget(self, "mask")
    local nInfo = me.assignWidget(self, "openBuild")
    local bBtn = me.assignWidget(self, "needBtn")
    local canBuild = me.assignWidget(self, "canBuild")
    local bHall = me.assignWidget(self, "bHall")
    local Image_glow_bg = me.assignWidget(self,"Image_glow_bg")
    me.registGuiClickEventByName(self, "descBtn", function()
        print("buildShopView building inifo !!!!")
        local info = buildingInfoLayer:create("buildingInfoLayer.csb")
        info:setBuidData(self.builddata)
        me.assignWidget(info, "lv_label"):setVisible(true)
        mainCity.bshopBox:addChild(info, me.MAXZORDER)
        me.DelayRun( function()
            me.showLayer(info, "bg_frame")
        end , 0.01)
    end )

    icon:loadTexture(buildIcon(build), me.plistType)
    me.resizeImage(icon, 200, 160)

    -- me.doLayout(bHall,bHall:getContentSize())
    name:setString(build.name)
    local tmpBuildTime = build.time * getTimePercentByPropertyValue("BuildTime")
    tmpBuildTime = math.floor(tmpBuildTime)
    time:setString(me.formartSecTime(tmpBuildTime))
    peasant:setString("x" .. build.farmer)
    num:setString(self:getBuildingNum(build))
    mask:setVisible(false)
    canBuild:setVisible(self:checkHlight(build))
    me.setButtonDisable(bBtn, self:checkHlight(build))
    nInfo:setVisible(not self:checkHlight(build))
    local btntitle =  me.assignWidget(self,"btn_title")
    if not self:checkHlight(build) then
        me.Helper:grayImageView(btntitle)
        me.Helper:grayImageView(bHall)
        name:setTextColor(cc.c3b(191,191,191))
        num:setTextColor(cc.c3b(191,191,191))        
        me.Helper:grayImageView(Image_glow_bg)
        me.Helper:grayImageView(icon)
        
    else
        me.Helper:normalImageView(btntitle)
        me.Helper:normalImageView(icon)
        me.Helper:normalImageView(bHall)
        me.Helper:normalImageView(Image_glow_bg)
        name:setTextColor(me.convert3Color_("DEC197"))
        num:setTextColor(me.convert3Color_("EAB22B"))
    end
    if build.openLevel then
        local openbuildDef = cfg[CfgType.BUILDING][me.toNum(build.openLevel)]
        nInfo:setString(TID_NEED .. openbuildDef.name .. TID_LEVEL .. openbuildDef.level)
    end
    self:isNewBuilding()
end
function bShopItem:isNewBuilding()
    local status = SharedDataStorageHelper():getNewOpenBuildings(self.builddata.id)
    local function haveBuilded()
        for key, var in pairs(mainCity.buildingMoudles) do
            if self.builddata.type == var:getDef().type then
                return true
            end
        end
        return false
    end
    if haveBuilded() == false and status == 1 then
        me.assignWidget(self,"Image_new"):setVisible(true)
    else
         me.assignWidget(self,"Image_new"):setVisible(false)
    end
end
function bShopItem:setGuideView()
    -- 因为wonder奇迹字段对应多个建筑物，所以这里做特殊处理，不指定具体的建筑物，让玩家自己选择
    if self.builddata.type == self.guideType and self.guideType ~= "wonder" then
        local buildBtn = me.assignWidget(self, "needBtn")
        if guideViewInstace then
            guideViewInstace:close()
        end
        local guide = guideView:getInstance()
        if self.force then
            guide:showGuideView(buildBtn, true, true, nil, "ui_ty_button_hong_154x56.png", false)
        else
            guide:showGuideView(buildBtn, false, false)
        end
        mainCity:addChild(guide, me.GUIDEZODER)
    end
end

function bShopItem:getBuildingNum(build)
    local limit = user.centerBuild:getDef().extValue[build.type]
    if nil == limit then
        limit = 1
    end

    local bHall = me.assignWidget(self, "needBtn")
    local totalNum = 0
    -- 总建筑物数量
    local buildNum = 0
    -- 已经修好的建筑物
    local buildingNum = 0
    -- 正在新建的建筑物
    if user.buildingTypeNum[build.type] and user.buildingTypeNum[build.type] > 0 then
        buildNum = me.toNum(user.buildingTypeNum[build.type])
    end
    buildingNum = me.toNum(UserModel:getBuildingLineTypeNumWithStatus(build.type, BUILDINGSTATE_BUILD.key))
    totalNum = buildNum + buildingNum

    if not(totalNum < me.toNum(limit)) then
        bHall.blimit = true
        totalNum = limit
    else
        bHall.blimit = false
    end
    return totalNum .. "/" .. limit
end
function bShopItem:checkHlight(build)

    local openLevel = build.openLevel
    local bHall = me.assignWidget(self, "needBtn")

    if openLevel then
        local openBuild = cfg[CfgType.BUILDING][me.toNum(openLevel)]
        assert(openBuild, "openBuild nil")
        if bHaveLevelBuilding(openBuild.type, openBuild.level) then
            bHall.locked = false
            return true
        else
            bHall.locked = true
            return false
        end
    else
        return true
    end
end
function bShopItem:onEnter()
end
function bShopItem:enterTransitionFinish()
    if self.guideType then
        me.DelayRun( function(args)
            self:setGuideView()
        end )
    end
end
function bShopItem:onExit()
    print("bShopItem onExit")
    if self.guideLayer then
        self.guideLayer:removeFromParentAndCleanup(true)
    end
end
