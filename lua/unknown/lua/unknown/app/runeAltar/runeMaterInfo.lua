runeMaterInfo = class("runeMaterInfo", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end )
runeMaterInfo.__index = runeMaterInfo
function runeMaterInfo:create(...)
    local layer = runeMaterInfo.new(...)

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
        else
        print("---------------------->>>>")
    end
    return nil
end

function runeMaterInfo:ctor()
    self.view_name = "runeMaterInfo"
end

function runeMaterInfo:setData(data)
    self.data = data
    self.id = self.data.id --  材料配置id
    
--    local url = getRuneQualityIcon(self.data.quality)
--    self.image_mtr_bg:loadTexture(url, me.localType)

    self.image_mtr:loadTexture(getItemIcon(self.data.id), me.localType)

    self.text_mtr_name:setString(self.data.name)

    self.text_drop:setString(self.data.describe)
end

function runeMaterInfo:close()
    me.DelayRun( function(args)
        self:removeFromParentAndCleanup(true)
    end )
end

function runeMaterInfo:init()
    print("runeMaterInfo:init() ")
    --me.doLayout(self, me.winSize)
    --材料品质图片
    self.image_mtr_bg = me.assignWidget(self, "Image_mtr_bg")
    self.image_mtr_bg:setVisible(false)
    --材料图片
    self.image_mtr = me.assignWidget(self, "Image_mtr")
    --材料名称
    self.text_mtr_name = me.assignWidget(self, "Text_mtr_name")
    --掉落地点
    self.text_drop = me.assignWidget(self, "Text_drop")

    --前往掉落地点
    local button_1 = me.registGuiClickEventByName(self, "Button_1", function(node)
            self:gotoDropArea()
        end)
    --前往材料合成
    local button_2 = me.registGuiClickEventByName(self, "Button_2", function(node)
            self:gotoCompose()
        end)
    return true
end

function runeMaterInfo:gotoDropArea()
    NetMan:send(_MSG.Rune_find_guard_init())
    print("前往掉落地点")
    self:close()
end

function runeMaterInfo:gotoCompose()
    print("前往材料合成")
    local runeBagView = runeBagView:create("rune/runeBagView.csb")
    -- self.selectView:setParentView(self)
    me.runningScene():addChild(runeBagView, me.MAXZORDER)
    me.showLayer(runeBagView,"bg")

    runeBagView:setSelectedButton(1, self.id)
    self:close()
end


function runeMaterInfo:close()
    me.DelayRun( function(args)
        if self.sender ~= nil then
            self.sender:removeMtrInfoView()
        end
    end )
end

function runeMaterInfo:onEnter()
end
function runeMaterInfo:onExit()
--    UserModel:removeLisener(self.netListener)
--    me.RemoveCustomEvent(self.close_event)
end

function runeMaterInfo:setParent(sender)
    self.sender = sender
end