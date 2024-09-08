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
