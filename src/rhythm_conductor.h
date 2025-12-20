#ifndef RHYTHM_CONDUCTOR_H
#define RHYTHM_CONDUCTOR_H

#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/classes/audio_stream_player.hpp>

namespace godot {

class RhythmConductor : public Node {
    GDCLASS(RhythmConductor, Node)

private:
    double bpm;                 // Golpes por minuto (Velocidad del tambor)
    double song_position;       // En qué segundo va la canción
    double sec_per_beat;        // Cuántos segundos dura un beat
    int last_reported_beat;     // Para no repetir la señal en el mismo beat
    
    // Referencia al reproductor de música
    AudioStreamPlayer *music_player; 

protected:
    static void _bind_methods(); // Aqui se registra  las variables para el Editor

public:
    RhythmConductor();
    ~RhythmConductor();

    void _process(double delta) override; // Se ejecuta en cada frame
    
    // Funciones para que Jesus las use
    void play_music();
    void set_bpm(double p_bpm);
    double get_bpm() const;
    
    // Esto se asigna del nodo de audio desde el Editor
    void set_music_player(AudioStreamPlayer *p_player);
    AudioStreamPlayer *get_music_player() const;

    // Señales 
    // Se emite un beat cada que suene un tambor
};

}

#endif