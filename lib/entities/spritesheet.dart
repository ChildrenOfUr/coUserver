part of entity;

class Spritesheet
{
	String stateName;
	String url;
	int sheetWidth, sheetHeight, frameWidth, frameHeight, numFrames, numRows, numColumns;
	bool loops = false;
	int loopDelay;

	Spritesheet(this.stateName,this.url,this.sheetWidth,this.sheetHeight,this.frameWidth,this.frameHeight,this.numFrames,this.loops, {this.loopDelay:0})
	{
		numRows = sheetHeight~/frameHeight;
		numColumns = sheetWidth~/frameWidth;
	}

	@override
	String toString()
	{
		return "$stateName: width: $sheetWidth, height: $sheetHeight, numFrames: $numFrames, rows: $numRows, columns: $numColumns, frameWidth: $frameWidth, frameHeight: $frameHeight, src: $url";
	}

	Map toMap() => {
		"stateName": stateName,
		"url": url,
		"sheetWidth": sheetWidth,
		"sheetHeight": sheetHeight,
		"frameWidth": frameWidth,
		"frameHeight": frameHeight,
		"numFrames": numFrames,
		"numRows": numRows,
		"numColumns": numColumns,
		"loops": loops,
		"loopDelay": loopDelay
	};
}