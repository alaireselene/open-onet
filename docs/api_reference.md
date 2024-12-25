using Godot;
using System;

public partial class GameBoard : Node2D
{
	// Set grid dimensions
	private int rows = 6;
	private int columns = 10;
	private int tileSize = 64;

	// The Tile scene
	private PackedScene tileScene;

	public override void _Ready()
	{
		// Load the Tile scene
		tileScene = (PackedScene)ResourceLoader.Load("res://Tile.tscn");

		// Create the grid
		CreateGrid();
	}

	private void CreateGrid()
	{
		for (int row = 0; row < rows; row++)
		{
			for (int col = 0; col < columns; col++)
			{
				// Instantiate a new tile
				var tileInstance = (Node2D)tileScene.Instantiate();
				
				// Set tile position in the grid
				tileInstance.Position = new Vector2(col * tileSize, row * tileSize);
				
				// Add tile to the GameBoard
				AddChild(tileInstance);
			}
		}
	}
}
