shader_type spatial;

#define Z_FIGHT_GROUND_AVOIDANCE 0.0001

render_mode shadows_disabled;
render_mode unshaded;
render_mode depth_prepass_alpha;

uniform sampler2D sprite:source_color,filter_nearest;
uniform vec2 offset = vec2(0.0,0.0);

uniform int billboardMode = 0;
// 0: Regular billboard
// 1: Y-billboard
// 2: Rotate towards camera
// Update for 4.4: https://github.com/godotengine/godot/pull/94324

varying vec3 spriteDirection;

void vertex() {
	if(billboardMode == 2)
	{
		spriteDirection =  MAIN_CAM_INV_VIEW_MATRIX[3].xyz - MODEL_MATRIX[3].xyz;
	}
	else
	{
		spriteDirection = CAMERA_DIRECTION_WORLD;
	}

	vec3 local_x = MODEL_MATRIX[0].xyz;
	vec3 local_z = MODEL_MATRIX[2].xyz;

	vec3 local_y;

	if(billboardMode == 0)
	{
		local_y = MAIN_CAM_INV_VIEW_MATRIX[1].xyz;
	}
	else if(billboardMode == 1)
	{
		local_y = MODEL_MATRIX[1].xyz;
	}
	else
	{
		local_y = normalize(cross(cross(spriteDirection,MODEL_MATRIX[1].xyz),spriteDirection));
	}

	//use cross products to find world space axis for the billboard
	// local_y cross direction_to_camera = right
	vec3 billboard_x = normalize(cross(local_y, spriteDirection));
	// billboard_x cross local_y = forward
	vec3 billboard_z = normalize(cross(billboard_x, local_y));

	vec4 translation = vec4(offset.x * billboard_x + offset.y * local_y,0.0);

	// override the model view matrix, this mat4 shenanigan is setting the X, Y, and Z axis of the matrix, to the axis we just made (keeping local y)
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(vec4(billboard_x * length(local_x), 0.0), vec4(local_y, 0.0), vec4(billboard_z * length(local_z), 0.0), MODEL_MATRIX[3] + translation);

	// and then remmake the normal matrix
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}

vec3 VertexPositionAbovePivot(vec3 vertexPositionWorld, vec3 cameraPositionWorld, vec3 nodePositionWorld)
{
	vec3 ray = normalize(cameraPositionWorld-vertexPositionWorld);

	vec3 spriteFlatDirection = normalize(vec3(spriteDirection.x, 0.0, spriteDirection.z));
	
	float denom = dot(spriteFlatDirection, ray);
	
	float t = dot(nodePositionWorld-cameraPositionWorld, spriteFlatDirection)/denom;
	vec3 fakePosition = cameraPositionWorld + ray*t;
	
	return mix(fakePosition, vertexPositionWorld, step(denom, 0.0001));
}

vec3 VertexPositionBelowPivot(vec3 vertexPositionWorld, vec3 cameraPositionWorld, vec3 nodePositionWorld)
{
	vec3 ray = normalize(cameraPositionWorld-vertexPositionWorld);

	vec3 spriteFlatDirection = vec3(0.0,1.0,0.0);
	
	float denom = dot(spriteFlatDirection, ray);
	
	float t = dot(nodePositionWorld-cameraPositionWorld, spriteFlatDirection)/denom;
	
	vec3 fakePosition = cameraPositionWorld + ray*(t + Z_FIGHT_GROUND_AVOIDANCE);
	
	return mix(fakePosition, vertexPositionWorld, step(denom, 0.0));
}

void fragment() {
	vec4 tex = texture(sprite, UV);
	ALBEDO = tex.xyz;
	ALPHA = tex.a;
	
	vec3 worldVertex = (INV_VIEW_MATRIX * vec4(VERTEX,1.0)).xyz;
	worldVertex = mix(
		VertexPositionAbovePivot(worldVertex, CAMERA_POSITION_WORLD, NODE_POSITION_WORLD),
		VertexPositionBelowPivot(worldVertex, CAMERA_POSITION_WORLD, NODE_POSITION_WORLD),
		step(worldVertex.y, NODE_POSITION_WORLD.y)
	);

	vec4 projected = VIEW_MATRIX * vec4(worldVertex,1.0);
	projected = PROJECTION_MATRIX * projected;
	DEPTH = projected.z / projected.w;

	// Test if compatibility renderer
	if (OUTPUT_IS_SRGB)
	{
		DEPTH = (DEPTH + 1.0)/2.0;
	}
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
