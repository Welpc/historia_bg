-- main.lua

-- Posición inicial del botón
local boton = {
    x = 200,
    y = 200,
    width = 100,
    height = 50,
    color = {1, 0, 0} -- rojo
}

local arrastrando = false
local offsetX, offsetY = 0, 0

function love.load()
    love.window.setTitle("Botón rojo movible")
end

function love.draw()
    -- dibuja el botón
    love.graphics.setColor(boton.color)
    love.graphics.rectangle("fill", boton.x, boton.y, boton.width, boton.height)
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    -- si tocamos dentro del botón, empezamos a arrastrar
    if x >= boton.x and x <= boton.x + boton.width and
       y >= boton.y and y <= boton.y + boton.height then
        arrastrando = true
        offsetX = x - boton.x
        offsetY = y - boton.y
    end
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    -- si estamos arrastrando, movemos el botón
    if arrastrando then
        boton.x = x - offsetX
        boton.y = y - offsetY
    end
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    arrastrando = false
end
