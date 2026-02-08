#include "rhythm_manager.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/audio_server.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/classes/time.hpp>
#include <godot_cpp/classes/file_access.hpp>
#include <godot_cpp/classes/json.hpp>

using namespace godot;

RhythmManager::RhythmManager() {
    recording_mode = false; 
    note_scroll_speed = 2.0; 
}

RhythmManager::~RhythmManager() {
}

void RhythmManager::_ready() {
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
            UtilityFunctions::print(">>> [REC] GRABANDO...");
        } else {
            UtilityFunctions::print(">>> [PLAY] JUGANDO...");
        }
    }
}

void RhythmManager::_process(double delta) {
    if (!is_playing || !music_player) return;

    double time = music_player->get_playback_position();
    time += AudioServer::get_singleton()->get_time_since_last_mix();
    time -= AudioServer::get_singleton()->get_output_latency();
    
    song_position = time;

    if (!recording_mode) {
        while (current_note_index < level_notes.size()) {
            Dictionary note = level_notes[current_note_index];
            double spawn_time = (double)note["time"]; 
            
            if (song_position >= (spawn_time - note_scroll_speed)) {
                emit_signal("spawn_note", note["type"], note_scroll_speed, spawn_time, current_note_index);
                current_note_index++;
            } else {
                break;
            }
        }
    }
}

void RhythmManager::register_input(int input_type) {
    if (recording_mode && is_playing) {
        Dictionary note_data;
        note_data["time"] = song_position;
        note_data["type"] = input_type;
        recorded_notes.push_back(note_data);
        UtilityFunctions::print("Nota Guardada: ", input_type, " | Tiempo: ", song_position);
    } 
}

void RhythmManager::save_recording(String path) {
    Ref<FileAccess> file = FileAccess::open(path, FileAccess::WRITE);
    if (file.is_valid()) {
        file->store_string(JSON::stringify(recorded_notes, "\t")); 
        file->close();
        UtilityFunctions::print(">>> GUARDADO: ", path);
    } else {
        UtilityFunctions::print("ERROR CRÍTICO: No se pudo crear ", path);
    }
}

void RhythmManager::load_level(String path) {
    Ref<FileAccess> file = FileAccess::open(path, FileAccess::READ);
    if (file.is_valid()) {
        String content = file->get_as_text();
        level_notes = JSON::parse_string(content);
        
        // --- IMPORTANTE: Copiamos las notas para poder editarlas ---
        recorded_notes = level_notes.duplicate();
        
        UtilityFunctions::print(">>> NIVEL CARGADO: ", level_notes.size(), " notas.");
    } else {
        UtilityFunctions::print("ERROR: No se encontró ", path);
    }
}

Array RhythmManager::get_all_notes() const {
    return level_notes;
}

void RhythmManager::set_recording_mode(bool p_value) { recording_mode = p_value; }
bool RhythmManager::get_recording_mode() const { return recording_mode; }

// --- AQUÍ LA LÓGICA DE ACTUALIZAR TIEMPO (Fuera de bind_methods) ---
void RhythmManager::update_note_time(int id, double new_time) {
    if (id >= 0 && id < recorded_notes.size()) {
        Dictionary note = recorded_notes[id];
        note["time"] = new_time;
        recorded_notes[id] = note;
        
        // Actualizamos también la lista de reproducción si existe
        if (id < level_notes.size()) {
            level_notes[id] = note;
        }
    }
}

void RhythmManager::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_all_notes"), &RhythmManager::get_all_notes);
    ClassDB::bind_method(D_METHOD("set_music_player", "player"), &RhythmManager::set_music_player);
    ClassDB::bind_method(D_METHOD("start_song"), &RhythmManager::start_song);
    
    ClassDB::bind_method(D_METHOD("register_input", "input_type"), &RhythmManager::register_input);
    ClassDB::bind_method(D_METHOD("save_recording", "path"), &RhythmManager::save_recording);
    ClassDB::bind_method(D_METHOD("load_level", "path"), &RhythmManager::load_level);
    
    // --- REGISTRAMOS LA NUEVA FUNCIÓN ---
    ClassDB::bind_method(D_METHOD("update_note_time", "id", "new_time"), &RhythmManager::update_note_time);
    
    ClassDB::bind_method(D_METHOD("set_recording_mode", "p_value"), &RhythmManager::set_recording_mode);
    ClassDB::bind_method(D_METHOD("get_recording_mode"), &RhythmManager::get_recording_mode);
    
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "recording_mode"), "set_recording_mode", "get_recording_mode");

    ADD_SIGNAL(MethodInfo("spawn_note", 
        PropertyInfo(Variant::INT, "type"), 
        PropertyInfo(Variant::FLOAT, "speed"),
        PropertyInfo(Variant::FLOAT, "hit_time"),
        PropertyInfo(Variant::INT, "id")
    ));
}