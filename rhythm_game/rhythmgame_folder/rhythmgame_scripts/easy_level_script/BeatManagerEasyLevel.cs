using Godot;
using System;
using System.Collections.Generic;

public partial class BeatManagerEasyLevel : Node
{
	[Export] public AudioStream Music;
	[Export] public float FallTime = 2.5f;       // time for notes to reach hit lane
	[Export] public float GlobalOffset = 1.4f;  // in secs [1.4f OG]
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

	// Track if music has been started
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
		
		//load music if not assigned 
		if (Music == null)
		{
			Music = GD.Load<AudioStream>("res://rhythmgame_folder/rhythmgame_assets/music/WeWishYouAMerryChristmas.wav");
		}
		_musicPlayer.Stream = Music;

		//load the beat map for Rhythm Hell
		LoadEasyWeWishBeatMap();

		GD.Print($"BeatManager ready. Waiting to start Music");
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
			GD.Print($"🎵 Music Started - {_beatMap.Count} notes)");
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

	private void LoadEasyWeWishBeatMap()
	{
		//blue lane notes
		float[] blueTimes = { 0.93655323982239f, 4.5414514541626f, 8.12603187561035f, 10.5031747817993f, 14.1080722808838f, 16.4561901092529f, 18.9000911712646f, 22.5049877166748f, 29.662540435791f, 32.1470756530762f, 35.6997261047363f, 39.3365516662598f, 40.5730171203613f, 45.3505210876465f, 48.8944664001465f, 53.7242164611816f, 56.1158714294434f, 59.7526969909668f, 62.1414489746094f, 68.1147842407227f, 72.8922882080078f, 74.1403656005859f, 76.5407257080078f, 77.7133331298828f, 83.6866683959961f, 87.3031768798828f, 90.6323318481445f, 92.9049911499023f };

		//green lane notes
		float[] greenTimes = { -0.29120182991028f, 3.40947866439819f, 12.8599996566772f, 14.1312923431396f, 16.4678001403809f, 17.7478008270264f, 20.0726985931396f, 24.9053516387939f, 28.4986400604248f, 34.4922904968262f, 36.9477996826172f, 39.368480682373f, 40.5527000427246f, 44.1140594482422f, 46.5463485717773f, 54.9084358215332f, 57.3087997436523f, 60.8933792114258f, 62.1414489746094f, 65.6941070556641f, 68.0944671630859f, 71.6877517700195f, 75.4435806274414f, 77.7133331298828f, 80.0614547729492f, 84.914421081543f, 88.562858581543f, 91.7294769287109f, 94.5361938476563f };

		//red lane notes
		float[] redTimes = { 0.98009061813354f, 5.73727893829346f, 9.33056735992432f, 11.7106122970581f, 15.3038997650146f, 23.7095241546631f, 30.8990020751953f, 32.1151466369629f, 38.1407241821289f, 39.3568725585938f, 42.9211349487305f, 51.3470764160156f, 56.1042633056641f, 58.4610900878906f, 59.7410888671875f, 64.5098876953125f, 69.1800003051758f, 74.1403656005859f, 78.8975524902344f, 82.4821319580078f, 88.0926513671875f, 93.3084335327148f };

		//yellow lane notes
		float[] yellowTimes = { 2.1526985168457f, 6.94181442260742f, 9.34217643737793f, 15.3155097961426f, 17.7565078735352f, 21.3207702636719f, 27.2824935913086f, 33.2993659973145f, 35.6997261047363f, 41.7253074645996f, 47.6870307922363f, 50.1425399780273f, 52.4993667602539f, 57.3087997436523f, 60.9253044128418f, 63.3024520874023f, 66.9189605712891f, 70.4919281005859f, 78.8975524902344f, 81.3298416137695f, 86.0986404418945f, 89.7238540649414f, 92.5189590454102f, 94.556510925293f };

		// Normal mode
		int step = 1; //default is 1

		AddNotes(blueTimes, "blue", step);
		AddNotes(greenTimes, "green", step);
		AddNotes(redTimes, "red", step);
		AddNotes(yellowTimes, "yellow", step);

		//Sort by time so notes spawn in order
		_beatMap.Sort((a, b) => a.time.CompareTo(b.time));

		GD.Print($"Loaded {_beatMap.Count} notes for Easy We Wish");
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
		LoadEasyWeWishBeatMap();

		GD.Print("BeatManager reset");
	}
}
