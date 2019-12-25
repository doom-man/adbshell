--联盟要塞 
allianceLogView = class("allianceLogView",function (...)
    local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）       
        local pCell = me.assignWidget(arg[1],arg[2])
        return pCell:clone():setVisible(true)
    end
end)
allianceLogView.__index = allianceLogView
function allianceLogView:create(...)
    local layer = allianceLogView.new(...)
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
function allianceLogView:ctor()  
     me.registGuiClickEventByName(self,"close",function(node)
       self:close()
     end)
     self.curKey = 0
end
function allianceLogView:close()
  self:removeFromParentAndCleanup(true)
end
function allianceLogView:init()
    print("allianceLogView init")
    self.list = me.assignWidget(self,"infoList")
    self.list:setScrollBarEnabled(false)

    self.date = me.assignWidget(self,"time")
    self.logData = {}
    self.keyTb = {}
    --self:loadData("今天")
    --self:loadData("3月22日")
    --self:loadData("3月21日")
    return true
end
function allianceLogView:initWithData(data)
  print("allianceLogView initWithData")
  for key,var in pairs(data) do 
    local timeTb = me.split(var.time," ")
    local date = timeTb[1].." "..timeTb[2].." "..timeTb[3] 
    if not self.logData[date] then 
       self.logData[date] = {}
       table.insert(self.keyTb,date)
    end
    table.insert(self.logData[date],var)               
  end
  self:sortLogTable(self.logData)
--  for key,var in ipairs(self.keyTb) do 
--     self:loadDateData(var,self.logData[var])
--     if key == 2 then 
--        self.curKey = 2
--        break
--     end
--  end
   self:initLog()
end

--function allianceLogView:loadDateData(date, data)
--    local curDate = self.date:clone()
--    local m,d = self:getDate(date)
--    if m == os.date("*t").month and d == os.date("*t").day then 
--      me.assignWidget(curDate,"timeText"):setString("今天")
--    else
--      me.assignWidget(curDate,"timeText"):setString(m.."月"..d.."日")
--    end
--    curDate:setVisible(true)
--    self.list:addChild(curDate)
--    for key,var in pairs(data) do 
--        local strTb = me.split(cfg[CfgType.UNION_LOG][var.id].data,"|")
--        local time = me.split(var.time," ")[4]
--        local name = var.info
--        if me.toNum(var.id) <= 2 then 
--           strTb[1] = strTb[1]..name[1]
--        elseif me.toNum(var.id) <= 4 then 
--           strTb[1] = strTb[1]..name[1]
--           strTb[2] = strTb[2]..name[2]
--           strTb[3] = strTb[3]..me.alliancedegree(me.toNum(name[3]))
--        elseif me.toNum(var.id) == 5 then 
--           strTb[1] = strTb[1]..name[1]
--        elseif me.toNum(var.id) <=9 then 
--           strTb[1] = strTb[1]..name[1]
--           strTb[2] = strTb[2]..name[2]
--        elseif me.toNum(var.id) <= 11 then 
--           strTb[1] = strTb[1]..name[1]          
--        end                    
--        local s = table.concat(strTb)
--        local str = "<txt0018,d4c5b4>"..time.." &"..s
--        local rich = mRichText:create(str,700)
--        self.list:addChild(rich)
--    end
--end
    
function allianceLogView:initLog()
    local dataTb = {}
    for key,var in ipairs(self.keyTb) do        
        for k,v in ipairs(self.logData[var]) do 
           local item = {}
           item.data = v       
           table.insert(dataTb,item)
        end
    end
    
    local num = #dataTb
    local function cellSizeForTable(table, idx)
        return 757, 81 + 15
    end

    local function tableCellAtIndex(tableView, idx)
        -- print(idx)        
        local cell = tableView:dequeueCell()   
        local data = dataTb[idx+1].data     
        local function setCellInfo(tmpCell)
            
            local curDate = self.date:clone()
            local m,d = self:getDate(data.time)
            if m == os.date("*t").month and d == os.date("*t").day then 
              me.assignWidget(curDate,"timeText"):setString("今天")
            else
              me.assignWidget(curDate,"timeText"):setString(m.."月"..d.."日")
            end
            if idx %2 == 0 then 
              --curDate:loadTexture("default.png",me.localType)
            end
            curDate:setPosition(cc.p(0, 15))
            curDate:setVisible(true)
            tmpCell:addChild(curDate)  
        
            local strTb = me.split(cfg[CfgType.UNION_LOG][data.id].data,"|")
            local time = me.split(data.time," ")[4]
            me.assignWidget(curDate, "timeText_2"):setString(time)
            local name = data.info
            local pWidth = 700
            local pPointY = 0
            if me.toNum(data.id) <= 2 then 
               strTb[1] = strTb[1]..name[1]
            elseif me.toNum(data.id) <= 4 then 
               strTb[1] = strTb[1]..name[1]
               strTb[2] = strTb[2]..name[2]
               strTb[3] = strTb[3]..me.alliancedegree(me.toNum(name[3]))
            elseif me.toNum(data.id) == 5 then 
               strTb[1] = strTb[1]..name[1]..""..name[2]
            elseif me.toNum(data.id) == 6 or me.toNum(data.id) == 8 then 
               strTb[1] = strTb[1]..name[1].." "..name[2]
               strTb[2] = strTb[2]..name[3]                   
            elseif me.toNum(data.id) == 14  then
               strTb[1] = strTb[1]..name[1]
               strTb[2] = strTb[2]..name[2]
            elseif me.toNum(data.id) == 21 then
               strTb[1] = strTb[1]..name[1]
               strTb[2] = strTb[2]..name[2]
               pWidth = 650
               pPointY = -15 
            elseif me.toNum(data.id) <=9 then 
               strTb[1] = strTb[1]..name[1]
               strTb[2] = strTb[2]..name[2]
               strTb[3] = strTb[3]..name[3]
            elseif me.toNum(data.id) <= 11 then 
               strTb[1] = strTb[1]..name[1]      
            elseif me.toNum(data.id) == 12 or me.toNum(data.id) == 20 then     
               dump()                  
               strTb[1] = strTb[1]..name[1]
               strTb[2] = strTb[2]..name[2]
               strTb[3] = strTb[3]..name[3]
               pWidth = 650
               pPointY = -15
            elseif me.toNum(data.id) == 13 then
               strTb[1] = strTb[1]..name[1] 
            elseif me.toNum(data.id) == 16 then
                local pAlliance = name[4]
                if name[4] == "" then
                   pAlliance = "流浪"
                end  
               strTb[1] = strTb[1]..name[1]
               strTb[2] = strTb[2]..name[2]
               strTb[3] = strTb[3]..name[3]
               strTb[4] = strTb[4]..pAlliance
               strTb[5] = strTb[5]..name[5]
               strTb[6] = strTb[6]..name[6]
               pWidth = 650
               pPointY = -15 
            elseif me.toNum(data.id) == 17 then
                local pAlliance = name[2]
                if name[2] == "" then
                   pAlliance = "流浪"
                end  
               strTb[1] = strTb[1]..name[1]                 
               strTb[2] = strTb[2]..pAlliance
               strTb[3] = strTb[3]..name[3]
               strTb[4] = strTb[4]..name[4]    
               pWidth = 650
               pPointY = -15 
           elseif me.toNum(data.id) == 18 then                       
               strTb[1] = strTb[1]..name[1]
               strTb[2] = strTb[2]..name[2]
               strTb[3] = strTb[3]..name[3]
               strTb[4] = strTb[4]..name[4]
               strTb[5] = strTb[5]..name[5]      
               pWidth = 650
               pPointY = -15                                            
           elseif me.toNum(data.id) == 19 then                       
               strTb[1] = strTb[1]..name[1]
               strTb[2] = strTb[2]..name[2]
               strTb[3] = strTb[3]..name[3]
               strTb[4] = strTb[4]..name[4]   
               pWidth = 650
               pPointY = -15    
           elseif me.toNum(data.id) == 22 then                       
               strTb[1] = strTb[1]..name[1]
               strTb[2] = strTb[2]..name[2]
               pWidth = 650
               pPointY = -15   
           elseif me.toNum(data.id) == 23 then                       
               strTb[1] = strTb[1]..name[1]
               strTb[2] = strTb[2]..name[2]
               pWidth = 650
               pPointY = -15           
           elseif me.toNum(data.id) == 24 or me.toNum(data.id) == 25 then                       
               strTb[1] = strTb[1]..name[1]
               strTb[2] = strTb[2]..name[2]
               strTb[3] = strTb[3]..name[3]  
               pWidth = 650
               pPointY = -15                         
            end                    
            local s = table.concat(strTb)
            local str = s
            if me.toNum(data.id) == 5 or me.toNum(data.id) == 6 or me.toNum(data.id) == 8 or me.toNum(data.id) == 16 then
                str = parseRichtText(str)
            end
            pWidth = 710
            local rich = mRichText:create(str, pWidth)
            rich:registCallback(function (pos_)
                LookMap(pos_,"allianceview")
            end)
            --rich:setPosition(cc.p(35, (curDate:getContentSize().height - rich:getContentSize().height)/2))
            rich:setAnchorPoint(cc.p(0, 0.5))
            rich:setPosition(cc.p(20, 25))
            rich:setSwallowTouches(false)
            curDate:addChild(rich)
        end

        if nil == cell then
            cell = cc.TableViewCell:new()
            setCellInfo(cell)
        else
          cell:removeAllChildren()
          setCellInfo(cell)
        end  
        return cell
    end

    local function numberOfCellsInTableView(table)        
        return num
    end

    self.tableView = cc.TableView:create(cc.size(757, 466))
    self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.tableView:setPosition(cc.p(0, 0))
    self.tableView:setDelegate()
    me.assignWidget(self,"body"):addChild(self.tableView)      
    self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.tableView:reloadData() 
end

function allianceLogView:onEnter()   
	me.doLayout(self,me.winSize)  
end
function allianceLogView:onExit()  
end

function allianceLogView:sortLogTable(tb) 
   table.sort(self.keyTb,function(a,b)
     local aM,aD = self:getDate(a)
     local bM,bD = self:getDate(b)
     if aM == bM then 
       return aD > bD
     else 
       return aM > bM
     end
   end)
   for key,var in pairs(tb) do 
      table.sort(var,function(a,b)
      return self:getSecTime(a) > self:getSecTime(b)
      end)
   end
end
function allianceLogView:getDate(date)
  local dateTb = me.split(date," ")
  local month = dateTb[2]
  local m 
  if month == "Jan" then m = 1 
  elseif month =="Feb" then m = 2
  elseif month =="Mar" then m = 3
  elseif month =="Apr" then m = 4
  elseif month =="May" then m = 5
  elseif month =="Jun" then m = 6
  elseif month =="Jul" then m = 7
  elseif month =="Aug" then m = 8
  elseif month =="Sep" then m = 9
  elseif month =="Oct" then m = 10
  elseif month =="Nov" then m = 11
  elseif month =="Dec" then m = 12 end

  local d = me.toNum(dateTb[3])
  return m,d   
end
function allianceLogView:getSecTime(tb) 
    local time = me.split(tb.time," ")[4]
    local _,_,h,m,s = string.find(time,"(.+):(.+):(.+)")
    local second = me.toNum(h) * 3600 + me.toNum(m)*60 + me.toNum(s)
    return second
end
