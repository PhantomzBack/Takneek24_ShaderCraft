#ifdef GL_ES
precision mediump float;
#endif
vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec2 mod289(vec2 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 permute(vec3 x) {
  return mod289(((x*34.0)+1.0)*x);
}

float snoise(vec2 v)
  {
  const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                      0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                     -0.577350269189626,  // -1.0 + 2.0 * C.x
                      0.024390243902439); // 1.0 / 41.0
// First corner
  vec2 i  = floor(v + dot(v, C.yy) );
  vec2 x0 = v -   i + dot(i, C.xx);

// Other corners
  vec2 i1;
  //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
  //i1.y = 1.0 - i1.x;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  // x0 = x0 - 0.0 + 0.0 * C.xx ;
  // x1 = x0 - i1 + 1.0 * C.xx ;
  // x2 = x0 - 1.0 + 2.0 * C.xx ;
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;

// Permutations
  i = mod289(i); // Avoid truncation effects in permutation
  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
		+ i.x + vec3(0.0, i1.x, 1.0 ));

  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;

// Gradients: 41 points uniformly over a line, mapped onto a diamond.
// The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;

// Normalise gradients implicitly by scaling m
// Approximation of: m *= inversesqrt( a0*a0 + h*h );
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

// Compute final noise value at P
  vec3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}


float fBm(vec2 point, float H, float lacunarity, float frequency, float octaves)
{
	float value = 0.0;
	float rmd = 0.0;
	float pwHL = pow(lacunarity, -H);
	float pwr = pwHL; 

	for (int i=0; i<65535; i++)
	{
		value += snoise(point * frequency) * pwr;
		point *= lacunarity;
		pwr *= pwHL;
		if (i==int(octaves)-1) break;
	}

	rmd = octaves - floor(octaves);
	if (rmd != 0.0) value += rmd * snoise(point * frequency) * pwr;

	return value;
}

float rng( in vec2 pos )
{
    return fract(sin( pos.y + pos.x*78.233 )*43758.5453)*2.0 - 1.0;
}

float perlin( in float pos )
{
    // Get node values
    
    float a = rng( vec2(floor(pos), 1.0) );
    float b = rng( vec2(ceil( pos), 1.0) );
    
    float a_x = rng( vec2(floor(pos), 2.0) );
    float b_x = rng( vec2(ceil( pos), 2.0) );
    
    a += a_x*fract(pos);
    b += b_x*(fract(pos)-1.0);
    
    
    
    // Interpolate values
    
    return a + (b-a)*smoothstep(0.0,1.0,fract(pos));
}



// GLSL Perlin Noise Function

// Helper functions
float fade(float t) {
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

float lerp(float a, float b, float t) {
    return a + t * (b - a);
}

float cosine_interp(float a, float b, float t) {
    float t2 = (1.0 - cos(t * 3.1415927)) * 0.5;
    return a * (1.0 - t2) + b * t2;
}

// Hash function to generate pseudo-random values
float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

// Noise function
float noise(float x, int interpType, bool useFade) {
    float intX = floor(x);
    float fracX = x - intX;

    if (useFade) {
        fracX = fade(fracX);
    }

    float v1 = hash(intX);
    float v2 = hash(intX + 1.0);

    if (interpType == 1) { // Linear
        return lerp(v1, v2, fracX);
    } else if (interpType == 2) { // Cosine
        return cosine_interp(v1, v2, fracX);
    } else { // Cubic (not implemented in this example)
        return lerp(v1, v2, fracX); // Fallback to linear
    }
}

// Main function to get Perlin noise
float perlinNoise(float x, float frequency, float amplitude, int octaves, int interpType, bool useFade) {
    float total = 0.0;
    float maxAmplitude = 0.0;
    float freq = frequency;
    float amp = amplitude;

    for (int i = 0; i < 4; i++) {
        total += noise(x * freq, interpType, useFade) * amp;
        maxAmplitude += amp;
        freq *= 2.0;
        amp *= 0.5;
    }

    return amplitude * total / maxAmplitude;
}

#define N 3
float sdPolygon(vec2[N] v,vec2 p)
{
    float d = dot(p-v[0],p-v[0]);
    float s = 1.0;
    int j=N-1;
    vec2 e = v[2] - v[0];

    // for(int i=0; i<N;i++)
    // {
    //     vec2 e = v[j] - v[i];
    //     vec2 w =    p - v[i];
    //     vec2 b = w - e*clamp( dot(w,e)/dot(e,e), 0.0, 1.0 );
    //     d = min( d, dot(b,b) );
    //     bvec3 c = bvec3(p.y>=v[i].y,p.y<v[j].y,e.x*w.y>e.y*w.x);
    //     if( all(c) || all(not(c)) ) s*=-1.0;  
    //     j=i;
    // }
    return s*sqrt(d);
}

float sdTriangle(vec2 p, vec2 p0, vec2 p1, vec2 p2 )
{
    vec2 e0 = p1-p0, e1 = p2-p1, e2 = p0-p2;
    vec2 v0 = p -p0, v1 = p -p1, v2 = p -p2;
    vec2 pq0 = v0 - e0*clamp( dot(v0,e0)/dot(e0,e0), 0.0, 1.0 );
    vec2 pq1 = v1 - e1*clamp( dot(v1,e1)/dot(e1,e1), 0.0, 1.0 );
    vec2 pq2 = v2 - e2*clamp( dot(v2,e2)/dot(e2,e2), 0.0, 1.0 );
    float s = sign( e0.x*e2.y - e0.y*e2.x );
    vec2 d = min(min(vec2(dot(pq0,pq0), s*(v0.x*e0.y-v0.y*e0.x)),
                     vec2(dot(pq1,pq1), s*(v1.x*e1.y-v1.y*e1.x))),
                     vec2(dot(pq2,pq2), s*(v2.x*e2.y-v2.y*e2.x)));
    return -sqrt(d.x)*sign(d.y);
}

float isPointInTriangle(vec2 p, vec2 v0, vec2 v1, vec2 v2) {
    // Compute vectors
    vec2 v0v1 = v1 - v0;
    vec2 v0v2 = v2 - v0;
    vec2 v0p = p - v0;

    // Compute dot products
    float dot00 = dot(v0v2, v0v2);
    float dot01 = dot(v0v2, v0v1);
    float dot02 = dot(v0v2, v0p);
    float dot11 = dot(v0v1, v0v1);
    float dot12 = dot(v0v1, v0p);

    // Compute barycentric coordinates
    float invDenom = 1.0 / (dot00 * dot11 - dot01 * dot01);
    float u = (dot11 * dot02 - dot01 * dot12) * invDenom;
    float v = (dot00 * dot12 - dot01 * dot02) * invDenom;

    // Check if point is inside the triangle
    return (u >= 0.0 && v >= 0.0 && (u + v) <= 1.0) ? 0.0 : 1.0;
}
#define S(x,y,z) smoothstep(x,y,z)
#define B(x,y,z,b) S(x, x+b, z)*S(y+b, y, z)
float within(float a, float b, float t) {
	return (t-a) / (b-a); 
}


float skewbox(vec2 uv, vec3 top, vec3 bottom, float blur) {
	float y = within(top.z, bottom.z, uv.y);
    float left = mix(top.x, bottom.x, y);
    float right = mix(top.y, bottom.y, y);
    
    float horizontal = B(left, right, uv.x, blur);
    float vertical = B(bottom.z, top.z, uv.y, blur);
    return horizontal*vertical;
}

vec4 pine(vec2 uv, vec2 p, float s, float focus) {
	uv.x -= .5;
    float c = skewbox(uv, vec3(.0, .0, 1.), vec3(-.14, .14, .65), focus);
    c += skewbox(uv, vec3(-.10, .10, .65), vec3(-.18, .18, .43), focus);
    c += skewbox(uv, vec3(-.13, .13, .43), vec3(-.22, .22, .2), focus);
    c += skewbox(uv, vec3(-.04, .04, .2), vec3(-.04, .04, -.1), focus);
    
    vec4 col = vec4(1.,1.,1.,0.);
    col.a = c;
   
    float shadow = skewbox(uv.yx, vec3(.6, .65, .13), vec3(.65, .65, -.1), focus);
    shadow += skewbox(uv.yx, vec3(.43, .43, .13), vec3(.36, .43, -.2), focus);
    shadow += skewbox(uv.yx, vec3(.15, .2, .08), vec3(.17, .2, -.08), focus);
    
    col.rgb = mix(col.rgb, col.rgb*.8, shadow);
    
    return col;
}



uniform vec2 u_resolution;
uniform float u_time;

#define SKY_COLOR vec3(0.941,0.953,0.961)
#define SNOW vec3(0.961,0.98,1.)
#define LAYER_1 vec3()
#define WATER vec3(0.408,0.498,0.588)

bool isPointInRectangle(vec2 coord, vec2 startingCoord, vec2 widthHeight) {
    float left = startingCoord.x;
    float right = startingCoord.x + widthHeight.x;
    float bottom = startingCoord.y;
    float top = startingCoord.y + widthHeight.y;

    return (coord.x >= left && coord.x <= right && coord.y >= bottom && coord.y <= top);
}

float pine(vec2 coord, vec2 tree_coord, float base_width, float gap, float height){
  // float base_width = 0.2;
  // float gap = 0.1;
  // float height = 0.14;
  return 1.-isPointInTriangle(coord, tree_coord, vec2(tree_coord.x-base_width, tree_coord.y-height), vec2(tree_coord.x+base_width, tree_coord.y-height))
  *isPointInTriangle(vec2(coord.x, coord.y + gap), tree_coord, vec2(tree_coord.x-base_width, tree_coord.y-height), vec2(tree_coord.x+base_width, tree_coord.y-height))
  *isPointInTriangle(vec2(coord.x, coord.y + 2. * gap), tree_coord, vec2(tree_coord.x-base_width, tree_coord.y-height), vec2(tree_coord.x+base_width, tree_coord.y-height))
  *isPointInTriangle(vec2(coord.x, coord.y - gap/2.), tree_coord, vec2(tree_coord.x-base_width/2., tree_coord.y-height/2.), vec2(tree_coord.x+base_width/2., tree_coord.y-height/2.))
  // *isPointInTriangle(vec2(coord.x, coord.y - 0.07), tree_coord, vec2(tree_coord.x-base_width/2., tree_coord.y-0.04), vec2(tree_coord.x+base_width/2., tree_coord.y-0.04))

  ;

}


vec3 col_return(float x, float threshold){
  // vec3 col1 = vec3(0.165,0.208,0.251);
  vec3 col1 = vec3(0.408,0.49,0.557);
  vec3 col2 = vec3(0.361,0.424,0.475);
  return mix(col1, col2, 1.-smoothstep(x, threshold, threshold+0.05));

}
float mod(float n){
    if(n>0.0)
    {return n;
    }
    return -n;
}


vec4 func(vec2 position){
  float frequency = 4.0;
    float sharpness1 = 0.19;
    float sharpness2 = 0.1;
    float dist1 = 0.5;
    float dist2 = 0.5;
    float off1 = 0.3;
    float off2 = 0.2;
    float c = 0.02;

    vec3 color=vec3(1.0);

    vec4 FragColor;
   
    if((position.x<(sharpness1*mod(sin((position.y+off1)*frequency*3.141)*(sin((position.y+off1)*4.9*3.141)))+(position.y+off1))*dist1)){
        FragColor=vec4(color,0.5);
     }
     if((1.0-(position.x+c-0.02)<((sharpness2)*mod(sin((position.y+off2)*frequency*3.141)*(sin((position.y+off2)*4.9*3.141)))+(position.y+off2)*dist2))){
       
      FragColor=vec4(color,0.5);
     }
     if((position.x+c<(sharpness1*mod(sin((position.y+off1)*frequency*3.141)*(sin((position.y+off1)*4.9*3.141)))+(position.y+off1))*dist1)){
       
      FragColor=vec4(color,1.0);
     }
     if((1.0-position.x+c<((sharpness2)*mod(sin((position.y+off2)*frequency*3.141)*(sin((position.y+off2)*4.9*3.141)))+(position.y+off2)*dist2))){  
      FragColor=vec4(color,1.0);
     }
     return FragColor;

}


void main(){
    vec2 coord = gl_FragCoord.xy / u_resolution;
    vec3 sky_color = SKY_COLOR;
    vec3 layer_1 = vec3(0.824,0.867,0.898);
    vec3 layer_2 = vec3(0.694,0.753,0.796);
    vec3 snow_color = SNOW;
    vec3 water_color = WATER;
    // vec3 water_color = mix(WATER, vec3(0.), sin(u_time)*sin(u_time));

    float sky_height = 0.6;
    vec4 col = vec4(sky_color,1.0);
    // vec4 col = vec4(mix(sky_color, vec3(0.0, 0.0, 0.0), sin(u_time)),1.0);
    float perl = perlin(coord.x*10.0 + u_time*0.);
    float scaling_fac_x = 0.2;
    float perl_2 = perlinNoise(coord.x*scaling_fac_x + 0.01, 20., 5., 1, 0, true);
    float offset = 0.5; //u_time * 0.1;
    float perl_3 = perlinNoise(coord.x*scaling_fac_x + offset, 20., 5., 1, 0, true);
    
    float fac_layer_1 = perl_2 * 0.1+0.665;
    float fac_layer_2 = min(perl_3 * 0.15+0.3, fac_layer_1 + 0.05 );

    




    // float perl_4 = 

    


    col = mix(col, vec4(layer_1,1.0), step(coord.y, fac_layer_1));
    col = mix(col, vec4(layer_2,1.0), step(coord.y, fac_layer_2));

    

    // col = mix(col, vec4(snow_color,1.0), sdTriangle(coord, vec2(0.,0.), vec2(1.,0), vec2(1.,1.)));


    // col = mix(col, vec4(layer_1,1.0), step(coord.y, sky_height));

    // col = mix
    vec4 new_col = func(vec2(coord.x, coord.y+0.04));

    vec4 water_col = mix(new_col, vec4(water_color,1.0), 1.-new_col.a);

    col = mix(col, water_col, step(coord.y, sky_height));

    float inTriangle = isPointInTriangle(coord, vec2(0.5,0.5), vec2(0.4,0.6), vec2(0.6,0.6));
    float scale = 0.5;
    float pine1 = pine(coord, vec2(0.47, 0.7), 0.2 * scale, 0.1 * scale, 0.14 * scale);
    vec4 tree_col = vec4(col_return(coord.x, 0.47), pine1);
    col = mix(col, tree_col, pine1);
    // col = vec4(vec3(inTriangle), 1.0);

    scale = 0.6;
    pine1 = pine(coord, vec2(0.3, 0.68), 0.2 * scale, 0.1 * scale, 0.14 * scale);
    tree_col = vec4(col_return(coord.x, 0.3), pine1);
    col = mix(col, tree_col, pine1);

    scale = 0.8;
    float pine2 = pine(coord, vec2(0.2, 0.5), 0.2 * scale, 0.1 * scale, 0.14 * scale);
    vec4 tree_col_2 = vec4(col_return(coord.x, 0.2), pine2);
    col = mix(col, tree_col_2, pine2);

    
    scale = 0.3;
    pine1 = pine(coord, vec2(0.8, 0.68), 0.2 * scale, 0.1 * scale, 0.14 * scale);
    tree_col = vec4(col_return(coord.x, 0.8), pine1);
    col = mix(col, tree_col, pine1);
    
    scale = 0.6;
    pine1 = pine(coord, vec2(0.7, 0.6), 0.2 * scale, 0.1 * scale, 0.14 * scale);
    tree_col = vec4(col_return(coord.x, 0.7), pine1);
    col = mix(col, tree_col, pine1);
    
    scale = 0.9;
    pine1 = pine(coord, vec2(0.9, 0.4), 0.2 * scale, 0.1 * scale, 0.14 * scale);
    tree_col = vec4(col_return(coord.x, 0.9), pine1);
    col = mix(col, tree_col, pine1);

    




    
    



    

    // vec4 pineCol = pine(vec2(coord.x, coord.y), vec2(0., 0.1), 1., 0.);
    // col = vec4(pineCol.rgb, 1.0);
    // col = mix(col, pineCol, pineCol.a);

    // col = mix(col, vec4(snow_color,1.0), sdTriangle(coord, vec2(0.,0.), vec2(1.,0), vec2(1.,1.)));

    // col = vec4(sdTriangle(coord, vec2(0.5,0.5), vec2(0.4,0.6), vec2(0.6.,0.6)));

    





    // col = mix()






    // float n = smoothstep(0.2, 0.8, fBm(coord*0.05+u_time*0.01, 0.6, 1.9, 10.5, 14.));


    // vec2 coord = gl_FragCoord.xy / u_resolution;
    // float n = smoothstep(0.2, 0.8, fBm(coord*0.05+u_time*0.01, 0.6, 1.9, 10.5, 14.));
    // vec4 color_stop_1 = vec4(0.0, 0.702, 1.0, 1.0);
    // vec4 color_stop_2 = vec4(0.0118, 0.4745, 1.0, 1.0);
    // vec4 color_bg = mix(color_stop_1, color_stop_2, (coord.x+coord.y));
    // vec4 color_cloud = vec4(1.0, 1.0, 1.0, 1.0);
    // vec4 col = mix(color_cloud, color_bg, 1.-n);

    vec2 uv = gl_FragCoord.xy / u_resolution.xy;

    float elevation = perlin( uv.x*10.0 + u_time*1.0 );

    // float elevation = perlin( uv.x + 100.0 ) + perlin( uv.x*2.0 + 200.0 )/2.0
    //     + perlin( uv.x*4.0 + 300.0 )/4.0
    //     + perlin( uv.x*8.0 + 400.0 )/8.0
    //     + perlin( uv.x*16.0 + 500.0 )/16.0
    //     + perlin( uv.x*32.0 + 600.0 )/32.0
    //     + perlin( uv.x*64.0 + 600.0 )/64.0
    //     + chunk_size/2.0;
    
    
    
    // Display noise
    
    float pixel = step( uv.y, elevation );
    // fragColor = vec4( pixel, pixel, pixel, 1.0 );



    // vec4 col = vec4(1.0);
    // col = vec4( pixel, pixel, pixel, 1.0 );
    // col = water_col;
    col = mix(col, vec4(0.0, 0.0, 0.0, 1.0), sin(u_time)*sin(u_time));
    gl_FragColor = col;
    

}