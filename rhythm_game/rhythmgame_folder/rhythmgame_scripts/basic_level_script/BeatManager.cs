using Godot;
using System;

public partial class BeatManager : Node
{
	[Export] public float Bpm = 120f;          // song BPM
	[Export] public float Offset = 0.2f;       // audio latency (opt)
	[Export] public bool EasyMode = true;      // how often notes spawn

	//signal
	[Signal] public delegate void SpawnButtonEventHandler(string buttonColor);

	//internals
	private float _beatInterval;            //secs per beat
	private float _timer = 0f;
	private Random _rng = new Random();

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		_beatInterval = 60f / Bpm;          // 120bpm = 0.5 secs per beat
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		_timer += (float)delta;

		if (_timer >= _beatInterval + Offset)
		{
			_timer -= _beatInterval;    //reset timer to loop

			SpawnNote();
		}
	}

	private void SpawnNote()
	{
		string[] colors = { "blue", "green", "red", "yellow" };

		//easy mode : spawn less often
		if (EasyMode)
		{
			if (_rng.Next(0, 100) > 35)     //35% chance to spawn
				return;
		}

		//spawns in random lanes
		int randomIndex = _rng.Next(0, colors.Length);
		string chosenColor = colors[randomIndex];

		EmitSignal(SignalName.SpawnButton, chosenColor);
	}
}
