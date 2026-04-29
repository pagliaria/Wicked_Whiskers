extends Control

func _on_close_pressed() -> void:
	queue_free()

func _ready() -> void:
	# Coin: spritesheet with 16x16 frames, show first frame
	var coin_atlas = AtlasTexture.new()
	coin_atlas.atlas = load("res://assets/sprites/coin.png")
	coin_atlas.region = Rect2(0, 0, 16, 16)
	$Panel/ScrollContainer/Content/CoinsRow/CoinsImgBox/CoinImg.texture = coin_atlas
	$Panel/ScrollContainer/Content/CoinsRow/CoinsImgBox/CoinImg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	$Panel/ScrollContainer/Content/CoinsRow/CoinsImgBox/CoinImg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	# Hell hound idle: spritesheet with 64x32 frames, show first frame
	var hound_atlas = AtlasTexture.new()
	hound_atlas.atlas = load("res://assets/sprites/characters/hell-hound-idle.png")
	hound_atlas.region = Rect2(0, 0, 64, 32)
	$Panel/ScrollContainer/Content/CoinsRow/CoinsImgBox/HoundImg.texture = hound_atlas
	$Panel/ScrollContainer/Content/CoinsRow/CoinsImgBox/HoundImg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	$Panel/ScrollContainer/Content/CoinsRow/CoinsImgBox/HoundImg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	# Build controls grid
	ControlsGrid.build($Panel/ScrollContainer/Content/ControlsGrid)
