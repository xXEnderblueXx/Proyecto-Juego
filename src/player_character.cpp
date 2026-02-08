#include "player_character.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/engine.hpp>

using namespace godot;

PlayerCharacter::PlayerCharacter() {
    move_speed = 200.0;
    can_move = true;
    last_direction = Vector2(0, 1); // Mirando abajo por defecto
}

PlayerCharacter::~PlayerCharacter() {
    // Nada que limpiar
}

void PlayerCharacter::_ready() {
    if (Engine::get_singleton()->is_editor_hint()) return;

    interaction_raycast = get_node<RayCast2D>("InteractionRayCast");
    
    if (interaction_raycast) {
        interaction_raycast->set_enabled(true);
        // Dejamos que la configuración del Editor (Inspector) decida qué capas ver
        // Asegúrate en Godot que "Collide With Areas" y "Bodies" estén activados.
    }
}

void PlayerCharacter::_physics_process(double delta) {
    if (Engine::get_singleton()->is_editor_hint()) return;

    Input* input = Input::get_singleton();

    // 1. SISTEMA DE BLOQUEO (Para diálogos, cinemáticas, etc)
    if (!can_move) {
        set_velocity(Vector2(0, 0));
        move_and_slide();
        return; 
    }

    // 2. MOVIMIENTO (4 Direcciones estrictas)
    Vector2 input_dir = Vector2(0, 0);

    // Nota: Usar get_vector es más moderno, pero tu lógica manual está bien para 4 direcciones
    if (input->is_action_pressed("ui_right")) {
        input_dir.x = 1;
    } else if (input->is_action_pressed("ui_left")) {
        input_dir.x = -1;
    } else if (input->is_action_pressed("ui_down")) {
        input_dir.y = 1;
    } else if (input->is_action_pressed("ui_up")) {
        input_dir.y = -1;
    }

    Vector2 velocity = input_dir * move_speed;
    set_velocity(velocity);
    move_and_slide();

    // 3. ACTUALIZAR RAYCAST (Dirección)
    // Solo actualizamos la dirección si nos estamos moviendo
    if (velocity.length() > 0) {
        last_direction = velocity.normalized();
    }

    if (interaction_raycast) {
        // Multiplicamos por 100 (o 50) según el tamaño de tus tiles
        // Asegúrate de que interaction_raycast esté inicializado en _ready()
        interaction_raycast->set_target_position(last_direction * 100);
    }

    // 4. INTERACCIÓN (ELIMINADO AQUÍ)
    // Ya no detectamos "interact" aquí porque lo hace GDScript en _input.
    // Esto evita que se ejecute dos veces o se cancele a sí mismo.
    
    /* if (input->is_action_just_pressed("interact")) {
        interact();
    }
    */
}



void PlayerCharacter::interact() {
    if (!interaction_raycast) return;

    interaction_raycast->force_raycast_update();

    if (interaction_raycast->is_colliding()) {
        Object* collider = interaction_raycast->get_collider();
        
        // --- CHIVATO DE C++ ---
        if (collider) {
            // Esto imprimirá el nombre del objeto con el que choca en la consola de Godot
            UtilityFunctions::print("Raycast choco con: ", collider->get_class());
            
            if (collider->has_method("activar")) {
                collider->call("activar");
                UtilityFunctions::print("Metodo 'activar' llamado con exito!");
            } else {
                UtilityFunctions::print("El objeto no tiene el metodo 'activar'");
            }
        }
    } else {
        UtilityFunctions::print("El Raycast no esta chocando con NADA.");
    }
}
/*  void PlayerCharacter::interact() {
    if (!interaction_raycast) return;

    // CRÍTICO: Forzamos actualización para precisión instantánea
    interaction_raycast->force_raycast_update();

    if (interaction_raycast->is_colliding()) {
        Object* collider = interaction_raycast->get_collider();
        
        if (collider) {
            // Si el objeto tiene el script con 'activar', lo ejecutamos
            if (collider->has_method("activar")) {
                collider->call("activar");
            }
        }
    }
}
*/
// --- GETTERS Y SETTERS ---
void PlayerCharacter::set_can_move(bool p_value) { can_move = p_value; }
bool PlayerCharacter::get_can_move() const { return can_move; }

void PlayerCharacter::set_move_speed(double p_speed) { move_speed = p_speed; }
double PlayerCharacter::get_move_speed() const { return move_speed; }

Vector2 PlayerCharacter::get_last_direction() const { return last_direction; }


// --- REGISTRO DE MÉTODOS PARA GODOT ---
void PlayerCharacter::_bind_methods() {
    
    // Propiedad: Velocidad
    ClassDB::bind_method(D_METHOD("get_move_speed"), &PlayerCharacter::get_move_speed);
    ClassDB::bind_method(D_METHOD("set_move_speed", "p_speed"), &PlayerCharacter::set_move_speed);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "move_speed"), "set_move_speed", "get_move_speed");
    
    // Propiedad: Puede Moverse (Para diálogos)
    ClassDB::bind_method(D_METHOD("get_can_move"), &PlayerCharacter::get_can_move);
    ClassDB::bind_method(D_METHOD("set_can_move", "p_can_move"), &PlayerCharacter::set_can_move);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "can_move"), "set_can_move", "get_can_move");

    // Propiedad: Última Dirección (Solo lectura en inspector, útil para debug)
    ClassDB::bind_method(D_METHOD("get_last_direction"), &PlayerCharacter::get_last_direction); 
    ADD_PROPERTY(PropertyInfo(Variant::VECTOR2, "last_direction"), "", "get_last_direction");

    // Función: Interactuar (Por si se quiere llamar desde otro script)
    ClassDB::bind_method(D_METHOD("interact"), &PlayerCharacter::interact);
}