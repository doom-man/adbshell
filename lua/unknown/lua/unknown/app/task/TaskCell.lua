TaskCell = class("TaskCell", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        local pCell = me.assignWidget(arg[1], arg[2])
        local chs = pCell:getChildren()
        return pCell:clone():setVisible(true)
    end
end )
TaskCell.__index = TaskCell
function TaskCell:create(...)
    local layer = TaskCell.new(...)
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
    end
    return nil
end
function TaskCell:ctor()

end
function TaskCell:init()
    return true
end
function TaskCell:setTaskData(pData, pBool)
    if pData then
        local pConfig = pData:getDef()
        if pConfig then
            local newTask = me.assignWidget(self, "Image_new")
            newTask:setVisible(false)
            if LocalDataStorage:getNewTask(pConfig.id) == 1 and pData["progress"] ~= 3 and pBool ~= true then
                newTask:setVisible(true)
            end
            local pName = me.assignWidget(self, "task_cell_conent")

            pName:setString(pConfig["name"])

            if pData["progress"] == 3 then
                -- 完成
                me.assignWidget(self, "task_cell_complete"):setVisible(true)
            else
                me.assignWidget(self, "task_cell_complete"):setVisible(false)
            end

            -- 改变任务图标
            local taskIco = me.assignWidget(self, "icon")
            taskIco:loadTexture("taskIcon"..pConfig.typeIcon..".png",me.localType)
            me.assignWidget(taskIco, "taskType"):ignoreContentAdaptWithSize(true)
            taskIco:ignoreContentAdaptWithSize(true)
            if pConfig.type==3 then
                me.assignWidget(taskIco, "taskType"):loadTexture("richang.png",me.localType)
                me.assignWidget(taskIco, "taskType"):setVisible(true)

            else
                me.assignWidget(taskIco, "taskType"):loadTexture("zhuxian.png",me.localType)
                me.assignWidget(taskIco, "taskType"):setVisible(false)
            end
            --升级城镇中心 显示主线标志
            local tmp = string.split(pConfig.comConType,":")
            if tmp[1]=="upBuilding" then
                local tmp1 = string.split(tmp[2],"|")
                if tmp1[1]=="center" then
                    me.assignWidget(taskIco, "taskType"):loadTexture("zhuxian.png",me.localType)
                    me.assignWidget(taskIco, "taskType"):setVisible(true)
                end
            end

            -- 选中状态
            if pBool == true then
                me.assignWidget(self, "task_cell_bg_pitch"):setVisible(true)
                me.assignWidget(self, "task_cell_bg_normal"):setVisible(false)
                pName:setTextColor(cc.c3b(240,191,99))                
            else
                me.assignWidget(self, "task_cell_bg_pitch"):setVisible(false)
                me.assignWidget(self, "task_cell_bg_normal"):setVisible(true)
                pName:setTextColor(cc.c3b(185,168,135))                
            end
        end
    end
end
function TaskCell:onEnter()
    -- me.doLayout(self,me.winSize)
end
function TaskCell:onExit()
end
