if arg[2] == "debug" then
    require("lldebugger").start()
end
function love.load()
    -- Screen dimensions
    screenWidth = 800
    screenHeight = 600
    love.window.setMode(screenWidth, screenHeight)
    love.window.setTitle("Simple Breakout")

    -- Paddle properties
    paddle = {}
    paddle.width = 100
    paddle.height = 20
    paddle.x = (screenWidth - paddle.width) / 2
    paddle.y = screenHeight - 40
    paddle.speed = 500

    -- Ball properties
    ball = {}
    ball.radius = 10
    ball.x = screenWidth / 2
    ball.y = paddle.y - ball.radius
    ball.speed = 300
    ball.dx = 300
    ball.dy = -300

    -- Bricks properties
    bricks = {}
    brickRows = 5
    brickCols = 10
    brickWidth = 70
    brickHeight = 20
    brickPadding = 10
    brickOffsetTop = 50
    brickOffsetLeft = 35

    for row = 1, brickRows do
        bricks[row] = {}
        for col = 1, brickCols do
            bricks[row][col] = {
                x = brickOffsetLeft + (col - 1) * (brickWidth + brickPadding),
                y = brickOffsetTop + (row - 1) * (brickHeight + brickPadding),
                width = brickWidth,
                height = brickHeight,
                alive = true
            }
        end
    end

    score = 0
    totalBricks = brickRows * brickCols
    gameOver = false
    gameWon = false
end

function love.update(dt)
    if gameOver or gameWon then
        return
    end

    -- Paddle movement
    if love.keyboard.isDown("left") then
        paddle.x = paddle.x - paddle.speed * dt
        if paddle.x < 0 then
            paddle.x = 0
        end
    elseif love.keyboard.isDown("right") then
        paddle.x = paddle.x + paddle.speed * dt
        if paddle.x + paddle.width > screenWidth then
            paddle.x = screenWidth - paddle.width
        end
    end

    -- Update ball position
    ball.x = ball.x + ball.dx * dt
    ball.y = ball.y + ball.dy * dt

    -- Ball collision with screen edges
    if ball.x - ball.radius < 0 then
        ball.x = ball.radius
        ball.dx = -ball.dx
    elseif ball.x + ball.radius > screenWidth then
        ball.x = screenWidth - ball.radius
        ball.dx = -ball.dx
    end

    if ball.y - ball.radius < 0 then
        ball.y = ball.radius
        ball.dy = -ball.dy
    elseif ball.y - ball.radius > screenHeight then
        gameOver = true
    end

    -- Ball collision with paddle
    if ball.y + ball.radius >= paddle.y and
       ball.x >= paddle.x and
       ball.x <= paddle.x + paddle.width and
       ball.dy > 0 then
        -- Reflect ball upward
        ball.y = paddle.y - ball.radius
        ball.dy = -ball.dy

        -- Add some angle based on where ball hit the paddle
        local hitPos = (ball.x - paddle.x) / paddle.width - 0.5
        ball.dx = ball.dx + hitPos * 200
    end

    -- Ball collision with bricks
    for row = 1, brickRows do
        for col = 1, brickCols do
            local brick = bricks[row][col]
            if brick.alive and CheckCircleRectCollision(ball.x, ball.y, ball.radius, brick.x, brick.y, brick.width, brick.height) then
                brick.alive = false
                score = score + 1
                ball.dy = -ball.dy
                if score == totalBricks then
                    gameWon = true
                end
                break
            end
        end
    end
end

function love.draw()
    -- Background
    love.graphics.clear(0, 0, 0.1)

    -- Draw paddle
    love.graphics.setColor(0.3, 0.7, 0.9)
    love.graphics.rectangle("fill", paddle.x, paddle.y, paddle.width, paddle.height)

    -- Draw ball
    love.graphics.setColor(0.9, 0.9, 0.3)
    love.graphics.circle("fill", ball.x, ball.y, ball.radius)

    -- Draw bricks
    for row = 1, brickRows do
        for col = 1, brickCols do
            local brick = bricks[row][col]
            if brick.alive then
                love.graphics.setColor(0.8, 0.3 + row*0.1, 0.3 + col*0.05)
                love.graphics.rectangle("fill", brick.x, brick.y, brick.width, brick.height)
            end
        end
    end

    -- Draw score
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. score, 10, 10)

    -- Draw game over / win messages
    if gameOver then
        love.graphics.printf("Game Over! Press R to restart", 0, screenHeight/2 - 20, screenWidth, "center")
    elseif gameWon then
        love.graphics.printf("YOU WIN! Press R to restart", 0, screenHeight/2 - 20, screenWidth, "center")
    end
end

function love.keypressed(key)
    if (gameOver or gameWon) and key == "r" then
        love.load()
    end
end

-- Helper function to check collision between circle and rectangle
function CheckCircleRectCollision(cx, cy, cr, rx, ry, rw, rh)
    -- Find closest point on rectangle to circle center
    local closestX = math.max(rx, math.min(cx, rx + rw))
    local closestY = math.max(ry, math.min(cy, ry + rh))

    -- Calculate distance between circle center and this closest point
    local distanceX = cx - closestX
    local distanceY = cy - closestY

    local distanceSquared = (distanceX * distanceX) + (distanceY * distanceY)
    return distanceSquared < (cr * cr)
end



























local love_errorhandler = love.errorhandler

function love.errorhandler(msg)
    if lldebugger then
        error(msg, 2)
    else
        return love_errorhandler(msg)
    end
end