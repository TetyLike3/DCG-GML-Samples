///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////// [NOTES] /////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// There are some external variables required in the calling object (for example, the player object calling it in the Step event). The macros can be copied and pasted into a script instance as follows:

canCollideX					// Whether the subject can collide with walls on the X axis
canCollideY					// Whether the subject can collide with walls on the Y axis. Useful for semi-solid platforms.
xSpeed						// The horizontal speed of the subject
ySpeed						// The vertical speed of the subject

// There is also a global variable, which holds the tilemap layer for the ground, which is used in the tile collisions:
global.groundLayerTilemap

// You must assign values to all of these variables yourself.


// Finally, there is one object (objWall) that is used in the object collisions.


/*
    The basic premise of this collision system is that it checks for collisions on one axis (WallCollision functions check X axis, GroundCollision functions check Y axis).
    If there is a collision, it will move the subject in smaller and smaller increments until it is flush against the colliding surface. Then it will set the speed to 0.
    Regardless of whether there is a collision or not, it will then move the subject by the processed speed.
    For example, if there is no collision, xSpeed will be unchanged, and the player can move. Otherwise, xSpeed will be set to 0, and the player will therefore not move.
*/

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////// [VARIABLE DEFINITIONS] /////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// You will not need any Variable Definitions on an object for this code, as it should preferably be placed inside a script instance.


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////// [CODE] /////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// Object Wall (X axis) collisions
function getWallCollision(offset = 1) {
    if (!canCollideX) return false; // If the subject can't collide with wall objects (X axis), return false
    return collision_point(x+offset,y,objWall,false,false); // Check for a collision with the wall object using the offset, and return the result
}

function executeWallCollision() {
    if (getWallCollision(xSpeed)) { // If there is a collision with a wall object
        while (abs(xSpeed) > 0.1) { // While the speed is greater than 0.1
            xSpeed*=0.5; // Reduce the speed by half
            if (!getWallCollision(xSpeed)) x += xSpeed; // If there is no collision with the wall object, move the subject by the speed
        }
        xSpeed = 0; // Set the speed to 0
    }
    x += xSpeed; // Move the subject along the X axis by the processed speed
}

// Tile Wall (X axis) collisions
function getWallTileCollision(offset = 1) {
    if (!canCollideX) return false; // If the subject can't collide with wall tiles (X axis), return false
    return tilemap_get_at_pixel(global.groundLayerTilemap,x+offset,y); // Check for a collision with the wall tile using the offset, and return the result
}

// Imagine executeWallCollision(), but using getWallTileCollision() instead
function executeWallTileCollision() {
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
// This function basically combines the code of executeWallCollision() and executeWallTileCollision()
// NOTE: You can swap these if statements if you want objects to take priority over tiles, or vice versa.
function executeAllWallCollision() {
    if(getWallTileCollision(xSpeed)) {
        while(abs(xSpeed) > 0.1) {
            xSpeed *= 0.5;
            if (!getWallTileCollision(xSpeed)) x += xSpeed;
        }
        xSpeed = 0;
    }
    if (getWallCollision(xSpeed)) {
        while (abs(xSpeed) > 0.1) {
            xSpeed*=0.5;
            if (!getWallCollision(xSpeed)) x += xSpeed;
        }
        xSpeed = 0;
    }
    x += xSpeed;
}


// Object Ground (Y axis) collisions
function getGroundCollision(offset = 1) {
    if (!canCollideY) return false; // If the subject can't collide with ground objects (Y axis), return false
    return collision_point(x,y+offset,objWall,false,false); // Check for a collision with the ground object using the offset, and return the result
}

// Imagine executeWallCollision(), but using getGroundCollision() instead
function executeGroundCollision() {
    if(getGroundCollision(ySpeed)) {
        while(abs(ySpeed) > 0.1) {
            ySpeed *= 0.5;
            if (!getGroundCollision(ySpeed)) y += ySpeed;
        }
        ySpeed = 0;
    }
    y += ySpeed; // Move the subject along the Y axis by the speed
}

// Tile Ground (Y axis) collisions
function getGroundTileCollision(offset = 1) {
    if (!canCollideY) return false;
    return tilemap_get_at_pixel(global.groundLayerTilemap,x,y+offset);
}

// Imagine executeWallTileCollision(), but using getGroundTileCollision() instead
function executeGroundTileCollision() {
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
// This function basically combines the code of executeGroundCollision() and executeGroundTileCollision()
// NOTE: You can swap these if statements if you want objects to take priority over tiles, or vice versa.
function executeAllGroundCollision() {
    if(getGroundTileCollision(ySpeed)) {
        while(abs(ySpeed) > 0.1) {
            ySpeed *= 0.5;
            if (!getGroundTileCollision(ySpeed)) y += ySpeed;
        }
        ySpeed = 0;
    }
    if(getGroundCollision(ySpeed)) {
        while(abs(ySpeed) > 0.1) {
            ySpeed *= 0.5;
            if (!getGroundCollision(ySpeed)) y += ySpeed;
        }
        ySpeed = 0;
    }
    y += ySpeed;
}
