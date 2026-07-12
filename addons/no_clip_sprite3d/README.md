A Godot plugin with a custom type NoClipSprite3D that acts like a Sprite3D while avoiding clipping with the scenario

# How it works

Usually, when you add a 3D sprite to a scene and need it to face the camera (such as when making it a billboard), you might end up in situations where the sprite will end up clipping with the ground or a wall

What NoClipSprite3D does is render that sprite with a shader that will project the sprite in a L shape, therefore avoiding the clipping completely. The projection is done simply by changing the depth of each fragment of the sprite

# How to use it

The simplest way is to add a NoClipSprite3D node to your scene and assign the texture and its size

The facing direction and up direction fields can be used to set how to render the sprite, similarly to setting a sprite to show as a billboard

Finally, use the pivot field to adjust the position of the sprite without moving the node itself. It is important to keep the node position close to the ground as that's where the shader will position the corner of the L

The position of the pivot would normally be between the feet of a character, although that might change in some cases such as with an animal that stands on four legs

------

Using sprites from "Zelda-like tilesets and sprites" by ArMM1998
https://opengameart.org/content/zelda-like-tilesets-and-sprites
