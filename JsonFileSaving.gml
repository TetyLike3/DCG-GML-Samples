///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////// [NOTES] /////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*
    These functions will allow you to write and read data to and from a file, using JSON.
    This is an extremely overpowered way to store data, as you can store whole tables, for example, inventory data.

    ! ! !  Do note that every time you call the SaveJsonData and LoadJsonData functions, you must pass in a filename.
*/

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////// [VARIABLE DEFINITIONS] /////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// You do not need to define any object variables for these functions. This code should be stored in a script instance.


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////// [CODE] /////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// ! ! !  This is an internal function, use the LoadJsonData function to load data.
// This function will read all the text from a save file and return it as a JSON string.
function readAllFileText(filename) {
	if !file_exists(filename) return undefined;
	
	var buffer = buffer_load(filename);
	var result = buffer_read(buffer,buffer_string);
	buffer_delete(buffer);
	return result;
}

// ! ! !  This is an internal function, use the SaveJsonData function to save data.
// This function will write all the given text to a save file.
function writeAllFileText(filename,content) {
	var buffer = buffer_create(string_length(content),buffer_grow,1);
	buffer_write(buffer,buffer_string,content);
	buffer_save(buffer,filename);
	buffer_delete(buffer);
}



// This function will load the data from a save file using readAllFileText, and then return the data using json_parse.
function LoadJsonData(filename) {
	var jsonContent = readAllFileText(filename);
	
	if is_undefined(jsonContent) return undefined;
	
	try return json_parse(jsonContent);
	catch(_) return undefined;
}

// This function will convert the given value to a JSON string, and then call writeAllFileText with the given filename and JSON string.
// If you wanted to store multiple values, just pass in a table for the value.
function SaveJsonData(filename,value) {
	var jsonContent = json_stringify(value);
	writeAllFileText(filename,jsonContent);
}
