local getBlockName = function(hex)
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

local gameToScreen = function(x, y) --calculates screen position (as table) from the game position it is given
	x=(x-camPos.x)*2+borderWidth.left+camI.x;
	y=(y-camPos.y)*2+camI.y;
	return {x=x, y=y};
end

--TODO: parameter description
local drawMap=function(winSize, tSizeCam, tCount, tSizeScreen, verboseMode)
	local width=memory.read_u16_le(0x1f4430); --in tiles
	local start=memory.read_u32_le(0x1f4430+8)-adr;
	
	local row=start+width*2*(math.floor(camPos.y/tSizeCam.height))+2*(math.floor(camPos.x/tSizeCam.width)); --16 camera indices per tile

	local splitTile={};
	splitTile.x=((camPos.x%tSizeCam.width) /tSizeCam.width) *tSizeScreen.width;
	splitTile.y=((camPos.y%tSizeCam.height)/tSizeCam.height)*tSizeScreen.height;
			
	--tile positions
	for y=0, tCount.y
	do
		for x=0, tCount.x
		do
			local pos={};
			pos.x=x*tSizeScreen.width+borderWidth.left-splitTile.x+camI.x;
			pos.y=y*tSizeScreen.height               -splitTile.y+camI.y;
			local blockType=memory.readbyte(row+1+x*2);
			if verboseMode==false
				then
				if getBlockName(blockType) ~= "" then
					gui.drawImage(getBlockName(blockType) .. ".png", pos.x, pos.y, tSizeScreen.width, tSizeScreen.height);
				end
			else
				if blockType ~= 0x00 then
					gui.drawText(pos.x, pos.y, bizstring.hex(blockType), 0xFFFFFFFF, 14);
				end 
			end
		end
		row=row+width*2;
	end
		
	--shitty fix for drawing over the screen border
	gui.drawRectangle(0, 0, borderWidth.left, winSize.height, 0x00000000, 0xFF000000);
	gui.drawRectangle(winSize.width - borderWidth.right, 0, borderWidth.right, winSize.height, 0x00000000, 0xFF000000);
end

--!!!TODO: split/cleanup
local drawEvents=function(current, pos, staticHitbox)	
	--TODO: replace shifts with multiplication (since bytes are used this should be fine)
	local off4=memory.read_u32_le(current+4)-adr;
	local off54=memory.readbyte(current+0x54);
	local off55=memory.readbyte(current+0x55);
	
	anim2=off4+bit.lshift(bit.lshift(off54, 1)+off54, 2); --used in both
	
	--TODO: UNUSED?
	animAdr=memory.read_u32_le(anim2)-adr;--+bit.lshift(off55, 2);
	
	--static hitbox
	local sHitbox=memory.readbyte(current+0x48);
	if sHitbox~=0
	then
		local off0=memory.read_u32_le(current)-adr;
		
		local hitboxAdr=staticHitbox+bit.lshift(sHitbox, 3); --TODO: source?
		local off={x=memory.read_s16_le(hitboxAdr), y=memory.read_s16_le(hitboxAdr+2)};
		local width=memory.readbyte(hitboxAdr+4);
		local height=memory.readbyte(hitboxAdr+5);
		
		--regular position calculation
		local regular=gameToScreen(pos.x+off.x, pos.y+off.y);
		gui.drawRectangle(regular.x, regular.y, width*2, height*2);
		
		--position calculation occurrs at 1478fc
		local off55Calc=bit.lshift(memory.read_u16_le(anim2+8)*off55, 2);
		local hitOff7=bit.arshift(bit.lshift(memory.readbyte(hitboxAdr+7), 0x10), 0xe);
		local anim2Adr=memory.read_u32_le(anim2)-adr+off55Calc+hitOff7;
		
		local anim2Off3=memory.readbyte(anim2Adr+3);
		local anim1Adr=off0+bit.lshift(bit.lshift(anim2Off3, 2)+anim2Off3, 2);
		
		local final={};
		final.x=memory.readbyte(anim2Adr+1)+bit.band(memory.readbyte(anim1Adr+9), 0xf)+pos.x+off.x;
		final.y=memory.readbyte(anim2Adr+2)+bit.rshift(memory.readbyte(anim1Adr+9), 0x4)+pos.y+off.x;
		final=gameToScreen(final.x, final.y);
		gui.drawRectangle(final.x, final.y, width*2, height*2, "blue");
	end
	
	--animated hitbox
	if off55~=0
	then
		ahAdr=memory.read_u32_le(anim2+4)-adr+bit.lshift(off55, 2);
		axOff=memory.readbyte(ahAdr);
		ayOff=memory.readbyte(ahAdr+1);
		aWidth=memory.readbyte(ahAdr+2);
		aHeight=memory.readbyte(ahAdr+3);
		
		local aPos=gameToScreen(pos.x+axOff, pos.y+ayOff);
		gui.drawRectangle(aPos.x, aPos.y, aWidth*2, aHeight*2, "red");
	end
end

local drawStaticHitbox=function()
	--return x, y, width, height...
end

local drawIndex=function(index, screenPos, active, acString)	
	if screenPos.x>=0 and screenPos.y>=0 and screenPos.x<client.screenwidth() and screenPos.y<client.screenheight() --on screen?
	then
		if active
		then
			gui.text(screenPos.x, screenPos.y, index, null, "green");
		else
			gui.text(screenPos.x, screenPos.y, index, null, "red");
		end
	else
		if active
		then
			acString=acString .. index .. ", ";
		end
	end
	return acString;
end

--TODO: separate variables by how many times they needs to be refreshed?
--split by update/draw?
--better form management (ask adelikat?)

--borderWidth, camPos, camI and adr are global because they are read frequently!
--initialize camera / window values (assuming window is not resized)
local winSize={width=800, height=480}; --only needed to fix drawing past the game window
borderWidth={left=86, right=74}; --yes, border left > border right

--initialize camera data
camPos={x=0, y=0};
local camPrevious={x=0, y=0};
camI={x=0, y=0};

adr=0x80000000;

--PERSISTENT MAP/TILE DATA
local tSizeCam={width=16, height=16}; --tile size in game coordinates
local tCount={x=20, y=15}; --20*15 tiles are on camera each time
--on screen sizes
local tSizeScreen={width=32, height=32};

--initialize verbose state
local verboseMode=false;

--PERSISTENT EVENT DATA
local evSize=112;
local staticHitbox=0x1c1a94;

local form=forms.newform("RaymanMap");
local mapBox=forms.checkbox(form, "Draw map", 5, 0); --TODO: checked by default?!
local eventBox=forms.checkbox(form, "Draw events", 5, 30);
local verboseBox=forms.checkbox(form, "Verbose (map)", 5, 60);

memory.usememorydomain("MainRAM");

while true do
	if memory.readbyte(0x1cee81)==1 --only draw if in a level
	then
		verboseMode=forms.ischecked(verboseBox);
		
		--camera data
		camPos={x=memory.read_u16_le(0x1f84b8), y=memory.read_u16_le(0x1f84c0)};
		--interpolate camera (will be added to x, y coordinates)
		camI={x=(camPos.x - camPrevious.x)*3, y=(camPos.y - camPrevious.y)*3}; --3 is just a magic constant that happened to work for me, but it might not work elsewhere
		
		if forms.ischecked(mapBox)
		then
			drawMap(winSize, tSizeCam, tCount, tSizeScreen, verboseMode);
		end
		
		if forms.ischecked(eventBox)
		then
			local startEv=memory.read_u32_le(0x1d7ae0)-adr;
			local size=memory.readbyte(0x1d7ae0+4); --number of events
			
			local activeIndex=0x1e5428; --current index in the list of active events located here
			local acString="offscreen (active): ";
			
			for i=0, size-1 --loop through events
			do
				local current=startEv+evSize*i;
				
				local pos={x=memory.read_s16_le(current+0x1c), y=memory.read_s16_le(current+0x1c+2)};
				
				--checks if the event is in the active list
				local active=false;
				if i==memory.readbyte(activeIndex)
				then
					active=true;
					activeIndex=activeIndex+2;
				end
				
				local gamePos=gameToScreen(pos.x, pos.y);
				local screenPos={x=client.transformPointX(gamePos.x), y=client.transformPointY(gamePos.y)}; --translate game position to screen position
				--draws onscreen events as such, returns offscreen events into acString
				acString=drawIndex(i, screenPos, active, acString);
				
				drawEvents(current, pos, staticHitbox);
			end
			gui.text(0, 0, acString, null, "green");
		end
	end
	-- previous camera data to determine the camera speed
	camPrevious.x=camPos.x;
	camPrevious.y=camPos.y;
	
	-- advance frame
	emu.frameadvance();
end
