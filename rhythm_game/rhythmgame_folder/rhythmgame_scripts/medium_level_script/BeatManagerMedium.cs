using Godot;
using System;
using System.Collections.Generic;

public partial class BeatManagerMedium : Node
{
	[Export] public AudioStream Music;
	[Export] public float FallTime = 2f;       // FASTER fall time for 186 BPM (was 2.2f)
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
			Music = GD.Load<AudioStream>("res://rhythmgame_folder/rhythmgame_assets/music/Deck The Halls Christmas.wav");
		}
		_musicPlayer.Stream = Music;

		//load the beat map for Jingle Bells
		LoadDeckTheHallBeatMap();

		GD.Print($"BeatManager_Medium ready. Waiting to start Music");
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
			GD.Print($"Deck The Hall Started - {_beatMap.Count} notes)");
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

	private void LoadDeckTheHallBeatMap()
	{
		//blue lane notes
		float[] blueTimes = { 3.45165538787842f, 6.24675750732422f, 8.97510242462158f, 12.7106122970581f, 16.3996829986572f, 21.9347400665283f, 28.4218139648438f, 31.1849899291992f, 33.881404876709f, 37.5849876403809f, 39.4599990844727f, 45.0182762145996f, 48.7102508544922f, 51.4385948181152f, 53.7751007080078f, 56.1116104125977f, 59.7600440979004f, 62.9905242919922f, 67.1614074707031f, 68.0582733154297f, 72.7399978637695f, 76.4000473022461f, 79.1080703735352f, 81.9351043701172f, 82.8522872924805f, 84.7098846435547f, 89.2755126953125f, 94.8424911499023f, 98.5025405883789f, 101.274421691895f, 104.96639251709f, 107.790519714355f };

		//green lane notes
		float[] greenTimes = { 4.40947866439819f, 8.06952381134033f, 11.781813621521f, 13.627799987793f, 18.2137413024902f, 19.174467086792f, 23.7923355102539f, 27.4291610717773f, 32.955509185791f, 35.7709312438965f, 38.5341033935547f, 45.9354629516602f, 50.533016204834f, 55.1305656433105f, 58.8109283447266f, 62.5319290161133f, 65.2951049804688f, 66.2558288574219f, 74.5105209350586f, 78.2228088378906f, 82.3936996459961f, 86.5210418701172f, 90.1926956176758f, 92.9878005981445f, 97.5505218505859f, 100.368843078613f, 104.025985717773f };

		//red lane notes
		float[] redTimes = { 5.30634927749634f, 10.8326988220215f, 14.5014514923096f, 20.0597286224365f, 21.4442176818848f, 24.6659870147705f, 26.5119724273682f, 30.2242622375488f, 34.833423614502f, 40.3452606201172f, 41.2653503417969f, 44.0894775390625f, 47.7379150390625f, 52.3673934936523f, 54.2336959838867f, 57.893741607666f, 60.6975517272949f, 63.4171905517578f, 70.8330612182617f, 71.790885925293f, 75.4189987182617f, 80.0571899414063f, 85.5835342407227f, 87.9200439453125f, 91.1098861694336f, 96.676872253418f, 102.255462646484f, 105.903900146484f, 108.228797912598f };

		//yellow lane notes
		float[] yellowTimes = { 2.70281171798706f, 7.17265319824219f, 9.93582725524902f, 15.4505672454834f, 17.360408782959f, 20.9972343444824f, 22.8316097259521f, 25.5628566741943f, 29.2635383605957f, 32.1108856201172f, 36.6561889648438f, 42.3102493286133f, 43.1519737243652f, 46.8323364257813f, 49.6042175292969f, 53.3078002929688f, 54.6400451660156f, 56.9852600097656f, 61.5828132629395f, 64.3895263671875f, 68.9870758056641f, 69.8926544189453f, 73.5933303833008f, 77.2649917602539f, 80.9656677246094f, 83.7491607666016f, 87.4614486694336f, 88.390251159668f, 92.0793228149414f, 93.8933792114258f, 95.7712936401367f, 99.4603652954102f, 103.195869445801f, 106.853012084961f, 108.699005126953f };

		// Normal mode
		int step = 1; //default is 1

		AddNotes(blueTimes, "blue", step);
		AddNotes(greenTimes, "green", step);
		AddNotes(redTimes, "red", step);
		AddNotes(yellowTimes, "yellow", step);

		//Sort by time so notes spawn in order
		_beatMap.Sort((a, b) => a.time.CompareTo(b.time));

		GD.Print($"Loaded {_beatMap.Count} notes for Deck The Hall - 100 BPM!");
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
		LoadDeckTheHallBeatMap();

		GD.Print("BeatManager reset");
	}
}
