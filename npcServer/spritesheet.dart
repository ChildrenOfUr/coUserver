part of coUserver;

class Spritesheet
{
	String stateName;
	String url;
	int sheetWidth, sheetHeight, frameWidth, frameHeight, numFrames, numRows, numColumns;
	bool loops;
	
	Spritesheet(this.stateName,this.url,this.sheetWidth,this.sheetHeight,this.frameWidth,this.frameHeight,this.numFrames,this.loops)
	{
		numRows = sheetHeight~/frameHeight;
		numColumns = sheetWidth~/frameWidth;
	}
	
	@override
	String toString()
	{
		return "$stateName: width: $sheetWidth, height: $sheetHeight, numFrames: $numFrames, rows: $numRows, columns: $numColumns, frameWidth: $frameWidth, frameHeight: $frameHeight, src: $url";
	}
}