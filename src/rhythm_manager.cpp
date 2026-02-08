#include "rhythm_manager.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/audio_server.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/classes/time.hpp>

//  ¡IMPORTANTE! Faltaban estas dos librerías para poder guardar archivos
#include <godot_cpp/classes/file_access.hpp>
#include <godot_cpp/classes/json.hpp>

using namespace godot;

Array RhythmManager::get_all_notes() const {
    return level_notes;
}

RhythmManager::RhythmManager() {
    recording_mode = false; 
    note_scroll_speed = 2.0; // Valor por defecto
}

RhythmManager::~RhythmManager() {
}

void RhythmManager::_ready() {
    // Inicialización si fuera necesaria
}

void RhythmManager::set_music_player(AudioStreamPlayer* player) {
    music_player = player;
}

void RhythmManager::start_song() {
    if (music_player) {
        music_player->play();
        is_playing = true;
        current_note_index = 0; 
        
        if (recording_mode) {
            recorded_notes.clear();
            UtilityFunctions::print(">>> [REC] GRABANDO: Presiona las flechas al ritmo de los tambores...");
        } else {
            UtilityFunctions::print(">>> [PLAY] JUGANDO: Prepárate...");
        }
    }
}

void RhythmManager::_process(double delta) {
    if (!is_playing || !music_player) return;

    // 1. Obtener tiempo exacto compensando latencia
    double time = music_player->get_playback_position();
    time += AudioServer::get_singleton()->get_time_since_last_mix();
    time -= AudioServer::get_singleton()->get_output_latency();
    
    song_position = time;

    // 2. LOGICA DE JUEGO (SPAWNER) - Solo si NO estamos grabando
    if (!recording_mode) {
        while (current_note_index < level_notes.size()) {
            Dictionary note = level_notes[current_note_index];
            double spawn_time = (double)note["time"]; 
            
            // Verificamos si ya toca lanzar la nota para que llegue a tiempo
            if (song_position >= (spawn_time - note_scroll_speed)) {
    
    
                    emit_signal("spawn_note", note["type"], note_scroll_speed, spawn_time, current_note_index);
    
                    current_note_index++;
                } else {
                        // Si la siguiente nota está lejos, no seguimos revisando en este frame
                break;
            }
        }
    }
}

void RhythmManager::register_input(int input_type) {
    if (recording_mode && is_playing) {
        // --- MODO GRABACIÓN ---
        Dictionary note_data;
        note_data["time"] = song_position;
        note_data["type"] = input_type;
        
        recorded_notes.push_back(note_data);
        
        // Feedback visual en consola para saber que sí se guardó
        UtilityFunctions::print("Nota Guardada: ", input_type, " | Tiempo: ", song_position);
    } 
    else {
        // --- MODO JUEGO ---
        // Aquí validaremos el Hit/Miss en el futuro
    }
}

// Esta función permite guardar multiples archivos (facil.json, dificil.json)
// porque recibe el 'path' como argumento desde GDScript
void RhythmManager::save_recording(String path) {
    Ref<FileAccess> file = FileAccess::open(path, FileAccess::WRITE);
    if (file.is_valid()) {
        // El "\t" hace que el JSON sea legible (con tabulaciones)
        file->store_string(JSON::stringify(recorded_notes, "\t")); 
        file->close();
        UtilityFunctions::print(">>> ARCHIVO GUARDADO EXITOSAMENTE: ", path);
    } else {
        UtilityFunctions::print("ERROR CRÍTICO: No se pudo crear el archivo en ", path);
    }
}

void RhythmManager::load_level(String path) {
    Ref<FileAccess> file = FileAccess::open(path, FileAccess::READ);
    if (file.is_valid()) {
        String content = file->get_as_text();
        level_notes = JSON::parse_string(content);
        UtilityFunctions::print(">>> NIVEL CARGADO: ", level_notes.size(), " notas encontradas.");
    } else {
        UtilityFunctions::print("ERROR: No se encontró el nivel en ", path);
    }
}

void RhythmManager::set_recording_mode(bool p_value) { recording_mode = p_value; }
bool RhythmManager::get_recording_mode() const { return recording_mode; }

void RhythmManager::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_all_notes"), &RhythmManager::get_all_notes);
    ClassDB::bind_method(D_METHOD("set_music_player", "player"), &RhythmManager::set_music_player);
    ClassDB::bind_method(D_METHOD("start_song"), &RhythmManager::start_song);
    
    ClassDB::bind_method(D_METHOD("register_input", "input_type"), &RhythmManager::register_input);
    ClassDB::bind_method(D_METHOD("save_recording", "path"), &RhythmManager::save_recording);
    ClassDB::bind_method(D_METHOD("load_level", "path"), &RhythmManager::load_level);
    
    ClassDB::bind_method(D_METHOD("set_recording_mode", "p_value"), &RhythmManager::set_recording_mode);
    ClassDB::bind_method(D_METHOD("get_recording_mode"), &RhythmManager::get_recording_mode);
    
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "recording_mode"), "set_recording_mode", "get_recording_mode");

    // --- CORRECCIÓN AQUÍ ---
    // Borramos la versión vieja de 2 argumentos.
    // Solo dejamos esta ÚNICA versión de 4 argumentos:
    ADD_SIGNAL(MethodInfo("spawn_note", 
        PropertyInfo(Variant::INT, "type"), 
        PropertyInfo(Variant::FLOAT, "speed"),
        PropertyInfo(Variant::FLOAT, "hit_time"),
        PropertyInfo(Variant::INT, "id")
    ));
}