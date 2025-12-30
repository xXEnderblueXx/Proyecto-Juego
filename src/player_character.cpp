#include "player_character.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/engine.hpp>

using namespace godot;

PlayerCharacter::PlayerCharacter() {
    move_speed = 50.0; // Velocidad inicial (Ajusten esto en el godot por si es muy rapido o lento)
    last_direction = Vector2(0, 1); // Mirando hacia abajo al inicio 
}

PlayerCharacter::~PlayerCharacter() {
    // Nada que limpiar por ahora xdxdxd
}

void PlayerCharacter::_bind_methods() {
    // Registramos la variable 'move_speed' para que aparezca en el Inspector
    ClassDB::bind_method(D_METHOD("set_move_speed", "p_speed"), &PlayerCharacter::set_move_speed);
    ClassDB::bind_method(D_METHOD("get_move_speed"), &PlayerCharacter::get_move_speed);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "move_speed"), "set_move_speed", "get_move_speed");
    // el metodo para que jesus pueda llamar a "personaje.get_last_direction()" para saber hacia donde mira el personaje
    ClassDB::bind_method(D_METHOD("get_last_direction"), &PlayerCharacter::get_last_direction); 
    // Para ver la flechita en el inspector para depurar
    ADD_PROPERTY(PropertyInfo(Variant::VECTOR2, "last_direction"), "", "get_last_direction");

}

void PlayerCharacter::_physics_process(double delta) {
    if (Engine::get_singleton()->is_editor_hint()) return;

    Input* input = Input::get_singleton();
    Vector2 direction = Vector2(0, 0);

    // 4 direcciones (Cruz)
    // Con if eso amarra mejor
    // Aquí: Derecha > Izquierda > Arriba > Abajo 
    
    if (input->is_action_pressed("ui_right")) {
        direction.x = 1;
    }
    else if (input->is_action_pressed("ui_left")) {
        direction.x = -1;
    }
    else if (input->is_action_pressed("ui_up")) {
        direction.y = -1; // Y negativo es arriba
    }
    else if (input->is_action_pressed("ui_down")) {
        direction.y = 1;
    }

    //  Al usar "else if", si mantienes W y D al mismo tiempo,
    // el personaje se movera a la derecha (porque es el primer if) y ignorará la W.
    // Nunca se moverá en diagonal boooomb waza me voy al lol

    // Aplicar velocidad (usando la variable 'move_speed') para mover al personaje
    set_velocity(direction * move_speed); 
    
    move_and_slide();

    // L]ogica de movimiento
    if (direction.length() > 0) {
        // Si nos estamos moviendo, actualizamos la memoria
        last_direction = direction.normalized(); // aqui se guarda el dato

        // Se aplica la velocidad
        set_velocity(last_direction * move_speed);
    } else {
        // Si no nos movemos, la velocidad es 0, epro 'last_direction' recuerda la ultima direccion
        set_velocity(Vector2(0, 0));
    }
    
    move_and_slide();
}

// Getters y Setters
void PlayerCharacter::set_move_speed(double p_speed) { move_speed = p_speed; }
double PlayerCharacter::get_move_speed() const { return move_speed; }
Vector2 PlayerCharacter::get_last_direction() const {
    return last_direction;
}