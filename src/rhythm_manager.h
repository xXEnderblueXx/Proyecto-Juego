#ifndef RHYTHM_MANAGER_H
#define RHYTHM_MANAGER_H

#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/classes/audio_stream_player.hpp>
#include <godot_cpp/classes/file_access.hpp>
#include <godot_cpp/classes/json.hpp>

namespace godot {

class RhythmManager : public Node {
    GDCLASS(RhythmManager, Node)

private:
    AudioStreamPlayer* music_player = nullptr;
    
    double song_position = 0.0;
    bool is_playing = false;
    
    // Configuración
    double note_scroll_speed = 2.0; // Segundos que tarda la nota en llegar al hit point
    
    // --- MODO GRABACIÓN ---
    bool recording_mode = false; // Si es true, guarda inputs. Si es false, spawnea notas.
    Array recorded_notes;        // Aquí guardamos lo que grabes

    // --- MODO JUEGO ---
    Array level_notes;           // Las notas cargadas del nivel
    int current_note_index = 0;  // Por cuál nota vamos

protected:
    static void _bind_methods();

public:
    RhythmManager();
    ~RhythmManager();

    void _ready() override;
    void _process(double delta) override;
    Array get_all_notes() const;
    // Configuración
    void set_music_player(AudioStreamPlayer* player);
    void start_song();
    
    // Funciones de Archivos
    void save_recording(String path);
    void load_level(String path);

    // Inputs (Sirve para Jugar y para Grabar)
    void register_input(int input_type); 

    // Setters/Getters
    void set_recording_mode(bool p_value);
    bool get_recording_mode() const;
};

}

#endif