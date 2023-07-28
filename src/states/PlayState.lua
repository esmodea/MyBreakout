PlayState = Class{__includes = BaseState}

function PlayState:enter(params)
    self.paddle = params.paddle
    self.ball = params.ball
    self.bricks = params.bricks
    self.score = params.score
    self.health = params.health
    self.level = params.level
    self.direction = params.direction
    self.lengthPowerup = params.lengthPowerup
    self.lengthPowerup2 = params.lengthPowerup2


    if params.direction == 0 then
        self.ball.dx = math.abs(math.random(-200, 200))
    else
        self.ball.dx = -math.abs(math.random(-200, 200))
    end
    self.ball.dy = math.random(-70, -80)
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    self.paddle:update(dt)
    self.ball:update(dt)

    if self.ball:collides(self.paddle) then
        self.ball.y = self.paddle.y - self.ball.height
        self.ball.dy = -self.ball.dy

        if self.score > (1500 / self.health) and not self.lengthPowerup then
            self.lengthPowerup = true
            if self.paddle.size <= 3 then self.paddle.size = self.paddle.size + 1 end
        end
        if self.score > (15000 / self.health) and not self.lengthPowerup2 then
            self.lengthPowerup2 = true
            if self.paddle.size <= 3 then self.paddle.size = self.paddle.size + 1 end
        end

        if self.paddle.dx < 0 then
            self.ball.dx = -50 + -math.abs(8 * (self.paddle.x + self.paddle.width / 2 - self.ball.x))
        elseif self.paddle.dx > 0 then
            self.ball.dx = 50 + math.abs(8 * (self.paddle.x + self.paddle.width / 2 - self.ball.x))
        end

        gSounds['paddle-hit']:play()
    end

    for k, brick in pairs(self.bricks) do 
        if brick.inPlay and self.ball:collides(brick) then

            self.score = self.score + (brick.tier * 200 + brick.color * 25)

            brick:hit()

            if self:checkVictory() then
                gSounds['victory']:play()

                gStateMachine:change('victory', {
                    level = self.level,
                    paddle = self.paddle,
                    health = self.health,
                    score = self.score,
                    ball = self.ball,
                    lengthPowerup = self.lengthPowerup,
                    lengthPowerup2 = self.lengthPowerup2
                })
            end

            if self.ball.x + 2 < brick.x and self.ball.dx > 0 then
                self.ball.dx = -self.ball.dx
                self.ball.x = brick.x - self.ball.width
            elseif self.ball.x + 6 > brick.x + brick.width and self.ball.dx < 0 then
                self.ball.dx = -self.ball.dx
                self.ball.x = brick.x + brick.width
            elseif self.ball.y < brick.y then
                self.ball.dy = -self.ball.dy
                self.ball.y = brick.y - self.ball.height
            else
                self.ball.dy = -self.ball.dy
                self.ball.y = brick.y + brick.height
            end

            self.ball.dy = self.ball.dy * 1.02

            break
        end
    end

    if self.ball.y >= VIRTUAL_HEIGHT then
        self.health = self.health - 1
        gSounds['hurt']:play()

        if self.health <= 0 then 
            gStateMachine:change('game-over', {
                score = self.score,
                highScores = loadHighScores()
            })
        else
            gStateMachine:change('serve', {
                level = self.level,
                paddle = self.paddle,
                bricks = self.bricks,
                health = self.health,
                score = self.score,
                lengthPowerup = self.lengthPowerup,
                lengthPowerup2 = self.lengthPowerup2
            })
        end
    end

    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then 
        love.event.quit()
    end
end

function PlayState:render()
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render(self.paddle.size)
    self.ball:render()

    renderScore(self.score)
    renderHealth(self.health)

    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end
    end

    return true 
end

function PlayState:checkPowerup()
    local powerup = ''
    local healthPowerups = 0
    if self.score > 1000 and math.floor(self.score / 1000) % (1000 / healthPowerups) == 0 then
        healthPowerups = healthPowerups + 1
        if not self.health == 3 then 
            self.health = self.health + 1
        else
            --soon I will add functionality to grow paddle.
        end
    end

end