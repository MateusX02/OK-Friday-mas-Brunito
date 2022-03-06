function onCreate()
    makeLuaSpriteNoAntialiasing('green', 'battle', 0, 0);
    scaleObject('green', 0.5, 0.5);
    setLuaSpriteScrollFactor('green', 1, 1);
    setProperty('green.visible', false);
    addLuaSprite('green', false);
    makeLuaSprite('bg', 'hall', -300, -50);
	setLuaSpriteScrollFactor('bg', 1, 1);
	scaleObject('bg', 1, 1);
    setProperty('bg.visible', true);
	addLuaSprite('bg', false);
end


function onEvent(name, value1, value2)
    if name == "changeBG" then
        followchars = false;
        setProperty('bg.visible', false);
        setProperty('green.visible', true);
        setCharacterX('boyfriend', 770);
        setCharacterY('boyfriend', -325);
        setCharacterX('dad', 125);
        setCharacterY('dad', -365);
    end
end