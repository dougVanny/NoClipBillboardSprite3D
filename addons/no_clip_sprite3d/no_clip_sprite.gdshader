shader_type spatial;

#define Z_FIGHT_GROUND_AVOIDANCE 0.0001

render_mode shadows_disabled;
render_mode unshaded;
render_mode depth_prepass_alpha;

uniform sampler2D sprite:source_color,filter_nearest;

uniform vec2 pivot = vec2(0.0,0.0);
uniform bool noClip = true;

uniform int vertexModeFacing : hint_enum("Face Camera Direction (Billboard)", "Face Camera Position") = 0;
uniform int vertexModeUp : hint_enum("Camera Y", "Local Y") = 0;

varying vec3 spriteDirection;
varying vec3 localCameraPosition;
varying vec3 localNodePosition;
varying vec3 localVertex;

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

	localCameraPosition = (inverse(MODEL_MATRIX) * vec4(CAMERA_POSITION_WORLD,1.0)).xyz;

	localNodePosition = (inverse(MODEL_MATRIX) * vec4(NODE_POSITION_WORLD,1.0)).xyz;
	localNodePosition.y += Z_FIGHT_GROUND_AVOIDANCE;

	localVertex = VERTEX;
}

vec3 ProjectFromCameraOntoPlane(vec3 position, vec3 cameraPosition, vec3 planePosition, vec3 planeNormal)
{
	vec3 ray = normalize(cameraPosition-position);
	
	float denom = dot(planeNormal, ray);
	
	float t = dot(planePosition-cameraPosition, planeNormal)/denom;
	
	vec3 projectedPosition = cameraPosition + ray*t;
	
	return mix(projectedPosition, position, step(denom, 0.0001));
}

void fragment() {
	vec4 tex = texture(sprite, UV);
	ALBEDO = tex.xyz;
	ALPHA = tex.a;
	
	vec3 projectedVertex = mix(
		ProjectFromCameraOntoPlane(localVertex, localCameraPosition, localNodePosition, normalize(vec3(spriteDirection.x, 0.0, spriteDirection.z))),
		ProjectFromCameraOntoPlane(localVertex, localCameraPosition, localNodePosition, vec3(0.0,1.0,0.0)),
		step(localVertex.y, localNodePosition.y)
	);

	vec4 projected = VIEW_MATRIX * MODEL_MATRIX * vec4(projectedVertex,1.0);
	projected = PROJECTION_MATRIX * projected;
	DEPTH = projected.z / projected.w;

	// Test if compatibility renderer
	if (OUTPUT_IS_SRGB)
	{
		DEPTH = (DEPTH + 1.0)/2.0;
	}
}
