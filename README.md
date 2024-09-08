# Takneek24_ShaderCraft

## Our final files are final.glsl and final_animated.glsl












float smoothEdge(float edge, float x) {
    return smoothstep(edge - 0.01, edge + 0.01, x);
}

// Function to create tree shapes
float tree(vec2 p) {
    p.y *= 1.5; // Stretch trees vertically
    float treeShape = smoothEdge(0.3, abs(p.x)) - smoothEdge(0.35, abs(p.x)) * smoothEdge(0.7, p.y);
    return treeShape;
}

// Function to create snow path
float snowPath(vec2 p) {
    float path = smoothEdge(0.2 + 0.1*sin(p.y * 10.0 + u_time), abs(p.x)); // Dynamic wave
    return path;
}

// Function to create mountains in the background
float mountains(vec2 p) {
    float mtnShape = smoothEdge(0.7, p.y + sin(p.x * 3.0) * 0.3);
    return mtnShape;
}

// Function to create snow (white areas)
float snow(vec2 p) {
    return smoothEdge(0.0, p.y);
}

// Dynamic snowflake generation
float snowflakes(vec2 p) {
    float flake = sin(p.x * 10.0 + u_time * 2.0) * cos(p.y * 20.0 + u_time * 3.0);
    return smoothEdge(0.5, flake);
}

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    uv = uv * 2.0 - 1.0;
    uv.x *= u_resolution.x / u_resolution.y;
    
    // Colors based on the reference image
    vec3 bgColor = vec3(0.9, 0.95, 1.0);  // Light blue sky
    vec3 snowColor = vec3(0.95, 0.95, 1.0);  // Snow
    vec3 pathColor = vec3(0.3, 0.4, 0.5);  // Path (dark blue)
    vec3 treeColor = vec3(0.1, 0.2, 0.3);  // Dark trees
    
    vec3 color = bgColor;  // Background color
    
    // Mountain layer in the background
    if (mountains(uv + vec2(0.0, 0.5)) > 0.5) {
        color = mix(color, vec3(0.6, 0.7, 0.8), 0.6);
    }
    
    // Snow path in the middle
    if (snowPath(uv + vec2(0.0, 0.2)) > 0.5) {
        color = mix(color, pathColor, 0.8);
    }
    
    // Trees on the side
    if (tree(uv - vec2(-0.7, 0.0)) > 0.5 || tree(uv - vec2(0.7, 0.0)) > 0.5) {
        color = mix(color, treeColor, 0.9);
    }
    
    // Snow covering everything
    if (snow(uv + vec2(0.0, -0.2)) > 0.2) {
        color = mix(color, snowColor, 0.8);
    }
    
    // Dynamic snowflakes falling
    if (snowflakes(uv) > 0.8) {
        color = vec3(1.0);
    }
    
    gl_FragColor = vec4(color, 1.0);
}
