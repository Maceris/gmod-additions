--[[----------------------------------------------------------------------------
Text effects, based on and extending moatato's text effects. 
see https://github.com/moatato/moat-texteffects for the original.
------------------------------------------------------------------------------]]

local BUBBLE_MAX_SZ = 4
local M_SHOW_EFFECT_EXAMPLES = false
local __objects__ = {} -- the list of objects for the factory, don't touch it

--[[----------------------------------------------------------------------------
Align Text Helper
------------------------------------------------------------------------------]]
local function m_GetTextSize(text, font)
    surface.SetFont(font)
    return surface.GetTextSize(text)
end

--[[----------------------------------------------------------------------------
Utility Functions
------------------------------------------------------------------------------]]

--[[
GetMovableObj returns an object with position and speed. Sort of a base "class".
If you leave out 

x_pos = number for starting x, with 0 as the far left of the screen
y_pos = number for starting y, with 0 as the top of the screen
x_speed = number for x speed, where positive is moving right on the screen
y_speed = number for y speed, where positive is moving down on the screen
--]]
function GetMovableObj(x_pos, y_pos, x_speed, y_speed)
	x_pos = x_pos or 0
	y_pos = y_pos or 0
	x_speed = x_speed or 0
	y_speed = y_speed or 0
	
	local movobj = {x = x_pos, y = y_pos, x_spd = x_speed, y_spd = y_speed}
	return movobj
end

--[[
GetMovableObj takes a movable object and moves it within set bounds. If it hits 
one of the boudaries, it bounces off and goes the other way.

movable = the movable object (see GetMovableObj)
x_min = minimum x boundary
y_min = minimum y boundary
x_max = maximum x boundary
y_max = maximum y boundary
--]]
function MoveObj(movable, x_min, y_min, x_max, y_max)
	if (movable.x_spd > 0) then -- Moving right
		if (movable.x + movable.x_spd < x_max) then
			movable.x = movable.x + movable.x_spd
		else 
			movable.x = x_max
			movable.x_spd = -(movable.x_spd) -- hit bound and reverse
		end
	else -- Moving left
		if (movable.x + movable.x_spd > x_min) then
			movable.x = movable.x + movable.x_spd
		else 
			movable.x = x_min
			movable.x_spd = -(movable.x_spd) -- hit bound and reverse
		end
	end
	if (movable.y_spd > 0) then -- Moving down
		if (movable.y + movable.y_spd < y_max) then
			movable.y = movable.y + movable.y_spd
		else 
			movable.y = y_max
			movable.y_spd = -(movable.y_spd) -- hit bound and reverse
		end
	else -- Moving up
		if (movable.y + movable.y_spd > y_min) then
			movable.y = movable.y + movable.y_spd
		else 
			movable.y = y_min
			movable.y_spd = -(movable.y_spd) -- hit bound and reverse
		end
	end
end

--[[
ObjectFactory lets you associate an ID with a unique object, so you can access 
the same thing across function calls. Every time you call with the same uid, 
the same object returns. When first created it has the "done" entry set to 
false, so one-time setup can be done.

uid = a unique identifyer, a number or object to associate with the result
--]]
function ObjectFactory(uid)
	local thing = __objects__[uid]
	if (thing == nil) then
		__objects__[uid] = {}
		thing = __objects__[uid]
		thing.done = false
	end
	return thing
end

--[[
GetArray returns a table that knows its size, so you can populate or index 
with for loops over an integer set.

size = the number of elements to default to having
--]]
function GetArray(size)
	size = size or 0
	local arr = {}
	arr.size = size
	return arr
end

--[[
GetBubble returns a MovableObject that also has a radius.

x_pos = number for starting x, with 0 as the far left of the screen
y_pos = number for starting y, with 0 as the top of the screen
radi = number, radius of the bubble, as pixels
x_speed = number for x speed, where positive is moving right on the screen
y_speed = number for y speed, where positive is moving down on the screen
--]]
function GetBubble(x_pos, y_pos, radi, x_speed, y_speed)
	local bub = GetMovableObj(x_pos, y_pos, x_speed, y_speed)
	radi = radi or 5
	bub.radius = radi
	return bub
end

--[[
GetSmokeParticle returns a MovableObject that also has a radius and rotation 
value.

x_pos = number for starting x, with 0 as the far left of the screen
y_pos = number for starting y, with 0 as the top of the screen
radi = number, radius of the particle, as pixels
rotation = number, the rotation in degrees
x_speed = number for x speed, where positive is moving right on the screen
y_speed = number for y speed, where positive is moving down on the screen
--]]
function GetSmokeParticle(x_pos, y_pos, radi, rotation, x_speed, y_speed)
	local sm = GetMovableObj(x_pos, y_pos, x_speed, y_speed)
	radi = radi or 5
	rotation = rotation or 0
	sm.radius = radi
	sm.rot = rotation
	return sm
end

--[[----------------------------------------------------------------------------
Timer values for effect speeds
------------------------------------------------------------------------------]]

local sw_delay, sw_next = 0.05, CurTime() -- Swag
local bu_delay, bu_next = 0.1, CurTime() -- Bubbles
local sm_delay, sm_next = 0.01, CurTime() -- Smoke
local bf_delay, bf_next = 0.05, CurTime() -- Bonfire
local ra_delay, ra_next = 0.02, CurTime() -- Rain

--[[----------------------------------------------------------------------------
Text Effect Functions
------------------------------------------------------------------------------]]

--[[
DrawSwagText draws text with a bunch of dollar signs that bounce around on top.

intensity = number above 0, how many dollar signs to draw
text = the text to render
font = the font to use for the text
x = anchor x coordinate for the text
y = anchor y coordinate for the text
color = text color
color2 = dollar sign color
_obj_ = see ObjectFactory(uid)
--]]
function DrawSwagText(intensity, text, font, x, y, color, color2, _obj_)
    color2 = color2 or Color(14, 124, 0)
	intensity = intensity or 10

    draw.SimpleText(text, font, x, y, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	
	local tw, th = m_GetTextSize(text, font)
	
	if (_obj_.done == false) then
		_obj_.dollas = GetArray(intensity)
		for i=1,_obj_.dollas.size+1 do
			_obj_.dollas[i] = GetMovableObj(x + math.Rand(0, tw), 
				y + math.Rand(0, th), math.Rand(1, 5), math.Rand(1, 5))
		end
		_obj_.done = true
	end
	
	if (CurTime() >= sw_next) then -- To slow down the effects
		sw_next = CurTime() + sw_delay
		for i=1, _obj_.dollas.size+1 do
			MoveObj(_obj_.dollas[i], x, y, x + tw, y + th)
		end
	end
	for i=1, _obj_.dollas.size+1 do
		draw.SimpleText("$", "Trebuchet18", _obj_.dollas[i].x,
			_obj_.dollas[i].y, color2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

--[[
DrawBubbleText draws text with a bubbles floating up and popping in front.

intensity = number between 0 and 1. Higher means faster movement.
text = the text to render
font = the font to use for the text
x = anchor x coordinate for the text
y = anchor y coordinate for the text
color = text color
color2 = bubble color
_obj_ = see ObjectFactory(uid)
--]]
function DrawBubbleText(intensity, text, font, x, y, color, color2, _obj_)
    color2 = color2 or Color(66, 204, 255)
	intensity = intensity or 0.3

    draw.SimpleText(text, font, x, y, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	
	local tw, th = m_GetTextSize(text, font)
	
	if (_obj_.done == false) then
		_obj_.bubbles = GetArray(tw/15)
		for i=1,_obj_.bubbles.size+1 do
			local sz = math.Rand(0, BUBBLE_MAX_SZ)
			_obj_.bubbles[i] = GetBubble(x + math.Rand(0, tw), y + th, sz, 0, 
				-math.Rand(2,5))
		end
		_obj_.done = true
	end
	
	if (CurTime() >= bu_next) then -- To slow down the effects
		bu_next = CurTime() + bu_delay * (1-intensity)
		for i=1, _obj_.bubbles.size+1 do
			if (_obj_.bubbles[i].y + _obj_.bubbles[i].y_spd > y) then
				_obj_.bubbles[i].y = _obj_.bubbles[i].y + _obj_.bubbles[i].y_spd
				if (math.Rand(1,7) < 2) then 
					_obj_.bubbles[i].radius = _obj_.bubbles[i].radius + 1
				end
			else 
				_obj_.bubbles[i].y = y + th
				_obj_.bubbles[i].x = x + math.Rand(0, tw)
				_obj_.bubbles[i].radius = math.Rand(0, BUBBLE_MAX_SZ)
			end
		end
	end
	for i=1, _obj_.bubbles.size+1 do
		surface.DrawCircle(_obj_.bubbles[i].x, _obj_.bubbles[i].y, 
			_obj_.bubbles[i].radius, color2)
	end
end

--[[
DrawSmokeText draws text with smoke/fog swirling around it.

intensity = number between 0 and 1. Higher means more smoke.
text = the text to render
font = the font to use for the text
x = anchor x coordinate for the text
y = anchor y coordinate for the text
color = text color
color2 = smoke color
_obj_ = see ObjectFactory(uid)
--]]
function DrawSmokeText(intensity, text, font, x, y, color, color2, _obj_)
    color2 = color2 or Color(112, 112, 112, 100)
	intensity = intensity or 0.4
	
	local tw, th = m_GetTextSize(text, font)
	
	if (_obj_.done == false) then
		_obj_.smokes = GetArray(tw*intensity)
		for i=1,_obj_.smokes.size+1 do
			local sz = th / 2
			_obj_.smokes[i] = GetSmokeParticle(x + math.Rand(0, tw), 
				y + math.Rand(0, th), sz, math.Rand(0, 90), 
				math.Rand(2,7), math.Rand(0,2))
		end
		_obj_.done = true
	end
	
	if (CurTime() >= sm_next) then -- To slow down the effects
		sm_next = CurTime() + sm_delay
		for i=1, _obj_.smokes.size+1 do
			MoveObj(_obj_.smokes[i], x, y, x + tw, y + th)
			_obj_.smokes[i].rot = math.Rand(0, 90)
		end
	end
	local z_ind = math.random(_obj_.smokes.size+1)
	
	for i=1, z_ind do
		draw.NoTexture()
		surface.SetDrawColor( color2 )
		surface.DrawTexturedRectRotated(_obj_.smokes[i].x, _obj_.smokes[i].y, 
			_obj_.smokes[i].radius, _obj_.smokes[i].radius, _obj_.smokes[i].rot) 
	end
	
	draw.SimpleText(text, font, x, y, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	
	for i=z_ind, _obj_.smokes.size+1 do
		draw.NoTexture()
		surface.SetDrawColor( color2 )
		surface.DrawTexturedRectRotated(_obj_.smokes[i].x, _obj_.smokes[i].y, 
			_obj_.smokes[i].radius, _obj_.smokes[i].radius, _obj_.smokes[i].rot) 
	end
end

--[[
DrawRainText draws text with clouds and rain over it.

text = the text to render
font = the font to use for the text
x = anchor x coordinate for the text
y = anchor y coordinate for the text
color = text color
_obj_ = see ObjectFactory(uid)
--]]
function DrawRainText(text, font, x, y, color, _obj_)
	
	local tw, th = m_GetTextSize(text, font)
	
	if (_obj_.done == false) then
		_obj_.clouds = GetArray(tw/2)
		_obj_.drops = GetArray(tw/5)
		for i=1,_obj_.clouds.size+1 do
			local sz = th / 3
			_obj_.clouds[i] = GetSmokeParticle(x + math.random(tw), 
				y + math.random(th/3), sz, math.Rand(0, 90), math.Rand(1,3), 0)
		end
		for i=1,_obj_.drops.size+1 do
			local sz = 3
			_obj_.drops[i] = GetSmokeParticle(x + math.random(tw), 
				y + math.random(th/3), sz, 45, 0, 3)
		end
		_obj_.done = true
	end
	
	if (CurTime() >= ra_next) then -- To slow down the effects
		ra_next = CurTime() + ra_delay
		for i=1, _obj_.clouds.size+1 do
			MoveObj(_obj_.clouds[i], x, y, x + tw, y + th)
			_obj_.clouds[i].rot = math.Rand(0, 90)
		end
		for i=1, _obj_.drops.size+1 do
			if (_obj_.drops[i].y + _obj_.drops[i].y_spd < y + th) then
				_obj_.drops[i].y = _obj_.drops[i].y + _obj_.drops[i].y_spd
			else 
				_obj_.drops[i].y = y + math.random(th/3)
				_obj_.drops[i].x = x + math.random(tw)
			end
		end
	end
	
	for i=1, _obj_.drops.size+1 do
		draw.NoTexture()
		surface.SetDrawColor( Color(38, 121, 255, 150) )
		surface.DrawTexturedRectRotated(_obj_.drops[i].x, _obj_.drops[i].y,
			_obj_.drops[i].radius, _obj_.drops[i].radius, _obj_.drops[i].rot) 
	end
	
	for i=1, _obj_.clouds.size+1 do
		draw.NoTexture()
		surface.SetDrawColor( Color(112, 112, 112, 90) )
		surface.DrawTexturedRectRotated(_obj_.clouds[i].x, _obj_.clouds[i].y, 
			_obj_.clouds[i].radius, _obj_.clouds[i].radius, _obj_.clouds[i].rot) 
	end
	
	draw.SimpleText(text, font, x, y, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

--[[
DrawRainText draws text with particle-based realistic fire over it.

intensity = number between 0 and 1 (0.5 is half of the text height)
text = the text to render
font = the font to use for the text
x = anchor x coordinate for the text
y = anchor y coordinate for the text
color = text color
_obj_ = see ObjectFactory(uid)
--]]
function DrawBonfireText(intensity, text, font, x, y, color, _obj_)
	intensity = intensity or 0.84

    
	
	local tw, th = m_GetTextSize(text, font)
	
	if (_obj_.done == false) then
		_obj_.fire = GetArray(tw)
		_obj_.max_sz = (th*intensity)/3
		_obj_.slope = _obj_.max_sz / (th*intensity)
		for i=1,_obj_.fire.size+1 do
			_obj_.fire[i] = GetSmokeParticle(x + math.random(tw), y + th, 
				_obj_.max_sz, math.Rand(0, 90), 0, -math.Rand(1,5))
		end
		_obj_.done = true
	end
	
	if (CurTime() >= bf_next) then -- To slow down the effects
		bf_next = CurTime() + bf_delay

		for i=1, _obj_.fire.size+1 do
			_obj_.fire[i].rot = math.Rand(0, 90)
			if (_obj_.fire[i].y + _obj_.fire[i].y_spd > (
				y + th * (1 - intensity))) then
				_obj_.fire[i].y = _obj_.fire[i].y + _obj_.fire[i].y_spd
				_obj_.fire[i].radius = _obj_.slope * (_obj_.fire[i].y - y)
			else 
				_obj_.fire[i].y = y + th
				_obj_.fire[i].x = x + math.random(tw)
				_obj_.fire[i].radius = _obj_.max_sz
			end
		end
	end
	for i=1, _obj_.fire.size+1 do
		draw.NoTexture()
		surface.SetDrawColor(Color(255, (-200 / (th*intensity)) * (_obj_.fire[i].y - y) + 200/intensity + 55, 15, 50) )
		surface.DrawTexturedRectRotated(_obj_.fire[i].x, _obj_.fire[i].y, 
			_obj_.fire[i].radius, _obj_.fire[i].radius, _obj_.fire[i].rot) 
	end
	draw.SimpleText(text, font, x, y, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

--[[----------------------------------------------------------------------------
Example Command to see Text Effects -- You should exclude this if you're not 
using it.
------------------------------------------------------------------------------]]

function m_DrawEffectExamples()
    if (not M_SHOW_EFFECT_EXAMPLES) then return end

    draw.RoundedBox(0, 50, 50, 300, 350, Color(0, 0, 0, 200))

    local font = "DermaLarge"
    local x = 100
    local y = 100

    DrawSwagText(10, "SWAG TEXT", font, x, y, Color(255, 0, 0), Color(14, 124, 0), ObjectFactory(1))
	y = y + 50
    DrawBubbleText(0.3, "BUBBLE TEXT", font, x, y, Color(255, 0, 0), Color(66, 204, 255), ObjectFactory(2))
	y = y + 50
	DrawSmokeText(0.4, "SMOKE TEXT", font, x, y, Color(255, 0, 0), Color(112, 30, 99, 100), ObjectFactory(3))
	y = y + 50
	DrawRainText("RAIN TEXT", font, x, y, Color(255, 0, 0), ObjectFactory(4))
	y = y + 50
	DrawBonfireText(0.7, "BONFIRE TEXT", font, x, y, Color(255, 0, 0), ObjectFactory(5))
	
end
hook.Add("HUDPaint", "m_TextEffectsExample", m_DrawEffectExamples)
concommand.Add("m_textexamples", function() M_SHOW_EFFECT_EXAMPLES = not M_SHOW_EFFECT_EXAMPLES end)
