#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
float frequency = 4.0;
float sharpness1 = 0.19;
float sharpness2 = 0.1;
float dist1 = 0.5;
float dist2 = 0.5;
float off1 = 0.3;
float off2 = 0.2;
float c = 0.02;
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
   
    if((position.x<(sharpness1*mod(sin((position.y+off1)*frequency*3.141)*(sin((position.y+off1)*4.9*3.141)))+(position.y+off1))*dist1)){
       
     gl_FragColor=vec4(color,0.5);
     }
     if((1.0-(position.x+c-0.02)<((sharpness2)*mod(sin((position.y+off2)*frequency*3.141)*(sin((position.y+off2)*4.9*3.141)))+(position.y+off2)*dist2))){
       
     gl_FragColor=vec4(color,0.5);
     }
     if((position.x+c<(sharpness1*mod(sin((position.y+off1)*frequency*3.141)*(sin((position.y+off1)*4.9*3.141)))+(position.y+off1))*dist1)){
       
     gl_FragColor=vec4(color,1.0);
     }
     if((1.0-position.x+c<((sharpness2)*mod(sin((position.y+off2)*frequency*3.141)*(sin((position.y+off2)*4.9*3.141)))+(position.y+off2)*dist2))){
       
     gl_FragColor=vec4(color,1.0);
     }
}
