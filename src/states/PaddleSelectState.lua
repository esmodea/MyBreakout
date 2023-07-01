PaddleSelectState = Class{__includes = BaseState}

function PaddleSelectState:enter(params)
    self.highScores = params.highScores
end

function PaddleSelectState:init()
    -- the paddle we're highlighting; will be passed to the ServeState
    -- when we press Enter
    self.currentPaddle = 1
end