package;

import flixel.text.FlxText;
import lime.app.Promise;
import flixel.util.FlxColor;
import lime.app.Future;
import flixel.FlxG;
import openfl.utils.Assets as OpenFlAssets;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import flixel.addons.transition.FlxTransitionableState;

import haxe.io.Path;


class LoadingsState extends MusicBeatSubstate
{
	public var instantAlpha:Bool = false;
    var letext:FlxText;
	var art = new FlxSprite();
	var txtWeekTitle:FlxText;
	override function create()
	{
		
		//Basicamente este código vai invocar uma imagem que ficará atrás da arte principal do modboa
		//durante a tela de carregamento, por fins de, É ESTRANHO PA CACETE ver aquela tela preta
		//Enquanto o jogo carrega em celulares e pc's fracos (tipo o meu).
		//Ele vai pegar o nome da week e vai procurar por daweekart"nome da week" na pasta preload/images
		//Se o arquivo não existir, ele vai substituir pelo simpático menu do modboa comum
		if(OpenFlAssets.exists(Paths.image('daweekart' + FreeplayState.dapreselected))) { //anti crashing moment 
			art.loadGraphic(Paths.image('daweekart' + FreeplayState.dapreselected));
		} else {
			art.loadGraphic(Paths.image('daweekartweek0')); 
		}
		art.setGraphicSize(Std.int(FlxG.width * 1.0));
		art.updateHitbox();
		art.antialiasing = ClientPrefs.globalAntialiasing;
		art.scrollFactor.set();
		art.screenCenter();
		add(art); //Haha isso não é um NFT

		var tip:FlxSprite = new FlxSprite(0, 590).loadGraphic(Paths.image('loading/' + FlxG.random.int(1, 9)));
		if (FlxG.random.bool(0.5))
			tip.loadGraphic(Paths.image('loading/10'));
		tip.screenCenter(XY);
		tip.y -= 150;
		tip.setGraphicSize(Std.int(tip.width * 1.05), Std.int(tip.height * 0.9));
		add(tip);
		tip.antialiasing = true;

		letext = new FlxText(50, FlxG.height - 100, FlxG.width - 800, "Carregando...", 32); //Achei cringe
		letext.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		letext.scrollFactor.set();
		add(letext);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		blackBarThingie.y = -5;
		add(blackBarThingie);

		txtWeekTitle = new FlxText(0, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.screenCenter(X);
		txtWeekTitle.text = PreFreeplayState.leName;
		txtWeekTitle.alpha = 0.7;
		add(txtWeekTitle);

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		art.setGraphicSize(Std.int(FlxG.width * 1.0));
		art.updateHitbox();
		art.screenCenter(XY);
		if(controls.ACCEPT)
		{
			art.setGraphicSize(Std.int(art.width + 60));
			art.updateHitbox();
		}
	}
}
class LoadingState extends MusicBeatState
{
	inline static var MIN_TIME = 1.0;

	var target:FlxState;
	var stopMusic = false;
	var directory:String;
	var callbacks:MultiCallback;
	var targetShit:Float = 0;
	
	function new(target:FlxState, stopMusic:Bool, directory:String)
	{
		super();
		this.target = target;
		this.stopMusic = stopMusic;
		this.directory = directory;
	}
	
	override function create()
	{

		initSongsManifest().onComplete
		(
			function (lib)
			{
				callbacks = new MultiCallback(onLoad);
				var introComplete = callbacks.add("introComplete");
				if (PlayState.SONG != null) {
				checkLoadSong(getSongPath());
				if (PlayState.SONG.needsVoices)
					checkLoadSong(getVocalPath());
			}
				checkLibrary("shared");
				if(directory != null && directory.length > 0 && directory != 'shared') {
					checkLibrary(directory);
				}
				
				var fadeTime = 1.5;
				FlxG.camera.fade(FlxG.camera.bgColor, fadeTime, true);
				new FlxTimer().start(fadeTime + MIN_TIME, function(_) introComplete());
			}
		);
		super.create();
	}
	
	function checkLoadSong(path:String)
	{
		if (!Assets.cache.hasSound(path))
		{
			var library = Assets.getLibrary("songs");
			final symbolPath = path.split(":").pop();
			// @:privateAccess
			// library.types.set(symbolPath, SOUND);
			// @:privateAccess
			// library.pathGroups.set(symbolPath, [library.__cacheBreak(symbolPath)]);
			var callback = callbacks.add("song:" + path);
			Assets.loadSound(path).onComplete(function (_) { callback(); });
		}
	}
	
	function checkLibrary(library:String) {
		trace(Assets.hasLibrary(library));
		if (Assets.getLibrary(library) == null)
		{
			@:privateAccess
			if (!LimeAssets.libraryPaths.exists(library))
				throw "Missing library: " + library;
			
			var callback = callbacks.add("library:" + library);
			Assets.loadLibrary(library).onComplete(function (_) { callback(); });
		}
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		#if debug
		if (FlxG.keys.justPressed.SPACE)
			trace('fired: ' + callbacks.getFired() + " unfired:" + callbacks.getUnfired());
		#end
	}
	
	function onLoad()
	{
		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();
		
		FlxG.switchState(target);
	}
	
	static function getSongPath()
	{
		return Paths.inst(PlayState.SONG.song);
	}
	
	static function getVocalPath()
	{
		return Paths.voices(PlayState.SONG.song);
	}
	
	inline static public function loadAndSwitchState(target:FlxState, stopMusic = false, ?waitForLoad:Bool = false)
	{
		var waitTime = 0.0;
		if (waitForLoad)
		{
			FlxG.sound.music.fadeOut(1, 0);
			waitTime = 1.6;
		}

		FlxTransitionableState.skipNextTransIn = true;
		new FlxTimer().start(waitTime, function(tmr:FlxTimer) {
			
			FlxG.switchState(getNextState(target, stopMusic));
		});
		
	}
	
	static function getNextState(target:FlxState, stopMusic = false):FlxState
		{
			var directory:String = 'shared';
			var weekDir:String = StageData.forceNextDirectory;
			StageData.forceNextDirectory = null;
	
			if(weekDir != null && weekDir.length > 0 && weekDir != '') directory = weekDir;
	
			Paths.setCurrentLevel(directory);
			trace('Setting asset folder to ' + directory);
	
			#if NO_PRELOAD_ALL
			var loaded:Bool = false;
			if (PlayState.SONG != null) {
				loaded = isSoundLoaded(getSongPath()) && (!PlayState.SONG.needsVoices || isSoundLoaded(getVocalPath())) && isLibraryLoaded("shared") && isLibraryLoaded(directory);
			}
			
			if (!loaded)
				return new LoadingState(target, stopMusic, directory);
			#end
			if (stopMusic && FlxG.sound.music != null)
				FlxG.sound.music.stop();
			
			return target;
		}
	
	#if NO_PRELOAD_ALL
	static function isSoundLoaded(path:String):Bool
	{
		return Assets.cache.hasSound(path);
	}
	
	static function isLibraryLoaded(library:String):Bool
	{
		return Assets.getLibrary(library) != null;
	}
	#end
	
	override function destroy()
	{
		super.destroy();
		
		callbacks = null;
	}
	
	static function initSongsManifest()
	{
		var id = "songs";
		var promise = new Promise<AssetLibrary>();

		var library = LimeAssets.getLibrary(id);

		if (library != null)
		{
			return Future.withValue(library);
		}

		var path = id;
		var rootPath = null;

		@:privateAccess
		var libraryPaths = LimeAssets.libraryPaths;
		if (libraryPaths.exists(id))
		{
			path = libraryPaths[id];
			rootPath = Path.directory(path);
		}
		else
		{
			if (StringTools.endsWith(path, ".bundle"))
			{
				rootPath = path;
				path += "/library.json";
			}
			else
			{
				rootPath = Path.directory(path);
			}
			@:privateAccess
			path = LimeAssets.__cacheBreak(path);
		}

		AssetManifest.loadFromFile(path, rootPath).onComplete(function(manifest)
		{
			if (manifest == null)
			{
				promise.error("Cannot parse asset manifest for library \"" + id + "\"");
				return;
			}

			var library = AssetLibrary.fromManifest(manifest);

			if (library == null)
			{
				promise.error("Cannot open library \"" + id + "\"");
			}
			else
			{
				@:privateAccess
				LimeAssets.libraries.set(id, library);
				library.onChange.add(LimeAssets.onChange.dispatch);
				promise.completeWith(Future.withValue(library));
			}
		}).onError(function(_)
		{
			promise.error("There is no asset library with an ID of \"" + id + "\"");
		});

		return promise.future;
	}
}

class MultiCallback
{
	public var callback:Void->Void;
	public var logId:String = null;
	public var length(default, null) = 0;
	public var numRemaining(default, null) = 0;
	
	var unfired = new Map<String, Void->Void>();
	var fired = new Array<String>();
	
	public function new (callback:Void->Void, logId:String = null)
	{
		this.callback = callback;
		this.logId = logId;
	}
	
	public function add(id = "untitled")
	{
		id = '$length:$id';
		length++;
		numRemaining++;
		var func:Void->Void = null;
		func = function ()
		{
			if (unfired.exists(id))
			{
				unfired.remove(id);
				fired.push(id);
				numRemaining--;
				
				if (logId != null)
					log('fired $id, $numRemaining remaining');
				
				if (numRemaining == 0)
				{
					if (logId != null)
						log('all callbacks fired');
					callback();
				}
			}
			else
				log('already fired $id');
		}
		unfired[id] = func;
		return func;
	}
	
	inline function log(msg):Void
	{
		if (logId != null)
			trace('$logId: $msg');
	}
	
	public function getFired() return fired.copy();
	public function getUnfired() return [for (id in unfired.keys()) id];
}