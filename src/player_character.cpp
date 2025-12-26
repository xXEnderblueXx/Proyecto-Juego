#include "player_character.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/engine.hpp>

using namespace godot;

PlayerCharacter::PlayerCharacter() {
    move_speed = 200.0; // Velocidad inicial (Ajusten esto en el godot por si es muy rapido o lento)
}

PlayerCharacter::~PlayerCharacter() {
    // Nada que limpiar por ahora xdxdxd
}

void PlayerCharacter::_bind_methods() {
    // Registramos la variable 'move_speed' para que aparezca en el Inspector
    ClassDB::bind_method(D_METHOD("set_move_speed", "p_speed"), &PlayerCharacter::set_move_speed);
    ClassDB::bind_method(D_METHOD("get_move_speed"), &PlayerCharacter::get_move_speed);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "move_speed"), "set_move_speed", "get_move_speed");
}

void PlayerCharacter::_physics_process(double delta) {
    if (Engine::get_singleton()->is_editor_hint()) return;

    Input* input = Input::get_singleton();
    Vector2 input_vector = Vector2(0, 0);

    // Detectar teclas (WASD o Flechas) Voy a ver si proximamente le meto soporte para gamepad
    // "ui_right", "ui_left", etc. son acciones estándar de Godot
    input_vector.x = input->get_action_strength("ui_right") - input->get_action_strength("ui_left");
    input_vector.y = input->get_action_strength("ui_down") - input->get_action_strength("ui_up");

    // Normalizar vector: Esto evita que correr en diagonal sea más rápido
    if (input_vector.length() > 0) {
        input_vector = input_vector.normalized();
    }

    // Aplicar la velocidad
    set_velocity(input_vector * move_speed);
    
    // Mover y deslizarse (maneja las colisiones automáticamente)
    move_and_slide();

}

// Getters y Setters
void PlayerCharacter::set_move_speed(double p_speed) { move_speed = p_speed; }
double PlayerCharacter::get_move_speed() const { return move_speed; }