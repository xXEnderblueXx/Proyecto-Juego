#ifndef PLAYER_CHARACTER_H
#define PLAYER_CHARACTER_H

// 1. ZONA DE INCLUDES (Todo esto va FUERA del namespace)
#include <godot_cpp/classes/character_body2d.hpp>
#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/classes/ray_cast2d.hpp> // <--- Aquí está perfecto

// 2. AHORA SÍ ABRES EL NAMESPACE
namespace godot { 

class PlayerCharacter : public CharacterBody2D {
    GDCLASS(PlayerCharacter, CharacterBody2D)

private:
    double interaction_range = 100.0; // valor por defecto, puedes ajustarlo en el Inspector
    bool can_move = true;
    double move_speed;
    Vector2 last_direction;
    RayCast2D* interaction_raycast = nullptr; // Variable del rayo

protected:
    static void _bind_methods();

public:
    void set_interaction_range(double p_range);
    double get_interaction_range() const;
    void set_can_move(bool p_can_move);
    bool get_can_move() const;
    PlayerCharacter();
    ~PlayerCharacter();

    void _physics_process(double delta) override;

    void set_move_speed(const double p_speed);
    double get_move_speed() const;
    Vector2 get_last_direction() const;

    void interact();           // Tu nueva función
    void _ready() override;    // La corrección que hicimos antes
};

} // Cierre del namespace godot

#endif // Cierre del ifndef