#include "player_character.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

// --- CONSTRUCTOR ---
PlayerCharacter::PlayerCharacter() {
    move_speed = 200.0;
    can_move = true;
    interaction_range = 100.0; // Distancia inicial
    last_direction = Vector2(0, 1); // Mirando abajo por defecto
}

PlayerCharacter::~PlayerCharacter() {}

void PlayerCharacter::_ready() {
    if (Engine::get_singleton()->is_editor_hint()) return;
    
    // Intentamos obtener el rayo al inicio
    interaction_raycast = get_node<RayCast2D>("InteractionRayCast");
}

void PlayerCharacter::_physics_process(double delta) {
    if (Engine::get_singleton()->is_editor_hint()) return;

    Input* input = Input::get_singleton();

    // 1. Bloqueo de movimiento
    if (!can_move) {
        set_velocity(Vector2(0, 0));
        move_and_slide();
        return; 
    }

    // 2. Movimiento de 4 direcciones
    Vector2 input_dir = Vector2(0, 0);
    if (input->is_action_pressed("ui_right")) input_dir.x = 1;
    else if (input->is_action_pressed("ui_left")) input_dir.x = -1;
    else if (input->is_action_pressed("ui_down")) input_dir.y = 1;
    else if (input->is_action_pressed("ui_up")) input_dir.y = -1;

    Vector2 velocity = input_dir * move_speed;
    set_velocity(velocity);
    move_and_slide();

    // 3. Actualizar dirección y Raycast
    if (velocity.length() > 0) {
        last_direction = velocity.normalized();
    }

    if (interaction_raycast) {
        // El largo del rayo ahora depende de interaction_range
        interaction_raycast->set_target_position(last_direction * interaction_range);
    }
}

// --- SISTEMA DE INTERACCIÓN ---
void PlayerCharacter::interact() {
    // Lazy Initialization: Si es nulo, lo busca de nuevo
    if (!interaction_raycast) {
        interaction_raycast = get_node<RayCast2D>("InteractionRayCast");
    }

    if (!interaction_raycast) {
        UtilityFunctions::print("ERROR: No se encontro InteractionRayCast");
        return;
    }

    interaction_raycast->force_raycast_update(); // Precisión en el frame actual

    if (interaction_raycast->is_colliding()) {
        Object* collider = interaction_raycast->get_collider();
        
        if (collider && collider->has_method("activar")) {
            UtilityFunctions::print("Interactuando con: ", collider->get_class());
            collider->call("activar"); // Ejecuta el script del objeto
        }
    }
}

// --- GETTERS Y SETTERS ---
void PlayerCharacter::set_interaction_range(double p_range) { interaction_range = p_range; }
double PlayerCharacter::get_interaction_range() const { return interaction_range; }

void PlayerCharacter::set_can_move(bool p_value) { can_move = p_value; }
bool PlayerCharacter::get_can_move() const { return can_move; }

void PlayerCharacter::set_move_speed(double p_speed) { move_speed = p_speed; }
double PlayerCharacter::get_move_speed() const { return move_speed; }

Vector2 PlayerCharacter::get_last_direction() const { return last_direction; }

// --- REGISTRO PARA GODOT ---
void PlayerCharacter::_bind_methods() {
    // Propiedad: Velocidad
    ClassDB::bind_method(D_METHOD("get_move_speed"), &PlayerCharacter::get_move_speed);
    ClassDB::bind_method(D_METHOD("set_move_speed", "p_speed"), &PlayerCharacter::set_move_speed);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "move_speed"), "set_move_speed", "get_move_speed");
    
    // Propiedad: Control de Movimiento
    ClassDB::bind_method(D_METHOD("get_can_move"), &PlayerCharacter::get_can_move);
    ClassDB::bind_method(D_METHOD("set_can_move", "p_can_move"), &PlayerCharacter::set_can_move);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "can_move"), "set_can_move", "get_can_move");

    // Propiedad: Rango de Interacción (Aparecerá en el Inspector)
    ClassDB::bind_method(D_METHOD("get_interaction_range"), &PlayerCharacter::get_interaction_range);
    ClassDB::bind_method(D_METHOD("set_interaction_range", "p_range"), &PlayerCharacter::set_interaction_range);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "interaction_range"), "set_interaction_range", "get_interaction_range");

    ClassDB::bind_method(D_METHOD("get_last_direction"), &PlayerCharacter::get_last_direction);
    ClassDB::bind_method(D_METHOD("interact"), &PlayerCharacter::interact);
}