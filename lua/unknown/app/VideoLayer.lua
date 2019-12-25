local VideoLayer = class("VideoLayer", function(...)
     return cc.Layer:create()
end )

function VideoLayer.create(...)
    layer = VideoLayer.new( ...)
    local function onEvent(event)
        if "exit" == event then
            layer:onExit()
        elseif "enter" == event then
            layer:onEnter()
        elseif "enterTransitionFinish" == event then
            layer:onEnterTransition()
        end
    end
    layer:registerScriptHandler(onEvent)
    return layer
end

function VideoLayer:ctor(...)
    local videoName, callback = ...


    local function onVideoEventCallback(sener, eventType)
        --MsgTips.show(eventType)
        if eventType == ccexp.VideoPlayerEvent.PLAYING then

        elseif eventType == ccexp.VideoPlayerEvent.PAUSED then

        elseif eventType == ccexp.VideoPlayerEvent.STOPPED then

        elseif eventType == ccexp.VideoPlayerEvent.COMPLETED then
            if callback==nil then
                self.videoPlayer:seekTo(0)
                self.videoPlayer:play()
            else
                callback()
            end
        end
    end

    local visibleRect = cc.Director:getInstance():getOpenGLView():getVisibleRect()
    local centerPos   = cc.p(visibleRect.x + visibleRect.width / 2,visibleRect.y + visibleRect.height /2)

    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if targetPlatform ==cc.PLATFORM_OS_IPHONE or targetPlatform ==cc.PLATFORM_OS_IPAD or targetPlatform ==cc.PLATFORM_OS_ANDROID then
        local videoPlayer = ccexp.VideoPlayer:create()
        videoPlayer:setPosition(centerPos)
        videoPlayer:setAnchorPoint(cc.p(0.5, 0.5))
        videoPlayer:setContentSize(cc.size(me.winSize.width,me.winSize.height))
        videoPlayer:addEventListener(onVideoEventCallback)
        videoPlayer:setFullScreenEnabled(true)
        self:addChild(videoPlayer)
        self.videoPlayer = videoPlayer

        local videoFullPath = cc.FileUtils:getInstance():fullPathForFilename(videoName)
        videoPlayer:setFileName(videoFullPath)   
        videoPlayer:play()
    end
end

function VideoLayer:onEnter()


end

function VideoLayer:onEnterTransition()

end

function VideoLayer:onExit()
    if self.videoPlayer~=nil then
        self.videoPlayer:stop()
        self.videoPlayer:removeFromParentAndCleanup(true)
    end
end

return VideoLayer