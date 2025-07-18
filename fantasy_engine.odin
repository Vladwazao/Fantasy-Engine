package fantasy_engine

import rl "vendor:raylib"
import "core:fmt"
import "core:encoding/json"

Entity :: struct {
    id: int,
    name: string,
    components: [dynamic]string,
}

entity_counter: int = 1
entities: map[int]Entity = {}

create_entity :: proc(e_name: string) -> ^Entity {
    e_id := entity_counter
    entity_counter += 1

    ent := Entity{ id = e_id, name = e_name}
    entities[e_id] = ent
    return &entities[e_id]
}

ComponentFieldInfo :: struct {
    field_type: string,
    default_value: string,
}

component_metadata: map[string]map[string]ComponentFieldInfo = {}
//component_storage: map[string]map[int]any = {}

add_component_metadata :: proc(name: string, fields: map[string]ComponentFieldInfo) {
    component_metadata[name] = fields
}

add_component :: proc(entity: ^Entity, name: string, data: any) {
    append(&entity.components, name)

    // // Make sure store for this component exists
    // if _, ok := component_storage[name]; !ok {
    //     component_storage[name] = map[int]any{}
    // }

    // // Save data under entity.id
    // component_storage[name][entity.id] = data
}

// get_component :: proc(entity_id: int, name: string) -> any {
//     return component_storage[name][entity_id]
// }

set_component :: proc(entity_id: int, name: string, data: any) {
    // component_storage[name][entity_id] = data
}

remove_component :: proc(entity: ^Entity, name: string) {
    new_list: [dynamic]string = {}
    for c in entity.components {
        if c != name {
            append(&new_list, c)
        }
    }
    entity.components = new_list
    // delete_key(&component_storage[name], component_storage[name][entity.id])
}

System :: struct {
    name: string,
    init:  proc(),
    update: proc(dt: f32),
    exit:  proc(),
}

systems: [dynamic]System = {}

register_system :: proc(name: string, update: proc(dt: f32), init: proc() = nil, exit: proc() = nil) {
    append(&systems, System{name = name, update = update, init = init, exit = exit})
}

run_systems_init :: proc() {
    for sys in systems {
        if sys.init != nil {
            sys.init()
        }
    }
}

run_systems_update :: proc(dt: f32) {
    for sys in systems {
        sys.update(dt)
    }
}

run_systems_exit :: proc() {
    for sys in systems {
        if sys.exit != nil {
            sys.exit()
        }
    }
}

// =============================
// === UTILITY / TEMPLATE  ====
// =============================

EntityTemplate :: struct {
    name: string,
    components: map[string]any,
}

entity_templates: map[string]EntityTemplate = {}

register_entity_template :: proc(name: string, components: map[string]any) {
    entity_templates[name] = EntityTemplate{ name = name, components = components }
}

create_entity_from_template :: proc(name: string, pos: rl.Vector2) -> ^Entity {
    template := entity_templates[name]
    entity := create_entity(template.name)
    add_component(entity, "Position", pos)

    for comp_name, comp_data in template.components {
        add_component(entity, comp_name, comp_data)
    }
    return entity
}