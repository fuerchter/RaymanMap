-- Initialize functions
getBlockName = function(hex)
	if hex==0x04 then
		return "reactionary"
	elseif hex>=0x08 and hex<0x0c then
		return "left";
	elseif hex>=0x0c and hex<0x10 then
		return "right";
	elseif hex>=0x10 and hex<0x14 then
		return "left small 1";
	elseif hex>=0x14 and hex<0x18 then
		return "left small 2";
	elseif hex>=0x18 and hex<0x1c then
		return "right small 1";
	elseif hex>=0x1c and hex<0x20 then
		return "right small 2";
	elseif hex>=0x20 and hex<0x24 then
		return "death";
	elseif hex>=0x24 and hex<0x28 then
		return "bounce";
	elseif hex>=0x28 and hex<0x30 then
		return "water";
	elseif hex>=0x30 and hex<0x38 then
		return "climb";
	elseif hex>=0x38 and hex<0x3c then
		return "pass down";
	elseif hex>=0x3c and hex<0x48 then
		return "full";
	elseif hex>=0x48 and hex<0x4c then
		return "slippery left";
	elseif hex>=0x4c and hex<0x50 then
		return "slippery right";
	elseif hex>=0x50 and hex<0x54 then
		return "slippery left small 1";
	elseif hex>=0x54 and hex<0x58 then
		return "slippery left small 2";
	elseif hex>=0x58 and hex<0x5c then
		return "slippery right small 1";
	elseif hex>=0x5c and hex<0x60 then
		return "slippery right small 2";
	elseif hex>=0x60 and hex<0x64 then
		return "instant mortal";
	elseif hex>=0x64 and hex<0x78 then
		return "falling";
	elseif hex>=0x78 and hex<0x80 then
		return "slippery";
	else 
		return "";
	end
end

--initialize camera / window values
windowWidth = 800;
windowHeight= 480;
borderLeftWidth  = 86;
borderRightWidth = 74; --yes, border left > border right

tileWidthCamera =16;
tileHeightCamera=16;
xTiles=20; --20 tiles are on camera each time (horizontally)
yTiles=15;

--on screen sizes
tileWidthScreen =32;
tileHeightScreen=32;

--initialize camera data
xCameraPrevious=0;
yCameraPrevious=0;

--initialize verbose state
verboseMode=false;

form=forms.newform("RaymanMap");
verboseBox=forms.checkbox(form, "Verbose Mode", 5, 5);

while true do
	if mainmemory.readbyte(0x1cee81)==1 --only draw if in a level
	then
		verboseMode=forms.ischecked(verboseBox);
		
		--map data
		width=mainmemory.read_u16_le(0x1f4430); --in tiles
		start=mainmemory.read_u32_le(0x1f4438)-0x80000000;
		
		--camera data
		xCamera=mainmemory.read_u16_le(0x1f84b8);
		yCamera=mainmemory.read_u16_le(0x1f84c0);
		
		--interpolate camera (will be added to x, y coordinates)
		xCameraI=(xCamera - xCameraPrevious)*3; -- 3 is just a magic constant that happened to work for me
		yCameraI=(yCamera - yCameraPrevious)*3; -- ... but it might not work elsewhere
		
		row=start+width*2*(math.floor(yCamera/tileHeightCamera))+2*(math.floor(xCamera/tileWidthCamera)); --16 camera indices per tile

		xSplitTile=((xCamera%tileWidthCamera) /tileWidthCamera) *tileWidthScreen;
		ySplitTile=((yCamera%tileHeightCamera)/tileHeightCamera)*tileHeightScreen;
		
		--tile positions
		for y=0, yTiles
		do
			for x=0, xTiles
			do
				xPos=x*tileWidthScreen+borderLeftWidth-xSplitTile+xCameraI;
				yPos=y*tileHeightScreen               -ySplitTile+yCameraI;
				blockType=mainmemory.readbyte(row+1+x*2);
				if verboseMode==false
					then
					if getBlockName(blockType) ~= "" then
						gui.drawImage(getBlockName(blockType) .. ".png", xPos, yPos, tileWidthScreen, tileHeightScreen);
					end
				else
					if blockType ~= 0x00 then
						gui.drawText(xPos, yPos, bizstring.hex(blockType), 0xFFFFFFFF, 14);
					end 
				end
			end
			row=row+width*2;
		end
		
		--shitty fix for drawing over the screen border
		gui.drawRectangle(0, 0, borderLeftWidth, windowHeight, 0x00000000, 0xFF000000);
		gui.drawRectangle(windowWidth - borderRightWidth, 0, borderRightWidth, windowHeight, 0x00000000, 0xFF000000);
	end
	-- previous camera data to determine the camera speed
	xCameraPrevious=xCamera;
	yCameraPrevious=yCamera;
	
	-- advance frame
	emu.frameadvance();
end
