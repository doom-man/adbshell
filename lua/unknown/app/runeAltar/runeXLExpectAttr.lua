runeXLExpectAttr = class("runeXLExpectAttr",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
function runeXLExpectAttr:create(...)
    local layer = runeXLExpectAttr.new(...)
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
local COLOR_ORIGINAL = cc.c3b(103, 255, 2)
local COLOR_LOCK     = cc.c3b(174, 174, 174)
local COLOR_OTHER   = cc.c3b(232, 188, 70)

function runeXLExpectAttr:ctor()
end

function runeXLExpectAttr:onEnter()

end

function runeXLExpectAttr:onEnterTransitionDidFinish()
end

function runeXLExpectAttr:onExit()

end



function runeXLExpectAttr:init()
    print("runeXLExpectAttr init")
    me.doLayout(self, me.winSize)
    me.registGuiClickEventByName(self, "close", function(node)
        if self.closeCallback~=nil then
            self.closeCallback(self:getSelectId())
        end
        self:removeFromParentAndCleanup(true)
    end )

    self.srcAttrNodeList = {}
    self.lockNums = 0

    self.boxNode = me.assignWidget(self, "boxNode")
    self.srcAttrNode = me.assignWidget(self, "srcAttrNode")
    self.listView = me.assignWidget(self, "ListView_1")

    
    return true
    
end


function runeXLExpectAttr:setXLRuneInfo(runeInfo, expectList)
	self.runeInfo = runeInfo
    self.expectList={}
    for _, id in ipairs(expectList) do
        self.expectList[id]=true
    end
	self:updateView()
end

----
-- 更新按钮状态
--
function runeXLExpectAttr:updateLockBtnState()
    local lockNums=0
    for _, v in ipairs(self.srcAttrNodeList) do
        if v.lockState==false then
            if self.lockNums>=3 then
                me.assignWidget(v.node,"lockBtn"):loadTexture("runeXL10.png")
            else
                me.assignWidget(v.node,"lockBtn"):loadTexture("runeXL9.png")
            end
        else
            me.assignWidget(v.node,"lockBtn"):loadTexture("runeXL9.png")
            lockNums=lockNums+1
        end
    end
    self.lockNums = lockNums
end


----
-- 得到选中的属性列表ID
--
function runeXLExpectAttr:getSelectId()
    local idlist={}
    for _, v in ipairs(self.srcAttrNodeList) do
        if v.lockState==true then
            table.insert(idlist, v.id)
        end
    end
    return idlist
end


----
-- 点击属性鑜定
--
function runeXLExpectAttr:clickAttrLock(node)
    local nodeData=self.srcAttrNodeList[node.index]
    local appendNode = nodeData.node

    if nodeData.lockState==false then
        if self.lockNums>=3 then
            showTips("选择数量已达到上限")
            return
        end
        nodeData.lockState=true
        self.lockNums =self.lockNums+1
        me.assignWidget(appendNode,"attrName"):setTextColor(COLOR_LOCK)
        me.assignWidget(appendNode,"lockIco"):setVisible(true)
    else
        me.assignWidget(appendNode,"attrName"):setTextColor(COLOR_ORIGINAL)
        me.assignWidget(appendNode,"lockIco"):setVisible(false)
        nodeData.lockState=false
        self.lockNums =self.lockNums-1
    end

    self:updateLockBtnState()
end

function runeXLExpectAttr:updateView()
    local runeCfg = cfg[CfgType.RUNE_DATA][self.runeInfo.cfgId]
    local runePropertyCfg = cfg[CfgType.RUNE_PROPERTY]
    local dataList={}
    for k, v in pairs(runePropertyCfg) do
        if v.poolid==runeCfg.type then
            table.insert(dataList, v)
        end
    end
    table.sort(dataList, function(a,b) return a.sortid<b.sortid end)
    self.listView:removeAllItems()

    local bNode = nil
    local count=0
    for k, v in ipairs(dataList) do
        if count%8==0 then
            count=0
            bNode = self.boxNode:clone():setVisible(true)
            self.listView:pushBackCustomItem(bNode)
        end
        local appendNode = self.srcAttrNode:clone():setVisible(true)
        me.assignWidget(appendNode,"attrName"):setString(v.name)
        me.assignWidget(appendNode,"lockIco"):setVisible(false)

        local lockBtn = me.assignWidget(appendNode,"lockBtn")
        me.registGuiClickEvent(lockBtn, handler(self, self.clickAttrLock))
        appendNode:setPosition(11, 466-count*63)
        lockBtn.index=k
        bNode:addChild(appendNode)

        local lockState=false
        if self.expectList[v.id]==true then
            self.lockNums =self.lockNums+1
            me.assignWidget(appendNode,"attrName"):setTextColor(COLOR_LOCK)
            me.assignWidget(appendNode,"lockIco"):setVisible(true)
            lockState=true
        end

        table.insert(self.srcAttrNodeList, {node=appendNode, id=v.id, lockState=lockState})
        count=count+1
    end
end


function runeXLExpectAttr:setCloseCallback(closeCallback)
    self.closeCallback = closeCallback
end


