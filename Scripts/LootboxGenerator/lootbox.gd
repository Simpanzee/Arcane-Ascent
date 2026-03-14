extends Node

# Generates lootboxes based on rarity, size, luck, and count
# rarity: int >= 1
# size: int >= 1
# luck: 0.0 to 1.0
# count: number of lootboxes to generate
func generate_loot(rarity: int, size: int, luck: float, count: int) -> Array:
	var output_batch : Array = []

	for i in range(count):
		var items_dict : Dictionary = {}
		var box_tier = rarity
		
		items_dict[box_tier + 1] = 0
		items_dict[box_tier] = 0
		if box_tier - 1 > 0:
			items_dict[box_tier - 1] = 0
		if box_tier - 2 > 0:
			items_dict[box_tier - 2] = 0

		var min_items = 2 * size
		var max_items = int(2 * size + 2 * sqrt(size))
		var total_items = randi_range(min_items, max_items)
		var num_items = 0
		var guaranteed_num_of_matching_rarity = size

		if box_tier == 1:
			items_dict[box_tier] += guaranteed_num_of_matching_rarity
			num_items = guaranteed_num_of_matching_rarity

			var tiers = [box_tier + 1, box_tier]
			var weights = [25 + 75 * luck, 75 - 75 * luck]

			while num_items < total_items:
				var chosen_tier = weighted_choice(tiers, weights)
				items_dict[chosen_tier] += 1
				num_items += 1

		elif box_tier == 2:
			items_dict[box_tier] += guaranteed_num_of_matching_rarity
			num_items = guaranteed_num_of_matching_rarity

			var tiers = [box_tier + 1, box_tier, box_tier - 1]
			var weights = [10 + 90 * luck, 40 - 40 * luck, 50 - 50 * luck]

			while num_items < total_items:
				var chosen_tier = weighted_choice(tiers, weights)
				items_dict[chosen_tier] += 1
				num_items += 1

		else:
			items_dict[box_tier] += guaranteed_num_of_matching_rarity
			num_items = guaranteed_num_of_matching_rarity

			var tiers = [box_tier + 1, box_tier, box_tier - 1, box_tier - 2]
			var weights = [5 + 95 * luck, 40 - 40 * luck, 45 - 45 * luck, 10 - 10 * luck]

			while num_items < total_items:
				var chosen_tier = weighted_choice(tiers, weights)
				items_dict[chosen_tier] += 1
				num_items += 1

		var output : Dictionary = {
			"box_tier": rarity,
			"size": size,
			"luck": luck,
			"total_items": total_items,
			"loot": {}
		}

		for key in items_dict.keys():
			var value = items_dict[key]
			if value > 0:
				output["loot"]["Tier %d" % key] = value

		output_batch.append(output)

	return output_batch


# Helper function to mimic Python's random.choices with weights
func weighted_choice(choices: Array, weights: Array) -> int:
	var total = 0.0
	for w in weights:
		total += w
	var rnd = randf() * total
	var cumulative = 0.0
	for i in range(choices.size()):
		cumulative += weights[i]
		if rnd <= cumulative:
			return choices[i]
	return choices[-1]
