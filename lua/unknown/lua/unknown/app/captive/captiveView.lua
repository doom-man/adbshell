CaptiveView = class("CaptiveView",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end)
CaptiveView.__index = CaptiveView

function CaptiveView:create(...)
    local layer = CaptiveView.new(...)
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
function CaptiveView:ctor()  
       me.registGuiClickEventByName(self,"close",function (node)
         self:close()    
    end) 
end
function CaptiveView:close()       
    self:removeFromParentAndCleanup(true)         
end
function CaptiveView:init() 
    self.tabFun = {
        wood =  { slider = nil, t_cur = nil, userResNum = 0, proportion = 1 ,percent = 0,num =0},
        food =  { slider = nil, t_cur = nil, userResNum = 0, proportion = 1 ,percent = 0,num =0},
        stone = { slider = nil, t_cur = nil, userResNum = 0, proportion = 1 ,percent = 0,num =0},
        gold =  { slider = nil, t_cur = nil, userResNum = 0, proportion = 2 ,percent = 0,num =0}
    }
    self.canChange = true
    self.Master = CaptiveMgr:getMasterInfo()
    --test
    --self.Master = {name= "aaaaa",resource=400000,maxResource = 500000}
    local pCamp = ""
    if self.Master.camp then
       pCamp = self.Master.camp 
    end
    me.assignWidget(self, "Text_MasterName"):setString(pCamp..self.Master.name)
    me.assignWidget(self, "LoadingBar_1"):setPercent(self.Master.resource * 100 / self.Master.maxResource)

    self.bar = me.assignWidget(self, "LoadingBar_1_0")
    self.text_integral = me.assignWidget(self, "Text_integral")
    self.text_progress =  me.assignWidget(self, "Text_progress")
   
    self.btn_sure = me.registGuiClickEventByName(self,"Button_study",function (node)
         self:OnClickBtn()    
    end) 
    
    self.bar:setPercent(0)
    self.text_integral:setString(0)
    self.text_progress:enableOutline(cc.c3b(0, 0, 0), 1)
    self.text_progress:setString(self.Master.resource.."/"..self.Master.maxResource)
    
    for k, v in pairs(self.tabFun) do
        v.userResNum =  user[k]
        v.t_cur = me.assignWidget(self, "t_" .. k)
        me.assignWidget(self, "t_max_" .. k):setString("MAX " .. v.userResNum )
        v.t_cur:setString(0)

        local bg = me.assignWidget(self, "slider_bg_" .. k)
        v.slider = me.assignWidget(bg,"slider_bar")
        v.slider.tag = k
        local function sliderEvent(sender, eventType)
            print(eventType)
            if eventType == ccui.SliderEventType.percentChanged then
                local temp = self.tabFun[sender.tag]
                
                if not self.canChange and sender:getPercent() > temp.percent then
                    sender:setPercent(temp.percent)
                    self:adjust(sender)
                    return
                else
                    temp.t_cur:setString( math.floor(sender:getPercent() / 100 * temp.userResNum))
                    self:update(sender)
                end
            end
        end
        v.slider:addEventListener(sliderEvent)
    end
    
    return true
end

function CaptiveView:adjust(sender)
    local integral = 0
    for key, var in pairs(self.tabFun) do
        if var.num then
            local tempNum = var.slider == sender and 0 or var.num
            integral = integral + tempNum * var.proportion
        end
    end

    local needIntegral = self.Master.maxResource - self.Master.resource - integral 
    if needIntegral > 0 then
        self.text_integral:setString(integral + needIntegral)
        self.tabFun[sender.tag].t_cur:setString( math.ceil(needIntegral/ self.tabFun[sender.tag].proportion) )
        self.text_progress:setString(self.Master.maxResource .."/"..self.Master.maxResource)
    else
        
    end
end

function CaptiveView:update(sender)
    local integral = 0
    for key, var in pairs(self.tabFun) do
        var.percent = var.slider:getPercent()
        var.num = tonumber(var.t_cur:getString()) or 0
        if var.num and var.num > 0 then
            integral = integral +  var.num * var.proportion
        end
    end
    self.text_integral:setString(integral)
    self.bar:setPercent((self.Master.resource + integral) * 100 / self.Master.maxResource)
    self.text_progress:setString((self.Master.resource + integral) .."/"..self.Master.maxResource)
    self.canChange = self.Master.resource + integral < self.Master.maxResource
    if not self.canChange then 
        self:adjust(sender)
    end
end


function CaptiveView:OnClickBtn() 
    local tabSend = {food = 0,wood = 0,stone = 0,gold = 0}
    for key, var in pairs(self.tabFun) do
        local num = tonumber(var.t_cur:getString())
        tabSend[key] = num
    end
    GMan():send(_MSG.revertCaptive(tabSend))
    self:close()
end

function CaptiveView:onEnter()   
	me.doLayout(self,me.winSize)  
end
function CaptiveView:onExit()  
end
