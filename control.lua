-- Initialize platform connections
script.on_init(
    function()
        update_all_platform_connections()
    end
)

script.on_configuration_changed(
    function()
        update_all_platform_connections()
    end
)

-- Update when platform state changed
script.on_event(defines.events.on_space_platform_changed_state,
    function(event)
        -- skip if surface is not generated
        if not event.platform.surface then return end
        
        local planet_surface = get_planet_surface(event.platform)
        -- local space_radars = event.platform.surface.find_entities_filtered{name="radar"}

        if planet_surface then
            connect_platform(event.platform, planet_surface)
        else
            disconnect_platform(event.platform)
        end
    end
)

function update_all_platform_connections()
    for _, surface in pairs(game.surfaces) do
        if surface.platform then
            local planet_surface = get_planet_surface(surface.platform)
            if planet_surface then
                connect_platform(surface.platform, planet_surface)
            else
                disconnect_platform(surface.platform)
            end
        end
    end
end

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

function connect_platform(platform, planet_surface)
    local platform_surface = platform.surface
    if not platform.surface then return end

    -- init platform radar connector
    local platform_radar = platform_surface.find_entities_filtered{name="interorbital-radar-connector", force=platform.force}
    local platform_connector = nil
    if #platform_radar == 0 then
        platform_connector = platform_surface.create_entity{name="interorbital-radar-connector", position={x = 0.0, y = 0.0}, force=platform.force}
    else
        platform_connector = platform_radar[1]
    end

    -- init planet radar connector
    local planet_radar = planet_surface.find_entities_filtered{name="interorbital-radar-connector", force=platform.force}
    local planet_connector = nil
    if #planet_radar == 0 then
        planet_connector = planet_surface.create_entity{name="interorbital-radar-connector", position={x = 0.0, y = 0.0}, force=platform.force}
    else
        planet_connector = planet_radar[1]
    end

    -- connect platform & planet
    local red_connector = platform_connector.get_wire_connector(defines.wire_connector_id.circuit_red, true)
    local green_connector = platform_connector.get_wire_connector(defines.wire_connector_id.circuit_green, true)
    local planet_red_connector = planet_connector.get_wire_connector(defines.wire_connector_id.circuit_red, true)
    local planet_green_connector = planet_connector.get_wire_connector(defines.wire_connector_id.circuit_green, true)
    red_connector.connect_to(planet_red_connector, false, defines.wire_origin.script)
    green_connector.connect_to(planet_green_connector, false, defines.wire_origin.script)
end

function disconnect_platform(platform)
    local platform_surface = platform.surface
    if not platform.surface then return end
    local platform_radar = platform_surface.find_entities_filtered{name="interorbital-radar-connector", force=platform.force}
    local platform_connector = nil
    if #platform_radar == 0 then
        return
    else
        platform_connector = platform_radar[1]
    end

    local red_connectors = platform_connector.get_wire_connector(defines.wire_connector_id.circuit_red, true)
    local green_connectors = platform_connector.get_wire_connector(defines.wire_connector_id.circuit_green, true)
    for _, connection in pairs(red_connectors.connections) do
        if connection.target.owner.surface ~= platform.surface then
            red_connectors.disconnect_from(connection.target, defines.wire_origin.script)
        end
    end
    for _, connection in pairs(green_connectors.connections) do
        if connection.target.owner.surface ~= platform.surface then
            green_connectors.disconnect_from(connection.target, defines.wire_origin.script)
        end
    end
end
