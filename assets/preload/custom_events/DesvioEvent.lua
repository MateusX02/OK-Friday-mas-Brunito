function onCreate()
    --variables
	Dodged = false;
    canDodge = false;
    DodgeTime = 0.5;

    
    precacheSound('notice');
    precacheSound('dodge');
    precacheImage('DodgeMechs');
    precacheImage('spacebar_icon');
end

function onEvent(name, value1, value2)
    if name == "DodgeEvent" then
    --Get Dodge time
    --DodgeTime = (value1);
	
    --Make Dodge Sprite
	makeAnimatedLuaSprite('spacebar', 'spacebar_icon', 500, 300);
    luaSpriteAddAnimationByPrefix('spacebar', 'spacebar', 'spacebar', 25, true);
	luaSpritePlayAnimation('spacebar', 'spacebar');
	setObjectCamera('spacebar', 'other');
	scaleLuaSprite('spacebar', 0.8, 0.8); 
    --addLuaSprite('spacebar', true); 

    makeAnimatedLuaSprite('dg2', 'DodgeMechs', 600, 450);
    luaSpriteAddAnimationByPrefix('dg2', 'Alarm instance ', 'Alarm instance ', 25, false);
    luaSpritePlayAnimation('dg2', 'Alarm instance ');
    scaleLuaSprite('dg2', 0.8, 0.8);
    addLuaSprite('dg2', true); 
    setProperty('dad.specialAnim', true);

    playSound('notice')
	
	--Set values so you can dodge
	canDodge = true;
	runTimer('Died', DodgeTime);
	
	end
end

function onUpdate()
   if canDodge == true and keyJustPressed('space') then
    Desviar()
   end

   if canDodge == true and botPlay == true then
    Desviar()
   end
end

function Desviar()
    Dodged = true;
    canDodge = false;
   removeLuaSprite('dg2', true)
   characterPlayAnim('dad', 'miss', true);
   setProperty('boyfriend.alpha', 0);
   makeAnimatedLuaSprite('dg', 'DodgeMechs', 725, 447);
   luaSpriteAddAnimationByPrefix('dg', 'Dodge instance ', 'Dodge instance ', 25, false);
   luaSpritePlayAnimation('dg', 'Dodge instance ');
   scaleLuaSprite('dg', 1, 1); 
   addLuaSprite('dg', true); 
   makeAnimatedLuaSprite('dg1', 'DodgeMechs', 500, 400);
   luaSpriteAddAnimationByPrefix('dg1', 'Bones boi instance ', 'Bones boi instance ', 25, false);
   luaSpritePlayAnimation('dg1', 'Bones boi instance ');
   scaleLuaSprite('dg1', 1, 1); 
   addLuaSprite('dg1', true); 
   playSound('dodge')
   runTimer('anims', 1.15); 
end

function onTimerCompleted(tag, loops, loopsLeft)
   if tag == 'Died' and Dodged == false then
   setProperty('health', 0)
   characterDance('dad', true);
   makeAnimatedLuaSprite('dg1', 'DodgeMechs', 500, 400);
   luaSpriteAddAnimationByPrefix('dg1', 'Bones boi instance ', 'Bones boi instance ', 25, false);
   luaSpritePlayAnimation('dg1', 'Bones boi instance ');
   scaleLuaSprite('dg1', 1, 1); 
   addLuaSprite('dg1', true); 
   runTimer('anims', 1);
   characterPlayAnim('dad', 'miss', true);
   playSound('sansattack')
   
   elseif tag == 'Died' and Dodged == true then
    --nada
   end

   if tag == 'anims' then
    removeLuaSprite('dg', true);
    removeLuaSprite('dg1', true);
    setProperty('boyfriend.alpha', 1);
   end
end