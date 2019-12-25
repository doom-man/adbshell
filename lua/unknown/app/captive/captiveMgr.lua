-- 沦陷反叛数据管理
captiveMgr = class("captiveMgr")

function captiveMgr:getInstance()
    if not self.instance then
        self.instance = self:new()
    end
    return self.instance
end

function captiveMgr:ctor()
    self.capticesList = { }
    -- 联盟沦陷列表

    -- 被沦陷信息
    self.masterInfo = nil
    self.test = true
end

function captiveMgr:updateCapticesList(captices)
    self.capticesList = captices
end

function captiveMgr:getCapticesList()
    return self.capticesList
end

function captiveMgr:updateMasterInfo(masterInfo)
    self.masterInfo = masterInfo
end

function captiveMgr:getMasterInfo()
    return self.masterInfo
end

function captiveMgr:clearMasterInfo()
    self.masterInfo = nil
end

function captiveMgr:isCaptured()
    return self.masterInfo ~= nil
end

CaptiveMgr = captiveMgr:getInstance()
