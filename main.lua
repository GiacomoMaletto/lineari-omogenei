local random_shader = love.graphics.newShader([[
	uniform float seed;

  float PHI = 1.61803398874989484820459;

  float gold_noise(in vec2 xy, in float seed){
    return fract(tan(distance(xy*PHI, xy)*seed)*xy.x);
  }
	
	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 sc){	
		return vec4(gold_noise(sc, seed), gold_noise(sc, seed+1), 0.0, 1.0);
	}
]])

local draw_shader = love.graphics.newShader([[
	uniform Image X;
  uniform float N;
  uniform vec2 screen;

	vec4 position(mat4 transform_projection, vec4 vertex_position)
	{
		vec2 xy = Texel(X, vec2(vertex_position)/N).xy;
		return transform_projection * vec4(xy*1000, screen.x*0.0001, 1.0);
	}
]])

local V, M = unpack(require "vector")
local sw, sh = love.graphics.getDimensions()
draw_shader:send("screen", {sw, sh})

local white = love.graphics.newCanvas(sw, sh)
love.graphics.setCanvas(white)
love.graphics.clear(1, 1, 1)
love.graphics.setCanvas()

local A = {{0.5, 1.5}, {-0.5, 0.5}}

local x = {}
local N = 1024
draw_shader:send("N", N)
x[1] = love.graphics.newCanvas(N, N, {format="rg32f"})
x[2] = love.graphics.newCanvas(N, N, {format="rg32f"})
local nx, ox = x[1], x[2]

love.graphics.setShader(random_shader)
love.graphics.setCanvas(x[1])
random_shader:send("seed", love.math.random())
love.graphics.draw(white)
love.graphics.setCanvas(x[2])
love.graphics.draw(white)
love.graphics.setShader()
love.graphics.setCanvas()

local vertices = {}
for x = 1, N do
	for y = 1, N do
		vertices[#vertices+1] = {x, y}
	end
end
local mesh = love.graphics.newMesh(vertices, "points", "static")

function love.update(dt)
  if love.keyboard.isDown("escape") then
    love.event.quit()
  end

  --x_shader:send("dt", dt)
  nx, ox = ox, nx
end

function love.draw()
  --love.graphics.setShader(x_shader)
  --x_shader:send("A", A)
  --love.graphics.setCanvas(nx)

  --love.graphics.setCanvas()
  --love.graphics.setShader()

  love.graphics.setColor(1, 1, 1)
  love.graphics.setShader(draw_shader)
	draw_shader:send("X", nx)
	love.graphics.draw(mesh)
  love.graphics.setShader()

  --love.graphics.draw(nx)
end