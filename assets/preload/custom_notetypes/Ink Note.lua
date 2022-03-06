local tip = 0

function onCreate()
	--Iterate over all notes
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Ink Note' then --Check if the note on the chart is a Bullet Note
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'INK_assets'); --Change texture
			setPropertyFromGroup('unspawnNotes', i, 'noteSplashDisabled', false);
			setPropertyFromGroup('unspawnNotes', i, 'noteSplashTexture', 'inkSplashes');

			if getPropertyFromGroup('unspawnNotes', i, 'mustPress') == true then --Lets Opponent's instakill notes get ignored
				setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', true); --Miss has no penalties
			else
				setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', true);
			end
		end
	end
end

function noteMiss(id, direction, noteType, isSustainNote)

end

function goodNoteHit(id, direction, noteType, isSustainNote)
	if noteType == 'Ink Note' then
		tip = tip + 1 
		if tip == 1 then
			makeLuaSprite('exe', 'Damage01', 0, 0)
			setScrollFactor('exe', 0, 0);
			scaleObject('exe', 1, 1);
			setLuaSpriteCamera('exe', 'hud');
			addLuaSprite('exe', true);
			playSound('inked', 0.5);
			runTimer('ink', 5)
		elseif tip == 2 then
			makeLuaSprite('exe', 'Damage02', 0, 0)
			setScrollFactor('exe', 0, 0);
			scaleObject('exe', 1, 1);
			setLuaSpriteCamera('exe', 'hud');
			addLuaSprite('exe', true);
			playSound('inked', 0.5);
			runTimer('ink', 5)
		elseif tip == 3 then
			makeLuaSprite('exe', 'Damage03', 0, 0)
			setScrollFactor('exe', 0, 0);
			scaleObject('exe', 1, 1);
			setLuaSpriteCamera('exe', 'hud');
			addLuaSprite('exe', true);
			playSound('inked', 0.5);
			runTimer('ink', 5)
		elseif tip == 4 then
			makeLuaSprite('exe', 'Damage04', 0, 0)
			setScrollFactor('exe', 0, 0);
			scaleObject('exe', 1, 1);
			setLuaSpriteCamera('exe', 'hud');
			addLuaSprite('exe', true);
			playSound('inked', 0.5);
			runTimer('ink', 5)
		else
			--nada
			playSound('inked', 0.5);
			runTimer('ink', 5)
		end
		--setProperty('health', -1);
	end
end

function onTimerCompleted(tag, loops, loopsLeft)
	-- A loop from a timer you called has been completed, value "tag" is it's tag
	-- loops = how many loops it will have done when it ends completely
	-- loopsLeft = how many are remaining
	if loopsLeft >= 1 then
		tip = 0
		setProperty('health', getProperty('health')-0.001);
	end

	if tag == 'ink' then
		tip = 0;
	end
end