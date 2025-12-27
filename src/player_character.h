#ifndef PLAYER_CHARACTER_H
#define PLAYER_CHARACTER_H

#include <godot_cpp/classes/character_body2d.hpp>
#include <godot_cpp/classes/input.hpp>

namespace godot {

class PlayerCharacter : public CharacterBody2D {
    GDCLASS(PlayerCharacter, CharacterBody2D)

private:
    double move_speed; // Velocidad de movimiento
    Vector2 last_direction; 
protected:
    static void _bind_methods();

public:
    PlayerCharacter();
    ~PlayerCharacter();

    void _physics_process(double delta) override; // Esto es como para que se actualice cada frame de física

    // Para poder cambiar la velocidad desde el editor de Godot o desde otros scripts
    void set_move_speed(const double p_speed);
    double get_move_speed() const;

    //Getter para VO JESUS xdxdxd, este lo lees desde GDScript
    Vector2 get_last_direction() const;
};

}

#endif