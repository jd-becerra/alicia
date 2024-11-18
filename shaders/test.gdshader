shader_type canvas_item;

#define iTime TIME  // Built-in uniform for time-based effects (if needed)

// Resolution definitions
#define Res0 vec2(float(textureSize(iChannel0, 0).x), float(textureSize(iChannel0, 0).y))
#define Res1 vec2(float(textureSize(iChannel1, 0).x), float(textureSize(iChannel1, 0).y))
#define iResolution Res0  // Use texture 0 resolution as the main canvas resolution

#define Res iResolution.xy  // Shorthand for resolution (x, y)

// Uniform variables
uniform vec2 disp = vec2(200.0, 100.);  // Offset for position calculations
uniform float zoom : hint_range(0.05, 1.0, 0.05) = 0.5;  // Zoom factor
uniform sampler2D iChannel0:hint_screen_texture, filter_linear_mipmap;  // Main texture
uniform sampler2D iChannel1;  // Secondary texture used for random noise

vec4 getRand(vec2 pos)
{
    return textureLod(iChannel1,pos/Res1/iResolution.y*1080., 0.0);
}

vec4 getCol(vec2 pos) {
    // Map position `pos` to UV coordinates (normalized 0-1 range with aspect ratio adjustment)
    vec2 uv = ((pos - Res.xy * 0.5) / Res.y * Res0.y) / Res0.xy + 0.5;

    // Sample main texture at UV coordinates
    vec4 c1 = texture(iChannel0, uv);

    // Edge blending (smoothstep creates a fade effect near edges)
    vec4 e = smoothstep(vec4(-0.001), vec4(-0.0), vec4(uv, vec2(1) - uv));
    c1 = mix(vec4(1, 1, 1, 0), c1, e.x * e.y * e.z * e.w);

    // Calculate light intensity (dot product with a specific vector for shading)
    float d = clamp(dot(c1.xyz, vec3(1.0, -0.5, -0.5)), 0.0, 1.0);

    // Blend with a flat gray color to simulate hand-drawn shading
    vec4 c2 = vec4(0.5);
    return min(mix(c1, c2, .5 * d), 1.);
}

vec4 getColHT(vec2 pos)
{
 	return getCol(pos);
}

float getVal(vec2 pos)
{
    vec4 c=getCol(pos);
	// Convert to grayscale intensity
 	return pow(dot(c.xyz,vec3(.333)),1.)*1.;
}

vec2 getGrad(vec2 pos, float eps)
{
   	vec2 d=vec2(eps,0);
    // Central difference for gradient approximation
	return vec2(
        getVal(pos+d.xy)-getVal(pos-d.xy),
        getVal(pos+d.yx)-getVal(pos-d.yx)
    )/eps/2.;
}

#define AngleNum 4  // Number of drawing angles (e.g., simulates cross-hatching directions)
#define SampNum 1  // Number of samples per angle
#define PI2 6.28318530717959

void fragment()
{
     vec2 pos = (FRAGCOORD.xy - disp) * zoom; //+4.0*sin(iTime*1.*vec2(1,1.7))*iResolution.y/400. - disp) * zoom;
    vec3 col = vec3(0);
    vec3 col2 = vec3(0);
    float sum=0.;
    for(int i=0;i<AngleNum;i++)
    {
        float ang=PI2/float(AngleNum)*(float(i)+.8);
        vec2 v=vec2(cos(ang),sin(ang));
        for(int j=0;j<SampNum;j++)
        {
            vec2 dpos  = v.yx*vec2(1,-1)*float(j)*iResolution.y/400.;
            vec2 dpos2 = v.xy*float(j*j)/float(SampNum)*.7*iResolution.y/400.;
	        vec2 g;
            float fact;
            float fact2;

            for(float s=-1.;s<=1.;s+=2.)
            {
                vec2 pos2=pos+s*dpos+dpos2;
                vec2 pos3=pos+(s*dpos+dpos2).yx*vec2(1,-1);
            	g=getGrad(pos2,.4);
            	fact=dot(g,v)-.5*abs(dot(g,v.yx*vec2(1,-1)))/**(1.-getVal(pos2))*/;
            	fact2=dot(normalize(g+vec2(.0001)),v.yx*vec2(1,-1));
                
				
				fact = clamp(fact, 0.0, 0.05); // Reduced maximum value from 0.05 to 0.02
                fact2 = abs(fact2) * 0.5; // Reduced by scaling to 50%
                
                fact*=1.-float(j)/float(SampNum);
            	col += fact;
            	col2 += fact2*getColHT(pos3).xyz;
            	sum+=fact2;
            }
        }
    }
    col/=float(SampNum*AngleNum)*.75/sqrt(iResolution.y);
    col2/=sum;
    col.x*=(.6+.8*getRand(pos*.7).x);
    col.x=1.-col.x;
    col.x*=col.x*col.x;

    vec2 s=sin(pos.xy*.1/sqrt(iResolution.y/400.));
    vec3 karo=vec3(1.4);
    
	// This line adds the squares that look like notebook lines
	// karo-=.5*vec3(.05,.05,.05)*dot(exp(-s*s*80.),vec2(1));
    
	float r=length(pos-iResolution.xy*.5)/iResolution.x;
    float vign=1.-r*r*r;
	COLOR = vec4(vec3(col.x*col2*karo*vign),1);
    //COLOR=getCol(FRAGCOORD.xy * 0.5);
}