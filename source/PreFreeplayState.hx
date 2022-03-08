package;

import flixel.input.mouse.FlxMouseButton;
import flixel.ui.FlxButton;
import flixel.tweens.FlxEase;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import openfl.utils.Assets as OpenFlAssets;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;

using StringTools;

class PreFreeplayState extends MusicBeatState
{
	// Wether you have to beat the previous week for playing this one
	// Not recommended, as people usually download your mod for, you know,
	// playing just the modded week then delete it.
	// defaults to True
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var txtWeekTitle:FlxText;
	var bgSprite:FlxSprite;

	public var eltextodaweek:String;

	private static var curWeek:Int = 0;

	//var machine:FlxSprite;

//	var grpWeekText:FlxTypedGroup<MenuItem>;

	var botaoAceitar:FlxButton;
	var botaoVoltar:FlxButton;

	var leftArrow:FlxButton;
	var rightArrow:FlxButton;
	public static var leName:String;

	override function create()
	{

		Main.dumpCache(); // What can go wrong?

		WeekData.reloadWeekFiles(true);
		if(curWeek >= WeekData.weeksList.length) curWeek = 0;
		persistentUpdate = persistentDraw = true;

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 0, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		bgSprite = new FlxSprite(0, 0);
		bgSprite.antialiasing = ClientPrefs.globalAntialiasing;

		//grpWeekText = new FlxTypedGroup<MenuItem>();
	//	add(grpWeekText);

		botaoAceitar = new FlxButton(FlxG.width - 200,	FlxG.height - 100, '');
		botaoAceitar.loadGraphic(Paths.image('aceitas'));
		botaoAceitar.updateHitbox();
		botaoAceitar.antialiasing = ClientPrefs.globalAntialiasing;
		botaoAceitar.setGraphicSize(Std.int(botaoAceitar.width * 1.5));


		botaoVoltar = new FlxButton(FlxG.width - 425,	FlxG.height - 100, '');
		botaoVoltar.loadGraphic(Paths.image('retornas'));
		botaoVoltar.updateHitbox();
		botaoVoltar.antialiasing = ClientPrefs.globalAntialiasing;
		botaoVoltar.setGraphicSize(Std.int(botaoVoltar.width * 1.5));




	/*	for (i in 0...WeekData.weeksList.length)
		{
			WeekData.setDirectoryFromWeek(WeekData.weeksLoaded.get(WeekData.weeksList[i]));
			var weekThing:MenuItem = new MenuItem(0, bgSprite.y + 396, WeekData.weeksList[i]);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			weekThing.antialiasing = ClientPrefs.globalAntialiasing;
			// weekThing.updateHitbox();

			// Needs an offset thingie
		} */

		WeekData.setDirectoryFromWeek(WeekData.weeksLoaded.get(WeekData.weeksList[0]));
		var charArray:Array<String> = WeekData.weeksLoaded.get(WeekData.weeksList[0]).weekCharacters;


	/*	machine = new FlxSprite(0).loadGraphic(Paths.image('ModboaMenu'));
		machine.scrollFactor.x = 0;
		machine.scrollFactor.y = 0;
		machine.setGraphicSize(FlxG.width);
		machine.updateHitbox();
		machine.screenCenter();
		machine.visible = true;
		machine.antialiasing = ClientPrefs.globalAntialiasing; */
		

	//	add(bgYellow);
		add(bgSprite);
		add(botaoVoltar);
		add(botaoAceitar);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);
	//	add(grpWeekCharacters);
		//add(machine);
/*
		logoBl = new FlxButton(50, 10, '');

		logoBl.loadGraphic(Paths.image('logodeboa'));

		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
		logoBl.updateHitbox();
		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
		logoBl.setGraphicSize(Std.int(logoBl.width));
		logoBl.y = 30;
		logoBl.x = FlxG.width - logoBl.width - 50; //MATEMÁTICA AVANÇADA AGAIN
		add(logoBl); */

		leftArrow = new FlxButton(-600, 312, '');
		leftArrow.loadGraphic(Paths.image("arrowLeft"));
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;

		rightArrow = new FlxButton(3000, 312, '');
		rightArrow.loadGraphic(Paths.image("arrowRight"));
		rightArrow.antialiasing = ClientPrefs.globalAntialiasing;

		add(leftArrow);
		add(rightArrow);

		FlxTween.tween(leftArrow, {x: 28}, 1.5, {
			ease: FlxEase.quadOut,
			startDelay: 0.5
		});

		FlxTween.tween(rightArrow, {x: 1134}, 1.5, {
			ease: FlxEase.quadOut,
			startDelay: 0.5
		});

		add(txtWeekTitle);

		changeWeek();

		super.create();
	}

	override function closeSubState() {
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();
	}

	override function update(elapsed:Float)
	{

		//if (logoBl.justPressed) {
		//	selectWeek();
		//}

		#if desktop
		DiscordClient.changePresence("Escolhendo uma semana ", null);
		#end
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 30, 0, 1)));
		if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;

		if (!movedBack && !selectedWeek)
		{
			if (controls.UI_LEFT_P || leftArrow.justPressed)
			{
				changeWeek(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (controls.UI_RIGHT_P || rightArrow.justPressed)
			{
				changeWeek(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (controls.UI_RIGHT || rightArrow.pressed) {
				rightArrow.scale.set(0.95, 0.95);
			} else {
				rightArrow.scale.set(1, 1);
			}
			if (controls.UI_LEFT || leftArrow.pressed && !controls.UI_RIGHT) {
				leftArrow.scale.set(0.95, 0.95);
			} else {
				leftArrow.scale.set(1, 1);
			}

			if (controls.ACCEPT || botaoAceitar.justPressed)
			{
				selectWeek();
			}
		}

		if (controls.BACK || botaoVoltar.justPressed && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

			//	grpWeekText.members[curWeek].startFlashing();
			//	if(grpWeekCharacters.members[1].character != '') grpWeekCharacters.members[1].animation.play('confirm');
				stopspamming = true;
			}

			// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]).songs;
			for (i in 0...leWeek.length) {
				songArray.push(leWeek[i][0]);
			}

			// Nevermind that's stupid lmao
			selectedWeek = true;

			var botaoselect = WeekData.weeksList[curWeek];
			FreeplayState.dapreselected = botaoselect;
			
			new FlxTimer().start(1, function(tmr:FlxTimer)
				{
			MusicBeatState.switchState(new FreeplayState());
			FreeplayState.destroyFreeplayVocals();
			});
		}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= WeekData.weeksList.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = WeekData.weeksList.length - 1;

		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]);
		WeekData.setDirectoryFromWeek(leWeek);

		eltextodaweek = leWeek.storyName;
		leName = leWeek.storyName;
		txtWeekTitle.text = leName.toUpperCase();
		txtWeekTitle.screenCenter(X); //Bem vindo a turma de matemática avançada
		txtWeekTitle.y = 0;

		var bullShit:Int = 0;

	/*	for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0))
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}
*/
		bgSprite.visible = true;
		var assetName:String = leWeek.weekBackground;
		if(assetName == null || assetName.length < 1) {
			bgSprite.loadGraphic('assets/images/daweekartweek0.png');
			bgSprite.setGraphicSize(FlxG.width);
			bgSprite.screenCenter(XY);
		} else {
			if(OpenFlAssets.exists(Paths.image('daweekart' + assetName))) { //anti crashing moment 
				bgSprite.loadGraphic(Paths.image('daweekart' + assetName)); 
			} else {
				bgSprite.loadGraphic('assets/images/menuBG.png'); 
			}
			bgSprite.setGraphicSize(Std.int(FlxG.width * 0.95));
			bgSprite.screenCenter(XY);
		}

		if (leftArrow.alpha == 0) {
			FlxTween.tween(leftArrow, {alpha: 1}, 0.6, {});
			FlxTween.tween(rightArrow, {alpha: 1}, 0.6, {});
		}
		updateText();
	}

	function updateText()
	{
		var weekArray:Array<String> = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]).weekCharacters;

		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]);
		var stringThing:Array<String> = [];
		for (i in 0...leWeek.songs.length) {
			stringThing.push(leWeek.songs[i][3]); //Talvez isso ainda seja usado, mas ainda estoy pensando
		}
	}
}