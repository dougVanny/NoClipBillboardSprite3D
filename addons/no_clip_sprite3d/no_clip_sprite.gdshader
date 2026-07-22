shader_type spatial;

#define Z_FIGHT_GROUND_AVOIDANCE 0.0001

render_mode shadows_disabled;
render_mode unshaded;
render_mode depth_prepass_alpha;

uniform sampler2D sprite:source_color,filter_nearest;

uniform vec2 pivot = vec2(0.0,0.0);
uniform float zFightAvoidance = 0.01;

uniform int vertexModeFacing : hint_enum("Face Camera Direction (Billboard)", "Face Camera Position") = 0;
uniform int vertexModeUp : hint_enum("Camera Y", "Local Y") = 0;

varying vec3 spriteDirection;
varying vec3 nodeUpWorld;
varying vec3 nodeForwardWorld;

void vertex() {
	if(vertexModeFacing == 0)
	{
		spriteDirection = CAMERA_DIRECTION_WORLD;
	}
	else
	{
		spriteDirection =  CAMERA_POSITION_WORLD - NODE_POSITION_WORLD;
	}

	vec3 local_x = MODEL_MATRIX[0].xyz;
	vec3 local_z = MODEL_MATRIX[2].xyz;

	vec3 local_y;

	if(vertexModeUp == 0)
	{
		local_y = normalize(MODEL_MATRIX[1].xyz - CAMERA_DIRECTION_WORLD * dot(MODEL_MATRIX[1].xyz,CAMERA_DIRECTION_WORLD));
		local_y *= length(MODEL_MATRIX[1].xyz);
	}
	else
	{
		local_y = MODEL_MATRIX[1].xyz;
	}

	vec3 direction_x = normalize(cross(local_y, spriteDirection));
	vec3 direction_z = normalize(cross(direction_x, local_y));
	spriteDirection = direction_z;

	vec4 translation = vec4(pivot.x * direction_x + pivot.y * local_y,0.0);

	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(vec4(direction_x * length(local_x), 0.0), vec4(local_y, 0.0), vec4(direction_z * length(local_z), 0.0), MODEL_MATRIX[3] - translation);

	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);

	nodeUpWorld = normalize(MODEL_MATRIX[1].xyz);
	nodeForwardWorld = normalize(MODEL_MATRIX[2].xyz);
}

vec3 CastRayOntoPlane(vec3 rayOrigin, vec3 rayTarget, vec3 planePosition, vec3 planeNormal)
{
	vec3 ray = normalize(rayTarget - rayOrigin);
	float planeDistance = dot(planePosition, planeNormal);
	
	float denom = dot(-ray, planeNormal);

	float t = (dot(rayOrigin, planeNormal) - planeDistance)/denom;
	
	vec3 projectedPosition = rayOrigin + ray*(t - zFightAvoidance);
	
	return mix(projectedPosition, rayTarget, step(denom, 0.0001));
}

void fragment() {
	vec4 tex = texture(sprite, UV);
	ALBEDO = tex.xyz;
	ALPHA = tex.a;
	
	vec3 worldVertex = (INV_VIEW_MATRIX * vec4(VERTEX,1.0)).xyz;

	vec3 projectionForward = spriteDirection - (nodeUpWorld * dot(spriteDirection, nodeUpWorld));

	vec3 projectedVertex = mix(
		CastRayOntoPlane(CAMERA_POSITION_WORLD, worldVertex, NODE_POSITION_WORLD, normalize(projectionForward)),
		CastRayOntoPlane(CAMERA_POSITION_WORLD, worldVertex, NODE_POSITION_WORLD, nodeUpWorld),
		step(dot(worldVertex-NODE_POSITION_WORLD, nodeUpWorld), 0.0)
	);

	vec4 projected = VIEW_MATRIX * vec4(projectedVertex,1.0);
	projected = PROJECTION_MATRIX * projected;
	DEPTH = projected.z / projected.w;

	// Test if compatibility renderer
	if (OUTPUT_IS_SRGB)
	{
		DEPTH = (DEPTH + 1.0)/2.0;
	}
}
