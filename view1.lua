-----------------------------------------------------------------------------------------
--
-- view1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

--1) 게임에 사용될 랜덤함수 미리 초기화
   math.randomseed(os.time())
--2) widget 라이브러리 추가(아래서 사용할 것임)
local widget = require("widget")
--3) 점수 변수 선언
local score = 0
--4) GUI 요소들 선언 
local background
local gameUI = {}
local viewUI = {}
local playerUI = {}
local buttonUI = {}

function scene:create( event )
   local sceneGroup = self.view

   -- 배경화면
   background = display.newImageRect("Fruit/BG_Forest.png", display.contentWidth, display.contentHeight)
   background.x, background.y = display.contentWidth/2, display.contentHeight/2

   -- 5) gameUI들 넣기
   -- gameUI[0]은 약간 불투명한 검은 배경(앞의 자원찾기 게임에서도 했죠?)
   gameUI[0] = display.newRect(display.contentWidth/2, display.contentHeight/2, display.contentWidth, display.contentHeight)
   gameUI[0]:setFillColor(0)
   gameUI[0].alpha = 0.5

   -- gameUI[1]은 호두 사진
   gameUI[1] = display.newImageRect("Fruit/walnut.png", 200, 200)
   gameUI[1].x, gameUI[1].y = display.contentWidth/2, display.contentHeight/2 + 50
   gameUI[1].alpha = 1

   -- gameUI[2]은 호두가 까졌을때 사진
   gameUI[2] = display.newImageRect("Fruit/walnut_over.png", 200, 200)
   gameUI[2].x, gameUI[2].y = gameUI[1].x, gameUI[1].y
   gameUI[2].alpha = 0

   -- gameUI[3]은 호두를 때렸을때 사진
   gameUI[3] = display.newImageRect("Fruit/walnut_damage.png", 200, 200)
   gameUI[3].x, gameUI[3].y = gameUI[1].x, gameUI[1].y
   gameUI[3].alpha = 0

   -- 기타 게임 화면 구성 요소들
   -- gameUI[4]은 키 버튼 뒤에 있는 모서리가 둥근 네모
   gameUI[4] = display.newRoundedRect(gameUI[1].x, 75, 800, 110, 55)
   gameUI[4]:setFillColor(0)
   gameUI[4].alpha = 0.5

   -- gameUI[5]은 점수
   gameUI[5] = display.newText({
      text = "00000", x = 125, y = 75, width = 200,
      font = "돋움", fontSize = 50
   })

   -- gameUI[6]은 아래 나무
   gameUI[6] = display.newImageRect("Fruit/tree.png", 500, 260)
   gameUI[6].x, gameUI[6].y = gameUI[1].x, display.contentHeight-130

   -- 6) View UI => 상단에 나타나는 눌러야 하는 버튼들에 대한 UI   
   -- viewUI[0]는 방향키 이미지들이 모여있는 상자라고 생각
   viewUI[0] = graphics.newImageSheet("Fruit/key.png", {width = 200, height = 200, numFrames = 5})

   for i = 1, 5, 1 do
      viewUI[i] = {}
      viewUI[i][1] = display.newImageRect(viewUI[0], 1, 100, 100)
      viewUI[i][2] = display.newImageRect(viewUI[0], 2, 100, 100)
      viewUI[i][3] = display.newImageRect(viewUI[0], 3, 100, 100)
      viewUI[i][4] = display.newImageRect(viewUI[0], 4, 100, 100)
      viewUI[i][5] = display.newImageRect(viewUI[0], 5, 100, 100)
   end

   for i = 1, 5, 1 do
      for j = 1, 5, 1 do
         viewUI[i][j].alpha = 0
         viewUI[i][j].x, viewUI[i][j].y = gameUI[4].x - 300 + 150 * (i - 1), gameUI[4].y
      end
   end

   -- 7) Player UI => 플레이어의 이미지 삽입
   -- playerUI[0]에는 모든 캐릭터의 이미들을 넣는 상자
   playerUI[0] = graphics.newImageSheet("Fruit/player.png", {width = 300, height = 500, numFrames = 6})

   playerUI[1] = display.newImage(playerUI[0], 1)
   playerUI[1].x, playerUI[1].y = display.contentWidth/2 - 150, gameUI[1].y

   playerUI[2] = display.newImage(playerUI[0], 2)
   playerUI[2].x, playerUI[2].y = display.contentWidth/2 + 150, gameUI[1].y

   playerUI[3] = display.newImage(playerUI[0], 4)
   playerUI[3].x, playerUI[3].y = display.contentWidth/2 - 50, gameUI[1].y - 175

   playerUI[4] = display.newImage(playerUI[0], 3)
   playerUI[4].x, playerUI[4].y = display.contentWidth/2 + 50, gameUI[1].y - 175

   playerUI[5] = display.newImage(playerUI[0], 5)
   playerUI[5].x, playerUI[5].y = display.contentWidth/2, gameUI[1].y + 100

   playerUI[6] = display.newImage(playerUI[0], 6)
   playerUI[6].x, playerUI[6].y = display.contentWidth/2 + 200, gameUI[1].y - 50

   for i = 1, 6, 1 do
      playerUI[i].alpha = 0
   end
   

   -- 9)함수 작성
   -- makeView - 초기 상태를 만들어주는 함수
   local view = {}

   function makeView()
      view[0] = 1 -- 현재 버튼의 위치(index)

      gameUI[1].alpha = 1 -- 까기 전
      gameUI[2].alpha = 0 -- 까기 후

      -- 불투명도 초기화
      if view[1] ~= nil then
         for i = 1, 5, 1 do
            viewUI[i][view[i]].alpha = 0
         end
      end

      for i = 1, 5, 1 do
         view[i] = math.random(1, 5) -- 랜덤으로 방향키 고르기
         viewUI[i][view[i]].alpha = 1
      end
   end

   -- 시작할 때 무조건 한 번은 실행
   makeView()

   --  clearPlayer - 플레이어 이미지를 삭제하는 함수
   function  clearPlayer()
      for i = 1, 6, 1 do
         transition.to(playerUI[i], {time = 300, alpha = 0})
      end
   end

   -- inputEvent - 버튼을 눌렀을때 실행되는 함수
   function inputEvent( event )
      gameUI[3].alpha = 1
      transition.to(gameUI[3], {time = 300, alpha = 0})

      if event.target.name == "L" then
         if viewUI[view[0]][4].alpha == 1 then
            score = score + 100
            playerUI[1].alpha = 1
            transition.to(viewUI[view[0]][4], {time = 300, alpha = 0})
            view[0] = view[0] + 1
         elseif viewUI[view[0]][4].alpha ~= 1 then
            score = score - 500
            playerUI[5].alpha = 1
            makeView()
         end

      elseif event.target.name == "R" then
         if viewUI[view[0]][5].alpha == 1 then
            score = score + 100
            playerUI[2].alpha = 1
            transition.to(viewUI[view[0]][5], {time = 300, alpha = 0})
            view[0] = view[0] + 1
         elseif viewUI[view[0]][5].alpha ~= 1 then
            score = score - 500
            playerUI[5].alpha = 1
            makeView()
         end

      elseif event.target.name == "T" then
         if viewUI[view[0]][2].alpha == 1 then
            score = score + 100
            playerUI[3].alpha = 1
            transition.to(viewUI[view[0]][2], {time = 300, alpha = 0})
            view[0] = view[0] + 1
         elseif viewUI[view[0]][2].alpha ~= 1 then
            score = score - 500
            playerUI[5].alpha = 1
            makeView()
         end

      elseif event.target.name == "B" then
         if viewUI[view[0]][3].alpha == 1 then
            score = score + 100
            playerUI[4].alpha = 1
            transition.to(viewUI[view[0]][3], {time = 300, alpha = 0})
            view[0] = view[0] + 1
         elseif viewUI[view[0]][3].alpha ~= 1 then
            score = score - 500
            playerUI[5].alpha = 1
            makeView()
         end

      elseif event.target.name == "C" then
         if viewUI[view[0]][1].alpha == 1 then
            score = score + 100
            playerUI[6].alpha = 1
            transition.to(viewUI[view[0]][1], {time = 300, alpha = 0})
            view[0] = view[0] + 1
         elseif viewUI[view[0]][1].alpha ~= 1 then
            score = score - 500
            playerUI[5].alpha = 1
            makeView()
         end
      end

      clearPlayer()

      if view[0] > 5 then
         gameUI[1].alpha = 0 -- 까기 전
         gameUI[2].alpha = 1 -- 까기 후
         timer.performWithDelay(500, makeView)
         score = score + 500
      end

      gameUI[5].text = string.format("%05d", score)
   end


   -- 8) 버튼 이미지 삽입 및 함수연결
   buttonUI[1] = widget.newButton({
      defaultFile = "Fruit/input_L.png", overFile = "Fruit/input_L_over.png",
      width = 75, height = 150, onPress = inputEvent -- 버튼을 누르면 inputEvent
   })
   buttonUI[1].x, buttonUI[1].y = display.contentWidth-150-85, display.contentHeight - 150
   buttonUI[1].name = "L"

   buttonUI[2] = widget.newButton({ 
      defaultFile = "Fruit/input_R.png", overFile = "Fruit/input_R_over.png", 
      width = 75, height = 150, onPress = inputEvent 
   })
   buttonUI[2].x, buttonUI[2].y = display.contentWidth-150+85, display.contentHeight-150
   buttonUI[2].name = "R"

   buttonUI[3] = widget.newButton({ 
      defaultFile = "Fruit/input_T.png", overFile = "Fruit/input_T_over.png",
      width = 150, height = 75, onPress = inputEvent 
   })
   buttonUI[3].x, buttonUI[3].y = display.contentWidth-150, display.contentHeight-150-85
   buttonUI[3].name = "T"

   buttonUI[4] = widget.newButton({ 
      defaultFile = "Fruit/input_B.png", overFile = "Fruit/input_B_over.png", 
      width = 150, height = 75, onPress = inputEvent 
   })
   buttonUI[4].x, buttonUI[4].y = display.contentWidth-150, display.contentHeight-150+85
   buttonUI[4].name = "B"

   buttonUI[5] = widget.newButton({ 
      defaultFile = "Fruit/input_C.png", overFile = "Fruit/input_C_over.png", 
      width = 100, height = 100, onPress = inputEvent 
   })
   buttonUI[5].x, buttonUI[5].y = display.contentWidth-150, display.contentHeight-150
   buttonUI[5].name = "C"

   -- 10)마지막으로 sceneGroup:insert
   sceneGroup:insert(background) -- 숲 배경
   sceneGroup:insert(gameUI[0]) -- 불투명한 검은색 배경
   sceneGroup:insert(gameUI[6]) -- 나무

   for i = 1, 4, 1 do
      sceneGroup:insert(playerUI[i])
   end
   for i = 1, 5, 1 do
      sceneGroup:insert(gameUI[i])
   end
   for i = 5, 6, 1 do 
      sceneGroup:insert(playerUI[i]) -- 좌절한 플레이어
   end
   for i = 1, 5, 1 do
      sceneGroup:insert(buttonUI[i])
   end

   for i = 1, 5, 1 do
      for j = 1, 5, 1 do
         sceneGroup:insert(viewUI[i][j])
      end
   end

end

function scene:show( event )
   local sceneGroup = self.view
   local phase = event.phase
   
   if phase == "will" then
   elseif phase == "did" then
      -- e.g. start timers, begin animation, play audio, etc.
   end   
end

function scene:hide( event )
   local sceneGroup = self.view
   local phase = event.phase
   
   if event.phase == "will" then
      -- e.g. stop timers, stop animation, unload sounds, etc.)
   elseif phase == "did" then
   end
end

function scene:destroy( event )
   local sceneGroup = self.view
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene