#pragma once
#include "../src/Components.h"
//#include "../extern.h"
struct comp_elevator : Component
{
	int my_ent_id;
	int speed; //Velocitat de moviment de la plataforma
	lm::vec3 direction; //Direcció del moviment de la plataforma
	bool no_Automatic; //Si és automàtic la plataforma es mou sola si no, la plataforma es queda quieta

	lm::vec3 axis;
	// Data manipulation methods
	void Load(rapidjson::Value & entity, int ent_id);

	void update(float dt);
	void debugRender();
};