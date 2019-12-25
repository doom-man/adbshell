--[Comment]
--jnmo
recomondPromView = class("recomondPromView",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
recomondPromView.__index = recomondPromView
function recomondPromView:create(...)
    local layer = recomondPromView.new(...)
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
recomondPromView.DOWNLOADREBATE = 1 -- 下载
recomondPromView.PINGLUN = 2 -- 评论
recomondPromView.SHARE= 3 -- 分享

function recomondPromView:ctor()   
    print("recomondPromView ctor") 
    self.selCellId = nil
end
function recomondPromView:init()   
    print("recomondPromView init")
    self.Panel_right = me.assignWidget(self, "Panel_right")
	me.registGuiClickEventByName(self,"close",function (node)
        self:close()     
    end)    
    self.selCellId = 1
    self:setData()
    return true
end
function recomondPromView:setData()
     self.mPopularize = {}
    for key, var in pairs(user.popularizeData) do
        table.insert(self.mPopularize,var)
    end
    me.assignWidget(self,"Image_left"):removeAllChildren()
    self.Panel_right:removeAllChildren()
    self:revInitList()
    self:setRightView(self.mPopularize[self.selCellId])
    self:setSelectTableCell(self.selCellId)
end
function recomondPromView:setUpData()
     self.mPopularize = {}
    for key, var in pairs(user.popularizeData) do
        table.insert(self.mPopularize,var)
    end
 --   me.assignWidget(self,"Image_left"):removeAllChildren()
    self.Panel_right:removeAllChildren()
 --   self:revInitList()
    self:setRightView(self.mPopularize[self.selCellId])
--    self:setSelectTableCell(self.selCellId)
    if self.mPopularize[self.selCellId]["status"] == 2 then
          self:getGoodsAnimation(self.mPopularize[self.selCellId])
    end
end
function recomondPromView:setRightView(pData)
    if pData then
       self.mData = pData
       if pData["pType"] == recomondPromView.PINGLUN or pData["pType"] == recomondPromView.SHARE or pData["pType"] == recomondPromView.DOWNLOADREBATE then
           self.Panel_right:removeAllChildren()
           local pDownView = downloadRebate:create("downloadRebate.csb")
           pDownView:setData(pData)
           self.Panel_right:addChild(pDownView)
       end
    end
end
function recomondPromView:revInitList()
    local pNum = #self.mPopularize  
    local function numberOfCellsInTableView(table)
        return pNum
    end

    local function cellSizeForTable(table, idx)
        return 276, 86
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()        
        if nil == cell then
            cell = cc.TableViewCell:new()
            local node = me.assignWidget(self, "table_prom_cell"):clone()
            self:setCell(node,self.mPopularize[idx+1])
            cell:addChild(node)
            node:setVisible(true)
        else
           local node =me.assignWidget(cell, "table_prom_cell")
           self:setCell(node,self.mPopularize[idx+1])
        end
        return cell
    end

    local function tableCellTouched(table, cell)
        local pId = cell:getIdx()+1
        self:setRightView(self.mPopularize[pId])
        self:setSelectTableCell(pId)
    end

    self.tableView = cc.TableView:create(cc.size(290,520))
    self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.tableView:setPosition(8,6)
    self.tableView:setAnchorPoint(cc.p(0,0))
    self.tableView:setDelegate()
    me.assignWidget(self,"Image_left"):addChild(self.tableView)
    self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)        
    self.tableView:reloadData()    
end
function recomondPromView:setCell(pNode,pData)
    if pData then
       local pIconStr = "huodong_anniu_xiazai.png"
       local pPromIcon = me.assignWidget(pNode,"Panel_icon"):setVisible(false)
       if pData["pType"] == recomondPromView.DOWNLOADREBATE then
             pIconStr = "huodong_anniu_xiazai.png" 
            local sprite = mNetSprite:createmNetSprite("huodong_xiazai_moren_tu.png");
	        sprite:setFullImageUrl(pData["image"], "huodong_xiazai_moren_tu.png",true)
            pPromIcon:addChild(sprite) 
            pPromIcon:setVisible(true) 
       elseif pData["pType"] == recomondPromView.PINGLUN then
          pIconStr = "huodong_anniu_xiazaifenxiang.png"   
           local sprite = mNetSprite:createmNetSprite("huodong_xiazai_moren_tu.png");
	        sprite:setFullImageUrl(pData["image"], "huodong_xiazai_moren_tu.png",true)
            pPromIcon:addChild(sprite) 
            pPromIcon:setVisible(true)     
       elseif pData["pType"] == recomondPromView.SHARE then
          pIconStr = "huodong_anniu_fenxiang.png"
           local sprite = mNetSprite:createmNetSprite("huodong_xiazai_moren_tu.png");
	        sprite:setFullImageUrl(pData["image"], "huodong_xiazai_moren_tu.png",true)
            pPromIcon:addChild(sprite) 
            pPromIcon:setVisible(true) 
       end
       local pIcon = me.assignWidget(pNode,"ImageView_cell_normal")
       pIcon:loadTexture(pIconStr,me.plistType)
    end
end
function recomondPromView:setSelectTableCell(msgId_)
    local function getCellByid(id_)
        for key, var in pairs(self.mPopularize ) do
            if me.toNum(key) == me.toNum(id_) then
                local cell = self.tableView:cellAtIndex(me.toNum(key)-1)
                return cell
            end
        end
    end

    if self.selCellId ~= nil and self.selCellId ~= msgId_ then
       local lastCell = getCellByid(self.selCellId)
       if lastCell then
           local ImageView= me.assignWidget(lastCell, "ImageView_cell_select") 
           ImageView:loadTexture("huodong_anniu_weixuanzhong_an.png",me.plistType)
       end
    end

    self.selCellId = msgId_
    local lastCell = getCellByid(self.selCellId)
    if lastCell then
        local ImageView =me.assignWidget(lastCell, "ImageView_cell_select") 
        ImageView:loadTexture("huodong_anniu_xuanzhong_liang.png",me.plistType)
    end    
end
function recomondPromView:getGoodsAnimation()       
      local i = {}            
      for key, var in pairs(self.mData["hortations"]) do
          local cfg = cfg[CfgType.ETC][var[1]]        
          i[#i+1] = {}
          i[#i]["defId"] = cfg["id"]
          i[#i]["itemNum"] = var[2]
          i[#i]["needColorLayer"] = true                     
      end                       
      getItemAnim(i)    
end
function recomondPromView:update(msg)
    if checkMsg(msg.t, MsgCode.POPULARIZE_SKIP_TIME) then     
       self.selCellId = msg.c.id              
       self:setUpData()      
    end
end
function recomondPromView:onEnter()
    print("recomondPromView onEnter") 
	me.doLayout(self,me.winSize)  
    self.modelkey = UserModel:registerLisener(function(msg)  -- 注册消息通知
        self:update(msg)        
    end)
end
function recomondPromView:onEnterTransitionDidFinish()
	print("recomondPromView onEnterTransitionDidFinish") 
end
function recomondPromView:onExit()
    print("recomondPromView onExit")   
    UserModel:removeLisener(self.modelkey) -- 删除消息通知 
    mainCity.pRecomond = nil
end
function recomondPromView:close()
    self:removeFromParentAndCleanup(true)  
end
