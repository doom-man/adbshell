--[Comment]
--jnmo
convergeCombatRecord = class("convergeCombatRecord",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
convergeCombatRecord.__index = convergeCombatRecord
function convergeCombatRecord:create(...)
    local layer = convergeCombatRecord.new(...)
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
function convergeCombatRecord:ctor()   
    print("convergeCombatRecord ctor") 
end
function convergeCombatRecord:init()   
    print("convergeCombatRecord init")
	me.registGuiClickEventByName(self,"close",function (node)
        self:close()     
    end)    
    return true
end
function convergeCombatRecord:onEnter()
    print("convergeCombatRecord onEnter") 
    --排序
    table.sort(user.teamHistoryList,function (a,b)
        return a.time > b.time
    end)
    self:setTableView()
    self.close_event = me.RegistCustomEvent("convergeCombatRecord",function (evt)
        self:close()
    end)
	me.doLayout(self,me.winSize)  
end
function convergeCombatRecord:onEnterTransitionDidFinish()
	print("convergeCombatRecord onEnterTransitionDidFinish") 
end
function convergeCombatRecord:onExit()
    me.RemoveCustomEvent(self.close_event)
    print("convergeCombatRecord onExit")    
end
function convergeCombatRecord:close()
    self:removeFromParentAndCleanup(true)  
end

function convergeCombatRecord:setTableView()
    if #user.teamHistoryList <= 0 then
        showTips("暂无集火历史记录")
        return 
    end

    local function numberOfCellsInTableView(table)
        return #user.teamHistoryList
    end

    local function cellSizeForTable(table,idx)
        return 1166, 166 + 5
    end
    
    local function tableCellTouched(table, cell)
      
    end

    local function tableCellAtIndex(table,idx)
        local cell = table:dequeueCell() 
        local node = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            node = cc.CSLoader:createNode("convergeWarRecord.csb")
            node:setPosition(cc.p(0, 5))
            cell:addChild(node)
            node:setTag(999)
        else
            node = cell:getChildByTag(999)
        end
        local sData = user.teamHistoryList[me.toNum(idx+1)]

        if node == nil then
            __G__TRACKBACK__("node = nil !!")
            return
        end

        local leftPlayer, rightPlayer = nil ,nil
        if sData.rType == 3 then -- 集火
            me.assignWidget(node,"Fight_Icon"):loadTexture("jihuo_tubiao_jilv_jingong.png",me.localType)
            me.assignWidget(node,"Fight_attack"):setString("集火")
            me.assignWidget(node,"Next_attack_type"):setString("进攻方")
            me.assignWidget(node,"match_attack_type"):setString("防御方")
            leftPlayer = sData.attacker
            rightPlayer = sData.defener
        elseif sData.rType == 4 then --防御
            me.assignWidget(node,"Fight_Icon"):loadTexture("jihuo_tubiao_jilv_fangyu.png",me.localType)
            me.assignWidget(node,"Fight_attack"):setString("防御")
            me.assignWidget(node,"Next_attack_type"):setString("防御方")
            me.assignWidget(node,"match_attack_type"):setString("进攻方")
            leftPlayer = sData.defener
            rightPlayer = sData.attacker
        end
        me.assignWidget(node,"Fight_Position"):setString("("..rightPlayer.x..","..rightPlayer.y..")")
        me.assignWidget(node,"Fight_Time"):setString(me.GetSecTime(sData.time,true))
        if sData.win and me.toNum(sData.win) == 1 then
            me.assignWidget(node,"Fight_win_Icon"):loadTexture("zhanbao_icon_shengli.png", me.localType)
        else
            me.assignWidget(node,"Fight_win_Icon"):loadTexture("zhanbao_icon_shibai.png", me.localType)
        end
        me.assignWidget(node,"Fight_name"):setString(leftPlayer.name)
        me.assignWidget(node,"Fight_match_name"):setString(rightPlayer.name)
        me.assignWidget(node,"Next_attack_pople_num"):setString(leftPlayer.playerNum)
        me.assignWidget(node,"match_attack_pople_num"):setString(rightPlayer.playerNum)
        me.registGuiClickEventByName(node,"Button_point",function (node)
            LookMap(cc.p(rightPlayer.x,rightPlayer.y),"convergeCombatRecord","convergeView","allianceview")
        end)

        return cell
    end

    self.tableView = cc.TableView:create(cc.size(1166, 580))
    self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.tableView:setDelegate()
    self.tableView:setPosition(cc.p(10, 5))
    me.assignWidget(self,"Node_tab"):addChild(self.tableView)
    self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)  
    self.tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    self.tableView:reloadData()   
end