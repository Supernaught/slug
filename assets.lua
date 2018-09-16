local assets = {}

love.graphics.setDefaultFilter("nearest", "nearest")

-- Images
assets.whiteCircle = love.graphics.newImage("assets/img/white_circle.png")
assets.whiteSquare = love.graphics.newImage("assets/img/white_square.png")
assets.redSquare = love.graphics.newImage("assets/img/red_square.png")
assets.player = love.graphics.newImage("assets/img/player.png")
assets.jellyfish = love.graphics.newImage("assets/img/jellyfish.png")
assets.bg = love.graphics.newImage("assets/img/bg.png")
assets.bullet = love.graphics.newImage("assets/img/bullet.png")

-- Fonts
assets.font_lg = love.graphics.newFont("assets/fonts/04b03.ttf", 24)
assets.font_md = love.graphics.newFont("assets/fonts/04b03.ttf", 16)
assets.font_sm = love.graphics.newFont("assets/fonts/04b03.ttf", 8)

-- Sfx
-- assets.music = love.audio.newSource(love.sound.newDecoder("assets/sfx/music.mp3"))

-- Shaders
assets.spark_shader = love.graphics.newShader("alphonsus/shaders/spark.fs")

return assets