# Takneek24_ShaderCraft
Polygon - exact (https://www.shadertoy.com/view/wdBXRW)
float
sdPolygon ( in vec2[N] v,
in vec2 p )
float d = dot (p-v[0], p-v[0]);
float s =1.0：
Hor（int i=0，ゴ=N-1：
i<N：ゴニュ、ユ++ ）
vec2 e = vIj] - v[i];
vec2 w =
p - v[i];
vec2 b = w - e*clamp(
dot (w, e) /dot (e,e), 0.0, 1.0 );
d = min ( d, dot(b,b) );
bvec3 c = bvec3(p.y>=v[i]-y,p.y<v[j] -y,e.x*w.y>e.y*w.x);
if( all(c) || all(not(c)) ) s*=-1.0;
}
return
s*sqrt(d);
｝




Isosceles Triangle - exact (https://www.shadertoy.com/view/MIdcD7)
float sTriangleIsosceles ( in vec2 p, in vec2 q )
P.x
abs (p.x);
vec2
P - q*clamp( dot(p,9)/dot(9,9), 0.0, 1.0 );
vec2
b
p - g*vec2 ( clamp ( p.x/q.x, 0.0, 1.0 ), 1.0 );
float
=-sign( q-y);
vec2
d = min( vec2( dot (a,a), s*(p.x*q•y-p•y*q.x) ),
vec2 (dot (b,b), s*(p•y-q•y) ));
return -sqrt (d.x) *sign (d.y);
}




https://www.shadertoy.com/view/4s33zf





#version 330 core

out vec4 FragColor;

// Uniforms for controlling the snowfall effect
uniform float time; // Current time for animation
uniform vec2 resolution; // Screen resolution

// Function to generate random numbers based on coordinates
float random(vec2 seed) {
    return fract(sin(dot(seed, vec2(12.9898, 78.233))) * 43758.5453);
}

// Main fragment shader function
void main()
{
    // Calculate the normalized coordinates
    vec2 uv = gl_FragCoord.xy / resolution.xy;

    // Snowflake properties
    float snowflakeCount = 100.0; // Number of snowflakes
    float snowflakeSize = 0.02; // Size of the snowflakes
    float speed = 0.1; // Speed of snowfall

    // Initialize color and transparency
    vec3 snowColor = vec3(1.0, 1.0, 1.0); // White color for snowflakes
    float transparency = 0.5; // Base transparency

    // Generate random position and transparency for each snowflake
    for (float i = 0.0; i < snowflakeCount; i++) {
        vec2 snowflakePos = vec2(random(vec2(i, time)), random(vec2(i + 1.0, time)));
        snowflakePos.y += mod(time * speed + i, 1.0); // Falling animation

        // Check if the current fragment is within a snowflake
        float dist = distance(uv, snowflakePos);
        float alpha = max(0.0, snowflakeSize - dist) * (transparency * random(vec2(i, time)));

        // Set the fragment color based on snowflake position and transparency
        FragColor = vec4(snowColor, alpha);
    }
}

