local interorbital_radar_connector = {
    type = "radar",
    name = "interorbital-radar-connector",
    connects_to_other_radars = true,
    energy_usage = "1W",
    energy_per_sector = "1GJ",
    energy_per_nearby_scan = "1GJ",
    energy_source = {type = "void"},
    max_distance_of_sector_revealed = 0,
    max_distance_of_nearby_sector_revealed = 0,
    draw_circuit_wires = false,
    hidden = true,
    hidden_in_factoriopedia = true
}

data:extend{interorbital_radar_connector}