allianceTechView = class("allianceTechView ", function(csb)
    return cc.CSLoader:createNode(csb)
end )
allianceTechView._index = allianceTechView

allianceTechView.techViewInstance = nil
function allianceTechView:getInstance()
    return allianceTechView:create("techView.csb")
end

function allianceTechView:create(csb)
    if allianceTechView.techViewInstance ~= nil then
        return allianceTechView.techViewInstance 
    end

    allianceTechView.techViewInstance = allianceTechView.new(csb)
    if allianceTechView.techViewInstance then
        if allianceTechView.techViewInstance:init() then
            allianceTechView.techViewInstance:registerScriptHandler(function(tag)
                if "enter" == tag then
                    allianceTechView.techViewInstance:onEnter()
                elseif "exit" == tag then
                    allianceTechView.techViewInstance:onExit()
                end
            end )
            return allianceTechView.techViewInstance
        end
    end
    return nil
end

function allianceTechView:ctor()
    print("allianceTechView:ctor()")
    self.buildType = 0
    self.cellViews = {}
    self.listener = nil
    self.toftid = nil
end

function allianceTechView:init()
    print("allianceTechView:init()")
    self.titleName = me.assignWidget(self, "title")
    self.ScrollView_conent = me.assignWidget(self, "ScrollView_conent")
    self.Image_Arrow = me.assignWidget(self, "Image_Arrow")
    self.Text_workersType = me.assignWidget(self,"Text_workersType")
    self.Text_FarmerNum = me.assignWidget(self,"Text_FarmerNum")
    self.Node_Workers = me.assignWidget(self,"Node_Workers")
    me.assignWidget(self,"Image_farmer"):setVisible(false)
    me.assignWidget(self,"Image_given"):setVisible(true)
    self.Image_attacked = me.assignWidget(self,"Image_attacked")
    self.Image_attacked:setVisible(false)
    self.Text_GivenNum = me.assignWidget(self,"Text_GivenNum")
    self.Text_allianceTechType = me.assignWidget(self,"Text_allianceTechType")
    local def = cfg[CfgType.ETC][9012]
    self.Text_allianceTechType:setString(def.name..":")
        -- 注册点击事件
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )

    return true
end

function allianceTechView:updateData(msg)
    if nil == msg then
        return
    end
    if checkMsg(msg.t, MsgCode.FAMILY_TECH_UPDATING) then
        self:resetCellView(msg.c.list,MsgCode.FAMILY_TECH_UPDATING)
    elseif checkMsg(msg.t, MsgCode.FAMILY_TECH_GIVEN) then
        self.Text_GivenNum:setString(user.allianceGivenData.gongxian)
    end
end

function allianceTechView:initData()
    print("allianceTechView:initData()")
    self.titleName:setString("联盟科技")
    self.Text_GivenNum:setString(user.allianceGivenData.gongxian)
    self.Image_attacked:setVisible(CaptiveMgr:isCaptured())
    self.cthread = coroutine.create(function ()
        --这里为调用的方法 然后在该方法中加入coroutine.yield()
        self:initCellViews()
        self:initLines()
    end)
    self.schid = me.coroStart(self.cthread,0,nil)
end

--根据服务器下发新的数据，更改对应的cellview界面信息
function allianceTechView:resetCellView(upgradeList,msgType)
    --重新刷新数据  
    if msgType == MsgCode.FAMILY_TECH_UPDATING then
        for key, var in pairs(upgradeList) do
            local tmpDef = cfg[CfgType.TECH_FAMILY][var.id]
            if self.cellViews[tmpDef.techid] then
                self.cellViews[tmpDef.techid]:initData()
            end
        end        
    end
end

--初始化所有的cell节点
function allianceTechView:initCellViews()
    local techTab = techDataMgr.getFamilyTehcDatas()
--    dump(techTab)
    if techTab == nil then
        __G__TRACKBACK__("init cell views by build type error !!!")    
    end
    local posXMax,tmpViewW = 0
    for key, var in pairs(techTab) do
        local tmpView = techCellView_Alliance:create("techIconView.csb")
        local def = var:getDef()
        if tmpView and def then
            tmpView:setCellDataID(def.id)
            self.ScrollView_conent:addChild(tmpView)
            self.cellViews[def.techid]=tmpView
            --按照百分比适配Y坐标
            tmpViewW = tmpView:getContentSize().width
            local viewY = 0
            local viewX = 160*(def.posi-1)
            if posXMax < viewX then
                posXMax = viewX
            end
            if def.sort == 1 then
                viewY = 0
            elseif def.sort == 2 then
                viewY = self.ScrollView_conent:getContentSize().height/2-tmpView:getContentSize().height/2
            elseif def.sort == 3 then 
                viewY = self.ScrollView_conent:getContentSize().height-tmpView:getContentSize().height
            end
            tmpView:setPosition(viewX, viewY)
        else 
            __G__TRACKBACK__("techIconView.csb or data is nil  !!!")
        end
        coroutine.yield()
    end    
    if posXMax > self.ScrollView_conent:getContentSize().width then
        self.ScrollView_conent:setInnerContainerSize(cc.size(posXMax+tmpViewW,self.ScrollView_conent:getContentSize().height))
    end
end

--根据已有的节点连线
function allianceTechView:initLines()
    for key, var in pairs(self:getCellViews()) do
        local preids = techDataMgr.getPreNodePos_Alliance(key)
        local startPosX, startPosY= var:getPosition()
        if preids then
            for idKey, idVar in pairs(preids) do
                local imgLine = ccui.ImageView:create("keji_xian_9png.png",me.localType)
                var:getParent():addChild(imgLine,-1)
                local tmpDef1=cfg[CfgType.TECH_FAMILY][idVar]
                local view = nil
                for cellKey, cellVar in pairs(self:getCellViews()) do
                    local cellId = cellVar:getCellDataID()
                    local tmpDef2 = cfg[CfgType.TECH_FAMILY][cellId]
                    if me.toNum(tmpDef1.techid) == me.toNum(tmpDef2.techid) then
                        local endPosX, endPosY = cellVar:getPosition() 
                        local len = cc.pGetDistance(cc.p(endPosX,endPosY), cc.p(startPosX,startPosY))
                        imgLine:setScale9Enabled(true)
                        imgLine:setContentSize(cc.size(len, imgLine:getContentSize().height))
                        imgLine:setRotation(me.getAngleWith2Pos(cc.p(startPosX,startPosY), cc.p(endPosX,endPosY))) 
                        imgLine:setAnchorPoint(cc.p(0, 0.5))
                        imgLine:setPosition(cc.p(startPosX+var:getContentSize().width/2,startPosY+var:getContentSize().height/2))
                        break
                    end
                end
                coroutine.yield()
            end
        end
    end
end

function allianceTechView:onEnter()
    me.doLayout(self,me.winSize)  
    self.listener = UserModel:registerLisener(function (msg)
        self:updateData(msg)
    end)
end

function allianceTechView:onExit()
    print("allianceTechView:onExit()")
    allianceTechView.techViewInstance = nil
end

function allianceTechView:close()
    UserModel:removeLisener(self.listener)
    me.coroClear(self.schid)
    for key, var in pairs(self.cellViews) do
        var:removeFromParentAndCleanup(true)
    end

    self:removeFromParentAndCleanup(true)
end

function allianceTechView:getCellViews()
    return self.cellViews
end