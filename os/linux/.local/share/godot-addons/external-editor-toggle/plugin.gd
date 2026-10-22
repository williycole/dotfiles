@tool
extends EditorPlugin

## Flip between Godot's built-in script editor and the external one (nvim).
##
## WHY NOT THE ASSET-LIBRARY PLUGIN (asset 2646): it locates the toolbar with a
## hardcoded auto-generated node path — /root/@EditorNode@21272/@Panel@14/... —
## which is a per-build identifier, so it silently falls back to a floating
## button at a fixed pixel position on any Godot that isn't the author's. It is
## also a button, not a shortcut.
##
## BINDING IS Ctrl+Alt+E, NOT Ctrl+E. godot-neovim forwards keys to a real
## Neovim, where Ctrl+E scrolls the view down one line. Taking Ctrl+E here would
## quietly break a standard vim motion, and the conflict would be very hard to
## attribute.

const SETTING := "text_editor/external/use_external_editor"


func _enter_tree() -> void:
	# Menu entry as well as the shortcut, so the feature is discoverable and
	# shows its own binding rather than living only in this file.
	add_tool_menu_item("Toggle External Editor (Ctrl+Alt+E)", _toggle)


func _exit_tree() -> void:
	remove_tool_menu_item("Toggle External Editor (Ctrl+Alt+E)")


func _shortcut_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E and event.ctrl_pressed and event.alt_pressed:
			_toggle()
			# Without this the key also reaches Neovim, which would act on it.
			get_viewport().set_input_as_handled()


func _toggle() -> void:
	var settings := EditorInterface.get_editor_settings()
	var external: bool = settings.get_setting(SETTING)
	settings.set_setting(SETTING, not external)
	# A toast, because the only other feedback is the next script you open going
	# somewhere unexpected.
	var where := "nvim (external)" if not external else "Godot (built-in)"
	print_rich("[b]Script editor:[/b] " + where)
