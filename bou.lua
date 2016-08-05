---------------------------------------------------------------------------------
--
-- scene.lua
--
---------------------------------------------------------------------------------

local sceneName = ...

local composer = require( "composer" )
local gr3
if(tonumber(grade) == 3)then
	gr3 = require("g3")
elseif(tonumber(grade) == 4)then
	gr3 = require("gr4")
elseif(tonumber(grade) == 5)then
	gr3 = require("gr5")
elseif(tonumber(grade) == 6)then
	gr3 = require("gr6")
elseif(tonumber(grade) == 7)then
 gr3 = require("gr7")
end
local grTotal = gr3.total()
-- Load scene with same root filename as this file
local scene = composer.newScene( sceneName )

---------------------------------------------------------------------------------
local xInset,yInset = display.contentWidth / 20 , display.contentHeight / 20
local word =""
local xanderGroup = display.newGroup()
local vowels = {"a","e","i","o","u","y"}
local colors ={{51/255, 204/255, 51/255},
{0/255, 153/255, 255/255},
{255/255, 153/255, 51/255},
{255/255, 255/255, 51/255},
{204/255, 102/255, 255/255}
}
local keyboard = nil
local began
local prevWords = {}
local canvas ={}
local pieces = {}
local goingHome = false
local mpieces = {}
local tospell = {}
local counter = 1
local wordsGroup = display.newGroup()
local linesGroup = display.newGroup()
local bouGroup = display.newGroup()
local playersList = getPlayers()
local tick
local wordSound
local syllableSound
local wordChannel
local lookingFor
local isPlaying = false
local wordComplete = false
local wordpos = 34
local firstCorrect = true
local range = 10
local developerMode = false
local function gotoHome(event)
	--composer.gotoScene("menu")
	
	print(isPlaying)
	--if(isPlaying)then
	audio.stop()
		
	isPlaying = false
	playersList[cur].grade = grade
	playersList[cur].correct = correct
	playersList[cur].incorrect = incorrect
	addAndSavePlayers(playersList)
	--end
	goingHome = true
	transition.to(menuGroup,{time = 100, alpha = 0,onComplete =function() 
			transition.to(menuGroup,{time = 100, alpha = 1})
			end})
	transition.to(bouGroup,{time=500,y =  -2*display.contentHeight,onComplete = function() 
	transition.to(bouGroup,{time=500,y =  0,onComplete = function() 
	
	end})
	
	end})
	composer.gotoScene("menu",{time = 500,effect="fromBottom"}) 
	
	return true
end

local function getNextWord()
	local r 
	local word 
	local check = true
	while(check)do
		check = false
		r = math.random(grTotal )
		--wordpos=wordpos+1
		--print(wordpos)
		word = gr3.getWord(r)
		
		if(string.len(word)<3 or string.len(word)>14) then
				print("size")
				check =true
		end
		for i=1,#prevWords do
			if word == prevWords[i] then
				print("prev")
				check =true
			end
		end
	end
	
	--word = string.gsub( word, "%-","")
	--word = string.lower( word )
	if(#prevWords < 5) then
		prevWords[#prevWords+1] = word
	else
		prevWords = {}
		prevWords[#prevWords+1]= word
		
	end
	return word
end

local function hasCollided( obj1, obj2 )
    if ( obj1 == nil ) then  -- Make sure the first object exists
        return false
    end
    if ( obj2 == nil ) then  -- Make sure the other object exists
        return false
    end
 
    local left = obj1.contentBounds.xMin <= obj2.contentBounds.xMin and obj1.contentBounds.xMax >= obj2.contentBounds.xMin
    local right = obj1.contentBounds.xMin >= obj2.contentBounds.xMin and obj1.contentBounds.xMin <= obj2.contentBounds.xMax
    local up = obj1.contentBounds.yMin <= obj2.contentBounds.yMin and obj1.contentBounds.yMax >= obj2.contentBounds.yMin
    local down = obj1.contentBounds.yMin >= obj2.contentBounds.yMin and obj1.contentBounds.yMin <= obj2.contentBounds.yMax
 
    return (left or right) and (up or down)
end
local function isConsonant(letter)
	local cons = true
	for i=1,#vowels do
		if(letter == vowels[i] )then
			cons =false
		end
	end
	return cons
end
local function splitDoubleConsonants(w)
	local doubleC = false
	local split1 =""
	local split2 =""
	--print(w)
	local l = string.len(w) - 1
	for i = 1,l do
		if(isConsonant(w:sub(i,i)) and isConsonant(w:sub(i+1,i+1)))then
			split1 = w:sub(1,i)
			split2 = w:sub(i+1,string.len(w))
			return split1,split2
		end
	end
	
	-- if(isConsonant(w:sub(1,1))==false)then
		-- if(l<=2) then
			-- return
		-- end
		-- for i = 2,l do
			-- if(isConsonant(w:sub(i,i)) and isConsonant(w:sub(i+1,i+1)))then
				-- split1 = w:sub(1,i)
				-- split2 = w:sub(i+1,string.len(w))
				-- return split1,split2
			-- end
		-- end
	-- else	
		-- if(l<=3) then
			-- return
		-- end
		-- for i = 3,l do
			-- if(isConsonant(w:sub(i,i)) and isConsonant(w:sub(i+1,i+1)))then
				-- split1 = w:sub(1,i)
				-- split2 = w:sub(i+1,string.len(w))
				-- return split1,split2
			-- end
		-- end
	-- end
	
end
local function splitFirstVowel(w)
	--print(w)
	local fVowel = false
	local split1 =""
	local split2 =""
	local l = string.len(w)-1
	for i = 1,l do
		if(isConsonant(w:sub(i,i))==false)then
			split1 = w:sub(1,i)
			split2 = w:sub(i+1,string.len(w))
			return split1,split2
		end
	end
end
local function splitCheck(splitWord)
	
	if(string.len(splitWord)<4)then
		print(splitWord)
		pieces[#pieces+1]=splitWord
	else
		local s1,s2 = splitDoubleConsonants(splitWord)
		if(s1 ~= nil and s2 ~= nil)then
			
			splitCheck(s1)
			splitCheck(s2)
		else
			--split on first vowel
			local s1,s2 = splitFirstVowel(splitWord)
			if(s1 ~= nil and s2 ~= nil)then
				splitCheck(s1)
				splitCheck(s2)
			end
		end
	end
end

local function drawLines()
	linesGroup.anchorChildren = true
	linesGroup.anchorX = 0.5
	linesGroup.anchorY = 0
	linesGroup.x = display.contentWidth / 2
	linesGroup.y = display.contentHeight - yInset *5.5
	
	local i =1
	for k=1,#pieces do
		
		local part = pieces[k]
		local wordSize = string.len(part)
		
		for j=1,wordSize do
			
			local dash = display.newLine(i*(xInset),0, i*(xInset) + 15,0)
			dash:setStrokeColor(255/255, 51/255, 204/255)
			dash.strokeWidth = 2
			linesGroup:insert(dash)
			local options = 
			{
				--parent = textGroup,
				text = part:sub(j,j),     
				--x = 0,
				--y = 200,
				--width = 128,     --required for multi-line and alignment
				font = "TeachersPet",   
				fontSize = 28,
				align = "right"  --new alignment parameter
			}

			local myText = display.newText( options )
			myText.anchorX =0
			myText.anchorY =0
			myText.alpha = 0
			myText.x = i*(xInset)
			myText.y = -yInset*2
			myText:setFillColor( 0, 0, 0 )
			myText.pos = k
			tospell[i] = myText
			--tospell[i].dashWidth = dash.contentWidth
			linesGroup:insert(tospell[i])
			i=i+1
		end
		
	end
	tick = display.newImage("icon8.png")
	tick.y = -yInset
	tick:scale((xInset/1.1)/tick.contentWidth,(xInset/1.1)/tick.contentWidth)
	tick.x = (string.len(word)+1)*xInset + 15
	tick.alpha = 0
	linesGroup:insert(tick)
end
local function graduate()
	if(keyboard~=nil)then
		keyboard:destroy()
		keyboard = nil
	end
	local back = display.newRect(0,0,display.contentWidth,display.contentWidth)
	back.anchorX = 0
	back.anchorY = 0
	back:setFillColor(0)
	back.alpha = 0.4
	back:toFront()
	--back.isHitTestable = false
	local function block(event)
		return true
	end
	back:addEventListener("tap",block)
	bouGroup:insert(back)
	local xander = display.newImage("2-reverse.png")
	xander.x = display.contentWidth  / 2 - xInset * 2.2
	xander.y = display.contentHeight - yInset*12
	xander:scale(xInset*2.5/xander.contentWidth,xInset*2.5/xander.contentWidth)
	bouGroup:insert(xander)
	local nextGrade =  tonumber(grade)+1
	if(nextGrade<=7)then
	local options = 
	{
		--parent = row,
		text = "Veelsgeluk! Wil jy graad "..nextGrade.." doen?",     
		--x = 0,
		--y = 200,
		width = 180,     --required for multi-line and alignment
		font = "TeachersPet",   
		fontSize = 28,
		align = "left"  --new alignment parameter
	}
	
	
	confirmText = display.newText( options )
	--confirmText.anchorX =0.5
	--confirmText.anchorY =0
	confirmText.alpha = 1
	confirmText.x = display.contentWidth  / 2 + xInset * 3
	confirmText.y = display.contentHeight - yInset*15 - 10
	confirmText:setFillColor( 1, 1, 1 )
	local speechBox = display.newImage("speechbox.png")
	speechBox.x = display.contentWidth  / 2 + xInset * 3
	speechBox.y = display.contentHeight - yInset*15
	speechBox:scale((confirmText.width+20)/speechBox.contentWidth,(confirmText.height+25)/speechBox.contentHeight)
	bouGroup:insert(speechBox)
	bouGroup:insert(confirmText)
	
	local yes  = display.newRoundedRect(display.contentWidth / 2 - xInset*2 - 5,display.contentHeight - yInset*8,xInset*2,yInset*2,4)
	yes.anchorX = 0.5
	yes.anchorY = 0
	--yes.strokeWidth = 2
	yes:setFillColor( 255/255, 51/255, 204/255)
	--yes:setStrokeColor( 255/255, 51/255, 204/255 )
	bouGroup:insert(yes)
	local no  = display.newRoundedRect(display.contentWidth / 2 + xInset*2 + 5,display.contentHeight - yInset*8,xInset*2,yInset*2,4)
	no.anchorX = 0.5
	no.anchorY = 0
	--yes.strokeWidth = 2
	no:setFillColor( 255/255, 51/255, 204/255)
	--yes:setStrokeColor( 255/255, 51/255, 204/255 )
	bouGroup:insert(no)
	local options = 
	{
		--parent = row,
		text = "JA",     
		--x = 0,
		--y = 200,
		--width = 128,     --required for multi-line and alignment
		font = "TeachersPet",   
		fontSize = 28,
		align = "right"  --new alignment parameter
	}

	yesText = display.newText( options )
	yesText.anchorX =0.5
	yesText.anchorY =0
	yesText.alpha = 1
	yesText.x = display.contentWidth / 2 -xInset*2 - 5
	yesText.y = display.contentHeight - yInset*8+ 8
	yesText:setFillColor( 1, 1, 1 )
	bouGroup:insert(yesText)
	local options = 
	{
		--parent = row,
		text = "NEE",     
		--x = 0,
		--y = 200,
		--width = 128,     --required for multi-line and alignment
		font = "TeachersPet",   
		fontSize = 28,
		align = "right"  --new alignment parameter
	}

	noText = display.newText( options )
	noText.anchorX =0.5
	noText.anchorY =0
	noText.alpha = 1
	noText.x = display.contentWidth / 2 + xInset*2 + 5
	noText.y = display.contentHeight - yInset*8 + 8
	noText:setFillColor( 1, 1, 1 )
	bouGroup:insert(noText)
	local function cancel(event)
		----------------------------------------------------------------------------------------------------Maak graduation op kies speler beskikbaar
		
		
		back:removeSelf()
		back=nil
		confirmText:removeSelf()
		confirmText = nil
		yes:removeSelf()
		yes = nil
		no:removeSelf()
		no = nil
		yesText:removeSelf()
		yesText = nil
		noText:removeSelf()
		noText = nil
		xander:removeSelf()
		xander = nil
		speechBox:removeSelf()
		speechBox=nil
		
		
		return true
	end
	no:addEventListener("tap",cancel)
	local function confirmed(event)
		
		grade = tonumber(grade) + 1
		correct = 0
		transition.to(menuGroup,{time = 100, alpha = 0,onComplete =function() 
			transition.to(menuGroup,{time = 100, alpha = 1})
			end})
		transition.to(bouGroup,{time=500,y = 2*display.contentHeight,onComplete = function() 
		transition.to(bouGroup,{time=500,y = 0})
		end})
		composer.removeScene("bou")
		composer.gotoScene("menu",{time = 500,effect="fromTop"}) 
		list ={}
		addAndSaveIncorrectWords(list)
		
		playersList[cur].grade = grade
		playersList[cur].correct = correct
		playersList[cur].incorrect = 0
		addAndSavePlayers(playersList)
		if(keyboard~=nil)then
			keyboard:destroy()
			keyboard = nil
		end
		return true
	end
	
	yes:addEventListener("tap",confirmed)
	else
		local options = 
		{
			--parent = row,
			text = "Veelsgeluk! Kry ons Graad 8 - 12 Spelling App",     
			--x = 0,
			--y = 200,
			width = 180,     --required for multi-line and alignment
			font = "TeachersPet",   
			fontSize = 28,
			align = "left"  --new alignment parameter
		}
		
		
		confirmText = display.newText( options )
		--confirmText.anchorX =0.5
		--confirmText.anchorY =0
		confirmText.alpha = 1
		confirmText.x = display.contentWidth  / 2 + xInset * 3
		confirmText.y = display.contentHeight - yInset*15 - 10
		confirmText:setFillColor( 1, 1, 1 )
		local speechBox = display.newImage("speechbox.png")
		speechBox.x = display.contentWidth  / 2 + xInset * 3
		speechBox.y = display.contentHeight - yInset*15
		speechBox:scale((confirmText.width+20)/speechBox.contentWidth,(confirmText.height+25)/speechBox.contentHeight)
		bouGroup:insert(speechBox)
		bouGroup:insert(confirmText)
		local no  = display.newRoundedRect(display.contentWidth / 2 ,display.contentHeight - yInset*8,xInset*2,yInset*2,4)
		no.anchorX = 0.5
		no.anchorY = 0
		--yes.strokeWidth = 2
		no:setFillColor( 255/255, 51/255, 204/255)
		--yes:setStrokeColor( 255/255, 51/255, 204/255 )
		bouGroup:insert(no)
		local options = 
		{
			--parent = row,
			text = "OK",     
			--x = 0,
			--y = 200,
			--width = 128,     --required for multi-line and alignment
			font = "TeachersPet",   
			fontSize = 28,
			align = "right"  --new alignment parameter
		}

		noText = display.newText( options )
		noText.anchorX =0.5
		noText.anchorY =0
		noText.alpha = 1
		noText.x = display.contentWidth / 2 
		noText.y = display.contentHeight - yInset*8 + 8
		noText:setFillColor( 1, 1, 1 )
		bouGroup:insert(noText)
		local function cancel(event)
			----------------------------------------------------------------------------------------------------Maak graduation op kies speler beskikbaar
			
			
			back:removeSelf()
			back=nil
			confirmText:removeSelf()
			confirmText = nil
			no:removeSelf()
			no = nil
			
			noText:removeSelf()
			noText = nil
			xander:removeSelf()
			xander = nil
			speechBox:removeSelf()
			speechBox=nil
			
			
			return true
		end
		no:addEventListener("tap",cancel)
	end
end
local function Next()

		audio.stop()
		wordSound = nil
		syllableSound = nil
		isPlaying = false
		word = getNextWord()
		
		
		isPlaying = true
		timer.performWithDelay(500,function()
		if(goingHome == false)then
		
		wordSound = audio.loadSound( "sound/graad"..grade.."/"..word..".mp3" )
		syllableSound = audio.loadSound( "sound/graad"..grade.."/"..word.."s.mp3" )
		wordChannel = audio.play( wordSound ,{onComplete= function()
		
		audio.play( syllableSound ,{onComplete= function()
		isPlaying = false end})
		
		end})
		end
		end)
		--print(word)
		local s1,s2 = splitDoubleConsonants(word)
		
		if(s1 ~= nil and s2 ~= nil)then
			
			splitCheck(s1)
			splitCheck(s2)
		else
			--split on first vowel
			local s1,s2 = splitFirstVowel(word)
			if(s1 ~= nil and s2 ~= nil)then
				splitCheck(s1)
				splitCheck(s2)
			end
		end
		drawLines()
		
		local matchGroup = display.newGroup()
		wordsGroup:insert(matchGroup)
		local prevX = 0
		local c = math.random(4)
		for i=1,#pieces do
			
			local pieceGroup = display.newGroup()
			local r = math.random(5)
			
			local options = 
			{
				--parent = textGroup,
				text = pieces[i],     
				--x = 0,
				--y = 200,
				--width = 128,     --required for multi-line and alignment
				font = "TeachersPet",   
				fontSize = 48,
				align = "right"  --new alignment parameter
			}

			myText = display.newText( options )
			myText.anchorX =0
			myText.anchorY =0
			myText.alpha = 1
			myText:setFillColor( 0, 0, 0 )
			
			local canvasCollided = false
			while  canvasCollided==false do
				print("fitting")
				canvasCollided = true
				local xPos = math.random(4)
				local yPos =  math.random(4)
				myText.x =xInset*xPos*3 + xInset
				myText.y = yInset*yPos*3-yInset*1.5
				local length = myText.contentWidth + 20
				local height = myText.contentHeight + 20
				local rect = display.newRoundedRect(myText.x-5,myText.y +height/2,length+ 10,height+10,3)
				for l=1,#canvas do
					
					if(hasCollided(rect,canvas[l]))then
						
						canvasCollided = false
					end
				end
				rect:removeSelf()
			end
			local function myTap(event)
				sX = event.target.x
				print(event.target.t)
				--print(tospell[counter].text)
				local lookingFor = ""
				for i=1,#tospell do
					if(tospell[i].pos==counter)then
						lookingFor = lookingFor..tospell[i].text
					end
				end
				if(lookingFor == event.target.t)then
					event.target.alpha = 0
					for i=1,#tospell do
						if(counter==tospell[i].pos)then
							tospell[i].alpha = 1
						end
					end
					if(counter == #pieces)then
					
						tick.alpha = 1
						wordComplete = true
						timer.performWithDelay(300,function()
						linesGroup:removeSelf()
						linesGroup=nil
						linesGroup = display.newGroup()
						wordsGroup:removeSelf()
						wordsGroup = nil
						wordsGroup = display.newGroup()
						bouGroup:insert(wordsGroup)
						bouGroup:insert(linesGroup)
						pieces = {}
						mpieces ={}
						tospell = {}
						canvas ={}
						--Confirm grade is less then 7
						if(tonumber(grade) < 7)then
							--Can add to score
							if(tonumber(correct)<=100)then
								if(firstCorrect)then
								correct = correct + 1
								end
								--isPlaying = true
								firstCorrect = true
							end
							--Score has been reached can graduate
							if(tonumber(correct)==100)then
								graduate()
							
							
							end
							--User has chose to continue on this level
							if(tonumber(correct)>100)then
									correct = 100
							end
						else
							--Can add to score
							if(tonumber(correct)<=100)then
								if(firstCorrect)then
									correct = correct + 1
								end
								--isPlaying = true
								firstCorrect = true
							end
							--Score has been reached can graduate
							if(tonumber(correct)==100)then
								graduate()
							end
							--User has chose to continue on this level
							if(tonumber(correct)>100)then
									correct = 100
							end
						end
						
						Next()
						--isPlaying = true
						end)
						
						
						counter = 1
					else
						counter = counter + 1
					end
				else
					firstCorrect = false
					transition.to(event.target,{time =120 ,rotation= 1,x =  sX + 0.1,iterations = 3,onRepeat =function() 
						transition.to(event.target,{time =120 ,rotation = -1,x= sX - 0.10})
					end,onComplete =function() transition.to(event.target,{time =6,rotation = 0 ,x=sX}) end})
				end
				
				return true
			end
			
			--
			local function drag( event )
				if event.phase == "began" then
				collided = false
				began = true
				markX = event.target.x    -- store x location of object
				markY = event.target.y    -- store y location of object
				lookingFor = ""
				for i=1,#tospell do
					if(tospell[i].pos==counter)then
						lookingFor = lookingFor..tospell[i].text
					end
				end
				if(developerMode)then
				-------------------------------------------------------------------------------------------------------------------------------Determin correct drop area bounds
					for d = 1,#pieces do
						local yPos = linesGroup.y -yInset*1.5-- tospell[1].y
						local xPos = 0
						local stX = nil
						for i=1,#tospell do
								if(d==tospell[i].pos)then
									xPos = xPos + tospell[i].contentWidth + xInset/2
									if(stX == nil)then
										stX = linesGroup.x - (linesGroup.contentWidth / 2) + tospell[i].x - xInset/4
									end
								end
						end
						xPos = xPos + xInset
						-----------------------------------------------------------------------------------------------------------------------------------------------------------------
						-- print(" event.target.x" .. (event.x ))
						-- print(" event.target.y" .. event.y)
						-- print("stX :"..stX)
						-- print("stX + xPos = "..(stX + xPos))
						-- print(" event.target.x" .. event.target.x)
						-- print("yPos :"..yPos)
						-- print("xPos :"..xPos)
						-- print(lookingFor)
						local myRectangle = display.newRect(stX,yPos + yInset*2 ,xPos,yInset*4)
						myRectangle.strokeWidth = 3
						myRectangle:setFillColor( 0.5,0 )
						myRectangle:setStrokeColor( 1, 0, 0 )
						myRectangle:toFront()
						bouGroup:insert(myRectangle)
					end
				end
					display.getCurrentStage():setFocus( event.target )
				elseif event.phase == "moved" then
				
					if(began)then
					local x = (event.x - event.xStart) + markX
					local y = (event.y - event.yStart) + markY
					
					event.target.x, event.target.y = x, y    -- move object based on calculations above
					end
				elseif event.phase == "ended" or event.phase == "cancelled" then
					event.target.alpha = 1
					began = false
					-------------------------------------------------------------------------------------------------------------------------------Determin correct drop area bounds
					local yPos = linesGroup.y -yInset*1.5 --+ tospell[1].y
					local xPos = 0
					local stX = nil
					local pLen = 0
					for i=1,#tospell do
							if(counter==tospell[i].pos)then
								xPos = xPos + tospell[i].contentWidth + xInset/2
								pLen = pLen + 1
								if(stX == nil)then
									stX = linesGroup.x - (linesGroup.contentWidth / 2) + tospell[i].x - xInset/4
								end
							end
					end
					if(pLen == 1)then
						stX = stX - xInset/4
					end
					xPos = xPos + xInset
					-----------------------------------------------------------------------------------------------------------------------------------------------------------------
					-- print(" event.target.x" .. (event.x ))
					-- print(" event.target.y" .. event.y)
					-- print("stX :"..stX)
					-- print("stX + xPos = "..(stX + xPos))
					-- print(" event.target.x" .. event.target.x)
					-- print("yPos :"..yPos)
					-- print("xPos :"..xPos)
					-- print(lookingFor)
					-- local myRectangle = display.newRect(stX,yPos + yInset*2 ,xPos,yInset*4)
					-- myRectangle.strokeWidth = 3
					-- myRectangle:setFillColor( 0.5,0 )
					-- myRectangle:setStrokeColor( 1, 0, 0 )
					-- myRectangle:toFront()
					-- bouGroup:insert(myRectangle)
					local bool =  event.x-range < stX + xPos+range and event.x+range > stX - xInset/2 - range and event.y+range > yPos + yInset-range and event.y-range< yPos + yInset*5 + range 
					print(bool)
					if( bool) then
					-- if(event.target.pos~= nil)then
						-- if(hasCollided(event.target,event.target.rectangle))then
							-- event.target.alpha = 0
							-- tospell[event.target.pos].alpha = 1
							-- collided = true
					
						-- end
					
						
					-- end
					if(lookingFor == event.target.t)then
						event.target.alpha = 0
						for i=1,#tospell do
							if(counter==tospell[i].pos)then
								tospell[i].alpha = 1
							end
						end
						if(counter == #pieces)then
						
							tick.alpha = 1
							wordComplete = true
							timer.performWithDelay(300,function()
							linesGroup:removeSelf()
							linesGroup=nil
							linesGroup = display.newGroup()
							wordsGroup:removeSelf()
							wordsGroup = nil
							wordsGroup = display.newGroup()
							bouGroup:insert(wordsGroup)
							bouGroup:insert(linesGroup)
							pieces = {}
							mpieces ={}
							tospell = {}
							canvas ={}
							--Confirm grade is less then 7
							if(tonumber(grade) < 7)then
								--Can add to score
								if(tonumber(correct)<=100)then
									if(firstCorrect)then
									correct = correct + 1
									end
									--isPlaying = true
									firstCorrect = true
								end
								--Score has been reached can graduate
								if(tonumber(correct)==100)then
									graduate()
								
								
								end
								--User has chose to continue on this level
								if(tonumber(correct)>100)then
										correct = 100
								end
							else
								--Can add to score
								if(tonumber(correct)<=100)then
									if(firstCorrect)then
										correct = correct + 1
									end
									--isPlaying = true
									firstCorrect = true
								end
								--Score has been reached can graduate
								if(tonumber(correct)==100)then
									graduate()
								end
								--User has chose to continue on this level
								if(tonumber(correct)>100)then
										correct = 100
								end
							end
							
							Next()
							--isPlaying = true
							end)
							
							
							counter = 1
						else
							counter = counter + 1
						end
					else
						firstCorrect = false
						transition.to(event.target,{time = 500,x=markX,y=markY})
						-- sX = event.target.x
						-- transition.to(event.target,{time =120 ,rotation= 1,x =  sX + 0.1,iterations = 3,onRepeat =function() 
							-- transition.to(event.target,{time =120 ,rotation = -1,x= sX - 0.10})
						-- end,onComplete =function() transition.to(event.target,{time =6,rotation = 0 ,x=sX}) end})
					end
				else
					transition.to(event.target,{time = 500,x=markX,y=markY})
				end
					if(event.x > xInset*18 or event.x < xInset * 2)then
							transition.to(event.target,{time = 500,x=markX,y=markY})
						
					elseif(event.y>yInset*15 or event.y < yInset)then
							transition.to(event.target,{time = 500,x=markX,y=markY})
					end
					display.getCurrentStage():setFocus(nil)
				end
				
				return true
			end
			if(c<5)then
				c=c+1
				color =unpack(colors,c)
			else
				c = 1
				color =unpack(colors,c)
			end
			local length = myText.contentWidth
			local height = myText.contentHeight
			local rect = display.newRoundedRect(myText.x-5,myText.y +height/2,length+ 10,height+10,3,3)
			rect.anchorX =0
			rect.anchorY = 0.5
			rect:setFillColor(color[1],color[2],color[3])
			pieceGroup:insert(rect)
			pieceGroup:insert(myText)
			pieceGroup.pos = i
			pieceGroup.t = pieces[i]
			canvas[#canvas+1] = rect 
			wordsGroup:insert(pieceGroup)
			
			pieceGroup:addEventListener( "touch", drag )
		end
end
function scene:create( event )
    sceneGroup = self.view

    -- Called when the scene's view does not exist
    -- 
    -- INSERT code here to initialize the scene
    -- e.g. add display objects to 'sceneGroup', add touch listeners, etc
	local bg = display.newImage("background.png")
	    bg.anchorX =0
	    bg.anchorY =0
	    bg:setFillColor(1)
	    sceneGroup:insert(bg)
		
		local xander = display.newImage("1.png")
		xander.x = display.contentWidth - xInset*2
		xander.y = display.contentHeight/2 - yInset*2
		xander:scale(xInset*2.5/xander.contentWidth,xInset*2.5/xander.contentWidth)
		xanderGroup:insert(xander)
		
		local options = 
		{
			--parent = textGroup,
			text = "Bou die regte woord.",     
			--x = 0,
			--y = 200,
			--width = 128,     --required for multi-line and alignment
			font = "TeachersPet",   
			fontSize = 18,
			align = "right"  --new alignment parameter
		}
		
	    local myText = display.newText( options )
		myText.anchorY =0.5
		myText.alpha = 1
		myText.x = display.contentWidth - xInset*2.5
		myText.y = display.contentHeight/2 -yInset*7- 4.5
		myText:setFillColor( 1, 1, 1 )
		local speechBox = display.newImage("speechbox.png")
		speechBox.x = display.contentWidth - xInset*2.5
		speechBox.y = display.contentHeight/2 -yInset*7
		speechBox:scale(-(myText.contentWidth+10)/speechBox.contentWidth,yInset*2/speechBox.contentHeight)
		xanderGroup:insert(speechBox)
		xanderGroup:insert(myText)
		timer.performWithDelay(2000,function() transition.to(xanderGroup,{time = 500,alpha = 0})end)
		bouGroup:insert(xanderGroup)
		menuGroup = display.newGroup()
		local mCircle = display.newImage("home.png")
		mCircle:scale(xInset*1.5/mCircle.width,xInset*1.5/mCircle.width)
		--mCircle:setFillColor( 255/255, 51/255, 204/255 )
		menuGroup:insert(mCircle)
		menuGroup.x =  xInset*1.5
		menuGroup.y =  yInset*2
		menuGroup:addEventListener( "tap", gotoHome )
		bouGroup:insert(menuGroup)
		local soundButton = display.newImage("Sound.png")
		soundButton:scale(xInset*1.5/soundButton.width,xInset*1.5/soundButton.width)
		soundButton.x = xInset*1.5
		soundButton.y = display.contentHeight - yInset*2
		local function playWord(event)
			transition.to(soundButton,{time = 100, alpha = 0,onComplete =function() 
			transition.to(soundButton,{time = 100, alpha = 1})
			end})
			if(isPlaying==false)then
				wordSound = audio.loadSound( "sound/graad"..grade.."/"..word..".mp3" )
				syllableSound = audio.loadSound( "sound/graad"..grade.."/"..word.."s.mp3" )
				isPlaying = true
				wordChannel = audio.play( wordSound ,{onComplete=function()
				audio.play( syllableSound ,{onComplete=function()
				isPlaying=false end})
				end})
			end
			return true
		end
		
		soundButton:addEventListener("tap",playWord)
		bouGroup:insert(soundButton)
		
		Next()
	    bouGroup:insert( wordsGroup )
		bouGroup:insert( linesGroup )
		sceneGroup:insert(bouGroup)
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        -- Called when the scene is still off screen and is about to move on screen
        
    elseif phase == "did" then
        -- Called when the scene is now on screen
        -- 
        -- INSERT code here to make the scene come alive
        -- e.g. start timers, begin animation, play audio, etc
        
        -- we obtain the object by id from the scene's object hierarchy
		--math.randomseed( os.time() )
		goingHome = false
		
		if(xanderGroup.alpha==0)then
			xanderGroup.alpha = 1
			timer.performWithDelay(2000,function() transition.to(xanderGroup,{time = 500,alpha = 0})end)
		end
		if(isPlaying==false)then
			timer.performWithDelay(500,function()
			wordSound = audio.loadSound("sound/graad"..grade.."/"..word..".mp3" )
			syllableSound = audio.loadSound("sound/graad"..grade.."/"..word.."s.mp3" )
			isPlaying = true
			wordChannel = audio.play( wordSound ,{onComplete=function()
			audio.play( syllableSound ,{onComplete=function()
			isPlaying=false end})
			end})
			end)
		end
    end 
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if event.phase == "will" then
        -- Called when the scene is on screen and is about to move off screen
        --
        -- INSERT code here to pause the scene
        -- e.g. stop timers, stop animation, unload sounds, etc.)
    elseif phase == "did" then
        -- Called when the scene is now off screen
		
			audio.stop()
			isPlaying = false
			--addAndSaveIncorrectWords(list)
			playersList[cur].grade = grade
			playersList[cur].correct = correct
			playersList[cur].incorrect = incorrect
			addAndSavePlayers(playersList)
		
    end 
end


function scene:destroy( event )
    local sceneGroup = self.view

    -- Called prior to the removal of scene's "view" (sceneGroup)
    -- 
    -- INSERT code here to cleanup the scene
    -- e.g. remove display objects, remove touch listeners, save state, etc
	--addAndSaveIncorrectWords(list)
	playersList[cur].grade = grade
	playersList[cur].correct = correct
	playersList[cur].incorrect = incorrect
	addAndSavePlayers(playersList)
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
