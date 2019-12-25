local runeHecengItem = class("runeHecengItem",function (...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        return arg[1]
    end
end)
function runeHecengItem:create(...)
    local layer = runeHecengItem.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler(function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                end
            end)
            return layer
        end
    end
    return nil
end

function runeHecengItem:ctor()

end

function runeHecengItem:onEnter()

end

function runeHecengItem:onExit()

end

function runeHecengItem:init()
    self.icon = me.assignWidget(self, "icon")
    self.box = me.assignWidget(self, "box")
    self.lvBox = me.assignWidget(self, "lvBox")
    self.lvBox:setVisible(false)
    self.typeBox = me.assignWidget(self, "typeBox")
    self.typeBox:setVisible(false)
    self.nameBox = me.assignWidget(self, "nameBox")
    self.nameBox:setVisible(false)

    return true
end

function runeHecengItem:setData(data)
    self.data=data.data
    self.icon:loadTexture(getRuneIcon(self.data.icon), me.plistType)
    self.box:loadTexture("levelbox"..self.data.level..".png", me.plistType)
    --self.nameTxt:setString(self.data.name)
    --self.typeIco:loadTexture("rune_type_"..self.data.type..".png",me.plistType)

    if data.flag==1 then
       me.Helper:normalImageView(self.icon) 
       me.Helper:normalImageView(self.box)
       --self.nameTxt:setTextColor(cc.c3b(212,205,185))
       --self.lvTxt:setTextColor(cc.c3b(255,255,255))
       --me.Helper:normalImageView(self.typeIco)
    elseif data.flag==3 then
       me.Helper:grayImageView(self.icon) 
       me.Helper:grayImageView(self.box)
       --self.nameTxt:setTextColor(cc.c3b(112,109,99))
       --self.lvTxt:setTextColor(cc.c3b(112,109,99))
       --me.Helper:grayImageView(self.typeIco)
    end
end


 
 
runeComposecell = class("runeComposecell",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]
    end
end)
runeComposecell.__index = runeComposecell
function runeComposecell:create(...)
    local layer = runeComposecell.new(...)
    if layer then 
        if layer:init() then 
            layer:registerScriptHandler(function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                end
            end)            
            return layer
        end
    end
    return nil 
end


function runeComposecell:initRuneItem(runeItemNode)
    self.runeIcon = runeHecengItem:create(runeItemNode, 1) 
    self.runeIcon:setScale(0.32) 
    self.runeIcon:setPosition(22, 14.35)
    me.assignWidget(self, "runeNode"):addChild(self.runeIcon)
end

function runeComposecell:setData(pData)
    if self.schId~=nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schId)
        self.schId=nil
    end

    self.runeIcon:setData(pData)
    self.srcData = pData
    self.data = pData.data
    self.cateType:loadTexture("rune_type_"..self.data.type..".png",me.plistType)
    self.nameTxt:setString(self.data.name)
    
    if pData["flag"]==1 then
        self.nameTxt:setTextColor(cc.c3b(255,240,221))
        me.Helper:normalImageView(self.cateType)
        self.activeTxt:setVisible(true)
        self.noActiveTxt:setVisible(false)
    else
        self.nameTxt:setTextColor(cc.c3b(127,127,127))
        me.Helper:grayImageView(self.cateType)
        self.activeTxt:setVisible(false)
        self.noActiveTxt:setVisible(true)
    end
    self.numsTxt1:setTextColor(cc.c3b(121,255,44))


    --判断用户材料是否足够合成
    self.table_need_item = self:analysisNeedItem()
    local flag = true 
    local i=1
    for key, var in ipairs(self.table_need_item) do
        local needNum = var.num
        local userItem = self:getPkgItemById(var.id)
        local hasNum = 0
        if userItem ~= nil then
            --print("userItem.count")
            --dump(userItem)
            hasNum = userItem.count
        end
        local cailiaoItem=nil
        if self.cailiaoTbl[i]==nil then
             cailiaoItem = self.cailiaoItem:clone():setVisible(true)
             self.cailiaoTbl[i]=cailiaoItem
             self:addChild(cailiaoItem)
        else
            cailiaoItem=self.cailiaoTbl[i]
            cailiaoItem:setVisible(true)
        end
        cailiaoItem:setPosition(144.69+(i-1)*53, 49.15)
        local cf = cfg[CfgType.ETC][tonumber(var.id)]
        local cailiaoIcon = me.assignWidget(cailiaoItem, "cailiaoIcon")
        cailiaoIcon:loadTexture("item_"..cf["icon"]..".png", me.plistType)
        i=i+1
        if tonumber(hasNum) < tonumber(needNum) then
            flag = false --材料不够
            me.Helper:grayImageView(cailiaoItem) 
            me.Helper:grayImageView(cailiaoIcon)
        else
            cailiaoItem:loadTexture("fuwen_kuang_pingzhi_"..cf.quality..".png", me.plistType)
            me.Helper:normalImageView(cailiaoItem) 
            me.Helper:normalImageView(cailiaoIcon)
        end
    end
    for j=i, #self.cailiaoTbl do
        self.cailiaoTbl[j]:setVisible(false)
    end

    if pData["flag"]==1 then
        if self.data["needRunNum"]==0 then
            self.numsTxt1:setString("-")
            self.numsTxt2:setString("/-")
            self.activeTxt:setVisible(false)
        else
            self.activeTxt:setVisible(false)
            
            --[[
            if self.srcData["hasRuneNums"] then
                self.numsTxt1:setString(self.srcData["hasRuneNums"])
                if self.srcData["hasRuneNums"]<self.data["needRunNum"] then
                    self.numsTxt1:setTextColor(cc.c3b(255,0,0))
                end
            else
                local function dataUpdate()
                    if self.srcData["hasRuneNums"] then
                        self.numsTxt1:setString(self.srcData["hasRuneNums"])
                        if self.srcData["hasRuneNums"]<self.data["needRunNum"] then
                            self.numsTxt1:setTextColor(cc.c3b(255,0,0))
                        end
                        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schId)
                        self.schId=nil
                    end
                end
                self.schId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(dataUpdate, 0, false)
                self.numsTxt1:setString("-")
            end
            self.numsTxt2:setString("/"..self.data["needRunNum"])
            ]]
        end
    else
        if self.srcData["altarLevel"] then
            local str = "圣殿"..self.srcData["altarLevel"].."级激活"
            self.noActiveTxt:setString(str)
        else
            local function dataUpdate()
                if self.srcData["altarLevel"] then
                    self.noActiveTxt:setString("圣殿"..self.srcData["altarLevel"].."级激活")
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schId)
                    self.schId=nil
                end
            end
            self.schId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(dataUpdate, 0, false)
            self.noActiveTxt:setString("")
        end
    end

    if flag==true then
        self.hecengFlag:setVisible(true)
        self.hecengFlag1:setVisible(true)
    else
        self.hecengFlag:setVisible(false)
        self.hecengFlag1:setVisible(false)
    end
end

function runeComposecell:get_need_altar_level(args)
    local level = self.data.level
    local info = getAllRuneBuildingCfgInfo()
    local need_altar_level = 100
    for key, var in pairs(info) do
        local unlock_level = getRuneBuildingCfgInfoByid(var.id)
        if unlock_level == level then
            if var.level <= need_altar_level then
                need_altar_level = var.level
            end
        end
    end
    return need_altar_level
end

function runeComposecell:getPkgItemById(id)
    for key, var in pairs(user.materBackpack) do
        --print("var.defid = "..var.defid)
        if tonumber(var.defid) == tonumber(id) then
            return var
        end
    end
    return nil
end

function runeComposecell:analysisNeedItem()
--"2030:62,2031:63,2032:67,2033:69"
    self.needItem = self.data.needItem
    local table_needItem = {}
    local temp1 = self.needItem:split(",")
    for key, var in pairs(temp1) do
        local temp2 = var:split(":")
        local id = temp2[1]
        local num = temp2[2]
        local temp = {id = id, num = num}
        table.insert(table_needItem, temp)
    end
    return table_needItem
end

function runeComposecell:ctor()  
   
end
function runeComposecell:init()  

    self.cateType = me.assignWidget(self,"cateType") 
    self.nameTxt = me.assignWidget(self,"nameTxt") 
    self.hecengFlag = me.assignWidget(self,"hecengFlag") 
    self.hecengFlag1 = me.assignWidget(self,"hecengFlag1") 
    self.numsTxt1 = me.assignWidget(self,"numsTxt1") 
    self.numsTxt2 = me.assignWidget(self,"numsTxt2") 
    self.activeTxt = me.assignWidget(self,"activeTxt") 
    self.noActiveTxt = me.assignWidget(self,"noActiveTxt") 
    self.cailiaoItem = me.assignWidget(self,"cailiaoItem")
    self.cailiaoTbl={}
    
    return true
end
function runeComposecell:onEnter()   
	--me.doLayout(self,me.winSize)  
end
function runeComposecell:onExit()  
end
