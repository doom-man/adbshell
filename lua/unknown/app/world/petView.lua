petView = class("petView",function (...)   
    local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end    
end)
petView.__index = petView
function petView:create(...)
    local layer = petView.new(...)
    if layer then 
        if layer:init() then 
            layer:registerScriptHandler(function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                elseif "enterTransitionFinish" == tag then 
                    layer:enterTransitionFinish()
                end
            end)            
            return layer
        end
    end
    return nil 
end
function petView:ctor()   
    print("petView ctor")
    self.selectPet = 0
end

function petView:close() 
    print("petView close")  
    self:removeFromParentAndCleanup(true)         
end


function petView:init()   
    print("petView init")
    self.petList = me.assignWidget(self,"petList")
    self.petList:setScrollBarEnabled(false)
    self.bg = me.assignWidget(self,"bg")
    self.selectBorder = me.assignWidget(self,"selectBorder")
    
    me.registGuiTouchEventByName(self,"fixlayout",function (node,event)
        if event ~= ccui.TouchEventType.ended then
            return
        end  
        self:close()
    end)
    

   
  

    return true
end
function petView:setParpet(pParpet)
    local index = 1  
    local petsList = table.values(pParpet.pets)
    table.sort(petsList, function(a, b)
        return a.defid<b.defid
    end)
    for key,var in ipairs(petsList) do                   
      local petData = var:getDef()
      local petCell = petCell:create("petCell.csb")
      local iSize =  petCell:getContentSize()
      petCell:initWithData(petData,var.count)
      petCell:setPosition(cc.p((index-1)*(petCell:getContentSize().width+20)+20,6))

      if var.defid == pParpet.currentPetId then 
        self.selectBorder:setPosition(cc.p(petCell:getPositionX()+iSize.width / 2,petCell:getPositionY()+iSize.height / 2))
        self.selectBorder:setZOrder(me.MAXZORDER)
        self.selectBorder:setVisible(true)
      end

      index = index + 1
      me.registGuiClickEvent(petCell.petBtn, function()
          if not self.selectBorder:isVisible() then 
              self.selectBorder:setZOrder(me.MAXZORDER)
              self.selectBorder:setVisible(true)
          end
          self.selectBorder:setPosition(cc.p(petCell:getPositionX()+iSize.width / 2,petCell:getPositionY()+iSize.height / 2)) 
          pParpet:setCurrentPet(var.defid)
      end)
       self.petList:addChild(petCell)
       self.petList:setInnerContainerSize(cc.size((iSize.width+20)*(index-1)+20,iSize.height))
    end
 
end
function petView:onEnter()
  print("petView onEnter")
  me.doLayout(self,me.winSize) 
end
function petView:enterTransitionFinish()

end

function petView:onExit()
print("petView onExit")    
end