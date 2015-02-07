while true do
	--[[
	Issues:
	-lag (try making 16x16 image and scaling up to 32x32)
	-camera doesn't catch up (wrong memory value, reading from previous frame?)
	-draws blocks to the left and right of the screen
	]]--
	if mainmemory.readbyte(0x1cee81)==1 --don't do anything if we are not in a level
		then
		--map data
		width=mainmemory.read_u16_le(0x1f4430); --in tiles
		start=mainmemory.read_u32_le(0x1f4438)-0x80000000;
		
		--camera data
		xCamera=mainmemory.read_u16_le(0x1f84b8);
		yCamera=mainmemory.read_u16_le(0x1f84c0);
		tileWidthCamera=16;
		tileHeightCamera=16;
		xTiles=20; --20 tiles are on camera each time (horizontally)
		yTiles=15;
		--on screen sizes
		tileWidthScreen=32;
		tileHeightScreen=32;
		
		row=start+width*2*(math.floor(yCamera/tileHeightCamera))+2*(math.floor(xCamera/tileWidthCamera)); --16 camera indices per tile

		xSplitTile=((xCamera%tileWidthCamera)/tileWidthCamera)*tileWidthScreen;
		ySplitTile=((yCamera%tileHeightCamera)/tileHeightCamera)*tileHeightScreen;
		
		--tile positions
		for y=0, yTiles
		do
			for x=0, xTiles
			do
				xPos=x*tileWidthScreen+86-xSplitTile; --86 is the border width
				yPos=y*tileHeightScreen-ySplitTile;
				blockType=mainmemory.readbyte(row+1+x*2);
				if blockType>=0x08 and blockType<0x0c
				then
					gui.drawImage("left.png", xPos, yPos, tileWidthScreen, tileHeightScreen);
				elseif blockType>=0x0c and blockType<0x10
				then
					gui.drawImage("right.png", xPos, yPos, tileWidthScreen, tileHeightScreen);
				elseif blockType>=0x10 and blockType<0x14
				then
					gui.drawImage("left small 1.png", xPos, yPos, tileWidthScreen, tileHeightScreen);
				elseif blockType>=0x14 and blockType<0x18
				then
					gui.drawImage("left small 2.png", xPos, yPos, tileWidthScreen, tileHeightScreen);
				elseif blockType>=0x18 and blockType<0x1c
				then
					gui.drawImage("right small 1.png", xPos, yPos, tileWidthScreen, tileHeightScreen);
				elseif blockType>=0x1c and blockType<0x20
				then
					gui.drawImage("right small 2.png", xPos, yPos, tileWidthScreen, tileHeightScreen);
				--
				elseif blockType>=0x20 and blockType<0x24
				then
					gui.drawImage("death.png", xPos, yPos, tileWidthScreen, tileHeightScreen);
				elseif blockType>=0x24 and blockType<0x28
				then
					gui.drawImage("bounce.png", xPos, yPos, tileWidthScreen, tileHeightScreen);
				elseif blockType>=0x28 and blockType<0x30
				then
					gui.drawImage("water.png", xPos, yPos, tileWidthScreen, tileHeightScreen);
				elseif blockType>=0x30 and blockType<0x38
				then
					gui.drawImage("climb.png", xPos, yPos, tileWidthScreen, tileHeightScreen);
				elseif blockType>=0x38 and blockType<0x3c
				then
					gui.drawImage("pass down.png", xPos, yPos, tileWidthScreen, tileHeightScreen);
				elseif blockType>=0x3c and blockType<0x48
				then
					gui.drawImage("full.png", xPos, yPos, tileWidthScreen, tileHeightScreen);
				--
				elseif blockType>=0x48 and blockType<0x4c
				then
					gui.drawImage("slippery left.png", xPos, yPos, tileWidthScreen, tileHeightScreen);
				elseif blockType>=0x4c and blockType<0x50
				then
					gui.drawImage("slippery right.png", xPos, yPos, tileWidthScreen, tileHeightScreen);
				elseif blockType>=0x50 and blockType<0x54
				then
					gui.drawImage("slippery left small 1.png", xPos, yPos, tileWidthScreen, tileHeightScreen);
				elseif blockType>=0x54 and blockType<0x58
				then
					gui.drawImage("slippery left small 2.png", xPos, yPos, tileWidthScreen, tileHeightScreen);
				elseif blockType>=0x58 and blockType<0x5c
				then
					gui.drawImage("slippery right small 1.png", xPos, yPos, tileWidthScreen, tileHeightScreen);
				elseif blockType>=0x5c and blockType<0x60
				then
					gui.drawImage("slippery right small 2.png", xPos, yPos, tileWidthScreen, tileHeightScreen);
				--
				elseif blockType>=0x60 and blockType<0x64
				then
					gui.drawImage("instant mortal.png", xPos, yPos, tileWidthScreen, tileHeightScreen);
				elseif blockType>=0x64 and blockType<0x78
				then
					gui.drawImage("falling.png", xPos, yPos, tileWidthScreen, tileHeightScreen);
				elseif blockType>=0x78 and blockType<0x80
				then
					gui.drawImage("slippery.png", xPos, yPos, tileWidthScreen, tileHeightScreen);
				end
			end
			row=row+width*2;
		end
	end
	emu.frameadvance();
end