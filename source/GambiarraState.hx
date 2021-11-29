package;

import flixel.util.FlxAxes;
import WeekData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxTimer;
import haxe.io.Path;
import lime.app.Future;
import lime.app.Promise;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import lime.utils.Assets as LimeAssets;
import openfl.utils.Assets;
import LoadingState;

class GambiarraState extends MusicBeatState
{
	inline static var MIN_TIME = 1.0;
	
	var target:FlxState;
	var stopMusic = false;
	var directory:String;
	var callbacks:MultiCallback;
	
	var logo:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft = false;
	
	function new(target:FlxState, stopMusic:Bool, directory:String)
	{
		super();
		this.target = target;
		this.stopMusic = stopMusic;
		this.directory = directory;
	}

	var loadBar:FlxSprite;

	private static var art = new FlxSprite();

	override function create()
	{

		var art = new FlxSprite();
		if(Assets.exists(Paths.image('daweekart' + WeekData.getWeekFileName()))) { //anti crashing moment 
			art.loadGraphic(Paths.image('daweekart' + WeekData.getWeekFileName()));
		} else {
			art.loadGraphic(Paths.image('daweekartweek0')); // PRA QUE DIFEREnCIAR PACERO, EnFIA COMO WEEK 0 POLA
		}
		art.setGraphicSize(FlxG.width - 200);
		art.updateHitbox();
		art.antialiasing = ClientPrefs.globalAntialiasing;
		art.scrollFactor.set();
		art.screenCenter();

		loadBar = new FlxSprite(0, FlxG.height - 20).makeGraphic(FlxG.width, 10, -59694);
		loadBar.screenCenter(FlxAxes.X);
		add(art);
		add(loadBar); 
		
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
				checkLibrary("shared"); //Isso não fazia o menor sentido true da true
				if(directory != null && directory.length > 0 && directory != 'shared') {
					checkLibrary(directory);
				}

				var fadeTime = 0.5;
				FlxG.camera.fade(FlxG.camera.bgColor, fadeTime, true);
				new FlxTimer().start(fadeTime + MIN_TIME, function(_) introComplete());
			}
		);
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
	
	function checkLibrary(library:String)
	{
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

		if (callbacks != null)
			loadBar.scale.x = callbacks.getFired().length / callbacks.getUnfired().length;

		#if debug
		if (FlxG.keys.justPressed.SPACE)
			trace('fired: ' + callbacks.getFired() + " unfired:" + callbacks.getUnfired());
		#end
	}
	
	function onLoad()
	{
		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();
		art.kill(); //Oh nao, estou destruindo a arte
		MusicBeatState.switchState(target);
	}
	
	static function getSongPath()
		{
			return Paths.inst(PlayState.SONG.song);
		}
		
		static function getVocalPath()
		{
			return Paths.voices(PlayState.SONG.song);
		}
		
		inline static public function loadAndSwitchState(target:FlxState, stopMusic = false)
		{
			MusicBeatState.switchState(getNextState(target, stopMusic));
		}
		
		static function getNextState(target:FlxState, stopMusic = false):FlxState
		{
			var directory:String = 'shared';
			var weekDir:String = StageData.forceNextDirectory;
			StageData.forceNextDirectory = null;
	
			if(weekDir != null && weekDir.length > 0 && weekDir != '') directory = weekDir;
	
			Paths.setCurrentLevel(directory);
			//trace('Setting asset folder to ' + directory);

			//#if NO_PRELOAD_ALL
			var loaded:Bool = false;
			if (PlayState.SONG != null) {
				loaded = isSoundLoaded(getSongPath()) && (!PlayState.SONG.needsVoices || isSoundLoaded(getVocalPath())) && isLibraryLoaded("shared") && isLibraryLoaded(directory);
			}
			
			if (!loaded)
				return new GambiarraState(target, stopMusic, directory);
			//#end
			if (stopMusic && FlxG.sound.music != null)
				FlxG.sound.music.stop();
			
			return target;
		}
		
		//#if NO_PRELOAD_ALL
		static function isSoundLoaded(path:String):Bool
		{
			return Assets.cache.hasSound(path);
		}
		
		static function isLibraryLoaded(library:String):Bool
		{
			return Assets.getLibrary(library) != null;
		}
		//#end
	
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