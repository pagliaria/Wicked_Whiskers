extends Control

func _ready() -> void:
	# Cat: spritesheet with 16x16 frames, show first frame
	var cat_atlas = AtlasTexture.new()
	cat_atlas.atlas = load("res://assets/sprites/cat_idle.png")
	cat_atlas.region = Rect2(0, 0, 400, 467)
	$Panel/ScrollContainer/Content/CatsGrid/HappyCatBox/HappyCatRow/CatImg.texture = cat_atlas
	$Panel/ScrollContainer/Content/CatsGrid/HappyCatBox/HappyCatRow/CatImg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	$Panel/ScrollContainer/Content/CatsGrid/HappyCatBox/HappyCatRow/CatImg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	# Cat: spritesheet with 16x16 frames, show first frame
	var angry_cat_atlas = AtlasTexture.new()
	angry_cat_atlas.atlas = load("res://assets/sprites/cat_idle.png")
	angry_cat_atlas.region = Rect2(0, 0, 400, 467)
	$Panel/ScrollContainer/Content/CatsGrid/AngryCatBox/AngryCatRow/CatImg.texture = angry_cat_atlas
	$Panel/ScrollContainer/Content/CatsGrid/AngryCatBox/AngryCatRow/CatImg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	$Panel/ScrollContainer/Content/CatsGrid/AngryCatBox/AngryCatRow/CatImg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	$Panel/ScrollContainer/Content/CatsGrid/AngryCatBox/AngryCatRow/CatImg.modulate = Color.RED
	
	# Cat: spritesheet with 16x16 frames, show first frame
	var sup_cat_atlas = AtlasTexture.new()
	sup_cat_atlas.atlas = load("res://assets/sprites/cat_idle.png")
	sup_cat_atlas.region = Rect2(0, 0, 400, 467)
	$Panel/ScrollContainer/Content/CatsGrid/SurprisedCatBox/SurprisedCatRow/CatImg.texture = sup_cat_atlas
	$Panel/ScrollContainer/Content/CatsGrid/SurprisedCatBox/SurprisedCatRow/CatImg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	$Panel/ScrollContainer/Content/CatsGrid/SurprisedCatBox/SurprisedCatRow/CatImg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	$Panel/ScrollContainer/Content/CatsGrid/SurprisedCatBox/SurprisedCatRow/CatImg.modulate = Color.GREEN
	
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

func _on_close_pressed() -> void:
	queue_free()
