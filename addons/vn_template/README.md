# Breakfast VN Template Notes

## Controls
- **WASD** to move the player.
- **Mouse** to look around.
- **E** to interact with highlighted objects.
- **I** to toggle the inventory grid.
- **J** to open the quest journal.
- **Esc** to open the top bar menu.

## Adding Items
Items are implemented as `VNItemResource` instances. They can be created in code or by instancing the resource script located at `addons/vn_template/inventory/item_resource.gd`. Populate the identifier, display name, stack size, and optional size override before registering the item with `Game.register_item()`.

## Adding Quests
Quests use the resource script at `addons/vn_template/quests/quest_resource.gd`. Create a new quest resource, fill in its id, title, description, and steps array, then register it with `Game.register_quest()`. Each step dictionary supports `id`, `text`, and `auto_complete` flags.

When you need to start a quest, call `Game.start_quest("quest_id")`. Update steps with `Game.complete_quest_step("quest_id", "step_id")`.
