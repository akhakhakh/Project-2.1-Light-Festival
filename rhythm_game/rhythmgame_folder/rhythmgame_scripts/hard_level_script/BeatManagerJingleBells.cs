using Godot;
using System;
using System.Collections.Generic;

public partial class BeatManagerJingleBells : Node
{
	[Export] public AudioStream Music;
	[Export] public float FallTime = 5f;       // FASTER fall time for 186 BPM (was 2.2f)
	[Export] public bool NormalMode = false;        // Enable normal mode (normal notes)
	[Export] public float GlobalOffset = 1.2f;  // Adjusted offset for faster song
	[Export] public float TimingScale = 1.0f;   // multiplier to fix drift (no change)

	//signal to spawn notes
	[Signal] public delegate void SpawnButtonEventHandler(string buttonColor);
	
	//Signal for when song finishes
	[Signal] public delegate void SongFinishedEventHandler();
	
	public enum MusicMode { None, Menu, Gameplay };
	public MusicMode CurrentMode { get; private set; } = MusicMode.None;

	//music player
	private AudioStreamPlayer _musicPlayer;

	//beat map: List of (time, color) pairs
	private List<(float time, string color)> _beatMap = new List<(float time, string color)>();

	//track which notes have been spawned
	private int _nextNoteIndex = 0;

	//Track if music has been started
	private bool _musicStarted = false;
	
	//Track if music has been finished
	private bool _songFinished = false;

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		//create music player
		_musicPlayer = new AudioStreamPlayer();
		AddChild(_musicPlayer);
		
		//Connect to finished signal
		_musicPlayer.Finished += OnMusicFinished;

		//load music
		if (Music == null)
		{
			Music = GD.Load<AudioStream>("res://rhythmgame_folder/rhythmgame_assets/music/Jingle Bells.wav");
		}
		_musicPlayer.Stream = Music;

		//load the beat map for Jingle Bells
		LoadJingleBellsBeatMap();

		GD.Print($"BeatManagerJingleBells ready. Waiting to start Music");
	}
	
	//Called when the song is finished
	private void OnMusicFinished()
	{
		if (_songFinished)
			return; // Prevent multiple calls
		
		_songFinished = true;
		GD.Print("Song finished! Preparing results...");
		
		// Emit signal to notify other scripts
		EmitSignal(SignalName.SongFinished);
		
		// Wait 2 seconds for final notes to land, then go to results
		GetTree().CreateTimer(2.0).Timeout += GoToResultsScreen;
	}
	
	private void GoToResultsScreen()
	{
		GD.Print("Going to results screen...");
		
		// Change to your results/winning scene
		GetTree().ChangeSceneToFile("res://rhythmgame_folder/rhythmgame_scenes/win_menu/win_scene.tscn");
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		if (_nextNoteIndex < _beatMap.Count)
		{
			float currentTime = (float)_musicPlayer.GetPlaybackPosition();
			var (spawnTime, color) = _beatMap[_nextNoteIndex];

			//spawn note early by FallTime so it reaches the lane by beat
			if (currentTime >= spawnTime)
			{
				EmitSignal(SignalName.SpawnButton, color);
				_nextNoteIndex++;
			}
		}
	}

	public void StartMusic()
	{
		if (!_musicStarted)
		{
			_musicPlayer.Play();
			_musicStarted = true;
			GD.Print($"Jingle Bells Started ({(NormalMode ? "Normal" : "Hard")} Mode - {_beatMap.Count} notes)");
		}
	}

	// Public method to stop music (called on game over)
	public void StopMusic()
	{
		if (_musicPlayer != null && _musicPlayer.Playing)
		{
			_musicPlayer.Stop();
			GD.Print("Music stopped - Game Over");
		}
	}

	private void LoadJingleBellsBeatMap()
	{
		//blue lane notes
		float[] blueTimes = { 2.75795936584473f, 5.30634927749634f, 7.73863983154297f, 9.71233558654785f, 10.9604082107544f, 12.7947845458984f, 15.3025398254395f, 17.2007713317871f, 18.533016204834f, 22.0334243774414f, 24.1232204437256f, 27.3014507293701f, 27.8993644714355f, 29.8411331176758f, 31.0572776794434f, 32.9961433410645f, 35.515510559082f, 36.1134223937988f, 39.8547401428223f, 42.3944206237793f, 44.1765518188477f, 46.7133331298828f, 47.4070281982422f, 53.6590003967285f, 54.3410873413086f, 57.5193214416504f, 59.4088439941406f, 61.8614501953125f, 64.3895263671875f, 66.8972778320313f, 68.7838973999023f, 70.9694747924805f, 72.2291641235352f, 73.7326507568359f, 78.1705703735352f, 80.025260925293f, 82.3936996459961f, 84.8695220947266f, 88.390251159668f, 90.8863983154297f, 93.4028549194336f, 94.6625366210938f, 95.8873901367188f, 97.1673889160156f, 98.1281204223633f, 99.3761901855469f };

		//green lane notes
		float[] greenTimes = { 4.63587284088135f, 7.10009098052979f, 9.0941047668457f, 11.5147848129272f, 13.4449434280396f, 16.0484809875488f, 17.8625392913818f, 20.9856243133545f, 23.5136966705322f, 29.1561450958252f, 32.3053512573242f, 34.8653526306152f, 38.5747375488281f, 41.7239456176758f, 43.5902481079102f, 46.0747833251953f, 48.0165519714355f, 50.6171875f, 52.4747848510742f, 53.1365547180176f, 56.1870765686035f, 58.6716117858887f, 61.2316093444824f, 63.7799987792969f, 66.2761459350586f, 67.515510559082f, 70.6618118286133f, 71.8982772827148f, 73.0708847045898f, 74.4060287475586f, 79.450569152832f, 81.2094802856445f, 83.673698425293f, 87.6530151367188f, 90.1694793701172f, 92.7933349609375f, 94.3722915649414f, 95.556510925293f, 96.2182769775391f, 97.8088455200195f, 99.0569152832031f, 100.273063659668f };

		//red lane notes
		float[] redTimes = { 3.37619066238403f, 6.01165533065796f, 8.0579137802124f, 10.5975961685181f, 14.0631742477417f, 14.6930160522461f, 19.1947841644287f, 21.5400009155273f, 24.8372344970703f, 26.0736961364746f, 26.587438583374f, 30.4042167663574f, 33.5853500366211f, 36.4326972961426f, 37.393424987793f, 40.5078010559082f, 44.8470306396484f, 48.5912475585938f, 49.2326965332031f, 54.9070739746094f, 56.8807716369629f, 59.9516105651855f, 62.5f, 64.9322891235352f, 69.4659881591797f, 71.2481155395508f, 75.0561904907227f, 76.8470306396484f, 77.5407257080078f, 81.8190002441406f, 86.4368743896484f, 89.0171890258789f, 91.5133361816406f, 93.7221298217773f, 94.9266662597656f, 96.8916549682617f, 98.5112457275391f, 99.6838531494141f };

		//yellow lane notes
		float[] yellowTimes = { 4.01473903656006f, 6.58634948730469f, 8.38009071350098f, 10.2231750488281f, 12.1126985549927f, 16.6347846984863f, 19.7288436889648f, 20.2716102600098f, 22.6284351348877f, 25.4467582702637f, 28.5698413848877f, 31.6638984680176f, 34.2355117797852f, 38.0116539001465f, 39.2684364318848f, 41.0621757507324f, 43.0445823669434f, 45.4768714904785f, 49.9031753540039f, 51.2151031494141f, 51.7926979064941f, 55.5775527954102f, 58.0736961364746f, 60.6453056335449f, 63.1530609130859f, 65.6492080688477f, 68.1105194091797f, 70.0203628540039f, 71.5906143188477f, 75.6308822631836f, 76.2084808349609f, 78.8207244873047f, 80.5593185424805f, 82.9916076660156f, 85.5835342407227f, 87.0986404418945f, 89.6470260620117f, 92.15478515625f, 92.2941055297852f, 94.0326995849609f, 95.2256240844727f, 96.4969177246094f, 97.5505218505859f, 98.8218154907227f, 100.955146789551f };

		// Normal mode
		int step = 1; //default is 1

		AddNotes(blueTimes, "blue", step);
		AddNotes(greenTimes, "green", step);
		AddNotes(redTimes, "red", step);
		AddNotes(yellowTimes, "yellow", step);

		//Sort by time so notes spawn in order
		_beatMap.Sort((a, b) => a.time.CompareTo(b.time));

		GD.Print($"Loaded {_beatMap.Count} notes for Jingle Bells (Glee) - 186 BPM!");
	}

	private void AddNotes(float[] times, string color, int step)
	{
		for (int i = 0; i < times.Length; i += step)
		{
			//apply timing scale + global offset
			float spawnTime = (times[i] * TimingScale) - FallTime + GlobalOffset;
			_beatMap.Add((spawnTime, color));
		}
	}
	
	public void Reset()
	{
		_nextNoteIndex = 0;
		_musicStarted = false;

		if (_musicPlayer != null)
			_musicPlayer.Stop();

		_beatMap.Clear();
		LoadJingleBellsBeatMap();

		GD.Print("BeatManager reset");
	}
}
