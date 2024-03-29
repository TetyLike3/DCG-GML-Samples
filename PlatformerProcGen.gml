
//
// [NOTES]
//

/*
	I have created a couple macros that will be used here. The macros can be copied and pasted into a script instance as follows:
*/
	#macro CELL_WIDTH 16
	#macro CELL_HEIGHT 16
	#macro TILE_GROUND {\
		SURFACE : {\
			LEFT_EDGE : 20,\
			CENTER : 21,\
			RIGHT_EDGE : 22,\
			LEFT_CORNER : 54,\
			RIGHT_CORNER : 56,\
		},\
		GROUND : {\
			LEFT_EDGE : 37,\
			CENTER : 38,\
			RIGHT_EDGE : 39,\
			BOTTOM_LEFT_EDGE : 105,\
			BOTTOM_CENTER : 106,\
			BOTTOM_RIGHT_EDGE : 107,\
			PLACEHOLDER : 140\
		}\
	}
	#macro TILE_AIR 0
/*
	It is recommended that you change the values of the TILE_GROUND struct to the tile indices in your own tileset.
	CELL_WIDTH and CELL_HEIGHT should be equal to the width and height of your tiles in your tileset.
	TILE_AIR can be left as-is, unless you have a specific tile that you want to use for air.
*/


///////////////////////////////////////////////////////////////

//
// [VARIABLE DEFINITIONS]
//

minIslandWidth = 12; 				// Integer
averageIslandWidth = 16; 			// Integer

minIslandHeight = 8; 				// Integer
averageIslandHeight = 12; 			// Integer
startingIslandHeight = 8; 			// Integer

islandHeightVariation = 1; 			// Integer

platformLengthVariation = 8; 			// Integer
platformBaseHeight = 6; 			// Integer
platformHeightVariation = 2; 			// Integer

islandGapChance = 0.5; 				// Real, Range: 0-1
enemySpawnChance = 0.3; 			// Real, Range: 0-1
platformSpawnChance = 0.6; 			// Real, Range: 0-1



///////////////////////////////////////////////////////////////

//
// [CREATE EVENT]
//

// Randomise the seed so that every level is different.
randomise();


// [ Set up variables ] //

gridWidth = (room_width div CELL_WIDTH) + 2;
gridHeight = (room_height div CELL_HEIGHT) + 2;

// Create the grid, and then fill it with the index for the air tile.
//	(In this case, I'm using the index 0, which is always empty.)

grid = ds_grid_create(gridWidth, gridHeight);
ds_grid_set_region(grid, 0, 0, gridWidth, gridHeight, TILE_AIR);


// Used to ensure that islands are similar to the previous one
lastIslandEndX = 0;
lastIslandHeight = startingIslandHeight;

// Generate two walls of tiles that go along both sides of the room
for (var _y = 0; _y < gridHeight; _y++) {
	grid[# 0, _y] = TILE_GROUND.GROUND.PLACEHOLDER;
	grid[# gridWidth, _y] = TILE_GROUND.GROUND.PLACEHOLDER;
}





// [ Generate grid ] //

while (lastIslandEndX < gridWidth) {


	// Set up temporary variables //

	var cornerX;
	var cornerY = gridHeight; // This will always be the grid height (bottom of the grid), but it's nice to use this just in case


	// Generate a random number that will determine whether there will be a gap between the last island and the next one
	//	The gap created spans between 0-6 tiles. (Starting from 0 to make it slightly less likely to have a gap)

	var randomNumber = random_range(0,1);
	if (randomNumber <= islandGapChance) cornerX = lastIslandEndX + (irandom_range(0,2)*3);
	else var cornerX = lastIslandEndX;


	// If this island is the first one, then the gap will be ignored
	if (!lastIslandEndX) cornerX = 0;


	// Generate a pair of random numbers that will determine the dimensions of the island, 
	//	using the minimum and average values in a range to keep the values close to the given averages

	var islandWidth = irandom_range(minIslandWidth,averageIslandWidth);
	var islandHeight = irandom_range(minIslandHeight,averageIslandHeight);
	

	// Fill the island in with placeholder ground tiles

	for(var _x = cornerX; _x < islandWidth + cornerX; _x++) {
		for(var _y = cornerY; _y > cornerY - islandHeight; _y--) {
			if (_x > gridWidth) continue;
			grid[# _x, _y] = TILE_GROUND.GROUND.PLACEHOLDER;
		}
	}
	

	// Update these variables for the next island to use

	lastIslandEndX = (cornerX + islandWidth);
	lastIslandHeight = islandHeight;
	

	// Adjust the minimum values so that the next island's values does not deviate too much from the given averages

	minIslandWidth += (averageIslandWidth - islandWidth) div 2;
	minIslandHeight += (averageIslandHeight - islandHeight) div 2;
	



	// [ Random enemy spawning ] //

	randomNumber = random_range(0,1);
	if (randomNumber <= enemySpawnChance) {
		instance_create_layer((cornerX*CELL_WIDTH)+(islandWidth*CELL_WIDTH/2),(cornerY*CELL_HEIGHT)-(islandHeight*CELL_HEIGHT)-2,"Instances",/*PLACE YOUR ENEMY OBJECT HERE*/);

		// Update enemy counts here, for example:
		//objLevelManager.enemyCount++;
		//objLevelManager.maxEnemyCount++;
	}



	// [ Random platform spawning ] //

	randomNumber = random_range(0,1);
	if (randomNumber <= platformSpawnChance) {

		// Generate platform dimensions and X position

		var platformLength = islandWidth + irandom_range(-platformLengthVariation,0);
		var platformStartX = cornerX+((islandWidth-platformLength)/2)
		var platformHeight = cornerY-(islandHeight+platformBaseHeight+irandom_range(-platformHeightVariation,platformHeightVariation));
		

		// Fill the platform in with placeholder ground tiles

		for(var _x = platformStartX; _x < platformLength + cornerX; _x++) {
			if (_x > gridWidth) continue;
			grid[# _x, platformHeight] = TILE_GROUND.GROUND.PLACEHOLDER;
			grid[# _x, platformHeight-1] = TILE_GROUND.GROUND.PLACEHOLDER;
		}
	}
}




// [ Create the tilemap ] //
/* 
	I have assigned this as a global variable so that other objects can use it, for example in tile collisions.
*/

global.groundLayer = layer_create(100,"ProcGen"); // You might want to change the depth here, or change the depth of other layers in the room, otherwise you might not be able to see the tiles.
global.groundLayerTilemap = layer_tilemap_create(global.groundLayer,-1,0,/*PLACE YOUR TILESET HERE*/,gridWidth*CELL_WIDTH,gridHeight*CELL_HEIGHT);



// [ Adjust grid cell values for visual improvement] //
/*
	What this huge block of code does is simply check each adjacent tile, and if it is air, then it will change the tile to a more appropriate one.

	For example, if the tile to the left is air, and the tile above and below are not, then it will change the tile to a left edge tile.
	Or, if the tile to the top left is air, but the tiles above, below, and to the sides are not, then it will change the tile to a left inner corner tile.
*/


for (var _x = 0; _x < gridWidth; _x++) {
	for (var _y = 0; _y < gridHeight; _y++) {
		if (grid[# _x,_y] == TILE_AIR) continue;
		if (grid[# _x,_y-1] == TILE_AIR) { // Is a Surface tile
			if (grid[# _x-1,_y] == TILE_AIR) grid[# _x,_y] = TILE_GROUND.SURFACE.LEFT_EDGE;
			else if (grid[# _x+1,_y] == TILE_AIR) grid[# _x,_y] = TILE_GROUND.SURFACE.RIGHT_EDGE;
			else grid[# _x,_y] = TILE_GROUND.SURFACE.CENTER;
		} else if (grid[# _x-1,_y-1] == TILE_AIR && grid[# _x-1,_y] != TILE_AIR) grid[# _x,_y] = TILE_GROUND.SURFACE.LEFT_CORNER;
		else if (grid[# _x+1,_y-1] == TILE_AIR && grid[# _x+1,_y] != TILE_AIR) grid[# _x,_y] = TILE_GROUND.SURFACE.RIGHT_CORNER;
		else if (grid[# _x,_y+1] == TILE_AIR) { // Is a Ground bottom tile
			if (grid[# _x-1,_y] == TILE_AIR) grid[# _x,_y] = TILE_GROUND.GROUND.BOTTOM_LEFT_EDGE;
			else if (grid[# _x+1,_y] == TILE_AIR) grid[# _x,_y] = TILE_GROUND.GROUND.BOTTOM_RIGHT_EDGE;
			else grid[# _x,_y] = TILE_GROUND.GROUND.BOTTOM_CENTER;
		} else {
			if (grid[# _x-1,_y] == TILE_AIR) grid[# _x,_y] = TILE_GROUND.GROUND.LEFT_EDGE;
			else if (grid[# _x+1,_y] == TILE_AIR) grid[# _x,_y] = TILE_GROUND.GROUND.RIGHT_EDGE;
			else grid[# _x,_y] = TILE_GROUND.GROUND.CENTER;
		}
	}
}



// [ Project grid onto tilemap ] //
/*
	Finally, you can project all the cells on the grid onto the tilemap.
	We shift it to the left by one cell so that the left wall (created at the very top) is not visible.
	tileType is essentially just a cell in the grid, and every cell contains the index of the tile (from the given tileset) to be placed.
*/


for (var _x = 0; _x < gridWidth; _x++) {
	for (var _y = 0; _y < gridHeight; _y++) {
		var tileType = ds_grid_get(grid,_x,_y);
		tilemap_set(global.groundLayerTilemap,tileType,_x-1,_y);
	}
}



// To prevent memory leaks, we destroy the grid. If you wish to use this later on, you can remove this line.

ds_grid_destroy(grid);
