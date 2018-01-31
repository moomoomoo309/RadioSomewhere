
local noise = {
    description = "Noise shader",
}

function noise:new()
    self.canvas = love.graphics.newCanvas()
    self.shader = love.graphics.newShader [[
extern vec3 iResolution;
extern int iTime;

//Credit: http://stackoverflow.com/questions/4200224/random-noise-functions-for-glsl
number rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	//Fragment position, only used as random seed
	vec2 uv = fragCoord.xy / iResolution.xy;

	//Flicker frequency
	number flicker = 10.0;

	//Play with power to change noise frequency
	number freq = sin(pow(mod(iTime, flicker)+flicker, 1.9));

	//Play with this to change raster dot size (x axis only, y is calculated with aspect ratio)
	number pieces = number(1000);

	//Calculations to maintain square pixels
	number ratio_x = 1.0 / pieces;
	number ratio_y = ratio_x * iResolution.x / iResolution.y;
	number half_way_x = abs(freq * ratio_x);
	number half_way_y = abs(freq * ratio_y);

	//Checkerboard generation
	number x_pos = mod(uv.x, ratio_x);
	number y_pos = mod(uv.y, ratio_y);
	if(x_pos < half_way_x && y_pos < half_way_y)
		fragColor = vec4(1.0,1.0,1.0,1.0);
	else if(x_pos < half_way_x && y_pos > half_way_y)
		fragColor -= vec4(0.0,0.0,0.0,0.0);
	else if(x_pos > half_way_x && y_pos < half_way_y)
		fragColor -= vec4(0.0,0.0,0.0,0.0);
	else
		fragColor = vec4(1.0,1.0,1.0,1.0);

	//Comment this out to see how raster dots are simulated (noise overlay)
	fragColor *= vec4(rand(uv+mod(iTime, freq)), rand(uv+mod(iTime+.1, freq)), rand(uv), 1.0);

	//Use this for greyscale noise, comment out the line above (noise overlay)
	//fragColor *= vec4(rand(uv+mod(iTime, freq)), rand(uv+mod(iTime, freq)), rand(uv+mod(iTime, freq)), 1.0);
}


vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords){
    vec4 thisPx = Texel(texture, texture_coords);
    if (thisPx[3] < 0.15) {
        return thisPx;
    }
    vec2 fragCoord = texture_coords * iResolution.xy;
    mainImage( color, fragCoord );
    color[3] = 0.25;
    return color;
}
    ]]
    self.shader:send("iResolution", {1280,720, 0})
    self.shader:send("iTime", love.timer.getTime())
    return self.shader
end

function noise:set(key, value)
    if key == "iTime" then
        assert(type(value) == "number", ("Number expected, got %s."):format(type(value)))
        self.shader:send("iTime", value)
    end
end

function noise:draw(func, ...)
    local s = love.graphics.getShader()

    -- draw scene to canvas
    self:_render_to_canvas(self.canvas, func, ...)

    -- apply shader to canvas
    love.graphics.setShader(self.shader)
    local b = love.graphics.getBlendMode()
    love.graphics.setBlendMode('alpha', 'alphamultiply')
    love.graphics.draw(self.canvas, 0, 0)
    love.graphics.setBlendMode(b)

    -- reset shader and canvas
    love.graphics.setShader(s)
end

return noise