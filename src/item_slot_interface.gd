extends PanelContainer


@onready var margin_container = $MarginContainer
@onready var texture_rect = margin_container.get_node("TextureRect")

func set_data(item: Item):
    texture_rect.texture = item.texture
    tooltip_text = "%s\n%s" % [item.name, item.description]

func _process(_delta: float) -> void:
    # Make texture bigger if mouse is over the item
    if is_mouse_over():
        # make margins of 4 pixels
        resize_margin(0)
    else:
        resize_margin(8)

func is_mouse_over() -> bool:
    return texture_rect.get_global_rect().has_point(get_viewport().get_mouse_position())

func resize_margin(margin: int) -> void:
    margin_container.add_theme_constant_override("margin_left", margin)
    margin_container.add_theme_constant_override("margin_right", margin)
    margin_container.add_theme_constant_override("margin_top", margin)
    margin_container.add_theme_constant_override("margin_bottom", margin)