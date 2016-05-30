---------------------------------------------------------------------------------
--
-- scene.lua
--
---------------------------------------------------------------------------------

local sceneName = ...

local composer = require( "composer" )
local gr3 = require("g3")
local widget = require( "widget" )
require("onScreenKeyboard")
local k
local menuGroup
local wordTyped =""
local myText
local tospell = {}
local counter = 1

-- Load scene with same root filename as this file
local scene = composer.newScene( sceneName )

---------------------------------------------------------------------------------
local xInset,yInset = display.contentWidth / 20 , display.contentHeight / 20
local plaersList

function scene:create( event )
    local sceneGroup = self.view

    -- Called when the scene's view does not exist
    -- 
    -- INSERT code here to initialize the scene
    -- e.g. add display objects to 'sceneGroup', add touch listeners, etc
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
	    plaersList = getPlayers()
	
        -- local bg = display.newRect(0,0,display.contentWidth,display.contentHeight)
	    -- bg.anchorX =0
	    -- bg.anchorY =0
	    -- bg:setFillColor(255/255, 51/255, 204/255)
	    -- sceneGroup:insert(bg)
		local bg = display.newImage("background.png")
	    bg.anchorX =0
	    bg.anchorY =0
		bg:scale(display.contentWidth/bg.contentWidth,display.contentHeight/bg.contentHeight)
		sceneGroup:insert(bg)
		local options = 
		{
			--parent = row,
			text = "Kies 'n Speler",     
			--x = 0,
			--y = 200,
			--width = 128,     --required for multi-line and alignment
			font = "TeachersPet",   
			fontSize = 32,
			align = "right"  --new alignment parameter
		}

		local Text = display.newText( options )
		Text.anchorX =0.5
		Text.anchorY =0
		Text.alpha = 1
		Text.x = display.contentWidth  / 2
		Text.y = yInset
		Text:setFillColor( 0, 0, 0 )
		sceneGroup:insert(Text)
		local function gotoHome(event)
			composer.removeScene("player")
			composer.gotoScene("menu")
			return true
		end
		local menuGroup = display.newGroup()
		local mCircle = display.newImage("homeI.png")
		mCircle:scale(xInset*2/mCircle.width,xInset*2/mCircle.width)
		--mCircle:setFillColor( 255/255, 51/255, 204/255 )
		menuGroup:insert(mCircle)
		menuGroup.x =  xInset*2
		menuGroup.y =  yInset*2
		menuGroup:addEventListener( "tap", gotoHome )
		sceneGroup:insert(menuGroup)
		local function onRowRender( event )

			-- Get reference to the row group
			local row = event.row

			-- Cache the row "contentWidth" and "contentHeight" because the row bounds can change as children objects are added
			local rowHeight = row.contentHeight
			local rowWidth = row.contentWidth
			if(#plaersList>=1)then
				local gr3
				local grTotal
				if(plaersList[row.index].grade == "3")then
					gr3 = require("g3")
					grTotal = gr3.total()+53
				else
					gr3 = require("gr2")
					grTotal = gr3.total()+50
				end
				 --+ math.round(gr3.total()/2)
				
				local rowBox = display.newRoundedRect(row,0,0,xInset*18,rowHeight-rowHeight/10,2)
				rowBox.anchorY = 0
				rowBox.anchorX = 0
				rowBox.y = rowHeight/5
				rowBox.x = xInset
				local function selectPlayer(event)
					player = plaersList[row.index].name
					grade =plaersList[row.index].grade
					correct = plaersList[row.index].correct
					incorrect = plaersList[row.index].incorrect
					
					print(player)
					composer.removeScene("spel")
					composer.removeScene("wordsearch")
					composer.removeScene("bou")
					composer.removeScene("flash")
					cur = row.index
					composer.gotoScene("menu",{time = 500,effect = "fade"})
					return true
				end
				rowBox:addEventListener("tap",selectPlayer)
				local rowTitle = display.newText( row,plaersList[row.index].name, 0, 0,"TeachersPet", 24 )
				rowTitle:setFillColor( 0,0,0,0.5 )
		
				--Align the label left and vertically centered
				rowTitle.anchorX = 0
				rowTitle.anchorY = 0
				rowTitle.x = xInset*2
				rowTitle.y = rowHeight * 0.5
				local rowTitle = display.newText( row,"Graad: "..plaersList[row.index].grade , 0, 0,"TeachersPet", 24 )
				rowTitle:setFillColor( 0,0,0,0.5  )
				
				--Align the label left and vertically centered
				rowTitle.anchorX = 0
				rowTitle.anchorY = 0
				rowTitle.x = display.contentWidth/2 - xInset*2
				rowTitle.y = rowHeight * 0.5
				if(tonumber(plaersList[row.index].correct) == 100 )then
					local graduate = display.newImage(row,"grad2.png")
					graduate:scale(rowHeight*0.7/graduate.width,rowHeight*0.7/graduate.width)
					graduate.anchorX = 0
					--graduate.anchorY = 0
					graduate.x = xInset*12
					graduate.y = rowHeight *0.65
					local function grad(event)
						
						plaersList[row.index].grade = tonumber(grade)+1
						plaersList[row.index].correct = 0
						plaersList[row.index].incorrect = 0
						
						if(cur ~=  row.index)then
						
						cur = row.index
						
						end
						player = plaersList[row.index].name
						grade = plaersList[row.index].grade
						correct = plaersList[row.index].correct
						incorrect = 0
						list ={}
						addAndSaveIncorrectWords(list)
						addAndSavePlayers(plaersList)
						composer.removeScene("player")
						composer.gotoScene("player")
					return true
					end
					graduate:addEventListener("tap",grad)
				else
					local rowTitle = display.newText( row,plaersList[row.index].correct.." / ".. "100", 0, 0,"TeachersPet", 24 )
					rowTitle:setFillColor( 0,0,0,0.5)

					--Align the label left and vertically centered
					rowTitle.anchorX = 0
					rowTitle.anchorY = 0
					rowTitle.x = xInset*12
					rowTitle.y = rowHeight *0.5
					--Draw small pink line
				end
				
				local deleteRect = display.newRoundedRect(row,0,0,xInset* 2,rowHeight-rowHeight/10,0.5)
				deleteRect.anchorY = 0
				deleteRect.anchorX = 0
				deleteRect.x = display.contentWidth - xInset* 3
				deleteRect.y = rowHeight/5
				deleteRect:setFillColor(0.8)
				local deleteTick = display.newImage(row,"icontick2.png")
				
				deleteTick.x = display.contentWidth - xInset* 2
				deleteTick.y = rowHeight * 0.7
				deleteTick:scale(0.8,0.8)
				
				local function delete(event)
					local back = display.newRect(0,0,display.contentWidth,display.contentWidth)
					back.anchorX = 0
					back.anchorY = 0
					back:setFillColor(0)
					back.alpha = 0.4
					--back.isHitTestable = false
					local function block(event)
						return true
					end
					back:addEventListener("tap",block)
					sceneGroup:insert(back)
					local xander = display.newImage("2-reverse.png")
					xander.x = display.contentWidth  / 2 - xInset * 2.2
					xander.y = display.contentHeight - yInset*12
					xander:scale(xInset*2.5/xander.contentWidth,xInset*2.5/xander.contentWidth)
					sceneGroup:insert(xander)
					
					
					local options = 
					{
						--parent = row,
						text = "Is jy seker jy wil die speler verwyder?",     
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
					sceneGroup:insert(speechBox)
					sceneGroup:insert(confirmText)
					local yes  = display.newRoundedRect(display.contentWidth / 2 - xInset*2 - 5,display.contentHeight - yInset*8,xInset*2,yInset*2,4)
					yes.anchorX = 0.5
					yes.anchorY = 0
					--yes.strokeWidth = 2
					yes:setFillColor( 255/255, 51/255, 204/255)
					--yes:setStrokeColor( 255/255, 51/255, 204/255 )
					sceneGroup:insert(yes)
					local no  = display.newRoundedRect(display.contentWidth / 2 + xInset*2 + 5,display.contentHeight - yInset*8,xInset*2,yInset*2,4)
					no.anchorX = 0.5
					no.anchorY = 0
					--yes.strokeWidth = 2
					no:setFillColor( 255/255, 51/255, 204/255)
					--yes:setStrokeColor( 255/255, 51/255, 204/255 )
					sceneGroup:insert(no)
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
					sceneGroup:insert(yesText)
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
					sceneGroup:insert(noText)
					local function cancel(event)
						back:removeSelf()
						back = nil
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
						local destDir = system.DocumentsDirectory  -- Location where the file is stored
						local result, reason = os.remove( system.pathForFile( plaersList[row.index].name..".txt", destDir ) )

						if result then
						   print( "File removed" )
						else
						   print( "File does not exist", reason )  --> File does not exist    apple.txt: No such file or directory
						end
						table.remove(plaersList,row.index)
						addAndSavePlayers(plaersList)
						if(cur ==  row.index)then
							plaersList = getPlayers()
							if(plaersList[1]~=nil)then
							player = plaersList[1].name
							grade = plaersList[1].grade
							correct = plaersList[1].correct
							incorrect = plaersList[1].incorrect
							cur = 1
							end
						end
						composer.removeScene("player")
						composer.gotoScene("player")
						return true
					end
					
					yes:addEventListener("tap",confirmed)
					return true
				end
				deleteRect:addEventListener("tap",delete)
			end
		end
		-- Create the widget
		local tableView = widget.newTableView(
			{
				--left = 200,
				top = yInset*3.5,
				height = display.contentHeight - yInset*6,
				width = display.contentWidth,
				onRowRender = onRowRender,
				onRowTouch = onRowTouch,
				listener = scrollListener,
				hideBackground = true
			}
		)

		-- Insert 40 rows
		for i = 1, #plaersList do
			-- Insert a row into the tableView
			tableView:insertRow({
			rowHeight = yInset*3,
			rowColor = { default={0.8,0.8,0.8,0} },
            lineColor =  { 1, 0, 0,0 }
			})
		end
		sceneGroup:insert(tableView)
		local function addPlayer(event)
			menuGroup:removeEventListener("tap", addPlayer)
			
		
			local back =display.newImage("background.png")--display.newRect(0,0,display.contentWidth,display.contentWidth) --
			
			back.anchorX =0
			back.anchorY =0
			back:scale(display.contentWidth/back.contentWidth,display.contentHeight/back.contentHeight)
			--back.anchorX = 0
			--back.anchorY = 0
			--back:setFillColor(1)
			--back.alpha = 0.4
			local function block(event)
						return true
					end
			back:addEventListener("tap",block)
			sceneGroup:insert(back)
			local options = 
			{
				--parent = row,
				text = "Kies jou graad",     
				--x = 0,
				--y = 200,
				--width = 128,     --required for multi-line and alignment
				font = "TeachersPet",   
				fontSize = 28,
				align = "right"  --new alignment parameter
			}

			myText = display.newText( options )
			myText.anchorX =0.5
			myText.anchorY =0
			myText.alpha = 1
			myText.x = display.contentWidth  / 2
			myText.y = yInset
			myText:setFillColor( 0 )
			sceneGroup:insert(myText)
			local curOption = nil
			local function customRadioButtonTap(event)
				if(curOption.gr~=event.target.gr)then
					curOption:setFillColor(0.7)
					event.target:setFillColor(255/255, 51/255, 204/255)
					curOption = event.target
				end
				return true
			end
			local option1 = display.newRoundedRect(xInset*3.5,yInset * 3,xInset*3,yInset*2,4)
			option1.anchorX = 0.5
			option1.anchorY = 0
			option1:setFillColor( 255/255, 51/255, 204/255)
			option1.gr = 3
			sceneGroup:insert(option1)
			curOption = option1
			option1:addEventListener("tap",customRadioButtonTap)
			local options = 
			{
				--parent = row,
				text = "3",     
				--x = 0,
				--y = 200,
				--width = 128,     --required for multi-line and alignment
				font = "TeachersPet",   
				fontSize = 26,
				align = "right"  --new alignment parameter
			}

			myText = display.newText( options )
			myText.anchorX =0.5
			myText.anchorY =0
			myText.alpha = 1
			myText.x = xInset*3.5
			myText.y = yInset * 3 + myText.contentHeight / 4
			myText:setFillColor(1)
			sceneGroup:insert(myText)
			local option2 = display.newRoundedRect(xInset*6.5 + 10,yInset * 3,xInset*3,yInset*2,4)
			option2.anchorX = 0.5
			option2.anchorY = 0
			option2:setFillColor( 0.7)
			option2.gr = 4
			sceneGroup:insert(option2)
			option2:addEventListener("tap",customRadioButtonTap)
			local options = 
			{
				--parent = row,
				text = "4",     
				--x = 0,
				--y = 200,
				--width = 128,     --required for multi-line and alignment
				font = "TeachersPet",   
				fontSize = 26,
				align = "right"  --new alignment parameter
			}

			myText = display.newText( options )
			myText.anchorX =0.5
			myText.anchorY =0
			myText.alpha = 1
			myText.x = xInset*6.5 + 10
			myText.y = yInset * 3 + myText.contentHeight / 4
			myText:setFillColor(1)
			sceneGroup:insert(myText)
			local option3 = display.newRoundedRect(xInset*9.5 + 20,yInset * 3,xInset*3,yInset*2,4)
			option3.anchorX = 0.5
			option3.anchorY = 0
			option3:setFillColor( 0.7)
			option3.gr = 5
			sceneGroup:insert(option3)
			option3:addEventListener("tap",customRadioButtonTap)
			local options = 
			{
				--parent = row,
				text = "5",     
				--x = 0,
				--y = 200,
				--width = 128,     --required for multi-line and alignment
				font = "TeachersPet",   
				fontSize = 26,
				align = "right"  --new alignment parameter
			}

			myText = display.newText( options )
			myText.anchorX =0.5
			myText.anchorY =0
			myText.alpha = 1
			myText.x = xInset*9.5 + 20
			myText.y = yInset * 3 + myText.contentHeight / 4
			myText:setFillColor(1)
			sceneGroup:insert(myText)
			local option4 = display.newRoundedRect(xInset*12.5 + 30,yInset * 3,xInset*3,yInset*2,4)
			option4.anchorX = 0.5
			option4.anchorY = 0
			option4:setFillColor( 0.7)
			option4.gr = 6
			sceneGroup:insert(option4)
			option4:addEventListener("tap",customRadioButtonTap)
			local options = 
			{
				--parent = row,
				text = "6",     
				--x = 0,
				--y = 200,
				--width = 128,     --required for multi-line and alignment
				font = "TeachersPet",   
				fontSize = 26,
				align = "right"  --new alignment parameter
			}

			myText = display.newText( options )
			myText.anchorX =0.5
			myText.anchorY =0
			myText.alpha = 1
			myText.x = xInset*12.5 + 30
			myText.y = yInset * 3 + myText.contentHeight / 4
			myText:setFillColor(1)
			sceneGroup:insert(myText)
			local option5 = display.newRoundedRect(xInset*15.5 + 40,yInset * 3,xInset*3,yInset*2,4)
			option5.anchorX = 0.5
			option5.anchorY = 0
			option5:setFillColor( 0.7)
			option5.gr = 7
			sceneGroup:insert(option5)
			option5:addEventListener("tap",customRadioButtonTap)
			local options = 
			{
				--parent = row,
				text = "7",     
				--x = 0,
				--y = 200,
				--width = 128,     --required for multi-line and alignment
				font = "TeachersPet",   
				fontSize = 26,
				align = "right"  --new alignment parameter
			}

			myText = display.newText( options )
			myText.anchorX =0.5
			myText.anchorY =0
			myText.alpha = 1
			myText.x = xInset*15.5 + 40
			myText.y = yInset * 3 + myText.contentHeight / 4
			myText:setFillColor(1)
			sceneGroup:insert(myText)
			
			local customeTextbox  = display.newRoundedRect(display.contentWidth / 2,display.contentHeight - yInset*14,xInset*10,yInset*2,4)
			customeTextbox.anchorX = 0.5
			customeTextbox.anchorY = 0
			customeTextbox.strokeWidth = 2
			customeTextbox:setFillColor( 1)
			customeTextbox:setStrokeColor( 255/255, 51/255, 204/255 )
			sceneGroup:insert(customeTextbox)
			local options = 
			{
				--parent = row,
				text = "Jou speler naam",     
				--x = 0,
				--y = 200,
				--width = 128,     --required for multi-line and alignment
				font = "TeachersPet",   
				fontSize = 20,
				align = "right"  --new alignment parameter
			}

			myText = display.newText( options )
			myText.anchorX =0.5
			myText.anchorY =0
			myText.alpha = 1
			myText.x = display.contentWidth  / 2
			myText.y = display.contentHeight - yInset*14 + 10
			myText:setFillColor( 0, 0, 0,0.5 )
			sceneGroup:insert(myText)
			k = onScreenKeyboard:new()
			local typer=function(event)
				print("keyPressed")
				 if(event.phase == "began")then
					if(event.key == "del")then
						print(event.key)
						if(counter>1)then
							counter = counter - 1
							tospell[counter] =""
							wordTyped = wordTyped:sub(1,string.len(wordTyped)-1)
							myText.text = wordTyped
						end
					elseif(event.key == "ok")then
						back:removeSelf()
						back=nil
						customeTextbox:removeSelf()
						customeTextbox=nil
						k:destroy()
						k=nil
						--Use myText------------------------------------
						if(myText.text~="Enter Player Name")then
							local val = {}
							val.name =myText.text
							val.grade =curOption.gr
							val.correct ="0"
							val.incorrect = "0"
							plaersList[#plaersList+1]=val
							player = myText.text
							grade = "3"
							correct ="0"
							incorrect ="0"
							cur = #plaersList
							addAndSavePlayers(plaersList)
							composer.removeScene("player")
							composer.gotoScene("player")
						end
						myText:removeSelf()
						myText=nil
						menuGroup:addEventListener("tap", addPlayer)
					else
						tospell[counter]=k:getText() --update the textfield with the current text of the k
						wordTyped = wordTyped .. tospell[counter]
						myText.text = wordTyped
						counter = counter + 1
					end
					if(event.target.inputCompleted == true) then
                    print("Input of data complete...") 
					end
				end
			end
			
			
			 --let the onScreenKeyboard know about the listener
			k:setListener(  typer  )
			--show a k with small printed letters as default. Read more about the possible values for k types in the section "possible k types"
			
			k:drawKeyBoard(k.keyBoardMode.letters_large)
			
			return true
		end
		menuGroup = display.newGroup()
		--local mCircle = display.newCircle(0,0,28)
		--mCircle:setFillColor( 255/255, 51/255, 204/255 )
		local addPlayerButtton =  display.newRoundedRect(0,0,xInset*6,yInset*2,2)
		local options = 
		{
			--parent = row,
			text = "Nuwe Speler",     
			--x = 0,
			--y = 200,
			--width = 128,     --required for multi-line and alignment
			font = "TeachersPet",   
			fontSize = 20,
			align = "right"  --new alignment parameter
		}

		local myText = display.newText( options )
		myText.anchorX =0.5
		myText.anchorY =0.5
		myText.alpha = 1
		--myText.x = display.contentWidth  / 2
		--myText.y = display.contentHeight - yInset*14 + 10
		myText:setFillColor( 0, 0, 0,0.7 )
		menuGroup:insert(addPlayerButtton)
		menuGroup:insert(myText)
		menuGroup.x =  display.contentWidth / 2
		menuGroup.y =  display.contentHeight - yInset*2
		menuGroup:addEventListener( "tap", addPlayer )
		sceneGroup:insert(menuGroup)
		
		--k = onScreenKeyboard:new()
		 --let the onScreenKeyboard know about the listener
		---k:setListener(  listener  )
		--show a k with small printed letters as default. Read more about the possible values for k types in the section "possible k types"
		
		--timer.performWithDelay(500,function() k:hide() end)
		if(plaersList[1] == nil)then
			addPlayer()
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
		
    end 
end


function scene:destroy( event )
    local sceneGroup = self.view

    -- Called prior to the removal of scene's "view" (sceneGroup)
    -- 
    -- INSERT code here to cleanup the scene
    -- e.g. remove display objects, remove touch listeners, save state, etc
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
