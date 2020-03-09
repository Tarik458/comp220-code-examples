#version 330 core

struct DirectionalLight
{
	vec4 diffuseColour;
	vec4 specularColour;
	vec3 direction;
}; 

struct PointLight
{
	vec4 diffuseColour;
	vec4 specularColour;
	vec3 position;
};

struct Material
{
    vec4 ambientColour;
    vec4 diffuseColour;
    vec4 specularColour;
    float specularPower;
};


out vec4 colour;

in vec4 vertexColourOut;
in vec2 vertexTextureCoordOut;
in vec3 vertexNormalsOut;
in vec3 viewDirection;
in vec3 worldVertexPosition;

//Ambient Light Colour
uniform vec4 ambientLightColour;

uniform DirectionalLight directionalLight;

uniform PointLight pointLight;

uniform Material material;

vec4 CalculateLightColour(vec4 diffuseLightColour,vec4 specularLightColour,vec3 lightDirection)
{
    //Lambert Diffuse
    float nDotl=clamp(dot(vertexNormalsOut,normalize(lightDirection)),0.0,1.0);

    //Blinn Phong Specular
    vec3 halfWay=normalize(lightDirection+viewDirection);
    float nDoth=pow(clamp(dot(vertexNormalsOut,halfWay),0.0,1.0),material.specularPower);

    return (diffuseLightColour*nDotl*material.diffuseColour)
                +(specularLightColour*nDoth*material.specularColour);
}

vec4 CalculateDirectionLightColour()
{
	return CalculateLightColour(directionalLight.diffuseColour,
								directionalLight.specularColour,
								directionalLight.direction);
}

vec4 CalculuatePointLight()
{
    vec3 lightDirection=worldVertexPosition-pointLight.position;
	float lightDistance=length(lightDirection);
    lightDirection=normalize(lightDirection);
    
    vec4 colour=CalculateLightColour(pointLight.diffuseColour,pointLight.specularColour,lightDirection);

    float attenuation=1.0/(1.0+0.1*lightDistance+0.01*lightDistance*lightDistance);
    
    return colour*attenuation;
}

void main()
{
    vec4 finalColour=(ambientLightColour*material.ambientColour)+CalculateDirectionLightColour()+CalculuatePointLight();
    colour=finalColour;
}