function onCreate()
    --variables
	Dodged = false;
    canDodge = false;
    DodgeTime = 2;
    BotTime = 2;
	
    precacheImage('textbg');
end

function onEvent(name, value1, value2)
    if name == "CalcEvent" then
    --Get Dodge time
    keyToPress = value2;
    imgConta = value1;
	

    makeLuaSprite('tg', 'textbg', 0, 0);
    setObjectCamera('tg', 'camhud');
    addLuaSprite('tg', true);

    makeLuaSprite('conta', imgConta, 0, 0);
    setObjectCamera('conta', 'camhud');
    addLuaSprite('conta', true);
    

	--Set values so you can dodge
	canDodge = true;
	runTimer('morreu', DodgeTime);
	
	end
end

function onUpdate()
   if canDodge == true and keyJustPressed(keyToPress) then
    removeLuaSprite('conta', true);
    removeLuaSprite('tg', true);
    Dodged = true;
   end
   if canDodge == true and botPlay == true then
    removeLuaSprite('conta', true);
    removeLuaSprite('tg', true);
    Dodged = true;
   end
end

function onTimerCompleted(tag, loops, loopsLeft)
   if tag == 'morreu' and Dodged == false then
   setProperty('health', 0)
   elseif tag == 'morreu' and Dodged == true then
   Dodged = false
   canDodge = false
   end

   if tag == 'acertar' then
   removeLuaSprite('conta', true);
   removeLuaSprite('tg', true);
   Dodged = true;
   canDodge = false
   end

end