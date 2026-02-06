#include "player_character.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/variant/utility_functions.hpp> // <--- 1. NUEVO: Para usar print()

using namespace godot;

PlayerCharacter::PlayerCharacter() {
    move_speed = 50.0;
    last_direction = Vector2(0, 1);
}

PlayerCharacter::~PlayerCharacter() {
    // Nada que limpiar
}

void PlayerCharacter::_bind_methods() {
    ClassDB::bind_method(D_METHOD("set_move_speed", "p_speed"), &PlayerCharacter::set_move_speed);
    ClassDB::bind_method(D_METHOD("get_move_speed"), &PlayerCharacter::get_move_speed);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "move_speed"), "set_move_speed", "get_move_speed");
    
    ClassDB::bind_method(D_METHOD("get_last_direction"), &PlayerCharacter::get_last_direction); 
    ADD_PROPERTY(PropertyInfo(Variant::VECTOR2, "last_direction"), "", "get_last_direction");

    // <--- 2. NUEVO: Registramos la función interact para usarla en GDScript
    ClassDB::bind_method(D_METHOD("interact"), &PlayerCharacter::interact);
}

// <--- 3. NUEVO: Función _ready para conectar el nodo RayCast
void PlayerCharacter::_ready() {
    if (Engine::get_singleton()->is_editor_hint()) return;

    interaction_raycast = get_node<RayCast2D>("InteractionRayCast");
    
    if (!interaction_raycast) {
        UtilityFunctions::print("ERROR: No se encontró el nodo 'InteractionRayCast'.");
    } else {

        interaction_raycast->set_enabled(true); 
        interaction_raycast->set_target_position(Vector2(0, 50)); // Un rayo de 50px
        interaction_raycast->set_collision_mask(1); // Detectar la capa 1 (donde suele estar todo)
        
        UtilityFunctions::print("RayCast configurado y LISTO."); // Para confirmar que pasó por aquí
        interaction_raycast->set_collide_with_areas(true);  // ¡DETECTAR ÁREAS!
        interaction_raycast->set_collide_with_bodies(true); // Detectar paredes
        
        UtilityFunctions::print("RayCast configurado (Áreas y Cuerpos).");
    }
}

void PlayerCharacter::_physics_process(double delta) {
    if (Engine::get_singleton()->is_editor_hint()) return;

    // 1. Movimiento
    Input* input = Input::get_singleton();
    Vector2 input_dir = input->get_vector("ui_left", "ui_right", "ui_up", "ui_down");
    
    Vector2 velocity = input_dir * move_speed;
    set_velocity(velocity);
    move_and_slide();

    // 2. Actualizar dirección (Para saber a dónde mira Diego)
    if (velocity.length() > 0) {
        last_direction = velocity.normalized();
    }

    // 3. Actualizar RayCast (Ahora sí sigue a Diego)
    if (interaction_raycast) {
        interaction_raycast->set_target_position(last_direction * 50); // 50px en la dirección que miras
    }
}

// <--- 5. NUEVO: La implementación de la lógica de interacción
void PlayerCharacter::interact() {
    if (interaction_raycast && interaction_raycast->is_colliding()) {
        Object* collider = interaction_raycast->get_collider();
        if (collider) {
            // Preguntamos si el objeto tiene el método "activar"
            if (collider->has_method("activar")) {
                collider->call("activar"); // ¡BINGO!
            } else {
                // Opcional: Para saber si chocamos con algo que no es interactuable (como el TileMap)
                UtilityFunctions::print("Chocando con: ", collider->get_class(), " (No tiene activar)");
            }
        }
    }
}

// Getters y Setters
void PlayerCharacter::set_move_speed(double p_speed) { move_speed = p_speed; }
double PlayerCharacter::get_move_speed() const { return move_speed; }
Vector2 PlayerCharacter::get_last_direction() const { return last_direction; }