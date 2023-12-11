
//
// [NOTES]
//

/*
	There are some external variables required in the calling object (for example, the player object calling it in the Step event). The macros can be copied and pasted into a script instance as follows:
*/
canCollideX					// Whether the subject can collide with walls on the X axis
canCollideY					// Whether the subject can collide with walls on the Y axis. Useful for semi-solid platforms.
xSpeed						// The horizontal speed of the subject
ySpeed						// The vertical speed of the subject


/*
	There is also a global variable, which holds the tilemap layer for the ground, which is used in the tile collisions.
*/
global.groundLayerTilemap

/*
You must assign values to these variables yourself.
*/


/*
	Finally, there is one object (objWall) that is used in the object collisions.
*/


/*
	The basic premise of this collision system is that it checks for collisions on one axis (WallCollision functions check X axis, GroundCollision functions check Y axis).
	If there is a collision, it will move the subject in smaller and smaller increments until it is flush against the colliding surface. Then it will set the speed to 0.
	Regardless of whether there is a collision or not, it will then move the subject by the speed.
*/

///////////////////////////////////////////////////////////////


// Object Wall (X axis) collisions
function getWallCollision(offset = 1) {
	if (!canCollideX) return false; 					// If the subject can't collide with wall objects (X axis), return false
	return collision_point(x+offset,y,objWall,false,false); // Check for a collision with the wall object using the offset, and return the result
}

function executeWallCollision() {
	if (getWallCollision(xSpeed)) { 					// If there is a collision with a wall object
		while (abs(xSpeed) > 0.1) { 					// While the speed is greater than 0.1
			xSpeed*=0.5; 								// Reduce the speed by half
			if (!getWallCollision(xSpeed)) x += xSpeed; // If there is no collision with the wall object, move the subject by the speed
		}
		xSpeed = 0; 									// Set the speed to 0
	}
	x += xSpeed; 										// Move the subject along the X axis by the speed
}

// Tile Wall (X axis) collisions
function getWallTileCollision(offset = 1) {
	if (!canCollideX) return false; 					// If the subject can't collide with wall tiles (X axis), return false
	return tilemap_get_at_pixel(global.groundLayerTilemap,x+offset,y); // Check for a collision with the wall tile using the offset, and return the result
}

function executeWallTileCollision() {					// Essentially just the code of executeWallCollision(), but with getWallTileCollision() instead
	if(getWallTileCollision(xSpeed)) {
		while(abs(xSpeed) > 0.1) {
			xSpeed *= 0.5;
			if (!getWallTileCollision(xSpeed)) x += xSpeed;
		}
		xSpeed = 0;
	}
	x += xSpeed;
}

// All Wall (X axis) collisions
function executeAllWallCollision() {
	if(getWallTileCollision(xSpeed)) { 					// Essentially just most of executeWallTileCollision()
		while(abs(xSpeed) > 0.1) {
			xSpeed *= 0.5;
			if (!getWallTileCollision(xSpeed)) x += xSpeed;
		}
		xSpeed = 0;
	}
	if (getWallCollision(xSpeed)) { 					// Essentially just most of executeWallCollision()
		while (abs(xSpeed) > 0.1) {
			xSpeed*=0.5;
			if (!getWallCollision(xSpeed)) x += xSpeed;
		}
		xSpeed = 0;
	}
	x += xSpeed;

														// NOTE: You can swap these if statements if you want objects to take priority over tiles, or vice versa.
}


// Object Ground (Y axis) collisions
function getGroundCollision(offset = 1) {
	if (!canCollideY) return false; 					// If the subject can't collide with ground objects (Y axis), return false
	return collision_point(x,y+offset,objWall,false,false); // Check for a collision with the ground object using the offset, and return the result
}

function executeGroundCollision() {						// Essentially just the code of executeWallCollision(), but with getGroundCollision() instead
	if(getGroundCollision(ySpeed)) {
		while(abs(ySpeed) > 0.1) {
			ySpeed *= 0.5;
			if (!getGroundCollision(ySpeed)) y += ySpeed;
		}
		ySpeed = 0;
	}
	y += ySpeed; 										// Move the subject along the Y axis by the speed
}

// Tile Ground (Y axis) collisions
function getGroundTileCollision(offset = 1) {			// Essentially just the code of executeWallCollision(), but with getGroundCollision() instead
	if (!canCollideY) return false;
	return tilemap_get_at_pixel(global.groundLayerTilemap,x,y+offset);
}

function executeGroundTileCollision() {					// Essentially just the code of executeGroundCollision(), but with getGroundTileCollision() instead
	if(getGroundTileCollision(ySpeed)) {
		while(abs(ySpeed) > 0.1) {
			ySpeed *= 0.5;
			if (!getGroundTileCollision(ySpeed)) y += ySpeed;
		}
		ySpeed = 0;
	}
	y += ySpeed;
}

// All Ground (Y axis) collisions
function executeAllGroundCollision() {
	if(getGroundTileCollision(ySpeed)) { 				// Essentially just most of executeGroundTileCollision()
		while(abs(ySpeed) > 0.1) {
			ySpeed *= 0.5;
			if (!getGroundTileCollision(ySpeed)) y += ySpeed;
		}
		ySpeed = 0;
	}
	if(getGroundCollision(ySpeed)) {					// Essentially just most of executeGroundCollision()
		while(abs(ySpeed) > 0.1) {
			ySpeed *= 0.5;
			if (!getGroundCollision(ySpeed)) y += ySpeed;
		}
		ySpeed = 0;
	}
	y += ySpeed;

														// NOTE: You can swap these if statements if you want objects to take priority over tiles, or vice versa.
}