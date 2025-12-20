#include "rhythm_conductor.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

RhythmConductor::RhythmConductor() {
    bpm = 140.0; // Esto es el 
    song_position = 0.0;
    last_reported_beat = 0;
    sec_per_beat = 60.0 / bpm;
    music_player = nullptr;
}

RhythmConductor::~RhythmConductor() {
    // Limpieza si es necesaria
}

void RhythmConductor::_bind_methods() {
    // Se registra el beat (envía el número de beat actual)
    ClassDB::bind_method(D_METHOD("play_music"), &RhythmConductor::play_music);
    
    // Esto es para registrar las propiedades en el godot
    
    // Propiedad BPM
    ClassDB::bind_method(D_METHOD("set_bpm", "bpm"), &RhythmConductor::set_bpm);
    ClassDB::bind_method(D_METHOD("get_bpm"), &RhythmConductor::get_bpm);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "bpm"), "set_bpm", "get_bpm");

    // Propiedad Music Player (Para asignar el nodo de audio)
    ClassDB::bind_method(D_METHOD("set_music_player", "player"), &RhythmConductor::set_music_player);
    ClassDB::bind_method(D_METHOD("get_music_player"), &RhythmConductor::get_music_player);
    ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "music_player", PROPERTY_HINT_NODE_TYPE, "AudioStreamPlayer"), "set_music_player", "get_music_player");

    // Registramos la señal
    ADD_SIGNAL(MethodInfo("beat", PropertyInfo(Variant::INT, "beat_number")));
}

void RhythmConductor::play_music() {
    if (music_player) {
        music_player->play();
        last_reported_beat = -1;
    }
}

void RhythmConductor::_process(double delta) {
    if (!music_player || !music_player->is_playing()) {
        return;
    }

    // Obtenemos la posición exacta del audio (La sincronizacion)
    song_position = music_player->get_playback_position();
    
    // Ajuste de delay de audio (Segun se puede mejorar mas aqui pero eso lo veo mas tarde)
    song_position -= AudioServer::get_singleton()->get_output_latency();

    // Aqui pa calcular el beat actual
    if (bpm > 0) {
        double actual_beat = song_position / sec_per_beat;
        int beat_entero = (int)actual_beat;

        // Si hemos avanzado a un nuevo beat, emitimos la señal
        if (beat_entero > last_reported_beat) {
            last_reported_beat = beat_entero;
            emit_signal("beat", last_reported_beat);
            
            // Debug en consola para ver si funciona 
            UtilityFunctions::print("Golpe de Tambor: ", last_reported_beat);
        }
    }
}

// Getters y Setters
void RhythmConductor::set_bpm(double p_bpm) {
    bpm = p_bpm;
    if (bpm > 0) {
        sec_per_beat = 60.0 / bpm;
    }
}

double RhythmConductor::get_bpm() const {
    return bpm;
}

void RhythmConductor::set_music_player(AudioStreamPlayer *p_player) {
    music_player = p_player;
}

AudioStreamPlayer *RhythmConductor::get_music_player() const {
    return music_player;
}