-- Update when platform state changed
script.on_event(defines.events.on_space_platform_changed_state,
  function(event)
    -- skip if surface is not generated
    if not event.platform.surface then return end
    
    local planet_surface = get_planet_surface(event.platform)
    local space_radars = event.platform.surface.find_entities_filtered{name="radar"}

    if planet_surface then
        -- connect to planet
        for _, radar in pairs(space_radars) do
            if radar.status == defines.entity_status.working then
                connect_to_planet(radar, planet_surface)
            end
        end
    else
        -- disconnect
        for _, radar in pairs(space_radars) do
            reset_radar_connections(radar)
        end
    end
  end
)

-- Update when new radar built
script.on_event(defines.events.on_space_platform_built_entity,
  function(event)
    local planet_surface = get_planet_surface(event.platform)
    if planet_surface and event.entity.name == "radar" and event.entity.status == defines.entity_status.working then
        connect_to_planet(event.entity, planet_surface)
    end
  end
)

-- Update every 60 tick on platforms
script.on_nth_tick(60, 
  function()
    for _, surface in pairs(game.surfaces) do
        if surface.platform then
            local planet_surface = get_planet_surface(surface.platform)
            if planet_surface then
                local space_radars = surface.find_entities_filtered{name="radar"}
                for _, radar in pairs(space_radars) do
                    if radar.status == defines.entity_status.working then
                        connect_to_planet(radar, planet_surface)
                    end
                    if radar.status ~= defines.entity_status.working then
                        reset_radar_connections(radar)
                    end
                end
            end
        end
    end
  end
)

function get_planet_surface(platform)
    local planet_location = platform.space_location
    if planet_location then
        for _, planet in pairs(game.planets) do
            if planet.prototype == planet_location then
                return planet.surface
            end
        end
    end
    return nil
end

function connect_to_planet(radar, planet_surface)
    local planet_radars = planet_surface.find_entities_filtered{name="planet-radar-connector", force=radar.force}
    local planet_radar_connector = nil
    if #planet_radars == 0 then
        planet_radar_connector = planet_surface.create_entity{name="planet-radar-connector", position={x = 0.0, y = 0.0}, force=radar.force}
    else
        planet_radar_connector = planet_radars[1]
    end
    local red_connector = radar.get_wire_connector(defines.wire_connector_id.circuit_red, true)
    local green_connector = radar.get_wire_connector(defines.wire_connector_id.circuit_green, true)
    local planet_red_connector = planet_radar_connector.get_wire_connector(defines.wire_connector_id.circuit_red, true)
    local planet_green_connector = planet_radar_connector.get_wire_connector(defines.wire_connector_id.circuit_green, true)
    red_connector.connect_to(planet_red_connector, false, defines.wire_origin.script)
    green_connector.connect_to(planet_green_connector, false, defines.wire_origin.script)
end

function reset_radar_connections(radar)
    local red_connectors = radar.get_wire_connector(defines.wire_connector_id.circuit_red, true)
    local green_connectors = radar.get_wire_connector(defines.wire_connector_id.circuit_green, true)
    for _, connection in pairs(red_connectors.connections) do
        if connection.target.owner.surface ~= radar.surface then
            red_connectors.disconnect_from(connection.target, defines.wire_origin.script)
        end
    end
    for _, connection in pairs(green_connectors.connections) do
        if connection.target.owner.surface ~= radar.surface then
            green_connectors.disconnect_from(connection.target, defines.wire_origin.script)
        end
    end
end
