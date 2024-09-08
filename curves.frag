#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
float frequency = 4.0;
float sharpness = 0.2;
float dist1 = 0.5;
float dist2 = 0.3;
float off = 0.0;
float mod(float n){
    if(n>0.0)
    {return n;
    }
    return -n;
}


void main(){
    vec2 position=gl_FragCoord.xy / u_resolution;
    gl_FragColor=vec4(0.0);
    vec3 color=vec3(1.0);
   
    if((position.x<(sharpness*mod(sin((position.y+off)*frequency*3.141)*(sin((position.y+off)*4.9*3.141)))+(position.y+off))*dist1)){
       
     gl_FragColor=vec4(color,1.0);
     }
     if((1.0-position.x<(sharpness*mod(sin((position.y+off)*frequency*3.141)*(sin((position.y+off)*4.9*3.141)))+(1.5-position.y-off)*dist2))){
       
     gl_FragColor=vec4(color,1.0);
     }
     
}
